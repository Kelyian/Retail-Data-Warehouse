import pandas as pd

"""
order dataset

"""

orders = pd.read_csv("data/raw/olist_orders_dataset.csv")

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

customers = pd.read_csv("data/raw/olist_customers_dataset.csv")

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
customers.to_csv("data/processed/customers_cleaned_csv",index = False)