/* ========================================================================
Project:     DataCo Supply Chain Analysis (personal project, public Kaggle data)
Script:      data_validation_and_exploration.sql
Purpose:     Cross-check the Power BI dashboard KPIs against the raw table.
Grain:       One row = one ORDER LINE (order item), not one order.
             180K+ order lines roll up to ~66K orders.
Engine:      SQL Server (T-SQL)
========================================================================
*/

USE DataCo_SupplyChain;
GO

-- =============================================
-- 1. Data Preview (Sanity Check)
-- =============================================
-- Inspect the first 10 rows to understand schema and data types
SELECT TOP 10 * FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 2. Grain Check
-- =============================================
-- Confirms one row per order item, and how many distinct orders sit above it.
-- Total_Orders should match the dashboard's 'Total Orders' card (66K, DISTINCTCOUNT).
SELECT
    COUNT(*)                      AS Total_Order_Lines,
    COUNT(DISTINCT Order_Item_Id) AS Distinct_Order_Items,   -- equals Total_Order_Lines => line grain
    COUNT(DISTINCT Order_Id)      AS Total_Orders
FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 3. Time Range Validation
-- =============================================
-- Check the date range so the Power BI date table (CALENDAR over Order_Date) covers all data
SELECT
    MIN(Order_Date)                                AS First_Order_Date,
    MAX(Order_Date)                                AS Last_Order_Date,
    DATEDIFF(day, MIN(Order_Date), MAX(Order_Date)) AS Total_Days_Covered
FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 4. Financial Metrics Validation (KPI: Profit Margin)
-- =============================================
-- Should match the 'Total Revenue', 'Total Profit' and 'Profit Margin %' cards
SELECT
    SUM(Sales_per_customer)                                   AS Total_Revenue,
    SUM(Benefit_per_order)                                    AS Total_Profit,
    -- Calculation: (Total Profit / Total Revenue) * 100
    SUM(Benefit_per_order) / SUM(Sales_per_customer) * 100   AS Profit_Margin_Percent
FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 5. Logistics Metrics Validation (KPI: Late Rate / OTD %)
-- =============================================
-- Line-level, same as the DAX measures (Test_Late_Rate = late lines / all lines; OTD % = 1 - late rate).
-- Note: canceled lines stay in the denominator, as in the dashboard.
SELECT
    COUNT(*)                                                             AS Total_Order_Lines,
    SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END)   AS Late_Lines,
    100.0 * SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*)       AS Late_Delivery_Percent,
    100.0 - 100.0 * SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*) AS OTD_Percent,
    -- Should match 'Avg Real Days' and 'Avg Scheduled Days' (CAST avoids integer averaging)
    AVG(CAST(Days_for_shipping_real AS DECIMAL(10,2)))      AS Avg_Real_Days,
    AVG(CAST(Days_for_shipment_scheduled AS DECIMAL(10,2))) AS Avg_Scheduled_Days
FROM DataCoSupplyChainDataset;
GO
