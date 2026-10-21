-- Building a star schema 
-- Creating a sutomers dimension table 
describe customers;
create table if not exists dim_customers(
	customer_id varchar(32) primary key,
    customer_unique_id varchar(32),
    customer_zip_code_prefix int,
    customer_city varchar(100),
    customer_state varchar(2)
);

-- Populating the dimension table
insert into dim_customers(
	customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
select
	customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from customers;

-- checking the data inserted 
select count(*) as total_customer from dim_customers;

-- creating the product dimension 
create table if not exists dim_products(
	product_id varchar(32) primary key,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


-- Loading the dim_products table
INSERT INTO dim_products (
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
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products;

-- Building the fact table 
-- Analysing the source table  -> order_itmes 
describe order_items;

create table fact_sales(
	order_id varchar(32) not null,
    order_item_id int not null,
    customer_id varchar(32),
    product_id varchar(32),
    seller_id varchar(32),
    order_date date,
    price decimal(10,2),
    freight_value decimal(10,2),
    
    primary key(order_id,order_item_id)
);

-- loading fact_sales 
insert into fact_sales(
	order_id,
    order_item_id,
    customer_id,
    product_id,
    seller_id,
    order_date,
    price,
    freight_value
)
select 
	oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    date(o.order_purchase_timestamp),
    oi.price,
    oi.freight_value
from order_items oi 
join orders o 
	on oi.order_id = o.order_id;
    
-- validating the load
select count(*) as total_sales_items from  fact_sales;

-- checking for any missing values 
select
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(order_id, '-', order_item_id)) AS unique_order_items
FROM fact_sales;

select
    SUM(customer_id IS NULL) AS missing_customers,
    SUM(product_id IS NULL) AS missing_products,
    SUM(seller_id IS NULL) AS missing_sellers,
    SUM(order_date IS NULL) AS missing_order_dates
FROM fact_sales;

-- checking the total product price and freight
select 
    ROUND(SUM(price), 2) AS total_product_price,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(AVG(price), 2) AS average_item_price
FROM fact_sales;


-- Creating sellers dimension 
describe sellers;
create table dim_sellers(
	seller_id varchar(32) primary key,
    seller_zip_code_prefix int,
    seller_city varchar(100),
    seller_state varchar(2)
);

-- Loading the data 
insert into dim_sellers(
	seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
select 
	seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
from sellers;


-- creating dim_date 
-- checking the data range from the fact table 
select 
	min(order_date) as first_order_date,
    max(order_date) as last_order_date
from fact_sales;

create table dim_date(
	date_key int primary key,
    full_date date not null,
    year int not null,
    quarter int not null,
    month int not null,
    month_name varchar(55) not null,
    day int not null,
    day_of_week int not null,
    day_name varchar(15) not null,
    is_weekend boolean not null 
);

-- Loading the dates using recursice CTE ***
INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_of_week,
    day_name,
    is_weekend
)
WITH RECURSIVE dates AS (
    SELECT DATE('2016-09-04') AS dt

    UNION ALL

    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM dates
    WHERE dt < '2018-09-03'
)
SELECT
    YEAR(dt) * 10000 + MONTH(dt) * 100 + DAY(dt),
    dt,
    YEAR(dt),
    QUARTER(dt),
    MONTH(dt),
    MONTHNAME(dt),
    DAY(dt),
    WEEKDAY(dt) + 1,
    DAYNAME(dt),
    WEEKDAY(dt) IN (5, 6)
FROM dates;

-- checking the load  
select count(*) as total_dates from dim_date;

-- connecting the fact_sales to dim_dates 
alter table fact_sales
add column date_key int;

update fact_sales 
set date_key = 
	year(order_date) * 10000
    + month(order_date) * 100
    + day(order_date);

-- verifying the results
select 
	order_id,
    order_date,
    date_key
from fact_sales
limit 10;

-- checking that all dates match
select count(*) as unmatched_dates
from fact_sales f
left join dim_date d
	on 	f.date_key = d.date_key
where d.date_key is null;

-- adding a foreign key 
alter table fact_sales 
add constraint fk_sales_date
foreign key (date_key)
references dim_date(date_key);

-- verifying the foreign key  
select 
	f.order_id,
	f.price,
    f.freight_value,
    d.full_date,
    d.month_name,
    d.year
from fact_sales f
join dim_date d
	on f.date_key = d.date_key 
limit 10;

-- connecting the dim_customers to fact_sales
-- checking unmatched customers
select count(*) as unmatched_customers
from fact_sales f
left join dim_customers c
	on f.customer_id = c.customer_id
where c.customer_id is null ;

-- adding a foreign key 
alter table fact_sales 
add constraint fk_sales_customer
foreign key (customer_id)
references dim_customers(customer_id);

-- testing the foreign key 
select 
	f.order_id,
    f.price,
    c.customer_city,
    c.customer_state
from fact_sales f
join dim_customers c 
	on f.customer_id = c.customer_id
limit 10;

-- connecting the dim_products to fact_sales 
-- checking for unmatched products
select count(*) as unmatched_products 
from fact_sales f
left join dim_products p
	on f.product_id = p.product_id
where p.product_id is null;

-- adding a foreign key 
alter table fact_sales
add constraint fk_sales_product 
foreign key (product_id) 
references dim_products(product_id);

-- testing the key 
select 
	f.order_id,
    f.price,
    f.freight_value,
    p.product_category_name
from fact_sales f
join dim_products p 
	on 	f.product_id = p.product_id 
limit 10;

-- connecting the dim_sellers to fact_sales
-- checking unmatched sellers
select count(*) as unmatched_sellers
from fact_sales f
left join dim_sellers s
	on	 f.seller_id = s.seller_id
where s.seller_id is null;


-- adding a foreign key 
alter table fact_sales 
add constraint fk_sales_seller
foreign key (seller_id)
references dim_sellers(seller_id);

-- testing the key 
select 
	f.order_id,
    f.price,
    f.freight_value,
    s.seller_city,
    s.seller_state
from fact_sales f
join dim_sellers s
	on f.seller_id =  s.seller_id 
limit 10;

-- validating the whole star schema 
select 
	count(*) as total_sales_items,
    sum(c.customer_id is null) as missing_customers,
    sum(p.product_id is null) as missing_prodcuts,
    sum(s.seller_id is null) as missing_sellers,
    sum(d.date_key is null) as missing_dates
from fact_sales f
left join dim_customers c
	on f.customer_id = c.customer_id
left join dim_products p 
	on f.product_id = p.product_id 
left join dim_sellers s 
	on f.seller_id = s.seller_id
left join dim_date d
	on f.date_key = d.date_key;

	
















