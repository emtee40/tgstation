/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	var/max_streak_length = 6
	var/current_target = null
	var/temporary = 0
	var/datum/martial_art/base = null // The permanent style
	var/deflection_chance = 0 //Chance to deflect projectiles
	var/help_verb = null

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/add_to_streak(element,mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak,2)
	return

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A,mob/living/carbon/human/D)

	A.do_attack_animation(D)
	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)

	var/atk_verb = A.dna.species.attack_verb
	if(D.lying)
		atk_verb = "kick"

	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>")
		add_logs(A, D, "attempted to [atk_verb]")
		return 0

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
								"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>")

	D.apply_damage(damage, BRUTE, affecting, armor_block)

	add_logs(A, D, "punched")

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] has weakened [D]!!</span>", \
								"<span class='userdanger'>[A] has weakened [D]!</span>")
		D.apply_effect(4, WEAKEN, armor_block)
		D.forcesay(hit_appends)
	else if(D.lying)
		D.forcesay(hit_appends)
	return 1

/datum/martial_art/proc/teach(mob/living/carbon/human/H,make_temporary=0)
	if(help_verb)
		H.verbs += help_verb
	if(make_temporary)
		temporary = 1
	if(H.martial_art && temporary)
		base = H.martial_art
	H.martial_art = src

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	if(H.martial_art != src)
		return
	H.martial_art = base
	if(help_verb)
		H.verbs -= help_verb

/datum/martial_art/boxing
	name = "Boxing"

/datum/martial_art/boxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A << "<span class='warning'>Can't disarm while boxing!</span>"
	return 1

/datum/martial_art/boxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A << "<span class='warning'>Can't grab while boxing!</span>"
	return 1

/datum/martial_art/boxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 8) + A.dna.species.punchdamagelow
	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to hit [D] with a [atk_verb]!</span>")
		add_logs(A, D, "attempted to hit", atk_verb)
		return 0


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)

	D.visible_message("<span class='danger'>[A] has hit [D] with a [atk_verb]!</span>", \
								"<span class='userdanger'>[A] has hit [D] with a [atk_verb]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	add_logs(A, D, "punched (boxing) ")
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] has knocked [D] out with a haymaker!</span>", \
								"<span class='userdanger'>[A] has knocked [D] out with a haymaker!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.SetSleeping(5)
			D.forcesay(hit_appends)
			add_logs(A, D, "knocked out (boxing) ")
		else if(D.lying)
			D.forcesay(hit_appends)
	return 1

/mob/living/carbon/human/proc/wrestling_help()
	set name = "Recall Teachings"
	set desc = "Remember how to wrestle."
	set category = "Wrestling"

	usr << "<b><i>You flex your muscles and have a revelation...</i></b>"
	usr << "<span class='notice'>Clinch</span>: Grab. Passively gives you a chance to immediately aggressively grab someone. Not always successful."
	usr << "<span class='notice'>Suplex</span>: Disarm someone you are grabbing. Suplexes your target to the floor. Greatly injures them and leaves both you and your target on the floor."
	usr << "<span class='notice'>Advanced grab</span>: Grab. Passively causes stamina damage when grabbing someone."

#define TORNADO_COMBO "HHD"
#define THROWBACK_COMBO "DHD"
#define PLASMA_COMBO "HDDDH"

/datum/martial_art/plasma_fist
	name = "Plasma Fist"
	help_verb = /mob/living/carbon/human/proc/plasma_fist_help


/datum/martial_art/plasma_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,TORNADO_COMBO))
		streak = ""
		Tornado(A,D)
		return 1
	if(findtext(streak,THROWBACK_COMBO))
		streak = ""
		Throwback(A,D)
		return 1
	if(findtext(streak,PLASMA_COMBO))
		streak = ""
		Plasma(A,D)
		return 1
	return 0

