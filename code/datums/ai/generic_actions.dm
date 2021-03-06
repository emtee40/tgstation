
/datum/ai_behavior/resist/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.resist()
	finish_action(controller, TRUE)

/datum/ai_behavior/battle_screech
	///List of possible screeches the behavior has
	var/list/screeches

/datum/ai_behavior/battle_screech/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick(screeches))
	finish_action(controller, TRUE)

///Moves to target then finishes
/datum/ai_behavior/move_to_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/move_to_target/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE)


///Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
/datum/ai_behavior/find_and_set
	action_cooldown = 15 SECONDS
	var/locate_path
	var/bb_key_to_set

/datum/ai_behavior/find_and_set/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/atom/find_this_thing = search_tactic(controller)
	if(find_this_thing)
		controller.blackboard[bb_key_to_set] = find_this_thing
		react_to_success(controller)
		finish_action(controller, TRUE)
	else
		react_to_failure(controller)
		finish_action(controller, FALSE)

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller)
	return locate(locate_path) in oview(7, controller.pawn)

/datum/ai_behavior/find_and_set/proc/react_to_success(datum/ai_controller/controller)
	return

/datum/ai_behavior/find_and_set/proc/react_to_failure(datum/ai_controller/controller)
	return

///Goes to the move target, and forcemoves it inside itself. Simple creatures will enjoy this, more advanced ones should probably put in hands or something.
/datum/ai_behavior/forcemove_grab
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1 //it looks better because of pickup animations
	var/grab_verb = "grabs"
	var/bb_key_target

/datum/ai_behavior/forcemove_grab/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/obj/item/grabbed_item = controller.blackboard[bb_key_target]
	grabbed_item.do_pickup_animation(controller.pawn)
	controller.pawn.visible_message("<span class='notice'>[controller.pawn] [grab_verb] [grabbed_item]!</span>")
	grabbed_item.forceMove(controller.pawn)
	finish_action(controller, TRUE)

///drops an item at the turf of your movement target. this assumes the object is being held in some way by our pawn, so it forcemoves to the spot. If they're not holding the item, this looks and is !WEIRD!
/datum/ai_behavior/dropoff_item
	required_distance = 1
	//key that corresponds to the item we're dropping
	var/bb_key_item

/datum/ai_behavior/dropoff_item/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/obj/item/item_to_dropoff = controller.blackboard[bb_key_item]
	item_to_dropoff.forceMove(controller.current_movement_target)
	finish_action(controller, TRUE)

///pawn will flush an item down disposals (so not mobs!)
/datum/ai_behavior/disposals_item
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1
	var/bb_key_target
	///You can use /datum/ai_behavior/find_and_set to locate a disposals bin, pretty handy stuff
	var/bb_key_disposals

/datum/ai_behavior/disposals_item/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/disposals_user = controller.pawn
	var/obj/machinery/disposal/bin/bin = controller.blackboard[bb_key_disposals]
	var/atom/movable/throw_away = controller.blackboard[bb_key_target]

	bin.place_item_in_disposal(throw_away, disposals_user)
	controller.blackboard[bb_key_target] = null //cave johnson we're done here (we probably don't need this again.)

	react_to_success(controller.pawn)
	finish_action(controller, TRUE)

/datum/ai_behavior/disposals_item/proc/react_to_success(mob/pawn)
	return

//this behavior is for listening for customers from a venue, and getting their orders. how niche, right?
/datum/ai_behavior/listen_for_customers
	//key that corresponds to the venue used
	var/bb_key_venue
	//key for customers we have taken the order of, so they don't have their order taken down twice.
	var/bb_key_customers_list
	//key for the orders we need to serve.
	var/bb_key_orders_list

/datum/ai_behavior/listen_for_customers/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/datum/venue/bb_venue = controller.blackboard[bb_key_venue]
	var/list/customers_list = controller.blackboard[bb_key_customers_list]
	var/list/orders_list = controller.blackboard[bb_key_orders_list]
	var/initial_order_length = orders_list.len
	for(var/mob/living/simple_animal/robot_customer/customer as anything in bb_venue.current_visitors)
		if(customer in customers_list)
			continue //we took their order already
		var/datum/ai_controller/customer_ai = customer.ai_controller
		if(customer_ai.blackboard[BB_CUSTOMER_LEAVING])
			continue //we don't want this order
		var/order = customer_ai.blackboard[BB_CUSTOMER_CURRENT_ORDER]
		if(!order)
			continue //we'll just need to wait for them to actually sit and place their order
		customers_list += customer //so we don't get their order again
		orders_list += order //and we get their order
		RegisterSignal(customer, COMSIG_PARENT_QDELETING, .proc/customer_left, customers_list, orders_list)
	finish_action(controller, initial_order_length < orders_list.len)

/datum/ai_behavior/listen_for_customers/proc/customer_left(datum/source, list/customers_list, list/orders_list)
	SIGNAL_HANDLER
	var/mob/living/simple_animal/robot_customer/customer = source
	customers_list -= customer
	orders_list -= customer.ai_controller.current_behaviors[BB_CUSTOMER_CURRENT_ORDER]

//behavior for finding what customers ordered (it goes well with listen_for_customers if you didn't guess)
/datum/ai_behavior/find_and_set/find_customer_order
	action_cooldown = 40 SECONDS //let em take their time, this is intensive af
	//key for the orders we need to find.
	var/bb_key_orders_list

/datum/ai_behavior/find_and_set/find_customer_order/search_tactic(datum/ai_controller/controller)
	var/list/orders_list = controller.blackboard[bb_key_orders_list]
	var/obj/item/found_food
	for(var/obj/item/possible_order in oview(7, controller.pawn))
		if(possible_order.type in orders_list) //find their orders!
			found_food = possible_order
			break
	return found_food
