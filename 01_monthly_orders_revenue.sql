-- 01_monthly_orders_revenue.sql
-- Q1: What is the shape of the business? Orders and revenue by month.
--
-- Revenue is defined as price + freight_value throughout this project.
-- Freight is money the customer paid, and the revenue-at-risk figure in
-- query 04 includes it, so both are on the same basis.
--
-- Scope filters match queries 02-06 so all figures reconcile.

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(i.price + i.freight_value), 2) AS revenue
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  -- Late 2016 excluded: Olist was still onboarding sellers, volumes not representative
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY order_month
ORDER BY order_month;