import pandas as pd

#Loadint the datasets
orders = pd.read_csv("data/raw/olist_orders_dataset.csv")
customers = pd.read_csv("data/raw/olist_customers_dataset.csv")
order_items = pd.read_csv("data/raw/olist_order_items_dataset.csv")
products = pd.read_csv("data/raw/olist_products_dataset.csv")
sellers = pd.read_csv("data/raw/olist_sellers_dataset.csv")
payments = pd.read_csv("data/raw/olist_order_payments_dataset.csv")
reviews = pd.read_csv("data/raw/olist_order_reviews_dataset.csv")
geolocation = pd.read_csv("data/raw/olist_geolocation_dataset.csv")

"""
order dataset

"""


print(orders.head())
print(orders.dtypes)

#converting the date columns 
date_columns = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

for column in date_columns:
    orders[column] = pd.to_datetime(orders[column],errors = "coerce")

print(orders.dtypes)

#checking missing dates by order_status
print(orders.groupby("order_status")[
    [
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date"
    ]
    ].apply(lambda x : x.isna().sum()))


# creating delivery metrics for the orders dataset
orders["delivery_days"] = (orders["order_delivered_customer_date"] - orders["order_purchase_timestamp"]).dt.days

# expected delivery days
orders["expected_delivery_days"] = (orders["order_estimated_delivery_date"] - orders["order_purchase_timestamp"]).dt.days

#Delivary delay in days
orders["delivery_delay_days"] = (orders["order_delivered_customer_date"] - orders["order_estimated_delivery_date"]).dt.days

#checking the new columns
print(orders.head())

#summary statistics for the new columns
print(
    orders[[
        "delivery_days",
        "expected_delivery_days",
        "delivery_delay_days"
    ]].describe()
)

# 209 days  and 188 delivery  delay days  are extreme, understanding why.
#checking delivery days that were greater than 100
print(
    orders.loc[
        orders["delivery_days"] > 100,
        [
            "order_id",
            "order_status",
            "order_purchase_timestamp",
            "order_delivered_customer_date",
            "order_estimated_delivery_date",
            "delivery_days",
            "delivery_delay_days"
        ]
    ]
)

#checking delivery_delays that were > 100
print(
    orders.loc[
        orders["delivery_delay_days"] > 100,
        [
            "order_id",
            "order_status",
            "order_purchase_timestamp",
            "order_delivered_customer_date",
            "order_estimated_delivery_date",
            "delivery_days",
            "delivery_delay_days"
        ]
    ]
)

orders["long_delivery_flag"] = orders["delivery_days"] > 100
print("\n",orders["long_delivery_flag"].value_counts())

#classifying delivery performance
def classify_delivery(delay):
    if pd.isna(delay): #checks for missing values
        return "Not delivered"
    elif delay < 0 :
        return "Early"
    elif delay == 0:
        return "On Time"
    else:
        return "Late"

orders["delivery_performance"] = orders["delivery_delay_days"].apply(classify_delivery)

print("\n",orders["delivery_performance"].value_counts())

#validating the data
print("Shape :",orders.shape)
print("\nMissing values :",orders.isna().sum())
print("\nDuplicate rows :",orders.duplicated().sum())
print("\nDelivery_performance",orders["delivery_performance"].value_counts())

orders.to_csv(
    "data/processed/orders_cleaned.csv",
    index = False
)


"""
Customers Dataset

"""



#cleaning - 0 missing values and duplicate rows
#understanding the ID relationship 

print("\nUnique customer_id :",customers["customer_id"].nunique())
print("Unique customer_unique_id :",customers["customer_unique_id"].nunique())

print("\nCustomer IDs Duplicated:")
print(customers["customer_id"].duplicated().sum())

"""
A customer_unique_id represents the actual customer while differnt customers_ids can reprsent 
that customer's  different orders
"""

#Location data
print("\nUnique cities:",customers["customer_city"].nunique())
print("\nUnique states:", customers["customer_state"].nunique())
print("\nUnique ZIP Prefixes:",customers["customer_zip_code_prefix"].nunique())

print("'\n States")
print(customers["customer_state"].value_counts())

#checking whether the same customer_id has the same location
customer_locations = customers.groupby("customer_unique_id").agg(
    {
        "customer_city" : "nunique",
        "customer_state" : "nunique",
        "customer_zip_code_prefix" : "nunique"
    }
)

print(customer_locations.max()) # For atleast one customer_id ,the dataset contains 3 differnt cities ,states and zip prefixes


# Customers with inconsistent locations

print("Customers with multiple cities:", (customer_locations["customer_city"] > 1).sum())
print("Customers with multiple states:", (customer_locations["customer_state"] > 1).sum())
print("Customers with multiple  ZIP prefixes:", (customer_locations["customer_zip_code_prefix"] > 1).sum())


