/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/admin_help/down(client/user)
	. = ..()
	if(.)
		return
	user.get_adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("F2")
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
	return TRUE

/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/minimal_hud/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE


/datum/keybinding/client/show_names
	hotkey_keys = list("Shift")
	name = "show mob names"
	full_name = "show mob names"
	description = "Show names of nearby mobs."
	keybind_signal = COMSIG_KB_CLIENT_SHOW_MOB_NAMES_DOWN

/datum/keybinding/client/show_names/down(client/user)
	. = ..()
	if(.)
		return
	var/atom/movable/screen/plane_master/name_planemaster = user.mob.hud_used.plane_masters["[MOB_NAME_PLANE]"]
	name_planemaster.Show()

/datum/keybinding/client/show_names/up(client/user)
	var/atom/movable/screen/plane_master/name_planemaster = user.mob.hud_used.plane_masters["[MOB_NAME_PLANE]"]
	name_planemaster.Hide()


