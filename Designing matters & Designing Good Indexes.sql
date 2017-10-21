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

Selectivity. Think about that before!

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
DROP INDEX IF EXISTS IX_SalesCustomers_CustomerName ON Sales.Customers
GO
DROP INDEX IF EXISTS IX_SalesCustomers_DeliveryMethodID ON Sales.Customers

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

Cleaning Up

*/

DROP TABLE IF EXISTS dbo.SalesOrders001
DROP TABLE IF EXISTS dbo.SalesOrders002


--USE [master]
--RESTORE DATABASE [WideWorldImporters] FROM  DISK = N'I:\MSSQL\Backup\WideWorldImporters_20171016.bak' WITH  FILE = 1,REPLACE,  NOUNLOAD,  STATS = 5





USE sqlsat_prague
GO
SET STATISTICS IO ON
SET STATISTICS TIME ON

DROP INDEX IF EXISTS ix_Customer_PersonID ON dbo.Customer
DROP INDEX IF EXISTS ix_Person_FirstName ON dbo.Person
DROP INDEX IF EXISTS ix_SalesOrderHeader_CustomerID ON dbo.SalesOrderHeader
DROP INDEX IF EXISTS ix_Person_FirstName ON dbo.Person
DROP INDEX IF EXISTS ix_Person_LastName ON dbo.Person




DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT


SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'







-- Some Tips!
-- Avoid at most HASH JOINS
   -- Something is wrong here.. Usually non sorted outputs. Non indexed table. Big result set, Statistics not up to date

-- You can live with MERGE JOINS
   -- Merges are good. When you see then, usually means that you have columns indexes and your plan is getting better

-- Always pursue a NESTED LOOP
   -- Perform joins against small data sets.










-- Can we improve it even more?



CREATE NONCLUSTERED INDEX [ix_Person_FirstName_LastName] ON [dbo].[Person] ([FirstName],[LastName]) WITH(MAXDOP=1,DATA_COMPRESSION=PAGE)
GO



SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'

GO






/*


What about this below query? Is the index created before still good?


*/

SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' --AND p.LastName = 'Ewing'

GO


/*

What about now?


*/

SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
--WHERE p.FirstName = 'Bryon' 
WHERE p.LastName = 'Ewing'

GO



/*

Let me show you Index Intersection

*/

DROP INDEX [ix_Person_FirstName_LastName] ON [dbo].[Person]



GO

CREATE NONCLUSTERED INDEX [ix_Person_FirstName] ON [dbo].[Person] ([FirstName]) WITH(MAXDOP=1)
GO


CREATE NONCLUSTERED INDEX [ix_Person_LastName] ON [dbo].[Person] ([LastName]) WITH(MAXDOP=1)
GO

SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' --AND p.LastName = 'Ewing'

GO


/*

What about now?


*/

SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
--WHERE p.FirstName = 'Bryon' 
WHERE p.LastName = 'Ewing'

GO