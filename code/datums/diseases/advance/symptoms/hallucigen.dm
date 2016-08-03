/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen

	name = "Hallucigen"
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmittable = 0
	level = 5
	severity = 3

/datum/symptom/hallucigen/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='warning'>[pick("Something appears in your peripheral vision, then winks out.", "You hear a faint whispher with no source.", "Your head aches.")]</span>"
			if(3, 4)
				M << "<span class='danger'>[pick("Something is following you.", "You are being watched.", "You hear a whisper in your ear.", "Thumping footsteps slam toward you from nowhere.")]</span>"
			else
				M << "<span class='userdanger'>[pick("Oh, your head...", "Your head pounds.", "They're everywhere! Run!", "Something in the shadows...")]</span>"
				M.hallucination += 5

	return
