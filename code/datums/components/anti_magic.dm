/// Default magic resistance that blocks normal magic (wizard, spells, staffs)
#define MAGIC_RESISTANCE (1<<0)
/// Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
#define MAGIC_RESISTANCE_MIND (1<<1)
/// Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god, )
#define MAGIC_RESISTANCE_HOLY (1<<2)
/// Prevents a user from casting magic
#define MAGIC_CASTING_RESTRICTION (1<<3)
/// All magic resistances combined
#define MAGIC_RESISTANCE_ALL (MAGIC_RESISTANCE | MAGIC_RESISTANCE_MIND | MAGIC_RESISTANCE_HOLY | MAGIC_CASTING_RESTRICTION)

/// This provides different types of magic resistance on an object
/datum/component/anti_magic
	/// The types of magic resistance present on the object
	var/antimagic_flags
	/// The amount of times the object can protect the user
	var/remaining_charges
	/// The inventory slot the object must be located at in order to activate
	var/inventory_flags
	/// The proc that is triggered when magic has been successfully blocked
	var/datum/callback/reaction
	/// The proc that is triggered when the object is depleted of charges
	var/datum/callback/expiration

/**
 * Adds magic resistances to an object
 *
 * Magic resistance will prevent magic from affecting the user if it has the correct resistance
 * against the type of magic being used
 * 
 * args:
 * * resistances (optional) The types of magic resistance on the object
 * * total_charges (optional) The amount of times the object can protect the user from magic 
 * * inventory_slots (optional) The inventory slot the object must be located at in order to activate
 * * reaction (optional) The proc that is triggered when magic has been successfully blocked
 * * expiration (optional) The proc that is triggered when the object is depleted of charges
**/
/datum/component/anti_magic/Initialize(
		antimagic_flags = MAGIC_RESISTANCE,
		remaining_charges = INFINITY, 
		inventory_flags = ~ITEM_SLOT_BACKPACK, // items in a backpack won't activate, anywhere else is fine
		reaction, 
		expiration
	)

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect)
	else
		return COMPONENT_INCOMPATIBLE

	if(resistances)
		src.antimagic_flags =  || 
	if(total_charges)
		src.remaining_charges = total_charges
	if(inventory_slots)
		src.inventory_flags = inventory_slots 
	src.react = reaction
	src.expire = expiration

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(inventory_flags & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect, TRUE)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/anti_magic/proc/protect(datum/source, mob/user, resistances, charge_cost, list/protection_sources)
	SIGNAL_HANDLER

	// ignore magic casting restrictions since proc/protect is only called
	// when being attacked with magic by another mob
	var/antimagic = antimagic_flags & ~MAGIC_CASTING_RESTRICTION
	if(resistances & antimagic) 
		protection_sources += parent
		react?.Invoke(user, charge_cost, parent)
		remaining_charges -= charge_cost
		if(remaining_charges <= 0)
			expire?.Invoke(user, parent)
			qdel(src)
		return COMPONENT_BLOCK_MAGIC
