// The divisor for the power_factor when calculating the threshold.
#define THRESHOLD_POWER_DIVISOR 750

// The higher this number, the faster low integrity will drop threshold
// I would've named this "power", but y'know. :P
#define INTEGRITY_EXPONENTIAL_DEGREE 2

// At INTEGRITY_MIN_NUDGABLE_AMOUNT, the power will be treated as, at most, INTEGRITY_MAX_POWER_NUDGE.
// Any lower integrity will result in INTEGRITY_MAX_POWER_NUDGE.
#define INTEGRITY_MAX_POWER_NUDGE 1500
#define INTEGRITY_MIN_NUDGABLE_AMOUNT 0.7

#define RADIATION_CHANCE_AT_FULL_INTEGRITY 0.03
#define RADIATION_CHANCE_AT_ZERO_INTEGRITY 0.4
#define CHANCE_EQUATION_SLOPE (RADIATION_CHANCE_AT_ZERO_INTEGRITY - RADIATION_CHANCE_AT_FULL_INTEGRITY)

/obj/machinery/power/supermatter_crystal/proc/emit_radiation()
	// As power goes up, rads go up.
	// A standard N2 SM seems to produce a value of around 1,500.
	var/power_factor = power

	var/integrity = 1 - CLAMP01(damage / explosion_point)

	// When integrity goes down, the threshold (from an observable point of view, rads) go up.
	// However, the power factor must go up as well, otherwise turning off the emitters
	// on a delaminating SM would stop radiation from escaping.
	// To fix this, lower integrities raise the power factor to a minimum.
	var/integrity_power_nudge = LERP(INTEGRITY_MAX_POWER_NUDGE, 0, CLAMP01((integrity - INTEGRITY_MIN_NUDGABLE_AMOUNT) / (1 - INTEGRITY_MIN_NUDGABLE_AMOUNT)))

	power_factor = max(power_factor, integrity_power_nudge)

	// At the "normal" N2 power output (with max integrity), this is 2dB, which is enough to be stopped
	// by the walls or the radation shutters.
	// As integrity does down, rads go up.
	var/threshold
	switch(integrity)
		if(0)
			threshold = power_factor ? RAD_FULL_INSULATION : RAD_NO_INSULATION
		if(1)
			threshold = power_factor / THRESHOLD_POWER_DIVISOR
		else
			threshold = power_factor / (THRESHOLD_POWER_DIVISOR * integrity ** INTEGRITY_EXPONENTIAL_DEGREE)

	// Calculating chance is done entirely on integrity, so that actively delaminating SMs feel more dangerous
	var/chance = (CHANCE_EQUATION_SLOPE * (1 - integrity)) + RADIATION_CHANCE_AT_FULL_INTEGRITY

	radiation_pulse(
		src,
		max_range = 8,
		threshold = threshold,
		chance = chance * 100,
	)

#undef CHANCE_EQUATION_SLOPE
#undef INTEGRITY_EXPONENTIAL_DEGREE
#undef INTEGRITY_MAX_POWER_NUDGE
#undef INTEGRITY_MIN_NUDGABLE_AMOUNT
#undef RADIATION_CHANCE_AT_FULL_INTEGRITY
#undef RADIATION_CHANCE_AT_ZERO_INTEGRITY
