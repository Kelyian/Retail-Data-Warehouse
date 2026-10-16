create DATABASE  if not exists retail_data_warehouse;
use retail_data_warehouse;

-- Creating Table customers
Create table if not exists customers(
customer_id varchar(32) primary key,
customer_unique_id varchar(32),
customer_zip_code_prefix int,
customer_city varchar(100),
customer_state varchar(2)
);

-- Creating table orders
create table if not exists orders(
order_id varchar(32) primary key,
customer_id varchar(32) not null,
order_status varchar(20),
order_purchase_timestamp datetime,
order_approved_at datetime,
order_delivered_carrier_date datetime,
order_delivered_customer_date datetime,
order_estimated_delivery_date datetime,
missing_customer_delivery_date boolean,
delivery_days int,
expected_delivery_days int,
delivery_delay_days int,
long_delivery_flag boolean,
delivery_performance varchar(20),

foreign key (customer_id) references customers(customer_id)
);

-- creating products table 
create table if not exists products(
product_id varchar(32) primary key,
product_category_name varchar(100),
product_name_lenght int,
product_description_lenght int,
product_photos_qty int,
product_weight_g int,
product_lenght_cm decimal(10,2),
product_height_cm decimal(10,2),
product_width_cm decimal(10,2),
product_info_missing_flag boolean 
);

-- creating sellers table 
create table if not exists sellers(
seller_id varchar(32) primary key,
seller_zip_code_prefix int,
seller_city varchar(100),
seller_state varchar(2)
);

-- creating table order_items
create table if not exists order_items(
order_id varchar(32) not null,
order_item_id int not null,
product_id varchar(32) not null,
seller_id varchar(32) not null,
shipping_limit_date datetime,
price decimal(10,2),
freight_value decimal(10,2),
item_total decimal(10,2),

primary key (order_id,order_item_id),
foreign key (order_id) references orders(order_id),
foreign key (product_id) references products(product_id),
foreign key (seller_id) references sellers(seller_id)
);

-- creating payments table 
create table if not exists payments(
order_id varchar(32) not null,
payment_sequential int not null,
payment_type varchar(20),
payment_installments int,
payment_value decimal(10,2),

primary key (order_id, payment_sequential),
foreign key (order_id) references orders(order_id)
);

-- creating reviews table 
create table if not exists reviews(
review_id varchar(32) not null,
order_id varchar(32) not null,
review_score int,
review_comment_title text,
review_comment_message text,
review_creation_date datetime,
review_answer_timestamp datetime,

primary key(review_id,order_id),
foreign key (order_id) references orders(order_id)
);

-- creating geolocation table
create table if not exists geolocation(
geolocation_id int auto_increment primary key ,
geolocation_zip_code_prefix int not null,
geolocation_lat decimal(10,7),
geolocation_lng decimal(10,7),
geolocation_city varchar(100),
geolocation_state varchar(2)
);



show tables;




