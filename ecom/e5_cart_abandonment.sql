/*
E5 — Cart Abandonment by Cart Value Bucket

Business Question:
Does cart abandonment differ between low-value and high-value carts,
and which cart-value segments leave the most GMV on the table?

What This Tells Us:
The query groups add-to-cart sessions into five cart-value buckets,
measures conversion and abandonment in each bucket, and estimates
the total cart value lost from sessions that did not purchase.

PM Action:
Although carts below ₹500 have the highest abandonment rate (53%),
the ₹5,000–₹14,999 bucket leaves the largest GMV on the table
(₹9,848,217.87).

Prioritize checkout optimization and payment reliability for
high-value carts because reducing abandonment in this segment
would recover substantially more revenue than focusing only on
low-value carts.

Sanity Check:
1. atc_sessions = purchased_sessions + abandoned_sessions for each bucket.
2. abandonment_rate must be between 0 and 1.
3. The sum of atc_sessions across all buckets must equal the total
   number of distinct sessions containing an add_to_cart event.
*/

WITH session_cart_value AS (
    SELECT
        se.session_id,

        SUM(
            COALESCE(se.quantity, 0)
            * COALESCE(se.unit_price, 0)
        ) AS cart_value

    FROM ecom.session_events AS se

    WHERE se.event_type = 'add_to_cart'

    GROUP BY se.session_id
),

session_purchase_status AS (
    SELECT
        se.session_id,

        MAX(
            CASE
                WHEN se.event_type = 'purchase' THEN 1
                ELSE 0
            END
        ) AS purchased

    FROM ecom.session_events AS se

    WHERE se.event_type IN (
        'add_to_cart',
        'purchase'
    )

    GROUP BY se.session_id
),

cart_sessions AS (
    SELECT
        scv.session_id,
        scv.cart_value,
        COALESCE(sps.purchased, 0) AS purchased,

        CASE
            WHEN scv.cart_value < 500
                THEN '<₹500'

            WHEN scv.cart_value < 2000
                THEN '₹500–₹1,999'

            WHEN scv.cart_value < 5000
                THEN '₹2,000–₹4,999'

            WHEN scv.cart_value < 15000
                THEN '₹5,000–₹14,999'

            ELSE '₹15,000+'
        END AS cart_bucket,

        CASE
            WHEN scv.cart_value < 500 THEN 1
            WHEN scv.cart_value < 2000 THEN 2
            WHEN scv.cart_value < 5000 THEN 3
            WHEN scv.cart_value < 15000 THEN 4
            ELSE 5
        END AS bucket_order

    FROM session_cart_value AS scv

    LEFT JOIN session_purchase_status AS sps
        ON scv.session_id = sps.session_id
)

SELECT
    cart_bucket,

    COUNT(*) AS atc_sessions,

    COUNT(*) FILTER (
        WHERE purchased = 1
    ) AS purchased_sessions,

    COUNT(*) FILTER (
        WHERE purchased = 0
    ) AS abandoned_sessions,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE purchased = 0
            )
        )::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS abandonment_rate,

    ROUND(
        SUM(
            CASE
                WHEN purchased = 0
                THEN cart_value
                ELSE 0
            END
        ),
        2
    ) AS gmv_left_on_table

FROM cart_sessions

GROUP BY
    cart_bucket,
    bucket_order

ORDER BY bucket_order;