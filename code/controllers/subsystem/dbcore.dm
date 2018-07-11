SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DBCORE
	var/const/FAILED_DB_CONNECTION_CUTOFF = 5

	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
	var/failed_connections = 0

	var/last_error

	var/datum/BSQL_Connection/connection
	var/datum/BSQL_Operation/connectOperation

/datum/controller/subsystem/dbcore/Initialize()
	//We send warnings to the admins during subsystem init, as the clients will be New'd and messages
	//will queue properly with goonchat
	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	return ..()


/datum/controller/subsystem/dbcore/Recover()
	connection = SSdbcore.connection
	connectOperation = SSdbcore.connectOperation

/datum/controller/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_round_shutdown = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = '[sanitizeSQL(SSticker.end_state)]' WHERE id = [GLOB.round_id]")
		query_round_shutdown.Execute()
	if(IsConnected())
		Disconnect()
	world.BSQL_Shutdown()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	return !(var_name == NAMEOF(src, connection) || var_name == NAMEOF(src, connectOperation)) && ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, connection) || var_name == NAMEOF(src, connectOperation))
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)

	connection = new /datum/BSQL_Connection(BSQL_CONNECTION_TYPE_MARIADB)
	var/error
	if(QDELETED(connection))
		connection = null
		error = last_error
	else
		connectOperation = connection.BeginConnect(address, port, user, pass, db)
		UNTIL(connectOperation.IsComplete())
		error = connectOperation.GetError()
	. = !error
	if (!.)
		log_sql("Connect() failed | [error]")
		++failed_connections
		QDEL_NULL(connection)
		QDEL_NULL(connectOperation)

/datum/controller/subsystem/dbcore/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			log_world("Database connection established.")
			var/datum/DBQuery/query_db_version = NewQuery("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1")
			query_db_version.Execute()
			if(query_db_version.NextRow())
				db_major = text2num(query_db_version.item[1])
				db_minor = text2num(query_db_version.item[2])
				if(db_major != DB_MAJOR_VERSION || db_minor != DB_MINOR_VERSION)
					schema_mismatch = 1 // flag admin message about mismatch
					log_sql("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
			else
				schema_mismatch = 2 //flag admin message about no schema version
				log_sql("Could not get schema version from database")
		else
			log_sql("Your server failed to establish a connection with the database.")
	else
		log_sql("Database is not enabled in configuration.")

/datum/controller/subsystem/dbcore/proc/SetRoundID()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			var/datum/DBQuery/query_round_initialize = NewQuery("INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
			query_round_initialize.Execute()
			var/datum/DBQuery/query_round_last_id = NewQuery("SELECT LAST_INSERT_ID()")
			query_round_last_id.Execute()
			if(query_round_last_id.NextRow())
				GLOB.round_id = query_round_last_id.item[1]

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			var/datum/DBQuery/query_round_start = NewQuery("UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = [GLOB.round_id]")
			query_round_start.Execute()

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			var/sql_station_name = sanitizeSQL(station_name())
			var/datum/DBQuery/query_round_end = NewQuery("UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = '[sanitizeSQL(SSticker.mode_result)]', station_name = '[sql_station_name]' WHERE id = [GLOB.round_id]")
			query_round_end.Execute()

/datum/controller/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	QDEL_NULL(connectOperation)
	QDEL_NULL(connection)

/datum/controller/subsystem/dbcore/proc/IsConnected()
	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE
	//block until any connect operations finish
	var/datum/BSQL_Connection/_connection = connection
	var/datum/BSQL_Operation/op = connectOperation
	UNTIL(QDELETED(_connection) || op.IsComplete())
	return !QDELETED(connection) && !op.GetError()

/datum/controller/subsystem/dbcore/proc/Quote(str)
	if(connection)
		return connection.Quote(str)

/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	if(!CONFIG_GET(flag/sql_enabled))
		return "Database disabled by configuration"
	return last_error

/datum/controller/subsystem/dbcore/proc/ReportError(error)
	last_error = error

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query)
	if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Query has been blocked")
		return FALSE
	return new /datum/DBQuery(sql_query, connection)

/*
Takes a list of rows (each row being an associated list of column => value) and inserts them via a single mass query.
Rows missing columns present in other rows will resolve to SQL NULL
You are expected to do your own escaping of the data, and expected to provide your own quotes for strings.
The duplicate_key arg can be true to automatically generate this part of the query
	or set to a string that is appended to the end of the query
Ignore_errors instructes mysql to continue inserting rows if some of them have errors.
	 the erroneous row(s) aren't inserted and there isn't really any way to know why or why errored
Delayed insert mode was removed in mysql 7 and only works with MyISAM type tables,
	It was included because it is still supported in mariadb.
	It does not work with duplicate_key and the mysql server ignores it in those cases
*/
/datum/controller/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = FALSE)
	if (!table || !rows || !istype(rows))
		return
	var/list/columns = list()
	var/list/sorted_rows = list()

	for (var/list/row in rows)
		var/list/sorted_row = list()
		sorted_row.len = columns.len
		for (var/column in row)
			var/idx = columns[column]
			if (!idx)
				idx = columns.len + 1
				columns[column] = idx
				sorted_row.len = columns.len

			sorted_row[idx] = row[column]
		sorted_rows[++sorted_rows.len] = sorted_row

	if (duplicate_key == TRUE)
		var/list/column_list = list()
		for (var/column in columns)
			column_list += "[column] = VALUES([column])"
		duplicate_key = "ON DUPLICATE KEY UPDATE [column_list.Join(", ")]\n"
	else if (duplicate_key == FALSE)
		duplicate_key = null

	if (ignore_errors)
		ignore_errors = " IGNORE"
	else
		ignore_errors = null

	if (delayed)
		delayed = " DELAYED"
	else
		delayed = null

	var/list/sqlrowlist = list()
	var/len = columns.len
	for (var/list/row in sorted_rows)
		if (length(row) != len)
			row.len = len
		for (var/value in row)
			if (value == null)
				value = "NULL"
		sqlrowlist += "([row.Join(", ")])"

	sqlrowlist = "	[sqlrowlist.Join(",\n	")]"
	var/datum/DBQuery/Query = NewQuery("INSERT[delayed][ignore_errors] INTO [table]\n([columns.Join(", ")])\nVALUES\n[sqlrowlist]\n[duplicate_key]")
	if (warn)
		return Query.warn_execute(async)
	else
		return Query.Execute(async)

