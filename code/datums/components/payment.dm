
/**
  * Handles simple payment operations where the cost of the object in question doesn't change.
  *
  * What this is useful for:
  * Basic forms of vending.
  * Objects that can drain the owner's money linearly.
  * What this is not useful for:
  * Things where the seller may want to fluxuate the price of the object.
  * Improving standardizing every form of payment handing, as some custom handling is specific to that object.
  **/
/datum/component/payment
	///Standardized of operation.
	var/cost = 10
	///Flavor style for handling cash (Friendly? Hostile? etc.)
	var/transaction_style = "Clinical"
	///Who's getting paid?
	var/datum/bank_account/target_acc

/datum/component/payment/Initialize(_cost, _target, _style)
	target_acc = _target
	if(!target_acc)
		target_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	cost = _cost
	transaction_style = _style
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE, .proc/attempt_charge)
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE, .proc/change_cost)

/datum/component/payment/proc/attempt_charge(datum/source, atom/movable/target, extra_fees = 0)
	SIGNAL_HANDLER

	if(!cost) //In case a free variant of anything is made it'll skip charging anyone.
		return
	if(!ismob(target))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/mob/user = target
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	if(!card)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, "<span class='warning'>ID not detected, sorry [user]!</span>")
			if(PAYMENT_ANGRY)
				to_chat(user, "<span class='warning'>WHERE IS YOUR GOD DAMN CARD! GOD DAMNIT!</span>")
			if(PAYMENT_CLINICAL)
				to_chat(user, "<span class='warning'>ID card not present. Aborting.</span>")
		return COMPONENT_OBJ_CANCEL_CHARGE
	if(!card.registered_account)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, "<span class='warning'>There's no account detected on your ID, how mysterious!</span>")
			if(PAYMENT_ANGRY)
				to_chat(user, "<span class='warning'>ARE YOU JOKING. YOU DON'T HAVE A BANK ACCOUNT ON YOUR ID YOU IDIOT.</span>")
			if(PAYMENT_CLINICAL)
				to_chat(user, "<span class='warning'>ID Card lacks a bank account. Aborting.</span>")
		return COMPONENT_OBJ_CANCEL_CHARGE
	if(!(card.registered_account.has_money(cost + extra_fees)))
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, "<span class='warning'>I'm so sorry... You don't seem to have enough money. This costs [cost+extra_fees]</span>")
			if(PAYMENT_ANGRY)
				to_chat(user, "<span class='warning'>YOU MORON. YOU ABSOLUTE BAFOON. YOU INSUFFERABLE TOOL. YOU ARE POOR.</span>")
			if(PAYMENT_CLINICAL)
				to_chat(user, "<span class='warning'>ID Card lacks funds. Aborting.</span>")
		return COMPONENT_OBJ_CANCEL_CHARGE
	target_acc.transfer_money(card.registered_account, cost + extra_fees)
	card.registered_account.bank_card_talk("[cost+extra_fees] credits deducted from your account.")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)

/datum/component/payment/proc/change_cost(datum/source, new_cost)
	SIGNAL_HANDLER
	if(!isnum(new_cost))
		CRASH("change_cost called with variable new_cost as not a number.")
	cost = new_cost


/**
  * Handles simple payment operations where the parent can handle buying and selling items from a given keyed list.
  * Used on the merchant simplemob NPCs primarily.
  **/
/datum/component/payment/merchant
	///Associated list of products if payment is setup on a mob.
	var/list/products

/datum/component/payment/merchant/Initialize(_cost, _target, _style, _products)
	. = ..()
	if(_products)
		products = _products
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/purchase_item)

/datum/component/payment/merchant/proc/purchase_item(datum/source, atom/movable/customer)
	SIGNAL_HANDLER
	if(!LAZYLEN(products))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/i in 1 to length(products))
		var/obj/item/product = products[i]
		display_names["[initial(product.name)] ([i])"] = REF(product)
		var/image/product_image = image(icon = initial(product.icon), icon_state = initial(product.icon_state))
		items += list("[initial(product.name)] ([i])" = product_image)
	var/pick = show_radial_menu(customer, parent, items, custom_check = FALSE, require_near = TRUE)
	if(!pick)
		return
	var/product_reference = display_names[pick]
	var/obj/item/new_product = locate(product_reference) in products
	if(!new_product)
		return
	var/added_value = initial(new_product.custom_price) + initial(new_product.custom_premium_price)
	if(attempt_charge(src, customer, added_value) & COMPONENT_OBJ_CANCEL_CHARGE)
		return
	new new_product(customer.drop_location())
	if(ishuman(customer))
		var/mob/living/carbon/human/human_cust = customer
		human_cust.put_in_hand(new_product)
	products[new_product] -= 1
	if(products[new_product] < 1)
		products -= new_product
