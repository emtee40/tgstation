/// Adds threats to the list and notifies players
/obj/machinery/quantum_server/proc/add_threats(mob/living/threat)
	spawned_threat_refs.Add(WEAKREF(threat))
	SEND_SIGNAL(src, COMSIG_BITRUNNER_THREAT_CREATED)

/// Choses which antagonist role is spawned based on threat
/obj/machinery/quantum_server/proc/get_antagonist_role()
	var/list/available = list()

	for(var/datum/antagonist/bitrunning_glitch/subtype as anything in subtypesof(/datum/antagonist/bitrunning_glitch))
		if(threat >= initial(subtype.threat))
			available += subtype

	shuffle_inplace(available)
	var/datum/antagonist/bitrunning_glitch/chosen = pick(available)

	threat -= initial(chosen.threat) * 0.5

	return chosen

/// Selects a target to mutate. Gives two attempts, then crashes if it fails.
/obj/machinery/quantum_server/proc/get_mutation_target()
	var/datum/weakref/target_ref = pick(mutation_candidate_refs)
	var/mob/living/resolved = target_ref.resolve()

	if(isnull(resolved))
		mutation_candidate_refs.Remove(target_ref)
		target_ref = pick(mutation_candidate_refs)
		resolved = target_ref.resolve()

	return resolved

/// Finds any mobs with minds in the zones and gives them the bad news
/obj/machinery/quantum_server/proc/notify_spawned_threats()
	for(var/datum/weakref/baddie_ref as anything in spawned_threat_refs)
		var/mob/living/baddie = baddie_ref.resolve()
		if(isnull(baddie) || baddie.stat >= UNCONSCIOUS || isnull(baddie.mind))
			continue

		baddie.throw_alert(
			ALERT_BITRUNNER_RESET,
			/atom/movable/screen/alert/bitrunning/qserver_threat_deletion,
			new_master = src,
		)

		to_chat(baddie, span_userdanger("You have been flagged for deletion! Thank you for your service."))

/// Procedurally links all the spawning procs together.
/obj/machinery/quantum_server/proc/spawn_glitch()
	if(!length(mutation_candidate_refs))
		return

	validate_mutation_candidates()

	var/mob/living/mutation_target = get_mutation_target()
	if(isnull(mutation_target))
		CRASH("vdom: After two attempts, no valid mutation target was found.")

	mutation_target.AddElement(/datum/element/digital_aura)

	var/datum/antagonist/bitrunning_glitch/chosen_role = get_antagonist_role()
	var/role_name = initial(chosen_role.name)

	var/datum/callback/to_call = CALLBACK(src, PROC_REF(poll_concluded), chosen_role, mutation_target)
	mutation_target.AddComponent(/datum/component/orbit_poll, \
		ignore_key = POLL_IGNORE_GLITCH, \
		job_bans = ROLE_GLITCH, \
		to_call = to_call, \
		title = role_name, \
	)

/// Orbit poll has concluded - spawn the antag
/obj/machinery/quantum_server/proc/poll_concluded(datum/antagonist/bitrunning_glitch/chosen_role, mob/living/mutation_target, mob/dead/observer/ghost)
	if(QDELETED(mutation_target))
		return

	if(QDELETED(src) || isnull(ghost) || isnull(generated_domain) || !is_ready || !is_operational)
		mutation_target.RemoveElement(/datum/element/digital_aura)
		return

	var/role_name = initial(chosen_role.name)
	var/mob/living/antag_mob
	switch(role_name)
		if(ROLE_CYBER_BEHEMOTH)
			antag_mob = new /mob/living/basic/cyber_behemoth(mutation_target.loc)
		else // any other humanoid mob
			antag_mob = new /mob/living/carbon/human(mutation_target.loc)

	mutation_target.gib(DROP_ALL_REMAINS)

	antag_mob.key = ghost.key
	var/datum/mind/ghost_mind = antag_mob.mind
	ghost_mind.add_antag_datum(chosen_role)
	ghost_mind.special_role = ROLE_GLITCH
	ghost_mind.set_assigned_role(SSjob.GetJobType(/datum/job/bitrunning_glitch))

	playsound(antag_mob, 'sound/magic/ethereal_exit.ogg', 50, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(antag_mob)] has been made into virtual antagonist by an event.")
	antag_mob.log_message("was spawned as a virtual antagonist by an event.", LOG_GAME)

	add_threats(antag_mob)

/// Spawns a humanoid on the target
/obj/machinery/quantum_server/proc/spawn_antag(mob/living/mutation_target, typepath)
	var/mob/living/new_antag = new typepath(mutation_target.loc)
	mutation_target.gib(DROP_ALL_REMAINS)

	return new_antag

/// Oh boy - transports the antag station side
/obj/machinery/quantum_server/proc/station_spawn(mob/living/antag, obj/machinery/byteforge/chosen_forge)
	chosen_forge.flicker(angry = TRUE)
	radio.talk_into(src, "WARNING: Hostile input signature detected.", RADIO_CHANNEL_SUPPLY)

	var/timeout = ishuman(antag) ? 2 SECONDS : 5 SECONDS
	if(!do_after(antag, timeout))
		return

	chosen_forge.flash()

	antag.AddComponent(/datum/component/glitch, \
		server = src, \
		forge = chosen_forge, \
	)
	if(ishuman(antag))
		reset_equipment(antag)
	else
		radio.talk_into(src, "ERROR: Fabrication protocols have crashed unexpectedly. Evacuate.", RADIO_CHANNEL_COMMON)

	do_teleport(antag, get_turf(chosen_forge), forced = TRUE)

/// Removes any invalid candidates from the list
/obj/machinery/quantum_server/proc/validate_mutation_candidates()
	for(var/datum/weakref/creature_ref as anything in mutation_candidate_refs)
		var/mob/living/creature = creature_ref.resolve()
		if(isnull(creature) || creature.mind)
			mutation_candidate_refs.Remove(creature_ref)

	shuffle_inplace(mutation_candidate_refs)
