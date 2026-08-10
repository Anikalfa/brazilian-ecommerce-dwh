USE Brazilian_ecom_DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer for Olist Brazilian E-Commerce';
        PRINT '================================================';

        -- 1. Customers
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_customers_dataset;

        INSERT INTO silver.olist_customers_dataset (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state
        )
        SELECT 
            TRIM('"' FROM TRIM(customer_id)),
            TRIM('"' FROM TRIM(customer_unique_id)),
            TRY_CAST(TRIM('"' FROM TRIM(customer_zip_code_prefix)) AS INT),
            LOWER(TRIM('"' FROM TRIM(customer_city))),
            UPPER(TRIM('"' FROM TRIM(customer_state)))
        FROM bronze.olist_customers_dataset;

        SET @end_time = GETDATE();
        PRINT '>> olist_customers_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 2. Geolocation (Aggregated & Deduplicated by Zip Code)
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_geolocation_dataset;

        INSERT INTO silver.olist_geolocation_dataset (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        )
        SELECT 
            TRY_CAST(TRIM('"' FROM TRIM(geolocation_zip_code_prefix)) AS INT),
            AVG(TRY_CAST(TRIM('"' FROM TRIM(geolocation_lat)) AS FLOAT)),
            AVG(TRY_CAST(TRIM('"' FROM TRIM(geolocation_lng)) AS FLOAT)),
            LOWER(TRIM('"' FROM TRIM(MAX(geolocation_city)))),
            UPPER(TRIM('"' FROM TRIM(MAX(geolocation_state))))
        FROM bronze.olist_geolocation_dataset
        WHERE geolocation_zip_code_prefix IS NOT NULL
        GROUP BY TRY_CAST(TRIM('"' FROM TRIM(geolocation_zip_code_prefix)) AS INT);

        SET @end_time = GETDATE();
        PRINT '>> olist_geolocation_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 3. Order Items
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_order_items_dataset;

        INSERT INTO silver.olist_order_items_dataset (
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value
        )
        SELECT 
            TRIM('"' FROM TRIM(order_id)),
            TRY_CAST(TRIM('"' FROM TRIM(order_item_id)) AS INT),
            TRIM('"' FROM TRIM(product_id)),
            TRIM('"' FROM TRIM(seller_id)),
            TRY_CAST(TRIM('"' FROM TRIM(shipping_limit_date)) AS DATETIME2),
            TRY_CAST(TRIM('"' FROM TRIM(price)) AS DECIMAL(10,2)),
            TRY_CAST(TRIM('"' FROM TRIM(freight_value)) AS DECIMAL(10,2))
        FROM bronze.olist_order_items_dataset;

        SET @end_time = GETDATE();
        PRINT '>> olist_order_items_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 4. Order Payments
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_order_payments_dataset;

        INSERT INTO silver.olist_order_payments_dataset (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value
        )
        SELECT 
            TRIM('"' FROM TRIM(order_id)),
            TRY_CAST(TRIM('"' FROM TRIM(payment_sequential)) AS INT),
            LOWER(TRIM('"' FROM TRIM(payment_type))),
            TRY_CAST(TRIM('"' FROM TRIM(payment_installments)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(payment_value)) AS DECIMAL(10,2))
        FROM bronze.olist_order_payments_dataset;

        SET @end_time = GETDATE();
        PRINT '>> olist_order_payments_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 5. Order Reviews (Updated with Product Priority Logic)
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_order_reviews_dataset;

        WITH RankedReviews AS (
            SELECT 
                TRIM('"' FROM TRIM(r.review_id)) AS review_id,
                TRIM('"' FROM TRIM(r.order_id)) AS order_id,
                TRY_CAST(TRIM('"' FROM TRIM(r.review_score)) AS INT) AS review_score,
                TRIM('"' FROM TRIM(r.review_comment_title)) AS review_comment_title,
                TRIM('"' FROM TRIM(r.review_comment_message)) AS review_comment_message,
                TRY_CAST(TRIM('"' FROM TRIM(r.review_creation_date)) AS DATETIME2) AS review_creation_date,
                TRY_CAST(TRIM('"' FROM TRIM(r.review_answer_timestamp)) AS DATETIME2) AS review_answer_timestamp,
                ROW_NUMBER() OVER(
                    PARTITION BY TRIM('"' FROM TRIM(r.review_id)) 
                    ORDER BY 
                        CASE WHEN oi.order_id IS NOT NULL THEN 1 ELSE 2 END ASC,
                        TRY_CAST(TRIM('"' FROM TRIM(r.review_answer_timestamp)) AS DATETIME2) DESC
                ) AS row_num
            FROM bronze.olist_order_reviews_dataset r
            LEFT JOIN (
                SELECT DISTINCT order_id 
                FROM silver.olist_order_items_dataset
            ) oi ON TRIM('"' FROM TRIM(r.order_id)) = oi.order_id
        )
        INSERT INTO silver.olist_order_reviews_dataset (
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp
        )
        SELECT 
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp
        FROM RankedReviews
        WHERE row_num = 1;

        SET @end_time = GETDATE();
        PRINT '>> olist_order_reviews_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 6. Orders
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_orders_dataset;

        INSERT INTO silver.olist_orders_dataset (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date
        )
        SELECT 
            TRIM('"' FROM TRIM(order_id)),
            TRIM('"' FROM TRIM(customer_id)),
            LOWER(TRIM('"' FROM TRIM(order_status))),
            TRY_CAST(TRIM('"' FROM TRIM(order_purchase_timestamp)) AS DATETIME2),
            TRY_CAST(TRIM('"' FROM TRIM(order_approved_at)) AS DATETIME2),
            TRY_CAST(TRIM('"' FROM TRIM(order_delivered_carrier_date)) AS DATETIME2),
            TRY_CAST(TRIM('"' FROM TRIM(order_delivered_customer_date)) AS DATETIME2),
            TRY_CAST(TRIM('"' FROM TRIM(order_estimated_delivery_date)) AS DATETIME2)
        FROM bronze.olist_orders_dataset;

        SET @end_time = GETDATE();
        PRINT '>> olist_orders_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 7. Products
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_products_dataset;

        INSERT INTO silver.olist_products_dataset (
            product_id,
            product_category_name,
            product_name_length,
            product_description_length,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm
        )
        SELECT 
            TRIM('"' FROM TRIM(product_id)),
            TRIM('"' FROM TRIM(product_category_name)),
            TRY_CAST(TRIM('"' FROM TRIM(product_name_lenght)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(product_description_lenght)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(product_photos_qty)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(product_weight_g)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(product_length_cm)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(product_height_cm)) AS INT),
            TRY_CAST(TRIM('"' FROM TRIM(product_width_cm)) AS INT)
        FROM bronze.olist_products_dataset;

        SET @end_time = GETDATE();
        PRINT '>> olist_products_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 8. Sellers
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.olist_sellers_dataset;

        INSERT INTO silver.olist_sellers_dataset (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        )
        SELECT 
            TRIM('"' FROM TRIM(seller_id)),
            TRY_CAST(TRIM('"' FROM TRIM(seller_zip_code_prefix)) AS INT),
            LOWER(TRIM('"' FROM TRIM(seller_city))),
            LEFT(UPPER(TRIM('"' FROM TRIM(seller_state))), 2)
        FROM bronze.olist_sellers_dataset;

        SET @end_time = GETDATE();
        PRINT '>> olist_sellers_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 9. Product Category Translation
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.product_category_name_translation;

        INSERT INTO silver.product_category_name_translation (
            product_category_name,
            product_category_name_english
        )
        SELECT 
            TRIM('"' FROM TRIM(product_category_name)),
            TRIM('"' FROM TRIM(product_category_name_english))
        FROM bronze.product_category_name_translation;

        SET @end_time = GETDATE();
        PRINT '>> product_category_name_translation Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Summary
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Silver Layer Loaded Successfully!';
        PRINT 'Total Execution Time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR LOADING SILVER LAYER';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '================================================';
        THROW;
    END CATCH
END;
GO