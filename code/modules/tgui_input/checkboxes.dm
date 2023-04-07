/**
 * ### tgui_input_checkbox
 * Opens a window with a list of checkboxes and returns a list of selected choices.
 *
 * user - The mob to display the window to
 * message - The message inside the window
 * title - The title of the window
 * list/items - The list of items to display
 * timeout - The timeout for the input (optional)
 */
/proc/tgui_input_checkboxes(mob/user, message, title = "Select", list/items, timeout = 0)
	if (!user)
		user = usr
	if(!length(items))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		return input(user, message, title) as null|anything in items
	var/datum/tgui_checkbox_input/input = new(user, message, title, items, timeout)
	input.ui_interact(user)
	input.wait()
	if (input)
		. = input.choices
		qdel(input)

/// Window for tgui_input_checkboxes
/datum/tgui_checkbox_input
	/// Title of the window
	var/title
	/// Message to display
	var/message
	/// List of items to display
	var/list/items
	/// List of selected items
	var/list/choices
	/// Time when the input was created
	var/start_time
	/// Timeout for the input
	var/timeout
	/// Whether the input was closed
	var/closed

/datum/tgui_checkbox_input/New(mob/user, message, title, list/items, timeout)
	src.title = title
	src.message = message
	src.items = items.Copy()

	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_checkbox_input/Destroy(force, ...)
	SStgui.close_uis(src)
	QDEL_NULL(items)

	return ..()

/datum/tgui_checkbox_input/proc/wait()
	while (!closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_checkbox_input/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CheckboxInput")
		ui.open()

/datum/tgui_checkbox_input/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_checkbox_input/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_checkbox_input/ui_data(mob/user)
	var/list/data = list()

	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

	return data

/datum/tgui_checkbox_input/ui_static_data(mob/user)
	var/list/data = list()

	data["items"] = items
	data["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	data["message"] = message
	data["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	data["title"] = title

	return data

/datum/tgui_checkbox_input/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch(action)
		if("submit")
			var/list/selections = params["entry"]
			if(length(selections) > 0)
				set_choices(selections)
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

	return FALSE

/datum/tgui_checkbox_input/proc/set_choices(list/selections)
	src.choices = selections.Copy()
