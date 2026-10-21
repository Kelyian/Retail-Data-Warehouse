## Retail Data Warehouse Architecture 

# 1. Overview

The retail data warehouse uses a star schema to organize the sales data for reporting and e-commerce

The warehouse was developed using MySQL, python and pandas used for data exploartion ,cleaning and transformation 

It consists of one fact table and four dimension tables

# 2. Fact Table
fact_sales

The fact_sales table stores sales information at the order-item level.
Each row represents one item within a customer order.

Primary key: order_id, order_item_id

Foreign keys:

- customer_id

- product_id

- seller_id

- date_key

Measures:

price — Product selling price
freight_value — Shipping cost charged for the item

The table also contains order_date, which records the purchase date.

# 3. Dimension Tables
- dim_customers 
contain customer information,including customer identifiers,city,state and postal code

Primary key: customer_id

- dim_products
Contains product information, including product category, weight, dimensions, and product description attributes.

Primary key: product_id

- dim_sellers

Contains seller information, including seller identifier, city, state, and postal code prefix.

Primary key: seller_id

- dim_date

Contains calendar attributes used for time-based analysis, including year, quarter, month, day, weekday, and weekend indicators.

Primary key: date_key


# 4. Table Relationship 
The fact tbale connects to each dimension through foreign keys 

# 5. Data Validation 
I performed several SQL checks to validate the warehouse including:

- Checking the number of records loaded into the fact table

- Checking for duplicate order-item identifiers

- Checking for missing dimension references

- Comparing sales and freight totals

- Verifying date keys against purchase dates