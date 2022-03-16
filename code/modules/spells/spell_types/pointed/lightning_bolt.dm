/datum/action/cooldown/spell/pointed/projectile/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a lightning bolt at your foes! It will jump between targets, but can't knock them down."
	button_icon_state = "lightning0"

	sound = 'sound/magic/lightningbolt.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 2 SECONDS
	spell_requirements = NONE

	invocation = "P'WAH, UNLIM'TED P'WAH"
	invocation_type = INVOCATION_SHOUT

	base_icon_state = "lightning"
	active_msg = "You energize your hands with arcane lightning!"
	deactive_msg = "You let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/projectile/magic/aoe/lightning

	/// The range the bolt itself
	var/bolt_range = 15
	/// The power of the bolt itself
	var/bolt_power = 20000
	/// The flags the bolt itself takes when zapping someone
	var/bolt_flags =  ZAP_MOB_DAMAGE

/datum/action/cooldown/spell/pointed/projectile/lightningbolt/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(!istype(to_fire, /obj/projectile/magic/aoe/lightning))
		return

	var/obj/projectile/magic/aoe/lightning/bolt = to_fire
	bolt.zap_range = bolt_range
	bolt.zap_power = bolt_power
	bolt.zap_flags = bolt_flags
