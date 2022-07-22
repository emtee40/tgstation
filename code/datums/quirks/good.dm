//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/addict_resistance
	name = "Addiction Resistance"
	desc = "You have an unaddictive personality."
	icon = "spa"
	value = 4
	mob_trait = TRAIT_ADDICT_RESISTANCE
	gain_text = "<span class='notice'>You feel a strong sence of self dependence!</span>"
	lose_text = "<span class='danger'>Your sence of self dependence goes away.</span>"
	medical_record_text = "Patient demonstrates an abnormaly high level of addiction resistance."

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	icon = "beer"
	value = 4
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"
	medical_record_text = "Patient demonstrates a high tolerance for alcohol."

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You just don't care as much as other people. That's nice to have in a place like this, I guess."
	icon = "meh"
	value = 4
	mood_quirk = TRUE
	medical_record_text = "Patient was administered the Apathy Evaluation Scale but did not bother to complete it."

/datum/quirk/apathetic/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier += 0.2

/datum/quirk/brusier
	name = "Bruiser"
	desc = "You hit a lot harder with your fists"
	icon = "fist-raised"
	value = 6
	gain_text = "<span class='notice'>Your arms feel strong!</span>"
	lose_text = "<span class='danger'>Your arms feel weaker.</span>"
	medical_record_text = "Patient displays pugilistic tendancies"

/datum/quirk/brusier/add()
	if(iscarbon (quirk_holder))
		var/mob/living/carbon/heavy_hitter = quirk_holder
		heavy_hitter.dna.species.punchdamagelow *= 2
		heavy_hitter.dna.species.punchdamagehigh *= 2

/datum/quirk/brusier/remove()
	if(iscarbon (quirk_holder))
		var/mob/living/carbon/heavy_hitter = quirk_holder
		heavy_hitter.dna.species.punchdamagelow /= 2
		heavy_hitter.dna.species.punchdamagehigh /= 2

/datum/quirk/bullet_dodge
	name = "Bullet Dodger"
	desc = "Your flips cost stamina, but let you dodge bullets!"
	icon = "running"
	value = 6
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You like you could dodge anything!</span>"
	lose_text = "<span class='danger'>You don't feel like you could dodge anything anymore.</span>"
	medical_record_text = "Patient's body has been trained for advanced flipping techniques"

/datum/quirk/connoisseur
	name = "Connoisseur"
	desc = "You're a fan of fine food and drink."
	icon = "drumstick-bite"
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	mood_quirk = TRUE
	gain_text = "<span class='notice'>Your tastebuds feel lively!</span>"
	lose_text = "<span class='danger'>Your tastebuds dull.</span>"
	medical_record_text = "Patient's pallet is exeptionally refined"

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	icon = "wine-bottle"
	value = 8
	gain_text = "<span class='notice'>You feel like a drink would do you good.</span>"
	lose_text = "<span class='danger'>You no longer feel like drinking would ease your pain.</span>"
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."
	processing_quirk = TRUE

/datum/quirk/drunkhealing/process(delta_time)
	switch(quirk_holder.get_drunk_amount())
		if (6 to 40)
			quirk_holder.adjustBruteLoss(-0.1 * delta_time, FALSE)
			quirk_holder.adjustFireLoss(-0.05 * delta_time)
		if (41 to 60)
			quirk_holder.adjustBruteLoss(-0.4 * delta_time, FALSE)
			quirk_holder.adjustFireLoss(-0.2 * delta_time)
		if (61 to INFINITY)
			quirk_holder.adjustBruteLoss(-0.8 * delta_time, FALSE)
			quirk_holder.adjustFireLoss(-0.4 * delta_time)

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	icon = "smile-beam"
	value = 8
	mob_trait = TRAIT_EMPATH
	gain_text = "<span class='notice'>You feel in tune with those around you.</span>"
	lose_text = "<span class='danger'>You feel isolated from others.</span>"
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."

/datum/quirk/expert_sleeper
	name = "Expert Sleeper"
	desc = "You are the king of snoozing."
	icon = "bed"
	value = 4
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You fell comfortable!</span>"
	lose_text = "<span class='danger'>You fell less comfortable!</span>"
	medical_record_text = "Patient has an abnormally consistant circadian rythems"

/datum/quirk/item_quirk/clown_enjoyer
	name = "Clown Enjoyer"
	desc = "You enjoy clown antics and get a mood boost from wearing your clown pin."
	icon = "map-pin"
	value = 2
	mob_trait = TRAIT_CLOWN_ENJOYER
	gain_text = "<span class='notice'>You are a big enjoyer of clowns.</span>"
	lose_text = "<span class='danger'>The clown doesn't seem so great.</span>"
	medical_record_text = "Patient reports being a big enjoyer of clowns."

