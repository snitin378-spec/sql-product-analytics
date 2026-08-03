/*
Business Question:
Which product features have the highest adoption,
and do customers who adopt features remain active?

What This Tells Us:
Measures feature adoption by account and compares
retention between adopters and non-adopters.

PM Action:
Increase onboarding for features with low adoption
but high retention impact.

Sanity Check:
adopted_accounts <= total_accounts
adoption_rate <= 100%
*/

WITH total_accounts AS (

    SELECT
        COUNT(DISTINCT account_id) AS total_accounts
    FROM saas.accounts

),

feature_usage AS (

    SELECT DISTINCT
        e.account_id,
        f.feature_name,
        f.category
    FROM saas.events e
    JOIN saas.features f
      ON e.feature_id = f.feature_id
    WHERE e.event_type = 'feature_use'

),

feature_summary AS (

    SELECT
        fu.feature_name,
        fu.category,

        COUNT(DISTINCT fu.account_id) AS adopted_accounts,

        COUNT(DISTINCT CASE
            WHEN s.status = 'active'
            THEN fu.account_id
        END) AS retained_accounts

    FROM feature_usage fu

    LEFT JOIN saas.subscriptions s
      ON fu.account_id = s.account_id

    GROUP BY
        fu.feature_name,
        fu.category

)

SELECT

    fs.feature_name,

    fs.category,

    fs.adopted_accounts,

    ta.total_accounts,

    ROUND(
        fs.adopted_accounts * 100.0 /
        ta.total_accounts,
        2
    ) AS adoption_rate_pct,

    fs.retained_accounts,

    ROUND(
        fs.retained_accounts * 100.0 /
        NULLIF(fs.adopted_accounts,0),
        2
    ) AS retention_rate_pct

FROM feature_summary fs
CROSS JOIN total_accounts ta

ORDER BY
    adoption_rate_pct DESC,
    retained_accounts DESC;
