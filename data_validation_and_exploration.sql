/* ========================================================================
Project: DataCo Supply Chain Analysis
Description: SQL Script for Data Validation & KPI Calculation
Purpose: To cross-verify Power BI dashboard metrics against the raw dataset.
========================================================================
*/

-- =============================================
-- 1. Database Setup & Initialization
-- =============================================
-- Create the database if it doesn't exist (Best practice wrapper)
-- CREATE DATABASE DataCo_SupplyChain; 

USE DataCo_SupplyChain;
GO

-- =============================================
-- 2. Data Preview (Sanity Check)
-- =============================================
-- Inspect the first 10 rows to understand schema and data types
SELECT TOP 10 * FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 3. Time Range Validation
-- =============================================
-- Check the date range to ensure the Power BI date table covers all data
SELECT 
    MIN([Order_Date]) as First_Order_Date,
    MAX([Order_Date]) as Last_Order_Date,
    DATEDIFF(day, MIN([Order_Date]), MAX([Order_Date])) as Total_Days_Covered
FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 4. Financial Metrics Validation (KPI: Profit Margin)
-- =============================================
-- Validating Total Revenue and Profit Margin % matches the dashboard
SELECT 
    SUM([Sales_per_customer]) as Total_Revenue,
    SUM([Benefit_per_order]) as Total_Profit,
    
    -- Calculation: (Total Profit / Total Revenue) * 100
    (SUM([Benefit_per_order]) / SUM([Sales_per_customer])) * 100 as Profit_Margin_Percent
FROM DataCoSupplyChainDataset;
GO

-- =============================================
-- 5. Logistics Metrics Validation (KPI: On-Time Delivery/Late Rate)
-- =============================================
-- Validating the Late Delivery Rate to check Delivery Performance
SELECT 
    COUNT(*) as Total_Orders,
    SUM(CASE WHEN [Delivery_Status] = 'Late delivery' THEN 1 ELSE 0 END) as Late_Count,
    
    -- Calculation: (Late Orders / Total Orders) * 100
    CAST(SUM(CASE WHEN [Delivery_Status] = 'Late delivery' THEN 1.0 ELSE 0.0 END) as DECIMAL(10,2)) / COUNT(*) * 100 as Late_Delivery_Percent
FROM DataCoSupplyChainDataset;
GO
