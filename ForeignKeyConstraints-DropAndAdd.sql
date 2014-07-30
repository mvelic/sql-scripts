/*

# Drop and re-add Foreign Key Constraints based on a Schema and Table combination

- To initialize, open the script in SQL Server Management Studio, then type "Ctrl + Shift + M". Enter the schema and table names.

- The script will create DROP and ADD CONSTRAINT statements based on the schema.table provided.
- Can be useful if a mass reset of test data needs to happen (IE, lots 'o TRUNCATE).
- Won't actually run the DROP and ADD commands; only generates the SQL necessary for copy-paste purposes.

*/

DECLARE @schema SYSNAME = '<schema_name, sysname, table_name>',
    @table SYSNAME = '<table_name, sysname, table_name>';

SELECT  'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + o.name + '];' AS DropStatements ,
        'ALTER TABLE [' + s.name + '].[' + t.name + '] ADD CONSTRAINT [' + o.name + '] FOREIGN KEY (' + c.name + ') REFERENCES [dbo].[CCDDomain] (Id);' AS CreateStatements
FROM    sys.foreign_key_columns AS fk
JOIN sys.tables AS t
	ON fk.parent_object_id = t.object_id
JOIN sys.columns AS c
	ON fk.parent_object_id = c.object_id
	AND fk.parent_column_id = c.column_id
JOIN sys.objects o
	ON fk.constraint_object_id = o.object_id
JOIN sys.schemas s
	ON t.schema_id = s.schema_id
WHERE fk.referenced_object_id = (
	SELECT t.object_id
	FROM sys.tables t
	JOIN sys.schemas s
		ON t.schema_id = s.schema_id
	WHERE s.name = @schema
		AND t.name = @table
);