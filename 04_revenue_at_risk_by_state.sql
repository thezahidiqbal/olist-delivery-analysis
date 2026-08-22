-- 04_revenue_at_risk_by_state.sql
-- Q4: Which states have the worst late-delivery rates, and how much revenue
--     sits behind them?
--
-- Revenue = price + freight_value, consistent with query 01.
--
-- The order_value CTE aggregates to one row per order BEFORE grouping by
-- state. Without it, the join to order_items would fan out multi-item orders
-- and count them repeatedly.
--
-- HAVING COUNT(*) >= 500 suppresses small states. Without this filter a state
-- with 40 orders can top the late-rate ranking on noise alone.

WITH order_value AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(i.price + i.freight_value) AS order_total,
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On time'
            ELSE 'Late'
        END AS delivery_status
    FROM orders o
    JOIN order_items i ON o.order_id = i.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      -- Late 2016 excluded: Olist was still onboarding sellers
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY o.order_id, c.customer_state, delivery_status
)
SELECT
    customer_state,
    COUNT(*) AS orders,
    SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    -- 100.0 forces numeric division; 100 alone would truncate to integers
    ROUND(100.0 * SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct,
    ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN order_total ELSE 0 END), 0) AS revenue_delivered_late
FROM order_value
GROUP BY customer_state
HAVING COUNT(*) >= 500
ORDER BY late_pct DESC;