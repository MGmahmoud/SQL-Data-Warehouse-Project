/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Concepts Used:
    - Window Ranking Functions: DENSE_RANK(), ROW_NUMBER()
    - TOP Clause
    - GROUP BY, ORDER BY
===============================================================================
*/

-- ============================================================================
-- Top 5 products by total revenue
-- ============================================================================
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM 
    gold.fact_sales f
LEFT JOIN 
    gold.dim_products p ON f.product_key = p.product_key
GROUP BY 
    p.product_name
ORDER BY 
    total_revenue DESC;


-- ============================================================================
-- Bottom 5 products by total revenue
-- ============================================================================
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM 
    gold.fact_sales f
LEFT JOIN 
    gold.dim_products p ON f.product_key = p.product_key
GROUP BY 
    p.product_name
ORDER BY 
    total_revenue ASC;


-- ============================================================================
-- Top 5 customers by revenue (using ROW_NUMBER)
-- ============================================================================
SELECT 
    *
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_customers,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(f.sales_amount) AS total_revenue
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
        c.first_name, c.last_name
) AS t
WHERE 
    rank_customers <= 5;


-- ============================================================================
-- Top 5 customers by revenue (using TOP N)
-- ============================================================================
SELECT TOP 5
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(f.sales_amount) AS total_revenue
FROM 
    gold.fact_sales f
LEFT JOIN 
    gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
    c.first_name, c.last_name
ORDER BY 
    total_revenue DESC;


-- ============================================================================
-- Bottom 3 customers by number of orders (using TOP N)
-- ============================================================================
SELECT TOP 3
    c.first_name + ' ' + c.last_name AS customer_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM 
    gold.fact_sales f
LEFT JOIN 
    gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
    c.first_name, c.last_name
ORDER BY 
    total_orders ASC;


-- ============================================================================
-- Bottom 3 customers by number of orders (using ROW_NUMBER)
-- ============================================================================
SELECT 
    *
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.order_number) ASC) AS rank_customers,
        c.first_name + ' ' + c.last_name AS customer_name,
        COUNT(DISTINCT f.order_number) AS total_orders
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
        c.first_name, c.last_name
) AS t
WHERE 
    rank_customers <= 3;


-- ============================================================================
-- Bottom 3 customers by number of orders (handling ties with DENSE_RANK)
-- ============================================================================
SELECT 
    *
FROM (
    SELECT
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT f.order_number) ASC) AS rank_customers,
        c.first_name + ' ' + c.last_name AS customer_name,
        COUNT(DISTINCT f.order_number) AS total_orders
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
        c.first_name, c.last_name
) AS t
WHERE 
    rank_customers <= 3;
