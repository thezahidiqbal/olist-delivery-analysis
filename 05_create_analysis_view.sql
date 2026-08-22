-- 05_create_analysis_view.sql
-- Serving layer for Power BI: one row per delivered order.
--
-- Aggregating item totals and review scores in CTEs before joining keeps the
-- grain at one row per order. Joining order_items or order_reviews directly
-- would fan out multi-item and multi-review orders.
--
-- LEFT JOIN on review_scores keeps orders that have no review (643 orders,
-- 0.7%); their review_score is NULL and is excluded from averages downstream.

DROP VIEW IF EXISTS vw_order_analysis;

CREATE VIEW vw_order_analysis AS
WITH item_totals AS (
    SELECT order_id, SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
),
review_scores AS (
    SELECT order_id, AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    o.order_id,
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month,
    c.customer_state,
    t.order_total,
    o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date AS days_vs_promise,
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On time'
        ELSE 'Late'
    END AS delivery_status,
    rs.review_score
FROM orders o
JOIN item_totals t ON o.order_id = t.order_id
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN review_scores rs ON o.order_id = rs.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  -- Late 2016 excluded: Olist was still onboarding sellers
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01';