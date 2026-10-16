-- ============================
-- LOAD CUSTOMERS
-- ============================


LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/customers_cleaned.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    location_inconsistency_flag
);



-- ============================
-- LOAD PRODUCTS
-- ============================

LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/products_cleaned.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    @product_info_missing_flag
);


-- =========================
-- LOAD SELLERS
-- =========================

LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/sellers_cleaned.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
);


-- =====================
-- Load Orders
-- =====================

LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/orders_cleaned.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    missing_customer_delivery_date,
    delivery_days,
    expected_delivery_days,
    delivery_delay_days,
    long_delivery_flag,
    delivery_performance
);

-- ========================
-- LOAD ORDER_ITEMS
-- ========================
LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/order_items_cleaned.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    item_total
);

-- =======================
-- LOAD PAYMENTS 
-- =======================
LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/payments_cleaned.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
);


-- ==================
-- LOAD REVIEWS
-- ==================

LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/reviews_cleaned.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
);



-- =========================
-- LOAD GEOLOCATION 
-- =========================

LOAD DATA LOCAL INFILE 'PATH_TO_PROJECT/data/processed/geolocation_cleaned.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
);