/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Identify which categories contribute most to total sales.
    - Evaluate performance distribution across product categories.
    - Ideal for pie charts, bar charts, and A/B comparisons.

SQL Functions Used:
    - SUM(): Aggregates sales per category.
    - SUM() OVER(): Computes overall total sales for proportion calculation.
===============================================================================
*/

--==============================================================================
-- Category Contribution to Total Sales
--==============================================================================

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    GROUP BY p.category
)

SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(
        ROUND(
            (CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2
        ), '%'
    ) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;