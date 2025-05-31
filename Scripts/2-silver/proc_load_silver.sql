/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to populate  
    the 'Silver' schema tables from Bronze tables.

Actions Performed:
    - Truncates 'Silver' tables  
    - Inserts data from Bronze tables into 'Silver' tables

Parameters:
    - None  
    This stored procedure doesn't accept any parameters or return any values.

Usage Example:
    - EXEC Silver.Load_Silver

===============================================================================
*/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE Silver.Load_Silver
AS
BEGIN
    DECLARE 
        @start_time DATETIME, 
        @end_time DATETIME, 
        @batch_start_time DATETIME, 
        @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '============================================================================';
        PRINT 'Loading Silver Layer';
        PRINT '============================================================================';

        PRINT '---------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------------------------';

        -- Load the 'Crm_Cust_Info' table
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.Crm_Cust_Info';
        TRUNCATE TABLE Silver.Crm_Cust_Info;

        PRINT '>> Inserting Data Into: Silver.Crm_Cust_Info';
        INSERT INTO Silver.Crm_Cust_Info 
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'N/A'
            END AS cst_marital_status,  -- Normalize marital status value to readable format
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'N/A'
            END AS cst_gndr,  -- Normalize gender value to readable format
            cst_create_date
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date) AS flag_last
            FROM Bronze.Crm_Cust_Info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;  -- Select the most recent record per customer

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'Prd_Info' table
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.Crm_Prd_Info';
        TRUNCATE TABLE Silver.Crm_Prd_Info;

        PRINT '>> Inserting Data Into: Silver.Crm_Prd_Info';
        INSERT INTO Silver.Crm_Prd_Info
        (
            prd_id,
            prd_key,
            prd_cat_id,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  -- Extract product key
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,  -- Extract category ID
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,  -- Map product line codes to descriptive values
            prd_start_dt,
            DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS prd_end_dt  -- Calculate end date as one day before the next start date
        FROM Bronze.Crm_Prd_Info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'Sales_Details' table
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.Crm_Sales_Details';
        TRUNCATE TABLE Silver.Crm_Sales_Details;

        PRINT '>> Inserting Data Into: Silver.Crm_Sales_Details';
        INSERT INTO Silver.Crm_Sales_Details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_price,
            sls_quantity,
            sls_sales
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE 
                WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price  -- Derive price if original value is invalid
            END AS sls_price,
            sls_quantity,
            CASE 
                WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales  -- Recalculate sales if original value is missing or incorrect
            END AS sls_sales
        FROM Bronze.Crm_Sales_Details;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        PRINT '---------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------------------';

        -- Load the 'Cust_Az12' table
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.Erp_Cust_Az12';
        TRUNCATE TABLE Silver.Erp_Cust_Az12;

        PRINT '>> Inserting Data Into: Silver.Erp_Cust_Az12';
        INSERT INTO Silver.Erp_Cust_Az12
        (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid 
            END AS cid,
            CASE
                WHEN bdate > GETDATE() OR bdate < '1924-01-01' THEN NULL
                ELSE bdate
            END AS bdate,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'N/A'
            END AS gen
        FROM Bronze.Erp_Cust_Az12;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'Loc_A101' table
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.Erp_Loc_A101';
        TRUNCATE TABLE Silver.Erp_Loc_A101;

        PRINT '>> Inserting Data Into: Silver.Erp_Loc_A101';
        INSERT INTO Silver.Erp_Loc_A101
        (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,
            CASE 
                WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'N/A'
                ELSE TRIM(cntry)
            END AS cntry  -- Normalize and handle missing or blank country code
        FROM Bronze.Erp_Loc_A101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'Px_Cat_G1v2' table
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.Erp_Px_Cat_G1v2';
        TRUNCATE TABLE Silver.Erp_Px_Cat_G1v2;

        PRINT '>> Inserting Data Into: Silver.Erp_Px_Cat_G1v2';
        INSERT INTO Silver.Erp_Px_Cat_G1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM Bronze.Erp_Px_Cat_G1v2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '============================================================================';
        PRINT 'Loading Silver Layer Is Completed';
        PRINT '    - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '============================================================================';
    END TRY
    BEGIN CATCH
        PRINT '============================================================================';
        PRINT 'Error Occurred During Loading Silver Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '============================================================================';
    END CATCH
END;
