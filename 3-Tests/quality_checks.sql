/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'bronze', 'silver', and 'gold' schemas.
    It includes checks for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization and consistency
    - Invalid date ranges and orders 
    - Data consistency between related fields

Usage Notes:
    - Run these checks after loading the data into each layer
    - Investigate and resolve any discrepancies found during the checks
===============================================================================
*/


-- =============================================================================
-- Bronze Layer
-- =============================================================================

-------------------------------------------------------------------------------
-- Checking 'bronze.crm_cust_info'
-------------------------------------------------------------------------------

-- Check for nulls or duplicates in primary key  
-- Expectation: No results  
SELECT  
    cst_id,  
    COUNT(*)  
FROM bronze.crm_cust_info  
GROUP BY cst_id  
HAVING COUNT(*) > 1 OR cst_id IS NULL;  

-- Check for unwanted spaces  
-- Expectation: No results  
SELECT *  
FROM bronze.crm_cust_info  
WHERE cst_firstname != TRIM(cst_firstname);  

SELECT *  
FROM bronze.crm_cust_info  
WHERE cst_lastname != TRIM(cst_lastname);  

-- Data standardization & consistency  
SELECT DISTINCT cst_gndr  
FROM bronze.crm_cust_info;  

SELECT DISTINCT cst_marital_status  
FROM bronze.crm_cust_info;  


-------------------------------------------------------------------------------
-- Checking 'bronze.crm_prd_info'
-------------------------------------------------------------------------------

-- Check for nulls or duplicates in primary key  
-- Expectation: No results  
SELECT  
    prd_id,  
    COUNT(*)  
FROM bronze.crm_prd_info  
GROUP BY prd_id  
HAVING COUNT(*) > 1 OR prd_id IS NULL;  

-- Check for unwanted spaces  
-- Expectation: No results  
SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_key != TRIM(prd_key);  

SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_nm != TRIM(prd_nm);  

-- Check for nulls or negative numbers  
-- Expectation: No results  
SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_cost < 0 OR prd_cost IS NULL;  

-- Data standardization & consistency  
SELECT DISTINCT prd_line  
FROM bronze.crm_prd_info;  

-- Check for invalid date orders  
SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_start_dt > prd_end_dt;  


-------------------------------------------------------------------------------
-- Checking 'bronze.crm_sales_details'
-------------------------------------------------------------------------------

-- Check for keys to merge  
-- Expectation: No results  
SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);  

SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);  

-- Check for invalid dates  
-- Expectation: No results  
SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_order_dt <= 0  
  OR LEN(sls_order_dt) != 8  
  OR sls_order_dt > 20250101  
  OR sls_order_dt < 20000101;  

SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_ship_dt <= 0  
  OR LEN(sls_ship_dt) != 8  
  OR sls_ship_dt > 20250101  
  OR sls_ship_dt < 20000101  
  OR sls_ship_dt < sls_order_dt;  

SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_due_dt <= 0  
  OR LEN(sls_due_dt) != 8  
  OR sls_due_dt > 20250101  
  OR sls_due_dt < 20000101  
  OR sls_due_dt < sls_order_dt  
  OR sls_due_dt < sls_ship_dt;  

-- Check for nulls, negative numbers, or business logic errors  
-- Expectation: No results  
SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_quantity <= 0 OR sls_quantity IS NULL;  

SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_price <= 0 OR sls_price IS NULL;  

SELECT *  
FROM bronze.crm_sales_details  
WHERE sls_sales <= 0  
  OR sls_sales IS NULL  
  OR sls_sales != (sls_quantity * sls_price);  


-------------------------------------------------------------------------------
-- Checking 'bronze.erp_cust_az12'
-------------------------------------------------------------------------------

-- Check for invalid keys to merge  
-- Expectation: No results  
SELECT *  
FROM bronze.erp_cust_az12  
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);  

-- Check for invalid birth date  
-- Expectation: No results  
SELECT *  
FROM bronze.erp_cust_az12  
WHERE bdate > GETDATE() OR bdate < '1924-01-01';  

