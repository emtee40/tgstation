// Apple
/obj/item/seeds/apple
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/apple/gold, /obj/item/seeds/apple/brass)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	filling_color = "#FF4500"
	bitesize = 100 // Always eat the apple in one bite
	foodtype = FRUIT
	juice_results = list("applejuice" = 0)
	tastes = list("apple" = 1)

// Gold Apple
/obj/item/seeds/apple/gold
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/gold
	maturation = 10
	production = 10
	mutatelist = list()
	reagents_add = list("gold" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 40 // Alchemy!

/obj/item/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/apple/gold
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	filling_color = "#FFD700"
	
	// Brass Apple
/obj/item/seeds/apple/brass
	name = "pack of brass apple seeds"
	desc = "These seeds grow into brass apple trees. Store away from machinery."
	icon_state = "seed-goldapple"
	species = "brassapple"
	plantname = "Brass Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/brass
	maturation = 10
	production = 10
	mutatelist = list(/obj/item/seeds/apple/brass/charged)
	reagents_add = list("brass" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 40

/obj/item/reagent_containers/food/snacks/grown/apple/brass
	seed = /obj/item/seeds/apple/brass
	name = "brass apple"
	desc = "You could swear you hear a faint ticking."
	filling_color = "#B5A642"

	// Charged Brass Apple
/obj/item/seeds/apple/brass/charged
	name = "pack of charged brass apple seeds"
	desc = "These seeds grow into charged brass apple trees. Handle with extreme care."
	species = "chargedbrassapple"
	plantname = "Charged Brass Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/brass/charged
	mutatelist = list()
	reagents_add = list("kindlelium" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 10

/obj/item/reagent_containers/food/snacks/grown/apple/brass/charged
	seed = /obj/item/seeds/apple/brass/charged
	name = "charged brass apple"
	desc = "You can feel the whirring of gears inside of this."
