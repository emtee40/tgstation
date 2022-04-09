//This system is designed to act as an in-between for cargo and science, and the first major money sink in the game outside of just buying things from cargo (As of 10/9/19, anyway).

//economics defined values, subject to change should anything be too high or low in practice.

#define MACHINE_OPERATION 100000
#define MACHINE_OVERLOAD 500000
#define MAJOR_THRESHOLD 6*CARGO_CRATE_VALUE
#define MINOR_THRESHOLD 4*CARGO_CRATE_VALUE
#define STANDARD_DEVIATION 2*CARGO_CRATE_VALUE
#define PART_CASH_OFFSET_AMOUNT 0.5*CARGO_CRATE_VALUE

/obj/machinery/rnd/bepis
	name = "\improper B.E.P.I.S. Chamber"
	desc = "A high fidelity testing device which unlocks the secrets of the known universe using the two most powerful substances available to man: excessive amounts of electricity and capital."
	icon = 'icons/obj/machines/bepis.dmi'
	icon_state = "chamber"
	base_icon_state = "chamber"
	density = TRUE
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	use_power = IDLE_POWER_USE
	active_power_usage = 1500
	circuit = /obj/item/circuitboard/machine/bepis

	///How much cash the UI and machine are depositing at a time.
	var/banking_amount = 100
	///How much stored player cash exists within the machine.
	var/banked_cash = 0
	///Payer's bank account.
	var/datum/bank_account/account
	///Name on the payer's bank account.
	var/account_name
	///When the BEPIS fails to hand out any reward, the ERROR cause will be a randomly picked string displayed on the UI.
	var/error_cause = null

	//Vars related to probability and chance of success for testing, using gaussian normal distribution.
	///How much cash you will need to obtain a Major Tech Disk reward.
	var/major_threshold = MAJOR_THRESHOLD
	///How much cash you will need to obtain a minor invention reward.
	var/minor_threshold = MINOR_THRESHOLD
	///The standard deviation of the BEPIS's gaussian normal distribution.
	var/std = STANDARD_DEVIATION

	//Stock part variables
	///Multiplier that lowers how much the BEPIS' power costs are. Maximum of 1, upgraded to a minimum of 0.7. See RefreshParts.
	var/power_saver = 1
	///Variability on the money you actively spend on the BEPIS, with higher inaccuracy making the most change, good and bad to spent cash.
	var/inaccuracy_percentage = 1.5
	///How much "cash" is added to your inserted cash efforts for free. Based on manipulator stock part level.
	var/positive_cash_offset = 0
	///How much "cost" is removed from both the minor and major threshold costs. Based on laser stock part level.
	var/negative_cash_offset = 0
	///List of objects that constitute your minor rewards. All rewards are unique or rare outside of the BEPIS.
	var/minor_rewards = list(
		//To add a new minor reward, add it here.
		/obj/item/stack/circuit_stack/full,
		/obj/item/pen/survival,
		/obj/item/circuitboard/machine/sleeper/party,
		/obj/item/toy/sprayoncan,
	)

/obj/machinery/rnd/bepis/attackby(obj/item/O, mob/user, params)
	if(!is_operational)
		to_chat(user, span_notice("[src] can't accept money when it's not functioning."))
		return
	if(istype(O, /obj/item/holochip) || istype(O, /obj/item/stack/spacecash))
		var/deposit_value = O.get_item_credit_value()
		banked_cash += deposit_value
		qdel(O)
		say("Deposited [deposit_value] credits into storage.")
		update_appearance()
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/Card = O
		if(Card.registered_account)
			account = Card.registered_account
			account_name = Card.registered_name
			say("New account detected. Console Updated.")
		else
			say("No account detected on card. Aborting.")
		return
	return ..()

/obj/machinery/rnd/bepis/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "chamber_open", "chamber", tool)

