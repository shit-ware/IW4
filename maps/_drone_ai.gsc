#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "generic_human" );

init()
{
	// drone type specific stuff
	level.drone_anims[ "allies" ][ "stand" ][ "idle" ]					= %casual_stand_idle;
	level.drone_anims[ "allies" ][ "stand" ][ "run" ]	 				= %run_lowready_F_relative;
	level.drone_anims[ "allies" ][ "stand" ][ "death" ]	 				= %exposed_death;
	
	//allies
	level.drone_anims[ "allies" ][ "covercrouch" ][ "idle" ][ 0 ]	 	= %covercrouch_hide_idle;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "idle" ][ 1 ]	 	= %covercrouch_twitch_1;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "idle" ][ 2 ]	 	= %covercrouch_twitch_2;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "idle" ][ 3 ]	 	= %covercrouch_twitch_3;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "idle" ][ 4 ]	 	= %covercrouch_hide_look;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "hide_2_aim" ]	 	= %covercrouch_hide_2_aim;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "aim_2_hide" ]	 	= %covercrouch_aim_2_hide;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "reload" ]	 		= %covercrouch_reload_hide;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "fire" ]	 		= %covercrouch_aim5;
	level.drone_anims[ "allies" ][ "covercrouch" ][ "death" ]	 		= %covercrouch_death_1;
	//level.drone_anims[ "allies" ][ "covercrouch" ][ "arrival" ]	 		= %covercrouch_run_in_M;

	level.drone_anims[ "allies" ][ "coverstand" ][ "idle" ][ 0 ]	 	= %coverstand_hide_idle;
	level.drone_anims[ "allies" ][ "coverstand" ][ "idle" ][ 1 ]	 	= %coverstand_look_quick;
	level.drone_anims[ "allies" ][ "coverstand" ][ "idle" ][ 2 ]	 	= %coverstand_look_quick_v2;
	level.drone_anims[ "allies" ][ "coverstand" ][ "idle" ][ 3 ]	 	= %coverstand_hide_idle_twitch04;
	level.drone_anims[ "allies" ][ "coverstand" ][ "idle" ][ 4 ]	 	= %coverstand_hide_idle_twitch05;
	level.drone_anims[ "allies" ][ "coverstand" ][ "hide_2_aim" ]	 	= %coverstand_hide_2_aim;
	level.drone_anims[ "allies" ][ "coverstand" ][ "aim_2_hide" ]	 	= %coverstand_aim_2_hide;
	level.drone_anims[ "allies" ][ "coverstand" ][ "reload" ]	 		= %coverstand_reloadA;
	level.drone_anims[ "allies" ][ "coverstand" ][ "fire" ]	 		= %exposed_aim_5;
	level.drone_anims[ "allies" ][ "coverstand" ][ "death" ]	 		= %coverstand_death_left;
	//level.drone_anims[ "allies" ][ "coverstand" ][ "arrival" ]	 	= %coverstand_trans_IN_M;
	
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "idle" ][ 0 ]	 	= %corner_standL_alert_idle;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "idle" ][ 1 ]	 	= %corner_standL_alert_twitch01;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "idle" ][ 2 ]	 	= %corner_standL_alert_twitch02;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "idle" ][ 3 ]	 	= %corner_standL_alert_twitch03;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "idle" ][ 4 ]	 	= %corner_standL_alert_twitch04;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "hide_2_aim" ]	= %corner_standL_trans_alert_2_B_v2;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "aim_2_hide" ]	= %corner_standL_trans_B_2_alert_v2;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "reload" ]	 	= %corner_standL_reload_v1;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "fire" ]	 		= %exposed_aim_5;
	level.drone_anims[ "allies" ][ "coverleftstand" ][ "death" ]	 		= %corner_standL_deathB;
	//level.drone_anims[ "allies" ][ "coverleftstand" ][ "arrival" ]	 	= %corner_standL_trans_IN_2;

	level.drone_anims[ "allies" ][ "coverrightstand" ][ "idle" ][ 0 ]	 	= %corner_standR_alert_idle;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "idle" ][ 1 ]	 	= %corner_standR_alert_twitch01;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "idle" ][ 2 ]	 	= %corner_standR_alert_twitch02;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "idle" ][ 3 ]	 	= %corner_standR_alert_twitch04;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "hide_2_aim" ]	= %corner_standR_trans_alert_2_B;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "aim_2_hide" ]	= %corner_standR_trans_B_2_alert;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "reload" ]	 	= %corner_standR_reload_v1;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "fire" ]	 		= %exposed_aim_5;
	level.drone_anims[ "allies" ][ "coverrightstand" ][ "death" ]	 		= %corner_standR_deathB;
	//level.drone_anims[ "allies" ][ "coverrightstand" ][ "arrival" ]	 	= %corner_standR_trans_IN_2;

	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "idle" ][ 0 ]	 	= %CornerCrR_alert_idle;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "idle" ][ 1 ]	 	= %CornerCrR_alert_twitch_v1;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "idle" ][ 2 ]	 	= %CornerCrR_alert_twitch_v2;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "idle" ][ 3 ]	 	= %CornerCrR_alert_twitch_v3;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "hide_2_aim" ]		= %CornerCrR_alert_2_lean;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "aim_2_hide" ]		= %CornerCrR_lean_2_alert;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "reload" ]	 		= %CornerCrR_reloadA;
	level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "death" ]	 		= %exposed_crouch_death_fetal;
	//level.drone_anims[ "allies" ][ "coverrightcrouch" ][ "arrival" ]	 		= %CornerCrR_trans_IN_M;
	
	
	level.drone_anims[ "allies" ][ "coverguard" ][ "idle" ][ 0 ]	 	= %exposed_crouch_idle_twitch_v2;
	level.drone_anims[ "allies" ][ "coverguard" ][ "idle" ][ 1 ]	 	= %exposed_crouch_idle_twitch_v3;
	level.drone_anims[ "allies" ][ "coverguard" ][ "reload" ]	 		= %exposed_crouch_reload;
	level.drone_anims[ "allies" ][ "coverguard" ][ "fire" ]	 		= %exposed_crouch_aim_5;
	level.drone_anims[ "allies" ][ "coverguard" ][ "death" ]	 		= %exposed_crouch_death_fetal;
	//level.drone_anims[ "allies" ][ "coverguard" ][ "arrival" ]	 	= %run_2_crouch_F;
	
	
	level.drone_anims[ "allies" ][ "coverprone" ][ "idle" ][ 0 ]	 	= %prone_reaction_A;
	level.drone_anims[ "allies" ][ "coverprone" ][ "idle" ][ 1 ]	 	= %prone_twitch_ammocheck;
	level.drone_anims[ "allies" ][ "coverprone" ][ "idle" ][ 2 ]	 	= %prone_twitch_scan;
	level.drone_anims[ "allies" ][ "coverprone" ][ "idle" ][ 3 ]	 	= %prone_twitch_look;
	level.drone_anims[ "allies" ][ "coverprone" ][ "idle" ][ 4 ]	 	= %prone_twitch_lookup;
	level.drone_anims[ "allies" ][ "coverprone" ][ "hide_2_aim" ]	 	= %prone_2_crouch;
	level.drone_anims[ "allies" ][ "coverprone" ][ "aim_2_hide" ]	 	= %crouch_2_prone;
	level.drone_anims[ "allies" ][ "coverprone" ][ "reload" ]	 		= %prone_reload;
	level.drone_anims[ "allies" ][ "coverprone" ][ "fire" ]	 		= %prone_fire_1;
	level.drone_anims[ "allies" ][ "coverprone" ][ "fire_exposed" ]	= %exposed_crouch_aim_5;  //special case for when prone guys occassionally stand up to fire
	level.drone_anims[ "allies" ][ "coverprone" ][ "death" ]	 		= %saw_gunner_prone_death;
	//level.drone_anims[ "allies" ][ "coverprone" ][ "arrival" ]	 	= %crouchrun2prone_straight;
	
	
	//axis
	level.drone_anims[ "axis" ][ "stand" ][ "idle" ]			= %casual_stand_idle;
	level.drone_anims[ "axis" ][ "stand" ][ "run" ]	 			= %run_lowready_F_relative;
	level.drone_anims[ "axis" ][ "stand" ][ "death" ]	 		= %exposed_death;
	
	level.drone_anims[ "axis" ][ "covercrouch" ][ "idle" ][ 0 ]	 	= %covercrouch_hide_idle;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "idle" ][ 1 ]	 	= %covercrouch_twitch_1;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "idle" ][ 2 ]	 	= %covercrouch_twitch_2;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "idle" ][ 3 ]	 	= %covercrouch_twitch_3;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "idle" ][ 4 ]	 	= %covercrouch_hide_look;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "hide_2_aim" ]	 	= %covercrouch_hide_2_aim;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "aim_2_hide" ]	 	= %covercrouch_aim_2_hide;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "reload" ]	 		= %covercrouch_reload_hide;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "fire" ]	 		= %covercrouch_aim5;
	level.drone_anims[ "axis" ][ "covercrouch" ][ "death" ]	 		= %covercrouch_death_1;
	//level.drone_anims[ "axis" ][ "covercrouch" ][ "arrival" ]	 		= %covercrouch_run_in_M;

	level.drone_anims[ "axis" ][ "coverstand" ][ "idle" ][ 0 ]	 	= %coverstand_hide_idle;
	level.drone_anims[ "axis" ][ "coverstand" ][ "idle" ][ 1 ]	 	= %coverstand_look_quick;
	level.drone_anims[ "axis" ][ "coverstand" ][ "idle" ][ 2 ]	 	= %coverstand_look_quick_v2;
	level.drone_anims[ "axis" ][ "coverstand" ][ "idle" ][ 3 ]	 	= %coverstand_hide_idle_twitch04;
	level.drone_anims[ "axis" ][ "coverstand" ][ "idle" ][ 4 ]	 	= %coverstand_hide_idle_twitch05;
	level.drone_anims[ "axis" ][ "coverstand" ][ "hide_2_aim" ]	 	= %coverstand_hide_2_aim;
	level.drone_anims[ "axis" ][ "coverstand" ][ "aim_2_hide" ]	 	= %coverstand_aim_2_hide;
	level.drone_anims[ "axis" ][ "coverstand" ][ "reload" ]	 		= %coverstand_reloadA;
	level.drone_anims[ "axis" ][ "coverstand" ][ "fire" ]	 		= %exposed_aim_5;
	level.drone_anims[ "axis" ][ "coverstand" ][ "death" ]	 		= %coverstand_death_left;
	//level.drone_anims[ "axis" ][ "coverstand" ][ "arrival" ]	 	= %coverstand_trans_IN_M;
	
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "idle" ][ 0 ]	 	= %corner_standL_alert_idle;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "idle" ][ 1 ]	 	= %corner_standL_alert_twitch01;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "idle" ][ 2 ]	 	= %corner_standL_alert_twitch02;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "idle" ][ 3 ]	 	= %corner_standL_alert_twitch03;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "idle" ][ 4 ]	 	= %corner_standL_alert_twitch04;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "hide_2_aim" ]	= %corner_standL_trans_alert_2_B_v2;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "aim_2_hide" ]	= %corner_standL_trans_B_2_alert_v2;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "reload" ]	 	= %corner_standL_reload_v1;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "fire" ]	 		= %exposed_aim_5;
	level.drone_anims[ "axis" ][ "coverleftstand" ][ "death" ]	 		= %corner_standL_deathB;
	//level.drone_anims[ "axis" ][ "coverleftstand" ][ "arrival" ]	 	= %corner_standL_trans_IN_2;

	level.drone_anims[ "axis" ][ "coverrightstand" ][ "idle" ][ 0 ]	 	= %corner_standR_alert_idle;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "idle" ][ 1 ]	 	= %corner_standR_alert_twitch01;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "idle" ][ 2 ]	 	= %corner_standR_alert_twitch02;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "idle" ][ 3 ]	 	= %corner_standR_alert_twitch04;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "hide_2_aim" ]	= %corner_standR_trans_alert_2_B;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "aim_2_hide" ]	= %corner_standR_trans_B_2_alert;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "reload" ]	 	= %corner_standR_reload_v1;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "fire" ]	 		= %exposed_aim_5;
	level.drone_anims[ "axis" ][ "coverrightstand" ][ "death" ]	 		= %corner_standR_deathB;
	//level.drone_anims[ "axis" ][ "coverrightstand" ][ "arrival" ]	 	= %corner_standR_trans_IN_2;

	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "idle" ][ 0 ]	 	= %CornerCrR_alert_idle;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "idle" ][ 1 ]	 	= %CornerCrR_alert_twitch_v1;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "idle" ][ 2 ]	 	= %CornerCrR_alert_twitch_v2;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "idle" ][ 3 ]	 	= %CornerCrR_alert_twitch_v3;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "hide_2_aim" ]		= %CornerCrR_alert_2_lean;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "aim_2_hide" ]		= %CornerCrR_lean_2_alert;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "reload" ]	 		= %CornerCrR_reloadA;
	level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "death" ]	 		= %exposed_crouch_death_fetal;
	//level.drone_anims[ "axis" ][ "coverrightcrouch" ][ "arrival" ]	 		= %CornerCrR_trans_IN_M;
	
	
	level.drone_anims[ "axis" ][ "coverguard" ][ "idle" ][ 0 ]	 	= %exposed_crouch_idle_twitch_v2;
	level.drone_anims[ "axis" ][ "coverguard" ][ "idle" ][ 1 ]	 	= %exposed_crouch_idle_twitch_v3;
	level.drone_anims[ "axis" ][ "coverguard" ][ "reload" ]	 		= %exposed_crouch_reload;
	level.drone_anims[ "axis" ][ "coverguard" ][ "fire" ]	 		= %exposed_crouch_aim_5;
	level.drone_anims[ "axis" ][ "coverguard" ][ "death" ]	 		= %exposed_crouch_death_fetal;
	//level.drone_anims[ "axis" ][ "coverguard" ][ "arrival" ]	 	= %run_2_crouch_F;
	
	
	level.drone_anims[ "axis" ][ "coverprone" ][ "idle" ][ 0 ]	 	= %prone_reaction_A;
	level.drone_anims[ "axis" ][ "coverprone" ][ "idle" ][ 1 ]	 	= %prone_twitch_ammocheck;
	level.drone_anims[ "axis" ][ "coverprone" ][ "idle" ][ 2 ]	 	= %prone_twitch_scan;
	level.drone_anims[ "axis" ][ "coverprone" ][ "idle" ][ 3 ]	 	= %prone_twitch_look;
	level.drone_anims[ "axis" ][ "coverprone" ][ "idle" ][ 4 ]	 	= %prone_twitch_lookup;
	level.drone_anims[ "axis" ][ "coverprone" ][ "hide_2_aim" ]	 	= %prone_2_crouch;
	level.drone_anims[ "axis" ][ "coverprone" ][ "aim_2_hide" ]	 	= %crouch_2_prone;
	level.drone_anims[ "axis" ][ "coverprone" ][ "reload" ]	 		= %prone_reload;
	level.drone_anims[ "axis" ][ "coverprone" ][ "fire" ]	 		= %prone_fire_1;
	level.drone_anims[ "axis" ][ "coverprone" ][ "fire_exposed" ]	= %exposed_crouch_aim_5;  //special case for when prone guys occassionally stand up to fire
	level.drone_anims[ "axis" ][ "coverprone" ][ "death" ]	 		= %saw_gunner_prone_death;
	//level.drone_anims[ "axis" ][ "coverprone" ][ "arrival" ]	 	= %crouchrun2prone_straight;
	
	//team3 (?)
	level.drone_anims[ "team3" ][ "stand" ][ "idle" ]			= %casual_stand_idle;
	level.drone_anims[ "team3" ][ "stand" ][ "run" ]	 		= %run_lowready_F_relative;
	level.drone_anims[ "team3" ][ "stand" ][ "death" ]	 		= %exposed_death;
	
	
	//muzzleflashes, etc
	level._effect[ "ak47_muzzleflash" ]		        = loadfx( "muzzleflashes/ak47_flash_wv" );
	level._effect[ "m16_muzzleflash" ]		        = loadfx( "muzzleflashes/m16_flash_wv" );
	
	
	// init the generic drone script
	maps\_drone::initGlobals();
}