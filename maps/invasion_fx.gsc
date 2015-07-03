#include common_scripts\utility;
#include maps\_utility;
#include maps\_debug;

main()
{
	level._effect[ "uav_explosion" ]						 		 = LoadFX( "explosions/vehicle_explosion_hummer_nodoors" );
	
	//walking through water
	level._effect[ "water_stop" ]						 			 = LoadFX( "misc/parabolic_water_stand" );
	level._effect[ "water_movement" ]					 			 = LoadFX( "misc/parabolic_water_movement" );

	level._effect[ "firelp_vhc_lrg_pm_farview" ]          			 = LoadFX( "fire/firelp_vhc_lrg_pm_farview" );
	level._effect[ "antiair_runner" ]				 				 = LoadFX( "misc/antiair_runner_cloudy" );
	level._effect[ "thin_black_smoke_L" ]			 				 = LoadFX( "smoke/thin_black_smoke_L" );
	level._effect[ "wood_explosion_1" ]			 					 = LoadFX( "explosions/wood_explosion_1" );

	level._effect[ "smokescreen" ]     								 = LoadFX( "smoke/smoke_grenade_low_invasion" );

	level._effect[ "ceiling_dust" ]						 			 = LoadFX( "dust/ceiling_dust_default" );

	//deleted by z for optimization
	//level._effect[ "horizon_explosion" ]				 			 = LoadFX( "explosions/default_explosion" );
	//level._effect[ "horizon_explosion_distant" ]			 		 = LoadFX( "explosions/default_explosion" );
	//level._effect[ "horizon_explosion_more_distant" ]				 = LoadFX( "explosions/default_explosion" );

	//intro 
	level._effect[ "humvee_explosion" ]						 		 = LoadFX( "explosions/small_vehicle_explosion" );
	level._effect[ "pillar_explosion_brick" ]				 		 = LoadFX( "explosions/pillar_explosion_brick_invasion" );

	// nates_restaurant prefab exploder id's 138-151 
	// just replace below with LoadFX( "misc/no_effect" ) to empty out the effect and do it yourself in createfx
	// we'll cleanup the entities when you're done making it pretty.
	level._effect[ "nates_roof_balcony_blaster" ]					 = LoadFX( "explosions/default_explosion" );
	level._effect[ "nates_roof_balcony_blaster_bricks" ]			 = LoadFX( "explosions/brick_chunk" );
	level._effect[ "nates_roof_balcony_blaster_sparks_b" ]			 = LoadFX( "explosions/sparks_b" );
	level._effect[ "nates_sign_explosion" ]				 			 = LoadFX( "explosions/window_explosion" );
	level._effect[ "nates_sign_explosion_sparks_runner" ]			 = LoadFX( "explosions/sparks_runner" );
	level._effect[ "nates_sign_explosion_flaming_awning" ]			 = LoadFX( "fire/firelp_small_pm" );
	level._effect[ "nates_roof_balcony_blaster" ]					 = LoadFX( "explosions/default_explosion" );
	level._effect[ "nates_roof_awning_flareup" ]					 = LoadFX( "explosions/fuel_med_explosion" );
	level._effect[ "nates_roof_pipe_fire" ]				 			 = LoadFX( "impacts/pipe_fire" );

	//this plays on super explosion
	level._effect[ "nates_super_explosion_smoke" ]					 = LoadFX( "smoke/thin_black_smoke_L" );
	level._effect[ "nates_super_explosion" ]						 = LoadFX( "explosions/nates_super_explosion" );
	level._effect[ "nates_sign_explode" ]						 	 = LoadFX( "explosions/nates_sign_explode" );

	level._effect[ "falling_debris_player" ]						 = LoadFX( "misc/falling_debris_player" );


	// fire fx
	level._effect[ "fire_tree" ]									 = LoadFX( "fire/fire_tree" );
	level._effect[ "fire_tree_slow" ]								 = LoadFX( "fire/fire_tree_slow" );
	level._effect[ "fire_falling_runner" ]							 = LoadFX( "fire/fire_falling_runner" );
	level._effect[ "fire_falling_localized_runner" ]				 = LoadFX( "fire/fire_falling_localized_runner" );
	level._effect[ "fire_tree_embers" ]								 = LoadFX( "fire/fire_tree_embers" );
	level._effect[ "fire_tree_distortion" ]							 = LoadFX( "fire/fire_tree_distortion" );

	level._effect[ "firelp_med_pm" ]								 = LoadFX( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm" ]								 = LoadFX( "fire/firelp_small_pm" );
	level._effect[ "firelp_small_pm_a" ]							 = LoadFX( "fire/firelp_small_pm_a" );
	
	level._effect[ "firelp_small_streak_pm1_h" ]					 = loadfx( "fire/firelp_small_streak_pm1_h" );

	//ambient	
	level._effect[ "bird_seagull_flock_large" ]						 = LoadFX( "misc/bird_seagull_flock_large" );
	level._effect[ "insect_trail_runner_icbm" ]						 = LoadFX( "misc/insect_trail_runner_icbm" );
	level._effect[ "leaves_fall_gentlewind" ]						 = LoadFX( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_ground_gentlewind" ]						 = LoadFX( "misc/leaves_ground_gentlewind" );
	level._effect[ "moth_runner" ]									 = LoadFX( "misc/moth_runner" );

	level._effect[ "ground_smoke_1200x1200" ]						 = LoadFX( "smoke/ground_smoke1200x1200" );
//	level._effect[ "battlefield_smokebank_S" ]						= LoadFX( "smoke/battlefield_smokebank_S" );
	level._effect[ "fog_ground_200" ]								 = LoadFX( "smoke/fog_ground_200" );
	level._effect[ "grn_smk_ling" ]									 = LoadFX( "smoke/grn_smk_ling" );
	level._effect[ "hallway_smoke_light" ]							 = LoadFX( "smoke/hallway_smoke_light" );

	level._effect[ "insects_light_invasion" ]						 = LoadFX( "misc/insects_light_invasion" );
	level._effect[ "heli_crash_fire" ]								 = LoadFX( "fire/heli_crash_fire" );

	level._effect[ "smoke_plume01" ]								 = LoadFX( "smoke/smoke_plume01" );
	level._effect[ "skybox_smoke" ]									 = LoadFX( "smoke/skybox_smoke" );

	treadfx_override();
	footstep_effects();

	//testing in different map that doesn't have soundaliases
	if ( GetDvar( "mapname" ) == "invasion" || GetDvar( "mapname" ) == "so_chopper_invasion" )
		maps\createfx\invasion_fx::main();

	//glass breaks when you shoot exploders 
	//glassarray = GetEntArray( "glass", "targetname" );
	//glassarray = array_combine( glassarray, GetEntArray( "glass", "script_noteworthy" ) );
	//array_thread( GetEntArray( "window_blaster", "script_noteworthy" ), ::window_blaster, glassarray );

	//deleting child exploders when 333 goes off.
	thread super_nates_exploder();

	thread glasstest();
	array_thread( GetEntArray( "traffic_light_blinky", "targetname" ), ::traffic_light_blinky );

	light = GetEnt( "tree_fire_light", "targetname" );
	if( isdefined( light ) )
		light SetLightIntensity( 0 );
		
	flag_init( "super_exploder_exploded" );
//	thread test_exploders();
	level.remote_missile_hide_stuff_func = ::hide_start_exploders;
	level.remote_missile_show_stuff_func = ::show_start_exploders;
//	thread debug_brushmodels();
}

hide_destructibles_for_uav()
{
	if( self.origin[1] > 0 ) // zero in Y direction is a convenient line to draw for this function. otherwise I would do istouching on a volume
		self hide();
}


glasstest()
{
	wait 10;

	if ( !getdvarint( "scr_glasstest" ) )
		return;

	PrintLn( "NOW" );
	array = GetGlassArray( "nates_glass_delete" );
	PrintLn( array.size );
	foreach ( glass in array )
	{
		origin = GetGlassOrigin( glass );
		thread sayhi( origin, glass );
		//dir = level.player.origin - origin;
		//DestroyGlass( glass, dir );
	}
}

sayhi( org, num )
{
	level waittillmatch( "glass_destroyed", num );
	PrintLn( num );
	for ( i = 0; i < 200; i++ )
	{
		Print3d( org, "." + num );
		wait .05;
	}
}

treadfx_override()
{
}

window_blaster( glassarray )
{
	Assert( IsDefined( self.radius ) );
	Assert( IsDefined( self.script_exploder ) || IsDefined( self.script_prefab_exploder ) );
	script_exploder = self.script_exploder;
	if ( !isdefined( script_exploder ) )
		script_exploder = self.script_prefab_exploder;
	glass_inradius = [];
	glass_inradius = get_array_of_closest( self.origin, glassarray, undefined, undefined, self.radius );
//	nearest_three_windows = get_array_of_closest( self.origin , glass_inradius , undefined , 3, self.radius ); 
//	foreach( window in nearest_three_windows )	
//		glass_inradius = array_remove( glass_inradius , window );     

	level waittill( "exploding_" + script_exploder );
	foreach ( glass in glass_inradius )
		glass notify( "damage", 150, undefined, undefined, undefined, "bullet" );
//	foreach( glass in nearest_three_windows )
//		glass notify ( "damage" ); 
}

super_nates_exploder()
{
	level waittill( "exploding_333" );
	for ( i = 139;i < 152;i++ )
	{
		stop_exploder( i );
	}
	for ( i = 139;i < 152;i++ )
		delete_exploder( i );

	//array_thread( GetEntArray( "nates_glass", "script_noteworthy" ), ::delete_glass );

	destroyGlass = GetGlassArray( "nates_glass_destroy" );
	deleteGlass = GetGlassArray( "nates_glass_delete" );

	foreach ( glass in destroyGlass )
		DestroyGlass( glass );
	foreach ( glass in deleteGlass )
		DeleteGlass( glass );
	
	for(i=0;i<6;i++)		
 		noself_delayCall( .1*i, ::physicsexplosionsphere, (245+randomint(55), -4730+randomint(55), 2594+randomint(55)), 3000, 2000, 6 ); 
	
	nates_lights = getentarray( "nates_lights", "targetname" );
	foreach ( light in nates_lights )
		light SetLightIntensity( 0 );
		
	flag_set( "super_exploder_exploded" );
}


delete_glass()
{
	GetEnt( self.target, "targetname" ) Delete();
	self Delete();
}


traffic_light_blinky()
{
	self endon( "death" );
	// use scrolling texture and save some resources here.
	while ( 1 )
	{
		self SetModel( "com_traffic_red_light_2x" );
		wait .75;
		self SetModel( "com_traffic_light_off2x" );
		wait .75;
	}
}

tree_fire_light()
{

	light = GetEnt( "tree_fire_light", "targetname" );
	if( !isdefined( light ) )
		return;
	light SetLightColor( ( 0.909804, 0.482353, 0.200000 ) );
	light SetLightIntensity( 3 );

	//make it waver intensity
//	light thread maps\_lights::burning_trash_fire();
	light thread maps\_lights::strobeLight( 2, 4, .5, "leaving_gas_station" );
//	light thread drawOriginForever();
	
	//these numbers less than half of maxmove, and maxturn values
	ang_range = ( 6, 6, 6);
	org_range = ( 44, 44, 0 );
	flare_offset = ( 50, 32, 64);
	dir = 1;

	original_origin = light.origin;
	original_angles = light.angles;
	

/*
	// wiggle it, just a little bit. careful not to violate the range!
	while ( 1 )
	{
		delay = RandomFloatRange( 0.4, 0.7 );
		if ( RandomInt( 50 ) > 25  )
			dir *= -1;
		//start down and move upish
		light moveto( original_origin + ( 0, 0, -64 ), .1 ) ;
		wait .1;
		light MoveTo( original_origin + ( dir * org_range ) + flare_offset, delay );
		if ( RandomInt( 50 ) > 25 )
			dir *= -1;
		light RotateTo( original_angles + ( dir * ang_range ), delay );
		wait delay-.05;
	}
*/

	random_x = 6;
	random_y = 6;
	random_z = -44;
	min_delay = .5;
	max_delay = .6;
	
	//original_origin = ( 2424, 943, 2748 ); //close to the tree center
	//light SetLightFovRange( <fov_outer>, <fov_inner> );

	while( !flag( "leaving_gas_station" ) )
	{
		delay = RandomFloatRange( min_delay, max_delay );
		amount = randomfloatrange( .1, 1 );
		
		x = ( random_x * ( randomfloatrange( .1, 1 ) ) );
		y = ( random_y * ( randomfloatrange( .1, 1 ) ) );
		z = ( random_z * ( randomfloatrange( .3, .7 ) ) );
		//new_angle = original_angles + ( amount * ang_range );
		//light RotateTo( new_angle, delay );
		//println( new_angle );
		new_position = original_origin + ( x, y, z );
		light moveto( new_position, delay ) ;
		wait delay;
	}
	light SetLightIntensity( 0 );
}

//tree_fire_light_new()
//{
//
//	light = GetEnt( "tree_fire_light", "targetname" );
//	if( !isdefined( light ) )
//		return;
//	light SetLightColor( ( 0.909804, 0.482353, 0.200000 ) );
//	light SetLightIntensity( 3 );
//
//	//make it waver intensity
//	light thread maps\_lights::burning_trash_fire();
////	light thread maps\_lights::strobeLight( 1, 3, .5 );
//	light thread drawOriginForever();
//	
//	//these numbers less than half of maxmove, and maxturn values
//	ang_range = ( 2, 2, 2);
//	org_range = ( 0, 64, 0 );
//	flare_offset = ( -64, 0, 128);
//	dir = 1;
//	
//	// 64 is maxmove
//	original_origin = light.origin+(64,0,-64); // has a range, we're going to move it from the bottom most of that range upward..
//	original_angles = light.angles;
//	
//	// wiggle it, just a little bit. careful not to violate the range!
//	while ( 1 )
//	{
//		delay = RandomFloatRange( 0.3, 0.5 );
//		dir = randomfloat(1);
//		if ( RandomInt( 50 ) > 25  )
//			dir *= -1;
//		//start down and move upish.  slight delay to reduce popping.
//		light moveto( original_origin , .5 ) ;
//		wait .5;
//		light MoveTo( original_origin + ( dir * org_range ) + flare_offset, delay );
//		if ( RandomInt( 50 ) > 25 )
//			dir *= -1;
////		light RotateTo( original_angles + ( dir * ang_range ), delay );
//		wait delay-.05;
//	}
//
//	random_x = 32;
//	random_y = 32;
//	random_z = -44;
//	min_delay = .5;
//	max_delay = .6;
//	
//	//original_origin = ( 2424, 943, 2748 ); //close to the tree center
//	//light SetLightFovRange( <fov_outer>, <fov_inner> );
//
//}


hide_start_exploders()
{
	thread hide_start_exploders_thread();
}

hide_start_exploders_thread()
{
	level endon ("show_start_exploders_thread");
	
	wait 1.05; // copy wait from _remotemissile for animation. +0.05
	hide_exploder_models("12");
	hide_exploder_models("13");
	hide_exploder_models("10");
	hide_exploder_models("11");
	hide_exploder_models("4");
	hide_exploder_models("2");
	hide_exploder_models("1");
	hide_exploder_models("3");
	hide_exploder_models("9990"); 
	hide_exploder_models("9991"); 
	hide_exploder_models("9992"); 
	array_call(getentarray( "window_poster", "targetname" ), ::hide );
	array_call(getentarray( "escape_door", "targetname" ), ::hide );
	
	if( flag( "super_exploder_exploded" ) )
		array_call(getentarray( "super_exploder_uav_hide", "script_noteworthy" ), ::hide );

	array_thread( getentarray( "destructible_vehicle", "targetname" ), ::hide_destructibles_for_uav );
	array_thread( getentarray( "destructible_toy", "targetname" ), ::hide_destructibles_for_uav );

}

show_start_exploders()
{
	thread show_start_exploders_thread();
}

show_start_exploders_thread()
{
	level notify ("show_start_exploders_thread");
	
	show_exploder_models("12");
	show_exploder_models("13");
	show_exploder_models("10");
	show_exploder_models("11");
	show_exploder_models("4"); 
	show_exploder_models("2"); 
	show_exploder_models("1"); 
	show_exploder_models("3"); 
	show_exploder_models("9990"); 
	show_exploder_models("9991"); 
	show_exploder_models("9992"); 
	array_call(getentarray( "window_poster", "targetname" ), ::show );
	array_call(getentarray( "escape_door", "targetname" ), ::show );
	
	if( flag( "super_exploder_exploded" ) )
		array_call(getentarray( "super_exploder_uav_hide", "script_noteworthy" ), ::show );
		
	array_thread( getentarray( "destructible_vehicle", "targetname" ), ::show_destructibles_for_uav );
	array_thread( getentarray( "destructible_toy", "targetname" ), ::show_destructibles_for_uav );

}

show_destructibles_for_uav()
{
	if( self.origin[1] > 0 ) // zero in Y direction is a convenient line to draw for this function. otherwise I would do istouching on a volume
		self show();
}

test_exploders()
{
	wait .5;
	exploder("12");
	exploder("13");
	exploder("10");
	exploder("11");
	exploder("4"); 
	exploder("2"); 
	exploder("1"); 
	exploder("3"); 
	exploder("9990"); 
	exploder("9991"); 
	exploder("9992"); 
}

debug_brushmodels()
{
	waittillframeend;
	waittillframeend;
	waittillframeend;
	
	while(1)
	{
		bmodels = getentarray("script_brushmodel","code_classname");
		foreach( model in bmodels )
			line( level.player.origin, model getcentroid() );
		wait .05;
	}
}

footstep_effects()
{

	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "water",	loadfx ( "impacts/footstep_water" ) );


	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"concrete",	loadfx ( "impacts/bodyfall_default_small_runner_concrete" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"rock",		loadfx ( "impacts/bodyfall_default_small_runner_concrete" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"asphalt",	loadfx ( "impacts/bodyfall_default_small_runner_concrete" ), "bodyfall_", "_small" );
	
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"concrete",	loadfx ( "impacts/bodyfall_default_large_runner_concrete" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"rock",		loadfx ( "impacts/bodyfall_default_large_runner_concrete" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"asphalt",	loadfx ( "impacts/bodyfall_default_large_runner_concrete" ), "bodyfall_", "_large" );
	
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"rock",		loadfx ( "impacts/footstep_dust" ) );
	
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"rock",		loadfx ( "impacts/footstep_dust" ) );
	
}
