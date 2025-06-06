/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the span of historical data available.

SQL Functions Used:
    - MIN()
    - MAX()
    - DATEDIFF()
===============================================================================
*/

-- ============================================================================
-- Find the date of the first and last order
-- How many years of sales are available?
-- ============================================================================
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM 
    gold.fact_sales;


-- ============================================================================
-- Find the youngest and oldest customers
-- ============================================================================
SELECT
    MAX(birthdate) AS youngest_birthdate,
    MIN(DATEDIFF(YEAR, birthdate, GETDATE())) AS youngest_age,
    MIN(birthdate) AS oldest_birthdate,
    MAX(DATEDIFF(YEAR, birthdate, GETDATE())) AS oldest_age
FROM 
    gold.dim_customers;

