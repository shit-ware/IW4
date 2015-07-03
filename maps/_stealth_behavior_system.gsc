#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;

stealth_behavior_system_main()
{
	stealth_behavior_system_init();
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/
stealth_behavior_system_init()
{
	assertEX( isdefined( level._stealth ), "There is no level._stealth struct.  You ran stealth behavior before running the detection logic.  Run _stealth_logic::main() in your level load first" );

	// this is our behavior struct inside of _stealth...everything we do will go in here.
	level._stealth.behavior = spawnstruct();
	level._stealth.node_search = spawnstruct();

	// bools to see if a sound has just been played
	level._stealth.behavior.sound = [];
	level._stealth.behavior.sound[ "huh" ] 		 = false;
	level._stealth.behavior.sound[ "hmph" ] 	 = false;
	level._stealth.behavior.sound[ "name" ]		 = false;
	level._stealth.behavior.sound[ "wtf" ] 		 = false;
	level._stealth.behavior.sound[ "spotted" ] 	 = [];
	level._stealth.behavior.sound[ "corpse" ] 	 = false;
	level._stealth.behavior.sound[ "alert" ] 	 = false;
	level._stealth.behavior.sound[ "acknowledge" ] = false;
	
	level._stealth.behavior.sound_reset_time = 3;
}