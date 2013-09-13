/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks")
	emote_hear = list("squeeks")
	emote_see = list("runs in a circle", "shakes")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	density = 0
	var/col	//brown, gray and white, leave blank for random

/mob/living/simple_animal/mouse/New()
	..()
	if(!col)
		col = pick( list("brown","gray","white") )
	icon_state = "mouse_[col]"
	icon_living = "mouse_[col]"
	icon_dead = "mouse_[col]_dead"


/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.icon_dead = "mouse_[col]_splat"
	Die()

/mob/living/simple_animal/mouse/Die()
	..()
	var/obj/item/trash/deadmouse/M = new(src.loc)
	M.icon_state = src.icon_dead
	del (src)

/mob/living/simple_animal/mouse/HasEntered(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			M << "\blue \icon[src] Squeek!"
			playsound(src, 'sound/effects/mousesqueek.ogg', 100, 1)
	..()

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	col = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	col = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	col = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"

/obj/item/trash/deadmouse
	name = "dead mouse"
	desc = "It looks like somebody dropped the bass on it."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray_dead"
