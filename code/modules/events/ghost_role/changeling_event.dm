/*
* Changeling midround spawn event. Takes a ghost volunteer and stuffs them into a changeling with their own identity and a flesh space suit.
* They arrive via a meateor, which collides with the station. They are expected to find their own way into the station by whatever means necessary.
* The midround changeling experience is, by nature, more difficult than playing as a roundstart crew changeling.
*
*/

/datum/round_event_control/changeling
	name = "Changeling Meteor"
	typepath = /datum/round_event/ghost_role/changeling
	weight = 8
	max_occurrences = 3
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A meteor containing a changeling is summoned and thrown at the exterior of the station."

/datum/round_event/ghost_role/changeling
	minimum_required = 1
	role_name = "space changeling"
	fakeable = FALSE

/datum/round_event/ghost_role/changeling/spawn_role()
	var/list/mob/dead/observer/candidate = get_candidates(ROLE_CHANGELING, ROLE_CHANGELING_MIDROUND)

	if(!candidate.len)
		return NOT_ENOUGH_PLAYERS

	spawned_mobs += generate_changeling_meteor(pick_n_take(candidate))

	if(spawned_mobs)
		return SUCCESSFUL_SPAWN

/**
 * Recieves a mob candidate, transforms them into a changeling, and hurls them at the station inside of a changeling meteor
 *
 * Takes a given candidate and turns them into a changeling, generates a changeling meteor, and throws it at the station.
 * Returns the changeling generated by the event, NOT the meteor. This is so that it plays nicely with the dynamic ruleset
 * while still being usable in the ghost_role event as well.
 *
 * Arguments:
 * * candidate - The mob (player) to be transformed into a changeling and meteored.
 */

/proc/generate_changeling_meteor(mob/dead/selected)
	var/datum/mind/player_mind = new(selected.key)
	player_mind.active = TRUE

	var/turf/picked_start

	if (SSmapping.is_planetary())
		var/list/possible_start = list()
		for(var/obj/effect/landmark/carpspawn/spawn_point in GLOB.landmarks_list)
			possible_start += get_turf(spawn_point)
		picked_start = pick(possible_start)
	else
		var/start_z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/start_side = pick(GLOB.cardinals)
		picked_start = spaceDebrisStartLoc(start_side, start_z)

	if (!picked_start)
		stack_trace("No valid spawn location for changeling meteor")

	var/obj/effect/meteor/meaty/changeling/changeling_meteor = new(picked_start, get_random_station_turf())
	var/mob/living/carbon/human/new_changeling = new(picked_start)

	new_changeling.forceMove(changeling_meteor) //Place our payload inside of its vessel

	player_mind.transfer_to(new_changeling)
	player_mind.special_role = ROLE_CHANGELING_MIDROUND
	player_mind.add_antag_datum(/datum/antagonist/changeling/space)
	SEND_SOUND(new_changeling, 'sound/magic/mutate.ogg')
	message_admins("[ADMIN_LOOKUPFLW(new_changeling)] has been made into a space changeling by an event.")
	new_changeling.log_message("was spawned as a midround space changeling by an event.", LOG_GAME)

	var/datum/antagonist/changeling/changeling_datum = locate() in player_mind.antag_datums
	changeling_datum.give_power(/datum/action/changeling/suit/organic_space_suit)
	changeling_datum.give_power(/datum/action/changeling/weapon/arm_blade)
	new_changeling.equipOutfit(/datum/outfit/changeling_space)

	return new_changeling

/obj/effect/meteor/meaty/changeling
	name = "unsettlingly meaty meteor"
	desc = "A tightly packed knit of flesh and skin, pulsating with life."
	icon_state = "changeling"
	heavy = FALSE
	hits = 1 //Instantly splatters apart when it hits anything.
	hitpwr = EXPLODE_LIGHT
	threat = 100
	signature = "xenobiological lifesign" //In the extremely unlikely one-in-a-million chance that one of these gets reported by the stray meteor event

/obj/effect/meteor/meaty/changeling/meteor_effect()
	..()

	for(var/atom/movable/child in contents)
		child.forceMove(get_turf(src))

/obj/effect/meteor/meaty/changeling/ram_turf()
	return //So we don't instantly smash into our occupant upon unloading them.

/obj/effect/meteor/meaty/changeling/shield_defense(obj/machinery/satellite/meteor_shield/defender)
	catapult(defender)
	..()

/obj/effect/meteor/meaty/changeling/handle_stopping() //In the event that we miss the station and reach the z level far end without hitting anything...
	if(dest)
		catapult(dest) //We eject the stored changeling and hurl them in the direction of their target turf.
	else
		var/obj/effect/landmark/observer_start/backup_target = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
		catapult(backup_target)
	..()

/**
 * Launches the meteor contents at the meteor destination atom.
 *
 * Performs an emergency ejection of the meteor's contents, launching them towards the meteor destination atom.
 * If the turf is gone, we pick a new emergency location to send them towards. Used to ensure the changeling is still
 * able to play the game if the meteor encounters an issue.
 *
 * Arguments:
 * * target - The thing we're launching our contents towards.
 */

/obj/effect/meteor/meaty/changeling/proc/catapult(atom/target)
	for(var/atom/movable/child in contents)
		child.forceMove(get_turf(src))
		child.throw_at(target, 2, 2, force = MOVE_FORCE_STRONG)
		to_chat(child, span_changeling("Sensing that something is terribly wrong, we forcibly eject ourselves from the [name]!"))
