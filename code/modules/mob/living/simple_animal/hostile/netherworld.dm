/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	mob_biotypes = list(MOB_INORGANIC)
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("creature")
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether")

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	speed = -0.5
	hud_type = /datum/hud/migo
	deathmessage = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'
	var/static/list/migo_sounds
	var/hushed = FALSE
	var/impersonation
	var/datum/migo_soundui/migo_soundui

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
	. = ..()
	update_health_hud()
	migo_soundui = new
	migo_soundui.owner = src
	migo_sounds = list('sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg', 'sound/items/deconstruct.ogg', 'sound/items/carhorn.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/megaphone.ogg', 'sound/items/screwdriver.ogg', 'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg', 'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/items/geiger/high1.ogg', 'sound/items/geiger/high2.ogg', 'sound/voice/beepsky/creep.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/ed209_20sec.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss6.ogg', 'sound/voice/medbot/patchedup.ogg', 'sound/voice/medbot/feelbetter.ogg', 'sound/voice/human/manlaugh1.ogg', 'sound/voice/human/womanlaugh.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/clockcultalr.ogg', 'sound/ambience/antag/ling_aler.ogg', 'sound/ambience/antag/tatoralert.ogg', 'sound/ambience/antag/monkey.ogg', 'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg', 'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clockcult_gateway_disrupted.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/curse1.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg', 'sound/effects/empulse.ogg', 'sound/effects/explosion_distant.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/effects/his_grace_awaken.ogg', 'sound/effects/pai_boot.ogg', 'sound/effects/phasein.ogg', 'sound/effects/picaxe1.ogg', 'sound/effects/ratvar_reveal.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg', 'sound/effects/supermatter.ogg', 'sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg', 'sound/misc/bloblarm.ogg', 'sound/misc/airraid.ogg', 'sound/misc/bang.ogg','sound/misc/highlander.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg', 'sound/misc/splort.ogg', 'sound/weapons/armbomb.ogg', 'sound/weapons/beam_sniper.ogg', 'sound/weapons/chainsawhit.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg', 'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg', 'sound/weapons/genhit1.ogg', 'sound/weapons/gunshot_silenced.ogg', 'sound/weapons/gunshot2.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg', 'sound/weapons/kenetic_accel.ogg', 'sound/machines/clockcult/steam_whoosh.ogg', 'sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlockclose.ogg', 'sound/machines/airlockforced.ogg', 'sound/machines/airlockopen.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg', 'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/cryo_warning.ogg', 'sound/machines/defib_charge.ogg', 'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg', 'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/machines/signal.ogg', 'sound/machines/synth_no.ogg', 'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/triple_beep.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg', 'sound/ai/outbreak5.ogg', 'sound/ai/outbreak7.ogg', 'sound/ai/poweroff.ogg', 'sound/ai/radiation.ogg', 'sound/ai/shuttlecalled.ogg', 'sound/ai/shuttledock.ogg', 'sound/ai/shuttlerecalled.ogg', 'sound/ai/aimalf.ogg') //hahahaha fuck you code divers

/mob/living/simple_animal/hostile/netherworld/migo/update_health_hud()
	if(hud_used)
		if(stat)
			hud_used.healths.icon_state = "mi-go_health7"
		else if(health >= maxHealth)
			hud_used.healths.icon_state = "mi-go_health0"
		else if(health > maxHealth*0.8)
			hud_used.healths.icon_state = "mi-go_health2"
		else if(health > maxHealth*0.6)
			hud_used.healths.icon_state = "mi-go_health3"
		else if(health > maxHealth*0.4)
			hud_used.healths.icon_state = "mi-go_health4"
		else if(health > maxHealth*0.2)
			hud_used.healths.icon_state = "mi-go_health5"
		else
			hud_used.healths.icon_state = "mi-go_health6"

/mob/living/simple_animal/hostile/netherworld/migo/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(updating_health)
		update_health_hud()

/mob/living/simple_animal/hostile/netherworld/migo/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat || hushed)
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10) && !hushed)
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Logout()
	..()
	hushed = FALSE
	if(impersonation)
		ChangeVoice()

/mob/living/simple_animal/hostile/netherworld/migo/GetVoice()
	if(impersonation)
		return impersonation
	return "[src]"

/mob/living/simple_animal/hostile/netherworld/migo/proc/Hush()
	set name = "Hush"
	set category = "Nether"
	set desc = "Toggles passive noises and noises when you talk."
	if(hushed)
		hushed = FALSE
		to_chat(src, "<span class='notice'>You will now occasionally mimic noises in this dimension.</span>")
	else
		hushed = TRUE
		to_chat(src, "<span class='notice'>You decide against mimicking noises for now.</span>")

