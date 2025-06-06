/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - Calculate aggregated metrics for quick insights.
    - Identify overall trends or spot anomalies.

SQL Concepts Used:
    - COUNT()
    - SUM()
    - AVG()
    - UNION ALL
===============================================================================
*/

-- ============================================================================
-- Total sales
-- ============================================================================
SELECT 
    SUM(sales_amount) AS total_sales
FROM 
    gold.fact_sales;


-- ============================================================================
-- Total quantity sold
-- ============================================================================
SELECT 
    SUM(quantity) AS total_quantity
FROM 
    gold.fact_sales;


-- ============================================================================
-- Average selling price
-- ============================================================================
SELECT 
    AVG(price) AS avg_price
FROM 
    gold.fact_sales;


-- ============================================================================
-- Total number of orders
-- ============================================================================
/*  Note:  
    The first query counts every row in fact_sales.  
    The second counts distinct order numbers, avoiding duplicates. */
SELECT 
    COUNT(order_number) AS total_orders_raw
FROM 
    gold.fact_sales;

SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM 
    gold.fact_sales;


-- ============================================================================
-- Total number of products
-- ============================================================================
SELECT 
    COUNT(product_key) AS total_products_raw
FROM 
    gold.dim_products;

SELECT 
    COUNT(DISTINCT product_key) AS total_products
FROM 
    gold.dim_products;


-- ============================================================================
-- Total number of customers
-- ============================================================================
SELECT 
    COUNT(customer_key) AS total_customers_raw
FROM 
    gold.dim_customers;

SELECT 
    COUNT(DISTINCT customer_key) AS total_customers
FROM 
    gold.dim_customers;


-- ============================================================================
-- Customers who have placed at least one order
-- ============================================================================
SELECT 
    COUNT(customer_key) AS total_customers_ordered_raw
FROM 
    gold.fact_sales;

SELECT 
    COUNT(DISTINCT customer_key) AS total_customers_ordered
FROM 
    gold.fact_sales;


-- ============================================================================
-- Consolidated metrics report
-- ============================================================================
SELECT 'Total Sales'          AS measure_name, SUM(sales_amount)          AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity'       AS measure_name, SUM(quantity)              AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price'        AS measure_name, AVG(price)                 AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders'     AS measure_name, COUNT(DISTINCT order_number)   AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products'   AS measure_name, COUNT(DISTINCT product_key)    AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers'  AS measure_name, COUNT(DISTINCT customer_key)   AS measure_value FROM gold.dim_customers;
