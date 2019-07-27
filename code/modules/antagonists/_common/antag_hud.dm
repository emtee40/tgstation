<<<<<<< HEAD
/datum/atom_hud/antag
	hud_icons = list(ANTAG_HUD)
	var/self_visible = TRUE
	var/team_hud = FALSE

/datum/atom_hud/antag/hidden
	self_visible = FALSE

/datum/atom_hud/antag/team
	team_hud = TRUE

/datum/atom_hud/antag/proc/join_hud(mob/M)
	var/datum/atom_hud/antag/mind_hud = M.mind.antag_hud
	
	if (team_hud)
		mind_hud = M.mind.team_antag_hud
		
	//sees_hud should be set to 0 if the mob does not get to see it's own hud type.
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	if(mind_hud) //note: please let this runtime if a mob has no mind, as mindless mobs shouldn't be getting antagged
		mind_hud.leave_hud(M)
	add_to_hud(M)
	if(self_visible)
		add_hud_to(M)

	if (!team_hud)
		M.mind.antag_hud = src
	else
		M.mind.team_antag_hud = src

/datum/atom_hud/antag/proc/leave_hud(mob/M)
	if(!M)
		return
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	if(M.mind)
		if (!team_hud)
			M.mind.antag_hud = null
		else
			M.mind.team_antag_hud = null
		
//GAME_MODE PROCS
//called to set a mob's antag icon state
/proc/set_antag_hud(mob/M, new_icon_state, team_hud=FALSE)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.icon_state = new_icon_state
	if(M.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're antagging a mindless mob, meaning we should runtime
		if (!team_hud)
			M.mind.antag_hud_icon_state = new_icon_state
		else
			M.mind.team_antag_hud_icon_state = new_icon_state

//MIND PROCS
//these are called by mind.transfer_to()
/datum/mind/proc/transfer_antag_huds(datum/atom_hud/antag/global_newhud, datum/atom_hud/antag/team_newhud)
	leave_all_antag_huds()
	
	set_antag_hud(current, antag_hud_icon_state)
	set_antag_hud(current, team_antag_hud_icon_state, TRUE)

	if(global_newhud)
		global_newhud.join_hud(current)
	if(team_newhud)
		team_newhud.join_hud(current)

/datum/mind/proc/leave_all_antag_huds()
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		if(hud.hudusers[current])
			hud.leave_hud(current)
=======
/datum/atom_hud/antag
	hud_icons = list(ANTAG_HUD)
	var/self_visible = TRUE

/datum/atom_hud/antag/hidden
	self_visible = FALSE

/datum/atom_hud/antag/proc/join_hud(mob/M)
	//sees_hud should be set to 0 if the mob does not get to see it's own hud type.
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	if(M.mind.antag_hud) //note: please let this runtime if a mob has no mind, as mindless mobs shouldn't be getting antagged
		M.mind.antag_hud.leave_hud(M)
	add_to_hud(M)
	if(self_visible)
		add_hud_to(M)
	M.mind.antag_hud = src

/datum/atom_hud/antag/proc/leave_hud(mob/M)
	if(!M)
		return
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	if(M.mind)
		M.mind.antag_hud = null


//GAME_MODE PROCS
//called to set a mob's antag icon state
/proc/set_antag_hud(mob/M, new_icon_state)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.icon_state = new_icon_state
	if(M.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're antagging a mindless mob, meaning we should runtime
		M.mind.antag_hud_icon_state = new_icon_state


//MIND PROCS
//these are called by mind.transfer_to()
/datum/mind/proc/transfer_antag_huds(datum/atom_hud/antag/newhud)
	leave_all_antag_huds()
	set_antag_hud(current, antag_hud_icon_state)
	if(newhud)
		newhud.join_hud(current)

/datum/mind/proc/leave_all_antag_huds()
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		if(hud.hudusers[current])
			hud.leave_hud(current)
>>>>>>> Updated this old code to fork
