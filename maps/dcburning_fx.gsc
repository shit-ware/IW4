#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;

main()
{
	//!!!!! This is not actually called anywhere, but it needs to load immediately otherwise I get a precache error (?)
	level._effect[ "_attack_heli_spotlight_ending" ]	 = LoadFX( "misc/hunted_spotlight_model_dim" );
	//!!!!! This is not actually called anywhere, but it needs to load immediately otherwise I get a precache error (?)
	
	
	
	
	level._effect[ "vehicle_explosion_slamraam" ]	 = LoadFX( "explosions/vehicle_explosion_slamraam" );
	
	level._effect[ "_attack_heli_spotlight" ]	 = LoadFX( "misc/spotlight_large_dcburning" );
	
	//columns
	level._effect[ "large_column" ]			 = loadfx( "props/dcburning_pillars" );
	
	
	//Vehcile DeathFX Overrides
	maps\_vehicle::build_deathfx_override( "m1a1", "vehicle_m1a1_abrams", "explosions/javelin_explosion_dcburn", undefined , "exp_javelin_armor_destroy" );
	maps\_vehicle::build_deathfx_override( "hummer", "vehicle_hummer", "explosions/javelin_explosion_dcburn", undefined , "exp_javelin_armor_destroy" );
	maps\_vehicle::build_deathfx_override( "seaknight", "vehicle_ch46e_low", "explosions/javelin_explosion_dcburn", undefined , "exp_javelin_armor_destroy" );
	maps\_vehicle::build_deathfx_override( "bradley", "vehicle_bradley", "explosions/javelin_explosion_dcburn", undefined , "exp_javelin_armor_destroy" );

	level._effect[ "turret_overheat_haze" ]				 = loadfx( "distortion/abrams_exhaust" );
	level._effect[ "turret_overheat_smoke" ]			 = loadfx( "distortion/armored_car_overheat" );

	//Magic Bullet Muzzleflashes
	level._effect[ "javelin_muzzle" ] 					= loadfx( "muzzleflashes/javelin_flash_wv" );

	level._effect[ "light_glow_white_bulb" ]			 = loadfx( "misc/light_glow_white_bulb" );
	
	level._effect[ "door_kick_dust" ]				 = loadfx( "dust/door_kick" );
	
	
	level._effect[ "dlight_laptop" ] 						= loadfx( "misc/dlight_laptop" );
	
	/*-----------------------
	CHEAP VEHICLE EXPLOSIONS
	-------------------------*/	
	level._effect[ "large_vehicle_explosion" ] 		 = loadfx( "explosions/large_vehicle_explosion" );
	level._effect[ "cheap_vehicle_explosion" ]		 = loadfx( "explosions/small_vehicle_explosion_low" );
	level._effect[ "cheap_mack_truck_explosion" ] 	 = loadfx( "explosions/tanker_explosion_dcburn" );
	level._effect[ "tanker_fire" ]					 = loadfx( "fire/firelp_large_pm" );
	
	/*-----------------------
	PLAYER BLACKHAWK  CRASH
	-------------------------*/	
	level._effect[ "smoke_trail_black_heli" ] 			= loadfx( "smoke/smoke_trail_black_heli" );
	level._effect[ "dlight_blue" ] 						= loadfx( "misc/dlight_blue" );
	level._effect[ "dlight_red" ] 						= loadfx( "misc/aircraft_light_cockpit_red" );
	level._effect[ "player_death_explosion" ]			= loadfx( "explosions/player_death_explosion" );
	level._effect[ "heat_shimmer_door" ]				= loadfx( "distortion/abrams_exhaust" );
	
	level._effect[ "firelp_large_pm_nolight" ]					= loadfx( "fire/firelp_large_pm_nolight" );
	level._effect[ "firelp_med_pm_nolight" ]					= loadfx( "fire/firelp_med_pm_nolight" );
	level._effect[ "firelp_small_pm_nolight" ]					= loadfx( "fire/firelp_small_pm_nolight" );
	
	/*-----------------------
	LITTLEBIRD CRASH
	-------------------------*/	
	level._effect[ "crash_main_01" ] 		= loadfx( "explosions/javelin_explosion_dcburn" );
	level._effect[ "crash_end_01" ] 	 	= loadfx( "explosions/helicopter_explosion_little_bird_dcburn" );
	
	level._effect[ "chopper_smoke_trail" ]		 = loadfx( "fire/fire_smoke_trail_L" );
	level._effect[ "chopper_explosion" ] 			 = loadfx( "explosions/aerial_explosion" );

	/*-----------------------
	Sniping
	-------------------------*/	
	level._effect[ "headshot" ]						 = loadfx( "impacts/flesh_hit_head_fatal_exit" );	// sprays on wall
	level._effect[ "headshot2" ]					 = loadfx( "impacts/flesh_hit_splat_large" );		// chunks
	level._effect[ "headshot3" ]					 = loadfx( "impacts/flesh_hit_body_fatal_exit" );	// big spray
	level._effect[ "headshot4" ]					 = loadfx( "impacts/sniper_escape_blood" );	// big spray
	level._effect[ "bodyshot" ]						 = loadfx( "impacts/flesh_hit" );

	level._effect[ "thermal_body_gib" ]				 = loadfx( "impacts/thermal_body_gib" );	// splatter
	
	level._effect[ "flare_ambient" ]		 = loadfx( "misc/flare_ambient" );

	level._effect[ "heat_shimmer_door" ]				 = loadfx( "distortion/abrams_exhaust" );
	level._effect[ "heli_dust_default" ] 				 = loadfx( "treadfx/heli_dust_airlift" );
	
	
	/*-----------------------
	FLARES
	-------------------------*/	
	level._effect[ "flare_runner_intro" ]				 = loadfx( "misc/flare_start" );
	level._effect[ "flare_runner" ]					 = loadfx( "misc/flare" );
	level._effect[ "flare_runner_fizzout" ]			 = loadfx( "misc/flare_end" );
	
	
	/*-----------------------
	PLANE AIRSTRIKES
	-------------------------*/	
	level.airstrikefx 	 = loadfx( "explosions/clusterbomb" );
	//level.airstrikefx 	 = loadfx( "explosions/tanker_explosion" );
	//level.scr_sound[ "airstrike" ][ "explosion" ]				 = "mortar_incoming";

	/*-----------------------
	AMBIENT FX
	-------------------------*/	
	level._effect["powerline_runner"]							= loadfx ("explosions/powerline_runner");	

	level._effect[ "antiair_runner" ]							= loadfx( "misc/antiair_runner_night" );
	level._effect[ "hallway_smoke_dark" ]						= loadfx( "smoke/hallway_smoke_dark" );
	level._effect[ "ground_smoke_dcburning1200x1200" ]			= loadfx( "smoke/ground_smoke1200x1200_dcburning" );
	level._effect[ "thin_black_smoke_L" ]						= loadfx( "smoke/thin_black_smoke_L" );
	level._effect[ "thick_white_smoke_giant" ]					= loadfx( "smoke/thick_white_smoke_giant_dcburning" );
	level._effect[ "thick_dark_smoke_giant" ]					= loadfx( "smoke/thick_dark_smoke_giant_dcburning" );

	level._effect[ "firelp_small_pm" ]							= LoadFX( "fire/firelp_small_pm" );
	level._effect[ "firelp_small_pm_a" ]						= LoadFX( "fire/firelp_small_pm_a" );
	level._effect[ "firelp_med_pm" ]							= LoadFX( "fire/firelp_med_pm" );
	level._effect[ "firelp_large_pm" ]							= LoadFX( "fire/firelp_large_pm" );
	level._effect[ "firelp_vhc_lrg_pm_farview" ]				= loadfx( "fire/firelp_vhc_lrg_pm_farview" );

	level._effect[ "drips_slow" ]								= loadfx( "misc/drips_slow" );
	level._effect[ "drips_fast" ]								= loadfx( "misc/drips_fast" );
	level._effect[ "powerline_runner_cheap" ] 					= loadfx( "explosions/powerline_runner_cheap" );
	level._effect[ "water_pipe_spray" ]	 						= loadfx( "water/water_pipe_spray" );
	level._effect[ "cgo_ship_puddle_small" ]	 				= loadfx( "distortion/cgo_ship_puddle_small" );
	level._effect[ "rock_falling_small_runner" ]	 			= loadfx( "misc/rock_falling_small_runner" );


	//Exploders
	level._effect[ "ceiling_dust_default" ]						= loadfx( "dust/ceiling_dust_default" );
	level._effect[ "commerce_window_shatter" ] 					= loadfx( "props/car_glass_large" );
	maps\createfx\dcburning_fx::main();	

}

