# SQL Product Analytics – Business Interpretations

This document summarizes the business objective, key insights, and recommended actions for each SQL analysis included in this portfolio.

---
# E1 – Activation Curve

## Business Question

How quickly do newly registered customers become active after signup?

## What This Analysis Shows

The strongest cohort, beginning **18-May-2026**, achieved a **21.67% 7-day activation rate**, while the most recent cohort reached only **8.79%**. The lower activation for recent cohorts is expected because their observation windows are still incomplete.

## Business Value

- Measures onboarding effectiveness across signup cohorts.
- Identifies cohorts requiring additional activation support.
- Helps Growth and Product teams monitor improvements to the onboarding experience.

## Recommended Action

Review the onboarding journey for the **8-Jun-2026** cohort, which recorded the lowest observed activation (**8.79%**). Compare email delivery, product walkthrough completion, and acquisition channels with the higher-performing **18-May-2026** cohort (**21.67%**) to identify improvement opportunities.
---

# E2 – Checkout Funnel

## Business Question

Where do customers abandon the checkout process, and which stage offers the biggest opportunity to improve conversion?

## What This Analysis Shows

The analysis tracks customer progression through each checkout stage across acquisition channels. The largest drop-off occurred at the **final Purchase step**, with abandonment ranging between **7.56% and 8.30%** across channels. This indicates that most customers successfully progress through checkout but some fail to complete the final purchase.

## Business Value

- Identifies the checkout stage with the greatest customer drop-off.
- Enables Product and Engineering teams to prioritize checkout improvements.
- Helps measure the effectiveness of future checkout optimizations.

## Recommended Action

Investigate the final purchase stage by reviewing payment failures, checkout performance, and user experience. Since all acquisition channels show a similar **7.56%–8.30%** drop-off, improvements at this stage are likely to benefit the overall conversion rate.
---

# E3 – Weekly Retention

## Business Question

Do customers continue returning after signup, and how does retention change over time?

## What This Analysis Shows

The strongest cohort achieved **36.30% Week-1 retention**. Retention gradually declined in later weeks, while recent cohorts show lower values because their observation windows have not yet completed. This highlights the importance of comparing cohorts with similar maturity.

## Business Value

- Measures customer engagement beyond initial activation.
- Identifies long-term retention trends.
- Helps Product and Growth teams evaluate the effectiveness of engagement initiatives.

## Recommended Action

Focus on improving engagement beyond the first week through lifecycle messaging, personalized recommendations, and product notifications. Monitor whether future cohorts improve upon the current **36.30% Week-1 retention** benchmark.
---

# E4 – PDP Engagement

## Business Question

Which high-traffic products underperform compared with similar products in their category?

## What This Analysis Shows

The analysis compares each product's add-to-cart (ATC) rate against the median ATC rate for its category rather than using an absolute benchmark. The highest-view product, **Suta Threads Velvet Kajal**, received **4,334 product page views** but achieved only a **6.0% ATC rate**, performing approximately **30 percentage points below** the median for the **Makeup** category.

## Business Value

- Identifies products attracting strong customer interest but weak conversion.
- Benchmarks products against their own category for fair comparison.
- Helps Merchandising teams prioritize product page improvements with the greatest potential business impact.

## Recommended Action

Review the highest-view products performing below their category median by evaluating pricing, product images, descriptions, customer reviews, and stock availability before increasing marketing spend.
---

# E5 – Cart Abandonment

## Business Question

Which cart-value segments contribute the greatest revenue leakage, and where should checkout optimization efforts be focused?

## What This Analysis Shows

The analysis groups shopping sessions into five cart-value buckets and measures abandonment within each segment. While the **<₹500** bucket recorded the highest abandonment rate (**53%**), the **₹5,000–₹14,999** bucket generated the largest **GMV left on the table (₹9,848,217.87)**. This demonstrates that the highest abandonment percentage does not necessarily correspond to the greatest revenue impact.

## Business Value

- Identifies which cart-value segments contribute the greatest revenue leakage.
- Quantifies GMV lost because of abandoned carts.
- Enables Product, Marketing, and Growth teams to prioritize high-impact checkout improvements.

## Recommended Action

Prioritize checkout optimization for the **₹5,000–₹14,999** segment because it represents the largest revenue recovery opportunity. For lower-value carts, consider targeted promotions such as free-shipping thresholds or limited-time incentives to reduce the **53%** abandonment rate.
---

