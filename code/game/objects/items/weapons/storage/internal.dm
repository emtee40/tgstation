/obj/item/weapon/storage/internal
	storage_slots = 2
	max_w_class = 2
	max_combined_w_class = 50 // Limited by slots, not combined weight class
	w_class = 4

/obj/item/weapon/storage/internal/ClickAccesible(mob/user, depth=1)
	if(loc)
		return loc.ClickAccesible(user, depth)

/obj/item/weapon/storage/internal/Adjacent(A)
	if(loc)
		return loc.Adjacent(A)

/obj/item/weapon/storage/internal/pocket
	var/priority = TRUE
	// TRUE if opens when clicked, like a backpack.
	// FALSE if opens only when dragged on mob's icon (hidden pocket)
	var/quickdraw = FALSE
	// TRUE if you can quickdraw items from it with alt-click.

/obj/item/weapon/storage/internal/pocket/New()
	..()
	if(loc)
		name = loc.name

/obj/item/weapon/storage/internal/pocket/big
	max_w_class = 3

/obj/item/weapon/storage/internal/pocket/small
	storage_slots = 1
	priority = FALSE

/obj/item/weapon/storage/internal/pocket/tiny
	storage_slots = 1
	max_w_class = 1
	priority = FALSE

/obj/item/weapon/storage/internal/pocket/shoes
	can_hold = list(
		/obj/item/weapon/kitchen/knife, /obj/item/weapon/switchblade, /obj/item/weapon/pen,
		/obj/item/weapon/scalpel, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/hypospray/medipen, /obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/implanter, /obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool/mini,
		/obj/item/device/firing_pin
		)
	//can hold both regular pens and energy daggers. made for your every-day tactical librarians/murderers.
	priority = FALSE
	quickdraw = TRUE
	silent = TRUE

/obj/item/weapon/storage/internal/pocket/shoes/clown
	can_hold = list(
		/obj/item/weapon/kitchen/knife, /obj/item/weapon/switchblade, /obj/item/weapon/pen,
		/obj/item/weapon/scalpel, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/hypospray/medipen, /obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/implanter, /obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool/mini,
		/obj/item/device/firing_pin, /obj/item/weapon/bikehorn)

/obj/item/weapon/storage/internal/pocket/small/detective
	priority = TRUE // so the detectives would discover pockets in their hats

/obj/item/weapon/storage/internal/pocket/small/detective/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/flask/det(src)

/*
/proc/isstorage(var/atom/A)
	if(istype(A, /obj/item/weapon/storage))
		return 1

	if(istype(A, /obj/item/clothing))
		var/obj/item/clothing/C = A
		if(C.pockets) return 1*/