littlebird_monument_crash( crashStruct )
{
	while( isdefined( self ) )
	{
		self waittill( "damage", amount, attacker, enemy_org, impact_org, type );
		if ( !isdefined( type ) )
			continue;
		if ( !isdefined( attacker ) )
			continue;
		if ( !isdefined( amount ) )
			continue;
		if ( isplayer( attacker ) )
			continue;
		if ( ( type == "MOD_PROJECTILE" ) && ( amount > 999 ) )
			break;
		if ( ( type == "MOD_PROJECTILE_SPLASH" ) && ( amount == 4000 ) )
			break;
	}
	
	self vehicle_detachfrompath();
	self setvehgoalpos( crashStruct.origin, false );
	self thread play_sound_on_entity( "car_explode" );
	earthquake( .3, 1.5, level.player.origin, 1600 );
	self Vehicle_SetSpeed( 80 );
	self thread littlebird_spinout();
	
	array_thread( self.riders,::littlebird_monument_rider_death, self );
	playfxOnTag( getfx( "crash_main_01" ), self, "tag_deathfx" );
	while ( distance( self.origin, crashStruct.origin ) > 100 )
	{
		playfxOnTag( getfx( "chopper_smoke_trail" ), self, "tag_deathfx" );
		wait( .1 );
	}
	self thread play_sound_on_entity( "exp_tanker_vehicle" );
	dummy = spawn( "script_origin", self gettagorigin( "tag_deathfx" ) );
	playfx( getfx( "crash_end_01" ), dummy.origin );
	earthquake( .3, 2, level.player.origin, 1600 );
	self delete();
	dummy delete();
	
}


