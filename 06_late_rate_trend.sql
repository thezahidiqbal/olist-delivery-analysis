-- 06_late_rate_trend.sql
-- Q5: Is the late-delivery rate getting better or worse over time?
--
-- Uses LAG() to compare each month's late rate against the previous month.
-- The monthly view matters because the headline 8% late rate is an average
-- across 20 months and hides considerable month-to-month variation.

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month,
        COUNT(*) AS delivered_orders,
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                 THEN 1 ELSE 0 END) AS late_orders
    FROM orders o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      -- Late 2016 excluded: Olist was still onboarding sellers
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY order_month
),
rates AS (
    SELECT
        order_month,
        delivered_orders,
        late_orders,
        ROUND(100.0 * late_orders / delivered_orders, 1) AS late_pct
    FROM monthly
)
SELECT
    order_month,
    delivered_orders,
    late_orders,
    late_pct,
    LAG(late_pct) OVER (ORDER BY order_month) AS prev_month_late_pct,
    ROUND(late_pct - LAG(late_pct) OVER (ORDER BY order_month), 1) AS change_pp
FROM rates
ORDER BY order_month;