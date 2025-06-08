/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- =========================================================================
-- Sales Performance Over Time (Yearly)
-- =========================================================================
SELECT
    YEAR(order_date) AS order_year,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- =========================================================================
-- Sales Performance Over Time (Monthly)
-- =========================================================================
SELECT
    MONTH(order_date) AS order_month,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY order_month;

-- =========================================================================
-- Monthly Sales Performance Using DATETRUNC
-- =========================================================================
SELECT
    DATETRUNC(MONTH, order_date) AS order_month,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_month;