littlebird_monument_rider_death( heli )
{
	if ( ( self.script_startingposition == 0 ) || ( self.script_startingposition == 1 ) )
		return;
	tag = "tag_detach_right";
	linked = false;
	
	sAnim = undefined;
	if ( ( self.script_startingposition == 2 ) || ( self.script_startingposition == 3 ) || ( self.script_startingposition == 4 ) )
	{
		tag = "tag_detach_left";
	}
	if ( ( self.script_startingposition == 2 ) || ( self.script_startingposition == 5 ) )
		sAnim = "little_bird_death_guy1";
	if ( ( self.script_startingposition == 3 ) || ( self.script_startingposition == 6 ) || ( self.script_startingposition == 7 ) )
		sAnim = "little_bird_death_guy3";
	if ( self.script_startingposition == 4 ) 
	{
		linked = true;
		sAnim = "little_bird_death_guy2";
	}
	
	//wait( randomfloatrange( .1, .9 ) );
	self.animname = "generic";
	self setcontents( 0 );
	self stopanimscripted();
	self.skipdeathanim	= 1;
	self delaythread( randomfloatrange( .3, 1 ), ::play_sound_in_space, "generic_death_falling" );
	pos = heli gettagorigin( tag );
	angles = heli gettagangles( tag );
	dummy = undefined;
	if ( linked )
	{
		heli anim_generic( self, sAnim, tag );
	}
	else
	{
		dummy = spawn( "script_origin", pos );
		dummy.angles = angles;
		dummy thread updatePos( heli, tag );
		dummy thread ent_cleanup( heli );
		self unlink();
		self linkto( dummy );
		//thread debug_message( "dummy", undefined, 9999, dummy );
		dummy anim_generic( self, sAnim );
		self unlink();
	}
	
	if( isdefined( self ) )
		self kill();

}

ent_cleanup( ent )
{
	ent waittill( "death" );
	self delete();
}

updatePos( heli, tag )
{
	heli endon( "death" );
	self endon( "death " );
	org = undefined;
	while( true )
	{
		wait( 0.05 );
		org = heli gettagorigin( tag );
		self.origin = org;
		//self.origin = ( org[ 0 ], org[ 1 ], self.origin[ 2 ] );
	}
}



