/*
===============================================================================
Script Purpose:
    This Script Creates Stored Procedure To Load The Data Into The 'Silver Layer' Tables, Truncating Existing Tables. 
    Run Exec Command Only In This Script To Load The Data Into 'Silver Layer' Tables
===============================================================================    
Warning:
    Running This Script Will Truncate The Entire 'Silver Schema Tables' If They Exist.
    All Data In The 'Silver Layer' Tables Will Be Permanently Deleted And Replaced With New One.
    Proceed With Caution And Ensure You Have Proper Backups Before Running This Script.
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
        PRINT 'Loading Bronze Layer';
        PRINT '============================================================================';

        PRINT '---------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------------------------';

        -- Load The 'Crm_Cust_Info' Table
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
                ELSE 'n/a'
            END AS cst_marital_status,  -- Normalize Marital Status Value To Readable Format
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END AS cst_gndr,  -- Normalize Gender Value To Readable Format
            cst_create_date
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date) AS flag_last
            FROM Bronze.Crm_Cust_Info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;  -- Select The Most Recent Record Per Customer

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'Prd_Info' Table
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
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  -- Extract Product Key
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,  -- Extract Category Id
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,  -- Map Product Line Codes To Descriptive Values
            prd_start_dt,
            DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS prd_end_dt  -- Calculate End Date As One Day Before The Next Start Date
        FROM Bronze.Crm_Prd_Info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'Sales_Details' Table
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
                ELSE sls_price  -- Drive Price If Original Value Is Invalid
            END AS sls_price,
            sls_quantity,
            CASE 
                WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales  -- Recalculate Sales If Original Value Is Missing Or Incorrect
            END AS sls_sales
        FROM Bronze.Crm_Sales_Details;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        PRINT '---------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------------------';

        -- Load The 'Cust_Az12' Table
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
                ELSE 'n/a'
            END AS gen
        FROM Bronze.Erp_Cust_Az12;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'Loc_A101' Table
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
                WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry  -- Normalize And Handle Missing Or Blank Country Code
        FROM Bronze.Erp_Loc_A101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'Px_Cat_G1v2' Table
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
