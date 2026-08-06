# SaaS Schema Recon

## Overview

The SaaS schema contains 17 active business tables (excluding legacy tables). The schema models customer accounts, users, subscriptions, product usage, billing, payments, trials, feature adoption, support tickets, and A/B experiments.

---

## Entity Relationship Diagram

```mermaid
erDiagram

ACCOUNTS ||--o{ USERS : contains
ACCOUNTS ||--o{ SUBSCRIPTIONS : owns
ACCOUNTS ||--o{ EVENTS : generates
ACCOUNTS ||--o{ TRIALS : starts
ACCOUNTS ||--o{ INVOICES : receives

USERS ||--o{ SUBSCRIPTIONS : may_hold
USERS ||--o{ EVENTS : performs

PLANS ||--o{ SUBSCRIPTIONS : defines
SUBSCRIPTIONS ||--o{ SUBSCRIPTION_EVENTS : generates
SUBSCRIPTIONS ||--o{ PAYMENT_ATTEMPTS : receives

FEATURES ||--o{ EVENTS : referenced_by

ACCOUNTS {
    bigint account_id
    text account_type
    timestamp signup_date
}

USERS {
    bigint user_id
    bigint account_id
}

SUBSCRIPTIONS {
    int subscription_id
    bigint account_id
    int user_id
    int plan_id
    numeric mrr
    text status
}

SUBSCRIPTION_EVENTS {
    bigint event_id
    int subscription_id
    bigint account_id
    timestamp event_time
    numeric mrr_delta
}

EVENTS {
    int event_id
    int user_id
    bigint account_id
    int feature_id
    timestamp occurred_at
}

FEATURES {
    int feature_id
    text feature_name
}

PLANS {
    int plan_id
    text plan_name
    numeric monthly_price
}

# Table Inventory

| Table | Approximate Rows | Purpose |
|---------|----------------:|---------|
| accounts | 1,250 | Customer accounts |
| users | 2,556 | Users belonging to customer accounts |
| subscriptions | 2,113 | Subscription records |
| subscription_events | 3,741 | Subscription lifecycle events |
| plans | 8 | Subscription plans |
| invoices | 4,201 | Billing invoices |
| payment_attempts | 5,690 | Payment attempts |
| events | 53,534 | Product usage events |
| trials | 250 | Trial records |
| seats | 1,556 | Licensed seats |
| support_tickets | 1,249 | Customer support requests |
| email_sends | 3,385 | Marketing and notification emails |
| experiments | 4 | A/B experiments |
| experiment_variants | 8 | Experiment variants |
| experiment_assignments | 3,200 | User experiment assignments |
| features | 50 | Product features |

---

# Important Relationships

- accounts.account_id → users.account_id
- accounts.account_id → subscriptions.account_id
- accounts.account_id → trials.account_id
- accounts.account_id → events.account_id
- accounts.account_id → invoices.account_id
- accounts.account_id → payment_attempts.account_id
- users.user_id → subscriptions.user_id
- users.user_id → events.user_id
- users.user_id → experiment_assignments.user_id
- plans.plan_id → subscriptions.plan_id
- subscriptions.subscription_id → subscription_events.subscription_id
- subscriptions.subscription_id → payment_attempts.subscription_id
- features.feature_id → events.feature_id
- experiments.experiment_id → experiment_variants.experiment_id
- experiment_variants.variant_id → experiment_assignments.variant_id

---

# Probe Question 1 – Grain of subscriptions

The subscriptions table has mixed grain.

For Self-Serve customers, subscriptions belong to individual users. Each subscription generally has one seat.

For B2B customers, subscriptions belong to customer accounts. User IDs are NULL and subscriptions may contain multiple seats.

One account may have multiple subscription records representing renewals, upgrades, downgrades, or historical subscriptions.

---

# Probe Question 2 – MRR

The plans table stores catalogue prices.

The subscriptions table stores the actual Monthly Recurring Revenue (MRR).

Stored MRR does not always equal:

Monthly Price × Seat Count

This indicates custom pricing, discounts or enterprise pricing.

The subscription_events table stores revenue movements using mrr_delta.

Positive values represent expansion revenue while negative values represent contraction or churn.

---

# Probe Question 3 – Subscription Status

| Status | Count |
|---------|------:|
| Active | 885 |
| Churned | 557 |
| Trialing | 292 |
| Past Due | 195 |
| Paused | 184 |

Active subscriptions generate most recurring revenue.

All churned subscriptions have a valid cancelled_at timestamp.

---

# Probe Question 4 – Trial vs Paid

The trials table stores:

- started_at
- ends_at
- converted_at
- converted_subscription_id

Average trial duration is 14 days.

Paid subscriptions are identified using Active status.

Current trial users are identified using Trialing status.

---

# Probe Question 5 – Timezone

Database timezone is UTC.

Most lifecycle timestamps use Timestamp With Time Zone.

Some business dates such as signup_date and issue_date use Timestamp Without Time Zone.

---

# Probe Question 6 – Soft Delete

No deleted_at or is_deleted pattern exists.

Lifecycle is managed using:

- status
- cancelled_at
- is_active

instead of soft deletes.

---

# Data Quality Findings

## Finding 1

Plan names are inconsistent.

Examples:

- Pro
- pro
- Enterprise
- enterprise
- professional

Recommendation:

Use LOWER(TRIM(plan)) before analysis.

---

## Finding 2

243 subscriptions (11.5%) have NULL plan_id.

Recommendation:

Use LEFT JOIN when joining to plans.

---

## Finding 3

566 product usage events contain a NULL `account_id`.

These rows are unattributed events. They are not confirmed orphan users because a missing `account_id` is different from a `user_id` that does not match the users table.

Recommendation:

Exclude rows with NULL `account_id` from account-level analyses such as feature adoption and account retention. For user-level analysis, separately validate whether `user_id` exists in the users table before classifying an event as orphaned.

---

## Finding 4

226 subscription events occur after the official dataset boundary of 15-Jun-2026.

Including these future-dated rows causes SaaS metrics to change depending on the date the query is executed. This affected MRR movements, GRR/NRR cohorts, and expansion-revenue totals.

Recommendation:

Use the following fixed reporting cutoff in all historical SaaS revenue queries:

`2026-06-15 23:59:59`

This cutoff is applied consistently in S1, S3, S4, and S5 to ensure reproducible results.

---

# Column Dictionary

## accounts

- `account_id` – Unique identifier for a customer account and the main key used for account-level SaaS analysis.
- `account_type` – Identifies whether the customer follows a self-serve or B2B commercial model.
- `industry` – Industry segment used for customer segmentation and retention analysis.
- `country` – Customer location used for regional analysis.
- `signup_date` – Date the account entered the product; used as the starting point for cohorts, activation, adoption, and retention windows.
- `acquisition_channel` – Marketing or sales channel that acquired the account.

## users

- `user_id` – Unique identifier for an individual product user.
- `account_id` – Links a user to the customer account they belong to.
- `signup_date` – Date the individual user registered for the product.
- `signup_source` – Source or workflow through which the user registered.
- `plan_type` – User-level plan classification where applicable.
- `is_active` – Current user activity flag; this should not be used as a replacement for historical retention logic.
- `last_login_date` – Most recent recorded login date, useful for engagement and inactivity analysis.

## subscriptions

- `subscription_id` – Unique identifier for a subscription record.
- `account_id` – Links the subscription to the customer account responsible for payment.
- `user_id` – Links self-serve subscriptions to an individual user; it may be NULL for account-level B2B subscriptions.
- `plan` – Stored plan label, which requires normalization because casing is inconsistent.
- `plan_id` – Links the subscription to the plans catalogue; some values are NULL, so joins must preserve unmatched subscriptions.
- `mrr` – Monthly recurring revenue associated with the subscription. Used for subscription snapshots, GRR, NRR, and revenue validation.
- `seat_count` – Number of licensed seats included in the subscription.
- `status` – Current lifecycle state, such as active, churned, trialing, past due, or paused.
- `start_date` – Date from which the subscription became effective.
- `end_date` – Date the subscription stopped being active, where available.
- `cancelled_at` – Timestamp of cancellation, used to determine whether a subscription was alive at a historical point in time.

## subscription_events

- `subscription_id` – Subscription affected by the lifecycle event.
- `account_id` – Account affected by the subscription movement.
- `user_id` – User associated with the event where the subscription is user-level.
- `event_type` – Type of lifecycle change, such as subscription start, plan change, cancellation, seat addition, or trial conversion.
- `event_time` – Timestamp used to order subscription movements and build historical MRR balances.
- `from_plan` – Plan held before a plan-change event.
- `to_plan` – Plan held after a plan-change event.
- `mrr_delta` – Signed change in recurring revenue. Positive values represent growth; negative values represent contraction or churn.
- `seats_delta` – Signed change in licensed seat count.

## plans

- `plan_id` – Unique identifier for a catalogue plan.
- `plan_name` – Standard catalogue name of the plan.
- `monthly_price` – Published monthly list price, which may differ from actual subscription MRR.
- `seat_limit` – Maximum seats allowed under the plan.
- `billing_interval` – Frequency at which the plan is billed, such as monthly or annual.

---

# Sample Queries

## Active Paying Accounts

643

## Accounts by Plan

| Plan | Accounts |
|------|---------:|
| Pro | 439 |
| Enterprise | 242 |
| Starter | 176 |
| Free | 121 |

## Sample Subscription Events

Verified subscription lifecycle events including:

- subscription_started
- trial_started
- plan_changed
- trial_converted
- cancelled
- seat_add

---

# Summary

The SaaS schema is designed around customer accounts, subscriptions, product usage, and billing. Subscription history is maintained through lifecycle events, while MRR movements are captured separately using subscription_events. The schema is well suited for product analytics, revenue analysis, feature adoption, churn analysis, and customer lifecycle reporting.
