/datum/map_template/shuttle/voidcrew/blackbeard
	name = "Blackbeard-class Heavy Boarder"
	suffix = "syndicate_blackbeard"
	short_name = "Blackbeard-Class"

	job_slots = list(
		list(
			name = "Syndicate Strike Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/syndicate,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor/syndicate,
			slots = 1,
		),
		list(
			name = "Syndicate Marine",
			outfit = /datum/outfit/job/assistant/syndicate,
			slots = 4,
		),
	)
