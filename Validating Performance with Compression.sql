/*
DEMO 003: COMPRESSION?
@Database: sqlsat_prague

*/
USE sqlsat_prague
GO
SET STATISTICS IO ON
SET STATISTICS TIME ON

DROP INDEX IF EXISTS ix_Customer_PersonID ON dbo.Customer_pagecomp
DROP INDEX IF EXISTS ix_Person_FirstName ON dbo.Person_pagecomp
DROP INDEX IF EXISTS ix_SalesOrderHeader_CustomerID ON dbo.SalesOrderHeader_pagecomp
DROP INDEX IF EXISTS ix_Person_FirstName ON dbo.Person
DROP INDEX IF EXISTS ix_Person_LastName ON dbo.Person




DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT

SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader_pagecomp AS soh
JOIN dbo.Customer_pagecomp AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person_pagecomp AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'


SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader AS soh
JOIN dbo.Customer AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'







-- Some Tips!
-- Avoid at most HASH JOINS
   -- Something is wrong here.. Usually non sorted outputs. Non indexed table. Big result set

-- You can live with MERGE JOINS
   -- Merges are good. When you see then, usually means that you have columns indexes and your plan is getting better

-- Always pursue a NESTED LOOP
   -- Perform joins against small data sets.
























-- Step 1: Let's start some indexing!
-- Dot not forget. Every new index has to be compacted when you create them

CREATE NONCLUSTERED INDEX ix_SalesOrderHeader_CustomerID ON dbo.SalesOrderHeader_pagecomp(CustomerID) WITH(MAXDOP=2,DATA_COMPRESSION=PAGE)



SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader_pagecomp AS soh
JOIN dbo.Customer_pagecomp AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person_pagecomp AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'


























-- Did the plan improve? Could we improve even more?












CREATE NONCLUSTERED INDEX ix_Customer_PersonID ON dbo.Customer_pagecomp(PersonID) WITH(MAXDOP=1,DATA_COMPRESSION=PAGE)

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT

SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader_pagecomp AS soh
JOIN dbo.Customer_pagecomp AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person_pagecomp AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'



-- How about now??



































-- Can we improve it even more?



CREATE NONCLUSTERED INDEX [ix_Person_FirstName_LastName] ON [dbo].[Person_pagecomp] ([FirstName],[LastName]) WITH(MAXDOP=1,DATA_COMPRESSION=PAGE)
GO

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT


SELECT soh.PurchaseOrderNumber,soh.OrderDate,soh.SubTotal,soh.TaxAmt,soh.Freight,soh.TotalDue FROM dbo.SalesOrderHeader_pagecomp AS soh
JOIN dbo.Customer_pagecomp AS cu
ON cu.CustomerID = soh.CustomerID
JOIN dbo.Person_pagecomp AS p
ON p.BusinessEntityID = cu.PersonID
WHERE p.FirstName = 'Bryon' AND p.LastName = 'Ewing'

GO
