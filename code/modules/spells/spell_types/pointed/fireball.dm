/datum/action/cooldown/spell/pointed/projectile/fireball
	name = "Fireball"
	desc = "This spell fires an explosive fireball at a target."
	base_icon_state = "fireball"
	action_icon_state = "fireball0"

	sound = 'sound/magic/fireball.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS // 1 second reduction per rank

	invocation = "ONI SOMA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	range = 8

	active_msg = "You prepare to cast your fireball spell!"
	deactive_msg = "You extinguish your fireball... for now."
	projectile_type = /obj/projectile/magic/aoe/fireball

/datum/action/cooldown/spell/pointed/projectile/fireball/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	to_fire.range = (6 + 2 * spell_level)
