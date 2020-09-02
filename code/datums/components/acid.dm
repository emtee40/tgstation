/** Component representing acid applied to an object.
  *
  * Must be attached to an atom.
  * Processes, repeatedly damaging whatever it is attached to.
  * If the parent atom is a turf it applies acid to the contents of the turf.
  */
/datum/component/acid
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The strength of the acid on the parent [/atom].
	var/acid_power
	/// The volume of acid on the parent [/atom].
	var/acid_volume
	/// The maximum volume of acid on the parent [/atom].
	var/max_volume = INFINITY
	/// The ambiant sound of acid eating away at the parent [/atom].
	var/datum/looping_sound/acid/sizzle
	/// Used exclusively for melting turfs. TODO: Move integrity to the atom level so that this can be dealt with there.
	var/parent_integrity = 30
	/// The proc used to handle the parent [/atom] when processing. TODO: Unify damage and resistance flags so that this doesn't need to exist!
	var/datum/callback/process_effect

/datum/component/acid/Initialize(_acid_power, _acid_volume, _max_volume=null)
	if((_acid_power) <= 0 || (_acid_volume <= 0))
		WARNING("Acid component added with insufficient acid power ([_acid_power]) or acid volume ([_acid_power]).")
		return COMPONENT_INCOMPATIBLE // Not enough acid.
	if(!isatom(parent))
		WARNING("Acid component added to [parent] ([parent?.type]) which is not a /atom subtype.")
		return COMPONENT_INCOMPATIBLE // Incompatible type. TODO: Rework take_damage to the atom level and move this there.

	if(isobj(parent))
		var/obj/parent_object = parent
		if(parent_object.resistance_flags & UNACIDABLE) // The parent object cannot have acid.
			WARNING("Acid component added to unacidable object [parent].")
			return COMPONENT_INCOMPATIBLE

		max_volume = OBJ_ACID_VOLUME_MAX
		process_effect = CALLBACK(src, .proc/process_obj, parent)
	else if(isliving(parent))
		max_volume = MOB_ACID_VOLUME_MAX
		process_effect = CALLBACK(src, .proc/process_mob, parent)
	else if(isturf(parent))
		max_volume = TURF_ACID_VOLUME_MAX
		process_effect = CALLBACK(src, .proc/process_turf, parent)

	acid_power = _acid_power
	set_volume(_acid_volume)

	var/atom/parent_atom = parent
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/on_update_overlays)
	parent_atom.update_icon()
	sizzle = new(list(parent), TRUE)
	START_PROCESSING(SSacid, src)

/datum/component/acid/Destroy(force, silent)
	STOP_PROCESSING(SSacid, src)
	QDEL_NULL(sizzle)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	if(parent && !QDELING(parent))
		var/atom/parent_atom = parent
		parent_atom.update_icon()
	return ..()

/datum/component/acid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/on_clean)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/on_crossed)

/datum/component/acid/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_ATOM_ATTACK_HAND,
		))

	if(isturf(parent))
		UnregisterSignal(parent, COMSIG_MOVABLE_CROSSED)

/// Averages corrosive power and sums volume.
/datum/component/acid/InheritComponent(datum/component/C, i_am_original, _acid_power, _acid_volume)
	acid_power = ((acid_power * acid_volume) + (_acid_power * _acid_volume)) / (acid_volume + _acid_volume)
	set_volume(acid_volume + _acid_volume)

/// Sets the acid volume to a new value. Limits the acid volume by the amount allowed to exist on the parent atom.
/datum/component/acid/proc/set_volume(new_volume)
	acid_volume = clamp(new_volume, 0, max_volume)
	if(!acid_volume)
		qdel(src)


/// Handles the slow corrosion of the parent [/atom].
/datum/component/acid/process()
	process_effect?.InvokeAsync()
	set_volume(acid_volume - (ACID_DECAY_BASE + (ACID_DECAY_SCALING*round(sqrt(acid_volume)))))

