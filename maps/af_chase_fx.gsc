#include common_scripts\utility;
#include maps\_utility;
#include maps\_sandstorm;

main()
{
	if ( !isdefined( level.script ) )
		level.script = ToLower( GetDvar( "mapname" ) );

	PreCacheModel( "fog_blackout" );

	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/helicopter_explosion_secondary_small", 	"tag_engine_left", 	undefined, 	undefined, 			undefined, 		undefined, 		0.0, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/helicopter_explosion_secondary_small", 	"tag_engine_right", 	undefined, 	undefined, 			undefined, 		undefined, 		1.4, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/helicopter_explosion_secondary_small", 	"tag_engine_right", 	undefined, 	undefined, 			undefined, 		undefined, 		3.9, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/helicopter_explosion_secondary_small", 	"tail_rotor_jnt", 	undefined, 	undefined, 			undefined, 		undefined, 		5.34, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/helicopter_explosion_secondary_small", 	"tag_engine_left", 	undefined, 	undefined, 			undefined, 		undefined, 		6.0, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "fire/fire_smoke_trail_L", 							"tag_engine_left", 	undefined, 	true, 				0.05, 			true, 			0.2, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/helicopter_explosion_secondary_small", 	"tag_engine_right", 	undefined, 	undefined, 			undefined, 		undefined, 		2.5, 		true );
	maps\_vehicle::build_deathfx_override( "pavelow", "vehicle_pavelow", "explosions/aerial_explosion_large", 						undefined, 		undefined, 			undefined, 			undefined, 		undefined, 		 - 1, 		undefined, 	"stop_crash_loop_sound" );
	
	level._effect[ "explosions/large_vehicle_explosion" ] = loadfx( "explosions/large_vehicle_explosion" );

	//walking through water
	level._effect[ "water_stop" ]				 = LoadFX( "misc/parabolic_water_stand" );
	level._effect[ "water_movement" ]			 = LoadFX( "misc/parabolic_water_movement" );

	level._effect[ "rocket_hits_heli" ]			 = LoadFX( "explosions/grenadeExp_metal" );

/*-----------------------------------------------------------------------------------------------------*/

	//Zodiac Wake
	level._effect[ "zodiac_wake_geotrail" ]		 = LoadFX( "treadfx/zodiac_wake_geotrail_af_chase" );

	// only ever see the front of the players boat plays on tag_origin	
	level._effect[ "zodiac_leftground" ]		 = LoadFX( "misc/watersplash_large" );

	//Zodiac bigbump
	level._effect[ "player_zodiac_bumpbig" ]	 = LoadFX( "misc/watersplash_large" );
	level._effect[ "zodiac_bumpbig" ]			 = LoadFX( "misc/watersplash_large" );
	level._effect_tag[ "zodiac_bumpbig" ] 		 = "tag_guy2";// pushing this farther forward so the player sees it better.

	//Zodiac bump
	level._effect[ "player_zodiac_bump" ] 		 = LoadFX( "impacts/large_waterhit" );
	level._effect[ "zodiac_bump" ] 				 = LoadFX( "impacts/large_waterhit" );

	//zodiac collision
	level._effect[ "zodiac_collision" ] 		 = LoadFX( "misc/watersplash_large" );
	level._effect_tag[ "zodiac_collision" ] 	 = "TAG_DEATH_FX";// pushing this farther forward so the player sees it better.

/*-----------------------------------------------------------------------------------------------------*/

	//Zodiac Bounce Small Left
	level._effect[ "zodiac_bounce_small_left" ]  		 = LoadFX( "water/zodiac_splash_bounce_small" );
	level._effect_tag[ "zodiac_bounce_small_left" ] 	 = "TAG_FX_LF";

	//Zodiac Bounce Small Right
	level._effect[ "zodiac_bounce_small_right" ]  		 = LoadFX( "water/zodiac_splash_bounce_small" );
	level._effect_tag[ "zodiac_bounce_small_right" ] 	 = "TAG_FX_RF";

	//Zodiac Bounce Large Left
	level._effect[ "zodiac_bounce_large_left" ]  		 = LoadFX( "water/zodiac_splash_bounce_large" );
	level._effect_tag[ "zodiac_bounce_large_left" ] 	 = "TAG_FX_LF";

	//Zodiac Bounce Large Right
	level._effect[ "zodiac_bounce_large_right" ]  		 = LoadFX( "water/zodiac_splash_bounce_large" );
	level._effect_tag[ "zodiac_bounce_large_right" ] 	 = "TAG_FX_RF";

