/*
Business Question:
Where is expansion revenue coming from?

What This Tells Us:
Shows which expansion activities generate the
most recurring revenue.

PM Action:
Focus sales and product efforts on the highest
performing expansion opportunities.

Sanity Check:
Expansion revenue should only include positive
MRR changes.
*/

WITH expansion_events AS (

    SELECT
        event_time,
        event_type,
        account_id,
        from_plan,
        to_plan,
        seats_delta,
        mrr_delta

    FROM saas.subscription_events

    WHERE event_type IN (
        'plan_changed',
        'seat_add',
        'addon_attach'
    )

      AND mrr_delta > 0

),

expansion_summary AS (

    SELECT

        CASE

            WHEN event_type='plan_changed'
                THEN 'Plan Upgrade'

            WHEN event_type='seat_add'
                THEN 'Seat Expansion'

            WHEN event_type='addon_attach'
                THEN 'Add-on'

        END AS expansion_type,

        COUNT(*) AS events,

        COUNT(DISTINCT account_id) AS accounts,

        SUM(mrr_delta) AS expansion_mrr,

        AVG(mrr_delta) AS avg_expansion_mrr,

        MAX(mrr_delta) AS largest_expansion

    FROM expansion_events

    GROUP BY
        expansion_type

),

upgrade_paths AS (

    SELECT

        LOWER(from_plan) AS from_plan,

        LOWER(to_plan) AS to_plan,

        COUNT(*) AS upgrades,

        SUM(mrr_delta) AS expansion_mrr

    FROM expansion_events

    WHERE event_type='plan_changed'

    GROUP BY
        LOWER(from_plan),
        LOWER(to_plan)

)

SELECT

    expansion_type,

    events,

    accounts,

    ROUND(expansion_mrr,2) AS expansion_mrr,

    ROUND(avg_expansion_mrr,2) AS avg_expansion_mrr,

    ROUND(largest_expansion,2) AS largest_expansion

FROM expansion_summary

ORDER BY expansion_mrr DESC;
