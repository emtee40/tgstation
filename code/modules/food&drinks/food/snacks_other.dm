
////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"

/obj/item/weapon/reagent_containers/food/snacks/candy_corn/New()
	..()
	peakReagents = list("nutriment", 4, "sugar", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolatebarunwrapped"
	wrapped = 0
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/New()
	..()
	peakReagents = list("nutriment", 3, "sugar", 2, "coco", 2, "vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/proc/Unwrap(mob/user)
		icon_state = "chocolatebarunwrapped"
		desc = "It won't make you all sticky."
		user << "<span class='notice'>You remove the foil.</span>"
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped
	desc = "It's wrapped in some foil."
	icon_state = "chocolatebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/New()
	..()
	peakReagents = list("nutriment", 3, "vitamin", 1)
	src.bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/popcorn/New()
	..()
	eatverb = pick("bite","crunch","nibble","gnaw","gobble","chomp")
	unpopped = rand(1,10)
	peakReagents = list("nutriment", 2)
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/On_Consume()
	if(prob(unpopped))	//lol ...what's the point? << AINT SO POINTLESS NO MORE
		usr << "<span class='danger'>You bite down on an un-popped kernel, and it hurts your teeth!</span>"
		unpopped = max(0, unpopped-1)
		reagents.add_reagent("sacid",0.1) //only a little tingle.
	..()

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "loaded baked potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato/New()
	..()
	peakReagents = list("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "space fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/fries/New()
	..()
	peakReagents = list("nutriment", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "soy dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/soydope/New()
	..()
	peakReagents = list("nutriment", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "cheesy fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/New()
	..()
	peakReagents = list("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from cook for this."
	icon_state = "badrecipe"

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/New()
	..()
	eatverb = pick("choke down","nibble","gnaw","chomp")
	peakReagents = list("????", 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff/New()
	..()
	peakReagents = list("nutriment", 6, "mushroomhallucinogen", 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/New()
	..()
	peakReagents = list("nutriment", 6, "amatoxin", 6, "mushroomhallucinogen", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "carrot fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/carrotfries/New()
	..()
	peakReagents = list("nutriment", 3, "oculine", 3, "vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"

/obj/item/weapon/reagent_containers/food/snacks/candiedapple/New()
	..()
	peakReagents = list("nutriment", 3, "sugar", 3)
	bitesize = 3

/*
/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore/New()
	..()
	reagents.add_reagent("slimejelly", 5)
	bitesize = 3
*/
/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"

/obj/item/weapon/reagent_containers/food/snacks/mint/New()
	..()
	peakReagents = list("minttoxin", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/wrap/New()
	..()
	peakReagents = list("nutriment", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/beans/New()
	..()
	peakReagents = list("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"

/obj/item/weapon/reagent_containers/food/snacks/spidereggs/New()
	..()
	peakReagents = list("nutriment", 2, "toxin", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chococoin
	name = "chocolate coin"
	desc = "A completely edible but nonflippable festive coin."
	icon_state = "chococoin"

/obj/item/weapon/reagent_containers/food/snacks/chococoin/New()
	..()
	peakReagents = list("nutriment", 3, "sugar", 2, "coco", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocoorange
	name = "chocolate orange"
	desc = "A festive chocolate orange"
	icon_state = "chocoorange"

/obj/item/weapon/reagent_containers/food/snacks/chocoorange/New()
	..()
	peakReagents = list("nutriment", 4, "sugar", 2, "coco", 2)
