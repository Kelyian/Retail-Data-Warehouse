-- VARYFYING THE IMPORTED DATA 
-- checking raw counts
select 'customers' as table_name,count(*) as raw_count from customers 
union all 
select 'orders',count(*) from orders 
union all
select 'order_items',count(*) from order_items
union all 
select 'products',count(*) from products
union all 
select 'sellers',count(*) from sellers
union all 
select 'payments',count(*) from payments
union all 
select 'reviews',count(*) from reviews
union all 
select 'geolocation',count(*) from geolocation;

-- checking foreign keys 
select 
	table_name,
	column_name,
    constraint_name,
    referenced_table_name,
    referenced_column_name 
from information_schema.KEY_COLUMN_USAGE
where table_schema = 'retail_data_warehouse' 
	and referenced_table_name is not null ;
    
-- checking primary keys 
select 
	table_name,
    column_name
from information_schema.key_column_usage
where table_schema ='retail_data_warehouse'
	and constraint_name = 'primary';
 
-- checking whether each order points to a valid customer
select count(*) as orphan_orders
from orders o 
left join customers c 
	on o.customer_id = c.customer_id
where c.customer_id is null;

-- checking every order_item.order_id matches and existing orders.order_id
select count(*) as orphan_order_items 
from order_items oi
left join orders o 
	on oi.order_id = o.order_id
where o.order_id is null;

-- check order_items to products 
select count(*) as orphan_order_items
from order_items oi 
left join products p 
	on oi.product_id = p.product_id
where p.product_id is null;

-- checking order_items to sellers 
select count(*) as orphan_order_items 
from order_items oi
left join sellers s
	on oi.seller_id = s.seller_id
where s.seller_id is null;

-- checking payments to order
select count(*) as orphan_payments 
from payments p
left join orders o
	on p.order_id = o.order_id
where o.order_id is null;

-- checking reviews to orders
select count(*) as orphan_reviews
from reviews r 
left join orders o 
	on r.order_id = o.order_id 
where o.order_id is null;

-- checking the datatypes of the columns 
select 
	table_name,
    column_name,
    data_type
from information_schema.columns 
where table_schema = 'retail_data_warehouse' 
order by table_name,ordinal_position;

-- CHECKING FOR UNEXPECTED NULLS 
-- orders 
select 
	count(*) as total_orders,
    SUM(order_approved_at is null) as missing_approved,
    sum(order_delivered_carrier_date is null) as missing_carrier,
    sum(order_delivered_customer_date is null) as missing_customer_delivery,
    sum(delivery_days is null) as missing_delivery_days,
    sum(delivery_delay_days is null) as missing_delay
from orders;

-- This has an error,the orders data has several nullable date columns 
-- Handling the error for order delivered_customer_date
select 
	order_id,
    order_status,
    order_delivered_customer_date,
    delivery_days,
    delivery_performance
from orders
where order_status <> 'delivered' limit 20; -- The missing delivery dates were imported as 0000-00-00 00:00:00 instead of proper SQL values 

-- checking how many zero dates exist 
select count(*) as zero_delivery_dates 
from orders
where cast(order_delivered_customer_date as char)
	like '0000-00-00%'; -- 2965 
    
-- Fixing the delivery dates
update orders
set order_delivered_customer_date = null
where cast(order_delivered_customer_date as char)
	like '0000-00-00%';
    
-- verifying 
select count(*) as missing_delivery_dates 
from orders where order_delivered_customer_date is null;

-- Handling missing_approved and missing carrier dates
update orders 
set order_approved_at = null
where cast(order_approved_at as char)
	like '0000-00-00%';

update orders
set order_delivered_carrier_date = null 
where cast(order_delivered_carrier_date as char)
like '0000-00-00%';

-- verifying both
select 
	sum(order_approved_at is null) as missing_approved_dates,
    sum(order_delivered_carrier_date is null) as missing_carrier_dates
from orders;

select 
	count(*) as missing_delivery_dates,
    sum(delivery_days = 0 ) as zero_delivery_days,
    sum(delivery_delay_days = 0) as zero_delivery_delay
from orders
where order_delivered_customer_date is null;

update orders 
set 
	delivery_days = null,
    delivery_delay_days = null
where order_delivered_customer_date is null;

-- checking whether delivery_performance is correctly stored
select
	delivery_performance,
    count(*) as total_orders
from orders
group by delivery_performance
order by total_orders desc; 
 
-- The orders table is corrected and validated