-- Check for data standardization & consistency  
SELECT DISTINCT gen  
FROM bronze.erp_cust_az12;  


-------------------------------------------------------------------------------
-- Checking 'bronze.erp_loc_a101'
-------------------------------------------------------------------------------

-- Check for invalid keys to merge  
-- Expectation: No results  
SELECT *  
FROM bronze.erp_loc_a101  
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);  

-- Check for data standardization & consistency  
SELECT DISTINCT cntry  
FROM bronze.erp_loc_a101;  


-------------------------------------------------------------------------------
-- Checking 'bronze.erp_px_cat_g1v2'
-------------------------------------------------------------------------------

-- Check for invalid keys to merge  
SELECT *  
FROM bronze.erp_px_cat_g1v2  
WHERE id NOT IN (SELECT prd_cat_id FROM silver.crm_prd_info);  

-- Check for unwanted spaces  
SELECT *  
FROM bronze.erp_px_cat_g1v2  
WHERE cat != TRIM(cat)  
   OR subcat != TRIM(subcat)  
   OR maintenance != TRIM(maintenance);  

-- Check for data standardization & consistency  
SELECT DISTINCT cat  
FROM bronze.erp_px_cat_g1v2;  

SELECT DISTINCT subcat  
FROM bronze.erp_px_cat_g1v2;  

SELECT DISTINCT maintenance  
FROM bronze.erp_px_cat_g1v2;

-- ============================================================================= 
-- Silver Layer
-- =============================================================================

-------------------------------------------------------------------------------
-- Checking 'silver.crm_cust_info'
-------------------------------------------------------------------------------
-- Check For Nulls Or Duplicates In Primary Key  
-- Expectation: No Results  
SELECT  
    cst_id,  
    COUNT(*)  
FROM silver.crm_cust_info  
GROUP BY cst_id  
HAVING COUNT(*) > 1 OR cst_id IS NULL;  

-- Check For Unwanted Spaces  
-- Expectation: No Results  
SELECT *  
FROM silver.crm_cust_info  
WHERE cst_firstname != TRIM(cst_firstname);  

SELECT *  
FROM silver.crm_cust_info  
WHERE cst_lastname != TRIM(cst_lastname);  

-- Data Standardization And Consistency  
SELECT DISTINCT cst_gndr  
FROM silver.crm_cust_info;  

SELECT DISTINCT cst_marital_status  
FROM silver.crm_cust_info;  

-------------------------------------------------------------------------------
-- Checking 'silver.crm_prd_info'
-------------------------------------------------------------------------------
-- Check For Nulls Or Duplicates In Primary Key  
-- Expectation: No Results  
SELECT  
    prd_id,  
    COUNT(*)  
FROM silver.crm_prd_info  
GROUP BY prd_id  
HAVING COUNT(*) > 1 OR prd_id IS NULL;  

-- Check For Unwanted Spaces  
-- Expectation: No Results  
SELECT *  
FROM silver.crm_prd_info  
WHERE prd_key != TRIM(prd_key);  

SELECT *  
FROM silver.crm_prd_info  
WHERE prd_nm != TRIM(prd_nm);  

-- Check For Nulls Or Negative Numbers  
-- Expectation: No Results  
SELECT *  
FROM silver.crm_prd_info  
WHERE prd_cost < 0 OR prd_cost IS NULL;  

-- Data Standardization And Consistency  
SELECT DISTINCT prd_line  
FROM silver.crm_prd_info;  

-- Check For Invalid Date Orders  
SELECT *  
FROM silver.crm_prd_info  
WHERE prd_start_dt > prd_end_dt;  

-------------------------------------------------------------------------------
-- Checking 'silver.crm_sales_details'
-------------------------------------------------------------------------------
-- Check For Keys To Merge  
-- Expectation: No Results  
SELECT *  
FROM silver.crm_sales_details  
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);  

SELECT *  
FROM silver.crm_sales_details  
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);  

-- Check For Invalid Dates  
-- Expectation: No Results  
SELECT *  
FROM silver.crm_sales_details  
WHERE sls_ship_dt < sls_order_dt;  

