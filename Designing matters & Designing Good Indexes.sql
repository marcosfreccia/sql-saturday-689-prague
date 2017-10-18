/*

DEMO: Designing matters & Designing Good Indexes
DB: WideWorldImporters

*/

USE WideWorldImporters
GO

SET STATISTICS IO ON

/*

Just create an empty table

*/
SELECT TOP(0) * INTO SalesOrders001 FROM Sales.Orders

GO

/*

Part 01: Avoiding High Updated Columns

*/

CREATE CLUSTERED INDEX CLI_SalesOrders001_OrderDate ON dbo.SalesOrders001(OrderDate)
GO


-- Generate some data using SQL Data Generator

SELECT * FROM dbo.SalesOrders001

GO

/*

Checking the fragmentation

*/
DECLARE @Object_id INT = (SELECT object_id FROM sys.tables WHERE name = 'SalesOrders001' )


SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'SAMPLED')
WHERE object_id = @Object_id

GO

ALTER INDEX CLI_SalesOrders001_OrderDate ON dbo.SalesOrders001 REBUILD
GO

/*

Checking the fragmentation

*/

DECLARE @Object_id INT = (SELECT object_id FROM sys.tables WHERE name = 'SalesOrders001' )


SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'SAMPLED')
WHERE object_id = @Object_id





/*

Creating our second empty table

*/
CREATE TABLE [dbo].[SalesOrders002](
	[OrderID] [INT] IDENTITY NOT NULL,
	[CustomerID] [INT] NOT NULL,
	[SalespersonPersonID] [INT] NOT NULL,
	[PickedByPersonID] [INT] NULL,
	[ContactPersonID] [INT] NOT NULL,
	[BackorderOrderID] [INT] NULL,
	[OrderDate] [DATE] NOT NULL,
	[ExpectedDeliveryDate] [DATE] NOT NULL,
	[CustomerPurchaseOrderNumber] [NVARCHAR](20) NULL,
	[IsUndersupplyBackordered] [BIT] NOT NULL,
	[Comments] [NVARCHAR](MAX) NULL,
	[DeliveryInstructions] [NVARCHAR](MAX) NULL,
	[InternalComments] [NVARCHAR](MAX) NULL,
	[PickingCompletedWhen] [DATETIME2](7) NULL,
	[LastEditedBy] [INT] NOT NULL,
	[LastEditedWhen] [DATETIME2](7) NOT NULL
) ON [USERDATA] TEXTIMAGE_ON [USERDATA]
GO

/*

Part 01: Avoiding High Updated Columns

*/

CREATE CLUSTERED INDEX CLI_SalesOrders002_OrderID ON dbo.SalesOrders002(OrderID)
GO



-- Generate some data using SQL Data Generator

SELECT * FROM dbo.SalesOrders002

GO

/*

Checking the fragmentation

*/
DECLARE @Object_id INT = (SELECT object_id FROM sys.tables WHERE name = 'SalesOrders002' )


SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'SAMPLED')
WHERE object_id = @Object_id

GO

ALTER INDEX CLI_SalesOrders002_OrderID ON dbo.SalesOrders002 REBUILD
GO

/*

Checking the fragmentation

*/
DECLARE @Object_id INT = (SELECT object_id FROM sys.tables WHERE name = 'SalesOrders002' )


SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'SAMPLED')
WHERE object_id = @Object_id


--EXEC dbo.sp_SQLskills_helpindex @objname = N'dbo.SalesOrders002' -- nvarchar(776)

SELECT * FROM dbo.SalesOrders001
GO
SELECT * FROM dbo.SalesOrders002

/*

Cleaning up

*/

DROP TABLE IF EXISTS dbo.SalesOrders001
DROP TABLE IF EXISTS dbo.SalesOrders002








/*

Creating good NonClustered Indexes

*/

/*

Selectivity

*/


