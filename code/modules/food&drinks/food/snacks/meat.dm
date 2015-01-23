/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/sosjerky

/obj/item/weapon/reagent_containers/food/snacks/meat/New()
	..()
	peakReagents = list("nutriment", 3)
	src.bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/meat/synthmeat
	name = "synthmeat"
	desc = "A synthetic slab of meat."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/slime
	icon_state = "slimemeat"
	desc = "Because jello wasn't offensive enough to vegans"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/slime/New()
	..()
	peakReagents = list("slimejelly", 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem
	icon_state = "golemmeat"
	desc = "Edible rocks, welcome to the future"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem/New()
	..()
	peakReagents = list("iron", 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = "From the slime pen to the rune to the kitchen, science"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = "Delicious dino damage"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/plant
	icon_state = "plantmeat"
	desc = "All the joys of healthy eating with all the fun of cannibalism"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = "Ow, the edge"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/fly
	icon_state = "flymeat"
	desc = "Nothing says tasty like maggot filled radioactive mutant flesh"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/fly/New()
	..()
	peakReagents = list("uranium", 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/skeleton
	name = "-bone"
	icon_state = "skeletonmeat"
	desc = "There's a point where this needs to stop and clearly we have passed it"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/zombie
	name = "-meat (rotten)"
	icon_state = "lizardmeat" //Close enough.
	desc = "Halfway to becoming fertilizer for your garden."

/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/pug
	name = "Pug meat"
	desc = "Tastes like... well you know..."