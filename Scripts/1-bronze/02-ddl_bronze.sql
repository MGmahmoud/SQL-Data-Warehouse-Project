/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This Script Creates Tables In The 'Bronze' Schema, Dropping Existing Tables 
    If They Already Exist.
    Run This Script To Re-Define The DDL Structure Of 'Bronze' Tables
===============================================================================
Warning:
    Running This Script Will Drop The Entire 'Bronze Schema Tables' If They Exist.
    All Tables In The Bronze Schema Will Be Permanently Deleted.
    Proceed With Caution And Ensure You Have Proper Backups Before Running This Script.
===============================================================================
*/

USE DataWarehouse;
GO

-- Create The 'Crm_Cust_Info' Table
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info 
(
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

-- Create The 'Prd_Info' Table
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info
(
    prd_id          INT,
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE
);
GO

-- Create The 'Sales_Details' Table
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num     NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    INT,
    sls_ship_dt     INT,
    sls_due_dt      INT,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT
);
GO

-- Create The 'Cust_AZ12' Table
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12
(
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50)
);
GO

-- Create The 'Loc_A101' Table
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101
(
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50)
);
GO

-- Create The 'Px_Cat_G1V2' Table
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50)
);
GO
