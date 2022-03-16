/datum/action/cooldown/spell/conjure_item/infinite_guns
	school = SCHOOL_CONJURATION
	cooldown_time = 1.25 MINUTES
	cooldown_reduction_per_rank = 18.5 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

	// Enchanted guns tend to self delete anyways.
	delete_old = FALSE
	item_type = /obj/item/gun/ballistic/rifle

// Because enchanted guns self-delete and regenerate themselves,
// let's not bother with tracking their weakrefs.
/datum/action/cooldown/spell/conjure_item/infinite_guns/make_item()
	return new item_type()

/datum/action/cooldown/spell/conjure_item/infinite_guns/gun
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? \
		Summons an unending stream of bolt action rifles that deal little damage, \
		but will knock targets down. Requires both hands free to use. \
		Learning this spell makes you unable to learn Arcane Barrage."
	button_icon_state = "bolt_action"

	item_type = /obj/item/gun/ballistic/rifle/enchanted

/datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage
	name = "Arcane Barrage"
	desc = "Fire a torrent of arcane energy at your foes with this (powerful) spell. \
		Deals much more damage than Lesser Summon Guns, but won't knock targets down. Requires both hands free to use. \
		Learning this spell makes you unable to learn Lesser Summon Gun."
	button_icon_state = "arcane_barrage"

	item_type = /obj/item/gun/ballistic/rifle/enchanted/arcane_barrage
