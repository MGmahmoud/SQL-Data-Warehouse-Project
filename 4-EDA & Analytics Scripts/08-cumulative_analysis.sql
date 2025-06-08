/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - Calculate running totals and moving averages for key metrics.
    - Track cumulative performance over time.
    - Identify long-term trends and patterns in sales behavior.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

--==============================================================================
-- 1. Monthly Total Sales and Running Total
--==============================================================================

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total
FROM (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) AS t
ORDER BY order_date;

--==============================================================================
-- 2. Yearly Total Sales, Running Total & Moving Average of Price
--==============================================================================

SELECT
    YEAR(order_date) AS order_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average
FROM (
    SELECT
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) AS t
ORDER BY order_date;