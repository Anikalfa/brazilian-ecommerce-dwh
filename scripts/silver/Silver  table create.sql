USE Brazilian_ecom_DataWarehouse;
GO

-- 1. Customers Dataset
IF OBJECT_ID ('silver.olist_customers_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_customers_dataset;
CREATE TABLE silver.olist_customers_dataset (
    customer_id              NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_unique_id       NVARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city            NVARCHAR(100),
    customer_state           NVARCHAR(10),
    dwh_create_date          DATETIME2 DEFAULT GETDATE()
);

-- 2. Geolocation Dataset (Deduplicated Zip Aggregations)
IF OBJECT_ID ('silver.olist_geolocation_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_geolocation_dataset;
CREATE TABLE silver.olist_geolocation_dataset (
    geolocation_zip_code_prefix INT NOT NULL PRIMARY KEY,
    geolocation_lat             FLOAT,
    geolocation_lng             FLOAT,
    geolocation_city            NVARCHAR(100),
    geolocation_state           NVARCHAR(10),
    dwh_create_date             DATETIME2 DEFAULT GETDATE()
);

-- 3. Order Items Dataset
IF OBJECT_ID ('silver.olist_order_items_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_order_items_dataset;
CREATE TABLE silver.olist_order_items_dataset (
    order_id            NVARCHAR(50) NOT NULL,
    order_item_id       INT NOT NULL,
    product_id          NVARCHAR(50) NOT NULL,
    seller_id           NVARCHAR(50) NOT NULL,
    shipping_limit_date DATETIME2,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_order_items PRIMARY KEY (order_id, order_item_id)
);

-- 4. Order Payments Dataset
IF OBJECT_ID ('silver.olist_order_payments_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_order_payments_dataset;
CREATE TABLE silver.olist_order_payments_dataset (
    order_id             NVARCHAR(50) NOT NULL,
    payment_sequential   INT NOT NULL,
    payment_type         NVARCHAR(50),
    payment_installments INT,
    payment_value        DECIMAL(10,2),
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);

-- 5. Order Reviews Dataset (Deduplicated)
IF OBJECT_ID ('silver.olist_order_reviews_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_order_reviews_dataset;
CREATE TABLE silver.olist_order_reviews_dataset (
    review_id               NVARCHAR(50) NOT NULL PRIMARY KEY,
    order_id                NVARCHAR(50) NOT NULL,
    review_score            INT,
    review_comment_title    NVARCHAR(255),
    review_comment_message  NVARCHAR(MAX),
    review_creation_date    DATETIME2,
    review_answer_timestamp DATETIME2,
    dwh_create_date         DATETIME2 DEFAULT GETDATE()
);

-- 6. Orders Dataset
IF OBJECT_ID ('silver.olist_orders_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_orders_dataset;
CREATE TABLE silver.olist_orders_dataset (
    order_id                      NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id                   NVARCHAR(50) NOT NULL,
    order_status                  NVARCHAR(50),
    order_purchase_timestamp      DATETIME2,
    order_approved_at             DATETIME2,
    order_delivered_carrier_date  DATETIME2,
    order_delivered_customer_date DATETIME2,
    order_estimated_delivery_date DATETIME2,
    dwh_create_date               DATETIME2 DEFAULT GETDATE()
);

-- 7. Products Dataset
IF OBJECT_ID ('silver.olist_products_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_products_dataset;
CREATE TABLE silver.olist_products_dataset (
    product_id                 NVARCHAR(50) NOT NULL PRIMARY KEY,
    product_category_name      NVARCHAR(100),
    product_name_length        INT,
    product_description_length INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT,
    dwh_create_date            DATETIME2 DEFAULT GETDATE()
);

-- 8. Sellers Dataset
IF OBJECT_ID ('silver.olist_sellers_dataset', 'U') IS NOT NULL DROP TABLE silver.olist_sellers_dataset;
CREATE TABLE silver.olist_sellers_dataset (
    seller_id              NVARCHAR(50) NOT NULL PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city            NVARCHAR(100),
    seller_state           VARCHAR(50),
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);

-- 9. Product Category Translation Dataset
IF OBJECT_ID ('silver.product_category_name_translation', 'U') IS NOT NULL DROP TABLE silver.product_category_name_translation;
CREATE TABLE silver.product_category_name_translation (
    product_category_name         NVARCHAR(100) NOT NULL PRIMARY KEY,
    product_category_name_english NVARCHAR(100),
    dwh_create_date               DATETIME2 DEFAULT GETDATE()
);
GO