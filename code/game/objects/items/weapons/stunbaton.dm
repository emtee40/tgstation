/obj/item/weapon/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 50, bio = 0, rad = 0, fire = 80, acid = 80)

	var/stunforce = 7
	var/status = 0
	var/shitcurity = 0
	var/obj/item/weapon/stock_parts/cell/high/bcell = null
	var/hitcost = 1000
	var/throw_hit_chance = 35

/obj/item/weapon/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/weapon/melee/baton/New()
	..()
	update_icon()
	return

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom)
	..()
	//Only mob/living types have stun handling
	if(status && prob(throw_hit_chance) && isliving(hit_atom))
		baton_stun(hit_atom)

/obj/item/weapon/melee/baton/loaded/New() //this one starts with a cell pre-installed.
	..()
	bcell = new(src)
	update_icon()

/obj/item/weapon/melee/baton/proc/deductcharge(chrgdeductamt)
	if(bcell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = bcell.use(chrgdeductamt)
		if(status && bcell.charge < hitcost)
			//we're below minimum, turn off
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)


/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
	else
		icon_state = "[initial(name)]"

/obj/item/weapon/melee/baton/examine(mob/user)
	..()
	if(bcell)
		user <<"<span class='notice'>The baton is [round(bcell.percent())]% charged.</span>"
	else
		user <<"<span class='warning'>The baton does not have a power source installed.</span>"

/obj/item/weapon/melee/baton/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/C = W
		if(bcell)
			user << "<span class='notice'>[src] already has a cell.</span>"
		else
			if(C.maxcharge < hitcost)
				user << "<span class='notice'>[src] requires a higher capacity cell.</span>"
				return
			if(!user.unEquip(W))
				return
			W.loc = src
			bcell = W
			user << "<span class='notice'>You install a cell in [src].</span>"
			update_icon()

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			user << "<span class='notice'>You remove the cell from [src].</span>"
			status = 0
			update_icon()
	else
		return ..()

/obj/item/weapon/melee/baton/attack_self(mob/user)
	if(bcell && bcell.charge > hitcost)
		status = !status
		user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		if(!bcell)
			user << "<span class='warning'>[src] does not have a power source!</span>"
		else
			user << "<span class='warning'>[src] is out of charge.</span>"
	update_icon()
	add_fingerprint(user)

/obj/item/weapon/melee/baton/AltClick(mob/user)
	shitcurity = !shitcurity
	user << "<span class='notice'>You will [shitcurity ? "now" : "no longer"] strike terror into the hearts of criminals.</span>"

/obj/item/weapon/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(status && user.disabilities & CLUMSY && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits themself with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	if(iscyborg(M))
		..()
		return

	var/mob/living/carbon/human/L = M
	if(!istype(L))
		return

	if(check_martial_counter(L, user))
		return 

	if(user.a_intent != INTENT_HARM)
		if(status)
			if(baton_stun(L, user))
				user.do_attack_animation(L)
				return
		else
			L.visible_message("<span class='warning'>[user] has prodded [L] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
	else
		if(status)
			baton_stun(L, user)
			if(user.real_name == user.name && shitcurity) //only say it if you aren't disguised
				user.say("[pick("STOP RESISTING ARREST", "YOU HAVE THE RIGHT TO REMAIN SILENT", "REACH FOR THE SKY", "DROP THE WEAPON", "IF YOU CAN'T DO THE TIME, DON'T DO THE CRIME", \
			"I AM THE LAW", "SELF-DEFENSE", "I AM JUDGE, JURY, AND EXECUTIONER", "PEOPLE LIKE YOU ARE RUINING THIS STATION", "LIZARD LIVES DON'T MATTER")]!!")
		..()


/obj/item/weapon/melee/baton/proc/baton_stun(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(0, "[user]'s [name]", src, MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	L.Stun(stunforce)
	L.Weaken(stunforce)
	L.apply_effect(STUTTER, stunforce)
	if(user)
		user.lastattacked = L
		L.lastattacker = user
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		add_logs(user, L, "stunned")

	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(hit_appends)


	return 1

/obj/item/weapon/melee/baton/emp_act(severity)
	deductcharge(1000 / severity)
	..()

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/weapon/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	item_state = "prod"
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stunforce = 5
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = SLOT_BACK
	var/obj/item/device/assembly/igniter/sparkler = 0

/obj/item/weapon/melee/baton/cattleprod/New()
	..()
	sparkler = new (src)

/obj/item/weapon/melee/baton/cattleprod/baton_stun()
	if(sparkler.activate())
		..()

/obj/item/weapon/melee/baton/cattleprod/AltClick(mob/user)
	return