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