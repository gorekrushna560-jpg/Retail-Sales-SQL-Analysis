# Retail Sales Data Analysis — SQL Server / SSMS

## Files
- `Retail_Sales_Dataset.csv`: 1,000 generated sample order rows for practice.
- `Retail_Sales_Analysis_All_SQL.sql`: database/table creation, import helper, validation, 15 analytical sections, window functions, and a summary view.

## Run in SSMS
1. Extract this ZIP.
2. Open SSMS and connect to your SQL Server instance.
3. Open `Retail_Sales_Analysis_All_SQL.sql` and execute the first database/table setup section.
4. In Object Explorer, right-click `RetailSalesDB` > Tasks > Import Flat File (or Import Data).
5. Select `Retail_Sales_Dataset.csv`. Import it into a staging table named `RetailSales_Import` (recommended).
6. Confirm the column names and data types. Then execute the INSERT block in the SQL file to load rows into `dbo.RetailSales`.
7. Run the analysis queries one at a time or section by section.
8. Verify `SELECT COUNT(*) FROM dbo.RetailSales;` returns 1000.

If the import wizard creates a table with a different name, change `dbo.RetailSales_Import` in the INSERT block to match that table. If you import directly into `dbo.RetailSales`, skip the INSERT block (but ensure its schema matches).

## Skills demonstrated
SELECT, WHERE, GROUP BY, HAVING, ORDER BY, aggregate functions, CASE, subquery, CTE, DENSE_RANK, LAG, date functions, data validation, and VIEW.

## Resume-ready project description
**Retail Sales Data Analysis using SQL Server**
- Built a SQL Server database and analyzed 1,000 sample retail order records to evaluate sales, profit, customer, product, regional, and monthly performance.
- Used aggregations, CTEs, subqueries, window functions, and a SQL view to answer business questions and summarize key performance indicators.
- Validated row counts, duplicate order IDs, and key missing values before analysis.

Only include the project on your resume after you have run it yourself and can explain the queries. Dataset is generated for learning and does not represent a real company.
