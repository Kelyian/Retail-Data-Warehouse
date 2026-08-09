import pandas as pd

"""
Order dataset exploration

"""

#loading the orders dataset
orders = pd.read_csv("data/raw/olist_orders_dataset.csv")
print("FIRST 5 ROWS OF THE DATASET")
print(orders.head())

#size of the data
print("\nSIZE OF THE DATASET")
print(orders.shape)

#colums in the dataset
print("\nCOLUMNS IN THE DATASET")
print(orders.columns)


#datatypes of the colums
print("\nDATATYPES OF THE COLUMNS")
print(orders.dtypes)

#checking for missing values
print("\nMISSING VALUES IN EACH COLUMN")
print(orders.isnull().sum())

#checking for duplicates
print("\nDUPLICATED ROWS")
print(orders.duplicated().sum())

#checking order status distribution
print("\nORDER STATUS DISTRIBUTION")
print(orders['order_status'].value_counts())

#UNIQUE CUSTOMERS
print("\n unique customers: ", orders['customer_id'].nunique())



"""
Customer dataset exploration

"""
customers = pd.read_csv("data/raw/olist_customers_dataset.csv")

print("\nCUSTOMERS: FIRST 5 ROWS")
print(customers.head(5))

print("\nCUSTOMERS:SHAPE")
print(customers.shape)

print("\nCUSTOMERS:COLUMNS")
print(customers.columns)

print("\nCUSTOMERS:DATATYPES")
print(customers.dtypes)

print("\nCUSTOMERS:MISSING VALUES")
print(customers.isnull().sum())

print("\nCUSTOMERS:DUPLICATED ROWS")
print(customers.duplicated().sum())

print("\nCUSTOMERS:UNIQUE CUSTOMERS IDs:")
print(customers['customer_id'].nunique())

print("\nCustomers: UNIQUE CUSTOMER UNIQUE IDs")
print(customers["customer_unique_id"].nunique())

customer_counts = customers["customer_unique_id"].value_counts()

print("\nREPEATED CUSTOMERS")
print((customer_counts > 1).sum())

"""
Order items dataset exploration

"""

order_items = pd.read_csv("data/raw/olist_order_items_dataset.csv")

print("\nORDER ITEMS : FIRST 5 ROWS" )
print(order_items.head(5))

print("\nORDER ITEMS : SHAPE")
print(order_items.shape)

print("\nORDER ITEMS : COLUMNS")
print(order_items.columns)

print("\nORDER ITEMS : DATATYPES")
print(order_items.dtypes)

print("\nORDER ITEMS : MISSING VALUES")
print(order_items.isnull().sum())

print("\nORDER ITEMS : DUPLICATED ROWS")
print(order_items.duplicated().sum())

print("\nORDER ITEMS : UNIQUE ORDER IDs")
print(order_items['order_id'].nunique())

print("\nORDER ITEMS : UNIQUE PRODUCT IDs")
print(order_items['product_id'].nunique())

print("\nORDER ITEMS : UNIQUE SELLER IDs")
print(order_items['seller_id'].nunique())


#order_id and order_item_id should uniquely identify an item
print("\n Duplicate order + item combinations")
print(order_items.duplicated(subset=['order_id', 'order_item_id']).sum())

#checking the maximum number of items per order
print("\nMaximum items per order: ",order_items.groupby("order_id")["order_item_id"].count().max())



"""

Olist products dataset exploration

"""

products = pd.read_csv("data/raw/olist_products_dataset.csv")

print("PRODUCTS : FIRST 5 ROWS")
print(products.head(5))

print("\nPRODUCTS : SHAPE")
print(products.shape)

print("\nPRODUCTS:COLUMNS")
print(products.columns)

print("\nPRODUCTS:DATATYPES")
print(products.dtypes)

print("\nPRODUCTS:MISSING VALUES")
print(products.isnull().sum())

print("\nPRODUCTS : DUPLICATED")
print(products.duplicated().sum())

print("\nPRODCUTS : UNIQUE PRODUCT IDs")
print(products["product_id"].nunique())


"""

Olist sellers dataset exploration

"""

sellers = pd.read_csv("data/raw/olist_sellers_dataset.csv")

print("\nSELLERS : FIRST 5 ROWS")
print(sellers.head(5))

print("\nSELLERS : SHAPE")
print(sellers.shape)

print("\nSELLERS : COLUMNS")
print(sellers.columns)

print("\nSELLERS : DATATYPES")
print(sellers.dtypes)

print("\nSELLERS : MISSING VALUES")
print(sellers.isnull().sum())

print("\nSELLERS : DUPLICATED")
print(sellers.duplicated().sum())

print("\nSELLERS : UNIQUE SELLER IDs")
print(sellers["seller_id"].nunique())


"""

PAYMENTS DATASET

"""

payments = pd.read_csv("data/raw/olist_order_payments_dataset.csv")

print("\nPAYMENTS : FIRST 5 ROWS")
print(payments.head(5))

print("\nPAYMENTS : SHAPE")
print(payments.shape)

print("\nPAYMENTS : COLUMNS")
print(payments.columns)

print("\nPAYMENTS : DATATYPES")
print(payments.dtypes)

print("\nPAYMENTS : MISSING VALUES")
print(payments.isnull().sum())

print("\nPAYMENTS : DUPLICATED")
print(payments.duplicated().sum())

print("\nPAYMENTS : UNIQUE ORDER IDs")
print(payments["order_id"].nunique())

print("\n PAYMENTS: PAYMENT TYPES")
print(payments["payment_type"].value_counts())


"""

REVIEWS DATASET

"""

reviews = pd.read_csv("data/raw/olist_order_reviews_dataset.csv")

print("\nREVIEWS : FIRST 5 ROWS")
print(reviews.head(5))

print("\nREVIEWS : SHAPE")
print(reviews.shape)

print("\nREVIEWS : COLUMNS")
print(reviews.columns)

print("\nREVIEWS : DATATYPES")
print(reviews.dtypes)  

print("\nREVIEWS : MISSING VALUES")
print(reviews.isnull().sum())

print("\nREVIEWS : DUPLICATED")
print(reviews.duplicated().sum())

print("\nREVIEWS: REVIEW SCORES DISTRIBUTION")
print(reviews["review_score"].value_counts().sort_index())

print("\nREVIEWS: UNIQUE ORDER IDs")
print(reviews["order_id"].nunique())

print(
    "Duplicate review IDs:",
    reviews["review_id"].duplicated().sum())

print(
    "Duplicate review_id + order_id combinations:",
    reviews.duplicated(
        subset=["review_id", "order_id"]
    ).sum())

# THUS review_id and order_id act as a composite primary keyfor the reviews dataset.


"""
GOELOCATION DATASET

"""

geolocation = pd.read_csv("data/raw/olist_geolocation_dataset.csv")

print("\nGEOLOCATION : FIRST 5 ROWS")
print(geolocation.head(5))

print("\nGEOLOCATION : SHAPE")
print(geolocation.shape)

print("\nGEOLOCATION : COLUMNS")
print(geolocation.columns)

print("\nGEOLOCATION : DATATYPES")
print(geolocation.dtypes)

print("\nGEOLOCATION : MISSING VALUES")
print(geolocation.isnull().sum())

print("\nGEOLOCATION : DUPLICATED")
print(geolocation.duplicated().sum())