//littlebird_crash()
//{
//	thread flag_set_delayed( "littlebird_crash_path_end", 3 );
//	self thread play_sound_on_entity( "car_explode" );
//	earthquake( .3, 1.5, level.player.origin, 1600 );
//	self Vehicle_SetSpeed( 70 );
//	self thread littlebird_spinout();
//	array_thread( self.riders,::littlebird_rider_death, self );
//	playfxOnTag( getfx( "crash_main_01" ), self, "tag_deathfx" );
//	while ( !flag( "littlebird_crash_path_end") )
//	{
//		playfxOnTag( getfx( "chopper_smoke_trail" ), self, "tag_deathfx" );
//		wait( .1 );
//	}
//	self thread play_sound_on_entity( "exp_tanker_vehicle" );
//	dummy = spawn( "script_origin", self gettagorigin( "tag_deathfx" ) );
//	playfx( getfx( "crash_main_02" ), dummy.origin );
//	playfx( getfx( "crash_end_01" ), dummy.origin );
//	playfx( getfx( "crash_end_02" ), dummy.origin );
//	earthquake( .3, 2, level.player.origin, 1600 );
//	self delete();
//	
//}
//
//littlebird_crash2()
//{
//	//thread flag_set_delayed( "littlebird_crash_02_end", 3 );
//	self thread play_sound_on_entity( "car_explode" );
//	array_thread( self.riders,::littlebird_rider_death, self );
//	earthquake( .3, 1.5, level.player.origin, 1600 );
//	//self Vehicle_SetSpeed( 70 );
//	
//	self thread littlebird_spinout();
//	
//	playfxOnTag( getfx( "crash_main_01" ), self, "tag_deathfx" );
//	while ( !flag( "littlebrid_crash_02_end") )
//	{
//		playfxOnTag( getfx( "chopper_smoke_trail" ), self, "tag_deathfx" );
//		wait( .1 );
//	}
//	self thread play_sound_on_entity( "exp_tanker_vehicle" );
//	dummy = spawn( "script_origin", self gettagorigin( "tag_deathfx" ) );
//	playfx( getfx( "crash_main_02" ), dummy.origin );
//	playfx( getfx( "crash_end_01" ), dummy.origin );
//	playfx( getfx( "crash_end_02" ), dummy.origin );
//	earthquake( .3, 2, level.player.origin, 1600 );
//	self delete();
//	
//}

littlebird_spinout()
{
	self SetMaxPitchRoll( 100, 200 );
	self setturningability( 1 );
	yawspeed = 1400;
	yawaccel = 200;
	targetyaw = undefined;

	while ( isdefined( self ) )
	{
		targetyaw = self.angles[ 1 ] - 300;
		self setyawspeed( yawspeed, yawaccel );
		self settargetyaw( targetyaw );
		wait 0.1;
	}
}

//littlebird_rider_death( heli )
//{
//	if ( ( self.script_startingposition == 0 ) || ( self.script_startingposition == 1 ) )
//		return;
//	tag = "tag_detach_right";
//	if ( ( self.script_startingposition == 2 ) || ( self.script_startingposition == 3 ) || ( self.script_startingposition == 4 ) )
//		tag = "tag_detach_left";
//	wait( randomfloatrange( .1, .8 ) );
//	//self unlink();
//	self.animname = "generic";
//	self setcontents( 0 );
//	self stopanimscripted();
//	self delaythread( randomfloatrange( .3, 1 ), ::play_sound_in_space, "generic_death_falling" );
//	heli anim_generic( self, "littlebird_rider_death", tag );
//	if( isdefined( self ) )
//		self kill();
//
//}

monument_heli_destroyed( monument_heli_owned )
{
	monument_heli_owned_destroyed = getent( "monument_heli_owned_destroyed", "targetname" );
	monument_heli_owned delete();
	monument_heli_owned_destroyed show();
	playfx( getfx( "large_vehicle_explosion" ), monument_heli_owned_destroyed.origin );
	monument_heli_owned_destroyed thread play_sound_in_space( "exp_tanker_vehicle" );
	monument_heli_owned_destroyeddummy = spawn( "script_origin", monument_heli_owned_destroyed.origin + ( 0, 0, 0 ) );
	monument_heli_owned_destroyeddummy.angles = monument_heli_owned_destroyed.angles;
	fx = spawnFx( getFx( "tanker_fire" ), monument_heli_owned_destroyeddummy.origin );
	triggerFx( fx );
	
	flag_wait( "player_entering_top_elevator_area" );
	fx delete();
	monument_heli_owned_destroyeddummy delete();
}

