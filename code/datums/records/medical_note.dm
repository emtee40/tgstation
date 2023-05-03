/**
 * Player-written medical note.
 */
/datum/medical_note
	/// Player that wrote the note
	var/author
	/// Details of the note
	var/content
	/// Station timestamp
	var/time

/datum/medical_note/New(author = "Anonymous", content = "No details provided.")
	src.author = author
	src.content = content
	src.time = SSday_night.get_twenty_four_hour_timestamp()
