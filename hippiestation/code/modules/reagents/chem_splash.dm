//This is a MIRRORED /TG/ PROC
/*
Booleans have been brought up to code standard
Direct holder reference "splash_holder" changed to a particle_effect object named "epicentre" with it's own holder thanks to the create_reagents proc
This allows for the "handle_state_change" proc to type check the source of the reaction as a particle effect and apply the same code it does for smoke and foam regarding dupe reduction (currently define multipliers)
*/
/proc/chem_splash(turf/epicenter, affected_range = 3, list/datum/reagents/reactants = list(), extra_heat = 0, threatscale = 1, adminlog = 1)
	if(!isturf(epicenter) || !reactants.len || threatscale <= 0)
		return
	var/has_reagents
	var/total_reagents
	for(var/datum/reagents/R in reactants)
		if(R.total_volume)
			has_reagents = 1
			total_reagents += R.total_volume

	if(!has_reagents)
		return

	var/atom/epicentre = new /obj/effect/particle_effect/steam
	epicentre.create_reagents(total_reagents)

	var/total_temp = 0

	for(var/datum/reagents/R in reactants)
		R.trans_to(epicentre.reagents, R.total_volume, threatscale, 1, 1)
		total_temp += R.chem_temp
	epicentre.reagents.chem_temp = (total_temp/reactants.len) + extra_heat // Average temperature of reagents + extra heat.
	epicentre.reagents.handle_reactions() // React them now.

	if(epicentre.reagents.total_volume && affected_range >= 0)	//The possible reactions didnt use up all reagents, so we spread it around.
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, epicenter)
		steam.attach(epicenter)
		steam.start()

		var/list/viewable = view(affected_range, epicenter)

		var/list/accessible = list(epicenter)
		for(var/i=1; i<=affected_range; i++)
			var/list/turflist = list()
			for(var/turf/T in (orange(i, epicenter) - orange(i-1, epicenter)))
				turflist |= T
			for(var/turf/T in turflist)
				if(!(get_dir(T,epicenter) in GLOB.cardinals) && (abs(T.x - epicenter.x) == abs(T.y - epicenter.y) ))
					turflist.Remove(T)
					turflist.Add(T) // we move the purely diagonal turfs to the end of the list.
			for(var/turf/T in turflist)
				if(accessible[T])
					continue
				for(var/thing in T.GetAtmosAdjacentTurfs(alldir = TRUE))
					var/turf/NT = thing
					if(!(NT in accessible))
						continue
					if(!(get_dir(T,NT) in GLOB.cardinals))
						continue
					accessible[T] = 1
					break
		var/list/reactable = accessible
		for(var/turf/T in accessible)
			for(var/atom/A in T.GetAllContents())
				if(!(A in viewable))
					continue
				reactable |= A
			if(extra_heat >= 300)
				T.hotspot_expose(extra_heat*2, 5)
		if(!reactable.len) //Nothing to react with. Probably means we're in nullspace.
			return
		for(var/thing in reactable)
			var/atom/A = thing
			var/distance = max(1,get_dist(A, epicenter))
			var/fraction = 0.5/(2 ** distance) //50/25/12/6... for a 200u splash, 25/12/6/3... for a 100u, 12/6/3/1 for a 50u
			epicentre.reagents.reaction(A, TOUCH, fraction)

	qdel(epicentre)
	return TRUE