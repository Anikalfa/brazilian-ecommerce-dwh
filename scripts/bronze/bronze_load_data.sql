USE Brazilian_ecom_DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer for Olist Brazilian E-Commerce';
        PRINT '================================================';

        ------------------------------------------------
        -- 1. olist_customers_dataset
        ------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_customers_dataset;

        BULK INSERT bronze.olist_customers_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_customers_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_customers_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 2. olist_geolocation_dataset
   
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_geolocation_dataset;

        BULK INSERT bronze.olist_geolocation_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_geolocation_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_geolocation_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 3. olist_order_items_dataset
   
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_order_items_dataset;

        BULK INSERT bronze.olist_order_items_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_order_items_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_order_items_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 4. olist_order_payments_dataset
  
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_order_payments_dataset;

        BULK INSERT bronze.olist_order_payments_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_order_payments_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_order_payments_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

      
        -- 5. olist_order_reviews_dataset 
    
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_order_reviews_dataset;

        BULK INSERT bronze.olist_order_reviews_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_order_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_order_reviews_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

      
        -- 6. olist_orders_dataset
     
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_orders_dataset;

        BULK INSERT bronze.olist_orders_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_orders_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_orders_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

  
        -- 7. olist_products_dataset
 
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_products_dataset;

        BULK INSERT bronze.olist_products_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_products_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_products_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

     
        -- 8. olist_sellers_dataset
    
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.olist_sellers_dataset;

        BULK INSERT bronze.olist_sellers_dataset
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\olist_sellers_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> olist_sellers_dataset Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

      
        -- 9. product_category_name_translation
   
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.product_category_name_translation;

        BULK INSERT bronze.product_category_name_translation
        FROM 'C:\Brazilian E-Commerce Public Dataset by Olist\product_category_name_translation.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> product_category_name_translation Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Summary
     
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Bronze Layer Loaded Successfully!';
        PRINT 'Total Execution Time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR LOADING BRONZE LAYER';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;
GO