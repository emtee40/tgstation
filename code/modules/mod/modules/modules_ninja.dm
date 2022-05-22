//Ninja modules for MODsuits

///Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A complete retrofitting of the suit, this is a form of visual concealment tech employing esoteric technology \
		to bend light around the user, as well as mimetic materials to make the surface of the suit match the \
		surroundings based off sensor data. For some reason, this tech is rarely seen."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CHARGE_DRAIN * 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, .proc/unstealth)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_unarmed_attack)
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(mod.wearer, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), .proc/unstealth)
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	on_deactivation(display_message = TRUE, deleting = FALSE)

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.nodamage)
		return
	unstealth(source)

//Advanced Cloaking - Doesn't turf off on bump, less power drain, more stealthy.
/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "The latest in stealth technology, this module is a definite upgrade over previous versions. \
		The field has been tuned to be even more responsive and fast-acting, with enough stability to \
		continue operation of the field even if the user bumps into others. \
		The power draw has been reduced drastically, making this perfect for activities like \
		standing near sentry turrets for extended periods of time."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = DEFAULT_CHARGE_DRAIN
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 3 SECONDS

///Camera Vision - Prevents flashes, blocks tracking.
/obj/item/mod/module/welding/camera_vision
	name = "MOD camera vision module"
	desc = "A module installed into the suit's helmet. This replaces the standard visor with a set of camera eyes, \
		which protect from bright flashes as well as using special track-blocking technology. Become the unseen."
	removable = FALSE
	complexity = 0
	overlay_state_inactive = null

/obj/item/mod/module/welding/camera_vision/on_suit_activation()
	. = ..()
	RegisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK, .proc/can_track)

/obj/item/mod/module/welding/camera_vision/on_suit_deactivation(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK)

/obj/item/mod/module/welding/camera_vision/proc/can_track(datum/source, mob/user)
	SIGNAL_HANDLER

	return COMPONENT_CANT_TRACK

//Ninja Star Dispenser - Dispenses ninja stars.
/obj/item/mod/module/dispenser/ninja
	name = "MOD ninja star dispenser module"
	desc = "This piece of Spider Clan technology can immediately print a ninja-star using pure electricity."
	dispense_type = /obj/item/throwing_star/stamina/ninja
	cooldown_time = 0.5 SECONDS

///Hacker - This module hooks onto your right-clicks with empty hands and causes ninja actions.
/obj/item/mod/module/hacker
	name = "MOD hacker module"
	desc = "This piece of Spider Clan technology hooks into the internal electronics of a machine to hack it. \
		It can also zap people with electricity on disarming attacks."
	icon_state = "hacker"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/hacker)
	/// Whether or not we're currently draining something
	var/draining = FALSE
	/// Minimum amount of power we can drain in a single drain action
	var/mindrain = 200
	/// Maximum amount of power we can drain in a single drain action
	var/maxdrain = 400
	/// Whether or not the communication console hack was used to summon another antagonist.
	var/communication_console_hack_success = FALSE
	/// How many times the module has been used to force open doors.
	var/door_hack_counter = 0

/obj/item/mod/module/hacker/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/hack)

/obj/item/mod/module/hacker/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/mod/module/hacker/proc/hack(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || draining || !proximity)
		return NONE
	target.add_fingerprint(mod.wearer)
	draining = TRUE
	var/drain_amount = target.ninjadrain_act(mod, mod.wearer, src)
	draining = FALSE
	if(isnum(drain_amount)) //Numerical values of drained handle their feedback here, Alpha values handle it themselves (Research hacking)
		if(drain_amount)
			to_chat(mod.wearer, span_notice("Gained <B>[display_energy(drain_amount)]</B> of energy from [target]."))
		else
			to_chat(mod.wearer, span_warning("[target] has run dry of energy, you must find another source!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	else
		return NONE

///Weapon Recall - Teleports your katana to you, prevents gun use.
/obj/item/mod/module/weapon_recall
	name = "MOD weapon recall module"
	desc = "This piece of Spider Clan technology connects to an energy katana that will be recalled \
		to the user when the module is used. To emphasise blade mastery, it prevents the user from using ranged weaponry."
	icon_state = "recall"
	removable = FALSE
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/weapon_recall)
	cooldown_time = 0.5 SECONDS
	/// The item linked to the module that will get recalled.
	var/obj/item/linked_weapon
	/// The accepted typepath we can link to.
	var/accepted_type = /obj/item/energy_katana

/obj/item/mod/module/weapon_recall/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NOGUNS, MOD_TRAIT)

