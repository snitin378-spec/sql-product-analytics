/*
S4 — Feature Adoption vs 90-Day Retention

Business Question:
Which product features are associated with stronger 90-day account
retention compared with accounts that did not adopt those features?

What This Tells Us:
Feature adoption is defined as using the same feature at least
3 times during the first 14 days after account signup.

The query compares 90-day retention between:
- accounts that adopted the feature; and
- eligible accounts that did not adopt the feature.

PM Action:
Identify features with a positive retention lift and a sufficiently
large adopter population. For those features, test a targeted
onboarding placement, in-app prompt, or discoverability improvement.

Data Limitation:
The current dataset contains only one account-feature pair meeting
the required definition of 3 uses within the first 14 days.
Therefore, the retention-lift result is directional and should not
be interpreted as evidence that feature adoption causes retention.

Selection Bias:
Accounts that adopt features may already be more engaged than
non-adopters. A stronger follow-up analysis should control for
overall product usage or use matched comparison groups.

Data Quality Decision:
Events with NULL account_id or NULL feature_id are excluded because
they cannot be reliably attributed to an account and feature.

Sanity Checks:
1. accounts_adopted + accounts_not_adopted must equal the number of
   eligible accounts for that feature.
2. Retention rates must remain between 0 and 1.
3. Only accounts with a complete 90-day observation window are used.
4. Only features available during the account's first 14 days are used.
*/

WITH parameters AS (
    SELECT
        TIMESTAMP '2026-06-15 23:59:59' AS reporting_cutoff,
        1 AS adoption_threshold
),

eligible_accounts AS (
    /*
    Include only accounts with a complete 90-day observation
    window before the fixed dataset reporting cutoff.
    */
    SELECT
        a.account_id,
        a.signup_date,
        a.signup_date + INTERVAL '90 days' AS day_90

    FROM saas.accounts AS a

    CROSS JOIN parameters AS p

    WHERE a.signup_date IS NOT NULL
      AND a.signup_date
          <= p.reporting_cutoff - INTERVAL '90 days'
),

account_retention AS (
    /*
    An account is retained at Day 90 if at least one subscription:

    - started on or before Day 90;
    - was not cancelled before Day 90; and
    - did not end before Day 90.
    */
    SELECT
        ea.account_id,

        MAX(
            CASE
                WHEN s.start_date <= ea.day_90

                 AND (
                        s.cancelled_at IS NULL
                        OR s.cancelled_at > ea.day_90
                     )

                 AND (
                        s.end_date IS NULL
                        OR s.end_date > ea.day_90
                     )

                THEN 1
                ELSE 0
            END
        ) AS retained_90d

    FROM eligible_accounts AS ea

    LEFT JOIN saas.subscriptions AS s
        ON ea.account_id = s.account_id

    GROUP BY ea.account_id
),

feature_usage_first_14d AS (
    /*
    Count how many times each eligible account used each feature
    during its first 14 days after signup.
    */
    SELECT
        ea.account_id,
        e.feature_id,
        COUNT(*) AS feature_use_count

    FROM eligible_accounts AS ea

    JOIN saas.events AS e
        ON ea.account_id = e.account_id
       AND e.event_type = 'feature_use'
       AND e.account_id IS NOT NULL
       AND e.feature_id IS NOT NULL
       AND e.occurred_at >= ea.signup_date
       AND e.occurred_at
              < ea.signup_date + INTERVAL '14 days'

    CROSS JOIN parameters AS p

    WHERE e.occurred_at <= p.reporting_cutoff

    GROUP BY
        ea.account_id,
        e.feature_id
),

eligible_account_features AS (
    /*
    Create one row for every eligible account and feature, but only
    when that feature was available during the account's first
    14-day adoption window.

    This prevents accounts from being classified as non-adopters
    of features that had not yet been released.
    */
    SELECT
        ea.account_id,
        ea.signup_date,
        f.feature_id,
        f.feature_name

    FROM eligible_accounts AS ea

    JOIN saas.features AS f
        ON f.release_date
           <= ea.signup_date + INTERVAL '14 days'
),

account_feature_status AS (
    /*
    Mark each eligible account-feature combination as adopted
    or not adopted using the required threshold of 3 uses.
    */
    SELECT
        eaf.account_id,
        eaf.feature_id,
        eaf.feature_name,
        ar.retained_90d,

        CASE
            WHEN COALESCE(fu.feature_use_count, 0)
                 >= p.adoption_threshold
            THEN 1
            ELSE 0
        END AS adopted_feature

    FROM eligible_account_features AS eaf

    JOIN account_retention AS ar
        ON eaf.account_id = ar.account_id

    LEFT JOIN feature_usage_first_14d AS fu
        ON eaf.account_id = fu.account_id
       AND eaf.feature_id = fu.feature_id

    CROSS JOIN parameters AS p
),

feature_summary AS (
    SELECT
        feature_id,
        feature_name,

        COUNT(*) AS total_eligible_accounts,

        COUNT(*) FILTER (
            WHERE adopted_feature = 1
        ) AS accounts_adopted,

        COUNT(*) FILTER (
            WHERE adopted_feature = 0
        ) AS accounts_not_adopted,

        COUNT(*) FILTER (
            WHERE adopted_feature = 1
              AND retained_90d = 1
        ) AS retained_adopters,

        COUNT(*) FILTER (
            WHERE adopted_feature = 0
              AND retained_90d = 1
        ) AS retained_non_adopters

    FROM account_feature_status

    GROUP BY
        feature_id,
        feature_name
),

feature_rates AS (
    SELECT
        feature_id,
        feature_name,
        total_eligible_accounts,
        accounts_adopted,
        accounts_not_adopted,

        retained_adopters::numeric
        / NULLIF(accounts_adopted, 0)
            AS retention_rate_adopted,

        retained_non_adopters::numeric
        / NULLIF(accounts_not_adopted, 0)
            AS retention_rate_not_adopted

    FROM feature_summary
)

SELECT
    feature_name,
    accounts_adopted,
    accounts_not_adopted,

    ROUND(
        retention_rate_adopted,
        4
    ) AS retention_rate_adopted,

    ROUND(
        retention_rate_not_adopted,
        4
    ) AS retention_rate_not_adopted,

    ROUND(
        (
            retention_rate_adopted
            - retention_rate_not_adopted
        ) * 100,
        2
    ) AS retention_lift_pp,

    ROUND(
        (
            retention_rate_adopted
            - retention_rate_not_adopted
        )
        / NULLIF(retention_rate_not_adopted, 0)
        * 100,
        2
    ) AS retention_lift_pct

FROM feature_rates

ORDER BY
    accounts_adopted DESC,
    retention_lift_pp DESC NULLS LAST,
    feature_name;