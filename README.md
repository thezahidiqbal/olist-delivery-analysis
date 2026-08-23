# Olist Delivery Performance and Customer Satisfaction

**Does late delivery drive bad reviews at a Brazilian e-commerce marketplace — and what does it cost?**

**[View the live dashboard →](https://app.powerbi.com/view?r=eyJrIjoiNjFhNzUwOWEtZGZjZC00MjExLWI3NjgtYmQ4OGJlOGNiOGViIiwidCI6ImNmYmJiNzY1LWQyMzItNDFiYy04N2I0LTQ3MjE4OTM3Yjc0NyJ9)**

SQL analysis in PostgreSQL, dashboard in Power BI. 96,203 delivered orders, January 2017 to August 2018.

---

## The question

Olist is a Brazilian marketplace connecting small sellers to major retail platforms. Delivery is handled by sellers and carriers, not by Olist itself, so delivery reliability is something Olist can measure and influence but not directly control.

This analysis asks four things:

1. What is the shape of the business — orders and revenue over time?
2. How long do deliveries actually take, and how does that compare to the date customers were promised?
3. Does late delivery predict a lower review score?
4. Where does the money sit — which states carry the most revenue behind late deliveries?

A fifth question emerged during the analysis and turned out to matter most: **is the late-delivery rate stable, or does it move?**

---

## Data and scope

| | |
|---|---|
| Source | [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) |
| Tables used | `orders`, `order_items`, `order_reviews`, `customers` (4 of 9) |
| Period | January 2017 – August 2018 (20 months) |
| Delivered orders in scope | 96,203 |
| Orders with a review score | 95,560 |

**Scope decisions:**

- **Late 2016 is excluded.** Olist was still onboarding sellers and monthly volumes were not representative.
- **Only `order_status = 'delivered'`.** Cancelled and in-transit orders have no meaningful delivery outcome.
- **Revenue is `price + freight_value`** throughout. Freight is money the customer paid, so including it keeps the revenue figures and the revenue-at-risk figures on the same basis.
- **Late** means delivered after the estimated delivery date shown to the customer.
- **643 orders (0.7%) have no review score.** They are retained for delivery analysis but excluded from review averages, which is why delivery figures cover 96,203 orders and review figures cover 95,560. This is intentional, not a discrepancy.

---

## Method

```
CSV extracts  →  PostgreSQL (00_setup)
                      ↓
              Analysis queries (01–04, 06)
                      ↓
              vw_order_analysis (05) — one row per order
                      ↓
                  Power BI
```

All figures in the dashboard trace back to a query in this repository. The view in `05_create_analysis_view.sql` is a deliberate denormalised serving layer: item totals and review scores are aggregated to order level in CTEs *before* joining, so the grain stays at one row per order rather than fanning out across items and reviews.

---

## Findings

### 1. The delivery promise is heavily padded — and still misses

Average delivery takes **12.5 days**, but orders arrive on average **11.8 days earlier than promised**. Olist quotes deeply conservative dates.

Despite that cushion, **7,822 orders (8.1%) still arrived late**.

### 2. Late delivery roughly halves customer satisfaction

| Delivery | Orders | Avg review score |
|---|---|---|
| On time | 87,902 | **4.30** |
| Late | 7,658 | **2.57** |

A **1.73-star gap** on a 5-point scale. This is the central finding.

### 3. Early delivery buys nothing

Breaking delivery into bands against the promised date shows the relationship is asymmetric:

| Band | Avg review |
|---|---|
| 15+ days early | 4.32 |
| 8–14 days early | 4.31 |
| 1–7 days early | 4.20 |
| On the day | 4.04 |
| 1–7 days late | 2.72 |
| 8–14 days late | 1.67 |
| 15+ days late | 1.73 |

Delivering 15 days early scores essentially the same as delivering on the day. Satisfaction then falls off a cliff the moment an order goes late.

**Customers do not reward early delivery. They punish late delivery.** The padding is buying Olist nothing in goodwill.

### 4. The 8% headline hides severe volatility

This is the finding that changes the recommendation. Monthly late rates range from **1.4% to 21.4%**:

| Month | Late rate | Change |
|---|---|---|
| Oct 2017 | 5.3% | +0.1pp |
| **Nov 2017** | **14.3%** | **+9.0pp** |
| Dec 2017 | 8.4% | −5.9pp |
| Feb 2018 | 16.0% | +9.4pp |
| **Mar 2018** | **21.4%** | **+5.4pp** |
| Apr 2018 | 5.3% | −16.1pp |

**November 2017 is Black Friday.** Order volume rose 63% (4,478 → 7,288) and the late rate more than doubled in a single month. The delivery network fails under peak load.

**March 2018 is the worst month in the series** — more than one order in five arrived late — followed by an abrupt 16.1pp recovery in April. A step change of that size suggests a specific cause (a carrier change or an operational fix) rather than gradual improvement.

Quoting "8% of orders are late" as though it were a stable background rate is misleading. This is a capacity problem that surfaces under load.

### 5. Rate and exposure point to different states

Among states with 500+ orders, **Bahia and Rio de Janeiro** have the highest late rates. But the states with the worst rates are not always the ones with the most money behind them — a small state with a bad rate is a smaller commercial problem than a large state with a moderate one.

**R$1.35M of revenue** was delivered late over the period, against **R$15.37M total**.

---

## Recommendation

**Stop padding the delivery estimate year-round. Start planning capacity for peak.**

The 11.8-day cushion is sized for average conditions and provides no satisfaction benefit — customers score early delivery no higher than on-time delivery. Meanwhile it fails exactly when it is most needed, during volume peaks.

Three actions follow:

1. **Tighten the delivery promise** to something closer to actual performance in normal months. There is no measurable goodwill being purchased by the current padding.
2. **Build surge capacity for November.** The Black Friday spike is predictable and recurring, and it is the single largest driver of late deliveries in the dataset.
3. **Investigate Q1 2018.** The rise to 21.4% in March and the abrupt recovery in April both need a root cause before anyone can be confident the problem is fixed.

Prioritise by revenue exposure, not by late rate alone.

---

## What this analysis cannot tell you

- **Causation.** Late delivery correlates strongly with low review scores, but reviews may also reflect product quality, seller communication or packaging. This analysis cannot separate those effects.
- **The August 2018 figure is not comparable.** The dataset ends in August 2018, so orders placed that month may not have completed delivery before the data was cut. This inflates the final month's late rate. July's +3.1pp rise is the cleaner evidence of late-period deterioration.
- **Why March 2018 happened.** The data shows the spike and the recovery but contains nothing explaining either.
- **Customer lifetime impact.** Whether a late delivery reduces repeat purchasing cannot be measured here, as the dataset does not reliably track customers across orders.
- **Cost of the fix.** Surge capacity has a price, which this dataset does not contain. The revenue-at-risk figure sizes the problem, not the business case.

---

## Repository contents

| File | Purpose |
|---|---|
| `00_setup_load_data.sql` | Creates the four tables and loads the CSV extracts |
| `01_monthly_orders_revenue.sql` | Q1 — orders and revenue by month |
| `02_delivery_performance.sql` | Q2 — delivery speed and reliability against the promise |
| `03_delivery_vs_reviews.sql` | Q3 — review scores by on-time / late |
| `04_revenue_at_risk_by_state.sql` | Q4 — late rate and revenue exposure by state |
| `05_create_analysis_view.sql` | Serving view for Power BI, one row per order |
| `06_late_rate_trend.sql` | Q5 — month-over-month late-rate trend using `LAG()` |

Run `00_setup_load_data.sql` first. The remaining files can be run in any order.

---

## Notes on the SQL

A few decisions worth pointing out, since they are the ones that would otherwise silently distort the results:

- **Fan-out control.** `order_items` has one row per item and `order_reviews` can hold more than one review per order (99,224 rows across 98,673 distinct orders). Joining either table directly to `orders` multiplies rows. Queries 01, 04 and 05 aggregate to order level before joining; query 01 additionally uses `COUNT(DISTINCT order_id)`.
- **Small-sample suppression.** `04` applies `HAVING COUNT(*) >= 500`. Without it, a state with 40 orders can top the late-rate ranking on noise alone and send operations after the wrong problem.
- **Integer division.** Percentages use `100.0 *` rather than `100 *`, which would truncate to whole numbers in PostgreSQL.
- **Null handling.** `05` uses a `LEFT JOIN` for review scores so that orders without a review are retained rather than silently dropped.

---

## Tools

PostgreSQL 18 · pgAdmin 4 · Power BI Desktop · DAX
