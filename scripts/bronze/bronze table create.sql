USE Brazilian_ecom_DataWarehouse;
GO

-- 1. Customers Dataset
IF OBJECT_ID ('bronze.olist_customers_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_customers_dataset;
CREATE TABLE bronze.olist_customers_dataset (
    customer_id              NVARCHAR(100),
    customer_unique_id       NVARCHAR(100),
    customer_zip_code_prefix NVARCHAR(50),
    customer_city            NVARCHAR(255),
    customer_state           NVARCHAR(50)
);

-- 2. Geolocation Dataset
IF OBJECT_ID ('bronze.olist_geolocation_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_geolocation_dataset;
CREATE TABLE bronze.olist_geolocation_dataset (
    geolocation_zip_code_prefix NVARCHAR(50),
    geolocation_lat             NVARCHAR(100),
    geolocation_lng             NVARCHAR(100),
    geolocation_city            NVARCHAR(255),
    geolocation_state           NVARCHAR(50)
);

-- 3. Order Items Dataset
IF OBJECT_ID ('bronze.olist_order_items_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_order_items_dataset;
CREATE TABLE bronze.olist_order_items_dataset (
    order_id            NVARCHAR(100),
    order_item_id       NVARCHAR(50),
    product_id          NVARCHAR(100),
    seller_id           NVARCHAR(100),
    shipping_limit_date NVARCHAR(100),
    price               NVARCHAR(50),
    freight_value       NVARCHAR(50)
);

-- 4. Order Payments Dataset
IF OBJECT_ID ('bronze.olist_order_payments_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_order_payments_dataset;
CREATE TABLE bronze.olist_order_payments_dataset (
    order_id             NVARCHAR(100),
    payment_sequential   NVARCHAR(50),
    payment_type         NVARCHAR(100),
    payment_installments NVARCHAR(50),
    payment_value        NVARCHAR(50)
);

-- 5. Order Reviews Dataset
IF OBJECT_ID ('bronze.olist_order_reviews_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_order_reviews_dataset;
CREATE TABLE bronze.olist_order_reviews_dataset (
    review_id               NVARCHAR(100),
    order_id                NVARCHAR(100),
    review_score            NVARCHAR(50),
    review_comment_title    NVARCHAR(500),
    review_comment_message  NVARCHAR(MAX),
    review_creation_date    NVARCHAR(100),
    review_answer_timestamp NVARCHAR(100)
);

-- 6. Orders Dataset
IF OBJECT_ID ('bronze.olist_orders_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_orders_dataset;
CREATE TABLE bronze.olist_orders_dataset (
    order_id                      NVARCHAR(100),
    customer_id                   NVARCHAR(100),
    order_status                  NVARCHAR(100),
    order_purchase_timestamp      NVARCHAR(100),
    order_approved_at             NVARCHAR(100),
    order_delivered_carrier_date  NVARCHAR(100),
    order_delivered_customer_date NVARCHAR(100),
    order_estimated_delivery_date NVARCHAR(100)
);

-- 7. Products Dataset
IF OBJECT_ID ('bronze.olist_products_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_products_dataset;
CREATE TABLE bronze.olist_products_dataset (
    product_id                 NVARCHAR(100),
    product_category_name      NVARCHAR(255),
    product_name_lenght        NVARCHAR(50),
    product_description_lenght NVARCHAR(50),
    product_photos_qty         NVARCHAR(50),
    product_weight_g           NVARCHAR(50),
    product_length_cm          NVARCHAR(50),
    product_height_cm          NVARCHAR(50),
    product_width_cm           NVARCHAR(50)
);

-- 8. Sellers Dataset
IF OBJECT_ID ('bronze.olist_sellers_dataset', 'U') IS NOT NULL DROP TABLE bronze.olist_sellers_dataset;
CREATE TABLE bronze.olist_sellers_dataset (
    seller_id              NVARCHAR(100),
    seller_zip_code_prefix NVARCHAR(50),
    seller_city            NVARCHAR(255),
    seller_state           NVARCHAR(50)
);

-- 9. Product Category Translation Dataset
IF OBJECT_ID ('bronze.product_category_name_translation', 'U') IS NOT NULL DROP TABLE bronze.product_category_name_translation;
CREATE TABLE bronze.product_category_name_translation (
    product_category_name         NVARCHAR(255),
    product_category_name_english NVARCHAR(255)
);
GO