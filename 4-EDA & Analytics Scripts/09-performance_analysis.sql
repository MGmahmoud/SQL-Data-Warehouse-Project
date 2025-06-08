/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - Evaluate product performance trends year-over-year.
    - Benchmark against product-specific average sales.
    - Identify high or underperforming products.

SQL Functions Used:
    - LAG(): Access prior row for comparison.
    - AVG() OVER(): Compute average within product group.
    - CASE: Label performance trends.
===============================================================================
*/

--==============================================================================
-- Yearly Product Sales with Avg & YoY Performance Insights
--==============================================================================

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
    product_name,
    order_year,
    current_sales,

    -- Benchmark against product's average yearly sales
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Avg'
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Avg'
        ELSE 'Avg'
    END AS avg_change,

    -- Year-over-Year comparison
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY product_name, order_year;