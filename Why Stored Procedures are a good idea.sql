/*

DEMO: Why stored procedures are good!
DB: WideWorldImporters

*/

USE WideWorldImporters
GO
SET STATISTICS IO ON

DBCC FREEPROCCACHE

SELECT c.CityName,SUM(ct.TransactionAmount) AS TransactionAmount
FROM Application.Cities AS c
JOIN Sales.Customers AS cu
ON cu.DeliveryCityID = c.CityID
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = cu.CustomerID
WHERE c.CityName = 'Rogersville'
AND ct.TransactionAmount > 0
GROUP BY c.CityName





SELECT c.CityName,SUM(ct.TransactionAmount) AS TransactionAmount
FROM Application.Cities AS c
JOIN Sales.Customers AS cu
ON cu.DeliveryCityID = c.CityID
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = cu.CustomerID
WHERE c.CityName = 'Lompoc'
AND ct.TransactionAmount > 0
GROUP BY c.CityName



/*

Let's check the Plan Cache
Open another session

*/

SELECT cp.usecounts,cp.size_in_bytes,cp.cacheobjtype,cp.objtype,txt.text,pl.query_plan FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS txt
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS pl
WHERE txt.dbid = DB_ID('WideWorldImporters')
OPTION(RECOMPILE)


GO






/*

Re-writting to a stored procedure

*/

CREATE PROCEDURE Sales.CitySales @CityName NVARCHAR(50)
AS
SELECT c.CityName,
       SUM(ct.TransactionAmount) AS TransactionAmount
FROM Application.Cities AS c
    JOIN Sales.Customers AS cu
        ON cu.DeliveryCityID = c.CityID
    JOIN Sales.CustomerTransactions AS ct
        ON ct.CustomerID = cu.CustomerID
WHERE c.CityName = @CityName
      AND ct.TransactionAmount > 0
GROUP BY c.CityName;


EXEC sales.CitySales @CityName = N'Rogersville' -- nvarchar(50)
GO
EXEC sales.CitySales @CityName = N'Lompoc' -- nvarchar(50)
GO


EXEC sp_SQLskills_helpindex @objname = N'Sales.CustomerTransactions' -- nvarchar(776)


CREATE INDEX ix_CustomerTransactions_TransactionAmount ON Sales.CustomerTransactions(TransactionAmount) INCLUDE(CustomerID)
GO
DROP INDEX IF EXISTS ix_CustomerTransactions_TransactionAmount ON Sales.CustomerTransactions
GO
CREATE INDEX ix_CustomerTransactions_TransactionAmount ON Sales.CustomerTransactions(TransactionAmount) INCLUDE(CustomerID) WHERE TransactionAmount > 0
GO


CREATE INDEX IX_City_CityName ON Application.Cities(CityName)


EXEC sales.CitySales @CityName = N'Rogersville' -- nvarchar(50)
GO
EXEC sales.CitySales @CityName = N'Lompoc' -- nvarchar(50)
GO


/*

Which query is performing better?

We can force the index and try it

*/


SELECT c.CityName,SUM(ct.TransactionAmount) AS TransactionAmount
FROM Application.Cities AS c
JOIN Sales.Customers AS cu
ON cu.DeliveryCityID = c.CityID
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = cu.CustomerID
WHERE c.CityName = 'Lompoc'
AND ct.TransactionAmount > 0
GROUP BY c.CityName



SELECT c.CityName,SUM(ct.TransactionAmount) AS TransactionAmount
FROM Application.Cities AS c WITH(INDEX(PK_Application_Cities)) 
JOIN Sales.Customers AS cu
ON cu.DeliveryCityID = c.CityID
JOIN Sales.CustomerTransactions AS ct
ON ct.CustomerID = cu.CustomerID
WHERE c.CityName = 'Lompoc'
AND ct.TransactionAmount > 0
GROUP BY c.CityName


/*

Cleaning up the database

*/
DROP INDEX IF EXISTS IX_City_CityName ON Application.Cities
GO
DROP INDEX IF EXISTS ix_CustomerTransactions_TransactionAmount ON Sales.CustomerTransactions
GO
DROP PROCEDURE IF EXISTS Sales.CitySales