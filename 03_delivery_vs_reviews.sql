-- 03_delivery_vs_reviews.sql
-- Q3: Does late delivery drive lower review scores?
--
-- Reviews are aggregated to order level before joining. order_reviews holds
-- 99,224 rows across 98,673 distinct orders, so 551 orders carry more than
-- one review. Joining the raw table would count review rows rather than
-- orders and weight the average toward multi-review orders.
-- Measured impact: inflates counts by 527 orders, moves the on-time average
-- by 0.01 stars. Immaterial to the finding, but corrected for accuracy.

WITH review_scores AS (
    SELECT order_id, AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS orders,
    ROUND(AVG(rs.review_score), 2) AS avg_review_score
FROM orders o
JOIN review_scores rs ON o.order_id = rs.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  -- Late 2016 excluded: Olist was still onboarding sellers, volumes not representative
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY delivery_status;