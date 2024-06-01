/**
 * Equips this mob with a given outfit and loadout items as per the passed preferences.
 *
 * Loadout items override the pre-existing item in the corresponding slot of the job outfit.
 * Some job items are preserved after being overridden - belt items, ear items, and glasses.
 * The rest of the slots, the items are overridden completely and deleted.
 *
 * Species with special outfits are snowflaked to have loadout items placed in their bags instead of overriding the outfit.
 *
 * * outfit - the job outfit we're equipping
 * * preference_source - the preferences to draw loadout items from.
 * * visuals_only - whether we call special equipped procs, or if we just look like we equipped it
 */
/mob/living/carbon/human/proc/equip_outfit_and_loadout(
	datum/outfit/outfit = /datum/outfit,
	datum/preferences/preference_source,
	visuals_only = FALSE,
)
	if(isnull(preference_source))
		return equipOutfit(outfit, visuals_only)

	var/datum/outfit/equipped_outfit
	if(ispath(outfit, /datum/outfit))
		equipped_outfit = new outfit()
	else if(istype(outfit, /datum/outfit))
		equipped_outfit = outfit
	else
		CRASH("Invalid outfit passed to equip_outfit_and_loadout ([outfit])")

	var/list/preference_list = preference_source.read_preference(/datum/preference/loadout)
	var/list/loadout_datums = loadout_list_to_datums(preference_list)
	// Slap our things into the outfit given
	for(var/datum/loadout_item/item as anything in loadout_datums)
		item.insert_path_into_outfit(equipped_outfit, src, visuals_only)
	// Equip the outfit loadout items included
	if(!equipped_outfit.equip(src, visuals_only))
		return FALSE
	// Handle any snowflake on_equips
	var/list/new_contents = get_all_gear()
	for(var/datum/loadout_item/item as anything in loadout_datums)
		var/obj/item/equipped = locate(item.item_path) in new_contents
		if(isnull(equipped))
			return
		item.on_equip_item(
			equipped,
			preference_source,
			preference_list,
			src,
			visuals_only,
		)

	return TRUE

/**
 * Takes a list of paths (such as a loadout list)
 * and returns a list of their singleton loadout item datums
 *
 * loadout_list - the list being checked
 *
 * returns a list of singleton datums
 */
/proc/loadout_list_to_datums(list/loadout_list)
	RETURN_TYPE(/list)
	var/list/datums = list()

	if(!length(GLOB.all_loadout_datums))
		CRASH("No loadout datums in the global loadout list!")

	for(var/path in loadout_list)
		var/actual_datum = GLOB.all_loadout_datums[path]
		if(!istype(actual_datum, /datum/loadout_item))
			stack_trace("Could not find ([path]) loadout item in the global list of loadout datums!")
			continue

		datums += actual_datum

	return datums

/// Used for very easily adding a new typepath with associated data to the loadout list of this preference
/datum/preferences/proc/add_loadout_item(typepath, list/data = list())
	PRIVATE_PROC(TRUE) // Yes this is private, I don't really want this used outside of preferences

	var/list/loadout_list = read_preference(/datum/preference/loadout)
	loadout_list[typepath] = data
	write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)

/// Used for very easily removing a typepath from the loadout list of this preference
/datum/preferences/proc/remove_loadout_item(typepath)
	PRIVATE_PROC(TRUE) // See above

	var/list/loadout_list = read_preference(/datum/preference/loadout)
	if(loadout_list.Remove(typepath))
		write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)
