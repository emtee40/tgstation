SUBSYSTEM_DEF(card)
	name = "Card Game Manager"
	init_order = INIT_ORDER_CARD
	flags = SS_NO_FIRE

	var/list/active_games
	var/list/completed_games

	var/list/all_cards = list()			// An assoc list with weight values representing rarity of the card. For making booster packs
	var/list/creature_cards = list()
	var/list/effect_cards = list()
	var/list/equipment_cards = list()
	var/list/area_cards = list()

/datum/controller/subsystem/card/Initialize()
	. = ..()
	for(var/ctype in subtypesof(/obj/item/griffeningdeck/cardhand/single))
		var/obj/item/griffeningdeck/cardhand/single/card = new ctype()
		all_cards[ctype] = card.rarity
		switch(card.card_type)
			if(CREATURE_CARD)
				creature_cards[ctype] = card.rarity
			if(EFFECT_CARD)
				effect_cards[ctype] = card.rarity
			if(EQUIPMENT_CARD)
				equipment_cards[ctype] = card.rarity
			if(AREA_CARD)
				area_cards[ctype] = card.rarity

/datum/controller/subsystem/card/proc/get_new_card(card_type=FALSE)
	switch(card_type)
		if(CREATURE_CARD)
			card_type = pick(creature_cards)
		if(EFFECT_CARD)
			card_type = pick(effect_cards)
		if(EQUIPMENT_CARD)
			card_type = pick(equipment_cards)
		if(AREA_CARD)
			card_type = pick(area_cards)
		else
			card_type = pick(all_cards)

	var/new_card = new card_type()
	return new_card

/datum/controller/subsystem/card/proc/get_cards(num=30,card_type=FALSE)
	var/list/cards = list()
	for(var/i in 1 to num)
		cards += get_new_card(card_type)
	return cards