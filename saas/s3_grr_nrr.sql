/*
Business Question:
For each monthly customer cohort, how much of the original MRR
remained after 12 months, and how much changed through expansion,
contraction or churn?

What This Tells Us:
GRR shows how much starting revenue was retained without counting
expansion. NRR shows total revenue retained after including expansion.

PM Action:
If GRR is below 80%, investigate churn and contraction by account type,
plan and cohort. If NRR is above 110%, identify the accounts and
expansion motions driving the increase.

Sanity Checks:
1. GRR must never exceed 100%.
2. NRR may exceed 100%.
3. retained_mrr_12m + contraction_mrr_12m + churn_mrr_12m
   should approximately equal cohort_starting_mrr.
4. ending_mrr_12m =
   retained_mrr_12m + expansion_mrr_12m.
*/

WITH eligible_events AS (

    SELECT
        event_id,
        account_id,
        event_type,
        event_time,
        mrr_delta
    FROM saas.subscription_events
    WHERE account_id IS NOT NULL

      -- Exclude future-dated legacy events
      AND event_time < CURRENT_DATE + INTERVAL '1 day'
),

first_paid_event AS (

    /*
    Find the first positive paid event for each account.

    ROW_NUMBER is safer than joining only on MIN(event_time),
    because two events could share the same timestamp.
    */

    SELECT
        account_id,
        event_id,
        event_time AS first_paid_at,
        DATE_TRUNC('month', event_time)::date AS cohort_month,
        mrr_delta AS starting_mrr
    FROM (
        SELECT
            account_id,
            event_id,
            event_time,
            mrr_delta,

            ROW_NUMBER() OVER (
                PARTITION BY account_id
                ORDER BY event_time, event_id
            ) AS paid_event_number

        FROM eligible_events
        WHERE event_type IN (
                  'subscription_started',
                  'trial_converted'
              )
          AND mrr_delta > 0
    ) AS ranked_paid_events

    WHERE paid_event_number = 1
),

account_mrr_after_12m AS (

    /*
    Reconstruct each account's MRR after 12 months by adding all
    signed MRR movements from its first paid event through the
    12-month anniversary.

    Positive movements add MRR.
    Negative movements reduce MRR.
    */

    SELECT
        fp.account_id,
        fp.cohort_month,
        fp.first_paid_at,
        fp.starting_mrr,

        fp.first_paid_at + INTERVAL '12 months'
            AS twelve_month_date,

        SUM(
            COALESCE(e.mrr_delta, 0)
        ) AS calculated_mrr_12m

    FROM first_paid_event AS fp

    LEFT JOIN eligible_events AS e
        ON e.account_id = fp.account_id
       AND e.event_time >= fp.first_paid_at
       AND e.event_time <= fp.first_paid_at + INTERVAL '12 months'

    /*
    Exclude immature cohorts whose full 12-month observation
    period has not yet closed.
    */
    WHERE fp.first_paid_at + INTERVAL '12 months'
          < CURRENT_DATE + INTERVAL '1 day'

    GROUP BY
        fp.account_id,
        fp.cohort_month,
        fp.first_paid_at,
        fp.starting_mrr
),

account_retention_components AS (

    /*
    Prevent negative ending MRR caused by unusual or duplicated
    negative events. Economically, an account cannot have MRR below 0.
    */

    SELECT
        account_id,
        cohort_month,
        starting_mrr,

        GREATEST(calculated_mrr_12m, 0) AS ending_mrr_12m,

        /*
        Retained base revenue:
        The smaller of starting and ending MRR, provided the account
        is still paying.
        */
        CASE
            WHEN calculated_mrr_12m > 0
            THEN LEAST(starting_mrr, calculated_mrr_12m)
            ELSE 0
        END AS retained_mrr_12m,

        /*
        Expansion:
        Ending MRR above starting MRR.
        */
        CASE
            WHEN calculated_mrr_12m > starting_mrr
            THEN calculated_mrr_12m - starting_mrr
            ELSE 0
        END AS expansion_mrr_12m,

        /*
        Contraction:
        Account still pays, but less than it originally paid.
        */
        CASE
            WHEN calculated_mrr_12m > 0
             AND calculated_mrr_12m < starting_mrr
            THEN starting_mrr - calculated_mrr_12m
            ELSE 0
        END AS contraction_mrr_12m,

        /*
        Churn:
        Account's ending MRR is zero.
        */
        CASE
            WHEN calculated_mrr_12m <= 0
            THEN starting_mrr
            ELSE 0
        END AS churn_mrr_12m

    FROM account_mrr_after_12m
),

cohort_retention AS (

    SELECT
        cohort_month,

        COUNT(*) AS cohort_accounts,

        SUM(starting_mrr) AS cohort_starting_mrr,

        SUM(retained_mrr_12m) AS retained_mrr_12m,

        SUM(expansion_mrr_12m) AS expansion_mrr_12m,

        SUM(contraction_mrr_12m) AS contraction_mrr_12m,

        SUM(churn_mrr_12m) AS churn_mrr_12m,

        SUM(ending_mrr_12m) AS ending_mrr_12m

    FROM account_retention_components
    GROUP BY cohort_month
)

SELECT
    cohort_month,
    cohort_accounts,

    ROUND(cohort_starting_mrr, 2)
        AS cohort_starting_mrr,

    ROUND(retained_mrr_12m, 2)
        AS retained_mrr_12m,

    ROUND(expansion_mrr_12m, 2)
        AS expansion_mrr_12m,

    ROUND(contraction_mrr_12m, 2)
        AS contraction_mrr_12m,

    ROUND(churn_mrr_12m, 2)
        AS churn_mrr_12m,

    ROUND(ending_mrr_12m, 2)
        AS ending_mrr_12m,

    /*
    GRR excludes expansion.
    This is equivalent to:

    starting MRR - contraction - churn
    ----------------------------------
               starting MRR
    */
    ROUND(
        (
            cohort_starting_mrr
            - contraction_mrr_12m
            - churn_mrr_12m
        )
        / NULLIF(cohort_starting_mrr, 0),
        4
    ) AS grr,

    /*
    NRR includes expansion.

    ending MRR
    ----------
    starting MRR
    */
    ROUND(
        ending_mrr_12m
        / NULLIF(cohort_starting_mrr, 0),
        4
    ) AS nrr,

    /*
    Percentage versions for easier reading in Metabase.
    */
    ROUND(
        (
            cohort_starting_mrr
            - contraction_mrr_12m
            - churn_mrr_12m
        )
        * 100.0
        / NULLIF(cohort_starting_mrr, 0),
        2
    ) AS grr_pct,

    ROUND(
        ending_mrr_12m
        * 100.0
        / NULLIF(cohort_starting_mrr, 0),
        2
    ) AS nrr_pct

FROM cohort_retention
ORDER BY cohort_month;
