/*
E4 — PDP Engagement: High-View, Low-Cart Products

Business Question:
Which products attract substantial product-page traffic but convert
poorly into add-to-cart activity compared with similar products in
the same category?

What This Tells Us:
The query compares each product's add-to-cart rate with the median
rate for its category. This prevents misleading comparisons across
categories with naturally different shopping behaviour.

PM Action:

The highest-traffic product (Suta Threads Velvet Kajal) recorded
4,334 PDP views but an ATC rate of only 6.0%, which is
30 percentage points below the median for the Makeup category.

Prioritize merchandising review for the highest-view,
below-category-median products by evaluating pricing,
product imagery, descriptions, reviews, and inventory
availability before investing in additional traffic.

Sanity Check:
1. add_to_cart_sessions <= views for every product.
2. atc_rate must be between 0 and 1.
3. atc_rate_vs_category_median below 0 identifies products performing
   worse than their category median.
*/

WITH product_event_metrics AS (
    SELECT
        se.product_id,

        COUNT(*) FILTER (
            WHERE se.event_type = 'product_view'
        ) AS views,

        COUNT(DISTINCT se.session_id) FILTER (
            WHERE se.event_type = 'add_to_cart'
        ) AS add_to_cart_sessions

    FROM ecom.session_events AS se

    WHERE se.product_id IS NOT NULL
      AND se.event_type IN (
          'product_view',
          'add_to_cart'
      )

    GROUP BY se.product_id
),

product_rates AS (
    SELECT
        pem.product_id,
        p.product_name,
        c.category_name AS category,
        pem.views,
        pem.add_to_cart_sessions,

        pem.add_to_cart_sessions::numeric
        / NULLIF(pem.views, 0) AS atc_rate

    FROM product_event_metrics AS pem

    JOIN ecom.products AS p
        ON pem.product_id = p.product_id

    JOIN ecom.categories AS c
        ON p.category_id = c.category_id

    WHERE pem.views > 0
),

category_benchmarks AS (
    SELECT
        category,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY atc_rate
        ) AS category_median_atc_rate

    FROM product_rates

    GROUP BY category
),

ranked_products AS (
    SELECT
        pr.product_id,
        pr.product_name,
        pr.category,
        pr.views,
        pr.add_to_cart_sessions,
        pr.atc_rate,
        cb.category_median_atc_rate,

        pr.atc_rate
        - cb.category_median_atc_rate
            AS atc_rate_vs_category_median,

        DENSE_RANK() OVER (
            ORDER BY pr.views DESC
        ) AS views_rank,

        DENSE_RANK() OVER (
            ORDER BY pr.atc_rate ASC
        ) AS atc_rate_rank

    FROM product_rates AS pr

    JOIN category_benchmarks AS cb
        ON pr.category = cb.category
)

SELECT
    product_id,
    product_name,
    category,
    views,
    add_to_cart_sessions,

    ROUND(atc_rate, 4) AS atc_rate,

    ROUND(
        atc_rate_vs_category_median::numeric,
        4
    ) AS atc_rate_vs_category_median,

    views_rank,
    atc_rate_rank

FROM ranked_products

WHERE atc_rate < category_median_atc_rate

ORDER BY
    views_rank ASC,
    atc_rate_vs_category_median ASC

LIMIT 10;