/obj/machinery/rnd/bepis/RefreshParts()
	. = ..()
	var/C = 0
	var/M = 0
	var/L = 0
	var/S = 0
	for(var/obj/item/stock_parts/capacitor/Cap in component_parts)
		C += ((Cap.rating - 1) * 0.1)
	power_saver = 1 - C
	for(var/obj/item/stock_parts/manipulator/Manip in component_parts)
		M += ((Manip.rating - 1) * PART_CASH_OFFSET_AMOUNT)
	positive_cash_offset = M
	for(var/obj/item/stock_parts/micro_laser/Laser in component_parts)
		L += ((Laser.rating - 1) * PART_CASH_OFFSET_AMOUNT)
	negative_cash_offset = L
	for(var/obj/item/stock_parts/scanning_module/Scan in component_parts)
		S += ((Scan.rating - 1) * 0.25)
	inaccuracy_percentage = (1.5 - S)

/obj/machinery/rnd/bepis/update_icon_state()
	if(panel_open == TRUE)
		icon_state = "[base_icon_state]_open"
		return ..()
	if((use_power == ACTIVE_POWER_USE) && (banked_cash > 0) && (is_operational))
		icon_state = "[base_icon_state]_active_loaded"
		return ..()
	if (((use_power == IDLE_POWER_USE) && (banked_cash > 0)) || (banked_cash > 0) && (!is_operational))
		icon_state = "[base_icon_state]_loaded"
		return ..()
	if(use_power == ACTIVE_POWER_USE && is_operational)
		icon_state = "[base_icon_state]_active"
		return ..()
	if(((use_power == IDLE_POWER_USE) && (banked_cash == 0)) || (!is_operational))
		icon_state = base_icon_state
		return ..()
	return ..()

/obj/machinery/rnd/bepis/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Bepis", name)
		ui.open()
	RefreshParts()
	if(isliving(user))
		var/mob/living/customer = user
		account = customer.get_bank_account()

/obj/machinery/rnd/bepis/ui_data(mob/user)
	var/list/data = list()
	var/powered = FALSE
	var/zvalue = ((banking_amount + banked_cash) - (major_threshold - positive_cash_offset - negative_cash_offset))/(std)
	var/std_success = 0
	var/prob_success = 0
	//Admittedly this is messy, but not nearly as messy as the alternative, which is jury-rigging an entire Z-table into the code, or making an adaptive z-table.
	var/z = abs(zvalue)
	if(z > 0 && z <= 0.5)
		std_success = 19.1
	else if(z > 0.5 && z <= 1.0)
		std_success = 34.1
	else if(z > 1.0 && z <= 1.5)
		std_success = 43.3
	else if(z > 1.5 && z <= 2.0)
		std_success = 47.7
	else if(z > 2.0 && z <= 2.5)
		std_success = 49.4
	else
		std_success = 50
	if(zvalue > 0)
		prob_success = 50 + std_success
	else if(zvalue == 0)
		prob_success = 50
	else
		prob_success = 50 - std_success

	if(use_power == ACTIVE_POWER_USE)
		powered = TRUE
	data["account_owner"] = account_name
	data["amount"] = banking_amount
	data["stored_cash"] = account?.account_balance
	data["mean_value"] = (major_threshold - positive_cash_offset - negative_cash_offset)
	data["error_name"] = error_cause
	data["power_saver"] = power_saver
	data["accuracy_percentage"] = inaccuracy_percentage * 100
	data["positive_cash_offset"] = positive_cash_offset
	data["negative_cash_offset"] = negative_cash_offset
	data["manual_power"] = powered ? FALSE : TRUE
	data["silicon_check"] = issilicon(user)
	data["success_estimate"] = prob_success
	return data

/obj/machinery/rnd/bepis/ui_act(action,params)
	. = ..()
	if(.)
		return
	switch(action)
		if("begin_experiment")
			if(use_power == IDLE_POWER_USE)
				return
			depositcash()
			if(banked_cash == 0)
				say("Please select funds to deposit to begin testing.")
				return
			calcsuccess()
			use_power(MACHINE_OPERATION * power_saver) //This thing should eat your APC battery if you're not careful.
			update_use_power(IDLE_POWER_USE) //Machine shuts off after use to prevent spam and look better visually.
			update_appearance()
		if("amount")
			var/input = text2num(params["amount"])
			if(input)
				banking_amount = input
		if("toggle_power")
			if(use_power == ACTIVE_POWER_USE)
				update_use_power(IDLE_POWER_USE)
			else
				update_use_power(ACTIVE_POWER_USE)
			update_appearance()
		if("account_reset")
			if(use_power == IDLE_POWER_USE)
				return
			account_name = ""
			account = null
			say("Account settings reset.")
	. = TRUE