SELECT COUNT(DISTINCT CustomerName) AS DistinctColValues,
       COUNT(CustomerName) AS NumberOfRows,
       (CAST(COUNT(DISTINCT CustomerName) AS DECIMAL) / CAST(COUNT(CustomerName) AS DECIMAL)) AS Selectivity
FROM Sales.Customers;


SELECT COUNT(DISTINCT DeliveryMethodID) AS DistinctColValues,
       COUNT(DeliveryMethodID) AS NumberOfRows,
       (CAST(COUNT(DISTINCT DeliveryMethodID) AS DECIMAL) / CAST(COUNT(DeliveryMethodID) AS DECIMAL)) AS Selectivity
FROM Sales.Customers;



/*

Creating both NONCLUSTERED INDEXES

*/
CREATE NONCLUSTERED INDEX IX_SalesCustomers_CustomerName ON Sales.Customers(CustomerName)
GO
CREATE NONCLUSTERED INDEX IX_SalesCustomers_DeliveryMethodID ON Sales.Customers(DeliveryMethodID) 






/*

Customer Orders

Tip: Enable Statistics IO and SQL Plan

*/


SET STATISTICS IO ON

DROP INDEX IF EXISTS [FK_Sales_Customers_AlternateContactPersonID] ON [Sales].[Customers]
DROP INDEX IF EXISTS FK_Sales_Customers_BuyingGroupID ON Sales.Customers
DROP INDEX IF EXISTS FK_Sales_Customers_CustomerCategoryID ON Sales.Customers
DROP INDEX IF EXISTS FK_Sales_Customers_DeliveryCityID ON Sales.Customers
DROP INDEX IF EXISTS FK_Sales_Customers_DeliveryMethodID ON Sales.Customers
DROP INDEX IF EXISTS FK_Sales_Customers_PostalCityID ON Sales.Customers
DROP INDEX IF EXISTS FK_Sales_Customers_PrimaryContactPersonID ON Sales.Customers
DROP INDEX IF EXISTS IX_Sales_Customers_Perf_20160301_06 ON Sales.Customers
ALTER TABLE [Sales].[Customers] DROP CONSTRAINT [UQ_Sales_Customers_CustomerName]
DROP INDEX IF EXISTS UQ_Sales_Customers_CustomerName ON Sales.Customers




SELECT ct.InvoiceID,ct.PaymentMethodID,ct.AmountExcludingTax,ct.TransactionAmount FROM Sales.Customers AS c
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = c.CustomerID
WHERE c.CustomerName = 'Ratan Poddar'


/*

In case if we didn't have any indexes

*/
DROP INDEX IF EXISTS IX_SalesCustomers_CustomerName ON Sales.Customers



SELECT ct.InvoiceID,ct.PaymentMethodID,ct.AmountExcludingTax,ct.TransactionAmount FROM Sales.Customers AS c
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = c.CustomerID
WHERE c.CustomerName = 'Ratan Poddar'





/*

Let's test the index created on DeliveryMethodID

*/

SELECT ct.InvoiceID,ct.PaymentMethodID,ct.AmountExcludingTax,ct.TransactionAmount FROM Sales.Customers AS c
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = c.CustomerID
WHERE c.DeliveryMethodID = 3



SELECT ct.InvoiceID,ct.PaymentMethodID,ct.AmountExcludingTax,ct.TransactionAmount 
FROM Sales.Customers AS c WITH(INDEX(IX_SalesCustomers_DeliveryMethodID))
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = c.CustomerID
WHERE c.DeliveryMethodID = 3






DROP INDEX IF EXISTS IX_SalesCustomers_DeliveryMethodID ON Sales.Customers


/*

Restore Database

*/

USE [master]
RESTORE DATABASE [WideWorldImporters] FROM  DISK = N'I:\MSSQL\Backup\WideWorldImporters_20171016.bak' WITH  FILE = 1,REPLACE,  NOUNLOAD,  STATS = 5
