/*
E4 — Product Detail Page Engagement

Business question:
How effectively do product detail page views convert into
add-to-cart actions and purchases?

Grain:
One row per session and product before aggregation.

Metrics:
- PDP viewing sessions
- Add-to-cart sessions
- Purchase sessions
- Add-to-cart rate
- PDP purchase rate
- Cart-to-purchase rate

Important:
Repeated events by the same session for the same product are counted once.
*/

WITH session_product_activity AS (

    SELECT
        session_id,
        product_id,

        MAX(
            CASE
                WHEN event_type = 'product_view' THEN 1
                ELSE 0
            END
        ) AS viewed_pdp,

        MAX(
            CASE
                WHEN event_type = 'add_to_cart' THEN 1
                ELSE 0
            END
        ) AS added_to_cart,

        MAX(
            CASE
                WHEN event_type = 'purchase' THEN 1
                ELSE 0
            END
        ) AS purchased

    FROM ecom.session_events

    WHERE product_id IS NOT NULL

      AND event_type IN (
          'product_view',
          'add_to_cart',
          'purchase'
      )

    GROUP BY
        session_id,
        product_id
),

product_engagement AS (

    SELECT
        product_id,

        COUNT(*) FILTER (
            WHERE viewed_pdp = 1
        ) AS pdp_view_sessions,

        COUNT(*) FILTER (
            WHERE viewed_pdp = 1
              AND added_to_cart = 1
        ) AS add_to_cart_sessions,

        COUNT(*) FILTER (
            WHERE viewed_pdp = 1
              AND purchased = 1
        ) AS purchase_sessions,

        COUNT(*) FILTER (
            WHERE viewed_pdp = 1
              AND added_to_cart = 1
              AND purchased = 1
        ) AS cart_to_purchase_sessions

    FROM session_product_activity

    GROUP BY product_id
)

SELECT
    product_id,

    pdp_view_sessions,

    add_to_cart_sessions,

    purchase_sessions,

    ROUND(
        100.0 * add_to_cart_sessions
        / NULLIF(pdp_view_sessions, 0),
        2
    ) AS add_to_cart_rate_pct,

    ROUND(
        100.0 * purchase_sessions
        / NULLIF(pdp_view_sessions, 0),
        2
    ) AS pdp_purchase_rate_pct,

    ROUND(
        100.0 * cart_to_purchase_sessions
        / NULLIF(add_to_cart_sessions, 0),
        2
    ) AS cart_to_purchase_rate_pct

FROM product_engagement

WHERE pdp_view_sessions > 0

ORDER BY
    pdp_view_sessions DESC,
    product_id;