/datum/martial_art/plasma_fist/proc/Tornado(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.say("TORNADO SWEEP!")
	spawn(0)
		for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
			A.setDir(i)
			playsound(A.loc, 'sound/weapons/punch1.ogg', 15, 1, -1)
			sleep(1)
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
	var/list/turfs = list()
	for(var/turf/T in range(1,A))
		turfs.Add(T)
	R.cast(turfs)
	add_logs(A, D, "tornado sweeped(Plasma Fist)")
	return

/datum/martial_art/plasma_fist/proc/Throwback(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='danger'>[A] has hit [D] with Plasma Punch!</span>", \
								"<span class='userdanger'>[A] has hit [D] with Plasma Punch!</span>")
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
	D.throw_at(throw_target, 200, 4,A)
	A.say("HYAH!")
	add_logs(A, D, "threw back (Plasma Fist)")
	return

/datum/martial_art/plasma_fist/proc/Plasma(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	A.say("PLASMA FIST!")
	D.visible_message("<span class='danger'>[A] has hit [D] with THE PLASMA FIST TECHNIQUE!</span>", \
								"<span class='userdanger'>[A] has hit [D] with THE PLASMA FIST TECHNIQUE!</span>")
	D.gib()
	add_logs(A, D, "gibbed (Plasma Fist)")
	return

/datum/martial_art/plasma_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/plasma_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/plasma_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/mob/living/carbon/human/proc/plasma_fist_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Plasma Fist."
	set category = "Plasma Fist"

	usr << "<b><i>You clench your fists and have a flashback of knowledge...</i></b>"
	usr << "<span class='notice'>Tornado Sweep</span>: Harm Harm Disarm. Repulses target and everyone back."
	usr << "<span class='notice'>Throwback</span>: Disarm Harm Disarm. Throws the target and an item at them."
	usr << "<span class='notice'>The Plasma Fist</span>: Harm Disarm Disarm Disarm Harm. Knocks the brain out of the opponent and gibs their body."

//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"
/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	deflection_chance = 100
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,WRIST_WRENCH_COMBO))
		streak = ""
		wristWrench(A,D)
		return 1
	if(findtext(streak,BACK_KICK_COMBO))
		streak = ""
		backKick(A,D)
		return 1
	if(findtext(streak,STOMACH_KNEE_COMBO))
		streak = ""
		kneeStomach(A,D)
		return 1
	if(findtext(streak,HEAD_KICK_COMBO))
		streak = ""
		headKick(A,D)
		return 1
	if(findtext(streak,ELBOW_DROP_COMBO))
		streak = ""
		elbowDrop(A,D)
		return 1
	return 0

/datum/martial_art/the_sleeping_carp/proc/wristWrench(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.stunned && !D.weakened)
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] grabs [D]'s wrist and wrenches it sideways!</span>", \
						  "<span class='userdanger'>[A] grabs your wrist and violently wrenches it to the side!</span>")
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.emote("scream")
		D.drop_item()
		D.apply_damage(5, BRUTE, pick("l_arm", "r_arm"))
		D.Stun(3)
		return 1
	add_logs(A, D, "wrist wrenched (Sleeping Carp)")
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/backKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.dir == D.dir && !D.stat && !D.weakened)
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] kicks [D] in the back!</span>", \
						  "<span class='userdanger'>[A] kicks you in the back, making you stumble and fall!</span>")
		step_to(D,get_step(D,D.dir),1)
		D.Weaken(4)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return 1
	add_logs(A, D, "back-kicked (Sleeping Carp)")
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/kneeStomach(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] knees [D] in the stomach!</span>", \
						  "<span class='userdanger'>[A] winds you with a knee in the stomach!</span>")
		D.audible_message("<b>[D]</b> gags!")
		D.losebreath += 3
		D.Stun(2)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return 1
	add_logs(A, D, "stomach kneed (Sleeping Carp)")
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/headKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] kicks [D] in the head!</span>", \
						  "<span class='userdanger'>[A] kicks you in the jaw!</span>")
		D.apply_damage(20, BRUTE, "head")
		D.drop_item()
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.Stun(4)
		return 1
	add_logs(A, D, "head kicked (Sleeping Carp)")
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/elbowDrop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(D.weakened || D.resting || D.stat)
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] elbow drops [D]!</span>", \
						  "<span class='userdanger'>[A] piledrives you with their elbow!</span>")
		if(D.stat)
			D.death() //FINISH HIM!
		D.apply_damage(50, BRUTE, "chest")
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		return 1
	add_logs(A, D, "elbow dropped (Sleeping Carp)")
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	if(A.grab_state >= GRAB_AGGRESSIVE)
		D.grabbedby(A, 1)
	else
		A.start_pulling(D, 1)
		if(A.pulling)
			D.drop_all_held_items()
			D.stop_pulling()
			add_logs(A, D, "grabbed", addition="aggressively")
			A.grab_state = GRAB_AGGRESSIVE //Instant aggressive grab
	return 1

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(rand(10,15), BRUTE)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[D] stumbles and falls!</span>", "<span class='userdanger'>The blow sends you to the ground!</span>")
		D.Weaken(4)
	add_logs(A, D, "[atk_verb] (Sleeping Carp)")
	return 1


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	return ..()

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	usr << "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>"

	usr << "<span class='notice'>Wrist Wrench</span>: Disarm Disarm. Forces opponent to drop item in hand."
	usr << "<span class='notice'>Back Kick</span>: Harm Grab. Opponent must be facing away. Knocks down."
	usr << "<span class='notice'>Stomach Knee</span>: Grab Harm. Knocks the wind out of opponent and stuns."
	usr << "<span class='notice'>Head Kick</span>: Disarm Harm Harm. Decent damage, forces opponent to drop item in hand."
	usr << "<span class='notice'>Elbow Drop</span>: Harm Disarm Harm Disarm Harm. Opponent must be on the ground. Deals huge damage, instantly kills anyone in critical condition."

