
/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life(delta_time = SSMOBS_DT, times_fired)
	return

/mob/living/carbon/human/dummy/attach_rot(mapload)
	return

/mob/living/carbon/human/dummy/proc/wipe_state()
	delete_equipment()
	cut_overlays(TRUE)

/mob/living/carbon/human/dummy/setup_human_dna()
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna(skip_index = TRUE) //Skip stuff that requires full round init.

//Inefficient pooling/caching way.
GLOBAL_LIST_EMPTY(human_dummy_list)
GLOBAL_LIST_EMPTY(dummy_mob_list)

/proc/generate_or_wait_for_human_dummy(slotkey)
	if(!slotkey)
		return new /mob/living/carbon/human/dummy
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	if(istype(D))
		UNTIL(!D.in_use)
	if(QDELETED(D))
		D = new
		GLOB.human_dummy_list[slotkey] = D
		GLOB.dummy_mob_list += D
	else
		D.regenerate_icons() //they were cut in wipe_state()
	D.in_use = TRUE
	return D

/proc/generate_dummy_lookalike(slotkey, mob/target)
	if(!istype(target))
		return generate_or_wait_for_human_dummy(slotkey)

	var/mob/living/carbon/human/dummy/copycat = generate_or_wait_for_human_dummy(slotkey)

	//even if target isn't a carbon, if they have a client we can make the
	//dummy look like what their human would look like based on their prefs
	var/datum/preferences/prefs = target?.client?.prefs
	if(istype(prefs))
		prefs.copy_to(copycat, icon_updates=TRUE, roundstart_checks=FALSE, character_setup=TRUE)

	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/carbon_target = target
		carbon_target.dna.transfer_identity(copycat, transfer_SE = TRUE)

		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/human_target = target
			human_target.copy_clothing_prefs(copycat)

		//updating appearance if target isn't a carbon will reset the appearance given above by prefs
		copycat.updateappearance(icon_update=TRUE, mutcolor_update=TRUE, mutations_overlay_update=TRUE)

	return copycat

/proc/unset_busy_human_dummy(slotkey)
	if(!slotkey)
		return
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	if(istype(D))
		D.wipe_state()
		D.in_use = FALSE

/proc/clear_human_dummy(slotkey)
	if(!slotkey)
		return

	var/mob/living/carbon/human/dummy/dummy = GLOB.human_dummy_list[slotkey]

	GLOB.human_dummy_list -= slotkey
	if(istype(dummy))
		GLOB.dummy_mob_list -= dummy
		qdel(dummy)
