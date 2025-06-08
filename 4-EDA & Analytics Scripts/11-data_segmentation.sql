/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

--==============================================================================
-- Product Segmentation by Cost Ranges
--==============================================================================

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        product_cost,
        CASE 
            WHEN product_cost < 100 THEN 'Below 100'
            WHEN product_cost < 500 THEN '100 - 499'
            WHEN product_cost < 1000 THEN '500 - 999'
            ELSE '1000+'
        END AS cost_range
    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

--==============================================================================
-- Customer Segmentation by Spending and Tenure
--==============================================================================

-- Step 1: Calculate customer sales and lifespan
WITH customer_spending AS (
    SELECT
        c.customer_key,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(f.sales_amount) AS total_sales,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS life_span
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
)

-- Step 2: Assign segment labels
SELECT
    customer_name,
    total_sales,
    life_span,
    CASE
        WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN life_span >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_spending
ORDER BY total_sales DESC, life_span DESC;

--==============================================================================
-- Customer Count by Segment
--==============================================================================

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_sales,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS life_span
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,
        CASE
            WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN life_span >= 12 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segments
GROUP BY customer_segment
ORDER BY total_customers DESC;