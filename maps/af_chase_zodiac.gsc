#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_vehicle_spline_zodiac;

/************************************************************************************************************/
/*													zodiac												*/
/************************************************************************************************************/


clear_all_ai_grenades()
{
	add_global_spawn_function( "axis", ::no_grenades );
	ai = getaiarray( "axis" );
	foreach( guy in ai )
		guy no_grenades();
}

no_grenades()
{
	self.grenadeammo = 0;
}


zodiac_main()
{
	thread enemy_zodiacs_wipe_out();
	
	init_vehicle_splines();

// I need to do this too. because the use hint for mounting the zodiac happens to late.
//	zodiac_triggers = getentarray( "zodiac_trigger", "targetname" );
//	array_call( zodiac_triggers, ::setHintString, "Press &&1 to mount" );

	clear_all_ai_grenades();
	
	level.enemy_snowmobiles_max = 1;
	
//	kill_enemy_zodiacs = getentarray( "kill_enemy_zodiac", "targetname" );
//	array_thread( kill_enemy_zodiacs, ::kill_enemy_zodiac_think );
	
// think this is what I might use to put the zodiac in position to kill the helicopter at the end.
//	player_path_triggers = getentarray( "player_path_trigger", "targetname" );
//	array_thread( player_path_triggers, ::player_path_trigger_think );
	
	flag_wait( "player_on_boat" );

	// faster regen for this part to make it more exciting
	level.longRegenTime = 2000;

	// a little extra invul time for the harder difs
	if ( level.player.deathInvulnerableTime > 2000 )
		level.player.deathInvulnerableTime = 2000;

	zodiac = level.players_boat;
	assert( isdefined( zodiac ) );

	
	level.player thread track_player_progress( zodiac.origin );
//	flag_set( "player_gets_on_zodiac" );
//	thread missile_repulser();

	// this when real ai boats start coming in
	flag_wait( "exit_caves" );

	level.player.baseIgnoreRandomBulletDamage = true;
	level.ignoreRandomBulletDamage = true;

	level.doPickyAutosaveChecks = false;
	level.autosave_threat_check_enabled = false;

//	setsaveddvar( "sm_sunSampleSizeNear", 1 );
//	autosave_by_name( "ride_the_bike" );

	level.bike_score = 0;
	thread enemy_zodiacs_spawn_and_attack();
}


player_path_trigger_think()
{
	self waittill( "trigger" );
	node = getvehiclenode( self.target, "targetname" );
//	level.player.vehicle attachPath( node );
	level.player.vehicle.veh_pathType = "follow";
	level.player.vehicle startPath( node );
}

enemy_zodiacs_spawn_and_attack()
{
	if( flag( "enemy_zodiacs_wipe_out" ) )
		return;
	level endon( "enemy_zodiacs_wipe_out" );
	wait_time = 3;
	wait( 2 );
	for ( ;; )
	{
		thread spawn_enemy_bike();
		wait( wait_time );
		wait_time -= 0.5;
		if ( wait_time < 0.5 )
			wait_time = 0.5;
		//wait( randomfloatrange( 2, 3 ) );		
	}
}


trigger_enemy_zodiacs_wipe_out()
{
	self waittill ( "trigger" );
	flag_set( "enemy_zodiacs_wipe_out" );
}

enemy_zodiacs_wipe_out()
{
	flag_wait( "enemy_zodiacs_wipe_out" );
	foreach ( enemy in level.enemy_snowmobiles)
	{
		enemy thread wipeout_soon();
	}
}

wipeout_soon()
{
	self endon( "death" );
	wait( randomfloatrange( 2, 4 ) );
	if ( !isdefined( self ) )
		return;
	self.wipeout = true;	
}
