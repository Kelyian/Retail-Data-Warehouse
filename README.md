# Retail Data Warehouse 

## Project Overview

The project focuses on building a retail data warehouse using python and MySQL. It uses the Brazilian E-Commerce Public dataset by Olist,which contains information about customer orders,products,sellers,payments,deliveries and customer reviews

The goal is to transform raw e-commerce data into an analytical database that supports business analysis and decision making.

The project covers data exploration,cleaning,database design,data loading,validation and SQl analysis.A power BI dashboard is planned to visualize the findings.

## Technologies Used

- MYSQL - Database Management and SQL analysis
- Python - data exploration and cleaning
- Pandas - Data manipulation
- Power BI - Planned data visualization
- Git and Github - project documentation

## Dataset
The project uses the Brazilian E-Commerce dataset available on kaggle.

The dataset contains approximately 100,000 orders and includes several related tables:

- Customers

- Orders

- Order items

- Products

- Sellers

- Payments

- Reviews

- Geolocation

## Project Objectives
1.Explore the raw retail data to understand its structure and quality.

2.Clean and transform the datasets using Python.

3.Create a relational database in MySQL.

4.Load and validate the cleaned data.

5.Design a star schema for analytical queries.

6.Perform SQL analysis to answer business questions.

7.Develop a Power BI dashboard to present the findings.

## The project structure:

Retail-Data-warehouse/
│
├── dashboards/
│
├── data/
│   ├── raw/
│   ├── staging/
│   └── processed/
│
├── documents/
│   └── data_dictionary.md
│
├── python/
│   ├── data_cleaning.py
│   └── data_exploration.py
│
├── sql/
│   ├── Table_creation.sql
│   ├── LOADING DATA.sql
│   ├── Validating the data.sql
│   ├── star_schema.sql
│   └── sql_analysis.sql
│
├── .gitignore
├── .gitkeep
├── README.md
└── Requirements.txt

## DATA PROCESSING 

1. Data Exploration  

Python and pandass were used to check the datasets before loading them into MySQL.

The exploration included:
- Checking the number of  rows and columns 
- Checking missing values
- Checking duplicates
- Understanding the relationships between datasets

2. Data Cleaning and Transformation 

The datasets were cleaned and prepared for database loading 

This included handling missing values,checking duplicates and creating delivery metrics.

3. Database Design and Loading  

Created a relational database named retail_data_warehouse in MySQL.

Used SQL scripts to create tables,load data and validating the records

Created a star schem to support analytical queries using fact and dimension tables 


4.SQL Business Analysis

I wrote SQL queries to investigate some business questions across sales,products,sellers,deliveries,payments, and customer reviews

The analysis uses concepts such as 
- joins
- grouping and filtering
- subqueries 
- aggregations 


## Project Status

# Completed

- Data exploration

- Data cleaning and transformation

- MySQL database creation and loading

- Data validation

- Star schema design

- SQL business analysis

## Dataset source
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

