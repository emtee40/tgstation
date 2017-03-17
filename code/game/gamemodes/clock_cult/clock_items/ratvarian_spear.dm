//Ratvarian spear: A relatively fragile spear from the Celestial Derelict. Deals extreme damage to silicons and enemy cultists, but doesn't last long when summoned.
/obj/item/clockwork/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	clockwork_desc = "A powerful spear of Ratvarian making. It's more effective against enemy cultists and silicons."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 15 //Extra damage is dealt to targets in attack()
	throwforce = 40
	sharpness = IS_SHARP_ACCURATE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	var/impale_cooldown = 50 //delay, in deciseconds, where you can't impale again
	var/attack_cooldown = 10 //delay, in deciseconds, where you can't attack with the spear
	var/timerid

/obj/item/clockwork/ratvarian_spear/New()
	..()
	impale_cooldown = 0

/obj/item/clockwork/ratvarian_spear/Destroy()
	deltimer(timerid)
	return ..()

/obj/item/clockwork/ratvarian_spear/ratvar_act()
	if(ratvar_awakens) //If Ratvar is alive, the spear is extremely powerful
		force = 25
		throwforce = 50
		armour_penetration = 10
		clockwork_desc = initial(clockwork_desc)
		deltimer(timerid)
	else
		force = initial(force)
		throwforce = initial(throwforce)
		armour_penetration = 0
		clockwork_desc = "A powerful spear of Ratvarian making. It's more effective against enemy cultists and silicons, though it won't last for long."
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, .proc/break_spear), RATVARIAN_SPEAR_DURATION, TIMER_STOPPABLE)

/obj/item/clockwork/ratvarian_spear/cyborg/ratvar_act() //doesn't break!
	if(ratvar_awakens)
		force = 25
		throwforce = 50
		armour_penetration = 10
	else
		force = initial(force)
		throwforce = initial(throwforce)
		armour_penetration = 0

/obj/item/clockwork/ratvarian_spear/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='brass'>Stabbing a human you are pulling or have grabbed with the spear will impale them, doing massive damage and stunning.</span>")
		if(!iscyborg(user))
			to_chat(user, "<span class='brass'>Throwing the spear will do massive damage, break the spear, and stun the target.</span>")

