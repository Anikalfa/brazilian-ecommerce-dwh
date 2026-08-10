USE Brazilian_ecom_DataWarehouse;
GO

SELECT 
    r.review_id,
    r.review_score,
    r.review_comment_message,
    
    -- Order Info
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    
    -- Customer Info
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    
    -- Product & Seller Info
    oi.order_item_id,
    p.product_id,
    p.product_category_name,
    oi.price,
    oi.seller_id

FROM bronze.olist_order_reviews_dataset r

-- Join Orders to get Customer Key
JOIN silver.olist_orders_dataset o 
    ON r.order_id = o.order_id

-- Join Customers to get Unique Customer ID
JOIN silver.olist_customers_dataset c 
    ON o.customer_id = c.customer_id

-- Join Order Items to get Product & Seller Details
LEFT JOIN silver.olist_order_items_dataset oi 
    ON o.order_id = oi.order_id

-- Join Products
LEFT JOIN silver.olist_products_dataset p 
    ON oi.product_id = p.product_id

WHERE r.review_id = '08528f70f579f0c830189efc523d2182'
ORDER BY o.order_purchase_timestamp;


SELECT * 
FROM silver.olist_order_reviews_dataset 
WHERE review_id = '08528f70f579f0c830189efc523d2182';



------------- filter using product_id___
USE Brazilian_ecom_DataWarehouse;
GO

SELECT 
    r.review_id,
    r.review_score,
    r.review_comment_message,
    
    -- Order Info
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    
    -- Customer Info
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    
    -- Product & Seller Info
    oi.order_item_id,
    p.product_id,
    p.product_category_name,
    oi.price,
    oi.seller_id

FROM silver.olist_order_reviews_dataset r

-- Join Orders
JOIN silver.olist_orders_dataset o 
    ON r.order_id = o.order_id

-- Join Customers
JOIN silver.olist_customers_dataset c 
    ON o.customer_id = c.customer_id

-- Join Order Items
LEFT JOIN silver.olist_order_items_dataset oi 
    ON o.order_id = oi.order_id

-- Join Products
LEFT JOIN silver.olist_products_dataset p 
    ON oi.product_id = p.product_id

WHERE r.review_id = '08528f70f579f0c830189efc523d2182';