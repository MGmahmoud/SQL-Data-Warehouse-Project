/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure and content of the dimension tables.
	
SQL Concepts Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- ============================================================================
-- Explore all countries our customers come from
-- ============================================================================
SELECT 
    DISTINCT country 
FROM 
    gold.dim_customers;


-- ============================================================================
-- Explore product categories, subcategories, and product names
-- ============================================================================
SELECT 
    DISTINCT 
        category,        -- Major division
        subcategory, 
        product_name
FROM 
    gold.dim_products
ORDER BY 
    category, 
    subcategory, 
    product_name;
