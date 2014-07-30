/*

# Gut check databases

- Script can return info on important database statuses and configurations.
- The initial query can be used to look at everything on an instance.
- Uncomment each WHERE clause individually to find potential problems.

*/

SELECT
	d.database_id
	,d.name
	,d.state_desc
	,CASE d.is_auto_shrink_on
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS is_auto_shrink_on
	,d.recovery_model_desc
	,d.page_verify_option_desc
	,CASE d.is_auto_create_stats_on
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS is_auto_create_stats_on
	,CASE d.is_auto_update_stats_on
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS is_auto_update_stats_on
	,d.log_reuse_wait_desc
FROM sys.databases AS d

/*
 * Why are any of your databases not online?
 */
--WHERE d.state_desc <> 'ONLINE'

/*
 * Auto shrink is bad ju-ju for performance. Make sure it isn't turned on for any databases.
 */
--WHERE d.is_auto_shrink_on = 1

/*
 * CHECKSUM is the best level of protection against data corruption.
 */
--WHERE d.page_verify_option_desc <> 'CHECKSUM'

/*
 * Statistics are an important piece of SQL Server performance. At a base level, make sure they are begin created/updated automatically.
 */
 --WHERE d.is_auto_create_stats_on = 0
 --  AND d.is_auto_update_stats_on = 0

/*
 * What's keeping the transaction log from cycling?
 */
--WHERE d.log_reuse_wait_desc <> 'NOTHING'