/obj/item/clockwork/ratvarian_spear/attack(mob/living/target, mob/living/carbon/human/user)
	var/impaling = FALSE
	if(attack_cooldown > world.time)
		to_chat(user, "<span class='warning'>You can't attack right now, wait [max(round((attack_cooldown - world.time)*0.1, 0.1), 0)] seconds!</span>")
		return
	if(user.pulling && ishuman(user.pulling) && user.pulling == target)
		if(impale_cooldown > world.time)
			to_chat(user, "<span class='warning'>You can't impale [target] yet, wait [max(round((impale_cooldown - world.time)*0.1, 0.1), 0)] seconds!</span>")
		else
			impaling = TRUE
			attack_verb = list("impaled")
			force += 22 //total 40 damage if ratvar isn't alive, 50 if he is
			armour_penetration += 10 //if you're impaling someone, armor sure isn't that useful
			user.stop_pulling()

	if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	user.lastattacked = target
	target.lastattacker = user
	user.do_attack_animation(target)
	if(!target.attacked_by(src, user)) //TODO MAKE ATTACK() USE PROPER RETURN VALUES
		impaling = FALSE //if we got blocked, stop impaling
	else if(!target.null_rod_check()) //if they don't have a null rod, we do bonus damage on a successful attack
		if(issilicon(target))
			var/mob/living/silicon/S = target
			if(S.stat != DEAD)
				S.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] shudders violently at [src]'s touch!</span>", "<span class='userdanger'>ERROR: Temperature rising!</span>", subjects=list(S))
				S.adjustFireLoss(22) //total 37 damage on borgs
		else if(iscultist(target) || isconstruct(target))
			var/mob/living/M = target
			if(M.stat != DEAD)
				to_chat(M, "<span class='userdanger'>Your body flares with agony at [src]'s presence!</span>")
				M.adjustFireLoss(15) //total 30 damage on cultists
		else
			target.adjustFireLoss(3) //anything else takes a total of 18
	add_logs(user, target, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)

	attack_verb = list("stabbed", "poked", "slashed")
	ratvar_act()
	if(impaling)
		impale_cooldown = world.time + initial(impale_cooldown)
		attack_cooldown = world.time + initial(attack_cooldown) //can't attack until we're done impaling
		if(target)
			new /obj/effect/overlay/temp/dir_setting/bloodsplatter(get_turf(target), get_dir(user, target))
			target.Stun(2) //brief stun
			to_chat(user, "<span class='brass'>You prepare to remove your ratvarian spear from [target]...</span>")
			var/remove_verb = pick("pull", "yank", "drag")
			if(do_after(user, 10, 1, target))
				var/turf/T = get_turf(target)
				var/obj/effect/overlay/temp/dir_setting/bloodsplatter/B = new /obj/effect/overlay/temp/dir_setting/bloodsplatter(T, get_dir(target, user))
				playsound(T, 'sound/misc/splort.ogg', 200, 1)
				playsound(T, 'sound/weapons/pierce.ogg', 200, 1)
				if(target.stat != CONSCIOUS)
					user.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] [remove_verb]s [src] out of [IDENTITY_SUBJECT(2)]!</span>", "<span class='warning'>You [remove_verb] your spear from [IDENTITY_SUBJECT(2)]!</span>", subjects=list(user, target))
				else
					user.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] kicks [IDENTITY_SUBJECT(2)] off of [src]!</span>", "<span class='warning'>You kick [IDENTITY_SUBJECT(2)] off of [src]!</span>", subjects=list(user, target))
					to_chat(target, "<span class='userdanger'>You scream in pain as you're kicked off of [src]!</span>")
					target.emote("scream")
					step(target, get_dir(user, target))
					T = get_turf(target)
					B.forceMove(T)
					target.Weaken(2) //then weaken if we stayed next to them
					playsound(T, 'sound/weapons/thudswoosh.ogg', 50, 1)
				flash_color(target, flash_color="#911414", flash_time=8)
			else if(target) //it's a do_after, we gotta check again to make sure they didn't get deleted
				user.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] [remove_verb]s [src] out of [IDENTITY_SUBJECT(2)]!</span>", "<span class='warning'>You [remove_verb] your spear from [IDENTITY_SUBJECT(2)]!</span>", subjects=list(user, target))
				if(target.stat == CONSCIOUS)
					to_chat(target, "<span class='userdanger'>You scream in pain as [src] is suddenly [remove_verb]ed out of you!</span>")
					target.emote("scream")
				flash_color(target, flash_color="#911414", flash_time=4)

/obj/item/clockwork/ratvarian_spear/throw_impact(atom/target)
	var/turf/T = get_turf(target)
	if(isliving(target))
		var/mob/living/L = target
		if(is_servant_of_ratvar(L))
			if(L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] catches [src] out of the air!</span>", subjects=list(L))
			else
				L.visible_message("<span class='warning'>[src] bounces off of [IDENTITY_SUBJECT(1)], as if repelled by an unseen force!</span>", subjects=list(L))
		else if(!..())
			if(!L.null_rod_check())
				if(issilicon(L) || iscultist(L))
					L.Stun(6)
					L.Weaken(6)
				else
					L.Stun(2)
					L.Weaken(2)
			break_spear(T)
	else
		..()

/obj/item/clockwork/ratvarian_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T) //make sure we're not in null or something
			T.visible_message("<span class='warning'>[src] [pick("cracks in two and fades away", "snaps in two and dematerializes")]!</span>")
			new /obj/effect/overlay/temp/ratvar/spearbreak(T)
		qdel(src)
