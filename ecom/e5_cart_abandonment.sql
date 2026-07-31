/*
E5 — Cart Abandonment Analysis

Business Question:
How many shopping sessions abandon their cart before completing a purchase?

Definition:
A cart is abandoned if:
- add_to_cart occurred
- purchase did not occur
*/

WITH session_cart_activity AS (

    SELECT
        session_id,

        MAX(
            CASE
                WHEN event_type = 'add_to_cart' THEN 1
                ELSE 0
            END
        ) AS added_to_cart,

        MAX(
            CASE
                WHEN event_type = 'begin_checkout' THEN 1
                ELSE 0
            END
        ) AS began_checkout,

        MAX(
            CASE
                WHEN event_type = 'purchase' THEN 1
                ELSE 0
            END
        ) AS purchased

    FROM ecom.session_events

    WHERE event_type IN (
        'add_to_cart',
        'begin_checkout',
        'purchase'
    )

    GROUP BY session_id

)

SELECT

    COUNT(*) FILTER (
        WHERE added_to_cart = 1
    ) AS cart_sessions,

    COUNT(*) FILTER (
        WHERE began_checkout = 1
    ) AS checkout_sessions,

    COUNT(*) FILTER (
        WHERE purchased = 1
    ) AS purchased_sessions,

    COUNT(*) FILTER (
        WHERE added_to_cart = 1
          AND purchased = 0
    ) AS abandoned_cart_sessions,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE added_to_cart = 1
              AND purchased = 0
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE added_to_cart = 1
            ),
            0
        ),
        2
    ) AS cart_abandonment_rate_pct,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE began_checkout = 1
              AND purchased = 0
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE began_checkout = 1
            ),
            0
        ),
        2
    ) AS checkout_abandonment_rate_pct

FROM session_cart_activity;