/*-----------------------------------------------------------------------------------------------------*/

	//Zodiac Turn Hard Left /Hit left
	level._effect[ "zodiac_sway_left" ] 		 = LoadFX( "water/zodiac_splash_turn_hard" );
	level._effect_tag[ "zodiac_sway_left" ] 	 = "TAG_FX_LF";

	//Zodiac Turn Hard Right /Hit right
	level._effect[ "zodiac_sway_right" ] 		 = LoadFX( "water/zodiac_splash_turn_hard" );
	level._effect_tag[ "zodiac_sway_right" ] 	 = "TAG_FX_RF";

	//Zodiac Turn Light Left 
	level._effect[ "zodiac_sway_left_light" ] 		 = LoadFX( "water/zodiac_splash_turn_light" );
	level._effect_tag[ "zodiac_sway_left_light" ] 	 = "TAG_FX_LF";

	//Zodiac Turn Light Right 
	level._effect[ "zodiac_sway_right_light" ] 		 = LoadFX( "water/zodiac_splash_turn_light" );
	level._effect_tag[ "zodiac_sway_right_light" ] 	 = "TAG_FX_RF";

/*-----------------------------------------------------------------------------------------------------*/

	//sound
	level.zodiac_fx_sound[ "zodiac_bump" ]		 = "water_boat_splash_small";
	level.zodiac_fx_sound[ "zodiac_bumpbig" ]	 = "water_boat_splash";

	level.zodiac_fx_sound[ "player_zodiac_bump" ]		 = "water_boat_splash_small_plr";
	level.zodiac_fx_sound[ "player_zodiac_bumpbig" ]	 = "water_boat_splash_plr";

	//two bumps small and big. change them at points in the level to allow more or less visibility. 
	level.water_sheating_time[ "bump_big_start" ] = 2;
	level.water_sheating_time[ "bump_small_start" ] = 1;

	// sheeting time smaller just so action can be more visible.  I'm just trying this I suppose
	level.water_sheating_time[ "bump_big_after_rapids" ] = 4;
	level.water_sheating_time[ "bump_small_after_rapids" ] = 2;

	// water sheating time when the player dies. meant to be really long to cover up some nasty.
	level.water_sheating_time[ "bump_big_player_dies" ] = 7;
	level.water_sheating_time[ "bump_small_player_dies" ] = 3;


	//player falls over waterfall, this shoots up just as they go over.
	level._effect[ "splash_over_waterfall"		 ] = LoadFX( "misc/watersplash_large" );

	//player falls over waterfall, this shoots up when they hit below
	level._effect[ "player_hits_water_after_waterfall"		 ] = LoadFX( "misc/watersplash_large" );


	level._effect[ "powerline_runner_cheap" ] 						 = loadfx( "explosions/powerline_runner_cheap" );
	level._effect[ "firelp_small_pm_a_nolight" ] 					 = LoadFX( "fire/firelp_small_pm_a_nolight" );
	level._effect[ "firelp_large_pm_nolight" ] 						 = LoadFX( "fire/firelp_large_pm_nolight" );
	level._effect[ "heli_crash_fire" ]								 = LoadFX( "fire/pavelow_crash_large" );
	level._effect[ "heli_crash_fire_short_smoke" ]					 = LoadFX( "fire/pavelow_crash_large_short_smoke" );
	level._effect[ "no_effect" ]					 				 = LoadFX( "misc/no_effect" );
	level._effect[ "player_stabbed" ]								 = LoadFX( "impacts/player_stabbed" );
	level._effect[ "player_knife_wound" ]							 = LoadFX( "impacts/player_knife_wound" );
	level._effect[ "player_knife_pull_1" ]							 = LoadFX( "impacts/player_knife_pull_1" );
	level._effect[ "player_knife_pull_2" ]							 = LoadFX( "impacts/player_knife_pull_2" );
	level._effect[ "blood_sheperd_eye" ]							 = LoadFX( "misc/blood_sheperd_eye" );
	level._effect[ "blood_sheperd_eye_geotrail" ]					 = LoadFX( "misc/blood_sheperd_eye_geotrail" );
	level._effect[ "revolver_bullets" ]								 = LoadFX( "shellejects/revolver_af_chase" );
	level._effect[ "crawl_dust_sandstorm_runner" ]				 	 = LoadFX( "impacts/crawl_dust_sandstorm_runner" );
	level._effect[ "footstep_dust_sandstorm_runner" ]				 = LoadFX( "impacts/footstep_dust_sandstorm_runner" );
	level._effect[ "footstep_dust_sandstorm_small_runner" ]			 = LoadFX( "impacts/footstep_dust_sandstorm_small_runner" );
	level._effect[ "bodyfall_dust_sandstorm_large_runner" ]			 = LoadFX( "impacts/bodyfall_dust_sandstorm_large_runner" );

	
	// need something cool here.
	level._effect[ "body_falls_from_ropes_splash"			 ] = LoadFX( "impacts/large_waterhit" );

	level._effect[ "sand_storm_distant" ]				 	 = LoadFX( "weather/sand_storm_distant" );
	level._effect[ "sand_storm_canyon_light" ]				 = LoadFX( "weather/sand_storm_canyon_light" );
	level._effect[ "sand_storm_player" ]					 = LoadFX( "weather/sand_storm_player" );
	level._effect[ "sand_storm_intro" ]						 = LoadFX( "weather/sand_storm_intro" );
	level._effect[ "sand_storm_light" ]						 = LoadFX( "weather/sand_storm_light" );
	level._effect[ "sand_storm_distant_oriented" ] 			 = LoadFX( "weather/sand_storm_distant_oriented" );
	level._effect[ "sand_spray_detail_runner0x400" ]	 	 = LoadFX( "dust/sand_spray_detail_runner_0x400" );
	level._effect[ "sand_spray_detail_runner400x400" ]	 	 = LoadFX( "dust/sand_spray_detail_afchase_runner_400x400" );
	level._effect[ "sand_spray_detail_oriented_runner" ]	 = LoadFX( "dust/sand_spray_detail_oriented_runner" );
	level._effect[ "sand_spray_detail_oriented_runner" ]	 = LoadFX( "dust/sand_spray_detail_oriented_runner" );
	level._effect[ "sand_spray_cliff_oriented_runner" ] 	 = LoadFX( "dust/sand_spray_cliff_oriented_runner" );

	level._effect[ "dust_wind_fast" ]						 = LoadFX( "dust/dust_wind_fast_afcaves" );
	level._effect[ "dust_wind_canyon" ]						 = LoadFX( "dust/dust_wind_canyon_far" );
	level._effect[ "steam_vent_large_wind" ]				 = LoadFX( "smoke/steam_vent_large_wind" );

	level._effect[ "ground_fog_afchase" ]	 				 = LoadFX( "smoke/ground_fog_afchase" );
	level._effect[ "light_shaft_ground_dust_small" ]	 	 = LoadFX( "dust/light_shaft_ground_dust_small" );
	level._effect[ "light_shaft_ground_dust_large" ]	 	 = LoadFX( "dust/light_shaft_ground_dust_large" );
	level._effect[ "light_shaft_ground_dust_small_yel" ]	 = LoadFX( "dust/light_shaft_ground_dust_small_yel" );
	level._effect[ "light_shaft_ground_dust_large_yel" ]	 = LoadFX( "dust/light_shaft_ground_dust_large_yel" );
	level._effect[ "light_shaft_motes_afchase" ]			 = LoadFX( "dust/light_shaft_motes_afchase" );
	
	if ( level.script == "ending" )
		level._effect[ "light_glow_white_bulb" ]			 	 = LoadFX( "dust/light_shaft_motes_afchase" );
	else
		level._effect[ "light_glow_white_bulb" ]			 	 = LoadFX( "misc/light_glow_white_bulb" );

	level._effect[ "splash_underwater_afchase" ]	 		 = loadfx( "water/splash_underwater_afchase" );
	level._effect[ "rapids_splash_0x1000" ] 				 = LoadFX( "water/rapids_splash_0x1000" );
	level._effect[ "rapids_splash_1000x1000" ] 				 = LoadFX( "water/rapids_splash_1000x1000" );
	level._effect[ "rapids_splash_large" ] 					 = LoadFX( "water/rapids_splash_large" );
	level._effect[ "rapids_splash_large_dark" ] 			 = LoadFX( "water/rapids_splash_large_dark" );
	level._effect[ "rapids_splash_large_far" ] 				 = LoadFX( "water/rapids_splash_large_far" );
	level._effect[ "waterfall_afchase" ]	 				 = LoadFX( "water/waterfall_afchase" );
	level._effect[ "waterfall_base_afchase" ]	 			 = LoadFX( "water/waterfall_base_afchase" );

	level._effect[ "heli_blinds_player" ]					 = LoadFX( "weather/sand_storm_player_blind" );
	level._effect[ "shepherd_anaconda" ]					 = LoadFX( "muzzleflashes/desert_eagle_flash_wv");
	// this overrides the blizzard snow fx.	
	
	//Zodiac Bounce Small Left
	level._effect[ "pavelow_minigunner_splash_add" ]  		 = LoadFX( "water/zodiac_splash_bounce_small" );

	level._effect[ "bloodpool_ending" ]	 	 = Loadfx( "impacts/deathfx_bloodpool_ending" );


	if ( GetDvarInt( "r_reflectionProbeGenerate" ) )
		return;

	//fake blizzard in createfx
	//thread createfx_stuff();
	treadfx_override();
	maps\createfx\af_chase_fx::main();

}

