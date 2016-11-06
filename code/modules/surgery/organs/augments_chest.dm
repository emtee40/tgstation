/obj/item/organ/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso"
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = "chest"

/obj/item/organ/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = "stomach"
	origin_tech = "materials=2;powerstorage=2;biotech=2"

/obj/item/organ/cyberimp/chest/nutriment/on_life()
	if(synthesizing)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		owner << "<span class='notice'>You feel less hungry...</span>"
		owner.nutrition += 50
		sleep(50)
		synthesizing = FALSE

/obj/item/organ/cyberimp/chest/nutriment/emp_act(severity)
	if(!owner)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	owner << "<span class='warning'>You feel like your insides are burning.</span>"


/obj/item/organ/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"

/obj/item/organ/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=5;programming=4;biotech=4"
	slot = "heartdrive"
	var/revive_cost = 0
	var/reviving = 0
	var/cooldown = 0

/obj/item/organ/cyberimp/chest/reviver/on_life()
	if(reviving)
		if(owner.stat == UNCONSCIOUS)
			addtimer(src, "heal", 30)
		else
			cooldown = revive_cost + world.time
			reviving = FALSE
		return

	if(cooldown > world.time)
		return
	if(owner.stat != UNCONSCIOUS)
		return
	if(owner.suiciding)
		return

	revive_cost = 0
	reviving = TRUE

/obj/item/organ/cyberimp/chest/reviver/proc/heal()
	if(prob(90) && owner.getOxyLoss())
		owner.adjustOxyLoss(-3)
		revive_cost += 5
	if(prob(75) && owner.getBruteLoss())
		owner.adjustBruteLoss(-1)
		revive_cost += 20
	if(prob(75) && owner.getFireLoss())
		owner.adjustFireLoss(-1)
		revive_cost += 20
	if(prob(40) && owner.getToxLoss())
		owner.adjustToxLoss(-1)
		revive_cost += 50

/obj/item/organ/cyberimp/chest/reviver/emp_act(severity)
	if(!owner)
		return

	if(reviving)
		revive_cost += 200
	else
		cooldown += 200

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.heart_attack = TRUE
			addtimer(src, "undo_heart_attack", 600 / severity)

/obj/item/organ/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.heart_attack = FALSE
	if(H.stat == CONSCIOUS)
		H << "<span class='notice'>You feel your heart beating again!</span>"


/obj/item/organ/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpack, this device has no stablilzation system."
	slot = "thrusters"
	icon_state = "imp_jetpack"
	origin_tech = "materials=4;magnets=4;biotech=4;engineering=5"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = 3
	var/on = 0
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/organ/cyberimp/chest/thrusters/Insert(mob/living/carbon/M, special = 0)
	..()
	if(!ion_trail)
		ion_trail = new
	ion_trail.set_up(M)

/obj/item/organ/cyberimp/chest/thrusters/Remove(mob/living/carbon/M, special = 0)
	if(on)
		toggle(silent=1)
	..()

/obj/item/organ/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/cyberimp/chest/thrusters/proc/toggle(silent=0)
	if(!on)
		if(crit_fail)
			if(!silent)
				owner << "<span class='warning'>Your thrusters set seems to be broken!</span>"
			return 0
		on = 1
		if(allow_thrust(0.01))
			ion_trail.start()
			if(!silent)
				owner << "<span class='notice'>You turn your thrusters set on.</span>"
	else
		ion_trail.stop()
		if(!silent)
			owner << "<span class='notice'>You turn your thrusters set off.</span>"
		on = 0
	update_icon()

/obj/item/organ/cyberimp/chest/thrusters/update_icon()
	if(on)
		icon_state = "imp_jetpack-on"
	else
		icon_state = "imp_jetpack"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/cyberimp/chest/thrusters/proc/allow_thrust(num)
	if(!on || !owner)
		return 0

	var/turf/T = get_turf(owner)
	if(!T) // No more runtimes from being stuck in nullspace.
		return 0

	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && environment.return_pressure() > 30)
		return 1

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num*100)
		owner.adjustPlasma(-num*100)
		return 1

	// Priority 3: use internals tank.
	var/obj/item/weapon/tank/I = owner.internal
	if(I && I.air_contents && I.air_contents.total_moles() > num)
		var/datum/gas_mixture/removed = I.air_contents.remove(num)
		if(removed.total_moles() > 0.005)
			T.assume_air(removed)
			return 1
		else
			T.assume_air(removed)

	toggle(silent=1)
	return 0

/obj/item/organ/cyberimp/chest/rocket_arm_ports
	name = "Rocket arms"
	desc = "Please help, I need description."
	icon_state = "chest_implant"
	implant_color = "#AA0000"
	slot = "rocket_arms"
	origin_tech = "materials=2;powerstorage=2;biotech=2"
	actions_types = list(/datum/action/item_action/organ_action/toggle/)
	var active = FALSE
	var/obj/effect/proc_holder/rocket_arms_ability/ability = new

/obj/item/organ/cyberimp/chest/rocket_arm_ports/Insert(mob/living/carbon/M, special = 0)
	..()
	active = FALSE

/obj/item/organ/cyberimp/chest/rocket_arm_ports/Remove(mob/living/carbon/M, special = 0)
	..()
	active = FALSE


/obj/item/organ/cyberimp/chest/rocket_arm_ports/ui_action_click()
 	toggle()

/obj/item/organ/cyberimp/chest/rocket_arm_ports/proc/toggle()
	var/message
	if(active)
		message = "<span class='notice'>You deactivate your arm</span>"
		ability.remove_ranged_ability(message)
	else
		message = "<span class='notice'>You prepare your rocket arm. <B>Left-click to fire at a target!</B></span>"
		ability.add_ranged_ability(owner, message, TRUE)

/obj/item/organ/cyberimp/chest/rocket_arm_ports/proc/fire(target, params)
	if(!owner)
		return 0

	var/obj/item/bodypart/organ = owner.has_hand_for_held_index(owner.active_hand_index)

	// No matter what, disable ability and spark
	active = FALSE
	ability.remove_ranged_ability()

	var/datum/effect_system/spark_spread/S = new
	S.set_up(10,0,owner.loc)
	S.start()

	if(!organ)
		owner << "Your arm socket sparks."
		return 0

	organ.fire_at(target, params)

/obj/effect/proc_holder/rocket_arms_ability/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return

	if(!ishuman(caller) || caller.stat)
		remove_ranged_ability(caller)
		return

	var/mob/living/carbon/human/user = caller

	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE

	user.visible_message("<span class='danger'>[user] fires his arm!", "<span class='alertalien'>You fire your arm!.</span>")

	var/obj/item/organ/cyberimp/chest/rocket_arm_ports/implant = user.getorganslot("rocket_arms")
	if(implant.fire(target, params))
		user.newtonian_move(get_dir(U, T))

	return TRUE
