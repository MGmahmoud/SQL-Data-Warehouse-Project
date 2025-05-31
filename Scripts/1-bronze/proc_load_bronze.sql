/*
===============================================================================
Stored Procedure: Load Bronze Layer (CSVs -> Bronze)
===============================================================================

Script Purpose:
    This stored procedure performs the EL (Extract, Load) process to populate  
    the 'Bronze' schema tables from CSV files.

Actions Performed:
    - Truncates 'Bronze' tables  
    - Inserts data from CSV files into 'Bronze' tables

Parameters:
    - None  
    This stored procedure doesn't accept any parameters or return any values.

Usage Example:
    - EXEC bronze.load_bronze

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

        -- Load the 'crm_cust_info' table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\mahmo\Desktop\Data Warehouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'crm_prd_info' table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\mahmo\Desktop\Data Warehouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'crm_sales_details' table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\mahmo\Desktop\Data Warehouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        PRINT '---------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------------------';

        -- Load the 'erp_cust_az12' table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\mahmo\Desktop\Data Warehouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'erp_loc_a101' table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\mahmo\Desktop\Data Warehouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- Load the 'erp_px_cat_g1v2' table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\mahmo\Desktop\Data Warehouse SQL Project\SQL-Data-Warehouse-Project\Datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------------------------------------';

        SET @batch_end_time = GETDATE();
        PRINT '============================================================================';
        PRINT 'Loading Bronze Layer Is Completed';
        PRINT '        - Total load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '============================================================================';

    END TRY

    BEGIN CATCH
        PRINT '============================================================================';
        PRINT 'Error occurred during loading Bronze Layer';
        PRINT 'Error message: ' + ERROR_MESSAGE();
        PRINT 'Error number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error state  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '============================================================================';
    END CATCH
END
