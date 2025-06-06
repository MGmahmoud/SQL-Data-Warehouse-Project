/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including table and column metadata.

Tables Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/


-- ============================================================================
-- Explore All Tables in the Database
-- ============================================================================
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM 
    INFORMATION_SCHEMA.TABLES;


-- ============================================================================
-- Explore Columns in the 'dim_customers' Table
-- ============================================================================
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'dim_customers';


-- ============================================================================
-- Explore Columns in the 'dim_products' Table
-- ============================================================================
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'dim_products';


-- ============================================================================
-- Explore Columns in the 'fact_sales' Table
-- ============================================================================
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH 
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'fact_sales';