/obj/item/mod/module/weapon_recall/on_suit_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NOGUNS, MOD_TRAIT)

/obj/item/mod/module/weapon_recall/on_use()
	. = ..()
	if(!.)
		return
	if(!linked_weapon)
		var/obj/item/weapon_to_link = mod.wearer.is_holding_item_of_type(accepted_type)
		if(!weapon_to_link)
			balloon_alert(mod.wearer, "can't locate weapon!")
			return
		set_weapon(weapon_to_link)
		balloon_alert(mod.wearer, "[linked_weapon.name] linked")
		return
	if(linked_weapon in mod.wearer.get_all_contents())
		balloon_alert(mod.wearer, "already on self!")
		return
	var/distance = get_dist(mod.wearer, linked_weapon)
	var/in_view = (linked_weapon in view(mod.wearer))
	if(!in_view && !drain_power(use_power_cost * distance * 10))
		return
	linked_weapon.forceMove(linked_weapon.drop_location())
	if(in_view)
		do_sparks(5, FALSE, linked_weapon)
		mod.wearer.visible_message(span_danger("[linked_weapon] flies towards [mod.wearer]!"),span_warning("You hold out your hand and [linked_weapon] flies towards you!"))
		linked_weapon.throw_at(mod.wearer, distance+1, linked_weapon.throw_speed, mod.wearer)
	else
		recall_weapon()

/obj/item/mod/module/weapon_recall/proc/set_weapon(obj/item/weapon)
	linked_weapon = weapon
	RegisterSignal(linked_weapon, COMSIG_MOVABLE_IMPACT, .proc/catch_weapon)
	RegisterSignal(linked_weapon, COMSIG_PARENT_QDELETING, .proc/deleted_weapon)

/obj/item/mod/module/weapon_recall/proc/recall_weapon(caught = FALSE)
	linked_weapon.forceMove(get_turf(src))
	var/alert = ""
	if(mod.wearer.put_in_hands(linked_weapon))
		alert = "[linked_weapon.name] teleports to your hand"
	else if(mod.wearer.equip_to_slot_if_possible(linked_weapon, ITEM_SLOT_BELT, disable_warning = TRUE))
		alert = "[linked_weapon.name] sheathes itself in your belt"
	else
		alert = "[linked_weapon.name] teleports under you"
	if(caught)
		if(mod.wearer.is_holding(linked_weapon))
			alert = "you catch [linked_weapon.name]"
		else
			alert = "[linked_weapon.name] lands under you"
	else
		do_sparks(5, FALSE, linked_weapon)
	if(alert)
		balloon_alert(mod.wearer, alert)

