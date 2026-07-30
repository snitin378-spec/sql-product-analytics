WITH customer_cohorts AS (
    SELECT
        c.customer_id,
        c.created_at AS signup_time,
        DATE_TRUNC('week', c.created_at)::date AS signup_week
    FROM ecom.customers AS c
    WHERE c.created_at >= TIMESTAMP '2026-04-19'
),

first_valid_action AS (
    SELECT
        c.customer_id,
        MIN(se.occurred_at) AS first_meaningful_action
    FROM customer_cohorts AS c
    LEFT JOIN ecom.session_events AS se
        ON c.customer_id = se.customer_id
       AND se.event_type IN (
            'add_to_cart',
            'begin_checkout',
            'purchase'
       )
       AND se.occurred_at >= c.signup_time
    GROUP BY c.customer_id
),

customer_activation AS (
    SELECT
        c.customer_id,
        c.signup_week,
        c.signup_time,
        f.first_meaningful_action,

        CASE
            WHEN f.first_meaningful_action IS NOT NULL
            THEN EXTRACT(
                EPOCH FROM (
                    f.first_meaningful_action - c.signup_time
                )
            ) / 60.0
        END AS minutes_to_activation,

        CASE
            WHEN f.first_meaningful_action >= c.signup_time
             AND f.first_meaningful_action
                    < c.signup_time + INTERVAL '7 days'
            THEN 1
            ELSE 0
        END AS activated_7d

    FROM customer_cohorts AS c
    LEFT JOIN first_valid_action AS f
        ON c.customer_id = f.customer_id
),

weekly_activation AS (
    SELECT
        signup_week,
        COUNT(*) AS cohort_size,
        SUM(activated_7d) AS activated_7d,

        ROUND(
            100.0 * SUM(activated_7d)
            / NULLIF(COUNT(*), 0),
            2
        ) AS activation_rate_7d,

        ROUND(
            (
                PERCENTILE_CONT(0.5)
                WITHIN GROUP (
                    ORDER BY minutes_to_activation
                )
                FILTER (
                    WHERE activated_7d = 1
                )
            )::numeric,
            2
        ) AS median_minutes_to_activation,

        ROUND(
            (
                PERCENTILE_CONT(0.9)
                WITHIN GROUP (
                    ORDER BY minutes_to_activation
                )
                FILTER (
                    WHERE activated_7d = 1
                )
            )::numeric,
            2
        ) AS p90_minutes_to_activation

    FROM customer_activation
    GROUP BY signup_week
)

SELECT
    signup_week,
    cohort_size,
    activated_7d,
    activation_rate_7d,
    median_minutes_to_activation,
    p90_minutes_to_activation,

    CASE
        WHEN activated_7d <= cohort_size
        THEN 'PASS'
        ELSE 'FAIL'
    END AS sanity_check

FROM weekly_activation
ORDER BY signup_week;
