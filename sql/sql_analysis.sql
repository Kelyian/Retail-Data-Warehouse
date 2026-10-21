-- ANALYSIS OF THE DATA 
-- What is the total sales revenue,total freight_value,number of orders and average item price 
select
	sum(price) as total_sales_revenue,
	sum(freight_value) as total_freight_cost,
    count(distinct order_id) as total_orders,
	avg(price) as average_item_price 
from fact_sales;

-- How do sales and order volumes change from month to month?
select 
	d.year,
	d.month,
    d.month_name,
    count(distinct f.order_id) as total_order,
    sum(f.price) as total_revenue 
from fact_sales f 
join dim_date d 
	on f.date_key = d.date_key
group by 
	d.year,
    d.month,
    d.month_name
order by 
	d.year,
    d.month;

-- 3.	Which months and years recorded the highest and lowest sales?
select 
	d.year,
    d.month,
    d.month_name,
    sum(f.price) as total_revenue
from fact_sales f
join dim_date d
	on f.date_key = d.date_key
group by
	d.year,
    d.month_name
order by total_revenue desc;

-- 4.	What is the average order value, and how does it change over time?
select
	d.year,
    d.month_name,
    count(distinct f.order_id) as total_orders,
    sum(f.price) as total_revenue,
    (sum(f.price) / count(distinct f.order_id)) as average_order_value
from fact_sales f
join dim_date d
	on 	f.date_key = d.date_key
group by 
	d.year,
    d.month,
    d.month_name 
order by 
	d.year,
    d.month;

-- product performance 
-- 5.	Which product categories generate the highest sales revenue?
select
	p.product_category_name,
	sum(f.price) as total_revenue
from fact_sales f
join dim_products p 
	on f.product_id =  p.product_id 
group by 
	p.product_category_name
order by total_revenue desc;
    
--  6.	Which product categories have the highest number of items sold?
select 
	p.product_category_name,
    count(*) as total_items_sold 
from fact_sales f
join dim_products p
	on f.product_id = p.product_id
group by 
	p.product_category_name
order by 
	total_items_sold desc;

-- 7.	What are the top 10 best-selling products by sales revenue?
select 
	f.product_id,
    p.product_category_name,
    sum(f.price) as total_revenue
from fact_sales f
join dim_products p
	on f.product_id = p.product_id
group by 
	f.product_id,
    p.product_category_name
order by 
	total_revenue desc
    limit 10;
    
-- 8.	Which product categories have the highest average item prices?
select 
	p.product_category_name,
    avg(f.price) as average_item_price
from fact_sales f
join dim_products p 
	on f.product_id = p.product_id
group by 
	p.product_category_name
order by 
	average_item_price desc 
    limit 10 ;

-- customer analysis 
-- 9.	Which Brazilian states generate the highest sales revenue?
select 
	c.customer_state,
    sum(f.price) as total_revenue
from fact_sales f
join dim_customers c
	on f.customer_id = c.customer_id
group by 
	c.customer_state
order by total_revenue desc;

-- 10.	Which cities contribute the most orders and revenue?
select 
	c.customer_city,
    c.customer_state,
    count(distinct f.order_id) as total_orders,
    sum(f.price) as total_revenue 
from fact_sales f
join dim_customers c
	on f.customer_id = c.customer_id
group by 
	c.customer_city,
    c.customer_state
order by 
	total_revenue desc
limit 10;

-- 11. How many unique customers make repeat purchases

select
	count(*) as total_unique_customers,
    sum(case 
		when total_orders > 1 then 1
        else 0
	end) as repeat_customers
from (
	select
		c.customer_unique_id,
        count(distinct f.order_id) as total_orders 
	from fact_sales f
    join dim_customers c
		on f.customer_id = c.customer_id
	group by  
		c.customer_unique_id
)  as customer_orders;
    
-- 12.	What is the average number of orders per unique customer?
select 
	avg(total_orders) as average_orders_per_customer
from (
	select 
		c.customer_unique_id,
		count(distinct f.order_id) as total_orders
	from fact_sales f 
    join dim_customers c
		on f.customer_id = c.customer_id 
	group by 
		c.customer_unique_id 
) as customer_orders;
    
-- seller performance
-- 13.	Which sellers generate the highest sales revenue?
select 
	s.seller_id,
    s.seller_city,
    s.seller_state,
    sum(f.price) as total_revenue
from fact_sales f
join dim_sellers s
	on f.seller_id = s.seller_id
group by 
	f.seller_id,
    s.seller_city,
    s.seller_state
