/datum/component/grillable
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // So you can change grill results with various cookstuffs
	///Result atom type of grilling this object
	var/atom/cook_result
	///Amount of time required to cook the food
	var/required_cook_time = 2 MINUTES
	///Is this a positive grill result?
	var/positive_result = TRUE

	///Time spent cooking so far
	var/current_cook_time = 0

	///Are we currently grilling?
	var/currently_grilling = FALSE

	///Do we use the large steam sprite?
	var/use_large_steam_sprite = FALSE

/datum/component/grillable/Initialize(cook_result, required_cook_time, positive_result, use_large_steam_sprite)
	. = ..()
	if(!isitem(parent)) //Only items support grilling at the moment
		return COMPONENT_INCOMPATIBLE

	src.cook_result = cook_result
	src.required_cook_time = required_cook_time
	src.positive_result = positive_result
	src.use_large_steam_sprite = use_large_steam_sprite

	register_signal(parent, COMSIG_ITEM_GRILLED, .proc/OnGrill)
	register_signal(parent, COMSIG_PARENT_EXAMINE, .proc/OnExamine)

// Inherit the new values passed to the component
/datum/component/grillable/InheritComponent(datum/component/grillable/new_comp, original, cook_result, required_cook_time, positive_result, use_large_steam_sprite)
	if(!original)
		return
	if(cook_result)
		src.cook_result = cook_result
	if(required_cook_time)
		src.required_cook_time = required_cook_time
	if(positive_result)
		src.positive_result = positive_result
	if(use_large_steam_sprite)
		src.use_large_steam_sprite = use_large_steam_sprite

///Ran every time an item is grilled by something
/datum/component/grillable/proc/OnGrill(datum/source, atom/used_grill, delta_time = 1)
	SIGNAL_HANDLER

	. = COMPONENT_HANDLED_GRILLING

	current_cook_time += delta_time * 10 //turn it into ds
	if(current_cook_time >= required_cook_time)
		FinishGrilling(used_grill)
	else if(!currently_grilling) //We havn't started grilling yet
		StartGrilling(used_grill)


///Ran when an object starts grilling on something
/datum/component/grillable/proc/StartGrilling(atom/grill_source)
	currently_grilling = TRUE
	register_signal(parent, COMSIG_MOVABLE_MOVED, .proc/OnMoved)
	register_signal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/AddGrilledItemOverlay)

	var/atom/A = parent
	A.update_appearance()

///Ran when an object finished grilling
/datum/component/grillable/proc/FinishGrilling(atom/grill_source)

	var/atom/original_object = parent

	if(istype(parent, /obj/item/stack)) //Check if its a sheet, for grilling multiple things in a stack
		var/obj/item/stack/itemstack = original_object
		var/atom/grilled_result = new cook_result(original_object.loc, itemstack.amount)
		SEND_SIGNAL(parent, COMSIG_GRILL_COMPLETED, grilled_result)
		currently_grilling = FALSE
		grill_source.visible_message("<span class='[positive_result ? "notice" : "warning"]'>[parent] turns into \a [grilled_result]!</span>")
		grilled_result.pixel_x = original_object.pixel_x
		grilled_result.pixel_y = original_object.pixel_y
		qdel(parent)
		return

	var/atom/grilled_result = new cook_result(original_object.loc)

	if(original_object.custom_materials)
		grilled_result.set_custom_materials(original_object.custom_materials, 1)

	grilled_result.pixel_x = original_object.pixel_x
	grilled_result.pixel_y = original_object.pixel_y


	grill_source.visible_message("<span class='[positive_result ? "notice" : "warning"]'>[parent] turns into \a [grilled_result]!</span>")
	SEND_SIGNAL(parent, COMSIG_GRILL_COMPLETED, grilled_result)
	currently_grilling = FALSE
	qdel(parent)

///Ran when an object almost finishes grilling
/datum/component/grillable/proc/OnExamine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!current_cook_time) //Not grilled yet
		if(positive_result)
			examine_list += span_notice("[parent] can be <b>grilled</b> into \a [initial(cook_result.name)].")
		return

	if(positive_result)
		if(current_cook_time <= required_cook_time * 0.75)
			examine_list += span_notice("[parent] probably needs to be cooked a bit longer!")
		else if(current_cook_time <= required_cook_time)
			examine_list += span_notice("[parent] seems to be almost finished cooking!")
	else
		examine_list += span_danger("[parent] should probably not be cooked for much longer!")

///Ran when an object moves from the grill
/datum/component/grillable/proc/OnMoved(atom/A, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	currently_grilling = FALSE
	unregister_signal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	unregister_signal(parent, COMSIG_MOVABLE_MOVED)
	A.update_appearance()

/datum/component/grillable/proc/AddGrilledItemOverlay(datum/source, list/overlays)
	SIGNAL_HANDLER

	overlays += mutable_appearance('icons/effects/steam.dmi', "[use_large_steam_sprite ? "steam_triple" : "steam_single"]", ABOVE_OBJ_LAYER)