createfx_stuff()
{
	if ( GetDvar( "createfx" ) != "" )
	{
		waittillframeend; // let _load run
		level.sandstorm_time = spawnstruct();
		level.sandstorm_time.min = 0.3;
		level.sandstorm_time.max = 0.5;

		thread sand_storm_rolls_in();
		//thread maps\af_chase_fx::sand_storm_effect();
		thread maps\af_chase_fx::sandstorm_fog_management();
	}
}


sand_storm_rolls_in()
{
	fog_set_changes( "afch_fog_dunes", 4 );// fog transitions over 20 seconds

	// double the sandstorm
	//thread sand_storm_effect();
	thread sand_storm_effect();
	
	flag_set( "blinder_effect" );
	block_out_the_sky();
	sunlight_change();
	flag_clear( "blinder_effect" );
}

sunlight_change()
{
	sunvect = ( 1.441176, 1.2411765, 0.9705885 );
	sunvect *= .53;
	level.sand_storm_sun = sunvect;
	SetSunLight( sunvect[ 0 ], sunvect[ 1 ], sunvect[ 2 ] );
}

sunlight_restore( fTime )
{
	sunvect = ( 1.441176, 1.2411765, 0.9705885 );
	thread sun_light_fade( level.sand_storm_sun, sunvect, fTime );
//	SetSunLight( sunvect[ 0 ], sunvect[ 1 ], sunvect[ 2 ] );
}