/obj/item/mod/module/weapon_recall/proc/catch_weapon(obj/item/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	if(!mod)
		return
	if(hit_atom != mod.wearer)
		return
	INVOKE_ASYNC(src, .proc/recall_weapon, TRUE)
	return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/obj/item/mod/module/weapon_recall/proc/deleted_weapon(obj/item/source)
	SIGNAL_HANDLER

	linked_weapon = null

//Reinforced DNA Lock - Gibs if wrong DNA, emp-proof.
/obj/item/mod/module/dna_lock/reinforced
	name = "MOD reinforced DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		due to its' reinforcements this one cannot be shorted by EMPs, it also reacts in a special way to incompatible DNAs."
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5

/obj/item/mod/module/dna_lock/reinforced/dna_check(mob/user)
	. = ..()
	if(.)
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	to_chat(carbon_user, span_danger("<B>fATaL EERRoR</B>: 382200-*#00CODE <B>RED</B>\nUNAUTHORIZED USE DETECteD\nCoMMENCING SUB-R0UTIN3 13...\nTERMInATING U-U-USER..."))
	carbon_user.gib()

/obj/item/mod/module/dna_lock/reinforced/on_emp(datum/source, severity)
	return

//EMP Pulse - In addition to normal shielding, can also launch an EMP itself.
/obj/item/mod/module/emp_shield/pulse
	name = "MOD EMP pulse module"
	desc = "This modification to the EMP shield lets it \"launch\" it's electromagnetic field inhibitor, causing an EMP of it's own."
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	cooldown_time = 8 SECONDS

/obj/item/mod/module/emp_shield/pulse/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/effects/empulse.ogg', 60, TRUE)
	empulse(src, heavy_range = 4, light_range = 6)
	drain_power(use_power_cost)

///Status Readout - Puts a lot of information including health, nutrition, fingerprints, temperature to the suit TGUI.
/obj/item/mod/module/status_readout
	name = "MOD status readout module"
	desc = "A module installed into the suit's spine. It reads out all information the user needs at all times."
	icon_state = "status"
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/status_readout)
	tgui_id = "status_readout"

/obj/item/mod/module/status_readout/add_ui_data()
	. = ..()
	.["statustime"] = station_time_timestamp()
	.["statusid"] = GLOB.round_id
	.["statushealth"] = mod.wearer ? mod.wearer.health : 0
	.["statusmaxhealth"] = mod.wearer ? mod.wearer.getMaxHealth() : 0
	.["statusbrute"] = mod.wearer ? mod.wearer.getBruteLoss() : 0
	.["statusburn"] = mod.wearer ? mod.wearer.getFireLoss() : 0
	.["statustoxin"] = mod.wearer ? mod.wearer.getToxLoss() : 0
	.["statusoxy"] = mod.wearer ? mod.wearer.getOxyLoss() : 0
	.["statustemp"] = mod.wearer ? mod.wearer.bodytemperature : 0
	.["statusnutrition"] = mod.wearer ? mod.wearer.nutrition : 0
	.["statusfingerprints"] = mod.wearer ? md5(mod.wearer.dna.unique_identity) : null
	.["statusdna"] = mod.wearer ? mod.wearer.dna.unique_enzymes : null
	.["statusviruses"] = null
	if(!length(mod.wearer?.diseases))
		return
	var/list/viruses = list()
	for(var/datum/disease/virus as anything in mod.wearer.diseases)
		var/list/virus_data = list()
		virus_data["name"] = virus.name
		virus_data["type"] = virus.spread_text
		virus_data["stage"] = virus.stage
		virus_data["maxstage"] = virus.max_stages
		virus_data["cure"] = virus.cure_text
		viruses += list(virus_data)
	.["statusviruses"] = viruses

///Energy Net - Ensnares enemies in a net that prevents movement.
/obj/item/mod/module/energy_net
	name = "MOD energy net module"
	desc = "A custom-built energy net launcher that ensnares targets, preventing them from moving."
	icon_state = "energy_net"
	removable = FALSE
	module_type = MODULE_ACTIVE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 6
	incompatible_modules = list(/obj/item/mod/module/energy_net)
	cooldown_time = 1.5 SECONDS

