/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You can hear your own voice echoing in your mind!</span>"
	text_lose_indication = "<span class='notice'>You don't hear your mind echo anymore.</span>"
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy
	instability = 10


/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Smells begin to make more sense...</span>"
	text_lose_indication = "<span class='notice'>Your sense of smell goes back to normal.</span>"
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	var/reek = 0

/*following code doesnt really work since you cant keep vars
(in this case, var/reek) on the mutation datum*/

/datum/mutation/human/olfaction/on_life()
	var/hygiene_now = owner.hygiene
	if(!reek)
		reek = hygiene_now
		return

	if(hygiene_now < 100 && prob(5))
		owner.adjustOxyLoss(rand(3,5))
	if(hygiene_now < HYGIENE_LEVEL_DIRTY && prob(50))
		owner.adjustOxyLoss(7)

	if(hygiene_now < HYGIENE_LEVEL_NORMAL && reek >= HYGIENE_LEVEL_NORMAL)
		to_chat(usr,"<span class='warning'>Your inhumanly strong nose picks up a bad odor. Maybe you should shower soon.</span>")
		reek = hygiene_now
	if(hygiene_now < 150 && reek >= 150)
		to_chat(usr,"<span class='warning'>This is getting bad. Your odor is getting intolerable.</span>")
		reek = hygiene_now
	if(hygiene_now < 100 && reek >= 100)
		to_chat(usr,"<span class='warning'>Your odor begins to make you gag. You silently curse your god-like nose.</span>")
		reek = hygiene_now
	if(hygiene_now < HYGIENE_LEVEL_DIRTY && reek >= HYGIENE_LEVEL_DIRTY)
		to_chat(usr,"<span class='warning'>Your horrible stench causes your nostrils to slam shut as your survival instincts involuntarily kick in.</span>")
		to_chat(usr,"<span class='userdanger'>You can't breathe!</span>")
		reek = hygiene_now

/*see comment above*/

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	charge_max = 100
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets,mob/user = usr)
	var/atom/sniffed = usr.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = sniffed.return_fingerprints()
		for(var/mob/living/carbon/C in GLOB.mob_list)
			if(prints[md5(C.dna.uni_identity)])
				possible |= C
		if(!length(possible))
			to_chat(usr,"<span class='warning'>Despite your best efforts, there are no scents to be found on [sniffed]...</span>")
			return
		tracking_target = input(user, "Choose a scent to remember.", "Scent Tracking") as null|anything in possible
		if(!tracking_target)
			if(!old_target)
				to_chat(usr,"<span class='warning'>You decide against remembering any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was.</span>")
				return
			tracking_target = old_target
			on_the_trail()
			return
		to_chat(usr,"<span class='notice'>You pick up the scent of [tracking_target]. The hunt begins.</span>")
		on_the_trail()
		return

	if(!tracking_target)
		to_chat(usr,"<span class='warning'>You're not holding anything to smell, and you haven't smelled anything you can track. You smell your palm instead; it's kinda salty.</span>")
		return

	on_the_trail()

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail()
	if(!tracking_target)
		to_chat(usr,"<span class='warning'>You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug.</span>")
		return
	if(tracking_target == usr)
		to_chat(usr,"<span class='warning'>You smell out the trail to yourself. Yep, it's you.</span>")
		return
	if(usr.z < tracking_target.z)
		to_chat(usr,"<span class='warning'>The trail leads... way up above you? Huh. They must be really, really far away.</span>")
		return
	else if(usr.z > tracking_target.z)
		to_chat(usr,"<span class='warning'>The trail leads... way down below you? Huh. They must be really, really far away.</span>")
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(usr,"<span class='notice'>You consider [tracking_target]'s scent. The trail leads <b>[direction_text].</b></span>")

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your throat is burning!</span>"
	text_lose_indication = "<span class='notice'>Your throat is cooling down.</span>"
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	charge_max = 600
	clothes_req = FALSE
	range = 20
	projectile_type = /obj/item/projectile/magic/aoe/fireball/firebreath
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	active_msg = "You built up heat in your mouth."
	deactive_msg = "You swallow the flame."

/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.is_mouth_covered())
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			to_chat(C,"<span class='warning'>Something in front of your mouth caught fire!</span>")
			return FALSE

/obj/item/projectile/magic/aoe/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 4

/datum/mutation/human/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>You feel a heavy, dull force just beyond the walls watching you.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void

/datum/mutation/human/void/on_life()
	if(!isturf(owner.loc))
		return
	if(prob(0.5+((100-dna.stability)/20))) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		new /obj/effect/immortality_talisman/void(get_turf(owner), owner)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = "evocation"
	clothes_req = FALSE
	charge_max = 600
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = "shout"
	action_icon_state = "void_magnet"

/obj/effect/proc_holder/spell/self/void/can_cast(mob/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(mob/user = usr)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)
