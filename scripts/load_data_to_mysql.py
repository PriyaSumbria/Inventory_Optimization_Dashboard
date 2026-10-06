import pandas as pd
import mysql.connector

# Load cleaned dataset
df = pd.read_csv("Data/inventory_cleaned.csv")

print("CSV rows:", len(df))
print("CSV columns:", len(df.columns))

# Connect to MySQL
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="psMYSQL@26",
    database="inventory_optimization"
)

cursor = connection.cursor()

# Prepare insert query
columns = [
    "Date",
    "SKU_ID",
    "Warehouse_ID",
    "Supplier_ID",
    "Region",
    "Units_Sold",
    "Inventory_Level",
    "Supplier_Lead_Time_Days",
    "Reorder_Point",
    "Order_Quantity",
    "Unit_Cost",
    "Unit_Price",
    "Promotion_Flag",
    "Stockout_Flag",
    "Demand_Forecast",
    "Inventory_Value",
    "Unit_Margin",
    "Demand_Variance",
    "Reorder_Risk"
]

placeholders = ", ".join(["%s"] * len(columns))

query = f"""
INSERT INTO inventory_data
({", ".join(columns)})
VALUES ({placeholders})
"""

# Convert dataframe rows to tuples
data = [
    tuple(row)
    for row in df[columns].itertuples(index=False, name=None)
]

# Insert data in batches
batch_size = 1000

for i in range(0, len(data), batch_size):
    batch = data[i:i + batch_size]
    cursor.executemany(query, batch)
    connection.commit()

    print(f"Inserted {min(i + batch_size, len(data))} / {len(data)} rows")

cursor.close()
connection.close()

print("Data import completed successfully.")