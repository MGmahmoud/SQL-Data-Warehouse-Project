/*
==============================================================
Create Database And Schemas
==============================================================
Script Purpose:
    This Script Creates A New Database Named 'DataWarehouse' After Checking If It Already Exists Or Not.
    If The Database Exists:
        It Is Dropped And Recreated.
    Additionally, The Script Sets Up Three Schemas Within The Database:
        1. 'Bronze'
        2. 'Silver'
        3. 'Gold'

Warning:
    Running This Script Will Drop The Entire 'DataWarehouse' Database If It Exists.
    All Data In The Database Will Be Permanently Deleted. Proceed With Caution
    And Ensure You Have Proper Backups Before Running This Script.
*/

USE master;
GO

-- Drop And Recreate The 'DataWarehouse' Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create The 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
