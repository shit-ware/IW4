#include common_scripts\utility;
#include maps\_utility;

main()
{
	setup_util_fx();
	
	level._effect[ "technical_gate_shatter" ] = LoadFX( "explosions/wood_explosion_1" );
	
	level._effect[ "bird_takeoff_pm" ] = LoadFX( "misc/bird_takeoff_pm" );
	
	level._effect[ "headshot" ] = LoadFX( "impacts/flesh_hit_head_fatal_exit" );
	level._effect[ "bodyshot" ]	= LoadFX( "impacts/flesh_hit" );
	
	// ambient level fx
	level._effect[ "insects_carcass_runner" ] 	= LoadFX( "misc/insects_carcass_runner" );
	level._effect[ "firelp_med_pm" ] 			= LoadFX( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm_a" ] 		= LoadFX( "fire/firelp_small_pm_a" );
	level._effect[ "dust_wind_fast" ] 			= LoadFX( "dust/dust_wind_fast" );
	level._effect[ "dust_wind_fast_light" ] 	= LoadFX( "dust/dust_wind_fast_light" );
	level._effect[ "trash_spiral_runner" ] 		= LoadFX( "misc/trash_spiral_runner" );
	level._effect[ "trash_spiral_runner_far" ] 	= LoadFX( "misc/trash_spiral_runner_far" );
	level._effect[ "leaves_fall_gentlewind" ] 	= LoadFX( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_ground_gentlewind" ] = LoadFX( "misc/leaves_ground_gentlewind" );
	level._effect[ "hallway_smoke_light" ] 		= LoadFX( "smoke/hallway_smoke_light" );
	level._effect[ "battlefield_smokebank_S" ] 	= LoadFX( "smoke/battlefield_smokebank_S" );
	level._effect[ "room_smoke_200" ] 			= LoadFX( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_200_fast_far" ] 	= LoadFX( "smoke/room_smoke_200_fast_far" );
	level._effect[ "insect_trail_runner_icbm" ] = LoadFX( "misc/insect_trail_runner_icbm" );
	level._effect[ "moth_runner" ] 				= LoadFX( "misc/moth_runner" );
	level._effect[ "insects_light_invasion" ] 	= LoadFX( "misc/insects_light_invasion" );
	level._effect[ "chimney_small" ] 			= LoadFX( "smoke/chimney_small" );
	level._effect[ "chimney_large" ] 			= LoadFX( "smoke/chimney_large" );
	level._effect[ "roof_slide" ] 				= LoadFX( "misc/roof_slide" );

	// airliner exhaust
	level._effect[ "airliner_exhaust" ]			= LoadFX( "fire/jet_engine_anatov_constant" );
	level._effect[ "airliner_wingtip_left" ]	= LoadFX( "misc/aircraft_light_wingtip_green" );
	level._effect[ "airliner_wingtip_right" ]	= LoadFX( "misc/aircraft_light_wingtip_red" );
	level._effect[ "airliner_tail" ]			= LoadFX( "misc/aircraft_light_white_blink" );
	level._effect[ "airliner_belly" ]			= LoadFX( "misc/aircraft_light_red_blink" );
	
	// fake chopper shellejects
	level._effect[ "hind_fake_shelleject" ] = LoadFX( "shellejects/20mm_cargoship" );
	
	// fake rotor wash dust
	level._effect[ "hind_fake_rotorwash_dust" ] = LoadFX( "treadfx/heli_dust_icbm" );
	
	// chopper flares
	level.flare_fx[ "pavelow" ] = LoadFX( "misc/flares_cobra" );
	
	// fake explosions for the chopper owning
	level._effect[ "hind_fake_explosion_1" ] = LoadFX( "explosions/grenadeexp_metal" );
	level._effect[ "hind_fake_explosion_2" ] = LoadFX( "explosions/circuit_breaker" );
	level._effect[ "hind_fake_explosion_3" ] = LoadFX( "explosions/pillar_explosion_brick_invasion" );
	
	// fx for player falling
	level._effect[ "playerfall_impact" ] = LoadFX( "impacts/bodyfall_dust_large" );
	level._effect[ "playerfall_residual" ] = LoadFX( "explosions/breach_room_residual" );
	
	// fake squibs around player
	level._effect[ "squib_plaster" ] = LoadFX( "impacts/large_plaster" );
	
	
	level._effect[ "flashlight" ] = LoadFX( "misc/gulag_cafe_spotlight" );
	
	levelstart_fx_setup();
	treadfx_override();
	footstep_effects();
}

setup_util_fx()
{
	// for bloody_death
	level._effect[ "flesh_hit" ] = LoadFX( "impacts/flesh_hit_body_fatal_exit" );
}

bird_startle_trigs()
{
	trigs = GetEntArray( "trig_bird_startle", "targetname" );
	array_thread( trigs, ::bird_startle_trig_think );
}

bird_startle_trig_think()
{
	ASSERT( IsDefined( self.script_exploder ), "Bird startle trigger at origin " + self.origin + " doesn't have script_exploder set." );
	exploderName = self.script_exploder;
	
	self waittill( "trigger" );
	level thread exploder( exploderName );
	
	self Delete();
}

levelstart_fx_setup()
{
	lights = GetEntArray( "flickerlight_fire", "script_noteworthy" );
	array_thread( lights, ::flickerlight_fire );
}

flickerlight_fire()
{
	wait( RandomFloatRange( .05, .5 ) );
	
	intensity = self GetLightIntensity();
	while( 1 )
	{
		self SetLightIntensity( intensity * RandomFloatRange( 1.2, 2.2 ) );
		wait( RandomFloatRange( .05, 1 ) );
	}
}

footstep_effects()
{

	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "mud",		loadfx ( "impacts/footstep_mud" ) );
	
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "asphalt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "mud",			loadfx ( "impacts/footstep_mud" ) );
	  
	//Other notetrack fx
	/*
	setNotetrackEffect( <notetrack>, <tag>, <surface>, <loadfx>, <sound_prefix>, <sound_suffix> )
		<notetrack>: name of the notetrack to do the fx/sound on
		<tag>: name of the tag on the AI to use when playing fx
		<surface>: the fx will only play when the AI is on this surface. Specify "all" to make it work for all surfaces.
		<loadfx>: load the fx to play here
		<sound_prefix>: when this notetrack hits a sound can be played. This is the prefix of the sound alias to play ( gets followed by surface type )
		<sound_suffix>: suffix of sound alias to play, follows the surface type. Example: prefix of "bodyfall_" and suffix of "_large" will play sound alias "bodyfall_dirt_large" when the notetrack happens on dirt.
	*/
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"dirt",		loadfx ( "impacts/bodyfall_dust_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"concrete",	loadfx ( "impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"asphalt",	loadfx ( "impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"rock",		loadfx ( "impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"dirt",		loadfx ( "impacts/bodyfall_dust_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"concrete",	loadfx ( "impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"asphalt",	loadfx ( "impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"rock",		loadfx ( "impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"mud",		loadfx ( "impacts/bodyfall_mud_large_runner" ), "bodyfall_", "_large" );
	
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"mud",		loadfx ( "impacts/footstep_mud" ) );
	
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"mud",		loadfx ( "impacts/footstep_mud" ) );
	
}

treadfx_override()
{
	driving_tread_fx = "treadfx/tread_dust_boneyard";
	
	maps\_treadfx::setvehiclefx( "technical", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "technical", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "technical", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "technical", "none", driving_tread_fx );
	
	maps\_treadfx::setvehiclefx( "technical_physics", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "technical_physics", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "technical_physics", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "technical_physics", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "technical_physics", "none", driving_tread_fx );
	
	
	flying_tread_fx = "treadfx/heli_dust_large";
	
	maps\_treadfx::setvehiclefx( "pavelow", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "pavelow", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "pavelow", "none", flying_tread_fx );
}