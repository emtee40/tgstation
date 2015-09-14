/obj/effect/proc_holder/spell/proc/check_frosty(mob/living/carbon/human/H)
	. = FALSE
	if(!H||!istype(H))
		return
	if(H.dna.species.id == "frost_scion_t" && is_scion(H))
		return TRUE
	if(is_scion(H))
		src << "<span class='warning'>This spell requires more power than available to you while disguised.</span>"
		return
	src << "<span class='warning'>This spell is beyond your limited knowledge of the Kingdom of Frost.</span>"

/obj/item/weapon/melee/touch_attack/frosty
	catchphrase = null
	icon = 'icons/obj/frosty.dmi'

/obj/effect/proc_holder/spell/aoe_turf/spread_frost
	name = "Spread Frost"
	desc = "Forms a slowly-spreading layer of frost on the ground beneath your feet."
	panel = "Scion Abilities"
	charge_max = 100
	clothes_req = 0
	range = 0
	action_icon_state = "frost"

/obj/effect/proc_holder/spell/aoe_turf/spread_frost/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	for(var/turf/T in targets)
		if(locate(/obj/structure/alien/weeds/frost/node) in T.contents)
			user << "<span class='warning'>There is already thick frost here!</span>"
			return 0
		new /obj/structure/alien/weeds/frost/node(T)
	user.visible_message("<span class='notice'>[user] has formed some thick frost!</span>")
	return 1

/obj/effect/proc_holder/spell/targeted/chilling_grasp
	name = "Chilling Grasp"
	desc = "Allows you to turn a conscious, non-braindead, non-catatonic human to a pawn of the Kingdom. This takes some time to cast and requires that the target is not wearing a jumpsuit."
	panel = "Scion Abilities"
	charge_max = 0
	clothes_req = 0
	range = 1 //Adjacent to user
	action_icon_state = "chill"
	var/turning = 0


/obj/effect/proc_holder/spell/targeted/chilling_grasp/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	listclearnulls(ticker.mode.frost_scions)
	if(!(user.mind in ticker.mode.frost_scions))
		return
	/*
	if(user.dna.species.id != "shadowling")
		if(ticker.mode.thralls.len >= 5)
			user << "<span class='warning'>With your telepathic abilities suppressed, your human form will not allow you to enthrall any others. Hatch first.</span>"
			charge_counter = charge_max
			return
	*/
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(usr, target))
			user << "<span class='warning'>You need to be closer to turn [target].</span>"
			charge_counter = charge_max
			return
		if(!target.key || !target.mind)
			user << "<span class='warning'>The target has no mind.</span>"
			charge_counter = charge_max
			return
		if(target.stat)
			user << "<span class='warning'>The target must be conscious.</span>"
			charge_counter = charge_max
			return
		if(is_frosty(target))
			user << "<span class='warning'>You can not turn allies.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			user << "<span class='warning'>You can only turn humans.</span>"
			charge_counter = charge_max
			return
		if(turning)
			user << "<span class='warning'>You are already turning someone!</span>"
			charge_counter = charge_max
			return
		if(!target.client)
			user << "<span class='warning'>[target]'s mind is vacant of activity.</span>"
			return
		turning = 1
		user << "<span class='danger'>This target is valid. You begin the turning.</span>"
		target << "<span class='userdanger'>[user] places \his hand on your chest. You begin to feel cooler.</span>"

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					user << "<span class='notice'>You begin preparing yourself for the turning.</span>"
					user.visible_message("<span class='warning'>Tendrils of frost begin running up [user]'s arm.</span>")
				if(2)
					user << "<span class='notice'>You begin the turning of [target].</span>"
					user.visible_message("<span class='danger'>[user] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>")
					target << "<span class='boldannounce'>Your whole body begins to feel cold, radiating from your chest. You fall to the floor as your heart begins to slow.</span>"
					target.Weaken(12)
					sleep(20)
					if(isloyal(target))
						user << "<span class='notice'>They are enslaved by Nanotrasen. You begin to freeze the nanobot implant - this will take some time.</span>"
						user.visible_message("<span class='danger'>[user] halts for a moment, then begins passing its hand over [target]'s body.</span>")
						target << "<span class='boldannounce'>You feel your loyalties begin to weaken!</span>"
						sleep(150) //15 seconds - not spawn() so the turning takes longer
						user << "<span class='notice'>The nanobots composing the loyalty implant have been frozen solid. Now to continue.</span>"
						user.visible_message("<span class='danger'>[user] halts their hand and places it back on [target]'s chest.</span>")
						for(var/obj/item/weapon/implant/loyalty/L in target)
							if(L && L.implanted)
								qdel(L)
								target << "<span class='boldannounce'>Your unwavering loyalty to Nanotrasen unexpectedly falters, dims, dies.</span>"
				if(3)
					user << "<span class='notice'>[target]'s internal temperature is minimal. You begin freezing each of [target]'s cells.</span>"
					user.visible_message("<span class='danger'>[user]'s eyes turn completely white.</span>")
					target << "<span class='boldannounce'>Your entire body is numb. You feel nothing but [user]'s hand on your chest, even colder than you.</span>"
			if(!do_mob(user, target, 100)) //around 30 seconds total for turning, 45 for someone with a loyalty implant
				user << "<span class='warning'>The turning has been interrupted - [target] is once again heating \himself internally.</span>"
				target << "<span class='userdanger'>You suddenly feel your heratbeat speeding up as you start to warm yourself again.</span>"
				turning = 0
				return 0

		turning = 0
		usr << "<span class='notice'>You have turned <b>[target]</b>!</span>"
		target.visible_message("<span class='big'>[target] looks to have been frozen solid!</span>", \
							   "<span class='warning'>Your heart stops.</b></span>")
		target.setOxyLoss(0) //In case the scion was choking them out
		ticker.mode.make_pawn(target.mind)
		target.mind.special_role = "FrostPawn"
		return 1

