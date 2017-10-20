/*

Maintaining Indexes

*/



/*

Duplicated Indexes

Script from my great friend and SQL Server Performance Expert and MVP Fabiano Amorin
Twitter: @mcflyamorim
Blog: https://blogfabiano.com/

*/
WITH    indexcols
          AS ( SELECT   object_id AS id ,
                        index_id AS indid ,
                        name ,
                        ( SELECT    CASE keyno
                                      WHEN 0 THEN NULL
                                      ELSE colid
                                    END AS [data()]
                          FROM      sys.sysindexkeys AS k
                          WHERE     k.id = i.object_id
                                    AND k.indid = i.index_id
                          ORDER BY  keyno ,
                                    colid
                        FOR
                          XML PATH('')
                        ) AS cols ,
                        ( SELECT    CASE keyno
                                      WHEN 0 THEN colid
                                      ELSE NULL
                                    END AS [data()]
                          FROM      sys.sysindexkeys AS k
                          WHERE     k.id = i.object_id
                                    AND k.indid = i.index_id
                          ORDER BY  colid
                        FOR
                          XML PATH('')
                        ) AS inc
               FROM     sys.indexes AS i
             )
    SELECT  DB_NAME() AS 'DBName' ,
            OBJECT_SCHEMA_NAME(c1.id) + '.' + OBJECT_NAME(c1.id) AS 'TableName' ,
            c1.name + CASE c1.indid
                        WHEN 1 THEN ' (clustered index)'
                        ELSE ' (nonclustered index)'
                      END AS 'IndexName' ,
            c2.name + CASE c2.indid
                        WHEN 1 THEN ' (clustered index)'
                        ELSE ' (nonclustered index)'
                      END AS 'ExactDuplicatedIndexName',
                      'DROP INDEX ' + QUOTENAME(c2.name) + ' ON ' +  OBJECT_SCHEMA_NAME(c1.id) + '.' + OBJECT_NAME(c1.id)
                      
    FROM    indexcols AS c1
            INNER JOIN indexcols AS c2 ON c1.id = c2.id
                                          AND c1.indid < c2.indid
                                          AND c1.cols = c2.cols
                                          AND c1.inc = c2.inc ;



/*

Index Utilization

*/


SELECT 
o.name
, indexname=i.name
, i.index_id   
, reads=user_seeks + user_scans + user_lookups   
, writes =  user_updates   
, rows = (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id)
, Cast((ps.reserved_page_count * 8)/1024. as decimal(12,2)) as size_in_mb
, CASE
	WHEN s.user_updates < 1 THEN 100
	ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) / s.user_updates
  END AS reads_per_write
, 'DROP INDEX ' + QUOTENAME(i.name) 
+ ' ON ' + QUOTENAME(c.name) + '.' + QUOTENAME(OBJECT_NAME(s.object_id)) as 'drop statement'
FROM sys.dm_db_index_usage_stats s  
INNER JOIN sys.indexes i ON i.index_id = s.index_id AND s.object_id = i.object_id   
INNER JOIN sys.objects o on s.object_id = o.object_id
INNER JOIN sys.schemas c on o.schema_id = c.schema_id
INNER JOIN sys.dm_db_partition_stats ps ON i.object_id = ps.object_id AND i.index_id = ps.index_id
WHERE OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
AND s.database_id = DB_ID()   
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
--AND (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id) > 10000
ORDER BY reads






/*

Prefer looking for missing indexes into the Plan Cache
Author: Glenn Berry 
Twitter: @GlennAlanBerry
https://sqlserverperformance.wordpress.com/category/diagnostic-queries/


*/

SELECT TOP(25) OBJECT_NAME(objectid) AS [ObjectName], 
               cp.objtype, cp.usecounts, cp.size_in_bytes, query_plan
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE CAST(query_plan AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
AND dbid = DB_ID()
ORDER BY cp.usecounts DESC OPTION (RECOMPILE);


