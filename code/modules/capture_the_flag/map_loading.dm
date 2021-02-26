/obj/effect/landmark/ctf
	name = "CTF Map Spawner"

/obj/effect/landmark/ctf/Initialize(mapload)
	. = ..()
	load_map()

/obj/effect/landmark/ctf/proc/load_map()
	
	var/list/map_options = subtypesof(/datum/map_template/ctf)
	var/turf/spawn_area = get_turf(src)
	var/datum/map_template/ctf/current_map

	current_map = pick(map_options)
	current_map = new current_map

	if(!spawn_area)
		CRASH("No spawn area detected for CTF!")
	else if(!current_map)
		CRASH("No map prepared")
	var/list/bounds = current_map.load(spawn_area, TRUE)
	if(!bounds)
		CRASH("Loading CTF map failed!")

/datum/map_template/ctf
	var/description = ""

/datum/map_template/ctf/classic
	name = "Classic"
	width = 107
	height = 43
	description = "The original CTF map."
	mappath = "_maps/map_files/CTF/classic.dmm"