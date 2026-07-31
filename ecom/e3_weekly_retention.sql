WITH customer_cohorts AS (

    SELECT
        customer_id,
        DATE_TRUNC('week', created_at)::date AS cohort_week
    FROM ecom.customers
    WHERE created_at >= TIMESTAMP '2026-04-19'

),

customer_weekly_activity AS (

    SELECT DISTINCT
        c.customer_id,

        FLOOR(
            EXTRACT(
                EPOCH FROM (se.occurred_at - c.created_at)
            ) / (86400.0 * 7)
        )::int AS week_index

    FROM ecom.customers c

    JOIN ecom.session_events se
      ON c.customer_id = se.customer_id
     AND se.occurred_at >= c.created_at
     AND se.event_type IN (
            'product_view',
            'add_to_cart',
            'purchase'
        )

    WHERE c.created_at >= TIMESTAMP '2026-04-19'

),

cohort_retention AS (

    SELECT

        cc.cohort_week,

        COUNT(DISTINCT cc.customer_id) AS cohort_size,

        COUNT(DISTINCT CASE
            WHEN cwa.week_index = 0
            THEN cc.customer_id
        END) AS w0_active,

        COUNT(DISTINCT CASE
            WHEN cwa.week_index = 1
            THEN cc.customer_id
        END) AS w1_retained,

        COUNT(DISTINCT CASE
            WHEN cwa.week_index = 2
            THEN cc.customer_id
        END) AS w2_retained,

        COUNT(DISTINCT CASE
            WHEN cwa.week_index = 3
            THEN cc.customer_id
        END) AS w3_retained,

        COUNT(DISTINCT CASE
            WHEN cwa.week_index = 4
            THEN cc.customer_id
        END) AS w4_retained

    FROM customer_cohorts cc

    LEFT JOIN customer_weekly_activity cwa
      ON cc.customer_id = cwa.customer_id

    GROUP BY cc.cohort_week

)

SELECT

    cohort_week,

    cohort_size,

    w0_active,
    ROUND(100.0 * w0_active / cohort_size, 2) AS w0_retention_pct,

    w1_retained,
    ROUND(100.0 * w1_retained / cohort_size, 2) AS w1_retention_pct,

    w2_retained,
    ROUND(100.0 * w2_retained / cohort_size, 2) AS w2_retention_pct,

    w3_retained,
    ROUND(100.0 * w3_retained / cohort_size, 2) AS w3_retention_pct,

    w4_retained,
    ROUND(100.0 * w4_retained / cohort_size, 2) AS w4_retention_pct

FROM cohort_retention

ORDER BY cohort_week;
