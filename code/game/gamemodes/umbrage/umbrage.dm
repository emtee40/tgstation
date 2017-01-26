/*

Umbrage is the revamped Shadowling.
The gamemode focuses around several powerful aliens, called umbrages, that attempt to enslave crew members.
The umbrages thrive in darkness and can see in it, but the light physically hurts them.
They start disguised with no special abilities, and have to spend time "hatching", during which they are vulnerable.

Every umbrage on the station shares a goal: "ascend" into a progenitor, their true form.
Resembling eldritch monstrosities, progenitors are immensely powerful, immune to most damage and capable of killing with a mere thought.
When an umbrage successfully ascends, the shuttle is called. This is their win condition.
In order to do this, they must accumulate a certain amount of veils based on round population.
Ascension itself takes a long time, and the umbrage is completely vulnerable. Their veils must protect them.
To obtain this, umbrages and their veils are linked through silent hive mind. This can be detected with the right machinery.

Fluff-wise, umbrages are much more deceptive than shadowlings, and less brute-force. They think themselves more refined than humans rather than simply superior.
Think of how we look on apes, for instance. Similar to us, and what we came from, but stupid and slow compared to us.
They believe themselves as using magic, but it's more mundane; their bodies are capable of the things they believe are magic.

Terminology you might remember has been changed to spookier variants, such as:
	shadowlings => umbrages (pronounced "um-bridge")
	thralls => veils
	ascendants => progenitors

Folder contents:
	/code/game/gamemodes/umbrage
		/__umbrage_defines.dm: Contains defines and global variables for all umbrage code.
		/umbrage.dm: This file. Contains the skeleton of the gamemode.
		/umbrage_antags.dm: Contains antagonist datums for umbrages and veils.
		/umbrage_datum.dm: Contains the tracking datum for lots of umbrage stuff.
		/umbrage_major_abilities.dm: Contains hatching and ascension abilities and their related objects.
		/umbrage_minor_abilities.dm: Contains spells, abilities, and other stuff. Does NOT including hatching and ascension.
		/umbrage_objects.dm: Contains the few items and structures used in Umbrage.
		/umbrage_unsorted.dm: Contains things with nowhere else to be, like the umbrage race.

Idea and initial code by Xhuis (my 3rd gamemode now...)

*/

///////////////
// FRAMEWORK //
///////////////

/datum/game_mode
	var/list/umbrages = list() //A list of the minds of all umbrages, including progenitors.
	var/list/veils = list() //A list of the minds of all veils.
	var/list/umbrages_and_veils = list() //A list of the minds of all umbrages and veils.

/datum/game_mode/umbrage
	name = "umbrage"
	config_tag = "umbrage"
	antag_flag = ROLE_UMBRAGE
	required_players = 1 //25
	required_enemies = 1
	recommended_enemies = 3
	enemy_minimum_age = 14
	restricted_jobs = list("AI", "Cyborg", "Captain") //Notice that chaplains aren't here. Umbrages aren't magical or cultlike!
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	announce_span = "velvet"
	announce_text = "Eldritch aberrations are trying to enslave the station!\n\
	<span class='velvet'>Umbrages</span>: Dominate the will of the crew and ascend into a progenitor.\n\
	<span class='notice'>Crew</span>: Protect your minds and nullify the umbrages before they take over."
	var/list/initial_umbrages = list()

/datum/game_mode/umbrage/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"
	var/starting_umbrages = Clamp(round(num_players() / 10), 1, 3) //At least 1 umbrage, but no more than 3
	for(var/i = starting_umbrages, i > 0, i--)
		var/datum/mind/new_umbrage = pick(antag_candidates)
		initial_umbrages += new_umbrage
		antag_candidates -= new_umbrage
		modePlayer += new_umbrage
		new_umbrage.special_role = "Umbrage"
		new_umbrage.restricted_roles = restricted_jobs
		log_game("[new_umbrage.key] (ckey) has been selected as an umbrage.")
	return 1

/datum/game_mode/umbrage/post_setup()
	for(var/U in initial_umbrages)
		var/datum/mind/umbrage_mind = U
		var/mob/living/H = umbrage_mind.current
		antag_umbrage(H)
		umbrages += U //Temp.
		umbrages_and_veils += U
		greet_umbrage(H)
		equip_umbrage(H)
	..()
	return 1

/datum/game_mode/proc/greet_umbrage(mob/living/U) //Announcement and direction to the tutorial
	if(!U)
		return
	U << "<span class='velvet_large'><b>You are an umbrage!</b></span>"
	U << "<i>Use <b>.a</b> before your message to speak over the Mindlink.</i>"
	U << "<i>Look for the info button in the top left of your screen if you need help.</i>"
	return 1

/datum/game_mode/proc/equip_umbrage(mob/living/U)
	var/datum/umbrage/S = new
	S.linked_mind = U.mind
	U.mind.umbrage_psionics = S
	for(var/V in subtypesof(/datum/action/innate/umbrage))
		var/datum/action/innate/umbrage/A = new V
		A.Grant(U)
	return

/datum/game_mode/proc/antag_umbrage(mob/living/U)
#warn Umbrages need antag datums when LeoZ finishes his rework
	return

///////////
// PROCS //
///////////

/proc/is_umbrage(datum/mind/M)
	for(var/V in ticker.mode.umbrages)
		var/datum/mind/T = V
		if(T = M)
			return 1
	return 0

/proc/is_veil(datum/mind/M)
	for(var/V in ticker.mode.veils)
		var/datum/mind/T = V
		if(T = M)
			return 1
	return 0

/proc/is_umbrage_or_veil(datum/mind/M)
	return is_umbrage(M) || is_veil(M)

/proc/is_umbrage_progenitor(datum/mind/M)
	return 0
