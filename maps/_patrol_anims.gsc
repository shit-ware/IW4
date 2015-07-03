main()
{
	humans();
	dogs();
}

#using_animtree( "generic_human" );
humans()
{
	level.scr_anim[ "generic" ][ "patrol_walk" ]			 = %patrol_bored_patrolwalk;
	level.scr_anim[ "generic" ][ "patrol_walk_twitch" ]		 = %patrol_bored_patrolwalk_twitch;
	level.scr_anim[ "generic" ][ "patrol_stop" ]			 = %patrol_bored_walk_2_bored;
	level.scr_anim[ "generic" ][ "patrol_start" ]			 = %patrol_bored_2_walk;
	level.scr_anim[ "generic" ][ "patrol_turn180" ]			 = %patrol_bored_2_walk_180turn;
	level.scr_anim[ "generic" ][ "patrol_radio_in_clear" ]	 = %patrolwalk_cold_gunup_transition;


	level.scr_anim[ "generic" ][ "patrol_idle_1" ]			 = %patrol_bored_idle;
	level.scr_anim[ "generic" ][ "patrol_idle_2" ]			 = %patrol_bored_idle_smoke;
	level.scr_anim[ "generic" ][ "patrol_idle_3" ]			 = %patrol_bored_idle_cellphone;
	level.scr_anim[ "generic" ][ "patrol_idle_4" ]			 = %patrol_bored_twitch_bug;
	level.scr_anim[ "generic" ][ "patrol_idle_5" ]			 = %patrol_bored_twitch_checkphone;
	level.scr_anim[ "generic" ][ "patrol_idle_6" ]			 = %patrol_bored_twitch_stretch;

	level.scr_anim[ "generic" ][ "patrol_idle_smoke" ]		 = %patrol_bored_idle_smoke;
	level.scr_anim[ "generic" ][ "patrol_idle_checkphone" ]	 = %patrol_bored_twitch_checkphone;
	level.scr_anim[ "generic" ][ "patrol_idle_stretch" ]	 = %patrol_bored_twitch_stretch;
	level.scr_anim[ "generic" ][ "patrol_idle_phone" ]		 = %patrol_bored_idle_cellphone;
}

#using_animtree( "dog" );
dogs()
{
	level.scr_anim[ "generic" ][ "patrol_dog_stop" ]		 = %german_shepherd_run_stop;
	level.scr_anim[ "generic" ][ "patrol_dog_start" ]		 = %german_shepherd_run_start;
}
