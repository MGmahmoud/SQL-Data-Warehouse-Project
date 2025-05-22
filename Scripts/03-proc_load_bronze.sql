EXEC bronze.load_bronze;

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

				SET @start_time = GETDATE();
				PRINT '>> Truncating Table: bronze.crm_cust_info';
				TRUNCATE TABLE bronze.crm_cust_info;
				PRINT '>> Inserting Data Into: bronze.crm_cust_info';
				BULK INSERT bronze.crm_cust_info
				FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\source_crm\cust_info.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '>> ------------------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating Table: bronze.crm_prd_info';
				TRUNCATE TABLE bronze.crm_prd_info;
				PRINT '>> Inserting Data Into: bronze.crm_prd_info';
				BULK INSERT bronze.crm_prd_info
				FROM 'C:\Users\mahmo\Desktop\Data Warhouse SQL Project\source_crm\prd_info.csv'
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

		SET @batch_end_time = GETDATE();
		PRINT '============================================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '		-Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
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

