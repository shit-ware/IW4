#include maps\_utility;
#include maps\_anim;
#include common_scripts\utility;

#using_animtree( "generic_human" );
main( dialogue_array )
{
	if ( isdefined( dialogue_array ) )
	{
		level.dynamic_run_speed_dialogue = dialogue_array;
		foreach ( value in dialogue_array )
		{
			level.scr_radio[ value ] = value;
		}
	}
	level.scr_anim[ "generic" ][ "DRS_sprint" ]				 = %sprint1_loop;
	level.scr_anim[ "generic" ][ "DRS_combat_jog" ]			 = %combat_jog;// patrol_jog;
	level.scr_anim[ "generic" ][ "DRS_run_2_stop" ]			 = %run_2_crouch_F;		// run_2_stand_F_6;
	level.scr_anim[ "generic" ][ "DRS_stop_idle" ][ 0 ]		 = %exposed_crouch_aim_5;	// stand_aim_straight;	// casual_stand_idle

	//	level.scr_anim[ "generic" ][ "DRS_moveup" ]				= %	stand_exposed_wave_move_up;
	level.scr_anim[ "generic" ][ "signal_go" ]				 = %CQB_stand_wave_go_v1;
	
	level.drs_ahead_test = maps\_utility_code::dynamic_run_ahead_test;
}