block_out_the_sky()
{
	fogent = Spawn( "script_model", level.player GetEye() );
	fogent SetModel( "fog_blackout" );
	fogent LinkTo( level.player );
	level.fogent = fogent;
	flag_set( "sandstorm_fully_masked" ); // lets script know effects are good to go.
}


sand_storm_effect()
{
	level endon ( "stop_sandstorm_effect" );
	player = GetEntArray( "player", "classname" )[ 0 ];
	for ( ;; )
	{
		timer = randomfloatrange( level.sandstorm_time.min, level.sandstorm_time.max );
		timer *= 0.5;
		
		if ( timer < 0.5 )
			timer = 0.5;
		wait( timer );

		PlayFX( level._effect[ "sand_storm_player" ], player.origin + ( 0, 0, 100 ) );
	}
}

sandstorm_fx_increase()
{
	level.sandstorm_time.min = 0.3;
	level.sandstorm_time.max = 0.5;
}

stop_sandstorm_effect()
{
	// get the fx near price so we can turn them off later
	near_fx = [];
	foreach ( ent in level.createFXent )
	{
		if ( distance( ent.v[ "origin" ], level.price.origin ) < 400 )
		{
			ent.origin = ent.v[ "origin" ]; // so we can use normal sorts on distance
			near_fx[ near_fx.size ] = ent;
		}
	}
	
	// order them based on price's origin
	near_fx = SortByDistance( near_fx, level.price.origin );
	
	for ( ;; )
	{
	
		if ( level.sandstorm_time.min >= 1.5 && near_fx.size )
		{
			foreach( fx in near_fx )
				fx pauseeffect();
			
			near_fx = [];
		}

		if ( level.sandstorm_time.min >= 2.0 )
			break;
			
		level.sandstorm_time.min += 0.1;
		level.sandstorm_time.max += 0.15;
		wait( 0.5 );
	}
	
	level notify ( "stop_sandstorm_effect" );
}

