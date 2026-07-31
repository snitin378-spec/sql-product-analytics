/*
Business Question:
Of accounts that started a trial in each week,
what percentage converted to paid within
14, 30 and 60 days?

What This Tells Us:
Shows trial conversion performance by cohort
and how quickly customers become paying users.

PM Action:
Investigate cohorts with low 30-day conversion.
Segment by acquisition channel, plan and account type.

Sanity Check:
converted_by_14d <= converted_by_30d <= converted_by_60d
*/

WITH trial_cohorts AS (

    SELECT
        account_id,
        DATE_TRUNC('week', started_at)::date AS trial_week,
        started_at,
        converted_at,

        (converted_at::date - started_at::date) AS days_to_convert

    FROM saas.trials

),

cohort_summary AS (

    SELECT

        trial_week,

        COUNT(*) AS trials_started,

        COUNT(
            CASE
                WHEN days_to_convert <= 14
                THEN 1
            END
        ) AS converted_by_14d,

        COUNT(
            CASE
                WHEN days_to_convert <= 30
                THEN 1
            END
        ) AS converted_by_30d,

        COUNT(
            CASE
                WHEN days_to_convert <= 60
                THEN 1
            END
        ) AS converted_by_60d,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY days_to_convert
        ) AS median_days_trial_to_paid

    FROM trial_cohorts
    GROUP BY trial_week

)

SELECT

    trial_week,

    trials_started,

    converted_by_14d,

    converted_by_30d,

    converted_by_60d,

    ROUND(
        converted_by_14d * 100.0 / trials_started,
        2
    ) AS conv_rate_14d,

    ROUND(
        converted_by_30d * 100.0 / trials_started,
        2
    ) AS conv_rate_30d,

    ROUND(
        converted_by_60d * 100.0 / trials_started,
        2
    ) AS conv_rate_60d,

    median_days_trial_to_paid

FROM cohort_summary
ORDER BY trial_week;