/datum/quirk/item_quirk/clown_enjoyer/add_unique()
	give_item_to_holder(/obj/item/clothing/accessory/clown_enjoyer_pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/clown_enjoyer/add()
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(quirk_holder)

/datum/quirk/item_quirk/mime_fan
	name = "Mime Fan"
	desc = "You're a fan of mime antics and get a mood boost from wearing your mime pin."
	icon = "thumbtack"
	value = 2
	mob_trait = TRAIT_MIME_FAN
	gain_text = "<span class='notice'>You are a big fan of the Mime.</span>"
	lose_text = "<span class='danger'>The mime doesn't seem so great.</span>"
	medical_record_text = "Patient reports being a big fan of mimes."

/datum/quirk/item_quirk/mime_fan/add_unique()
	give_item_to_holder(/obj/item/clothing/accessory/mime_fan_pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/mime_fan/add()
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(quirk_holder)

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly and take no damage from short falls."
	icon = "running"
	value = 8
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"
	medical_record_text = "Patient scored highly on cardio tests."

/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	icon = "hands-helping"
	value = 2
	mob_trait = TRAIT_FRIENDLY
	gain_text = "<span class='notice'>You want to hug someone.</span>"
	lose_text = "<span class='danger'>You no longer feel compelled to hug others.</span>"
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates low-inhibitions for physical contact and well-developed arms. Requesting another doctor take over this case."

/datum/quirk/fireproof
	name = "Fireproof"
	desc = "Due to training, natural aptitude, or digesting large quantities of Aerogel as a child, your skin has developed a resistance to fire."
	icon = "fire"
	value = 8
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel resistant to fire!</span>"
	lose_text = "<span class='danger'>You no longer feel resistant to fire.</span>"
	medical_record_text = "Patient's skin shows natural resistance to fire."

/datum/quirk/indefatigable
	name = "Indefatigable"
	desc = "Through consistant exersize and good lifestyle choices you have an increased stamina pool."
	icon = "heartbeat"
	value = 8
	mob_trait = TRAIT_FRIENDLY
	gain_text = "<span class='notice'>You feel like you could run a mile.</span>"
	lose_text = "<span class='danger'>You feel tired.</span>"
	medical_record_text = "Patient has an exelent diet and exersises consistantly, well done."

/datum/quirk/iron_stomach
	name = "Iron Stomach"
	desc = "You can handel gross food better than most. Your strong stomach doesn't make it taste any better, but it does help you keep it down."
	icon = "pizza-slice"
	value = 2
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	medical_record_text = "Patient has exquisit gastro-intestial fortitude"

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	icon = "grin"
	value = 4
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates constant euthymia irregular for environment. It's a bit much, to be honest."

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; footsteps and stepping on sharp objects is quieter and less painful. Also, your hands and clothes will not get messed in case of stepping in blood."
	icon = "shoe-prints"
	value = 4
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>You walk with a little more litheness.</span>"
	lose_text = "<span class='danger'>You start tromping around like a barbarian.</span>"
	medical_record_text = "Patient's dexterity belies a strong capacity for stealth."

/datum/quirk/light_eater
	name = "Light Eater"
	desc = "You've never been a a big food guy."
	icon = "pizza-slice"
	value = 3
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You don't feel like eating all that much.</span>"
	lose_text = "<span class='danger'>You feel like you could probably use a bite to eat.</span>"
	medical_record_text = "Patient has a slower than average matabolism."

/datum/quirk/item_quirk/masochist
	name = "Masochist"
	desc = "Something about physical pain soothes your mind and soul."
	icon = "brain"
	value = 4
	mob_trait = TRAIT_MASOCHIST
	mood_quirk = TRUE
	gain_text = "<span class='notice'>You enjoy the sensation of pain.</span>"
	lose_text = "<span class='danger'>You realize that pain hurts.</span>"
	medical_record_text = "Patient displays machochistic tendencies."

/datum/quirk/item_quirk/musician
	name = "Musician"
	desc = "You can tune handheld musical instruments to play melodies that clear certain negative effects and soothe the soul."
	icon = "guitar"
	value = 2
	mob_trait = TRAIT_MUSICIAN
	gain_text = "<span class='notice'>You know everything about musical instruments.</span>"
	lose_text = "<span class='danger'>You forget how musical instruments work.</span>"
	medical_record_text = "Patient brain scans show a highly-developed auditory pathway."

/datum/quirk/item_quirk/musician/add_unique()
	give_item_to_holder(/obj/item/choice_beacon/music, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	icon = "eye"
	value = 4
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>The shadows seem a little less dark.</span>"
	lose_text = "<span class='danger'>Everything seems a little darker.</span>"
	medical_record_text = "Patient's eyes show above-average acclimation to darkness."

/datum/quirk/night_vision/add()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/remove()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/proc/refresh_quirk_holder_eyes()
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/internal/eyes/eyes = human_quirk_holder.getorgan(/obj/item/organ/internal/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	// We've either added or removed TRAIT_NIGHT_VISION before calling this proc. Just refresh the eyes.
	eyes.refresh()

/datum/quirk/quick_learner
	name = "Quick Learner"
	desc = "You pick up on skills quicker than most people."
	icon = "chalkboard-teacher"
	value = 3
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>You feel ready to learn.</span>"
	lose_text = "<span class='danger'>You feel like learning if for chumps.</span>"
	medical_record_text = "Patient shows unwarented enthusiasm for picking up new skills."

/datum/quirk/robust_genetics
	name = "Robust Genetics"
	desc = "You have an advanced capacity for genetic mutations."
	icon = "dna"
	value = 5
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>You feel ready to learn.</span>"
	lose_text = "<span class='danger'>You feel like learning if for chumps.</span>"
	medical_record_text = "Patient's DNA is very well structured as resistant to genetic collapse."

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	icon = "bone"
	value = 8
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."

/datum/quirk/skittish
	name = "Skittish"
	desc = "You're easy to startle, and hide frequently. Run into a closed locker to jump into it, as long as you have access. You can walk to avoid this."
	icon = "trash"
	value = 8
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."

/datum/quirk/skater
	name = "Skater"
	desc = "You're a pro skater."
	icon = "bicycle"
	value = 6
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient wouldn't shut up about how good they are at skateboarding."

/datum/quirk/item_quirk/spiritual
	name = "Spiritual"
	desc = "You hold a spiritual belief, whether in God, nature or the arcane rules of the universe. You gain comfort from the presence of holy people, and believe that your prayers are more special than others. Being in the chapel makes you happy."
	icon = "bible"
	value = 4
	mob_trait = TRAIT_SPIRITUAL
	gain_text = "<span class='notice'>You have faith in a higher power.</span>"
	lose_text = "<span class='danger'>You lose faith!</span>"
	medical_record_text = "Patient reports a belief in a higher power."

/datum/quirk/item_quirk/spiritual/add_unique()
	give_item_to_holder(/obj/item/storage/fancy/candle_box, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(/obj/item/storage/box/matches, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/super_immune
	name = "Super Immune"
	desc = "You have a robust immune system."
	icon = "pills"
	value = 4
	mob_trait = TRAIT_SPIRITUAL
	medical_record_text = "Patient has a hightened immune system."

/datum/quirk/item_quirk/sweet_tooth
	name = "Sweet tooth"
	desc = "You have a thing for sweets, they make you feel happy."
	icon = "cookie-bite"
	value = 2
	mob_trait = TRAIT_SPIRITUAL
	mood_quirk = TRUE
	gain_text = "<span class='notice'>You want somthing sweet.</span>"
	lose_text = "<span class='danger'>You loose your drive for something sweet.</span>"
	medical_record_text = "Patient has poor dental enamel due to an abnormal desire for sugar."

/datum/quirk/item_quirk/thick_skin
	name = "Thick Skin"
	desc = "Your skin is tough as leather, leaving you resistant to blunt and slashing wounds."
	icon = "shield-alt"
	value = 6
	mob_trait = TRAIT_THICK_SKIN
	medical_record_text = "Patient has abnormally thick skin."

/datum/quirk/item_quirk/tough_feet
	name = "Tough Feet"
	desc = "The skin on your feet is hard and calloused. You don't suffer the effects of caltrop-like effects while barefoot."
	icon = "shield-alt"
	value = 6
	mob_trait = TRAIT_SPIRITUAL
	medical_record_text = "Patient has abnormally thick skin."

/datum/quirk/item_quirk/robust_physique
	name = "Built From Stronger Stuff"
	desc = "You have robust physique, allowing you to take more punishment."
	icon = "user-astronaut"
	value = 10
	mob_trait = TRAIT_SPIRITUAL
	medical_record_text = "Patient has an unnaturally robust physique."

/datum/quirk/robust_physique/add()
	if(iscarbon (quirk_holder))
		var/mob/living/tough_guy = quirk_holder
		tough_guy.maxHealth *= 1.2
		tough_guy.health *= 1.2

/datum/quirk/robust_physique/remove()
	if(iscarbon(quirk_holder))
		var/mob/living/tough_guy = quirk_holder
		tough_guy.maxHealth /= 1.2
		tough_guy.health /= 1.2

/datum/quirk/item_quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. People will actually be impressed by your graffiti, and you can get twice as many uses out of drawing supplies."
	icon = "spray-can"
	value = 4
	mob_trait = TRAIT_TAGGER
	gain_text = "<span class='notice'>You know how to tag walls efficiently.</span>"
	lose_text = "<span class='danger'>You forget how to tag walls properly.</span>"
	medical_record_text = "Patient was recently seen for possible paint huffing incident."

/datum/quirk/item_quirk/tagger/add_unique()
	give_item_to_holder(/obj/item/toy/crayon/spraycan, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	icon = "drumstick-bite"
	value = 4
	mob_trait = TRAIT_VORACIOUS
	gain_text = "<span class='notice'>You feel HONGRY.</span>"
	lose_text = "<span class='danger'>You no longer feel HONGRY.</span>"
