# SQL Product Analytics Portfolio

## Executive Summary

This project contains 10 product analytics SQL case studies across two business models:

- **B2C E-commerce**
- **B2B and Self-Serve SaaS**

The analyses cover activation, conversion funnels, behavioral retention, product engagement, cart abandonment, Monthly Recurring Revenue, trial conversion, revenue retention, feature adoption, and expansion revenue.

The project demonstrates how the same SQL techniques can answer very different business questions depending on the customer journey, unit of analysis, and revenue model.

---

## B2C vs B2B Analytics

| Area | E-commerce | SaaS |
|---|---|---|
| Main analytical grain | Session or customer | Account or subscription |
| Typical time horizon | Minutes to weeks | Weeks to months |
| Activation | First meaningful shopping action | Trial conversion or product adoption |
| Funnel | Checkout steps inside a session | Trial → paid → retained → expanded |
| Retention | Customer returns and performs an action | Account continues paying |
| Revenue metric | GMV, conversion and cart value | MRR, GRR, NRR and expansion |
| Primary stakeholders | Product, Growth, Marketing | Product, Finance, Customer Success, Sales |

---

## Executive Business Highlights

| Domain | Key Finding | Business Value |
|---------|-------------|----------------|
| E-commerce | Built 5 product analytics case studies covering activation, funnel analysis, retention, engagement, and cart abandonment. | Demonstrates customer journey and conversion analysis. |
| SaaS | Built 5 SaaS analytics case studies covering MRR, Trial Conversion, GRR/NRR, Feature Adoption, and Expansion Revenue. | Demonstrates subscription and revenue analytics. |
| SQL | Used CTEs, Window Functions, Cohort Analysis, Conditional Aggregation, and Revenue Analytics. | Demonstrates advanced SQL skills used in production. |
| Business | Every query includes Business Question, PM Action, and Sanity Check. | Shows business thinking, not just SQL coding. |

| Analysis | Key Business Question |
|---|---|
| Activation Curve | How quickly do new customers perform a meaningful action? |
| Checkout Funnel | Where do customers abandon checkout? |
| Weekly Retention | Do customers return after signup? |
| PDP Engagement | Which products attract views but fail to generate cart additions? |
| Cart Abandonment | Which cart-value segments lose the most customers and revenue? |
| MRR Movements | What drove monthly recurring revenue growth or decline? |
| Trial Conversion | How quickly do trial accounts become paying customers? |
| GRR and NRR | How much existing customer revenue is retained after 12 months? |
| Feature Adoption | Which product features are associated with stronger retention? |
| Expansion Revenue | Is expansion driven by seats, plan upgrades or add-ons? |

---

## Query Index

### E-commerce Analytics

| Query | Business Question | Main SQL Concepts |
|---|---|---|
| [E1 – Activation Curve](ecom/e1_activation_curve.sql) | How quickly do signups become active customers? | CTEs, cohorts, percentiles |
| [E2 – Checkout Funnel](ecom/e2_checkout_funnel.sql) | Where does checkout lose customers by channel? | Funnel logic, conditional aggregation |
| [E3 – Weekly Retention](ecom/e3_weekly_retention.sql) | What percentage of customers return in Weeks 1–4? | Relative-week cohorts, retention |
| [E4 – PDP Engagement](ecom/e4_pdp_engagement.sql) | Which high-view products have weak cart conversion? | Product-level aggregation, ranking |
| [E5 – Cart Abandonment](ecom/e5_cart_abandonment.sql) | Which cart-value buckets lose the most revenue? | Bucketing, session aggregation |

### SaaS Analytics

| Query | Business Question | Main SQL Concepts |
|---|---|---|
| [S1 – MRR Movements](saas/s1_mrr_movements.sql) | What drove monthly MRR changes? | Event classification, running totals |
| [S2 – Trial Conversion](saas/s2_trial_conversion.sql) | What percentage converted within 14, 30 and 60 days? | Cohorts, conditional counting |
| [S3 – GRR and NRR](saas/s3_grr_nrr.sql) | How much cohort revenue remained after 12 months? | Revenue cohorts, windowed lifecycle logic |
| [S4 – Feature Adoption](saas/s4_feature_adoption.sql) | Which features are associated with retention? | Adoption flags, comparative rates |
| [S5 – Expansion Revenue](saas/s5_expansion_revenue.sql) | What is the dominant expansion motion? | Revenue decomposition, medians |

---

## Tools and Technologies

- PostgreSQL
- Metabase
- GitHub and GitHub Desktop
- SQL CTEs
- Window functions
- Conditional aggregation
- Cohort analysis
- Funnel analysis
- Revenue analytics

---

## Repository Structure

```text
sql-product-analytics/
├── ecom/
├── saas/
├── notes/
├── images/
└── README.md
```

---

## Data Quality Considerations

The analysis explicitly handles several realistic data issues:

- Inconsistent plan-name casing
- Missing `plan_id` values
- Orphan product-event users
- Future-dated subscription events
- Pre-signup e-commerce events
- Incomplete recent cohorts
- Mixed self-serve and B2B subscription grain

---

## Important Analytical Limitations

Feature adoption and retention are correlated, but the analysis does not prove that feature adoption causes retention. More engaged customers may naturally use more features.

Recent activation, retention and trial-conversion cohorts may be incomplete because their full observation windows have not closed.

---

## Portfolio Case Study

A detailed comparison will be published as:

**B2C vs B2B: How Funnels and Retention Actually Differ**

The case study compares behavioral e-commerce analytics with commercial SaaS analytics.

---

## Author

**Nithin S.**

Senior Data Analyst portfolio project focused on SQL, product analytics and business decision-making.
