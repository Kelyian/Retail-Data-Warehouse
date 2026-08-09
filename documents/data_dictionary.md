# Olist Retail Data Warehouse

## Source Data Profile

Table         | Grain                         | primary key 

customers     | 1 row = 1 customer            | customer_id
orders        | 1 row = 1 order               | order_id
order_items   | 1 row = 1 order_id            | order_id + order_item_id
products      | 1 row = 1 product             | prodcut_id
sellers       | 1 row = 1 seller              | sellers_id
payments      | 1 row = 1 payemnt             | order_id + payment_sequential
reviews       | 1 row = 1 review/order        | review_id + order_id
geolocation   | 1 row = 1 geographical observation   | Surrogate key required 

## Findings from the data

### Orders
- 0 duplicate rows
- missing approval,carrier delivery and customer delivery dates exist 
- 99,441 orders

### Customers
- 0 missing values
- 0 duplicate rows
- 2997 repeated customers according to customer_unique_id

###  Order Items
- 0 missing values
- 0 duplicate rows
- Composite key: order_id + order_item_id

### Products
- 610 products have missing category/text information
- 2 products have missing physical measurements
- product_id is unique

### Sellers
- 0 missing values
- 0 duplicate rows
- seller_id is unique

### Payments
- 0 missing values
- Composite key: order_id + payment_sequential

### Reviews
- review_id is not unique
- order_id is not unique
- review_id + order_id is unique

### Geolocation
- 1,000,163 rows
- 261,831 duplicate rows
- 19,015 unique ZIP prefixes
- Requires a surrogate key in the data warehouse