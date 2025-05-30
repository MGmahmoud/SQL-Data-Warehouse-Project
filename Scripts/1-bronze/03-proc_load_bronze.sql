/*
===============================================================================
Script Purpose:
    This Script Creates Stored Procedure To Load The Data Into The 'Bronze Layer' Tables, Truncating Existing Tables. 
    Run Exec Command Only In This Script To Load The Data Into 'Bronze Layer' Tables
=============================================================================== 
Warning:
    Running This Script Will Truncate The Entire 'Bronze Schema Tables' If They Exist.
    All Data In The 'Bronze Layer' Tables Will Be Permanently Deleted And Replaced With New One.
    Proceed With Caution And Ensure You Have Proper Backups Before Running This Script.
===============================================================================
*/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
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

        -- Load The 'crm_cust_info' Table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'crm_prd_info' Table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'crm_sales_details' Table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        PRINT '---------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------------------';

        -- Load The 'erp_cust_az12' Table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'erp_loc_a101' Table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load The 'erp_px_cat_g1v2' Table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        SET @batch_end_time = GETDATE();
        PRINT '============================================================================';
        PRINT 'Loading Bronze Layer Is Completed';
        PRINT '        - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '============================================================================';
    END TRY

    BEGIN CATCH
        PRINT '============================================================================';
        PRINT 'Error Occurred During Loading Bronze Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '============================================================================';
    END CATCH
END
