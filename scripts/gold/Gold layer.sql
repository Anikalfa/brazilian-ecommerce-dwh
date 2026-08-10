USE Brazilian_ecom_DataWarehouse;
GO

-- 1. Create Schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END
GO

PRINT '================================================';
PRINT 'Creating Gold Layer Views (Star Schema)';
PRINT '================================================';
GO

--------------------------------------------------
-- 2. Dimension: Customers (gold.dim_customers)
--------------------------------------------------
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix AS zip_code,
    c.customer_city AS city,
    c.customer_state AS state,
    g.geolocation_lat AS latitude,
    g.geolocation_lng AS longitude
FROM silver.olist_customers_dataset c
LEFT JOIN silver.olist_geolocation_dataset g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;
GO

PRINT '>> Created gold.dim_customers';
GO

--------------------------------------------------
-- 3. Dimension: Products (gold.dim_products)
--------------------------------------------------
CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    p.product_id,
    p.product_category_name AS product_category_name_pt,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_en,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM silver.olist_products_dataset p
LEFT JOIN silver.product_category_name_translation t
    ON p.product_category_name = t.product_category_name;
GO

PRINT '>> Created gold.dim_products';
GO

--------------------------------------------------
-- 4. Dimension: Sellers (gold.dim_sellers)
--------------------------------------------------
CREATE OR ALTER VIEW gold.dim_sellers AS
SELECT 
    s.seller_id,
    s.seller_zip_code_prefix AS zip_code,
    s.seller_city AS city,
    s.seller_state AS state,
    g.geolocation_lat AS latitude,
    g.geolocation_lng AS longitude
FROM silver.olist_sellers_dataset s
LEFT JOIN silver.olist_geolocation_dataset g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;
GO

PRINT '>> Created gold.dim_sellers';
GO

--------------------------------------------------
-- 5. Fact: Order Payments (gold.fact_order_payments)
-- Uses ROW_NUMBER() to identify primary payment type by highest value
--------------------------------------------------
CREATE OR ALTER VIEW gold.fact_order_payments AS
WITH RankedPayments AS (
    SELECT 
        order_id,
        payment_type,
        payment_installments,
        payment_value,
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY payment_value DESC, payment_sequential ASC
        ) AS rn
    FROM silver.olist_order_payments_dataset
),
AggregatedPayments AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_payment_value,
        MAX(payment_installments) AS max_installments,
        COUNT(payment_sequential) AS payment_count
    FROM silver.olist_order_payments_dataset
    GROUP BY order_id
)
SELECT 
    a.order_id,
    r.payment_type AS primary_payment_type,
    r.payment_value AS primary_payment_value,
    a.max_installments,
    a.payment_count,
    a.total_payment_value
FROM AggregatedPayments a
JOIN RankedPayments r 
    ON a.order_id = r.order_id 
   AND r.rn = 1;
GO

PRINT '>> Created gold.fact_order_payments';
GO

--------------------------------------------------
-- 6. Fact: Order Items (gold.fact_order_items)
--------------------------------------------------
CREATE OR ALTER VIEW gold.fact_order_items AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.order_status,
    
    -- Date Keys & Timestamps
    CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.shipping_limit_date,
    
    -- Financial Metrics
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value,
    
    -- Review Score
    r.review_score,
    
    -- Delivery Key Performance Indicators (KPIs)
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS actual_delivery_days,
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date) AS estimated_delivery_days,
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_delayed_delivery

FROM silver.olist_order_items_dataset oi
INNER JOIN silver.olist_orders_dataset o 
    ON oi.order_id = o.order_id
LEFT JOIN silver.olist_order_reviews_dataset r 
    ON oi.order_id = r.order_id;
GO

PRINT '>> Created gold.fact_order_items';
GO

--------------------------------------------------
-- 7. Fact: Orders Header Level (gold.fact_orders)
--------------------------------------------------
CREATE OR ALTER VIEW gold.fact_orders AS
WITH SingleReviews AS (
    SELECT 
        order_id,
        AVG(CAST(review_score AS FLOAT)) AS review_score
    FROM silver.olist_order_reviews_dataset
    GROUP BY order_id
)
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    p.primary_payment_type,
    p.max_installments,
    p.total_payment_value,
    r.review_score
FROM silver.olist_orders_dataset o
LEFT JOIN gold.fact_order_payments p ON o.order_id = p.order_id
LEFT JOIN SingleReviews r ON o.order_id = r.order_id;
GO

PRINT '>> Created gold.fact_orders';
GO

PRINT '================================================';
PRINT 'Gold Layer Created Successfully!';
PRINT '================================================';
GO