/// Handles processing on a [/obj].
/datum/component/acid/proc/process_obj(obj/target)
	if(target.resistance_flags & ACID_PROOF)
		return
	target.take_damage(min(1 + round(sqrt(acid_power * acid_volume)*0.3), OBJ_ACID_DAMAGE_MAX), BURN, ACID, 0)

/// Handles processing on a [/mob/living].
/datum/component/acid/proc/process_mob(mob/living/target)
	target.acid_act(acid_power, acid_volume)

/// Handles processing on a [/turf].
/datum/component/acid/proc/process_turf(turf/target)
	var/turf/T = parent
	var/acid_used = min(acid_volume * 0.05, 20)
	var/applied_targets = 0
	for(var/A in T)
		var/atom/acid_target = A
		acid_target.acid_act(acid_power, acid_used)
		applied_targets++

	set_volume(acid_volume - (acid_used * applied_targets))

	// Snowflake code for handling acid melting walls. TODO: Move integrity handling to the atom level so this can be desnowflaked.
	if(acid_power < ACID_POWER_MELT_TURF)
		return

	switch(parent_integrity--)
		if(-INFINITY to 0)
			T.visible_message("<span class='warning'>[T] collapses under its own weight into a puddle of goop and undigested debris!</span>")
			T.acid_melt()
		if(0 to 4)
			T.visible_message("<span class='warning'>[T] begins to crumble under the acid!</span>")
		if(4 to 8)
			T.visible_message("<span class='warning'>[T] is struggling to withstand the acid!</span>")
		if(8 to 16)
			T.visible_message("<span class='warning'>[T] is being melted by the acid!</span>")
		if(16 to 24)
			T.visible_message("<span class='warning'>[T] is holding up against the acid!</span>")


/// Used to maintain the acid overlay on the parent [/atom].
/datum/component/acid/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	overlays += mutable_appearance('icons/effects/acid.dmi', parent_atom.custom_acid_overlay || ACID_OVERLAY_DEFAULT)

/// Alerts any examiners to the acid on the parent atom.
/datum/component/acid/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += "<span class='danger'>[A.p_theyre()] covered in corrosive liquid!</span>"

/// Makes it possible to clean acid off of objects.
/datum/component/acid/proc/on_clean(atom/A, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_ACID))
		return NONE
	qdel(src)
	return TRUE // I know that returning booleans is bad form but this is how the proc handles it.

/// Handles searing the hand of anyone who tries to touch this without protection.
/datum/component/acid/proc/on_attack_hand(atom/parent_atom, mob/living/carbon/user)
	SIGNAL_HANDLER

	if(!istype(user))
		return NONE
	if((parent_atom == user) || (parent_atom.loc == user))
		return NONE // So we people can take their own clothes off.
	if((acid_power * acid_volume) < ACID_LEVEL_HANDBURN)
		return NONE
	if(user.gloves?.resistance_flags & (UNACIDABLE|ACID_PROOF))
		return NONE

	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	if(!affecting?.receive_damage(0, 5))
		return NONE

	to_chat(user, "<span class='warning'>The acid on \the [parent_atom] burns your hand!</span>")
	playsound(parent_atom, 'sound/weapons/sear.ogg', 50, TRUE)
	user.update_damage_overlays()
	return COMPONENT_NO_ATTACK_HAND

/// Handles searing the feet of whoever walks over this without protection. Only active if the parent is a turf.
/datum/component/acid/proc/on_crossed(atom/parent_atom, mob/living/crosser)
	SIGNAL_HANDLER

	if(!isliving(crosser))
		return
	if(crosser.movement_type & FLYING)
		return
	if(crosser.m_intent & MOVE_INTENT_WALK)
		return
	if(prob(60))
		return

	var/acid_used = min(acid_volume * 0.05, 20)
	if(crosser.acid_act(acid_power, acid_used, FEET))
		playsound(crosser, 'sound/weapons/sear.ogg', 50, TRUE)
		to_chat(crosser, "<span class='userdanger'>The acid on the [parent] burns you!</span>")
		set_volume(max(acid_volume - acid_used, 10))
