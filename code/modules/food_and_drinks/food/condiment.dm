
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "condiment bottle"
	desc = "Just your average condiment bottle."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	inhand_icon_state = "beer" //Generic held-item sprite until unique ones are made.
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = OPENCONTAINER
	obj_flags = UNIQUE_RENAME
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	volume = 50
	fill_icon_thresholds = list(0, 10, 25, 50, 75, 100)
	/// Icon (icon_state) to be used when container becomes empty (no change if falsy)
	var/icon_empty
	/// Holder for original icon_state value if it was overwritten by icon_emty to change back to
	var/icon_preempty

/obj/item/reagent_containers/food/condiment/update_icon_state()
	. = ..()
	if (reagents.reagent_list.len)
		if (icon_preempty)
			icon_state = icon_preempty
			icon_preempty = null
	else
		if (icon_empty && !icon_preempty)
			icon_preempty = icon_state
			icon_state = icon_empty

/obj/item/reagent_containers/food/condiment/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is trying to eat the entire [src]! It looks like [user.p_they()] forgot how food works!</span>")
	return OXYLOSS

/obj/item/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return FALSE

	if(!canconsume(M, user))
		return FALSE

	if(M == user)
		user.visible_message("<span class='notice'>[user] swallows some of the contents of \the [src].</span>", \
			"<span class='notice'>You swallow some of the contents of \the [src].</span>")
	else
		M.visible_message("<span class='warning'>[user] attempts to feed [M] from [src].</span>", \
			"<span class='warning'>[user] attempts to feed you from [src].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The condiment might be empty after the delay.
		M.visible_message("<span class='warning'>[user] fed [M] from [src].</span>", \
			"<span class='warning'>[user] fed you from [src].</span>")
		log_combat(user, M, "fed", reagents.log_list())
	reagents.trans_to(M, 10, transfered_by = user, methods = INGEST)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	return TRUE

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_drainable() || IS_EDIBLE(target))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>you can't add anymore to [target]!</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>")

/obj/item/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list(/datum/reagent/consumable/enzyme = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar sack"
	desc = "Tasty spacey sugar!"
	icon_state = "sugar"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/sugar = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/saltshaker		//Separate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	icon_empty = "emptyshaker"
	inhand_icon_state = ""
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/salt = 20)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to swap forms with the salt shaker! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Salt. From dead crew, presumably."
	return (TOXLOSS)

/obj/item/reagent_containers/food/condiment/saltshaker/afterattack(obj/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isturf(target))
		if(!reagents.has_reagent(/datum/reagent/consumable/salt, 2))
			to_chat(user, "<span class='warning'>You don't have enough salt to make a pile!</span>")
			return
		user.visible_message("<span class='notice'>[user] shakes some salt onto [target].</span>", "<span class='notice'>You shake some salt onto [target].</span>")
		reagents.remove_reagent(/datum/reagent/consumable/salt, 2)
		new/obj/effect/decal/cleanable/food/salt(target)
		return

/obj/item/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	icon_empty = "emptyshaker"
	inhand_icon_state = ""
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/blackpepper = 20)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/milk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/flour = 30)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/soymilk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/rice = 30)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list(/datum/reagent/consumable/soysauce = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/mayonnaise
	name = "mayonnaise"
	desc = "An oily condiment made from egg yolks."
	icon_state = "mayonnaise"
	list_reagents = list(/datum/reagent/consumable/mayonnaise = 50)
	fill_icon_thresholds = null

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list()
	/**
	  * List of possible styles (list(<icon_state>, <name>, <desc>)) for condiment packs.
	  * Since all of them differs only in color should probably be replaced with usual reagentfillings instead
	  */
	var/list/possible_states = list(
		/datum/reagent/consumable/ketchup = list("condi_ketchup", "Ketchup", "You feel more American already."),
		/datum/reagent/consumable/capsaicin = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"),
		/datum/reagent/consumable/soysauce = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"),
		/datum/reagent/consumable/frostoil = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in its passage"),
		/datum/reagent/consumable/salt = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"),
		/datum/reagent/consumable/blackpepper = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"),
		/datum/reagent/consumable/cornoil = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"),
		/datum/reagent/consumable/sugar = list("condi_sugar", "Sugar", "Tasty spacey sugar!"),
		/datum/reagent/consumable/astrotame = list("condi_astrotame", "Astrotame", "The sweetness of a thousand sugars but none of the calories."),
		/datum/reagent/consumable/bbqsauce = list("condi_bbq", "BBQ sauce", "Hand wipes not included."),
	)
	/// Can't use initial(name) for this. This stores the name set by condimasters.
	var/originalname = "condiment"

/obj/item/reagent_containers/food/condiment/pack/update_icon()
	return

/obj/item/reagent_containers/food/condiment/pack/attack(mob/M, mob/user, def_zone) //Can't feed these to people directly.
	return

/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(IS_EDIBLE(target))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but there's nothing in it.</span>")
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>" )
			qdel(src)
			return
		else
			to_chat(user, "<span class='notice'>You tear open [src] above [target] and the condiments drip onto it.</span>")
			src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
			qdel(src)
			return
	. = ..()

/obj/item/reagent_containers/food/condiment/pack/on_reagent_change(changetype)
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			desc = temp_list[3]
		else
			icon_state = "condi_mixed"
			desc = "A small condiment pack. The label says it contains [originalname]"
	else
		icon_state = "condi_empty"
		desc = "A small condiment pack. It is empty."

//Ketchup
/obj/item/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list(/datum/reagent/consumable/ketchup = 10)

//Hot sauce
/obj/item/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 10)

/obj/item/reagent_containers/food/condiment/pack/astrotame
	name = "astrotame pack"
	originalname = "astrotame"
	list_reagents = list(/datum/reagent/consumable/astrotame = 5)

/obj/item/reagent_containers/food/condiment/pack/bbqsauce
	name = "bbq sauce pack"
	originalname = "bbq sauce"
	list_reagents = list(/datum/reagent/consumable/bbqsauce = 10)
