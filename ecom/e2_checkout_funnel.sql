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