/**
 * Proc that handles the user's account to deposit credits for the BEPIS.
 * Handles success and fail cases for transferring credits, then logs the transaction and uses small amounts of power.
 **/
/obj/machinery/rnd/bepis/proc/depositcash()
	var/deposit_value = 0
	deposit_value = banking_amount
	if(deposit_value == 0)
		update_appearance()
		say("Attempting to deposit 0 credits. Aborting.")
		return
	deposit_value = clamp(round(deposit_value, 1), 1, 10000)
	if(!account)
		say("Cannot find user account. Please swipe a valid ID.")
		return
	if(!account.has_money(deposit_value))
		say("You do not possess enough credits.")
		return
	account.adjust_money(-deposit_value) //The money vanishes, not paid to any accounts.
	SSblackbox.record_feedback("amount", "BEPIS_credits_spent", deposit_value)
	log_econ("[deposit_value] credits were inserted into [src] by [account.account_holder]")
	banked_cash += deposit_value
	use_power(1000 * power_saver)
	return

/**
 * Proc used to determine the experiment math and results all in one.
 * Uses banked_cash and stock part levels to determine minor, major, and real gauss values for the BEPIS to hold.
 * If by the end real is larger than major, You get a tech disk. If all the disks are earned or you at least beat minor, you get a minor reward.
 **/

/obj/machinery/rnd/bepis/proc/calcsuccess()
	var/turf/dropturf = null
	var/gauss_major = 0
	var/gauss_minor = 0
	var/gauss_real = 0
	var/list/turfs = block(locate(x-1,y-1,z),locate(x+1,y+1,z)) //NO MORE DISCS IN WINDOWS
	while(length(turfs))
		var/turf/T = pick_n_take(turfs)
		if(T.is_blocked_turf(TRUE))
			continue
		else
			dropturf = T
			break
	if (!dropturf)
		dropturf = drop_location()
	gauss_major = (gaussian(major_threshold, std) - negative_cash_offset) //This is the randomized profit value that this experiment has to surpass to unlock a tech.
	gauss_minor = (gaussian(minor_threshold, std) - negative_cash_offset) //And this is the threshold to instead get a minor prize.
	gauss_real = (gaussian(banked_cash, std*inaccuracy_percentage) + positive_cash_offset) //this is the randomized profit value that your experiment expects to give.
	say("Real: [gauss_real]. Minor: [gauss_minor]. Major: [gauss_major].")
	flick("chamber_flash",src)
	update_appearance()
	banked_cash = 0
	if((gauss_real >= gauss_major)) //Major Success.
		if(SSresearch.techweb_nodes_experimental.len > 0)
			say("Experiment concluded with major success. New technology node discovered on technology disc.")
			new /obj/item/disk/tech_disk/major(dropturf,1)
			return
		say("Expended all available experimental technology nodes. Resorting to minor rewards.")
	if(gauss_real >= gauss_minor) //Minor Success.
		var/reward = pick(minor_rewards)
		new reward(dropturf)
		say("Experiment concluded with partial success. Dispensing compiled research efforts.")
		return
	if(gauss_real <= -1) //Critical Failure
		say("ERROR: CRITICAL MACHIME MALFUNCTI- ON. CURRENCY IS NOT CRASH. CANNOT COMPUTE COMMAND: 'make bucks'") //not a typo, for once.
		new /mob/living/simple_animal/deer(dropturf, 1)
		use_power(MACHINE_OVERLOAD * power_saver) //To prevent gambling at low cost and also prevent spamming for infinite deer.
		return
	//Minor Failure
	error_cause = pick("attempted to sell grey products to American dominated market.","attempted to sell gray products to British dominated market.","placed wild assumption that PDAs would go out of style.","simulated product #76 damaged brand reputation mortally.","simulated business model resembled 'pyramid scheme' by 98.7%.","product accidently granted override access to all station doors.")
	say("Experiment concluded with zero product viability. Cause of error: [error_cause]")
	return
