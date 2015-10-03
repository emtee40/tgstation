
/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	synth_cost = 3
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

/datum/reagent/thermite/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 1 && istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/Wall = T
		if(istype(Wall, /turf/simulated/wall/r_wall))
			Wall.thermite = Wall.thermite+(reac_volume*2.5)
		else
			Wall.thermite = Wall.thermite+(reac_volume*10)
		Wall.overlays = list()
		Wall.overlays += image('icons/effects/effects.dmi',"thermite")

/datum/reagent/thermite/on_mob_life(mob/living/M)
	M.adjustFireLoss(1)
	..()

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	synth_cost = 8
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/stabilizing_agent
	name = "Stabilizing Agent"
	id = "stabilizing_agent"
	synth_cost = 3
	description = "Keeps unstable chemicals stable. This does not work on everything."
	reagent_state = LIQUID
	color = "#FFFFFF"

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	synth_cost = 5
	description = "Makes a temporary 3x3 fireball when it comes into existence, so be careful when mixing. ClF3 applied to a surface burns things that wouldn't otherwise burn, sometimes through the very floors of the station and exposing it to the vacuum of space."
	reagent_state = LIQUID
	color = "#FF0000"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/clf3/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(2)
	var/burndmg = max(0.3*M.fire_stacks, 0.3)
	M.adjustFireLoss(burndmg)
	..()

/datum/reagent/clf3/reaction_turf(turf/simulated/T, reac_volume)
	if(istype(T, /turf/simulated/floor/plating))
		var/turf/simulated/floor/plating/F = T
		if(prob(1 + F.burnt + 5*F.broken)) //broken or burnt plating is more susceptible to being destroyed
			F.ChangeTurf(F.baseturf)
	if(istype(T, /turf/simulated/floor/))
		var/turf/simulated/floor/F = T
		if(prob(reac_volume/10))
			F.make_plating()
		else if(prob(reac_volume))
			F.burn_tile()
		if(istype(F, /turf/simulated/floor/))
			PoolOrNew(/obj/effect/hotspot, F)
	if(istype(T, /turf/simulated/wall/))
		var/turf/simulated/wall/W = T
		if(prob(reac_volume/10))
			W.ChangeTurf(/turf/simulated/floor/plating)

/datum/reagent/clf3/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(istype(M))
		if(method != INGEST)
			M.adjust_fire_stacks(min(reac_volume/5, 10))
			M.IgniteMob()
			PoolOrNew(/obj/effect/hotspot, M.loc)


/datum/reagent/sorium
	name = "Sorium"
	id = "sorium"
	synth_cost = 4
	description = "Sends everything flying from the detonation point."
	reagent_state = LIQUID
	color = "#FFA500"

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	synth_cost = 3
	description = "Sucks everything into the detonation point."
	reagent_state = LIQUID
	color = "#800080"

/datum/reagent/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	synth_cost = 9
	description = "Explodes. Violently."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.05

/datum/reagent/blackpowder/on_ex_act()
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(1 + round(volume/6, 1), location, 0, 0, message = 0)
	e.start()
	holder.clear_reagents()

/datum/reagent/flash_powder
	name = "Flash Powder"
	id = "flash_powder"
	synth_cost = 3
	description = "Makes a very bright flash."
	reagent_state = LIQUID
	color = "#FFFF00"

/datum/reagent/smoke_powder
	name = "Smoke Powder"
	id = "smoke_powder"
	synth_cost = 3
	description = "Makes a large cloud of smoke that can carry reagents."
	reagent_state = LIQUID
	color = "#808080"

/datum/reagent/sonic_powder
	name = "Sonic Powder"
	id = "sonic_powder"
	synth_cost = 3
	description = "Makes a deafening noise."
	reagent_state = LIQUID
	color = "#0000FF"

/datum/reagent/phlogiston
	name = "Phlogiston"
	id = "phlogiston"
	synth_cost = 3
	description = "Catches you on fire and makes you ignite."
	reagent_state = LIQUID
	color = "#FF9999"

/datum/reagent/phlogiston/on_mob_life(var/mob/living/M as mob)
	M.adjust_fire_stacks(1)
	M.IgniteMob()
	M.adjustFireLoss(0.2*M.fire_stacks)
	..()
	return

/datum/reagent/napalm
	name = "Napalm"
	id = "napalm"
	synth_cost = 3
	description = "Very flammable."
	reagent_state = LIQUID
	color = "#FF9999"

/datum/reagent/napalm/on_mob_life(var/mob/living/M as mob)
	M.adjust_fire_stacks(1)
	..()

/datum/reagent/napalm/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if((method == TOUCH || method == VAPOR || method == PATCH) && isliving(M))
		M.adjust_fire_stacks(min(reac_volume/4, 20))

/datum/reagent/cryostylane
	name = "Cryostylane"
	id = "cryostylane"
	synth_cost = 3
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Cryostylane slowly cools all other reagents in the mob down to 0K."
	color = "#B2B2FF" // rgb: 139, 166, 233
	metabolization_rate = 0.5 * REAGENTS_METABOLISM


/datum/reagent/cryostylane/on_mob_life(var/mob/living/M as mob) //TODO: code freezing into an ice cube
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 0.5)
		M.bodytemperature -= 15
	..()

/datum/reagent/cryostylane/on_tick()
	if(istype(holder.my_atom,/obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/G = holder.my_atom
		if(G.flags & NOREACT)
			return
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 1)
		holder.chem_temp -= 10
		holder.handle_reactions()
	..()

/datum/reagent/cryostylane/reaction_turf(var/turf/simulated/T, var/volume)
	if(volume >= 5)
		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(15,30))

/datum/reagent/pyrosium
	name = "Pyrosium"
	id = "pyrosium"
	synth_cost = 3
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Pyrosium slowly heats all other reagents in the mob."
	color = "#B20000" // rgb: 139, 166, 233
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/pyrosium/on_mob_life(var/mob/living/M as mob)
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 0.5)
		M.bodytemperature += 15
	..()

/datum/reagent/pyrosium/on_tick()
	if(istype(holder.my_atom,/obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/G = holder.my_atom
		if(G.flags & NOREACT)
			return
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 1)
		holder.chem_temp += 10
		holder.handle_reactions()
	..()