//ITEMS

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)
	return

/obj/item/weapon/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/weapon/storage/belt/champion/wrestling/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_belt)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/weapon/storage/belt/champion/wrestling/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_belt) == src)
		style.remove(H)
	return

/obj/item/weapon/plasma_fist_scroll
	name = "frayed scroll"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/weapon/plasma_fist_scroll/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/plasma_fist/F = new/datum/martial_art/plasma_fist(null)
		F.teach(H)
		H << "<span class='boldannounce'>You have learned the ancient martial art of Plasma Fist.</span>"
		used = 1
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

/obj/item/weapon/sleeping_carp_scroll
	name = "mysterious scroll"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

/obj/item/weapon/sleeping_carp_scroll/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	user << "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles \
	directed toward you. However, you are also unable to use any ranged weaponry. You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>"
	var/datum/martial_art/the_sleeping_carp/theSleepingCarp = new(null)
	theSleepingCarp.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src] lights up in fire and quickly burns to ash.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/weapon/CQC_scroll
	name = "frayed scroll"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/weapon/CQC_scroll/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/CQC/F = new/datum/martial_art/CQC(null)
		F.teach(H)
		H << "<span class='boldannounce'>You have learned CQC.</span>"
		used = 1
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

/obj/item/weapon/twohanded/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = 4
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 24
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bostaff0"
	block_chance = 50

/obj/item/weapon/twohanded/bostaff/update_icon()
	icon_state = "bostaff[wielded]"
	return

/obj/item/weapon/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((CLUMSY in user.disabilities) && prob(50))
		user << "<span class ='warning'>You club yourself over the head with [src].</span>"
		user.Weaken(3)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_bodypart_damage(2*force)
		return
	if(isrobot(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		user << "<span class='warning'>It would be dishonorable to attack a foe while they cannot retaliate.</span>"
		return
	if(user.a_intent == "disarm")
		if(!wielded)
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
									  "[user] smacks [H] with the butt of [src]!", \
									  "[user] broadsides [H] with [src]!", \
									  "[user] smashes [H]'s head with [src]!", \
									  "[user] beats [H] with front of [src]!", \
									  "[user] twirls and slams [H] with [src]!")
		H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
							   "<span class='userdanger'>[pick(fluffmessages)]</span>")
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		H.adjustStaminaLoss(rand(13,20))
		if(prob(10))
			H.visible_message("<span class='warning'>[H] collapses!</span>", \
								   "<span class='userdanger'>Your legs give out!</span>")
			H.Weaken(4)
		if(H.staminaloss && !H.sleeping)
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking them out cold!</span>", \
									   "<span class='userdanger'>[user] knocks you unconscious!</span>")
				H.SetSleeping(30)
				H.adjustBrainLoss(25)
	else
		return ..()

/obj/item/weapon/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(wielded)
		return ..()
	return 0

#define SLAM_COMBO "GH"
#define KICK_COMBO "HH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DG"
#define CONSECUTIVE_COMBO "HHD"
/datum/martial_art/CQC
	name = "CQC"
	help_verb = /mob/living/carbon/human/proc/CQC_help

/datum/martial_art/CQC/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,SLAM_COMBO))
		streak = ""
		Slam(A,D)
		return 1
	if(findtext(streak,KICK_COMBO))
		streak = ""
		Kick(A,D)
		return 1
	if(findtext(streak,RESTRAIN_COMBO))
		streak = ""
		Restrain(A,D)
		return 1
	if(findtext(streak,PRESSURE_COMBO))
		streak = ""
		Pressure(A,D)
		return 1
	if(findtext(streak,CONSECUTIVE_COMBO))
		streak = ""
		Consecutive(A,D)
		return 1
	return 0

