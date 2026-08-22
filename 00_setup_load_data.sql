-- 00_setup_load_data.sql
-- Creates the four tables used in this project and loads them from the
-- Olist CSV extracts. Run once, before any of the numbered analysis queries.
--
-- Source: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
--
-- Only 4 of the 9 tables in the dataset are needed for this analysis.
-- File paths assume the CSVs sit in C:\olist -- adjust if yours differ.
-- COPY runs as the PostgreSQL service account, so the folder must be
-- readable by that account (a user Desktop folder will fail).

CREATE TABLE orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

CREATE TABLE order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

COPY orders FROM 'C:\olist\olist_orders_dataset.csv'
    WITH (FORMAT csv, HEADER true);

COPY order_items FROM 'C:\olist\olist_order_items_dataset.csv'
    WITH (FORMAT csv, HEADER true);

COPY order_reviews FROM 'C:\olist\olist_order_reviews_dataset.csv'
    WITH (FORMAT csv, HEADER true);

COPY customers FROM 'C:\olist\olist_customers_dataset.csv'
    WITH (FORMAT csv, HEADER true);