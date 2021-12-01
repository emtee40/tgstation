/**
 * Creates a TGUI window with a text input. Returns the user's response.
 *
 * This proc should be used to create windows for text entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If max_length is specified, will return
 * stripped_multiline_input.
 *
 * Arguments:
 * * user - The user to show the textbox to.
 * * message - The content of the textbox, shown in the body of the TGUI window.
 * * title - The title of the textbox modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder.
 * * max_length - Specifies a max length for input.
 * * timeout - The timeout of the textbox, after which the modal will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_textbox(mob/user, message = null, title = "Text Input", default = null, max_length = null, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	/// Client does NOT have tgui_fancy on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_fancy))
		if(max_length)
			if(max_length <= MAX_NAME_LEN)
				return stripped_input(user, message, title, default, max_length)
			else
				return stripped_multiline_input(user, message, title, default, max_length)
		else
			return input(user, message, title, default)
	var/datum/tgui_textbox/textbox = new(user, message, title, default, max_length, timeout)
	textbox.ui_interact(user)
	textbox.wait()
	if (textbox)
		. = textbox.entry
		qdel(textbox)

/**
 * Creates an asynchronous TGUI text input window with an associated callback.
 *
 * This proc should be used to create textboxes that invoke a callback with the user's entry.
 * Arguments:
 * * user - The user to show the textbox to.
 * * message - The content of the textbox, shown in the body of the TGUI window.
 * * title - The title of the textbox modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder.
 * * max_length - Specifies a max length for input.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the textbox, after which the modal will close and qdel itself. Disabled by default, can be set to seconds otherwise.
 */
/proc/tgui_textbox_async(mob/user, message = null, title = "Text Input", default = "Type something...", max_length = null, datum/callback/callback, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_textbox/async/textbox = new(user, message, title, default, max_length, callback, timeout)
	textbox.ui_interact(user)

/**
 * # tgui_textbox
 *
 * Datum used for instantiating and using a TGUI-controlled textbox that prompts the user with
 * a message and has an input for text entry.
 */
/datum/tgui_textbox
	/// Boolean field describing if the tgui_textbox was closed by the user.
	var/closed
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum length for text entry
	var/max_length
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// The default (or current) value, shown as a default.
	var/default
	/// String that modulates the return casting
	var/start_time
	/// The lifespan of the tgui_textbox, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title


/datum/tgui_textbox/New(mob/user, message, title, default, max_length, timeout)
	src.default = default
	src.max_length = max_length
	src.message = message
	src.title = title
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_textbox/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_textbox's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_textbox/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_textbox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TextboxModal")
		ui.open()

/datum/tgui_textbox/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_textbox/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_textbox/ui_data(mob/user)
	. = list(
		"max_length" = max_length,
		"message" = message,
		"placeholder" = default, /// You cannot use default as a const
		"title" = title,
	)
	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_textbox/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(max_length && (length(params["entry"]) > max_length))
				return FALSE
			set_entry(params["entry"])
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			set_entry(null)
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_textbox/proc/set_entry(entry)
		src.entry = entry

/**
 * # async tgui_textbox
 *
 * An asynchronous version of tgui_textbox to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_textbox/async
	/// The callback to be invoked by the tgui_textbox upon having a choice made.
	var/datum/callback/callback

/datum/tgui_textbox/async/New(mob/user, message, title, default, max_length, callback, timeout)
	..(user, message, title, default, max_length, timeout)
	src.callback = callback

/datum/tgui_textbox/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_textbox/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		callback?.InvokeAsync(src.entry)

/datum/tgui_textbox/async/wait()
	return
