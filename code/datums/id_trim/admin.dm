/// Trim for admins and debug cards. Has every single access in the game.
/datum/id_trim/admin
	assignment = "Jannie"
	trim_state = "trim_janitor"
	department_color = "#134975"
	subdepartment_color = "#58C800"

/datum/id_trim/admin/New()
	. = ..()
	// Every single access in the game, all on one handy trim.
	access = SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))

/// Trim for highlander cards, used during the highlander adminbus event.
/datum/id_trim/highlander
	assignment = "Highlander"
	trim_state = "trim_ert_deathcommando"
	department_color = "#134975"
	subdepartment_color = "#58C800"

/datum/id_trim/highlander/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))
