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
print(orders.info())

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
print(customers.info())

print("\nCUSTOMERS:MISSING VALUES")
print(customers.isnull().sum())

print("\nCUSTOMERS:DUPLICATED ROWS")
print(customers.duplicated().sum())

print("\nCUSTOMERS:UNIQUE CUSTOMERS IDs:")
print(customers['customer_id'].nunique())

print("\nCustomers: UNIQUE CUSTOMER UNIQUE IDs")
print(customers["customer_unique_id"].nunique())




