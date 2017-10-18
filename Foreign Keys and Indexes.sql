/*
DEMO: Foreign Keys and Indexes
DB: WideWorldImporters

*/

USE WideWorldImporters
GO

SET STATISTICS IO ON

DROP INDEX IF EXISTS [FK_Sales_OrderLines_OrderID] ON [Sales].[OrderLines]
GO
ALTER TABLE [Sales].[OrderLines] DROP CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
GO

SELECT o.OrderID,
       ol.OrderLineID
FROM Sales.Orders o
    JOIN Sales.OrderLines AS ol
        ON ol.OrderID = o.OrderID;
































CREATE NONCLUSTERED INDEX [FK_Sales_OrderLines_OrderID] ON [Sales].[OrderLines] ([OrderID] ASC)



ALTER TABLE [Sales].[OrderLines]  WITH CHECK ADD  CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[OrderLines] CHECK CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
GO



SELECT o.OrderID,
       ol.OrderLineID
FROM Sales.Orders o
    JOIN Sales.OrderLines AS ol
        ON ol.OrderID = o.OrderID;














/*

What about if we change the source of column?

*/



SELECT ol.OrderID,
       ol.OrderLineID
FROM Sales.Orders o
    JOIN Sales.OrderLines AS ol
        ON ol.OrderID = o.OrderID;






/*

Do we really have improvements with constraints?

*/

ALTER TABLE [Sales].[OrderLines] NOCHECK CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
GO



SELECT ol.OrderID,
       ol.OrderLineID
FROM Sales.Orders o
    JOIN Sales.OrderLines AS ol
        ON ol.OrderID = o.OrderID
		WHERE o.OrderID = 850



