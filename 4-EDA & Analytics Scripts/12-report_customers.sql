/*
===============================================================================
Customer Report View: gold.report_customers
===============================================================================
Purpose:
    - Consolidate key customer metrics and behaviors into one unified view.

Highlights:
    1. Extracts essential customer fields: name, age, transaction history.
    2. Segments customers by:
        - Engagement (VIP, Regular, New)
        - Age group
    3. Aggregates key metrics:
        - Total orders, sales, quantity, distinct products
        - Customer lifespan (in months)
    4. Calculates KPIs:
        - Average order value (AOV)
        - Average monthly spend
        - Recency (months since last order)
===============================================================================
*/

-- Drop existing view if it exists
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

-- Create the new customer report view
CREATE VIEW gold.report_customers AS

WITH base_query AS (
    -- Base query: Combine customer & sales data
    SELECT
        c.customer_key,
        c.customer_number,
        c.first_name + ' ' + c.last_name AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS customer_age,
        f.product_key,
        f.order_number,
        f.quantity,
        f.sales_amount,
        f.order_date
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
)

, customer_aggregation AS (
    -- Aggregate metrics per customer
    SELECT
        customer_key,
        customer_name,
        customer_age,
        COUNT(DISTINCT product_key) AS total_products,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
    FROM base_query
    GROUP BY 
        customer_key,
        customer_name,
        customer_age
)

SELECT
    customer_key,
    customer_name,
    customer_age,

    -- Age segmentation
    CASE
        WHEN customer_age < 20 THEN 'Under 20'
        WHEN customer_age < 30 THEN '20-29'
        WHEN customer_age < 40 THEN '30-39'
        WHEN customer_age < 50 THEN '40-49'
        ELSE '50 and Above'
    END AS age_group,

    life_span,

    -- Customer segmentation
    CASE
        WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN life_span >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    total_products,
    total_orders,
    total_quantity,
    total_sales,

    -- KPI: Average Order Value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    -- KPI: Average Monthly Spend
    CASE
        WHEN life_span = 0 THEN 0
        ELSE total_sales / life_span
    END AS avg_monthly_spend,

    last_order_date,

    -- KPI: Recency (months since last order)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency

FROM customer_aggregation;