/mob/living/simple_animal/hostile/netherworld/migo/proc/ChangeVoice()//hey, not returning null in this is important! don't @ me!
	set name = "Tune Voice"
	set category = "Nether"
	set desc = "Changes your voice to someone else. You will copy the voice patterns if the name matches them."
	if(impersonation)
		if(client)
			to_chat(src, "<span class='notice'>You are no longer impersonating [impersonation].</span>")
		speak_emote = initial(speak_emote)
		impersonation = null
		return TRUE
	else
		var/t = copytext(sanitize(input(src, "Enter the name of your victim!", "Mimic", name) as text), 1, MAX_NAME_LEN)
		if(!t || t == "Unknown" || t == "floor" || t == "wall" || t == "r-wall") //Same as mob/dead/new_player/prefrences.dm
			if(t)
				alert("I can't mimic that!")
				return FALSE
		var/success = FALSE
		var/list/new_speak_emote = list()
		for(var/mob/living/simple_animal/speakmobs in GLOB.alive_mob_list)//this attempts to automatically copy the speak emotes of a mob if they're a simple animal
			if(t == speakmobs.name)
				for(var/i in speakmobs.speak_emote)
					new_speak_emote += i
				success = TRUE
				break
		if(success)
			to_chat(src, "<span class='notice'>Noticing that [t] is a creature, you copy their voice patterns!</span>")
		else
			new_speak_emote += "says"
		to_chat(src, "<span class='notice'>You tune your cords into [t]!</span>")
		impersonation = t
		speak_emote = new_speak_emote
		return TRUE

/mob/living/simple_animal/hostile/netherworld/migo/proc/CreateNoise()
	set name = "Fabricate Noise"
	set category = "Nether"
	set desc = "Creates a specific noise. Some noises are more intensive on the vocal cords, and will need longer times inbetween creation."
	if(!migo_soundui || !migo_soundui.owner)
		to_chat(src, "<span class='notice'>For some reason, your inner workings are all fucked. You should report this on github!</span>")
		return
	migo_soundui.ui_interact(src)

/datum/migo_soundui //WARNING: THIS CODE IS AN ABOMINATION. PLEASE DON'T COPY PASTE IT AND ALLOW IT TO SPREAD!
	var/mob/living/owner
	var/selected_sound
	var/cooldown

/datum/migo_soundui/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, \
force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)//ui_interact is called when the client verb is called.

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "migo_soundui", owner.name, 700, 700, master_ui, state)
		ui.open()

/datum/migo_soundui/ui_data(mob/user)
	var/list/data = list()
	var/isitoncooldown = FALSE
	if(cooldown > world.time)
		isitoncooldown = TRUE
	data["picked"] = selected_sound
	data["onCooldown"] = isitoncooldown
	return data

/datum/migo_soundui/ui_act(action, params)
	if(..())
		return
	if(selected_sound == action)
		return
	if(action != "submit")
		selected_sound = action
		. = TRUE
		return
	if(cooldown >= world.time)
		return
	switch(selected_sound)
		if("screwdriver")
			playsound(owner, 'sound/items/screwdriver.ogg', 100, TRUE)
			cooldown = world.time + 50
		if("wrench")
			playsound(owner, 'sound/items/ratchet.ogg', 100, TRUE)
			cooldown = world.time + 50

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "punches"
	deathmessage = "falls apart into a fine dust."

/mob/living/simple_animal/hostile/spawner/nether
	name = "netherworld link"
	desc = "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>"
	icon_state = "nether"
	icon_living = "nether"
	health = 50
	maxHealth = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	mob_biotypes = list(MOB_INORGANIC)
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/simple_animal/hostile/netherworld/migo, /mob/living/simple_animal/hostile/netherworld, /mob/living/simple_animal/hostile/netherworld/blankbody)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("nether")
	deathmessage = "shatters into oblivion."
	del_on_death = TRUE

/mob/living/simple_animal/hostile/spawner/nether/attack_hand(mob/user)
		user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
						  "<span class='userdanger'>Touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
		contents.Add(user)

/mob/living/simple_animal/hostile/spawner/nether/Life()
	..()
	var/list/C = src.get_contents()
	for(var/mob/living/M in C)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, 1)
			M.adjustBruteLoss(60)
			new /obj/effect/gibspawner/generic(get_turf(M))
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = "It's [M], but [M.p_their()] flesh has an ashy texture, and [M.p_their()] face is featureless save an eerie smile."
				src.visible_message("<span class='warning'>[M] reemerges from the link!</span>")
				qdel(M)
