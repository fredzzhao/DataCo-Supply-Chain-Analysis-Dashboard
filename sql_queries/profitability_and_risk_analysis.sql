/* ========================================================================
Project:     DataCo Supply Chain Analysis (personal project, public Kaggle data)
Script:      profitability_and_risk_analysis.sql
Purpose:     (1) Pin down what 'Unprofitable Order %' measures.
             (2) Test whether discounting, shipping mode, market or late delivery
                 explains loss-making order lines.
             (3) Fraud and cancellation exposure by market.
Note:        Benefit_per_order is recorded per order LINE in this dataset.
Engine:      SQL Server (T-SQL)
========================================================================
*/

USE DataCo_SupplyChain;
GO

-- =============================================
-- 1. Unprofitable Orders: Two Definitions
-- =============================================
-- Dashboard card 'Unprofitable Order %' = orders with AT LEAST ONE loss-making line / all orders.
-- The stricter view = orders whose TOTAL profit is negative.
WITH Order_Profit AS (
    SELECT
        Order_Id,
        MAX(CASE WHEN Benefit_per_order < 0 THEN 1 ELSE 0 END) AS Has_Loss_Line,
        SUM(Benefit_per_order)                                AS Order_Profit
    FROM DataCoSupplyChainDataset
    GROUP BY Order_Id
)
SELECT
    COUNT(*)                                                                    AS Total_Orders,
    CAST(100.0 * SUM(Has_Loss_Line) / COUNT(*) AS DECIMAL(5,2))                 AS Orders_With_Loss_Line_Percent,
    CAST(100.0 * SUM(CASE WHEN Order_Profit < 0 THEN 1 ELSE 0 END) / COUNT(*)
         AS DECIMAL(5,2))                                                       AS Loss_Making_Orders_Percent
FROM Order_Profit;
GO

-- =============================================
-- 2. What Explains Loss-Making Lines?
-- =============================================
-- If a factor drove losses, the loss-line share would move across its values.

-- 2a. By discount rate
SELECT
    Order_Item_Discount_Rate,
    COUNT(*) AS Order_Lines,
    CAST(100.0 * SUM(CASE WHEN Benefit_per_order < 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Loss_Line_Percent
FROM DataCoSupplyChainDataset
GROUP BY Order_Item_Discount_Rate
ORDER BY Order_Item_Discount_Rate;
GO

-- 2b. By shipping mode
SELECT
    Shipping_Mode,
    COUNT(*) AS Order_Lines,
    CAST(100.0 * SUM(CASE WHEN Benefit_per_order < 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Loss_Line_Percent
FROM DataCoSupplyChainDataset
GROUP BY Shipping_Mode
ORDER BY Loss_Line_Percent DESC;
GO

-- 2c. By market
SELECT
    Market,
    COUNT(*) AS Order_Lines,
    CAST(100.0 * SUM(CASE WHEN Benefit_per_order < 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Loss_Line_Percent
FROM DataCoSupplyChainDataset
GROUP BY Market
ORDER BY Loss_Line_Percent DESC;
GO

-- 2d. Late vs not late
SELECT
    CASE WHEN Delivery_Status = 'Late delivery' THEN 'Late' ELSE 'Not late' END AS Delivery_Group,
    COUNT(*) AS Order_Lines,
    CAST(100.0 * SUM(CASE WHEN Benefit_per_order < 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Loss_Line_Percent
FROM DataCoSupplyChainDataset
GROUP BY CASE WHEN Delivery_Status = 'Late delivery' THEN 'Late' ELSE 'Not late' END;
GO

-- =============================================
-- 3. Unprofitable Order % by Product Category (top 10)
-- =============================================
-- Same definition as the dashboard card, split by category
WITH Order_Category AS (
    SELECT
        Category_Name,
        Order_Id,
        MAX(CASE WHEN Benefit_per_order < 0 THEN 1 ELSE 0 END) AS Has_Loss_Line
    FROM DataCoSupplyChainDataset
    GROUP BY Category_Name, Order_Id
)
SELECT TOP 10
    Category_Name,
    COUNT(*)                                                    AS Orders,
    CAST(100.0 * SUM(Has_Loss_Line) / COUNT(*) AS DECIMAL(5,1)) AS Unprofitable_Order_Percent
FROM Order_Category
GROUP BY Category_Name
HAVING COUNT(*) >= 100          -- skip very small categories
ORDER BY Unprofitable_Order_Percent DESC;
GO

-- =============================================
-- 4. Fraud and Cancellation Exposure by Market
-- =============================================
-- Order level (an order carries one status). Potential loss = revenue on those orders.
WITH Orders AS (
    SELECT
        Order_Id,
        MAX(Market)             AS Market,
        MAX(Order_Status)       AS Order_Status,
        SUM(Sales_per_customer) AS Order_Revenue
    FROM DataCoSupplyChainDataset
    GROUP BY Order_Id
)
SELECT
    Market,
    COUNT(*)                                                                                        AS Orders,
    CAST(100.0 * SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS Fraud_Rate_Percent,
    CAST(100.0 * SUM(CASE WHEN Order_Status = 'CANCELED'        THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS Cancellation_Rate_Percent,
    CAST(SUM(CASE WHEN Order_Status IN ('SUSPECTED_FRAUD', 'CANCELED') THEN Order_Revenue ELSE 0 END)
         AS DECIMAL(14,2))                                                                          AS Potential_Loss
FROM Orders
GROUP BY Market
ORDER BY Fraud_Rate_Percent DESC;
GO
