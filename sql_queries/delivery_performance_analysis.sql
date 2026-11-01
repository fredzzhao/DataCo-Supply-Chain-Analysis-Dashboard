/* ========================================================================
Project:     DataCo Supply Chain Analysis (personal project, public Kaggle data)
Script:      delivery_performance_analysis.sql
Purpose:     Where does late delivery come from: shipping mode or geography?
Grain:       Order lines. No order uses more than one shipping mode,
             so line-level and order-level late rates by mode agree closely.
Engine:      SQL Server (T-SQL)
========================================================================
*/

USE DataCo_SupplyChain;
GO

-- =============================================
-- 1. Late Rate and Lead Time by Shipping Mode
-- =============================================
-- Compares the promised lead time (Days_for_shipment_scheduled) with the actual one
-- (Days_for_shipping_real). CAST avoids integer averaging in T-SQL.
SELECT
    Shipping_Mode,
    COUNT(*)                                                                        AS Order_Lines,
    CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,1))                                                AS Late_Rate_Percent,
    CAST(AVG(CAST(Days_for_shipment_scheduled AS DECIMAL(10,2))) AS DECIMAL(5,2))  AS Avg_Scheduled_Days,
    CAST(AVG(CAST(Days_for_shipping_real AS DECIMAL(10,2))) AS DECIMAL(5,2))       AS Avg_Actual_Days,
    CAST(AVG(CAST(Days_for_shipping_real - Days_for_shipment_scheduled AS DECIMAL(10,2)))
         AS DECIMAL(5,2))                                                           AS Avg_Delay_Days
FROM DataCoSupplyChainDataset
GROUP BY Shipping_Mode
ORDER BY Late_Rate_Percent DESC;
GO

-- =============================================
-- 2. Delivery Status Mix by Shipping Mode
-- =============================================
-- Same view as the 'Shipping Mode Efficiency' 100% stacked column chart
SELECT
    Shipping_Mode,
    CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Advance shipping'  THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Advance_Percent,
    CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Shipping on time'  THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS On_Time_Percent,
    CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Late delivery'     THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Late_Percent,
    CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Shipping canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Canceled_Percent
FROM DataCoSupplyChainDataset
GROUP BY Shipping_Mode
ORDER BY Late_Percent DESC;
GO

-- =============================================
-- 3. OTD % by Order Region, Ranked, with the Overall Spread
-- =============================================
-- If geography drove lateness, the spread between best and worst region would be wide.
WITH Region_OTD AS (
    SELECT
        Order_Region,
        COUNT(*) AS Order_Lines,
        100.0 - 100.0 * SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END)
              / COUNT(*) AS OTD_Percent
    FROM DataCoSupplyChainDataset
    GROUP BY Order_Region
)
SELECT
    Order_Region,
    Order_Lines,
    CAST(OTD_Percent AS DECIMAL(5,1))                       AS OTD_Percent,
    RANK() OVER (ORDER BY OTD_Percent ASC)                  AS Worst_Rank,
    CAST(MIN(OTD_Percent) OVER () AS DECIMAL(5,1))          AS Lowest_Region_OTD,
    CAST(MAX(OTD_Percent) OVER () AS DECIMAL(5,1))          AS Highest_Region_OTD
FROM Region_OTD
ORDER BY Worst_Rank;
GO

-- =============================================
-- 4. OTD % by Market
-- =============================================
SELECT
    Market,
    COUNT(*) AS Order_Lines,
    CAST(100.0 - 100.0 * SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,1)) AS OTD_Percent
FROM DataCoSupplyChainDataset
GROUP BY Market
ORDER BY OTD_Percent;
GO