SELECT *  
FROM silver.crm_sales_details  
WHERE sls_due_dt < sls_order_dt  
   OR sls_due_dt < sls_ship_dt;  

-- Check For Nulls Or Negative Numbers Or Business Logic Errors  
-- Expectation: No Results  
SELECT *  
FROM silver.crm_sales_details  
WHERE sls_quantity <= 0 OR sls_quantity IS NULL;  

SELECT *  
FROM silver.crm_sales_details  
WHERE sls_price <= 0 OR sls_price IS NULL;  

SELECT *  
FROM silver.crm_sales_details  
WHERE sls_sales <= 0  
   OR sls_sales IS NULL  
   OR sls_sales != (sls_quantity * sls_price);  

-------------------------------------------------------------------------------
-- Checking 'silver.erp_cust_az12'
-------------------------------------------------------------------------------
-- Check For Invalid Keys To Merge  
-- Expectation: No Results  
SELECT *  
FROM silver.erp_cust_az12  
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);  

-- Check For Invalid Birth Date  
-- Expectation: No Results  
SELECT *  
FROM silver.erp_cust_az12  
WHERE bdate > GETDATE() OR bdate < '1924-01-01';  

-- Check For Data Standardization And Consistency  
SELECT DISTINCT gen  
FROM silver.erp_cust_az12;  

-------------------------------------------------------------------------------
-- Checking 'silver.erp_loc_a101'
-------------------------------------------------------------------------------
-- Check For Invalid Keys To Merge  
-- Expectation: No Results  
SELECT *  
FROM silver.erp_loc_a101  
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);  

-- Check For Data Standardization And Consistency  
SELECT DISTINCT cntry  
FROM silver.erp_loc_a101  
ORDER BY cntry;  

-------------------------------------------------------------------------------
-- Checking 'silver.erp_px_cat_g1v2'
-------------------------------------------------------------------------------
-- Check For Invalid Keys To Merge  
SELECT *  
FROM silver.erp_px_cat_g1v2  
WHERE id NOT IN (SELECT prd_cat_id FROM silver.crm_prd_info);  

-- Check For Unwanted Spaces  
SELECT *  
FROM silver.erp_px_cat_g1v2  
WHERE cat != TRIM(cat)  
   OR subcat != TRIM(subcat)  
   OR maintenance != TRIM(maintenance);  

-- Check For Data Standardization And Consistency  
SELECT DISTINCT cat  
FROM silver.erp_px_cat_g1v2;  

SELECT DISTINCT subcat  
FROM silver.erp_px_cat_g1v2;  

SELECT DISTINCT maintenance  
FROM silver.erp_px_cat_g1v2;  

-- ============================================================================= 
-- Gold Layer
-- =============================================================================

-------------------------------------------------------------------------------
-- Checking 'gold.dim_customers'
-------------------------------------------------------------------------------
-- Check For Duplicates In Primary Key  
-- Expectation: No Results  
SELECT  
    customer_id,  
    COUNT(*)  
FROM gold.dim_customers  
GROUP BY customer_id  
HAVING COUNT(*) > 1 OR customer_id IS NULL;  

-- Check For Data Standardization And Consistency  
SELECT DISTINCT gender  
FROM gold.dim_customers;  

-------------------------------------------------------------------------------
-- Checking 'gold.dim_products'
-------------------------------------------------------------------------------
-- Check For Duplicates In Primary Key  
-- Expectation: No Results  
SELECT  
    product_id,  
    COUNT(*)  
FROM gold.dim_products  
GROUP BY product_id  
HAVING COUNT(*) > 1 OR product_id IS NULL;  

-------------------------------------------------------------------------------
-- Checking 'gold.fact_sales'
-------------------------------------------------------------------------------
-- Check For Foreign Key Integrity (Dimensions)  
-- Expectation: No Results  
SELECT  
    *  
FROM gold.fact_sales fs  
LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key  
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key  
WHERE dc.customer_key IS NULL OR dp.product_key IS NULL;  