/obj/item/mod/module/energy_net/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		balloon_alert(mod.wearer, "invalid target!")
		return
	var/mob/living/living_target = target
	if(locate(/obj/structure/energy_net) in get_turf(living_target))
		balloon_alert(mod.wearer, "already trapped!")
		return
	for(var/turf/between_turf as anything in get_line(get_turf(mod.wearer), get_turf(living_target)))
		if(between_turf.density)
			balloon_alert(mod.wearer, "not through obstacles!")
			return
	mod.wearer.Beam(living_target, "n_beam", time = 1.5 SECONDS)
	mod.wearer.say("Get over here!", forced = type)
	var/obj/structure/energy_net/net = new /obj/structure/energy_net(living_target.drop_location())
	net.affected_mob = living_target
	mod.wearer.visible_message(span_danger("[mod.wearer] caught [living_target] with an energy net!"), span_notice("You caught [living_target] with an energy net!"))
	if(living_target.buckled)
		living_target.buckled.unbuckle_mob(living_target, force = TRUE)
	net.buckle_mob(living_target, force = TRUE)
	drain_power(use_power_cost)

///Adrenaline Boost - Stops all stuns the ninja is affected with, increases his speed.
/obj/item/mod/module/adrenaline_boost
	name = "MOD adrenaline boost module"
	desc = "Injects a secret chemical concoction into the user, stopping all immobilizations. Needs to be refilled with radium."
	icon_state = "adrenaline_boost"
	removable = FALSE
	module_type = MODULE_USABLE
	incompatible_modules = list(/obj/item/mod/module/adrenaline_boost)
	cooldown_time = 12 SECONDS
	/// What reagent we need to refill?
	var/reagent_required = /datum/reagent/uranium/radium
	/// How much of a reagent we need to refill the boost.
	var/reagent_required_amount = 20
	/// Do we have a boost charge?
	var/charged = TRUE

/obj/item/mod/module/adrenaline_boost/on_use()
	. = ..()
	if(!.)
		return
	if(!charged)
		balloon_alert(mod.wearer, "no charge!")
		return
	mod.wearer.SetUnconscious(0)
	mod.wearer.SetStun(0)
	mod.wearer.SetKnockdown(0)
	mod.wearer.SetImmobilized(0)
	mod.wearer.SetParalyzed(0)
	mod.wearer.adjustStaminaLoss(-200)
	mod.wearer.remove_status_effect(/datum/status_effect/speech/stutter)
	mod.wearer.reagents.add_reagent(/datum/reagent/medicine/stimulants, 5)
	mod.wearer.say(pick_list_replacements(NINJA_FILE, "lines"), forced = type)
	charged = FALSE
	addtimer(CALLBACK(src, .proc/boost_aftereffects, mod.wearer), 7 SECONDS)

/obj/item/mod/module/adrenaline_boost/on_install()
	RegisterSignal(mod, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

/obj/item/mod/module/adrenaline_boost/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_PARENT_ATTACKBY)

/obj/item/mod/module/adrenaline_boost/attackby(obj/item/attacking_item, mob/user, params)
	if(charge_boost(attacking_item, user))
		return TRUE
	return ..()

/obj/item/mod/module/adrenaline_boost/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER

	if(charge_boost(attacking_item, user))
		return COMPONENT_NO_AFTERATTACK
	return NONE

/obj/item/mod/module/adrenaline_boost/proc/charge_boost(obj/item/attacking_item, mob/user)
	if(!istype(attacking_item, /obj/item/reagent_containers/glass))
		return FALSE
	if(!attacking_item.reagents.has_reagent(reagent_required, reagent_required_amount))
		return FALSE
	if(charged)
		balloon_alert(mod.wearer, "already charged!")
		return FALSE
	attacking_item.reagents.remove_reagent(/datum/reagent/uranium/radium, reagent_required_amount)
	charged = TRUE
	balloon_alert(mod.wearer, "charge reloaded")
	return TRUE

/obj/item/mod/module/adrenaline_boost/proc/boost_aftereffects(mob/affected_mob)
	if(!affected_mob)
		return
	affected_mob.reagents.add_reagent(reagent_required, reagent_required_amount * 0.25)
	to_chat(affected_mob, span_danger("You are beginning to feel the after-effect of the injection."))
