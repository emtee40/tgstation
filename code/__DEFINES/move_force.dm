<<<<<<< HEAD
//Defaults
#define MOVE_FORCE_DEFAULT 1000
#define MOVE_RESIST_DEFAULT 1000
#define PULL_FORCE_DEFAULT 1000

//Factors/modifiers
#define MOVE_FORCE_PULL_RATIO 1				//Same move force to pull objects
#define MOVE_FORCE_PUSH_RATIO 1				//Same move force to normally push
#define MOVE_FORCE_FORCEPUSH_RATIO 2		//2x move force to forcefully push
#define MOVE_FORCE_CRUSH_RATIO 3			//3x move force to do things like crush objects
#define MOVE_FORCE_THROW_RATIO 1			//Same force throw as resist to throw objects

#define MOVE_FORCE_OVERPOWERING (MOVE_FORCE_DEFAULT * MOVE_FORCE_CRUSH_RATIO * 10)
#define MOVE_FORCE_EXTREMELY_STRONG (MOVE_FORCE_DEFAULT * MOVE_FORCE_CRUSH_RATIO * 3)
#define MOVE_FORCE_VERY_STRONG ((MOVE_FORCE_DEFAULT * MOVE_FORCE_CRUSH_RATIO) - 1)
#define MOVE_FORCE_STRONG (MOVE_FORCE_DEFAULT * 2)
#define MOVE_FORCE_NORMAL MOVE_FORCE_DEFAULT
#define MOVE_FORCE_WEAK (MOVE_FORCE_DEFAULT / 2)
#define MOVE_FORCE_VERY_WEAK ((MOVE_FORCE_DEFAULT / MOVE_FORCE_CRUSH_RATIO) + 1)
#define MOVE_FORCE_EXTREMELY_WEAK (MOVE_FORCE_DEFAULT / (MOVE_FORCE_CRUSH_RATIO * 3))
=======
//Defaults
#define MOVE_FORCE_DEFAULT 1000
#define MOVE_RESIST_DEFAULT 1000
#define PULL_FORCE_DEFAULT 1000

//Factors/modifiers
#define MOVE_FORCE_PULL_RATIO 1				//Same move force to pull objects
#define MOVE_FORCE_PUSH_RATIO 1				//Same move force to normally push
#define MOVE_FORCE_FORCEPUSH_RATIO 2		//2x move force to forcefully push
#define MOVE_FORCE_CRUSH_RATIO 3			//3x move force to do things like crush objects
#define MOVE_FORCE_THROW_RATIO 1			//Same force throw as resist to throw objects

#define MOVE_FORCE_OVERPOWERING (MOVE_FORCE_DEFAULT * MOVE_FORCE_CRUSH_RATIO * 10)
#define MOVE_FORCE_EXTREMELY_STRONG (MOVE_FORCE_DEFAULT * MOVE_FORCE_CRUSH_RATIO * 3)
#define MOVE_FORCE_VERY_STRONG ((MOVE_FORCE_DEFAULT * MOVE_FORCE_CRUSH_RATIO) - 1)
#define MOVE_FORCE_STRONG (MOVE_FORCE_DEFAULT * 2)
#define MOVE_FORCE_NORMAL MOVE_FORCE_DEFAULT
#define MOVE_FORCE_WEAK (MOVE_FORCE_DEFAULT / 2)
#define MOVE_FORCE_VERY_WEAK ((MOVE_FORCE_DEFAULT / MOVE_FORCE_CRUSH_RATIO) + 1)
#define MOVE_FORCE_EXTREMELY_WEAK (MOVE_FORCE_DEFAULT / (MOVE_FORCE_CRUSH_RATIO * 3))
>>>>>>> Updated this old code to fork
