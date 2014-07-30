/*

# Gut check database files

- Script can check out some of the more important configuration options in the database files [on disk].
- The initial query can be used to look at everything on an instance.
- Uncomment each WHERE clause individually to find potential problems.

*/

SELECT
	mf.database_id
	,mf.[file_id]
	,mf.name
	,mf.type_desc
	,mf.physical_name
	,mf.size/128 AS [Size in MB]
	,mf.max_size/128 AS [Max Size in MB] --Note: 0 = Unlimited Size
	,CASE mf.is_percent_growth
		WHEN 1 THEN CONVERT(VARCHAR(12),mf.growth) + '%'
		WHEN 0 THEN CONVERT(VARCHAR(12),mf.growth/128) + 'MB'
	END AS [Growth]
	,CASE mf.is_percent_growth
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS is_percent_growth
FROM sys.master_files AS mf

/*
 * Any records returned are using the default log growth sizing, which can lead to run-away growth
 */
--WHERE mf.max_size = 268435456
--  AND mf.growth = 10
--  AND mf.is_percent_growth = 1
--  AND mf.type_desc = 'LOG'

/*
 * This combination can also lead to run-away growth without proper care
 */
--WHERE mf.max_size = -1
--  AND mf.is_percent_growth = 1

/*
 * Any records returned may be affected by a log growth bug described by Paul Randal
 * Paul notes that this is fixed in SQL Server 2012
 * See: http://www.sqlskills.com/BLOGS/PAUL/post/Bug-log-file-growth-broken-for-multiples-of-4GB.aspx
 */
--WHERE (mf.growth/128) % 4096 = 0
--  AND mf.is_percent_growth = 0
--  AND mf.type_desc = 'LOG'