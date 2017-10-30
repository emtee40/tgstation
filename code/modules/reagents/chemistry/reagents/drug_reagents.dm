/datum/reagent/drug
	name = "Drug"
	id = "drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.canmove)
			if(prob(10)) step(M, pick(GLOB.cardinals))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You start tripping hard!</span>")


/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 30
	taste_description = "smoke"

/datum/reagent/drug/nicotine/on_mob_life(mob/living/M)
	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	M.AdjustStun(-20, 0)
	M.AdjustKnockdown(-20, 0)
	M.AdjustUnconscious(-20, 0)
	M.adjustStaminaLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/menthol
	name = "Menthol"
	id = "menthol"
	description = "Tastes naturally minty, and imparts a very mild numbing sensation."
	taste_description = "mint"
	reagent_state = LIQUID
	color = "#80AF9C"

/datum/reagent/drug/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/drug/krokodil/on_mob_life(mob/living/M)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M)
	M.adjustBrainLoss(0.25*REM)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage1(mob/living/M)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/krokodil/addiction_act_stage2(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='danger'>Your skin feels loose...</span>")
	..()

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='danger'>Your skin starts to peel away...</span>")
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/human/M)
	CHECK_DNA_AND_SPECIES(M)
	if(!istype(M.dna.species, /datum/species/krokodil_addict))
		to_chat(M, "<span class='userdanger'>Your skin falls off easily!</span>")
		M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
		M.set_species(/datum/species/krokodil_addict)
	else
		M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1


/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Makes you nearly impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_threshold = 10
	taste_description = "salt" // because they're bathsalts?


/datum/reagent/drug/bath_salts/on_mob_life(mob/living/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustStun(-60, 0)
	M.AdjustKnockdown(-60, 0)
	M.AdjustUnconscious(-60, 0)
	M.adjustStaminaLoss(-5, 0)
	M.adjustBrainLoss(0.5)
	M.adjustToxLoss(0.1, 0)
	M.hallucination += 10
	if(M.canmove && !ismovableatom(M.loc))
		step(M, pick(GLOB.cardinals))
		step(M, pick(GLOB.cardinals))
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	M.hallucination += 10
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i in 1 to 8)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		M.drop_all_held_items()
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/M)
	M.hallucination += 10
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(5)
	M.adjustBrainLoss(10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/M)
	M.hallucination += 20
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustBrainLoss(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/M)
	M.hallucination += 30
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i = 0, i < 12, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustBrainLoss(10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/human/M)
	M.hallucination += 40
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i = 0, i < 16, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(50)
	M.Dizzy(50)
	M.adjustToxLoss(5, 0)
	M.adjustBrainLoss(10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "Amps you up and gets you going, fixes all stamina damage you might have but can cause toxin and oxygen damage.."
	reagent_state = LIQUID
	color = "#78FFF0"

/datum/reagent/drug/aranesp/on_mob_life(mob/living/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustStaminaLoss(-18, 0)
	M.adjustToxLoss(0.5, 0)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = 1


//Amphetamines
//Amphetamine sulfate
/datum/reagent/drug/amphetamine
	name = "Amphetamine"
	id = "amphetamine"
	description = "A potent CNS stimulant renowned for it's innocuous metabolization. Dangerous in high doses."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 30
	addiction_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM


/datum/reagent/drug/amphetamine/on_mob_life(mob/living/M)
	var/high_message = pick("You feel hyper.", "You have a pit in your stomach.", "Your head is pounding.")
	if(prob(3))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustStun(-2, 0)
	M.AdjustKnockdown(-2, 0)
	M.AdjustUnconscious(-40, 0)
	M.adjustStaminaLoss(-2, 0)
	M.status_flags |= GOTTAGOFAST
	M.Jitter(2)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/amphetamine/overdose_process(mob/living/M)
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinals))
	if(prob(33))
		M.visible_message("<span class='danger'>[M] shivers violently!</span>")
		M.drop_all_held_items()
	..()
	. = 1


/datum/reagent/drug/amphetamine/addiction_act_stage4(mob/living/M)
	if(prob(30))
		M.adjustStaminaLoss(2, 0)
		to_chat(M, "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>")
	return



//Methamphetamine
/datum/reagent/drug/amphetamine/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "Amphetamine with an extra methyl group attached to the N isonomer. While more potent, it is also much more toxic and introduces muscular atrophy due to cortisol release."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_threshold = 3
	metabolization_rate = 1 * REAGENTS_METABOLISM //meth is metabolized quicker. usually because it's smoked or injected, but reagent metabolization code is super primitive so this will do.
	var/heart_attack_chance = 0.001

/datum/reagent/drug/amphetamine/methamphetamine/on_mob_life(mob/living/M)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustStun(-20, 0)
	M.AdjustKnockdown(-20, 0)
	M.AdjustUnconscious(-40, 0)
	M.adjustStaminaLoss(-1, 0)//meth isn't actually that great of a stamina booster.
	M.status_flags |= GOTTAGOREALLYFAST
	M.Jitter(4)
	M.adjustBrainLoss(0.25)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	if(prob(heart_attack_chance))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest() && H.can_heartattack())
				H.set_heartattack(TRUE)
				if(H.stat == CONSCIOUS)
					H.visible_message("<span class='userdanger'>[H] clutches at [H.p_their()] chest as if [H.p_their()] heart stopped!</span>")
					//meth is super cardiotoxic in recreational doses. don't do meth kids.
	if(prob(1))
		M.visible_message("<span class='danger'>[M]'s eyes dart around the room.</span>")
		M.hallucination += 5
	..()
	. = 1



/datum/reagent/drug/amphetamine/methamphetamine/overdose_process(mob/living/M)
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.visible_message("<span class='danger'>[M]'s eyes dart around the room wildly!</span>")
		M.hallucination += 10 //meth psychosis
	if(prob(33))
		M.visible_message("<span class='danger'>[M] shivers violently!</span>")
		M.drop_all_held_items()
	if(prob(heart_attack_chance*100))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest() && H.can_heartattack())
				H.set_heartattack(TRUE)
				if(H.stat == CONSCIOUS)
					H.visible_message("<span class='userdanger'>[H] clutches at [H.p_their()] chest as if [H.p_their()] heart stopped!</span>")
					//meth is super cardiotoxic in recreational doses. don't do meth kids.
	..()
	M.adjustToxLoss(3, 0)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	. = 1



/datum/reagent/drug/amphetamine/methamphetamine/addiction_act_stage1(mob/living/M)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/amphetamine/methamphetamine/addiction_act_stage2(mob/living/M)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/amphetamine/methamphetamine/addiction_act_stage3(mob/living/M)
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/amphetamine/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if(M.canmove && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(20)
	M.Dizzy(20)
	M.hallucination += 10
	M.adjustToxLoss(5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1




//shake and bake meth
/datum/reagent/drug/amphetamine/methamphetamine/crank
	name = "Crank"
	id = "crank"
	description = "Very poorly synthesized methamphetamine."
	reagent_state = LIQUID
	color = "#FA00C8"
	overdose_threshold = 10
	addiction_threshold = 5
	metabolization_rate = 3 * REAGENTS_METABOLISM
	heart_attack_chance = 0.1
