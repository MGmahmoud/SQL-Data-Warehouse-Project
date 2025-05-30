/*
===============================================================================
Bronze Layer
===============================================================================
*/

---------------- crm_cust_info ----------------

-- Check For Nulls Or Duplicates In Primary Key  
-- Expectation: No Results  
SELECT  
    cst_id,  
    COUNT(*)  
FROM bronze.crm_cust_info  
GROUP BY cst_id  
HAVING COUNT(*) > 1 OR cst_id IS NULL;  

-- Check For Unwanted Spaces  
-- Expectation: No Results  
SELECT *  
FROM bronze.crm_cust_info  
WHERE cst_firstname != TRIM(cst_firstname);  

SELECT *  
FROM bronze.crm_cust_info  
WHERE cst_lastname != TRIM(cst_lastname);  

-- Data Standardization And Consistency  
SELECT DISTINCT cst_gndr  
FROM bronze.crm_cust_info;  

SELECT DISTINCT cst_marital_status  
FROM bronze.crm_cust_info;  

---------------- crm_prd_info ----------------

-- Check For Nulls Or Duplicates In Primary Key  
-- Expectation: No Results  
SELECT  
    prd_id,  
    COUNT(*)  
FROM bronze.crm_prd_info  
GROUP BY prd_id  
HAVING COUNT(*) > 1 OR prd_id IS NULL;  

-- Check For Unwanted Spaces  
-- Expectation: No Results  
SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_key != TRIM(prd_key);  

SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_nm != TRIM(prd_nm);  

-- Check For Nulls Or Negative Numbers  
-- Expectation: No Results  
SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_cost < 0 OR prd_cost IS NULL;  

-- Data Standardization And Consistency  
SELECT DISTINCT prd_line  
FROM bronze.crm_prd_info;  

-- Check For Invalid Date Orders  
SELECT *  
FROM bronze.crm_prd_info  
WHERE prd_start_dt > prd_end_dt;  

---------------- crm_sales_details ----------------


















/*
===============================================================================
Silver Layer
===============================================================================
*/

---------------- crm_cust_info ----------------

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


---------------- crm_prd_info ----------------

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