/datum/martial_art/CQC/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		D.visible_message("<span class='warning'>[A] slams [D] into the ground!</span>", \
						  	"<span class='userdanger'>[A] slams you into the ground!</span>")
		playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Weaken(6)
		add_logs(A, D, "CQC slammed")
	return 1

/datum/martial_art/CQC/proc/Kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		D.visible_message("<span class='warning'>[A] kicks [D] back!</span>", \
							"<span class='userdanger'>[A] kicks you back!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 1, 14, A)
		D.apply_damage(10, BRUTE)
		add_logs(A, D, "CQC kicked")
	if(D.weakened || D.resting || D.lying)
		D.visible_message("<span class='warning'>[A] kicks [D]'s head, knocking them out!</span>", \
					  	"<span class='userdanger'>[A] kicks your head, knocking you out!</span>")
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		D.SetSleeping(15)
	return 1

/datum/martial_art/CQC/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] forces their arm on [D]'s neck!</span>")
	D.adjustStaminaLoss(60)
	playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
	var/obj/item/weapon/gun/I = D.get_active_held_item()
	if (istype(I) && I.can_shoot())
		D.visible_message("<span class='warning'>[D] panics and fires their weapon blindly!</span>", \
							"<span class='userdanger'>[A] forces their arm on your neck! It hurts! You fire your weapon blindly!</span>")
		I.shoot_live_shot(D, pointblank = 0, null, message = 1)
	return 1

/datum/martial_art/CQC/proc/Restrain(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] locks [D] into a restraining position!</span>", \
						"<span class='userdanger'>[A] locks you into a restraining position!</span>")
	if("disarm")
		D.visible_message("<span class='warning'>[A] puts [D] into a choke hold!</span>", \
							"<span class='userdanger'>[A] puts you into a choke hold, you pass out!</span>")
		D.SetSleeping(20)
	var/obj/item/weapon/kitchen/knife/combat/I = A.get_active_held_item()
	if (istype(I) && "harm")
		D.visible_message("<span class='warning'>[A] slits [D]'s throat!</span>", \
							"<span class='userdanger'>[A] slits your throat!</span>")
		D.apply_damage(10, BRUTE)
	return 1

/datum/martial_art/CQC/proc/Consecutive(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		D.visible_message("<span class='warning'>[A] strikes [D]'s abdomen, neck and back consecutively</span>", \
							"<span class='userdanger'>[A] strikes your abdomen, neck and back consecutively!</span>")
		D.adjustStaminaLoss(70)
		D.apply_damage(20, BRUTE)
	return 1

/datum/martial_art/CQC/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	if(A.grab_state >= GRAB_AGGRESSIVE)
		D.grabbedby(A, 1)
	else
		A.start_pulling(D, 1)
		if(A.pulling)
			D.stop_pulling()
			add_logs(A, D, "grabbed", addition="aggressively")
			A.grab_state = GRAB_AGGRESSIVE //Instant aggressive grab

	return 1

/datum/martial_art/CQC/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	add_logs(A, D, "CQC'd")
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC'd", "Big Bossed")
	var/bonus_damage = 10
	if(D.weakened || D.resting || D.lying)
		bonus_damage += 5
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps")
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_logs(A, D, "[picked_hit_type] with CQC")
	return 1

/datum/martial_art/CQC/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	if(prob(70))
		var/obj/item/I = D.get_active_held_item()
		if(I)
			D.drop_item()
			A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
							"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	add_logs(A, D, "disarmed with krav maga")
	return 1

/mob/living/carbon/human/proc/CQC_help()
	set name = "Recall Teachings"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"

	usr << "<b><i>You try to remember some of the basics of CQC.</i></b>"

	usr << "<span class='notice'>Slam</span>: Grab Harm. Slam opponent into the ground, weakens and knocks down."
	usr << "<span class='notice'>CQC Kick</span>: Harm Harm. Knocks opponent away. Knocks out stunned or weakened opponents."
	usr << "<span class='notice'>Restrain</span>: Grab Grab. Locks opponents into a restraining position, disarm to knock them out with a choke hold or stab with a knife to slit throat."
	usr << "<span class='notice'>Pressure</span>: Disarm Grab. Decent stamina damage, forces opponent to fire any held weapons blindly."


