/*
===============================================================================
Product Report View: gold.report_products
===============================================================================
Purpose:
    - Consolidate essential product performance metrics for analytical insights.

Highlights:
    1. Includes product details: name, category, subcategory, cost.
    2. Segments products by total revenue:
        - High-Performer, Mid-Range, Low-Performer.
    3. Aggregates key product metrics:
        - Total orders, quantity, sales, unique customers, lifespan.
    4. Calculates KPIs:
        - Average Order Revenue (AOR)
        - Average Monthly Revenue
        - Recency (months since last sale)
===============================================================================
*/

-- Drop existing view if it exists
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

-- Create the new product report view
CREATE VIEW gold.report_products AS

WITH base_query AS (
    -- Combine product and sales data
    SELECT
        f.order_number,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_cost,
        f.customer_key,
        f.order_date,
        f.quantity,
        f.sales_amount
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
)

, product_aggregations AS (
    -- Aggregate product-level metrics
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        product_cost,
        ROUND(
            AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1
        ) AS avg_selling_price,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        product_cost
)

-- Final projection: calculate KPIs and segments
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,

    -- Segment products by sales performance
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    total_orders,
    total_customers,
    total_quantity,
    total_sales,
    avg_selling_price,

    -- KPI: Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- KPI: Average Monthly Revenue
    CASE
        WHEN life_span = 0 THEN 0
        ELSE total_sales / life_span
    END AS avg_monthly_revenue,

    life_span,

    -- KPI: Recency (months since last sale)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency

FROM product_aggregations;
