/**
  * Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
  *
  * Hardcoded to the ESC key.
  */
/client/verb/reset_held_keys()
	set name = "Reset Held Keys"
	set hidden = TRUE

	for(var/key in keys_held)
		keyUp(key)

	for(var/k in keybinds_held)
		var/datum/keybinding/keybind = k
		keybind.up(src)
