
// Schema version must always be the very last element in the array.

// Current Schema: 1.0.0
// [timestamp, category, message, data, world_state, semver_store, id, schema_version]

/// A datum which contains log information.
/datum/log_entry
	/// Next id to assign to a log entry.
	var/static/next_id = 0

	/// Unique id of the log entry.
	var/id

	/// Schema version of the log entry.
	var/schema_version = "1.0.0"

	/// Unix timestamp of the log entry.
	var/timestamp

	/// Category of the log entry.
	var/category

	/// Message of the log entry.
	var/message

	/// Data of the log entry; optional.
	var/list/data

	/// Semver store of the log entry, used to store the schema of data entries
	var/list/semver_store

GENERAL_PROTECT_DATUM(/datum/log_entry)

/datum/log_entry/New(timestamp, category, message, list/data, list/semver_store)
	..()

	src.id = next_id++
	src.timestamp = timestamp
	src.category = category
	src.message = message
	with_data(data)
	with_semver_store(semver_store)

/datum/log_entry/proc/with_data(list/data)
	if(!isnull(data))
		if(!islist(data))
			src.data = list("data" = data)
			stack_trace("Log entry data was not a list, it was [data.type].")
		else
			src.data = data
	return src

/datum/log_entry/proc/with_semver_store(list/semver_store)
	if(isnull(semver_store))
		return
	if(!islist(semver_store))
		stack_trace("Log entry semver store was not a list, it was [semver_store.type]. We cannot reliably convert it to a list.")
	else
		src.semver_store = semver_store
	return src

/// Converts the log entry to a human-readable string.
/datum/log_entry/proc/to_readable_text(serialize_data = FALSE)
	return "\[[timestamp]\] [uppertext(category)]: [message]"

/// Converts the log entry to a JSON string.
/datum/log_entry/proc/to_json_text()
	// I do not trust byond's json encoder, so we're doing it manually
	var/json_out = "\["

	// Timestamp
	json_out += "\"[timestamp]\","

	// Category
	json_out += "\"[category]\","

	// Message
	json_out += "\"[message]\","

	// Data?
	if(length(data))
		json_out += "[json_encode(data)],"
	else
		json_out += "\[\],"

	// World state
	json_out += "[json_encode(world.get_world_state_for_logging())],"

	// Semver store
	if(length(semver_store))
		json_out += "[json_encode(semver_store)],"
	else
		json_out += "\[\],"

	// ID
	json_out += "[id],"

	// Schema version
	json_out += "\"[schema_version]\""

	// End of array
	json_out += "\]"
	return json_out

/// Writes the log entry to a file.
/datum/log_entry/proc/write_entry_to_file(file)
	if(!fexists(file))
		CRASH("Attempted to log to an uninitialized file: [file]")
	rustg_file_append("[to_json_text()]\n", file)

/// Writes the log entry to a file as a human-readable string.
/datum/log_entry/proc/write_readable_entry_to_file(file)
	if(!fexists(file))
		CRASH("Attempted to log to an uninitialized file: [file]")
	rustg_file_append("[to_readable_text()]\n", file)