# S1 – Monthly Recurring Revenue (MRR) Movements

## Business Question

What factors contributed to increases and decreases in Monthly Recurring Revenue (MRR)?

## What This Analysis Shows

The analysis decomposes monthly revenue into **New MRR, Expansion MRR, Contraction MRR, Churn MRR, and Reactivation MRR**, with a running ending MRR balance. The reconciliation confirms that each month's ending MRR equals the previous month's ending MRR plus net revenue movements, providing confidence in the reported metrics.

## Business Value

- Explains the drivers of recurring revenue growth and decline.
- Supports Finance and Revenue Operations reporting.
- Provides a reliable monthly reconciliation of MRR movements.

## Recommended Action

Monitor months where **Churn MRR** and **Contraction MRR** exceed **Expansion MRR**. Investigate customer health, renewal risk, and expansion opportunities before revenue declines become persistent.
---

# S2 – Trial Conversion

## Business Question

How quickly do trial accounts convert into paying customers?

## What This Analysis Shows

Several cohorts achieved **100% conversion within 14 days**, while others converted between **25% and 50%**, indicating significant variation in onboarding effectiveness across signup cohorts.

## Business Value

- Measures the effectiveness of the trial experience.
- Identifies high-performing and low-performing onboarding cohorts.
- Supports Product and Growth teams in improving trial conversion.

## Recommended Action

Compare onboarding journeys for cohorts with **100% 14-day conversion** against cohorts below **50%**, focusing on activation emails, in-app guidance, and early product engagement.
---

# S3 – Gross Revenue Retention (GRR) & Net Revenue Retention (NRR)

## Business Question

How effectively is recurring revenue retained and expanded over a 12-month period?

## What This Analysis Shows

The **September 2022** cohort achieved **92.64% Gross Revenue Retention (GRR)** and **113.95% Net Revenue Retention (NRR)**. This indicates that expansion revenue more than offset revenue lost through churn and contraction within that cohort.

## Business Value

- Measures long-term customer revenue health.
- Separates revenue retention from revenue expansion.
- Supports Customer Success and Revenue teams in evaluating account growth.

## Recommended Action

Replicate the expansion strategies observed in high-performing cohorts while investigating cohorts with lower GRR to reduce churn and contraction.
---

# S4 – Feature Adoption

## Business Question

Is early feature adoption associated with stronger 90-day account retention?

## What This Analysis Shows

The original assignment threshold defined adoption as three or more feature uses within the first 14 days. That threshold produced no usable adopter comparison inside the eligible 90-day observation window.

A documented exploratory threshold of one feature use was therefore used. Under this definition, **API Bulk Operations** had **21 adopters**, with **52.4% retention among adopters versus 29.3% among non-adopters**, a **+23.1 percentage-point lift**.

However, **Zapier Integration** showed the opposite pattern: **13 adopters**, with **30.8% retention among adopters versus 41.2% among non-adopters**, a **−10.4 percentage-point lift**.

## Business Value

- Shows that retention association differs by feature.
- Demonstrates why adoption should not be treated as universally beneficial.
- Provides a framework for comparing adopters with eligible non-adopters.
- Highlights the importance of validating adoption thresholds against the available data.

## Recommended Action

Investigate API Bulk Operations as an onboarding candidate, but control for overall activity and account type before making a product decision. Do not conclude that adoption causes retention because more engaged customers may naturally use more features.
---

# S5 – Expansion Revenue

## Business Question

Which expansion motions contribute the most recurring revenue growth?

## What This Analysis Shows

Seat additions generated **$28,259.00** in expansion MRR, followed by plan upgrades at **$19,360.02** and add-ons at **$3,466.80**. The combined expansion total was **$51,085.82**, which reconciled exactly with S1.

## Business Value

- Identifies the strongest expansion revenue motion.
- Supports Customer Success and Revenue Operations planning.
- Measures expansion revenue per account and time from signup to expansion.
- Confirms consistent event classification through the S1–S5 tie-out.

## Recommended Action

Prioritize seat-growth opportunities through improved admin controls, user-invitation workflows, and account-health prompts. Continue testing plan-upgrade and add-on opportunities as secondary expansion motions.
---