order by 
	total_revenue desc
    limit 10;
	
-- 14 which sellers fulfil the largest number of orders
select 
	count(distinct f.order_id) as total_orders,
    s.seller_id,
    s.seller_city,
    s.seller_state
from fact_sales f
join dim_sellers s
	on f.seller_id = s.seller_id 
group by 
	s.seller_id,
	s.seller_city,
    s.seller_state
order by 
	total_orders desc
    limit 10;

-- 15.	What is the average sales value per seller?
select 
	count(*) as total_active_sellers,
    avg(seller_revenue) as average_seller_revenue 
from(
	select 
		seller_id,
        sum(price) as seller_revenue
	from fact_sales
    group by seller_id
) as seller_sales;


-- 16.	Which states have the highest concentration of sellers and sales?

select
    delivery_performance,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM orders
            WHERE order_status = 'delivered'
              AND delivery_performance IN
                  ('Early', 'On Time', 'Late')
        ),
        2
    ) AS percentage
FROM orders
WHERE order_status = 'delivered'
  AND delivery_performance IN
      ('Early', 'On Time', 'Late')
GROUP BY
    delivery_performance
ORDER BY
    total_orders DESC;
    
    

-- Q17. What percentage of delivered orders
-- arrived early, on time, or late?


-- Q17. What percentage of delivered orders
-- arrived early, on time, or late?

-- Q17. What percentage of delivered orders
-- arrived early, on time, or late?
SELECT
    delivery_performance,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
WHERE order_status = 'delivered'
  AND delivery_performance IN ('Early', 'On Time', 'Late')
GROUP BY delivery_performance
ORDER BY total_orders DESC;

-- 18.	What is the average delivery time for each delivery performance category?
select
	delivery_performance,
    count(*) as total_orders,
    avg(delivery_days) as avg_delivery_days
from orders 
where order_status = 'delivered'
	and delivery_performance in ('Early','On Time','Late')
group by 
	delivery_performance
order by 
	avg_delivery_days desc;

-- 19 which states experience the longest delivery times?
select
	c.customer_state,
    count(*) as total_orders,
    avg(o.delivery_days) as avg_delivery_days
from orders o 
join customers c 
	on o.customer_id = c.customer_id 
where o.order_status = 'delivered'
and o.delivery_days is not null 
group by
	c.customer_state
order by 
	avg_delivery_days desc;

-- 20 which payment methods are used most frequently 
select 
	payment_type,
    count(*) as total_payments
from payments 
group by 
	payment_type
order by 
	total_payments desc;
    
-- 21.	What is the average payment value by payment method?
select 
	payment_type,
    round(avg(payment_value),2) as avg_payment_value
from payments
group by 
	payment_type
order by
	avg_payment_value desc;


-- 22.	How do payment methods differ in their contribution to total payment value?
select
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(
        SUM(payment_value) * 100.0 /
        (SELECT SUM(payment_value) FROM payments),
        2
    ) AS percentage_contribution
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- 23.	How often do orders use multiple payment instalments?
select 
	case
		when payment_installments = 1 
			then 'Single installment'
		when payment_installments > 1 
			then 'Multiple installments'
		else
			'zero installments'
	end as installment_category,
    count(distinct order_id ) as total_orders
from payments 
group by 
	installment_category
order by 
	total_orders desc;

-- customer review performance
-- 24	What is the average customer review score?
select 
	count(*) as total_reviews,
    avg(review_score) as avg_review_score,
    min(review_score) as lowest_score,
    max(review_score) as highest_score
from reviews;

--  25.	Which product categories receive the highest and lowest review scores?
select 
	p.product_category_name,
    count(distinct r.review_id) as total_reviews,
    avg(r.review_score) as avg_review_score
from reviews r 
join orders o 
	on r.order_id = o.order_id 
join order_items oi
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
where p.product_category_name is not null
group by 
	p.product_category_name 
order by 
	avg_review_score desc;

--  26.	Which states have the highest and lowest average review scores?
select 
	c.customer_state,
    count(*) as total_reviews,
    avg(review_score) as avg_review_score
from reviews r
join orders o 
	on r.order_id = o.order_id 
join customers c 
	on o.customer_id = c.customer_id 
group by 
	c.customer_state
order by 
	avg_review_score desc;
    

-- 27.	Are late deliveries associated with lower customer review scores?

SELECT
    o.delivery_performance,
    COUNT(*) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
    AND o.delivery_performance IN ('Early', 'On Time', 'Late')
GROUP BY o.delivery_performance
ORDER BY avg_review_score DESC;
