main()
{
	humans();
	dogs();
}

#using_animtree( "generic_human" );
humans()
{
	// every stealth level has this anim and it's required by stealth behavior
	level.scr_anim[ "generic" ][ "patrol_turn180" ]				 = %patrol_bored_2_walk_180turn;

	level.scr_anim[ "generic" ][ "_stealth_patrol_jog" ]				= %patrol_jog;
	level.scr_anim[ "generic" ][ "_stealth_patrol_walk" ]				= %patrol_bored_patrolwalk;
	level.scr_anim[ "generic" ][ "_stealth_combat_jog" ]				= %combat_jog;
	level.scr_anim[ "generic" ][ "_stealth_patrol_cqb" ]				= %walk_CQB_F;

	if ( !isdefined( level.scr_anim[ "generic" ][ "_stealth_patrol_search_a" ] ) )
	{
		level.scr_anim[ "generic" ][ "_stealth_patrol_search_a" ]		= %patrol_boredwalk_lookcycle_A;
		level.scr_anim[ "generic" ][ "_stealth_patrol_search_b" ]		= %patrol_boredwalk_lookcycle_B;
	}

	level.scr_anim[ "generic" ][ "_stealth_behavior_spotted_short" ]	= %exposed_idle_twitch_v4;
	level.scr_anim[ "generic" ][ "_stealth_behavior_spotted_long" ]		= %patrol_bored_react_walkstop_short;

	level.scr_anim[ "generic" ][ "_stealth_look_around" ][ 0 ]			= %patrol_bored_react_look_v1;
	level.scr_anim[ "generic" ][ "_stealth_look_around" ][ 1 ]			= %patrol_bored_react_look_v2;

	level.scr_anim[ "generic" ][ "_stealth_behavior_saw_corpse" ]		= %exposed_idle_twitch_v4;

	//1 is the animation that looks the best at the closest range (fast reaction )...and slower
	//reactions get added down the line		
	level.scr_anim[ "generic" ][ "_stealth_behavior_generic1" ]			= %patrol_bored_react_look_advance;
	level.scr_anim[ "generic" ][ "_stealth_behavior_generic2" ]			= %patrol_bored_react_look_retreat;
	level.scr_anim[ "generic" ][ "_stealth_behavior_generic3" ]			= %patrol_bored_react_walkstop;
	level.scr_anim[ "generic" ][ "_stealth_behavior_generic4" ]			= %patrol_bored_react_walkstop_short;

	//find a body FROM a walk jog or run
	//level.scr_anim[ "generic" ][ "_stealth_find_walk" ]				= %patrol_boredwalk_find;
	level.scr_anim[ "generic" ][ "_stealth_find_jog" ]					= %patrol_boredjog_find;
	//level.scr_anim[ "generic" ][ "_stealth_find_run" ]				= %patrol_boredrun_find;
	level.scr_anim[ "generic" ][ "_stealth_find_stand" ]				= %patrol_bored_react_look_v2;

	//FRIENDLY STUFF
	level.scr_anim[ "generic" ][ "_stealth_prone_idle" ][ 0 ] 			= %prone_aim_idle;
	level.scr_anim[ "generic" ][ "_stealth_prone_stop" ] 				= %prone_crawl_2_prone;
	level.scr_anim[ "generic" ][ "_stealth_prone_start" ] 				= %prone_2_prone_crawl;
	level.scr_anim[ "generic" ][ "_stealth_prone_2_run_roll" ]			= %hunted_pronehide_2_stand_v4;

}

#using_animtree( "dog" );
dogs()
{
	level.scr_anim[ "generic" ][ "_stealth_dog_sleeping" ][ 0 ]		 = %german_shepherd_sleeping;

	level.scr_anim[ "generic" ][ "_stealth_dog_stop" ]				 = %german_shepherd_run_stop;

	level.scr_anim[ "generic" ][ "_stealth_dog_find" ]				 = %german_shepherd_run_flashbang;
	level.scr_anim[ "generic" ][ "_stealth_dog_howl" ]				 = %german_shepherd_attackidle_bark;
	level.scr_anim[ "generic" ][ "_stealth_dog_saw_corpse" ]		 = %german_shepherd_attackidle_bark;
	level.scr_anim[ "generic" ][ "_stealth_dog_growl" ]				 = %german_shepherd_attackidle_growl;

	level.scr_anim[ "generic" ][ "_stealth_dog_wakeup_fast" ]		 = %german_shepherd_wakeup_fast;
	level.scr_anim[ "generic" ][ "_stealth_dog_wakeup_slow" ]		 = %german_shepherd_wakeup_slow;
}