/world/proc/BSQL_Debug(message)
	log_world("BSQL_DEBUG: [message]")

/datum/DBQuery
	var/sql // The sql query being executed.
	var/list/item  //list of data values populated by NextRow()

	var/last_error
	var/skip_next_is_complete
	var/in_progress
	var/datum/BSQL_Connection/connection
	var/datum/BSQL_Operation/Query/query

/datum/DBQuery/New(sql_query, datum/BSQL_Connection/connection)
	sql = sql_query
	item = list()
	src.connection = connection

/datum/DBQuery/Destroy()
	Close()
	return ..()

/datum/DBQuery/proc/warn_execute(async = FALSE)
	. = Execute(async)
	if(!.)
		to_chat(usr, "<span class='danger'>A SQL error occurred during this operation, check the server logs.</span>")

/datum/DBQuery/proc/Execute(async = FALSE, log_error = TRUE)
	if(in_progress)
		CRASH("Attempted to start a new query while waiting on the old one")

	if(QDELETED(connection))
		last_error = "No connection!"
		return FALSE

	var/start_time
	var/timeout
	if(!async)
		timeout = CONFIG_GET(number/query_debug_log_timeout)
	if(timeout)
		start_time = REALTIMEOFDAY
	Close()
	query = connection.BeginQuery(sql)
	if(!async)
		query.WaitForCompletion()
	else
		in_progress = TRUE
		UNTIL(query.IsComplete())
		in_progress = FALSE
	skip_next_is_complete = TRUE
	var/error = QDELETED(query) ? "Query object deleted!" : query.GetError()
	last_error = error
	. = !error
	if(!. && log_error)
		log_sql("[error] | Query used: [sql]")
	if(timeout)
		if((REALTIMEOFDAY - start_time) > timeout)
			log_query_debug("Query execution started at [start_time]")
			log_query_debug("Query execution ended at [REALTIMEOFDAY]")
			log_query_debug("Possible slow query timeout detected.")
			log_query_debug("Query used: [sql]")
			slow_query_check()

/datum/DBQuery/proc/slow_query_check()
	message_admins("HEY! A database query may have timed out. Did the server just hang? <a href='?_src_=holder;[HrefToken()];slowquery=yes'>\[YES\]</a>|<a href='?_src_=holder;[HrefToken()];slowquery=no'>\[NO\]</a>")

/datum/DBQuery/proc/NextRow(async)
	UNTIL(!in_progress)
	if(!skip_next_is_complete)
		if(!async)
			query.WaitForCompletion()
		else
			in_progress = TRUE
			UNTIL(query.IsComplete())
			in_progress = FALSE
	else
		skip_next_is_complete = FALSE

	last_error = query.GetError()
	var/list/results = query.CurrentRow()
	. = results != null

	item.Cut()
	//populate item array
	for(var/I in results)
		item += results[I]

/datum/DBQuery/proc/ErrorMsg()
	return last_error

/datum/DBQuery/proc/Close()
	item.Cut()
	QDEL_NULL(query)
