/*
E2 — Checkout Funnel Drop-off by Entry Channel

Business Question:
Where do customers abandon the checkout process, and how does
step-to-step drop-off differ by acquisition channel?

What This Tells Us:
The query assigns each session its highest completed checkout step
and calculates funnel progression from begin_checkout through purchase.

Using the highest reached step prevents a session from being counted
at a later stage without also being counted at all earlier stages.
This keeps the funnel monotonic and avoids conversion rates above 100%.

PM Action:
The largest drop-off occurs between add_payment and purchase,
ranging from 7.56% to 8.30% across all five acquisition channels.

Review payment failures, checkout latency, error messages, and final
confirmation-page behaviour because the issue appears across every
channel rather than being isolated to one acquisition source.

Sanity Check:
1. For every channel:
   purchased <= payment <= shipping <= address <= begin_checkout.
2. Every drop-off percentage must remain between 0% and 100%.
3. A session is counted once per channel using its highest completed
   checkout step.
*/

WITH session_step_reached AS (
    SELECT
        se.session_id,
        sc.channel,

        MAX(
            CASE
                WHEN se.event_type = 'purchase' THEN 5
                WHEN se.event_type = 'add_payment' THEN 4
                WHEN se.event_type = 'select_shipping' THEN 3
                WHEN se.event_type = 'add_address' THEN 2
                WHEN se.event_type = 'begin_checkout' THEN 1
                ELSE 0
            END
        ) AS max_step

    FROM ecom.session_events AS se
    JOIN ecom.session_channels AS sc
        ON se.session_id = sc.session_id

    WHERE se.event_type IN (
        'begin_checkout',
        'add_address',
        'select_shipping',
        'add_payment',
        'purchase'
    )

    GROUP BY
        se.session_id,
        sc.channel
)

SELECT
    channel,

    COUNT(*) FILTER (
        WHERE max_step >= 1
    ) AS begin_checkout,

    COUNT(*) FILTER (
        WHERE max_step >= 2
    ) AS address,

    COUNT(*) FILTER (
        WHERE max_step >= 3
    ) AS shipping,

    COUNT(*) FILTER (
        WHERE max_step >= 4
    ) AS payment,

    COUNT(*) FILTER (
        WHERE max_step = 5
    ) AS purchased,

    ROUND(
        100.0 * (
            COUNT(*) FILTER (WHERE max_step >= 1)
            - COUNT(*) FILTER (WHERE max_step >= 2)
        )
        / NULLIF(
            COUNT(*) FILTER (WHERE max_step >= 1),
            0
        ),
        2
    ) AS drop_address_pct,

    ROUND(
        100.0 * (
            COUNT(*) FILTER (WHERE max_step >= 2)
            - COUNT(*) FILTER (WHERE max_step >= 3)
        )
        / NULLIF(
            COUNT(*) FILTER (WHERE max_step >= 2),
            0
        ),
        2
    ) AS drop_shipping_pct,

    ROUND(
        100.0 * (
            COUNT(*) FILTER (WHERE max_step >= 3)
            - COUNT(*) FILTER (WHERE max_step >= 4)
        )
        / NULLIF(
            COUNT(*) FILTER (WHERE max_step >= 3),
            0
        ),
        2
    ) AS drop_payment_pct,

    ROUND(
        100.0 * (
            COUNT(*) FILTER (WHERE max_step >= 4)
            - COUNT(*) FILTER (WHERE max_step = 5)
        )
        / NULLIF(
            COUNT(*) FILTER (WHERE max_step >= 4),
            0
        ),
        2
    ) AS drop_final_pct

FROM session_step_reached

GROUP BY channel

ORDER BY purchased DESC;