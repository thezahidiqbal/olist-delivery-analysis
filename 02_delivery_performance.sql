-- 02_delivery_performance.sql
-- Q2: How long do deliveries take, and how do they compare to the promise?
--
-- Two different measures here, and the distinction matters:
--   avg_days_to_deliver  = purchase to doorstep (actual speed)
--   avg_days_vs_promise  = doorstep vs estimated date (reliability)
-- Negative avg_days_vs_promise means orders arrive BEFORE the promised date.
--
-- Casting to ::date gives whole-day differences. Postgres returns an integer
-- number of days when subtracting two dates, which is what we want here --
-- subtracting the raw timestamps would return an interval instead.

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.order_delivered_customer_date::date - o.order_purchase_timestamp::date), 1) AS avg_days_to_deliver,
    ROUND(AVG(o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date), 1) AS avg_days_vs_promise,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders
FROM orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  -- Late 2016 excluded: Olist was still onboarding sellers, volumes not representative
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01';