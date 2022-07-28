//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type,specific = FALSE)
	RETURN_TYPE(/list/datum/mind)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type)
			. += A.owner

/// From a list of players (minds, mobs or clients), finds the one with the highest playtime (either from a specific role or overall living) and returns it.
/proc/get_most_experienced(list/players, specific_role)
	if(!CONFIG_GET(flag/use_exp_tracking)) //woops
		return players[1]
	var/index = 0
	for(var/client/player as anything in players)
		index++
		player = get_player_client(player)
		if(!player?.prefs)
			continue
		if(!length(player.prefs.exp))
			player.set_exp_from_db()
			if(!length(player.prefs.exp))
				continue
		var/client/most_played = get_player_client(players[1])
		if(player == most_played)
			continue
		if(!most_played.prefs || !length(most_played.prefs.exp))
			players.Swap(1, index)
			continue
		var/player_playtime
		var/most_playtime
		if(specific_role)
			player_playtime = player.prefs.exp[specific_role] ? text2num(player.prefs.exp[specific_role]) : 0
			most_playtime = most_played.prefs.exp[specific_role] ? text2num(most_played.prefs.exp[specific_role]) : 0
		else
			player_playtime = player.get_exp_living(TRUE)
			most_playtime = most_played.get_exp_living(TRUE)
		if(player_playtime > most_playtime)
			players.Swap(1, index)
	return players[1]
