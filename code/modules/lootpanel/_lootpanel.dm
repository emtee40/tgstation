/**
 * ## Loot panel
 * A datum that stores info containing the contents of a turf.
 * Handles opening the lootpanel UI and searching the turf for items.
 */
/datum/lootpanel
	/// The owner of the panel
	var/client/owner
	/// An associative list of all items indexed. ref:search_obj
	var/list/contents = list()
	/// The list of search_items needing processed
	var/list/datum/search_object/to_image = list()
	/// We've been notified about client version
	var/notified = FALSE
	/// If we have icons in queue for generating
	var/searching = FALSE
	/// The turf being searched
	var/turf/source_turf


/datum/lootpanel/New(client/owner)
	. = ..()

	src.owner = owner


/datum/lootpanel/Destroy(force)
	reset_contents()
	owner = null
	source_turf = null

	return ..()


/datum/lootpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LootPanel")
		ui.set_autoupdate(FALSE)
		ui.open()


/datum/lootpanel/ui_close(mob/user)
	. = ..()

	source_turf = null
	reset_contents()	
		

/datum/lootpanel/ui_data(mob/user)
	var/list/data = list()

	data["contents"] = get_contents()
	data["searching"] = searching

	return data


/datum/lootpanel/ui_status(mob/user, datum/ui_state/state)
	if(!source_turf.Adjacent(user))
		return UI_CLOSE

	if(user.incapacitated())
		return UI_DISABLED

	return UI_INTERACTIVE


/datum/lootpanel/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("grab")
			return grab(usr, params)
		if("refresh")
			return populate_contents()

	return FALSE
