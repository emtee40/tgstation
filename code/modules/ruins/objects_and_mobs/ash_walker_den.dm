#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/ash_walker
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"

	move_resist=INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200


	var/faction = list("ashwalker")
	var/meat_counter = 6

/obj/structure/lavaland/ash_walker/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/deconstruct(disassembled)
	new /obj/item/assembly/signaler/anomaly (get_step(loc, pick(GLOB.alldirs)))
	new	/obj/effect/collapse(loc)
	return ..()

/obj/structure/lavaland/ash_walker/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_SAVAGE))
		visible_message("1")
		return TRUE

/obj/structure/lavaland/ash_walker/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/ash_walker/proc/consume()
	for(var/mob/living/H in view(src, 1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Serrated tendrils eagerly pull [H] to [src], tearing the body apart as its blood seeps over the eggs.</span>")
			playsound(get_turf(src),'sound/magic/demon_consume.ogg', 100, 1)
			for(var/obj/item/W in H)
				if(!H.dropItemToGround(W))
					qdel(W)
			if(ismegafauna(H))
				meat_counter += 20
			else
				meat_counter++
			H.gib()
			obj_integrity = min(obj_integrity + max_integrity*0.05,max_integrity)//restores 5% hp of tendril
			for(var/mob/living/L in view(src, 5))
				if(HAS_TRAIT(L.mind, TRAIT_SAVAGE))
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_good)
				else
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_bad)

/obj/structure/lavaland/ash_walker/proc/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/human/ash_walker(get_step(loc, pick(GLOB.alldirs)))
		visible_message("<span class='danger'>One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!</span>")
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD
