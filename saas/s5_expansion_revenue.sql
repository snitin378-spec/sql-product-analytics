/*
S5 — Expansion Revenue: Who Is Expanding and Why?

Business Question:
Which expansion motion contributes the most recurring revenue:
seat additions, plan upgrades, or add-on purchases?

What This Tells Us:
The query classifies positive expansion events into three commercial
motions and measures event volume, accounts expanded, total expansion
MRR, expansion MRR per account, and median time from account signup
to expansion.

PM Action:
Use the dominant expansion motion to guide product investment.
If seat additions generate the most expansion MRR, prioritize
seat-management UX, admin controls, and prompts that help growing
accounts invite additional users.

Sanity Check:
1. Every included event must have mrr_delta > 0.
2. The total expansion MRR must reconcile exactly with S1 for the
   same reporting window and event classification.
3. Events after 15-Jun-2026 must be excluded.
*/

WITH parameters AS (
    SELECT
        TIMESTAMP '2026-06-15 23:59:59' AS reporting_cutoff
),

expansion_events AS (
    SELECT
        se.event_id,
        se.event_time,
        se.event_type,
        se.account_id,
        se.from_plan,
        se.to_plan,
        se.seats_delta,
        se.mrr_delta,
        a.signup_date,

        CASE
            WHEN se.event_type = 'seat_add'
                THEN 'seats_added'

            WHEN se.event_type = 'plan_changed'
             AND se.mrr_delta > 0
                THEN 'plan_upgrade'

            WHEN se.event_type = 'addon_attach'
                THEN 'addon'
        END AS expansion_type,

        EXTRACT(
            EPOCH FROM (
                se.event_time - a.signup_date
            )
        ) / 86400.0 AS days_from_signup_to_expansion

    FROM saas.subscription_events AS se

    JOIN saas.accounts AS a
        ON se.account_id = a.account_id

    CROSS JOIN parameters AS p

    WHERE se.event_time <= p.reporting_cutoff
      AND se.mrr_delta > 0

      AND (
            se.event_type IN (
                'seat_add',
                'addon_attach'
            )

            OR se.event_type = 'plan_changed'
          )
),

expansion_summary AS (
    SELECT
        expansion_type,

        COUNT(*) AS expansion_events,

        COUNT(DISTINCT account_id)
            AS accounts_expanded,

        SUM(mrr_delta)
            AS expansion_mrr_total,

        SUM(mrr_delta)
        / NULLIF(COUNT(DISTINCT account_id), 0)
            AS expansion_mrr_per_account,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY days_from_signup_to_expansion
        ) AS median_days_from_signup_to_expansion

    FROM expansion_events

    GROUP BY expansion_type
)

SELECT
    expansion_type,
    expansion_events,
    accounts_expanded,

    ROUND(
        expansion_mrr_total,
        2
    ) AS expansion_mrr_total,

    ROUND(
        expansion_mrr_per_account,
        2
    ) AS expansion_mrr_per_account,

    ROUND(
        median_days_from_signup_to_expansion::numeric,
        2
    ) AS median_days_from_signup_to_expansion

FROM expansion_summary

ORDER BY expansion_mrr_total DESC;