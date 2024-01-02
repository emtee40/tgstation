/obj/structure/spawner/ice_moon/demonic_portal/blobspore
	mob_types = list(/mob/living/basic/blob_minion/spore)
	spawn_time = 300
	faction = list(FACTION_WASTELAND)

/obj/structure/spawner/ice_moon/demonic_portal/hivebot
	mob_types = list(/mob/living/basic/hivebot/rapid)
	spawn_time = 300
	faction = list(FACTION_WASTELAND)

/**
 * Drops loot from the portal. Uses variable difficulty based on drops- more valulable rewards will also add additional enemies to the attack wave.
 * If you manage to win big and get a bunch of major rich loot, you will also be faced with a big mob of angries.
 * Absolutely deranged use of probability code below, trigger warning
 */

/obj/effect/collapsing_demonic_portal/drop_loot()
	visible_message("<span class='warning'>Something slips out of [src]!</span>")
	var/loot = rand(1, 24)
	switch(loot)
		if(1)//Clown hell. God help you if you roll this.
			visible_message("<span class='userdanger'>You can hear screaming and joyful honking.</span>")//now THIS is what we call a critical failure
			//playsound(loc,'sound/spookoween/ghosty_wind.ogg', 100, FALSE, 50, TRUE, TRUE)
			//playsound(loc,'sound/spookoween/scary_horn3.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(35))
				new /mob/living/basic/clown/clownhulk(loc)
			new /mob/living/basic/clown/longface(loc)
			if(prob(35))
				new /mob/living/basic/clown/banana(loc)
			if(prob(35))
				new /mob/living/basic/clown/fleshclown(loc)
				new /mob/living/basic/clown/fleshclown(loc)
			new /mob/living/basic/clown/honkling(loc)
			if(prob(35))
				new /mob/living/basic/clown/clownhulk/chlown(loc)
			if(prob(25))
				new /mob/living/basic/clown/mutant(loc)//oh god oh fuck
			if(prob(25))
				new /obj/item/veilrender/honkrender/honkhulkrender(loc)
			else
				new /obj/item/veilrender/honkrender(loc)
			if(prob(25))
				new /obj/item/storage/backpack/duffelbag/clown/syndie(loc)
				new /mob/living/basic/clown/fleshclown(loc)
			else
				new /obj/item/storage/backpack/duffelbag/clown/cream_pie(loc)
			if(prob(25))
				new /obj/item/borg/upgrade/transform/clown(loc)
				new /mob/living/basic/clown(loc)
			if(prob(25))
				new /obj/item/megaphone/clown(loc)
				new /mob/living/basic/clown(loc)
			if(prob(25))
				//new /obj/item/clothing/suit/space/hardsuit/clown
				new /mob/living/basic/clown/fleshclown(loc)
			if(prob(25))
				new /obj/item/gun/magic/staff/honk(loc)
				new /mob/living/basic/clown/fleshclown(loc)
			if(prob(15))
				new /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat(loc)
				new /mob/living/basic/clown/fleshclown(loc)
			if(prob(15))//you lost
				new /obj/item/hand_item/circlegame(loc)
			new /obj/item/stack/sheet/mineral/bananium(loc)
			new /turf/open/floor/mineral/bananium(loc)
		if(2)//basic demonic incursion
			visible_message("<span class='userdanger'>You glimpse an indescribable abyss in the portal. Horrifying monsters appear in a gout of flame.</span>")
			playsound(loc,'sound/hallucinations/wail.ogg', 200, FALSE, 50, TRUE, TRUE)
			if(prob(25))
				new /obj/item/clothing/glasses/godeye(loc)
				new /mob/living/basic/migo(loc)
			if(prob(35))
				new /obj/item/wisp_lantern(loc)
				new /mob/living/basic/blankbody(loc)
			if(prob(10))
				new /obj/item/his_grace(loc)//trust me, it's not worth the trouble.
				new /mob/living/basic/migo(loc)
				new /mob/living/basic/blankbody(loc)
			if(prob(35))
				new /obj/item/nullrod/staff(loc)
			if(prob(50))
				//new /obj/item/clothing/suit/space/hardsuit/quixote/dimensional(loc)
			else
				new /obj/item/immortality_talisman(loc)
			if(prob(25))
				new /obj/item/shared_storage/red(loc)
				new /mob/living/basic/blankbody(loc)
			new /mob/living/basic/migo(loc)
			new /mob/living/basic/creature(loc)
			new /turf/open/indestructible/necropolis(loc)
		if(3)//skeleton/religion association, now accepting YOUR BONES
			visible_message("<span class='userdanger'>Bones rattle and strained voices chant a forgotten god's name.</span>")
			playsound(loc,'sound/ambience/ambiholy.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(50))
				new /obj/item/reagent_containers/cup/bottle/potion/flight(loc)
			else
				new /obj/item/clothing/neck/necklace/memento_mori(loc)
				new /mob/living/basic/skeleton(loc)
			if(prob(25))
				new /obj/item/storage/box/holy_grenades(loc)
				new /mob/living/basic/skeleton/templar(loc)
			if(prob(35))
				new /obj/item/claymore(loc)
			if(prob(25))
				new /obj/item/gun/ballistic/bow(loc)
				new /obj/item/storage/bag/quiver(loc)
				//new /obj/item/ammo_casing/caseless/arrow/bronze(loc)
				//new /obj/item/ammo_casing/caseless/arrow/bronze(loc)
				//new /obj/item/ammo_casing/caseless/arrow/bronze(loc)
				//new /obj/item/ammo_casing/caseless/arrow/bronze(loc)
				//new /obj/item/ammo_casing/caseless/arrow/bronze(loc)
				new /mob/living/basic/skeleton/templar(loc)
			if(prob(35))
				new /obj/item/stack/sheet/mineral/wood/fifty(loc)
				new /mob/living/basic/skeleton(loc)
			if(prob(25))
				new /obj/item/staff/bostaff(loc)
				new /mob/living/basic/skeleton(loc)
			if(prob(35))
				new /obj/item/disk/design_disk/cleric_mace(loc)
				new /mob/living/basic/skeleton(loc)
			if(prob(25))
				new /obj/item/shield/roman(loc)
				new /mob/living/basic/skeleton(loc)
			if(prob(25))
				new /obj/item/clothing/suit/armor/riot/knight/blue(loc)
				new /obj/item/clothing/head/helmet/knight/blue(loc)
				new /mob/living/basic/skeleton(loc)
			if(prob(35))
				new /obj/item/disk/design_disk/knight_gear(loc)
				new /mob/living/basic/skeleton(loc)
			new /obj/item/instrument/trombone(loc)
			new /obj/item/stack/sheet/bone(loc)
			new /obj/item/stack/sheet/bone(loc)
			new /obj/item/stack/sheet/bone(loc)
			new /obj/item/stack/sheet/bone(loc)
			new /mob/living/basic/skeleton/templar(loc)
			new /turf/open/floor/mineral/silver(loc)
		if(4)//hogwart's school of witchcraft and wizardry. Featuring incredible loot at incredibly low chances
			visible_message("<span class='userdanger'>You hear phantom whispers. Candlelight and magic ooze through the dying portal.</span>")
			//playsound(loc,'sound/spookoween/ghost_whisper.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(15))
				new /obj/item/organ/internal/heart/cursed/wizard(loc)
			if(prob(25))
				new /obj/item/book/granter/action/spell/summonitem(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(25))
				new /obj/item/book/granter/action/spell/random(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(15))
				new /obj/item/book/granter/action/spell/sacredflame(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(15))
				//new /obj/item/book/granter/action/spell/shapechange(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(20))
				//new /obj/item/book/granter/action/spell/cards(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(15))
				new /obj/item/gun/magic/staff/chaos(loc)
				new /mob/living/simple_animal/hostile/dark_wizard(loc)
			if(prob(15))
				new /obj/item/mjollnir(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(15))
				new /obj/item/singularityhammer(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(15))
				new /obj/item/book/granter/action/spell/charge(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(10))
				new /obj/item/book/granter/action/spell/fireball(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(15))
				new /obj/item/gun/magic/wand/polymorph(loc)
				new /mob/living/basic/wizard(loc)
			if(prob(25))
				new /obj/item/guardian_creator/wizard(loc)
				new /mob/living/basic/wizard(loc)
			new /obj/item/upgradescroll(loc)
			new /obj/item/gun/magic/wand/fireball/inert(loc)
			new /mob/living/simple_animal/hostile/dark_wizard(loc)
			new /turf/open/floor/wood/ebony(loc)
		if(5)//syndicate incursion. Again, high-quality loot at low chances, this time with excessive levels of danger
			visible_message("<span class='userdanger'>Radio chatter echoes out from the portal. Red-garbed figures step through, weapons raised.</span>")
			//playsound(loc,'sound/effects/radiohiss.ogg', 200, FALSE, 50, TRUE, TRUE)
			playsound(loc,'sound/ambience/antag/tatoralert.ogg', 75, FALSE, 50, TRUE, TRUE)
			if(prob(25))
				if(prob(25))
					new /obj/item/mod/control/pre_equipped/elite(loc)
				else
					new /obj/item/mod/control/pre_equipped/traitor(loc)
				new /mob/living/basic/trooper/syndicate/ranged/smg/space(loc)
			if(prob(25))//the real prize
				new /obj/effect/spawner/random/food_or_drink/donkpockets(loc)
				new /obj/effect/spawner/random/food_or_drink/donkpockets(loc)
				new /obj/effect/spawner/random/food_or_drink/donkpockets(loc)
			if(prob(25))
				new /obj/item/clothing/shoes/magboots/syndie(loc)
			if(prob(25))
				new /obj/item/gun/ballistic/automatic/pistol/suppressed(loc)
				new /obj/item/ammo_box/magazine/
				new /mob/living/basic/trooper/syndicate/melee/sword(loc)
			if(prob(25))
				//new /obj/item/gun/ballistic/automatic/pistol/tec9(loc)
				new /mob/living/basic/trooper/syndicate/melee/sword(loc)
			if(prob(25))
				new /obj/item/clothing/gloves/rapid(loc)
				new /mob/living/basic/trooper/syndicate/melee/sword/space(loc)
			if(prob(25))
				new /obj/item/wrench/combat(loc)
				new /obj/item/storage/toolbox/syndicate(loc)
				new /mob/living/basic/trooper/syndicate/melee/sword/space(loc)
			if(prob(25))
				new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(loc)
			if(prob(15))
				//new /obj/item/borg/upgrade/transform/assault(loc)
				new /mob/living/basic/trooper/syndicate/ranged/smg(loc)
			if(prob(15))
				//new /obj/item/antag_spawner/nuke_ops/borg_tele/commando(loc)
				new /mob/living/basic/trooper/syndicate/ranged/smg(loc)
			if(prob(25))
				new /mob/living/basic/trooper/syndicate/melee/sword/space(loc)
				new /obj/item/guardian_creator/tech(loc)
			if(prob(25))
				new /mob/living/basic/trooper/syndicate/melee/sword(loc)
				new /obj/item/storage/backpack/duffelbag/syndie/c4(loc)
			if(prob(35))
				new /obj/item/storage/belt/military(loc)
			if(prob(25))
				//new /obj/item/kinetic_crusher/syndie(loc)
				new /mob/living/basic/trooper/syndicate/ranged/smg(loc)
			if(prob(25))
				new /obj/item/card/id/advanced/black/syndicate_command(loc)
			if(prob(25))
				new /obj/item/clothing/glasses/thermal/syndi(loc)
				new /mob/living/basic/trooper/syndicate/melee/sword(loc)
			if(prob(25))
				new /obj/item/shield/energy(loc)
				new /mob/living/basic/trooper/syndicate/ranged/shotgun(loc)
			if(prob(25))
				new /obj/item/reagent_containers/hypospray(loc)
				new /mob/living/basic/trooper/syndicate/ranged/shotgun(loc)
			if(prob(15))
				new /obj/item/card/emag(loc)
			new /mob/living/basic/trooper/syndicate/ranged/smg/space(loc)
			new /mob/living/basic/trooper/syndicate/melee/sword/space(loc)
			new /turf/open/floor/mineral/plastitanium/red(loc)
		if(6)//;HELP BLOB IN MEDICAL
			visible_message("<span class='userdanger'>You hear a robotic voice saying something about a \"Delta-level biohazard\".</span>")
			//playsound(loc,'sound/ai/outbreak5.ogg', 100, FALSE, 50, TRUE, TRUE)
			playsound(loc,'sound/misc/bloblarm.ogg', 50, FALSE, 50, TRUE, TRUE)
			if(prob(35))
				//new /obj/item/storage/box/hypospray/CMO(loc)
				new /mob/living/basic/blob_minion/spore/minion/weak(loc)
			if(prob(10))
				new /obj/item/gun/medbeam(loc)
				new /mob/living/simple_animal/hostile/blob/blobbernaut/independent(loc)
			if(prob(35))
				new /obj/item/defibrillator(loc)
				new /mob/living/basic/blob_minion/spore/minion/weak(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/sleeper(loc)
			if(prob(35))
				new /obj/item/stack/medical/suture/medicated(loc)
			if(prob(35))
				new /obj/item/stack/medical/mesh/advanced(loc)
			if(prob(25))
				new /obj/item/gun/syringe/syndicate(loc)
				new /mob/living/basic/blob_minion/spore/minion/weak(loc)
			if(prob(25))
				new /obj/item/healthanalyzer/advanced(loc)
			if(prob(35))
				new /obj/item/storage/medkit/advanced(loc)
				new /mob/living/basic/blob_minion/spore/minion/weak(loc)
			if(prob(25))
				new /obj/item/storage/medkit/tactical(loc)
				new /mob/living/basic/blob_minion/spore/minion/weak(loc)
			else
				new /obj/item/storage/medkit/regular(loc)
			if(prob(35))
				new /obj/item/rod_of_asclepius(loc)
			if(prob(25))
				new /obj/effect/mob_spawn/human/corpse/solgov/infantry(loc)
			else
				new /obj/effect/mob_spawn/corpse/human/doctor(loc)
			if(prob(25))
				new /obj/effect/mob_spawn/human/corpse/solgov/infantry(loc)
			else
				new /obj/effect/mob_spawn/corpse/human/doctor(loc)
			if(prob(25))
				new /obj/effect/mob_spawn/human/corpse/solgov/infantry(loc)
			else
				new /obj/effect/mob_spawn/corpse/human/doctor(loc)
			new /obj/item/healthanalyzer(loc)
			//new /turf/open/floor/carpet/nanoweave/beige(loc)
			new /mob/living/simple_animal/hostile/blob/blobbernaut/independent(loc)
			new /mob/living/basic/blob_minion/spore/minion/weak(loc)
			new /mob/living/basic/blob_minion/spore/minion/weak(loc)
		if(7)//teleporty ice world. Incomplete.
			visible_message("<span class='userdanger'>You glimpse a frozen, empty plane. Something stirs in the fractal abyss.</span>")
			playsound(loc,'sound/ambience/ambisin3.ogg', 150, FALSE, 50, TRUE, TRUE)
			if(prob(35))
				new /obj/item/warp_cube/red(loc)
				new /mob/living/simple_animal/hostile/asteroid/ice_demon(loc)
			if(prob(25))
				new /obj/item/clothing/suit/costume/drfreeze_coat(loc)
				new /obj/item/clothing/under/costume/drfreeze(loc)
				new /mob/living/simple_animal/hostile/asteroid/ice_demon(loc)
			if(prob(30))
				new /obj/item/gun/magic/wand/teleport(loc)
				new /mob/living/simple_animal/hostile/asteroid/ice_demon(loc)
			if(prob(30))
				new /obj/item/freeze_cube(loc)
				new /mob/living/simple_animal/hostile/asteroid/ice_demon(loc)
			if(prob(45))
				new /obj/item/clothing/shoes/winterboots/ice_boots(loc)
				new /mob/living/basic/bear/snow(loc)
				new /obj/effect/decal/remains/human(loc)
			new /mob/living/simple_animal/hostile/asteroid/ice_demon(loc)
			new /turf/open/misc/ice/smooth(loc)
		if(8)//FUCK FUCK HELP SWARMERS IN VAULT
			visible_message("<span class='userdanger'>Something beeps. Small, glowing forms spill out of the portal en masse!</span>")
			playsound(loc,'sound/ambience/ambitech.ogg', 150, FALSE, 50, TRUE, TRUE)
			//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(35))
				new /obj/item/construction/rcd/loaded(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(35))
				new /obj/item/holosign_creator/atmos(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				new /obj/item/circuitboard/machine/vendor(loc)
				new /obj/item/vending_refill/engivend(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(45))
				new /obj/item/tank/jetpack/oxygen(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				new /obj/item/stack/sheet/iron/fifty(loc)
				new /obj/item/grenade/chem_grenade/smart_metal_foam(loc)
				new /obj/item/grenade/chem_grenade/smart_metal_foam(loc)
				new /obj/item/grenade/chem_grenade/smart_metal_foam(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				new /obj/item/stack/sheet/iron/fifty(loc)
				new /obj/item/clothing/glasses/meson/engine(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				new /obj/item/stack/sheet/iron/twenty(loc)
				new /obj/
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				new /obj/item/storage/toolbox/syndicate(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				new /obj/machinery/portable_atmospherics/canister/oxygen(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
			if(prob(25))
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
				//new /mob/living/simple_animal/hostile/swarmer/ai(loc)
				new /obj/item/clothing/gloves/tinkerer(loc)
			new /obj/effect/mob_spawn/corpse/human/engineer(loc)
			new /turf/open/floor/circuit/telecomms(loc)
		if(9)//Literally blood-drunk.
			visible_message("<span class='userdanger'>Blood sprays from the portal. An ichor-drenched figure steps through!</span>")
			playsound(loc,'sound/magic/enter_blood.ogg', 150, FALSE, 50, TRUE, TRUE)
			new /obj/effect/gibspawner/human(loc)
			new /obj/effect/gibspawner/human(loc)
			new /obj/effect/gibspawner/human(loc)
			new /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/doom(loc)
			//if(prob(50))
				//new /obj/item/gem/bloodstone(loc)
			if(prob(25))
				new /obj/item/seeds/tomato/blood(loc)
			new /turf/open/misc/asteroid/basalt(loc)
		if(10)//Now's your chance to be a [[BIG SHOT]]
			visible_message("<span class='userdanger'>You hear the sound of big money and bigger avarice.</span>")
			playsound(loc,'sound/lavaland/cursed_slot_machine_jackpot.ogg', 150, FALSE, 50, TRUE, TRUE)
			new /obj/structure/cursed_slot_machine(loc)
			if(prob(25))
				new /obj/item/stack/spacecash/c1000(loc)
				new /obj/item/stack/spacecash/c1000(loc)
				new /obj/item/coin/gold(loc)
				new /mob/living/basic/faithless(loc)
			if(prob(25))
				//new /obj/item/clothing/mask/spamton(loc)
				new /mob/living/basic/faithless(loc)
			if(prob(25))
				//new /obj/item/gem/fdiamond(loc)
				new /mob/living/basic/faithless(loc)
			//else
				//new /obj/item/gem/rupee(loc)
			if(prob(35))
				new /obj/item/coin/gold(loc)
				new /obj/item/coin/gold(loc)
				//new /obj/item/stack/sheet/mineral/gold/twenty(loc)
			if(prob(35))
				new /obj/item/storage/fancy/cigarettes/cigpack_robustgold(loc)
			if(prob(35))
				new /obj/item/clothing/head/collectable/petehat(loc)
				new /mob/living/basic/faithless(loc)
			new /mob/living/basic/faithless(loc)
			new /mob/living/basic/faithless(loc)
			new /turf/open/floor/mineral/gold(loc)
		if(11)//hivebot factory
			visible_message("<span class='userdanger'>You catch a brief glimpse of a vast production complex. One of the assembly lines outputs through the portal!</span>")
			playsound(loc,'sound/ambience/antag/clockcultalr.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(45))
				//new /obj/item/stack/sheet/mineral/adamantine/ten(loc)
				//new /obj/item/stack/sheet/mineral/runite/ten(loc)
				//new /obj/item/stack/sheet/mineral/mythril/ten(loc)
				new /mob/living/basic/hivebot(loc)
			if(prob(25))
				//new /obj/item/stack/sheet/mineral/adamantine/ten(loc)
				//new /obj/item/stack/sheet/mineral/runite/ten(loc)
				//new /obj/item/stack/sheet/mineral/mythril/ten(loc)
				new /mob/living/basic/hivebot(loc)
			if(prob(15))
				//new /obj/item/stack/sheet/mineral/adamantine/ten(loc)
				//new /obj/item/stack/sheet/mineral/runite/ten(loc)
				//new /obj/item/stack/sheet/mineral/mythril/ten(loc)
				new /mob/living/basic/hivebot/strong(loc)
			if(prob(25))
				//new /obj/item/stack/sheet/mineral/silver/twenty(loc)
				//new /obj/item/stack/sheet/mineral/titanium/twenty(loc)
				//new /obj/item/stack/sheet/mineral/gold/twenty(loc)
				new /mob/living/basic/hivebot/strong(loc)
			if(prob(25))
				new /obj/item/circuitboard/computer/solar_control(loc)
				new /obj/item/electronics/tracker(loc)
				new /obj/item/solar_assembly(loc)
				new /obj/item/solar_assembly(loc)
				new /obj/item/solar_assembly(loc)
				new /obj/item/solar_assembly(loc)
			if(prob(35))
				new /obj/item/stack/circuit_stack(loc)
				new /mob/living/basic/hivebot/mechanic(loc)
			if(prob(35))
				//new /obj/item/circuitboard/machine/bluespace_miner(loc)
				new /mob/living/basic/hivebot/range(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/dna_vault(loc)
				new /mob/living/basic/hivebot/mechanic(loc)
				new /obj/item/dna_probe(loc)
				new /obj/item/dna_probe(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/dna_vault(loc)
				new /mob/living/basic/hivebot/mechanic(loc)
				new /obj/item/dna_probe(loc)
				new /obj/item/dna_probe(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/dna_vault(loc)
				new /mob/living/basic/hivebot/mechanic(loc)
				new /obj/item/dna_probe(loc)
				new /obj/item/dna_probe(loc)
			if(prob(45))
				//new /obj/item/stack/sheet/mineral/adamantine/ten(loc)
				//new /obj/item/stack/sheet/mineral/runite/ten(loc)
				//new /obj/item/stack/sheet/mineral/mythril/ten(loc)
				new /mob/living/basic/hivebot/strong(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/medipen_refiller(loc)
				new /mob/living/basic/hivebot(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/stasis(loc)
				new /mob/living/basic/hivebot(loc)
			if(prob(50))
				//new /obj/item/stack/sheet/iron/fifty(loc)
				new /obj/item/stack/sheet/glass/fifty(loc)
				new /obj/item/stack/cable_coil(loc)
				new /obj/item/storage/box/lights/bulbs(loc)
				new /mob/living/basic/hivebot(loc)
			new /mob/living/basic/hivebot(loc)
			new /mob/living/basic/hivebot/strong(loc)
			new /obj/machinery/conveyor(loc)
			new /turf/open/floor/circuit/red(loc)
		if(12)//miner's last moments
			visible_message("<span class='userdanger'>The familiar sound of an ash storm greets you. A miner steps through the portal, stumbles, and collapses.</span>")
			playsound(loc,'sound/weather/ashstorm/outside/weak_end.ogg', 150, FALSE, 50, TRUE, TRUE)
			if(prob(25))
				new /obj/item/disk/design_disk/modkit_disc/resonator_blast(loc)
			if(prob(25))
				new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(loc)
			if(prob(15))
				new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(loc)
			if(prob(25))
				new /obj/item/disk/design_disk/modkit_disc/bounty(loc)
			if(prob(35))
				new /obj/item/circuitboard/computer/order_console/mining(loc)
			if(prob(45))
				new /mob/living/simple_animal/hostile/asteroid/goliath/beast(loc)
			if(prob(35))
				new /obj/item/reagent_containers/hypospray/medipen/survival(loc)
			if(prob(35))
				new /obj/item/fulton_core(loc)
				new /obj/item/extraction_pack(loc)
				new /mob/living/simple_animal/hostile/asteroid/goliath/beast(loc)
			if(prob(35))
				new /obj/item/t_scanner/adv_mining_scanner/lesser(loc)
				new /mob/living/simple_animal/hostile/asteroid/goliath/beast(loc)
			if(prob(50))
				new /obj/item/kinetic_crusher(loc)
			else
				new /obj/item/gun/energy/recharge/kinetic_accelerator(loc)
			new /mob/living/simple_animal/hostile/asteroid/goliath/beast(loc)
			new /mob/living/simple_animal/hostile/asteroid/goliath/beast(loc)
			new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(loc)
			//new /obj/effect/mob_spawn/human/miner/old(loc)
			new /turf/open/misc/asteroid/basalt(loc)
		if(13)//sailing the ocean blue
			visible_message("<span class='userdanger'>Water pours out of the portal, followed by a strange vessel. It's occupied.</span>")
			playsound(loc,'sound/ambience/shore.ogg', 150, FALSE, 50, TRUE, TRUE)
			new /obj/vehicle/ridden/lavaboat/dragon(loc)
			new /obj/item/oar(loc)
			if(prob(50))
				new /obj/item/clothing/under/costume/sailor(loc)
			if(prob(50))
				//ew /obj/item/pneumatic_cannon/speargun(loc)
				//new /obj/item/storage/backpack/magspear_quiver(loc)
				//new /obj/item/throwing_star/magspear(loc)
				//new /obj/item/throwing_star/magspear(loc)
				//new /obj/item/throwing_star/magspear(loc)
				//new /obj/item/throwing_star/magspear(loc)
				//new /obj/item/throwing_star/magspear(loc)
				new /mob/living/basic/carp(loc)
			if(prob(45))
				//new /obj/item/clothing/suit/space/hardsuit/carp(loc)
				new /mob/living/basic/carp(loc)
			if(prob(35))
				new /obj/item/gun/magic/hook(loc)
				new /mob/living/basic/carp(loc)
			if(prob(45))
				new /obj/item/food/fishmeat/carp(loc)
				new /obj/item/food/fishmeat/carp(loc)
			if(prob(25))
				new /obj/item/guardian_creator/carp(loc)
				new /mob/living/basic/carp/mega(loc)
			if(prob(10))
				new /obj/item/book/granter/martial/carp(loc)
				new /mob/living/basic/carp/mega(loc)
			if(prob(25))
				new /obj/item/grenade/spawnergrenade/spesscarp(loc)
				new /mob/living/basic/carp/mega(loc)
			new /mob/living/basic/carp/mega(loc)
			new /mob/living/basic/carp(loc)
			new /turf/open/water(loc)
		if(14)//hydroponics forest
			visible_message("<span class='userdanger'>You catch a glimpse of a strange forest. Smells like weed and bad choices.</span>")
			playsound(loc,'sound/ambience/shore.ogg', 150, FALSE, 50, TRUE, TRUE)
			if(prob(35))
				new /obj/item/circuitboard/machine/biogenerator(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/seed_extractor(loc)
				new /mob/living/basic/venus_human_trap(loc)
			if(prob(35))
				//new /obj/item/circuitboard/machine/plantgenes(loc)
			else
				new /obj/item/circuitboard/machine/hydroponics(loc)
			if(prob(15))
				new /obj/item/seeds/gatfruit(loc)
				new /mob/living/basic/venus_human_trap(loc)
			if(prob(45))
				new /obj/item/seeds/random(loc)
			if(prob(45))
				new /obj/item/seeds/random(loc)
			if(prob(45))
				new /obj/item/seeds/random(loc)
			if(prob(45))
				new /obj/item/seeds/cannabis(loc)
			new /obj/item/clothing/gloves/botanic_leather(loc)
			new /obj/item/cultivator/rake(loc)
			new /obj/structure/spacevine(loc)
			new /mob/living/basic/venus_human_trap(loc)
			new /turf/open/misc/grass(loc)
		if(15)//fallout ss13
			visible_message("<span class='userdanger'>You hear a geiger counter click and smell ash.</span>")
			playsound(loc,'sound/items/radiostatic.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(50))
				new /obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola(loc)
				new /obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola(loc)
				new /obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola(loc)
				new /mob/living/basic/cockroach/glockroach(loc)
			if(prob(50))
				new /obj/structure/radioactive/stack(loc)
				new /mob/living/basic/cockroach/glockroach(loc)
			if(prob(45))
				//new /obj/item/stack/sheet/mineral/uranium/twenty(loc)
				new /mob/living/basic/cockroach/glockroach(loc)
			if(prob(35))
				new /obj/item/clothing/head/utility/radiation(loc)
				new /obj/item/clothing/suit/utility/radiation(loc)
			if(prob(35))
				new /mob/living/basic/cockroach/glockroach(loc)
			new /obj/item/geiger_counter(loc)
			new /mob/living/basic/cockroach/glockroach(loc)
			new /turf/open/misc/dirt(loc)

		if(16)//the cultists amoung us
			visible_message("<span class='userdanger'>Chanting and a hateful red glow spill through the portal.</span>")
			//playsound(loc,'sound/spookoween/ghost_whisper.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(50))
				new /obj/item/soulstone/anybody(loc)
				new /obj/item/soulstone/anybody(loc)
				new /obj/structure/constructshell(loc)
				new /mob/living/basic/construct/proteon/hostile(loc)
			if(prob(45))
				new /obj/item/borg/upgrade/modkit/lifesteal(loc)
				new /obj/item/bedsheet/cult(loc)
				new /mob/living/basic/construct/wraith/hostile(loc)
			if(prob(50))
				new /obj/item/stack/sheet/runed_metal/ten(loc)
			if(prob(35))
				new /obj/item/sharpener/cult(loc)
				new /mob/living/basic/construct/artificer/hostile(loc)
			if(prob(15))
				new /obj/item/cult_bastard(loc)
				new /mob/living/basic/construct/juggernaut/hostile(loc)
			if(prob(25))
				new /obj/item/cult_shift(loc)
				new /mob/living/basic/construct/proteon/hostile(loc)
			if(prob(45))
				//new /obj/item/gem/bloodstone(loc)
				new /mob/living/basic/construct/proteon/hostile(loc)
			if(prob(35))
				//new /obj/item/nullrod/scythe/talking/necro(loc)
				new /mob/living/basic/construct/proteon/hostile(loc)
			if(prob(35))
				new /obj/item/clothing/suit/hooded/cultrobes/hardened(loc)
				new /mob/living/basic/construct/artificer/hostile(loc)
			new /mob/living/basic/construct/juggernaut/hostile(loc)
			new /mob/living/basic/construct/wraith/hostile(loc)
			new /obj/structure/destructible/cult/pylon(loc)
			new /turf/open/floor/cult(loc)
		if(17)//the backroom freezer
			visible_message("<span class='userdanger'>The faint hallogen glow of a faraway kitchen greets you.</span>")
			if(prob(45))
				new /obj/item/knife/bloodletter(loc)
				new /mob/living/simple_animal/hostile/killertomato(loc)
			if(prob(45))
				new /obj/item/clothing/gloves/butchering(loc)
				new /mob/living/simple_animal/hostile/killertomato(loc)
			if(prob(45))
				new /obj/item/food/bread/meat(loc)
				new /obj/item/food/bread/meat(loc)
				new /obj/item/food/bread/meat(loc)
			if(prob(45))
				new /obj/item/food/cake/trumpet(loc)
			if(prob(35))
				new /obj/item/food/pizza/dank(loc)
			if(prob(25))
				new /obj/item/food/meat/steak/gondola(loc)
				new /mob/living/simple_animal/hostile/killertomato(loc)
			if(prob(25))
				new /obj/item/food/burger/roburger/big(loc)
				new /mob/living/simple_animal/hostile/killertomato(loc)
			if(prob(35))
				new /obj/item/knife/butcher(loc)
				new /mob/living/simple_animal/hostile/killertomato(loc)
			if(prob(25))
				new /obj/item/flamethrower/full(loc)
				new /mob/living/simple_animal/hostile/killertomato(loc)
			new /mob/living/simple_animal/hostile/alien/maid(loc)
			new /turf/open/floor/iron/kitchen_coldroom/freezerfloor(loc)
		if(18)//legion miniboss
			visible_message("<span class='userdanger'>The ground quakes. An immense figure reaches through the portal, crouching to squeeze through.</span>")
			playsound(loc,'sound/magic/knock.ogg', 100, FALSE, 50, TRUE, TRUE)
			new /mob/living/simple_animal/hostile/big_legion(loc)
			if(prob(50))
				new /obj/structure/closet/crate/necropolis/tendril(loc)
			new /turf/open/indestructible/necropolis(loc)
		if(19)//xenobiologist's hubris
			visible_message("<span class='userdanger'>You catch a glimpse of a wobbling sea of slimy friends. An abused-looking keeper slips through the portal.</span>")
			playsound(loc,'sound/effects/footstep/slime1.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(25))
				new /obj/item/slime_extract/adamantine(loc)
			if(prob(25))
				new /obj/item/slime_extract/gold(loc)
			if(prob(45))
				new /obj/item/extinguisher/advanced(loc)
			if(prob(25))
				new /obj/item/slimepotion/slime/renaming(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(25))
				new /obj/item/slimepotion/slime/sentience(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(25))
				new /obj/item/slimepotion/transference(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(35))
				new /obj/item/circuitboard/computer/xenobiology(loc)
				new /obj/item/slime_extract/grey(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/processor/slime(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(45))
				new /obj/item/slime_cookie/purple(loc)
				new /obj/item/slime_cookie/purple(loc)
				new /obj/item/slime_cookie/purple(loc)
			if(prob(25))
				new /obj/item/storage/box/monkeycubes(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(25))
				new /obj/item/slimepotion/speed(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(35))
				new /obj/item/slimepotion/slime/slimeradio(loc)
				new /mob/living/simple_animal/slime/random(loc)
			if(prob(25))
				new /mob/living/basic/pet/dog/corgi/puppy/slime(loc)
			new /obj/effect/mob_spawn/corpse/human/scientist(loc)
			new /turf/open/floor/mineral/titanium/purple(loc)
			new /mob/living/simple_animal/slime/random(loc)
		if(20)//lost abductor
			visible_message("<span class='userdanger'>You glimpse a frigid wreckage. A large block of something slips through the portal.</span>")
			playsound(loc,'sound/effects/break_stone.ogg', 100, FALSE, 50, TRUE, TRUE)
			if(prob(25))
				new /obj/item/stack/sheet/mineral/abductor(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(25))
				new /obj/item/clothing/under/abductor(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(25))
				new /obj/item/weldingtool/abductor(loc)
			if(prob(25))
				new /obj/item/scalpel/alien(loc)
			if(prob(20))
				//new /obj/item/circuitboard/machine/plantgenes/vault(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(20))
				new /obj/item/organ/internal/heart/gland/heal(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(20))
				new /obj/item/organ/internal/heart/gland/ventcrawling(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(20))
				new /obj/item/organ/internal/heart/gland/slime(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(10))
				new /obj/item/organ/internal/heart/gland/spiderman(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(35))
				new /obj/item/wrench/abductor(loc)
				new /obj/item/screwdriver/abductor(loc)
			if(prob(35))
				new /obj/item/crowbar/abductor(loc)
				new /obj/item/multitool/abductor(loc)
			if(prob(25))
				new /obj/item/abductor_machine_beacon/chem_dispenser(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			if(prob(25))
				new /obj/item/clothing/suit/armor/abductor/vest(loc)
				new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			new /obj/structure/fluff/iced_abductor(loc)
			new /mob/living/simple_animal/hostile/asteroid/polarbear(loc)
			new /turf/open/floor/mineral/abductor(loc)
		if(21)//hey, free elite tumor!
			visible_message("<span class='userdanger'>A large, pulsating structure falls through the portal and crashes to the floor.</span>")
			playsound(loc,'sound/effects/break_stone.ogg', 100, FALSE, 50, TRUE, TRUE)
			new /obj/structure/elite_tumor(loc)
			new /turf/open/misc/asteroid/basalt(loc)
		if(22)//*you flush the toilet.*
			visible_message("<span class='userdanger'>You hear the faint noise of a long flush.</span>")
			new /obj/structure/toilet(loc)
			new /obj/effect/decal/remains(loc)
			new /obj/item/newspaper(loc)
			new /turf/open/floor/plastic(loc)
			//new /obj/item/camera/rewind/loot(loc)
		if(23)//Research & Zombies
			visible_message("<span class='userdanger'>Flashing lights and quarantine alarms echo through the portal. You smell rotting flesh and plasma.</span>")
			playsound(loc,'sound/misc/bloblarm.ogg', 120, FALSE, 50, TRUE, TRUE)
			if(prob(35))
				new /obj/item/storage/box/rndboards(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			if(prob(35))
				new /obj/item/stack/spacecash/c1000(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			if(prob(25))
				new /obj/item/storage/box/stockparts/deluxe(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			else
				new /obj/item/storage/box/stockparts(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			if(prob(30))
				new /obj/item/circuitboard/machine/rdserver/ship(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			if(prob(35))
				new /obj/item/research_notes/loot/big(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			else
				new /obj/item/research_notes/loot/medium(loc)
			if(prob(35))
				new /obj/item/research_notes/loot/medium(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			else
				new /obj/item/research_notes/loot/small(loc)
			if(prob(25))
				new /obj/item/pneumatic_cannon(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			if(prob(35))
				new /obj/item/research_notes/loot/medium(loc)
				new /mob/living/simple_animal/hostile/zombie(loc)
			else
				new /obj/item/research_notes/loot/small(loc)
			new/turf/open/floor/mineral/titanium/purple(loc)
			new /mob/living/simple_animal/hostile/zombie(loc)
		if(24)//Silverback's locker room
			visible_message("<span class='userdanger'>You catch a glimpse of verdant green. Smells like a locker room.</span>")
			playsound(loc,'sound/creatures/gorilla.ogg', 75, FALSE, 50, TRUE, TRUE)
			new /mob/living/simple_animal/hostile/gorilla(loc)
			new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(35))
				new /obj/item/circuitboard/machine/dnascanner(loc)
			if(prob(35))
				new /obj/item/circuitboard/computer/scan_consolenew(loc)
			if(prob(15))
				new /obj/item/reagent_containers/hypospray/medipen/magillitis(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(25))
				new /obj/item/dnainjector/thermal(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(25))
				new /obj/item/storage/box/gorillacubes(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(25))
				new /obj/item/dnainjector/hulkmut(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(25))
				new /obj/item/dnainjector/firemut(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(25))
				new /obj/item/dnainjector/gigantism(loc)
			if(prob(35))
				new /obj/item/dnainjector/dwarf(loc)
			if(prob(25))
				//new /obj/item/dnainjector/firebreath(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			if(prob(25))
				new /mob/living/simple_animal/hostile/gorilla(loc)
				new /obj/item/dnainjector/telemut/darkbundle(loc)
			if(prob(35))
				new /obj/item/dnainjector/insulated(loc)
				new /mob/living/simple_animal/hostile/gorilla(loc)
			new /obj/item/sequence_scanner(loc)
			new /obj/structure/flora/grass/jungle(loc)
			new /turf/open/misc/grass/jungle(loc)

