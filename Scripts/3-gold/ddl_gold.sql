/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (star schema).

    Each view performs transformations and combines data from the Silver layer to
    produce a clean, enriched, and business-ready dataset.

===============================================================================
Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    cl.cntry AS country,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for customer info
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ci.cst_marital_status AS marital_status,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cl
    ON ci.cst_key = cl.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pf.prd_id) AS product_key,
    pf.prd_id AS product_id,
    pf.prd_key AS product_number,
    pf.prd_nm AS product_name,
    pf.prd_cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pf.prd_line AS product_line,
    pf.prd_cost AS product_cost,
    pf.prd_start_dt AS product_start_date
FROM silver.crm_prd_info pf
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pf.prd_cat_id = pc.id
WHERE pf.prd_end_dt IS NULL -- Filter out all historical data
;
GO

-- =============================================================================
-- Create Fact: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    dc.customer_key,
    dp.product_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_price AS price,
    sd.sls_quantity AS quantity,
    sd.sls_sales AS sales_amount
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers dc 
    ON sd.sls_cust_id = dc.customer_id
LEFT JOIN gold.dim_products dp 
    ON sd.sls_prd_key = dp.product_number;
GO
