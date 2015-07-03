//dont forget to add:
//include,common_hand_signals
//to your csv

#using_animtree( "generic_human" );

initHandSignals()
{
	level.scr_anim[ "generic" ][ "signal_moveout_cqb" ]		= %CQB_stand_signal_move_out;
	level.scr_anim[ "generic" ][ "signal_moveup_cqb" ]		= %CQB_stand_signal_move_up;
	level.scr_anim[ "generic" ][ "signal_stop_cqb" ]		= %CQB_stand_signal_stop;
	level.scr_anim[ "generic" ][ "signal_onme_cqb" ]		= %CQB_stand_wave_on_me;
	level.scr_anim[ "generic" ][ "signal_enemy_cqb" ]		= %CQB_stand_signal_stop;					// TEMP
	level.scr_anim[ "generic" ][ "signal_go_cqb" ]			= %CQB_stand_wave_go_v1;

	level.scr_anim[ "generic" ][ "signal_moveout" ]			= %stand_exposed_wave_move_out;
	level.scr_anim[ "generic" ][ "signal_moveup" ]			= %stand_exposed_wave_move_up;
	level.scr_anim[ "generic" ][ "signal_stop" ]			= %stand_exposed_wave_halt;
	level.scr_anim[ "generic" ][ "signal_onme" ]			= %stand_exposed_wave_on_me;
	level.scr_anim[ "generic" ][ "signal_enemy" ]			= %stand_exposed_wave_target_spotted;
	level.scr_anim[ "generic" ][ "signal_go" ]				= %stand_exposed_wave_go;
	//level.scr_anim[ "generic" ][ "signal_down" ]			= %stand_exposed_wave_down;
	
	// TEMP execpt additive go animation
	level.scr_anim[ "generic" ][ "signal_moveout_crouch" ]	= %CQB_stand_wave_go_v1;
	level.scr_anim[ "generic" ][ "signal_moveup_crouch" ]	= %CQB_stand_wave_go_v1;
	level.scr_anim[ "generic" ][ "signal_stop_crouch" ]		= %CQB_stand_wave_go_v1;
	level.scr_anim[ "generic" ][ "signal_onme_crouch" ]		= %CQB_stand_wave_go_v1;
	level.scr_anim[ "generic" ][ "signal_enemy_crouch" ]	= %CQB_stand_wave_go_v1;					
	level.scr_anim[ "generic" ][ "signal_go_crouch" ]		= %CQB_stand_wave_go_v1;
		
	level.scr_anim[ "generic" ][ "signal_moveout_coverR" ]	= %CornerStndR_alert_signal_move_out;
	level.scr_anim[ "generic" ][ "signal_moveup_coverR" ]	= %CornerStndR_alert_signal_move_out;		// TEMP
	level.scr_anim[ "generic" ][ "signal_stop_coverR" ]		= %CornerStndR_alert_signal_stopStay_down;
	level.scr_anim[ "generic" ][ "signal_onme_coverR" ]		= %CornerStndR_alert_signal_on_me;
	level.scr_anim[ "generic" ][ "signal_enemy_coverR" ]	= %CornerStndR_alert_signal_enemy_spotted;
	level.scr_anim[ "generic" ][ "signal_go_coverR" ]		= %CornerStndR_alert_signal_move_out;		// TEMP
}