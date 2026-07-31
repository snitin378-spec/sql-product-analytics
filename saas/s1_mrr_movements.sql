/*
Business Question:
How did Monthly Recurring Revenue change each month, and what drove
the movement: new, expansion, contraction, churn, or reactivation?

What This Tells Us:
This query decomposes monthly MRR movement and calculates Net New MRR
and the cumulative Ending MRR balance.

PM Action:
Investigate the month with the largest negative churn or contraction
movement by account type, plan, and customer cohort.

Sanity Check:
Ending MRR for month N should equal the previous month's Ending MRR
plus the current month's Net New MRR.
*/

WITH eligible_events AS (

    SELECT
        se.event_id,
        se.account_id,
        se.event_type,
        se.event_time,
        se.from_plan,
        se.to_plan,
        COALESCE(se.mrr_delta, 0) AS mrr_delta,
        se.seats_delta
    FROM saas.subscription_events AS se

    -- Exclude future-dated legacy events
    WHERE se.event_time < CURRENT_DATE + INTERVAL '1 day'
),

classified_events AS (

    SELECT
        DATE_TRUNC('month', e.event_time)::date AS month,
        e.account_id,
        e.event_type,
        e.mrr_delta,

        CASE
            -- Reactivation: the account previously cancelled and later restarted
            WHEN e.event_type IN (
                    'subscription_started',
                    'trial_converted'
                 )
                 AND e.mrr_delta > 0
                 AND EXISTS (
                     SELECT 1
                     FROM eligible_events AS previous_event
                     WHERE previous_event.account_id = e.account_id
                       AND previous_event.event_type = 'cancelled'
                       AND previous_event.event_time < e.event_time
                 )
                THEN 'reactivation_mrr'

            -- First paid subscription
            WHEN e.event_type IN (
                    'subscription_started',
                    'trial_converted'
                 )
                 AND e.mrr_delta > 0
                THEN 'new_mrr'

            -- Seat additions and add-ons
            WHEN e.event_type IN (
                    'seat_add',
                    'addon_attach'
                 )
                 AND e.mrr_delta > 0
                THEN 'expansion_mrr'

            -- Plan upgrade
            WHEN e.event_type = 'plan_changed'
                 AND e.mrr_delta > 0
                THEN 'expansion_mrr'

            -- Plan downgrade
            WHEN e.event_type = 'plan_changed'
                 AND e.mrr_delta < 0
                THEN 'contraction_mrr'

            -- Cancellation
            WHEN e.event_type = 'cancelled'
                 AND e.mrr_delta < 0
                THEN 'churn_mrr'

            -- Free subscriptions, trial starts and zero-MRR events
            ELSE 'excluded'
        END AS mrr_bucket

    FROM eligible_events AS e
),

monthly_movements AS (

    SELECT
        month,

        SUM(
            CASE
                WHEN mrr_bucket = 'new_mrr'
                THEN mrr_delta
                ELSE 0
            END
        ) AS new_mrr,

        SUM(
            CASE
                WHEN mrr_bucket = 'expansion_mrr'
                THEN mrr_delta
                ELSE 0
            END
        ) AS expansion_mrr,

        SUM(
            CASE
                WHEN mrr_bucket = 'contraction_mrr'
                THEN mrr_delta
                ELSE 0
            END
        ) AS contraction_mrr,

        SUM(
            CASE
                WHEN mrr_bucket = 'churn_mrr'
                THEN mrr_delta
                ELSE 0
            END
        ) AS churn_mrr,

        SUM(
            CASE
                WHEN mrr_bucket = 'reactivation_mrr'
                THEN mrr_delta
                ELSE 0
            END
        ) AS reactivation_mrr

    FROM classified_events
    GROUP BY month
),

net_mrr_movements AS (

    SELECT
        month,
        new_mrr,
        expansion_mrr,
        contraction_mrr,
        churn_mrr,
        reactivation_mrr,

        new_mrr
        + expansion_mrr
        + contraction_mrr
        + churn_mrr
        + reactivation_mrr AS net_new_mrr

    FROM monthly_movements
)

SELECT
    month,

    ROUND(new_mrr, 2) AS new_mrr,
    ROUND(expansion_mrr, 2) AS expansion_mrr,
    ROUND(contraction_mrr, 2) AS contraction_mrr,
    ROUND(churn_mrr, 2) AS churn_mrr,
    ROUND(reactivation_mrr, 2) AS reactivation_mrr,
    ROUND(net_new_mrr, 2) AS net_new_mrr,

    ROUND(
        SUM(net_new_mrr) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS ending_mrr

FROM net_mrr_movements
ORDER BY month;
