/*
DEMO 004: Table Variable  or Temporary Tables?
@Database: eadl365db & sqlsat_prague

*/

USE eadl365db
GO


SET STATISTICS IO ON


SELECT tr.nome AS TrainingName,mo.nome AS Module,al.nome AS ClassName FROM etraining.Treinamento AS tr
JOIN etraining.Modulo AS mo
ON mo.codTreinamento = tr.codigo
JOIN etraining.Aula AS al
ON al.codModulo = mo.codigo AND al.codTreinamento = mo.codTreinamento












DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT


-- Small DataSet
DECLARE @Traning TABLE(TrainingID int,TrainingName VARCHAR(100),TrainingDescription VARCHAR(MAX),Price MONEY,CreatedAt DATETIME)

INSERT INTO @Traning
(
	TrainingID,
    TrainingName,
	TrainingDescription,
    Price,
    CreatedAt
)
SELECT tr.codigo,tr.nome,tr.descricao,tr.valor,tr.criadoEm FROM etraining.Treinamento AS tr



SELECT tr.TrainingName,pgt.dataEmissao AS OrderDate,pgt.valorOriginal AS OriginalPrice,pgt.valorDesconto AS Discount FROM @Traning AS tr
JOIN etraining.PagamentoTreinamento AS pt
ON tr.TrainingID = pt.codTreinamento
JOIN etraining.Pagamento AS pgt
ON pgt.id = pt.idPagamento
ORDER BY tr.TrainingName,OrderDate







USE sqlsat_prague_design
GO




DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT


DECLARE @PriceAdjust TABLE(ProductID INT,ProductName VARCHAR(100),ProductNumber NVARCHAR(25),CurrentPrice MONEY,NewPrice MONEY,ChangedDate DATETIME)

INSERT INTO @PriceAdjust
(
    ProductID,
	ProductName,
    ProductNumber,
    CurrentPrice,
    NewPrice,
    ChangedDate
)
SELECT ProductID,Name,ProductNumber,StandardCost AS CurrentPrice, StandardCost + (StandardCost * 0.1) AS NewPrice,GETDATE() AS ChangedDate FROM dbo.Product



SELECT pa.ProductName,p.Color,p.StandardCost,pa.NewPrice FROM @PriceAdjust AS PA
JOIN dbo.Product AS p
ON p.ProductID = pa.ProductID


-- Can you see the problem???























-- Open a new session!

SET STATISTICS IO ON


DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT


create TABLE #PriceAdjust(ProductID INT,ProductName VARCHAR(100),ProductNumber NVARCHAR(25),CurrentPrice MONEY,NewPrice MONEY,ChangedDate DATETIME)

INSERT INTO #PriceAdjust
(
    ProductID,
	ProductName,
    ProductNumber,
    CurrentPrice,
    NewPrice,
    ChangedDate
)
SELECT ProductID,Name,ProductNumber,StandardCost AS CurrentPrice, StandardCost + (StandardCost * 0.1) AS NewPrice,GETDATE() AS ChangedDate FROM dbo.Product


SELECT pa.ProductName,p.Color,p.StandardCost,pa.NewPrice FROM #PriceAdjust AS PA
JOIN dbo.Product AS p
ON p.ProductID = pa.ProductID




/*

Let's create a physical table to test it 

*/



SET STATISTICS IO ON


DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
CHECKPOINT


create TABLE PriceAdjust(ProductID INT,ProductName VARCHAR(100),ProductNumber NVARCHAR(25),CurrentPrice MONEY,NewPrice MONEY,ChangedDate DATETIME)

INSERT INTO PriceAdjust
(
    ProductID,
	ProductName,
    ProductNumber,
    CurrentPrice,
    NewPrice,
    ChangedDate
)
SELECT ProductID,Name,ProductNumber,StandardCost AS CurrentPrice, StandardCost + (StandardCost * 0.1) AS NewPrice,GETDATE() AS ChangedDate FROM dbo.Product


SELECT pa.ProductName,p.Color,p.StandardCost,pa.NewPrice FROM PriceAdjust AS PA
JOIN dbo.Product AS p
ON p.ProductID = pa.ProductID



/*

Final test we compare both!

*/


DECLARE @PriceAdjust TABLE(ProductID INT,ProductName VARCHAR(100),ProductNumber NVARCHAR(25),CurrentPrice MONEY,NewPrice MONEY,ChangedDate DATETIME)

INSERT INTO @PriceAdjust
(
    ProductID,
	ProductName,
    ProductNumber,
    CurrentPrice,
    NewPrice,
    ChangedDate
)
SELECT ProductID,Name,ProductNumber,StandardCost AS CurrentPrice, StandardCost + (StandardCost * 0.1) AS NewPrice,GETDATE() AS ChangedDate FROM dbo.Product



SELECT pa.ProductName,p.Color,p.StandardCost,pa.NewPrice FROM @PriceAdjust AS PA
JOIN dbo.Product AS p
ON p.ProductID = pa.ProductID




DROP TABLE IF EXISTS PriceAdjust