sandstorm_fog_management()
{
	level endon ( "stop_sandstorm_fog" );

	struct = getstruct( "heli_fog_struct", "targetname" );
	targ_pos = getstruct( struct.target, "targetname" );
	targ = spawn( "script_origin", (0,0,0) );
	targ.origin = targ_pos.origin;

	offset_dist = Distance( targ.origin, struct.origin );

	ent = maps\_utility::create_fog( "afch_fog_dunes_dynamic" );
	ent.startDist = 0;
	ent.halfwayDist = 8340;
	ent.red = 0.661137;
	ent.Green = 0.554261;
	ent.Blue = 0.454014;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	
	min_fog_dist = 500;
	max_fog_dist = 200;
	fog_range = abs( min_fog_dist - max_fog_dist );

	level.sandstorm_min_dist = 500;
	shepherd_stumble = false;
	for ( ;; )
	{
		player_dist = Distance( level.player.origin, targ.origin );
		player_dist -= offset_dist;
		player_dist *= 0.25;
		
		if ( flag( "fog_out_stumble_shepherd" ) && isalive( level.shepherd_stumble ) )
		{
			if ( !shepherd_stumble )
			{
				shepherd_stumble = true;
			}
			
			// crudely move the ent to shepherd's origin
			dif = 0.80;
			targ.origin = targ.origin * dif + level.shepherd_stumble.origin * ( 1 - dif );
			
			new_dist = distance( level.player.origin, targ.origin );
			new_dist *= 0.75;
			
			dif = 0.9;
			level.sandstorm_min_dist = level.sandstorm_min_dist * dif + new_dist * ( 1 - dif );

			// bring in more fog as you get close to him
			level.sandstorm_min_dist = clamp( level.sandstorm_min_dist, 50, 500 );

			// 1 - ( ( min_black - max_black ) / black_range ) = 1 - ( ( chase_dist - max_black ) / black_range );
			//alpha = 1 - ( ( chase_dist - max_black ) / black_range );
			//alpha = clamp( alpha, 0, 1 );
		}
		else
		{
			if ( level.sandstorm_min_dist < 500 )
			{
				level.sandstorm_min_dist += 25;
				level.sandstorm_min_dist = clamp( level.sandstorm_min_dist, 0, 500 );
			}
		}

		if ( player_dist < level.sandstorm_min_dist )
			player_dist = level.sandstorm_min_dist;
		
		ent.startDist = player_dist * 0.75;
		ent.halfwayDist = player_dist;
		level.fog_transition_ent.fogset = "";
		thread fog_set_changes( "afch_fog_dunes_dynamic", 0.2 );
		wait( 0.2 );

		angles = VectorToAngles( struct.origin - level.player.origin );
		forward = AnglesToForward( angles );
//		Line( level.player.origin, level.player.origin + forward * player_dist, (1,0,0), 1, 0, 4 );
	}
}

blood_pulse()
{
	fx = getfx( "player_knife_wound" );
	knife = maps\af_chase_knife_fight_code::get_knife();
	PlayFXOnTag( fx, knife, "TAG_FX" );
}

play_underwater_fx()
{
	//play bubble fx as the player hits the water.
	PlayFX( getfx( "splash_underwater_afchase" ), ( 25590.3, 26824, -10008.9 ) );
}

treadfx_override()
{

	maps\_treadfx::setvehiclefx( "pavelow", "brick", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "bark", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "carpet", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "cloth", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "concrete", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "dirt", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "flesh", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "foliage", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "glass", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "grass", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "gravel", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "ice", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "metal", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "mud", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "paper", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "plaster", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "rock", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "sand", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "snow", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "water", "treadfx/heli_water" );
 	maps\_treadfx::setvehiclefx( "pavelow", "wood", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "asphalt", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "ceramic", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "plastic", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "rubber", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "cushion", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "fruit", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "painted metal", "treadfx/heli_sand_large" );
 	maps\_treadfx::setvehiclefx( "pavelow", "default", "treadfx/heli_sand_large" );
	maps\_treadfx::setvehiclefx( "pavelow", "none", "treadfx/heli_sand_large" );

	maps\_treadfx::setvehiclefx( "littlebird", "brick", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "bark", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "carpet", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "cloth", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "concrete", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "dirt", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "flesh", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "foliage", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "glass", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "grass", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "gravel", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "ice", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "metal", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "mud", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "paper", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "plaster", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "rock", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "sand", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "snow", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "water", "treadfx/heli_water" );
 	maps\_treadfx::setvehiclefx( "littlebird", "wood", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "asphalt", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "ceramic", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "plastic", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "rubber", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "cushion", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "fruit", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "painted metal", "treadfx/heli_sand_default" );
 	maps\_treadfx::setvehiclefx( "littlebird", "default", "treadfx/heli_sand_default" );
	maps\_treadfx::setvehiclefx( "littlebird", "none", "treadfx/heli_sand_default" );

}
