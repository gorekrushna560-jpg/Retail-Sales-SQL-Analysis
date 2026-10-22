/*
PROJECT: Retail Sales Data Analysis using Microsoft SQL Server (SSMS)
DATASET: Retail_Sales_Dataset.csv (1,000 sample retail order rows)
IMPORTANT:
1. Run this script first to create the database and table.
2. Import Retail_Sales_Dataset.csv into dbo.RetailSales using SSMS:
   Database RetailSalesDB > Tasks > Import Flat File (or Import Data).
   If wizard creates a new table, choose dbo.RetailSales only if available;
   otherwise import into a staging table and use INSERT INTO dbo.RetailSales
   SELECT ... FROM dbo.YourImportedTable after checking column types.
3. For the easiest path, import CSV into a staging table named dbo.RetailSales_Import,
   then run the provided INSERT block below.
4. This is a generated practice dataset, not real customer/business data.
*/

IF DB_ID('RetailSalesDB') IS NULL
    CREATE DATABASE RetailSalesDB;
GO
USE RetailSalesDB;
GO





-- 1. Check data and row count
SELECT COUNT(*) AS TotalRows FROM dbo.RetailSales;
SELECT TOP (10) * FROM dbo.RetailSales ORDER BY OrderID;

-- 2. Check for duplicate OrderIDs
SELECT OrderID, COUNT(*) AS DuplicateCount
FROM dbo.RetailSales
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- 3. Check missing values (basic validation)
SELECT
 SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END) AS MissingOrderDate,
 SUM(CASE WHEN CustomerID IS NULL OR LTRIM(RTRIM(CustomerID)) = '' THEN 1 ELSE 0 END) AS MissingCustomerID,
 SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS MissingSales,
 SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS MissingProfit
FROM dbo.RetailSales;

-- 4. Business KPI summary
SELECT
 COUNT(DISTINCT OrderID) AS TotalOrders,
 COUNT(DISTINCT CustomerID) AS UniqueCustomers,
 SUM(Quantity) AS UnitsSold,
 CAST(SUM(Sales) AS DECIMAL(14,2)) AS TotalSales,
 CAST(SUM(Profit) AS DECIMAL(14,2)) AS TotalProfit,
 CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS DECIMAL(6,2)) AS ProfitMarginPct
FROM dbo.RetailSales;

-- 5. Sales and profit by region
SELECT Region, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM dbo.RetailSales
GROUP BY Region
ORDER BY TotalSales DESC;

-- 6. Category performance
SELECT Category, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit,
       SUM(Quantity) AS UnitsSold
FROM dbo.RetailSales
GROUP BY Category
ORDER BY TotalSales DESC;

-- 7. Monthly sales trend
SELECT YEAR(OrderDate) AS SalesYear, MONTH(OrderDate) AS SalesMonth,
       SUM(Sales) AS MonthlySales, SUM(Profit) AS MonthlyProfit
FROM dbo.RetailSales
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;

-- 8. Top 10 products by sales
SELECT TOP (10) ProductName, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM dbo.RetailSales
GROUP BY ProductName
ORDER BY TotalSales DESC;

-- 9. Top 10 customers by sales
SELECT TOP (10) CustomerID, SUM(Sales) AS TotalSales,
       COUNT(DISTINCT OrderID) AS NumberOfOrders
FROM dbo.RetailSales
GROUP BY CustomerID
ORDER BY TotalSales DESC;

-- 10. Segment analysis
SELECT CustomerSegment, COUNT(DISTINCT OrderID) AS TotalOrders,
       SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM dbo.RetailSales
GROUP BY CustomerSegment
ORDER BY TotalSales DESC;

-- 11. Discount impact (group discount into bands)
SELECT
 CASE WHEN Discount = 0 THEN '0%'
      WHEN Discount <= 0.10 THEN '1-10%'
      WHEN Discount <= 0.20 THEN '11-20%'
      ELSE 'Above 20%' END AS DiscountBand,
 COUNT(*) AS OrderLines,
 SUM(Sales) AS TotalSales,
 AVG(Profit) AS AverageProfit
FROM dbo.RetailSales
GROUP BY CASE WHEN Discount = 0 THEN '0%'
      WHEN Discount <= 0.10 THEN '1-10%'
      WHEN Discount <= 0.20 THEN '11-20%'
      ELSE 'Above 20%' END
ORDER BY MIN(Discount);

-- 12. Orders above average sales using a subquery
SELECT OrderID, OrderDate, CustomerID, Region, Sales
FROM dbo.RetailSales
WHERE Sales > (SELECT AVG(Sales) FROM dbo.RetailSales)
ORDER BY Sales DESC;

-- 13. Rank products by total sales (window function)
WITH ProductSales AS (
    SELECT ProductName, SUM(Sales) AS TotalSales
    FROM dbo.RetailSales
    GROUP BY ProductName
)
SELECT ProductName, TotalSales,
       DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM ProductSales
ORDER BY SalesRank, ProductName;

-- 14. Year-over-year sales comparison
WITH YearlySales AS (
    SELECT YEAR(OrderDate) AS SalesYear, SUM(Sales) AS TotalSales
    FROM dbo.RetailSales
    GROUP BY YEAR(OrderDate)
)
SELECT SalesYear, TotalSales,
       LAG(TotalSales) OVER (ORDER BY SalesYear) AS PreviousYearSales,
       CAST(100.0 * (TotalSales - LAG(TotalSales) OVER (ORDER BY SalesYear))
            / NULLIF(LAG(TotalSales) OVER (ORDER BY SalesYear), 0) AS DECIMAL(8,2)) AS YoYGrowthPct
FROM YearlySales
ORDER BY SalesYear;

-- 15. Create a reusable summary view
IF OBJECT_ID('dbo.vw_RetailSalesSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_RetailSalesSummary;
GO
CREATE VIEW dbo.vw_RetailSalesSummary AS
SELECT OrderID, OrderDate, YEAR(OrderDate) AS SalesYear,
       MONTH(OrderDate) AS SalesMonth, CustomerID, CustomerSegment,
       Region, City, ShipMode, Category, SubCategory, ProductName,
       Quantity, UnitPrice, Discount, Sales, Cost, Profit,
       CAST(100.0 * Profit / NULLIF(Sales, 0) AS DECIMAL(8,2)) AS ProfitMarginPct
FROM dbo.RetailSales;
GO

SELECT TOP (20) * FROM dbo.vw_RetailSalesSummary ORDER BY Sales DESC;
