
USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Brazilian_ecom_DataWarehouse')
BEGIN
    ALTER DATABASE Brazilian_ecom_DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Brazilian_ecom_DataWarehouse;
END;
GO

CREATE DATABASE Brazilian_ecom_DataWarehouse;
GO

USE Brazilian_ecom_DataWarehouse;
GO


CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO