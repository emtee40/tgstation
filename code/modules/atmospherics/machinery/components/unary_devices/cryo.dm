#define CRYOMOBS 'icons/obj/cryo_mobs.dmi'
///Max temperature allowed inside the cryotube, should break before reaching this heat
#define MAX_TEMPERATURE 4000

/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-off"
	density = TRUE
	max_integrity = 350
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 30, ACID = 30)
	layer = ABOVE_WINDOW_LAYER
	state_open = FALSE
	circuit = /obj/item/circuitboard/machine/cryo_tube
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	occupant_typecache = list(/mob/living/carbon, /mob/living/simple_animal)
	processing_flags = NONE

	var/autoeject = TRUE
	var/volume = 100

	var/efficiency = 1
	var/sleep_factor = 0.00125
	var/unconscious_factor = 0.001
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.3

	var/obj/item/reagent_containers/glass/beaker = null
	var/reagent_transfer = 0

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	var/running_anim = FALSE

	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300
	///Cryo will continue to treat people with 0 damage but existing wounds, but will sound off when damage healing is done in case doctors want to directly treat the wounds instead
	var/treating_wounds = FALSE
	fair_market_price = 10
	payment_department = ACCOUNT_MED


/obj/machinery/atmospherics/components/unary/cryo_cell/Initialize()
	. = ..()
	initialize_directions = dir
	if(is_operational)
		begin_processing()

	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/machinery/atmospherics/components/unary/cryo_cell/Exited(atom/movable/AM, atom/newloc)
	var/oldoccupant = get_occupant()
	. = ..() // Parent proc takes care of removing occupant if necessary
	if (AM == oldoccupant)
		update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		C += M.rating

	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	unconscious_factor = initial(unconscious_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user) //this is leaving out everything but efficiency since they follow the same idea of "better beaker, better results"
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Efficiency at <b>[efficiency*100]%</b>.</span>"

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(beaker)
	///Take the turf the cryotube is on
	var/turf/T = get_turf(src)
	if(T)
		///Take the air composition of the turf
		var/datum/gas_mixture/env = T.return_air()
		///Take the air composition inside the cryotube
		var/datum/gas_mixture/air1 = airs[1]
		env.merge(air1)
		T.air_update_turf()

	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker

/obj/machinery/atmospherics/components/unary/cryo_cell/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		updateUsrDialog()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_deconstruction()
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()

	cut_overlays()

	if(panel_open)
		add_overlay("pod-panel")

	if(state_open)
		icon_state = "pod-open"
		return

	if(get_occupant())
		var/image/occupant_overlay

		if(ismonkey(get_occupant())) // Monkey
			occupant_overlay = image(CRYOMOBS, "monkey")
		else if(isalienadult(get_occupant()))
			if(isalienroyal(get_occupant())) // Queen and prae
				occupant_overlay = image(CRYOMOBS, "alienq")
			else if(isalienhunter(get_occupant())) // Hunter
				occupant_overlay = image(CRYOMOBS, "alienh")
			else if(isaliensentinel(get_occupant())) // Sentinel
				occupant_overlay = image(CRYOMOBS, "aliens")
			else // Drone or other
				occupant_overlay = image(CRYOMOBS, "aliend")

		else if(ishuman(get_occupant()) || islarva(get_occupant()) || (isanimal(get_occupant()) && !ismegafauna(get_occupant()))) // Mobs that are smaller than cryotube
			occupant_overlay = image(get_occupant().icon, get_occupant().icon_state)
			occupant_overlay.copy_overlays(get_occupant())

		else
			occupant_overlay = image(CRYOMOBS, "generic")

		occupant_overlay.dir = SOUTH
		occupant_overlay.pixel_y = 22

		if(on && !running_anim && is_operational)
			icon_state = "pod-on"
			running_anim = TRUE
			run_anim(TRUE, occupant_overlay)
		else
			icon_state = "pod-off"
			add_overlay(occupant_overlay)
			add_overlay("cover-off")

	else if(on && is_operational)
		icon_state = "pod-on"
		add_overlay("cover-on")
	else
		icon_state = "pod-off"
		add_overlay("cover-off")

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/run_anim(anim_up, image/occupant_overlay)
	if(!on || !get_occupant() || !is_operational)
		running_anim = FALSE
		return
	cut_overlays()
	if(occupant_overlay.pixel_y != 23) // Same effect as occupant_overlay.pixel_y == 22 || occupant_overlay.pixel_y == 24
		anim_up = occupant_overlay.pixel_y == 22 // Same effect as if(occupant_overlay.pixel_y == 22) anim_up = TRUE ; if(occupant_overlay.pixel_y == 24) anim_up = FALSE
	if(anim_up)
		occupant_overlay.pixel_y++
	else
		occupant_overlay.pixel_y--
	add_overlay(occupant_overlay)
	add_overlay("cover-on")
	addtimer(CALLBACK(src, .proc/run_anim, anim_up, occupant_overlay), 7, TIMER_UNIQUE)

/obj/machinery/atmospherics/components/unary/cryo_cell/nap_violation(mob/violator)
	open_machine()


/obj/machinery/atmospherics/components/unary/cryo_cell/on_set_is_operational(old_value)
	if(old_value) //Turned off
		on = FALSE
		end_processing()
		update_icon()
	else //Turned on
		begin_processing()


/obj/machinery/atmospherics/components/unary/cryo_cell/process(delta_time)
	..()

	if(!on)
		return
	if(!get_occupant())
		return

	var/mob/living/mob_occupant = get_occupant()
	if(mob_occupant.on_fire)
		mob_occupant.extinguish_mob()
	if(!check_nap_violations())
		return
	if(mob_occupant.stat == DEAD) // We don't bother with dead people.
		return
	if(mob_occupant.get_organic_health() >= mob_occupant.getMaxHealth()) // Don't bother with fully healed people.
		if(iscarbon(mob_occupant))
			var/mob/living/carbon/C = mob_occupant
			if(C.all_wounds)
				if(!treating_wounds) // if we have wounds and haven't already alerted the doctors we're only dealing with the wounds, let them know
					treating_wounds = TRUE
					playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
					var/msg = "Patient vitals fully recovered, continuing automated wound treatment."
					radio.talk_into(src, msg, radio_channel)
			else // otherwise if we were only treating wounds and now we don't have any, turn off treating_wounds so we can boot 'em out
				treating_wounds = FALSE

		if(!treating_wounds)
			on = FALSE
			update_icon()
			playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
			var/msg = "Patient fully restored."
			if(autoeject) // Eject if configured.
				msg += " Auto ejecting patient now."
				open_machine()
			radio.talk_into(src, msg, radio_channel)
			return

	var/datum/gas_mixture/air1 = airs[1]

	if(air1.gases.len)
		if(mob_occupant.bodytemperature < T0C) // Sleepytime. Why? More cryo magic.
			mob_occupant.Sleeping((mob_occupant.bodytemperature * sleep_factor) * 1000 * delta_time)
			mob_occupant.Unconscious((mob_occupant.bodytemperature * unconscious_factor) * 1000 * delta_time)
		if(beaker)
			if(reagent_transfer == 0) // Magically transfer reagents. Because cryo magic.
				beaker.reagents.trans_to(get_occupant(), 1, efficiency * 12.5 * delta_time, methods = VAPOR) // Transfer reagents.
				air1.gases[/datum/gas/oxygen][MOLES] -= max(0, air1.gases[/datum/gas/oxygen][MOLES] - delta_time / efficiency) //Let's use gas for this
				air1.garbage_collect()
			reagent_transfer += 0.5 * delta_time
			if(reagent_transfer >= 10 * efficiency) // Throttle reagent transfer (higher efficiency will transfer the same amount but consume less from the beaker).
				reagent_transfer = 0

	return 1

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos(delta_time)
	..()

	if(!on)
		return

	var/datum/gas_mixture/air1 = airs[1]

	if(!nodes[1] || !airs[1] || !air1.gases.len || air1.gases[/datum/gas/oxygen][MOLES] < 5) // Turn off if the machine won't work.
		on = FALSE
		update_icon()
		return

	if(get_occupant())
		var/mob/living/mob_occupant = get_occupant()
		var/cold_protection = 0
		var/temperature_delta = air1.temperature - mob_occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.

		if(ishuman(mob_occupant))
			var/mob/living/carbon/human/H = mob_occupant
			cold_protection = H.get_cold_protection(air1.temperature)

		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()

			var/heat = ((1 - cold_protection) * 0.1 + conduction_coefficient) * temperature_delta * (air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))

			air1.temperature = clamp(air1.temperature - heat * delta_time / air_heat_capacity, TCMB, MAX_TEMPERATURE)
			mob_occupant.adjust_bodytemperature(heat * delta_time / heat_capacity, TCMB)

		air1.gases[/datum/gas/oxygen][MOLES] = max(0,air1.gases[/datum/gas/oxygen][MOLES] - 0.5 / efficiency) // Magically consume gas? Why not, we run on cryo magic.
		air1.garbage_collect()

		if(air1.temperature > 2000)
			take_damage(clamp((air1.temperature)/200, 10, 20), BURN)

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/living/user, direction)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = FALSE)
	if(!state_open && !panel_open)
		on = FALSE
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
	set_occupant(null)
	flick("pod-open-anim", src)
	reagent_transfer = efficiency * 10 - 5 // wait before injecting the next occupant
	..()

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	treating_wounds = FALSE
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("pod-close-anim", src)
		..(user)
		return get_occupant()

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist_act(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the glass of [src]!</span>", \
		"<span class='notice'>You struggle inside [src], kicking the release with your foot... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='hear'>You hear a thump from [src].</span>")
	if(do_after(user, breakout_time, target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	. = ..()
	if(get_occupant())
		if(on)
			. += "Someone's inside [src]!"
		else
			. += "You can barely make out a form floating in [src]."
	else
		. += "[src] seems empty."

/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated())
			close_machine(target)
	else
		user.visible_message("<span class='notice'>[user] starts shoving [target] inside [src].</span>", "<span class='notice'>You start shoving [target] inside [src].</span>")
		if (do_after(user, 25, target=target))
			close_machine(target)

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
		. = 1 //no afterattack
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into [src]!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		beaker = I
		user.visible_message("<span class='notice'>[user] places [I] in [src].</span>", \
							"<span class='notice'>You place [I] in [src].</span>")
		var/reagentlist = pretty_string_from_reagent_list(I.reagents.reagent_list)
		log_game("[key_name(user)] added an [I] to cryo containing [reagentlist]")
		return
	if(!on && !get_occupant() && !state_open && (default_deconstruction_screwdriver(user, "pod-off", "pod-off", I)) \
		|| default_change_direction_wrench(user, I) \
		|| default_pry_open(I) \
		|| default_deconstruction_crowbar(I))
		update_icon()
		return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='warning'>You can't access the maintenance panel while the pod is " \
		+ (on ? "active" : (get_occupant() ? "full" : "open")) + "!</span>")
		return
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_state(mob/user)
	return GLOB.notcontained_state


/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cryo", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_data()
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = get_occupant() ? TRUE : FALSE
	data["isOpen"] = state_open
	data["autoEject"] = autoeject

	data["occupant"] = list()
	if(get_occupant())
		var/mob/living/mob_occupant = get_occupant()
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS, HARD_CRIT)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = round(mob_occupant.health, 1)
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = round(mob_occupant.getBruteLoss(), 1)
		data["occupant"]["oxyLoss"] = round(mob_occupant.getOxyLoss(), 1)
		data["occupant"]["toxLoss"] = round(mob_occupant.getToxLoss(), 1)
		data["occupant"]["fireLoss"] = round(mob_occupant.getFireLoss(), 1)
		data["occupant"]["bodyTemperature"] = round(mob_occupant.bodytemperature, 1)
		if(mob_occupant.bodytemperature < TCRYO)
			data["occupant"]["temperaturestatus"] = "good"
		else if(mob_occupant.bodytemperature < T0C)
			data["occupant"]["temperaturestatus"] = "average"
		else
			data["occupant"]["temperaturestatus"] = "bad"

	var/datum/gas_mixture/air1 = airs[1]
	data["cellTemperature"] = round(air1.temperature, 1)

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	var/beakerContents = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			if(on)
				on = FALSE
			else if(!state_open)
				on = TRUE
			update_icon()
			. = TRUE
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("autoeject")
			autoeject = !autoeject
			. = TRUE
		if("ejectbeaker")
			if(beaker)
				beaker.forceMove(drop_location())
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				. = TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/CtrlClick(mob/user)
	if(can_interact(user) && !state_open)
		on = !on
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/AltClick(mob/user)
	if(can_interact(user))
		if(state_open)
			close_machine()
		else
			open_machine()
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
	return // we don't see the pipe network while inside cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return // can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_see_pipes()
	return FALSE // you can't see the pipe network when inside a cryo cell.

/obj/machinery/atmospherics/components/unary/cryo_cell/return_temperature()
	var/datum/gas_mixture/G = airs[1]

	if(G.total_moles() > 10)
		return G.temperature
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	. = ..()
	if(.)
		SetInitDirections()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
		nullifyPipenet(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		SSair.add_to_rebuild_queue(src)

#undef CRYOMOBS
#undef MAX_TEMPERATURE
