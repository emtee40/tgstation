/datum/unit_test/timer_sanity/Run()
	if(SStimer.bucket_count < ZERO)
		Fail("SStimer is going into negative bucket count from something")