#investigating customers in multiple states

multi_state_customers = customers[
    customers["customer_unique_id"].isin(
        customer_locations[
            customer_locations["customer_state"] > 1
        ].index
    )
]

print(
    multi_state_customers[
        [
            "customer_unique_id",
            "customer_id",
            "customer_city",
            "customer_state",
            "customer_zip_code_prefix"
        ]
    ].sort_values("customer_unique_id")
)

#The customer placed orders from different locations 

#creating a quality flag 
inconsistent_customers = customer_locations[
    (customer_locations["customer_city"]>1) |
    (customer_locations["customer_state"]>1)|
    (customer_locations["customer_zip_code_prefix"]>1)
].index

customers["location_inconsistency_flag"] = (customers["customer_unique_id"].isin(inconsistent_customers))
#returns True or false 
print(customers["location_inconsistency_flag"].value_counts())

#finding actual customers affected - 252 have some form of location inconsistency
print(
    customers.loc[
    customers["location_inconsistency_flag"],"customer_unique_id"].nunique()
)

#final validation of the transformation 
print("shape:",customers.shape)
print("\nMissing values:",customers.isna().sum())
print("\nDuplicate rows:",customers.duplicated().sum())
print("\nUnique customer_ids :",customers["customer_id"].nunique())
print("\nUnique Customers:",customers["customer_unique_id"].nunique())

#saving the processed data
customers.to_csv("data/processed/customers_cleaned.csv",index = False)

"""
Order_items dataset 
- it had:
    - 112,650 rows
    - 7 columns
    - 0 missing values and duplicate rows
    - 98666 unique orders 
    - 32951 unique products 
    - 3095 unique sellers
    - composite key (order_id + order_item_id)

"""


# range of item numbers 
print("\nMinimum item number :",order_items["order_item_id"].min())
print("Maximum item number :",order_items["order_item_id"].max())

#checking the prices
print(order_items[["price","freight_value"]].describe())

#checking for any negative values 
print("Negatice prices:",(order_items["price"]<0).sum())
print("Negatice freight value:",(order_items["freight_value"]<0).sum())

#checking most expensive items 
print(
    order_items[
        ["order_id","order_item_id","product_id","seller_id","price","freight_value"]
    ].sort_values("price",ascending=False)
    .head(10)
)

#Total item value = price + freight value 
order_items["item_total"] = (order_items["price"] + order_items["freight_value"])
print(order_items[
    ["price","freight_value","item_total"]
].head(5))

#understanding the foreign keys -> order_id,product_id,seller_id
#every order item should belong to an order

missing_orders = ~order_items["order_id"].isin(orders["order_id"])
print("Order IDs missing from orders:",missing_orders.sum())


missing_products = ~order_items["product_id"].isin(products["product_id"])
print("Product IDs missing from products:",missing_products.sum())

missing_sellers = ~order_items["seller_id"].isin(sellers["seller_id"])
print("Seller IDs missing from sellers:",missing_sellers.sum())

#saving the processed dataset 
order_items.to_csv("data/processed/order_items_cleaned.csv",index = False)


"""

products dataset

"""
#checking and handling missing values - checking whether missing values occur on the same products
missing_products = products[products.isna().any(axis=1)]
print(missing_products)
print("\nProducts with any missing values:",missing_products.shape[0]) #returns number of rows with missing values
print(
    "Missing values by product:",
    products.isna().sum(axis=1).value_counts().sort_index()
)

#identifying the one product with 8 missing values 
print(products[products.isna().sum(axis=1) == 8])

#analysing the products with 4 missing values 
print(products[products.isna().sum(axis=1) == 4 ].head())

#checking whether this products are being sold 
missing_product_ids = products[
    products.isna().sum(axis=1) > 0 
]["product_id"]

print(
    "Missing-information products appearing in order items:",
    order_items["product_id"].isin(missing_product_ids).sum() 
)     # 1604 order_item records reference products that have atleast some missing product information

print(
    order_items[
        order_items["product_id"] == "5eb564652db742ff8f28759cd8d2652a"
    ]
) # the product is being sold ..it appears on order_items 18 times 


#checking which 4 columns are missing among the 610 products 
print(
    products[
        products.isna().sum(axis=1) == 4
    ].isna().sum()
)

#filling the categorical field with unknown 
products["product_category_name"] = (products["product_category_name"].fillna("Unknown"))

#creating a flag for the initial data 
products["product_info_missing_flag"] = products.isna().any(axis=1)
print("\n",products.isna().sum())
print(products["product_info_missing_flag"].value_counts())

print(
    "Product IDs in order items missing from products:",
    (~order_items["product_id"].isin(products["product_id"])).sum()
)

products.to_csv("data/processed/products_cleaned.csv")