/obj/effect/proc_holder/spell/targeted/scion_transform
	name = "Transform"
	desc = "Rids you of your human disguise and unleashes your true potential as a Scion of the Kingdom."
	panel = "Scion Abilities"
	charge_max = 3000
	range = -1
	include_user = 1
	clothes_req = 0
	icon_state = "frosty_transform"

/obj/effect/proc_holder/spell/targeted/scion_transform/cast()
	if(usr.stat || !ishuman(usr) || !usr || !is_scion(usr))
		charge_counter = charge_max
		return
	var/mob/living/carbon/human/H = usr
	//TODO: balance shit kinda like s-ling has
	ticker.mode.transform_scion(H)
	hardset_dna(H, mrace = /datum/species/frosty/scion/transformed)

/obj/effect/proc_holder/spell/aoe_turf/freeze_area
	name = "Freeze Area"
	desc = "Quickly lowers the temperature of the area around you."
	panel = "Scion Abilities"
	charge_max = 300
	clothes_req = 0
	range = 1
	action_icon_state = "frosty_freeze"
	var/temperature_delta = 80 //degrees K

/obj/effect/proc_holder/spell/aoe_turf/freeze_area/cast(list/targets)
	for(var/turf/simulated/T in targets)
		T.air.temperature = max(T.air.temperature - temperature_delta, TCMB) //TCMB is the same temperature value used by space tiles
	//TODO: feedback
	return 1

/obj/effect/proc_holder/spell/targeted/touch/frostbite
	name = "Frostbite"
	desc = "Purges cold-resistant mutations and chemicals from your target. Inflicts cold damage if the target is void of cold-resistant effects."

	hand_path = "obj/item/weapon/melee/touch_attack/frosty/frostbite"

	panel = "Scion Abilities"
	charge_max = 300
	clothes_req = 0
	icon_state = "frostbite"

/obj/effect/proc_holder/spell/targeted/touch/frostbite/cast()
	if(!check_frosty(src))
		return 0
	..()

/obj/item/weapon/melee/touch_attack/frosty/frostbite
	name = "\improper freezing hand"
	desc = "My hand is completely frozen."

	icon_state = "frostbite"

	var/base_dmg = 20
	var/base_temp = -100

/obj/item/weapon/melee/touch_attack/frosty/frostbite/afterattack(mob/living/carbon/human/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !istype(target) || !istype(user) || user.lying || user.handcuffed)
		return 0
	if(is_frosty(target))
		return 0
	var/affected = 0
	if(target.dna.check_mutation(COLDRES))
		target.dna.remove_mutation(COLDRES)
		affected++
	if(target.reagents.has_reagent("inaprovaline"))
		target.reagents.del_reagent("inaprovaline")
		affected++
	var/damageToAfflict = base_dmg - ((affected*0.5)*base_dmg) //does no damage if we removed two effects; half damage if we removed one effect; max damage if we removed none
	target.apply_damage(damageToAfflict, COLD)

	var/temperatureToAfflict = base_temp - ((affected*0.5)*base_dmg)
	target.bodytemperature = max(target.bodytemperature - temperatureToAfflict, TCMB)
	//TODO: feedback
	return 1

/obj/effect/proc_holder/spell/aoe_turf/extinguish
	name = "Extinguish"
	desc = "Quenches nearby fires."
	panel = "Scion Abilities"
	charge_max = 600
	clothes_req = 0
	range = 0

/obj/effect/proc_holder/spell/aoe_turf/extinguish/cast(list/targets)
	for(var/turf/simulated/T in targets)
		new /obj/effect/nanofrost_container/frosty(T)
	//TODO: logging, feedback

/obj/effect/nanofrost_container/frosty //nanofrost does everything we want for this ability, so why not just spawn one?
	name = "Ball of ice" //TODO: decent fluff
	desc = "blah blah blah magic blah blah cold"
	residue_name = "frozen residue"
	residue_desc = "residue of magic cold ball thing"

/obj/effect/proc_holder/spell/targeted/touch/refreeze
	name = "Re-Freeze"
	desc = "Cools and heals an ally."
	panel = "Scion Abilities"
	charge_max = 100
	clothes_req = 0
	hand_path = "/obj/item/weapon/melee/touch_attack/frosty/re_freeze"

/obj/effect/proc_holder/spell/targeted/touch/refreeze/cast()
	if(!check_frosty(src))
		return 0
	..()

/obj/item/weapon/melee/touch_attack/frosty/refreeze
	name = "\improper re-freezing touch"
	desc = "My hand is cool to the touch."

	icon_state = "refreeze"

	var/base_dmg = 30 //because of coldmod, this heals our allies
	var/temperature_delta = 40

/obj/item/weapon/melee/touch_attack/frosty/refreeze/afterattack(mob/living/carbon/human/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !istype(target) || !istype(user) || user.lying || user.handcuffed)
		return 0
	if(!is_frosty(target))
		return 0

	target.apply_damage(base_dmg/*, COLD*/)
	target.bodytemperature = max(target.bodytemperature - temperature_delta, TCMB)

	//TODO: logging, feedback