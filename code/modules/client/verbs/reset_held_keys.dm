/**
  * Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
  *
  * Hardcoded to the ESC key.
  * Arguments:
  */
/client/verb/reset_held_keys()
	set name = "Reset Held Keys"
	set category = "OOC"
	set hidden = TRUE

	for(var/key in keys_held)
		keyUp(key)

