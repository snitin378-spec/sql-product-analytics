# SQL Product Analytics Portfolio – E-commerce & SaaS Business Case Studies

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

# Executive Business Highlights

| Domain | Actual Finding | Business Value |
|---------|----------------|----------------|
| 🚀 Customer Activation | The highest 7-day activation rate reached **21.67%** (Week of May 18, 2026), while the latest cohort measured **8.79%** because it is still maturing. | Demonstrates how onboarding effectiveness changes across customer cohorts. |
| 🛒 Checkout Funnel | The largest checkout drop-off occurred at the **final Purchase step**, ranging from **7.56%–8.30%** across acquisition channels. | Indicates the biggest opportunity to improve conversion lies in the final payment-to-purchase stage. |
| 🔄 Weekly Retention | Week-1 retention peaked at **36.30%** (May 11 cohort), while recent cohorts naturally show lower later-week retention due to incomplete observation windows. | Highlights customer engagement patterns and cohort maturity effects. |
| 💰 Trial Conversion | Multiple cohorts achieved **100% conversion within 14 days**, while others ranged from **25%–50%**, showing significant variation in onboarding effectiveness. | Helps Product and Growth teams identify high-performing onboarding cohorts. |
| 📈 Revenue Retention | September 2022 cohort achieved **GRR 92.64%** and **NRR 113.95%**, showing expansion revenue more than offset customer losses. | Demonstrates strong expansion opportunities among retained customers. |
| 💵 Expansion Revenue | **Seat Expansion generated $28,259 MRR**, exceeding **Plan Upgrades ($19,281)** and **Add-ons ($3,467)**. | Indicates that customer growth through additional seats is the strongest expansion driver. |

### Business Impact

- Solved **10 real-world product analytics problems**
- Covered both **B2C (E-commerce)** and **B2B (SaaS)** analytics
- Demonstrated advanced SQL using CTEs, Window Functions, Cohort Analysis, Funnel Analysis, and Revenue Analytics
- Every analysis includes a Business Question, Business Interpretation, PM Action, and Sanity Check

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

## Query Portfolio

| Query | Stakeholder Question | Key Business Insight | SQL Concepts |
|------|----------------------|----------------------|-------------|
| E1 – Activation Curve | How quickly do customers activate after signup? | Measures onboarding effectiveness across customer cohorts. | Cohort Analysis, Window Functions |
| E2 – Checkout Funnel | Where do customers abandon checkout? | Identifies the highest drop-off stage in the purchase journey. | Conditional Aggregation |
| E3 – Weekly Retention | Do customers return after signup? | Measures long-term customer engagement. | Window Functions |
| E4 – PDP Engagement | Which products have high traffic but poor conversion? | Highlights products requiring merchandising improvements. | Product Analytics |
| E5 – Cart Abandonment | Which carts generate the highest lost revenue? | Quantifies revenue leakage across cart-value segments. | Session Analytics |
| S1 – MRR Movements | What drives monthly revenue growth? | Breaks MRR into New, Expansion, Churn, Contraction, and Reactivation. | Revenue Analytics |
| S2 – Trial Conversion | How quickly do trials become paid customers? | Measures trial effectiveness and conversion speed. | Cohort Analysis |
| S3 – GRR & NRR | How much recurring revenue is retained after one year? | Measures customer revenue retention and expansion. | Revenue Retention |
| S4 – Feature Adoption | Which product features improve retention? | Compares adoption rates and customer retention. | Product Analytics |
| S5 – Expansion Revenue | Where does expansion revenue originate? | Explains revenue growth from upgrades, seats, and add-ons. | Revenue Growth |

---

## Repository Features

✅ 10 Production-ready SQL business case studies

✅ Covers both B2C (E-commerce) and B2B (SaaS) analytics

✅ Every SQL query includes:
- Business Question
- What This Tells Us
- PM Action
- Sanity Check

✅ Built using PostgreSQL

✅ Designed using production-style SQL standards

✅ Suitable for Data Analyst / Senior Data Analyst portfolio

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

# Dashboard Highlights

Below are selected Metabase dashboards created as part of this project.

## Customer Activation (E1)

![Activation Curve](images/<img width="607" height="375" alt="e1_activation_curve" src="https://github.com/user-attachments/assets/f5012cc0-58a5-49f1-a445-49db6b491a52" />
)

**Key Insight:** Customer activation peaked at **21.67% within 7 days**, while recent cohorts show lower activation because their observation windows are still incomplete.

---

## Checkout Funnel (E2)

![Checkout Funnel](images/<img width="681" height="353" alt="e2_checkout_funnel" src="https://github.com/user-attachments/assets/09a4b7d8-4ed4-4983-9c7c-705078d1a6f7" />
)

**Key Insight:** The largest customer drop-off occurs at the **final Purchase stage (7.56%–8.30%)**, making it the highest-impact opportunity for conversion optimization.

---

## Monthly Recurring Revenue (S1)

![MRR Movements](images/<img width="569" height="383" alt="s1_mrr_movements" src="https://github.com/user-attachments/assets/d186371c-bc7d-4a68-9bce-8ed2902a51ef" />
)

**Key Insight:** Monthly recurring revenue was driven by a combination of new subscriptions, customer expansion, contraction, churn, and reactivation, providing Finance with a complete revenue movement breakdown.

---

## Gross Revenue Retention (S3)

![GRR NRR](images/<img width="758" height="381" alt="s3_grr_nrr" src="https://github.com/user-attachments/assets/3304feb8-64ef-49f8-95ec-e9a59ebdc096" />
)

**Key Insight:** The **September 2022** cohort achieved **92.64% GRR** and **113.95% NRR**, indicating that expansion revenue more than compensated for churn and contraction.

---

## Expansion Revenue (S5)

![Expansion Revenue](images/<img width="449" height="296" alt="s5_expansion_revenue" src="https://github.com/user-attachments/assets/621b84cf-471d-4c7c-9fc5-572967ce8b85" />
)

**Key Insight:** **Seat Expansion contributed $28,259 MRR**, outperforming both plan upgrades (**$19,281**) and add-ons (**$3,467**), making it the primary expansion revenue source.

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
