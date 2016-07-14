/datum/game_mode
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/apprentices = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	antag_flag = ROLE_WIZARD
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 14
	round_ends_with_antag_death = 1
	var/use_huds = 0
	var/finished = 0

/datum/game_mode/wizard/announce()
	world << "<B>The current game mode is - Wizard!</B>"
	world << "<B>There is a <span class='danger'>SPACE WIZARD</span>\black on the station. You can't let him achieve his objective!</B>"

/datum/game_mode/wizard/pre_setup()

	var/datum/mind/wizard = pick(antag_candidates)
	wizards += wizard
	modePlayer += wizard
	wizard.assigned_role = "Wizard"
	wizard.special_role = "Wizard"
	if(wizardstart.len == 0)
		wizard.current << "<span class='boldannounce'>A starting location for you could not be found, please report this bug!</span>"
		return 0
	for(var/datum/mind/wiz in wizards)
		wiz.current.loc = pick(wizardstart)

	return 1


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		log_game("[wizard.key] (ckey) has been selected as a Wizard")
		equip_wizard(wizard.current)
		forge_wizard_objectives(wizard)
		if(use_huds)
			update_wiz_icons_added(wizard)
		greet_wizard(wizard)
		name_wizard(wizard.current)
	..()
	return


/datum/game_mode/proc/forge_wizard_objectives(datum/mind/wizard)
	switch(rand(1,100))
		if(1 to 30)

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = wizard
			kill_objective.find_target()
			wizard.objectives += kill_objective

			if (!(locate(/datum/objective/escape) in wizard.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = wizard
				wizard.objectives += escape_objective
		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = wizard
			steal_objective.find_target()
			wizard.objectives += steal_objective

			if (!(locate(/datum/objective/escape) in wizard.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = wizard
				wizard.objectives += escape_objective

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = wizard
			kill_objective.find_target()
			wizard.objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = wizard
			steal_objective.find_target()
			wizard.objectives += steal_objective

			if (!(locate(/datum/objective/survive) in wizard.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = wizard
				wizard.objectives += survive_objective

		else
			if (!(locate(/datum/objective/hijack) in wizard.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = wizard
				wizard.objectives += hijack_objective
	return


/datum/game_mode/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = copytext(sanitize(input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname

		wizard_mob.real_name = newname
		wizard_mob.name = newname
		if(wizard_mob.mind)
			wizard_mob.mind.name = newname
	return


/datum/game_mode/proc/greet_wizard(datum/mind/wizard, you_are=1)
	if (you_are)
		wizard.current << "<span class='boldannounce'>You are the Space Wizard!</span>"
	wizard.current << "<B>The Space Wizards Federation has given you the following tasks:</B>"

	wizard.announce_objectives()
	return


/datum/game_mode/proc/learn_basic_spells(mob/living/carbon/human/wizard_mob)
	if(!istype(wizard_mob) || !wizard_mob.mind)
		return 0
	wizard_mob.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null)) //Wizards get Magic Missile and Ethereal Jaunt by default
	wizard_mob.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))


/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	wizard_mob.set_species(/datum/species/human)
	wizard_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), slot_ears)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(wizard_mob), slot_w_uniform)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), slot_shoes)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), slot_wear_suit)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), slot_head)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(wizard_mob), slot_back)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(wizard_mob), slot_in_backpack)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(wizard_mob), slot_r_store)
	var/obj/item/weapon/spellbook/spellbook = new /obj/item/weapon/spellbook(wizard_mob)
	spellbook.owner = wizard_mob
	wizard_mob.equip_to_slot_or_del(spellbook, slot_r_hand)

	wizard_mob << "You will find a list of available spells in your spell book. Choose your magic arsenal carefully."
	wizard_mob << "The spellbook is bound to you, and others cannot use it."
	wizard_mob << "In your pockets you will find a teleport scroll. Use it as needed."
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	wizard_mob.update_icons()
	return 1


/datum/game_mode/wizard/check_finished()

	for(var/datum/mind/wizard in wizards)
		if(isliving(wizard.current) && wizard.current.stat!=DEAD)
			return ..()

	if(SSevent.wizardmode) //If summon events was active, turn it off
		SSevent.toggleWizardmode()
		SSevent.resetFrequency()

	return ..()

/datum/game_mode/wizard/declare_completion()
	if(finished)
		feedback_set_details("round_end_result","loss - wizard killed")
		world << "<span class='userdanger'>The wizard[(wizards.len>1)?"s":""] has been killed by the crew! The Space Wizards Federation has been taught a lesson they will not soon forget!</span>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_wizard()
	if(wizards.len)
		var/text = "<br><font size=3><b>the wizards/witches were:</b></font>"

		for(var/datum/mind/wizard in wizards)

			text += "<br><b>[wizard.key]</b> was <b>[wizard.name]</b> ("
			if(wizard.current)
				if(wizard.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(wizard.current.real_name != wizard.name)
					text += " as <b>[wizard.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"

			var/count = 1
			var/wizardwin = 1
			for(var/datum/objective/objective in wizard.objectives)
				if(objective.check_completion())
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					feedback_add_details("wizard_objective","[objective.type]|SUCCESS")
				else
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					feedback_add_details("wizard_objective","[objective.type]|FAIL")
					wizardwin = 0
				count++

			if(wizard.current && wizard.current.stat!=2 && wizardwin)
				text += "<br><font color='green'><B>The wizard was successful!</B></font>"
				feedback_add_details("wizard_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The wizard has failed!</B></font>"
				feedback_add_details("wizard_success","FAIL")
			if(wizard.spell_list.len>0)
				text += "<br><B>[wizard.name] used the following spells: </B>"
				var/i = 1
				for(var/obj/effect/proc_holder/spell/S in wizard.spell_list)
					text += "[S.name]"
					if(wizard.spell_list.len > i)
						text += ", "
					i++
			text += "<br>"

		world << text
	return 1

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm.
/mob/proc/spellremove(mob/M)
	if(!mind)
		return
	for(var/X in src.mind.spell_list)
		var/obj/effect/proc_holder/spell/spell_to_remove = X
		qdel(spell_to_remove)
		mind.spell_list -= spell_to_remove

/*Checks if the wizard can cast spells.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/casting()
//Removed the stat check because not all spells require clothing now.
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		usr << "I don't feel strong enough without my robe."
		return 0
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		usr << "I don't feel strong enough without my sandals."
		return 0
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		usr << "I don't feel strong enough without my hat."
		return 0
	else
		return 1

//returns whether the mob is a wizard (or apprentice)
/proc/iswizard(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && ((M.mind in ticker.mode.wizards) || (M.mind in ticker.mode.apprentices))


/datum/game_mode/proc/update_wiz_icons_added(datum/mind/wiz_mind)
	var/datum/atom_hud/antag/wizhud = huds[ANTAG_HUD_WIZ]
	wizhud.join_hud(wiz_mind.current)
	set_antag_hud(wiz_mind.current, ((wiz_mind in wizards) ? "wizard" : "apprentice"))

/datum/game_mode/proc/update_wiz_icons_removed(datum/mind/wiz_mind)
	var/datum/atom_hud/antag/wizhud = huds[ANTAG_HUD_WIZ]
	wizhud.leave_hud(wiz_mind.current)
	set_antag_hud(wiz_mind.current, null)
