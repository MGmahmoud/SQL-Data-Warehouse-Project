/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates stored procedure to load the data into the 'bronze layer' Tables, Truncating existing tables. 
	Run Exec Command only in this script to load the Data into 'bronze layer' Tables
===============================================================================	
Warning:
	Running this script will Truncate the entire 'Bronze Schema Tables' if they exist.
	All Data in the 'bronze layer' tables will be permanently deleted and replaced with new one.
	Proceed with caution and ensure you have proper backups before running this script.
===============================================================================
*/


USE DataWarehouse;
GO

EXEC bronze.load_bronze;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '============================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '============================================================================';

			PRINT '---------------------------------------------------------------------------';
			PRINT 'Loading CRM Tables';
			PRINT '---------------------------------------------------------------------------';
				
				-- Load the 'crm_cust_info' Table
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

				-- Load the 'prd_info' Table
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

				-- Load the 'sales_details' Table
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

				-- Load the 'CUST_AZ12' Table
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
				
				-- Load the 'LOC_A101' Table
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

				-- Load the 'PX_CAT_G1V2' Table
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
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '		- Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '============================================================================';
	END TRY

	BEGIN CATCH
		PRINT '============================================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '============================================================================';
	END CATCH

END

