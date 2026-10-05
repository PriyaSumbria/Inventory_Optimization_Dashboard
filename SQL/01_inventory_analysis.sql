-- Inventory Optimization Dashboard
-- SQL Business Analysis
-- Author: Priya Sumbria

-- Dataset:
-- High-Dimensional Supply Chain Inventory Dataset

-- Objective:
-- Analyze inventory value, demand, reorder risk,
-- supplier performance, warehouse performance,
-- inventory turnover, and forecast accuracy.

USE inventory_optimization;


-- 1. OVERALL INVENTORY KPIs

SELECT
    ROUND(SUM(Inventory_Value), 2) AS Total_Inventory_Value,
    ROUND(AVG(Inventory_Level), 2) AS Average_Inventory_Level,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(AVG(Demand_Forecast), 2) AS Average_Daily_Demand,
    SUM(Reorder_Risk) AS Reorder_Risk_Records,
    ROUND(AVG(Reorder_Risk) * 100, 2) AS Reorder_Risk_Percentage
FROM inventory_data;

-- Query 2: Top 10 SKUs by Inventory Value

SELECT
    SKU_ID,
    ROUND(SUM(Inventory_Value), 2) AS Total_Inventory_Value,
    ROUND(AVG(Inventory_Level), 2) AS Average_Inventory,
    SUM(Units_Sold) AS Total_Units_Sold
FROM inventory_data
GROUP BY SKU_ID
ORDER BY Total_Inventory_Value DESC
LIMIT 10;

-- Query 3: Top 10 SKUs by Units Sold

SELECT
    SKU_ID,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(AVG(Inventory_Level), 2) AS Average_Inventory,
    ROUND(SUM(Inventory_Value), 2) AS Total_Inventory_Value
FROM inventory_data
GROUP BY SKU_ID
ORDER BY Total_Units_Sold DESC
LIMIT 10;

-- Query 4: Highest Reorder-Risk SKUs
-- =====================================================

SELECT
    SKU_ID,
    SUM(Reorder_Risk) AS Reorder_Risk_Count,
    COUNT(*) AS Total_Records,
    ROUND(
        SUM(Reorder_Risk) * 100.0 / COUNT(*),
        2
    ) AS Reorder_Risk_Percentage,
    ROUND(AVG(Inventory_Level), 2) AS Average_Inventory,
    ROUND(AVG(Reorder_Point), 2) AS Average_Reorder_Point
FROM inventory_data
GROUP BY SKU_ID
ORDER BY Reorder_Risk_Percentage DESC
LIMIT 10;

-- =====================================================
-- Query 5: Warehouse Performance
-- =====================================================

SELECT
    Warehouse_ID,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(AVG(Inventory_Level), 2) AS Average_Inventory,
    SUM(Reorder_Risk) AS Reorder_Risk_Count,
    ROUND(AVG(Reorder_Risk) * 100, 2) AS Reorder_Risk_Percentage
FROM inventory_data
GROUP BY Warehouse_ID
ORDER BY Inventory_Value DESC;

-- =====================================================
-- Query 6: Supplier Performance
-- =====================================================

SELECT
    Supplier_ID,
    ROUND(AVG(Supplier_Lead_Time_Days), 2) AS Average_Lead_Time,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value,
    SUM(Reorder_Risk) AS Reorder_Risk_Count,
    ROUND(AVG(Reorder_Risk) * 100, 2) AS Reorder_Risk_Percentage
FROM inventory_data
GROUP BY Supplier_ID
ORDER BY Reorder_Risk_Percentage DESC;


-- =====================================================
-- Query 7: Inventory Turnover
-- =====================================================

WITH sku_metrics AS (
    SELECT
        SKU_ID,
        SUM(Units_Sold * Unit_Cost) AS Total_COGS,
        AVG(Inventory_Value) AS Average_Inventory_Value
    FROM inventory_data
    GROUP BY SKU_ID
)
SELECT
    SKU_ID,
    ROUND(Total_COGS, 2) AS Total_COGS,
    ROUND(Average_Inventory_Value, 2) AS Average_Inventory_Value,
    ROUND(
        Total_COGS / NULLIF(Average_Inventory_Value, 0),
        2
    ) AS Inventory_Turnover
FROM sku_metrics
ORDER BY Inventory_Turnover ASC
LIMIT 10;


-- =====================================================
-- Query 8: Demand Forecast Accuracy
-- =====================================================

SELECT
    SKU_ID,
    ROUND(
        AVG(ABS(Units_Sold - Demand_Forecast)),
        2
    ) AS MAE,
    ROUND(
        AVG(Units_Sold - Demand_Forecast),
        2
    ) AS Forecast_Bias
FROM inventory_data
GROUP BY SKU_ID
ORDER BY MAE DESC
LIMIT 10;


-- =====================================================
-- Query 9: Reorder-Risk Records
-- =====================================================

SELECT
    SKU_ID,
    Warehouse_ID,
    Inventory_Level,
    Reorder_Point,
    Order_Quantity,
    Supplier_Lead_Time_Days
FROM inventory_data
WHERE Reorder_Risk = 1
ORDER BY Inventory_Level ASC;