/*
S3 — Gross Revenue Retention and Net Revenue Retention by Cohort

Business Question:
For each monthly customer cohort, how much of the original MRR
remained after 12 months, and how much changed through expansion,
contraction, or churn?

What This Tells Us:
GRR measures how much starting revenue remains after churn and
contraction, excluding expansion. NRR includes expansion and shows
whether retained accounts grew enough to offset lost revenue.

PM Action:
The September 2022 cohort previously produced 92.64% GRR and
113.95% NRR. Review the account types, plans, seat additions, and
upgrade events in that cohort to identify the expansion behaviour
that pushed NRR above 100%, then test whether the same customer-success
motion can be applied to lower-performing cohorts.

Sanity Checks:
1. GRR must never exceed 1.0.
2. NRR may exceed 1.0.
3. retained_mrr_12m + contraction_mrr_12m + churn_mrr_12m
   should equal cohort_starting_mrr.
4. ending_mrr_12m =
   retained_mrr_12m + expansion_mrr_12m.
5. Only cohorts with a complete 12-month observation window as of
   15-Jun-2026 are included.
*/

WITH parameters AS (
    SELECT
        TIMESTAMP '2026-06-15 23:59:59' AS reporting_cutoff
),

eligible_events AS (
    SELECT
        se.event_id,
        se.account_id,
        se.event_type,
        se.event_time,
        COALESCE(se.mrr_delta, 0) AS mrr_delta

    FROM saas.subscription_events AS se

    CROSS JOIN parameters AS p

    WHERE se.account_id IS NOT NULL
      AND se.event_time <= p.reporting_cutoff
),

first_paid_event AS (
    /*
    Find each account's first positive paid event.

    ROW_NUMBER avoids duplicate matches if multiple events share
    the same timestamp.
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

mature_first_paid_accounts AS (
    /*
    Include only accounts whose complete 12-month observation
    window had closed by the reporting cutoff.
    */
    SELECT
        fp.account_id,
        fp.cohort_month,
        fp.first_paid_at,
        fp.starting_mrr,
        fp.first_paid_at + INTERVAL '12 months' AS twelve_month_date

    FROM first_paid_event AS fp

    CROSS JOIN parameters AS p

    WHERE fp.first_paid_at + INTERVAL '12 months'
          <= p.reporting_cutoff
),

account_mrr_after_12m AS (
    /*
    Reconstruct MRR at the account's 12-month anniversary by
    summing all signed MRR movements from first paid event through
    the anniversary date.
    */
    SELECT
        mfp.account_id,
        mfp.cohort_month,
        mfp.first_paid_at,
        mfp.starting_mrr,
        mfp.twelve_month_date,

        SUM(
            COALESCE(e.mrr_delta, 0)
        ) AS calculated_mrr_12m

    FROM mature_first_paid_accounts AS mfp

    LEFT JOIN eligible_events AS e
        ON e.account_id = mfp.account_id
       AND e.event_time >= mfp.first_paid_at
       AND e.event_time <= mfp.twelve_month_date

    GROUP BY
        mfp.account_id,
        mfp.cohort_month,
        mfp.first_paid_at,
        mfp.starting_mrr,
        mfp.twelve_month_date
),

account_retention_components AS (
    SELECT
        account_id,
        cohort_month,
        starting_mrr,

        GREATEST(calculated_mrr_12m, 0)
            AS ending_mrr_12m,

        /*
        Retained base MRR is capped at starting MRR.
        Expansion is calculated separately.
        */
        CASE
            WHEN calculated_mrr_12m > 0
            THEN LEAST(starting_mrr, calculated_mrr_12m)
            ELSE 0
        END AS retained_mrr_12m,

        /*
        Expansion occurs when ending MRR exceeds starting MRR.
        */
        CASE
            WHEN calculated_mrr_12m > starting_mrr
            THEN calculated_mrr_12m - starting_mrr
            ELSE 0
        END AS expansion_mrr_12m,

        /*
        Contraction occurs when the account remains paying,
        but at a lower MRR.
        */
        CASE
            WHEN calculated_mrr_12m > 0
             AND calculated_mrr_12m < starting_mrr
            THEN starting_mrr - calculated_mrr_12m
            ELSE 0
        END AS contraction_mrr_12m,

        /*
        Churn occurs when ending MRR is zero or below.
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

        SUM(starting_mrr)
            AS cohort_starting_mrr,

        SUM(retained_mrr_12m)
            AS retained_mrr_12m,

        SUM(expansion_mrr_12m)
            AS expansion_mrr_12m,

        SUM(contraction_mrr_12m)
            AS contraction_mrr_12m,

        SUM(churn_mrr_12m)
            AS churn_mrr_12m,

        SUM(ending_mrr_12m)
            AS ending_mrr_12m

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

    ROUND(
        (
            cohort_starting_mrr
            - contraction_mrr_12m
            - churn_mrr_12m
        )
        / NULLIF(cohort_starting_mrr, 0),
        4
    ) AS grr,

    ROUND(
        ending_mrr_12m
        / NULLIF(cohort_starting_mrr, 0),
        4
    ) AS nrr,

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