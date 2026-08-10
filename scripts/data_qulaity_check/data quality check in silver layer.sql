SELECT 
geolocation_zip_code_prefix,
count(*)
FROM bronze. olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix
HAVING count(*)>1 OR geolocation_zip_code_prefix IS NULL

--------------------

SELECT geolocation_zip_code_prefix
FROM bronze. olist_customers_dataset
WHERE geolocation_zip_code_prefix != TRIM(geolocation_zip_code_prefix)



SELECT *
FROM bronze.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix = '"40487"';



SELECT 
order_id,
count(*)
FROM bronze. olist_order_items_dataset
GROUP BY order_id
HAVING count(*)>1 OR order_id IS NULL



SELECT *
FROM bronze.olist_order_items_dataset
WHERE order_id = '"11e75c2a931a2968007c44bddf001102"';


SELECT *
FROM silver.olist_order_reviews_dataset
WHERE review_id = '08528f70f579f0c830189efc523d2182';


SELECT * 
FROM bronze.olist_order_reviews_dataset
WHERE review_id = '08528f70f579f0c830189efc523d2182';

SELECT 
    review_id,
    COUNT(*) AS total_occurrences
FROM bronze.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY total_occurrences DESC;


SELECT * FROM silver.olist_customers_dataset


SELECT * FROM silver.olist_geolocation_dataset



SELECT 
order_id,
count(*)
FROM silver. olist_order_payments_dataset
GROUP BY order_id
HAVING count(*)>1 

---fact_order payment check_____

SELECT * 
FROM silver. olist_order_payments_dataset
WHERE order_id = '50089a9784f34a308dc31a939b4b6b1b';

SELECT * 
FROM gold.fact_order_payments
WHERE order_id = '50089a9784f34a308dc31a939b4b6b1b';