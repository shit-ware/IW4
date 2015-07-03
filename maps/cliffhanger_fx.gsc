#include maps\_utility;
#include maps\_blizzard;

main()
{
	level thread precacheFX();
	level thread treadfx_override();
	
	maps\createfx\cliffhanger_fx::main();
	maps\_blizzard::blizzard_main();
//	level thread playerEffect();

	//thread test_transition();	
	
	//Set default Far Cull so we can change it during the blizzard
	//SetCullDist( 120000 );
	
	//blizzard
	//SetCullDist( 3000 );
}

playerEffect()
{
	player = getentarray( "player", "classname" )[ 0 ];
	for ( ;; )
	{
		playfx( level._effect[ "snow_spray_detail_runner400x400" ], player.origin + ( 0, 0, 0 ), player.origin + ( 0, 100, 100 ) );
		wait( .3 );
	}
}

precacheFX()
{

	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "snow",			loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setFootstepEffect( "ice",			loadfx ( "impacts/footstep_ice" ) );
	animscripts\utility::setFootstepEffect( "slush",		loadfx ( "impacts/footstep_snow_slush" ) );
	animscripts\utility::setFootstepEffect( "mud",			loadfx ( "impacts/footstep_snow_slush" ) );
	
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "snow",	loadfx ( "impacts/footstep_snow_small" ) );
	animscripts\utility::setFootstepEffectSmall( "ice",		loadfx ( "impacts/footstep_ice" ) );
	animscripts\utility::setFootstepEffectSmall( "slush",	loadfx ( "impacts/footstep_snow_slush_small" ) );
	animscripts\utility::setFootstepEffectSmall( "mud",		loadfx ( "impacts/footstep_snow_slush_small" ) );
	
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
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"snow",		loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"ice",		loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"slush",	loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"mud",		loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"snow",		loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"ice",		loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"slush",	loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"mud",		loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"snow",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"ice",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"slush",	loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"mud",		loadfx ( "impacts/footstep_snow" ) );
	
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"snow",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"ice",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"slush",	loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"mud",		loadfx ( "impacts/footstep_snow" ) );
	
	
	
	
	//Player Footstep fx
	level._effect[ "footstep_snow_small" ]					= loadfx( "impacts/footstep_snow_small" );
	level._effect[ "footstep_snow" ]						= loadfx( "impacts/footstep_snow" );

	//Price Climbing FX (more in _climb.gsc)
	level._effect[ "snow_price_grab" ]						= loadfx( "snow/snow_price_grab" );
	level._effect[ "snow_jump" ]							= loadfx( "snow/snow_jump" );
	level._effect[ "snow_dropping_debris" ]					= loadfx( "snow/snow_dropping_debris" );

	//Price SLiding fx
	level._effect[ "price_landing" ]						= loadfx( "snow/snow_price_landing" );
	level._effect[ "price_sliding" ]						= loadfx( "snow/snow_price_sliding" );

	//Snowmobile FX
	level._effect[ "tread_snow_snowmobile_skidout" ]		= loadfx( "treadfx/tread_snow_snowmobile_skidout" );

	//Mig Landing FX
	level._effect[ "mig_landing_snow" ]						= loadfx( "treadfx/mig_landing_snow_runner" );
	level._effect[ "mig_landing_trail_snow" ]				= loadfx( "smoke/mig29_landing_trail_snow" );

	//Ambient fx
	level._effect[ "snow_blowoff_ledge" ]		 			= loadfx( "snow/snow_blowoff_ledge" );
	level._effect[ "snow_blowoff_ledge_runner" ]			= loadfx( "snow/snow_blowoff_ledge_runner" );
	
	level._effect[ "snow_updraft" ]							= loadfx( "snow/snow_updraft" );
	level._effect[ "snow_updraft_runner" ]					= loadfx( "snow/snow_updraft_runner" );

	level._effect[ "snow_clifftop_runner" ]					= loadfx( "snow/snow_clifftop_runner" );
	level._effect[ "snow_clifftop_jet_blow" ]				= loadfx( "snow/snow_clifftop_jet_blow" );

	level._effect[ "snow_spray_detail_runner400x400" ]		= loadfx( "snow/snow_spray_detail_runner400x400" );
	level._effect[ "snow_spray_detail_runner0x400" ]	 	= loadfx( "snow/snow_spray_detail_runner0x400" );
	level._effect[ "snow_spray_detail_runner0x400_far" ]	= loadfx( "snow/snow_spray_detail_runner0x400_far" );
	level._effect[ "snow_spray_detail_runner0x200_far" ]	= loadfx( "snow/snow_spray_detail_runner0x200_far" );
	level._effect[ "snow_spray_detail_runner50x50" ]	 	= loadfx( "snow/snow_spray_detail_runner50x50" );
	
	//Lights
	level._effect[ "lighthaze_snow" ]						= loadfx( "misc/lighthaze_snow" );
	level._effect[ "lighthaze_snow_headlights" ]			= loadfx( "misc/lighthaze_snow_headlights" );
	level._effect[ "car_taillight_uaz_l" ]					= loadfx( "misc/car_taillight_uaz_l" );
	level._effect[ "lighthaze_snow_spotlight" ]				= loadfx( "misc/lighthaze_snow_spotlight" );
	level._effect[ "aircraft_light_red_blink" ]				= loadfx( "misc/aircraft_light_red_blink" );
	level._effect[ "power_tower_light_red_blink" ]			= loadfx( "misc/power_tower_light_red_blink" );
	level._effect[ "light_glow_red_snow_pulse" ]			= loadfx( "misc/light_glow_red_snow_pulse" );

	level._effect[ "heater" ]								= loadfx( "distortion/heater" );
	level._effect[ "snow_vortex" ]							= loadfx( "snow/snow_vortex" );
	level._effect[ "snow_vortex_runner" ]					= loadfx( "snow/snow_vortex_runner" );

	//Hangar Destraction
	level._effect[ "fuel_tank_explosion" ]					= loadfx( "explosions/vehicle_explosion_mig29" );
	level._effect[ "fuel_truck_explosion" ]					= loadfx( "explosions/vehicle_explosion_mig29" );
	
	level._effect[ "thin_black_smoke_M" ]					= loadfx( "smoke/thin_black_smoke_M" );
	level._effect[ "thin_black_smoke_L" ]					= loadfx( "smoke/thin_black_smoke_L" );
	level._effect[ "tire_fire_med" ]						= loadfx( "fire/tire_fire_med" );

	//Hangar Welder
	level._effect[ "welding_runner" ]						= loadfx( "misc/welding_runner" );

	//Snowmobile Section
	level._effect[ "large_snow_explode" ]					= loadfx( "explosions/large_snow_explode" );
	level._effect[ "tree_trunk_explosion" ]					= loadfx( "explosions/tree_trunk_explosion" );

	//Avalanche
	level._effect[ "avalanche_explosion" ]					= loadfx( "explosions/avalanche_explosion" );
	level._effect[ "avalanche_start" ]						= loadfx( "snow/avalanche_start" );
	level._effect[ "avalanche_start2" ]						= loadfx( "snow/avalanche_start2" );
	level._effect[ "avalanche_loop_large" ]					= loadfx( "snow/avalanche_loop_large" );
	
/*	
	//Ambient Cloud Test
	level._effect[ "cloudy" ]								= loadfx( "weather/cloud_mountains" );
	level._effect[ "cloudy_far" ]							= loadfx( "weather/cloud_mountains_far" );
	level._effect[ "cloudy_extreme" ]						= loadfx( "weather/cloud_mountains_extreme" );
*/
	
}

test_transition()
{
	//wait <seconds>;
	//iprintlnbold ( "transition starting" );
	//time = <transition time>;


	//	blizzard_level_transition_none( time );
	//	blizzard_level_transition_light( time );
	//	blizzard_level_transition_med( time );
	//	blizzard_level_transition_hard( time );

	while ( 1 )
	{
		wait 10;

		blizzard_level_transition_none( 1 );
		iprintlnbold( "none" );

		wait 10;

		blizzard_level_transition_hard( 1 );
		iprintlnbold( "hard" );
	}
}

treadfx_override()
{
	
	//it's frik'n snow'n, so everything is snow fx
	tread_effects = "treadfx/tread_snow_slush";
	flying_tread_fx = "treadfx/heli_snow_default";
	
	maps\_treadfx::setvehiclefx( "hind", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "hind", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "hind", "none", flying_tread_fx );

	maps\_treadfx::setvehiclefx( "cobra", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "cobra", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "cobra", "none", flying_tread_fx );
	
	maps\_treadfx::setvehiclefx( "seaknight", "brick", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "bark", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "carpet", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "cloth", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "concrete", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "dirt", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "flesh", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "foliage", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "glass", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "grass", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "gravel", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "ice", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "metal", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "mud", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "paper", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "plaster", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "rock", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "sand", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "snow", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "water", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "wood", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "asphalt", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "ceramic", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "plastic", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "rubber", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "cushion", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "fruit", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "painted metal", "treadfx/heli_snow_seaknight" );
 	maps\_treadfx::setvehiclefx( "seaknight", "default", "treadfx/heli_snow_seaknight" );
	maps\_treadfx::setvehiclefx( "seaknight", "none", "treadfx/heli_snow_seaknight" );

	maps\_treadfx::setvehiclefx( "mi28", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi28", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "mi28", "none", flying_tread_fx );

	maps\_treadfx::setvehiclefx( "mig29", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mig29", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "mig29", "none", flying_tread_fx );

	maps\_treadfx::setvehiclefx( "bmp", "brick", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "bark", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "carpet", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "cloth", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "concrete", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "dirt", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "flesh", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "foliage", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "glass", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "grass", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "gravel", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "ice", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "metal", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "mud", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "paper", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "plaster", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "rock", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "sand", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "snow", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "water", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "wood", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "asphalt", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "ceramic", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "plastic", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "rubber", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "cushion", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "fruit", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "painted metal", tread_effects );
 	maps\_treadfx::setvehiclefx( "bmp", "default", tread_effects );
	maps\_treadfx::setvehiclefx( "bmp", "none", tread_effects );

	maps\_treadfx::setvehiclefx( "uaz", "brick", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "bark", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "carpet", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "cloth", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "concrete", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "dirt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "flesh", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "foliage", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "glass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "grass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "gravel", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "ice", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "mud", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "paper", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "plaster", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "rock", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "sand", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "snow", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "slush", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "water", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "wood", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "asphalt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "ceramic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "plastic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "rubber", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "cushion", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "fruit", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "painted metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz", "default", "treadfx/tread_snow_slush_uaz" );
	maps\_treadfx::setvehiclefx( "uaz", "none", "treadfx/tread_snow_slush_uaz" );

	maps\_treadfx::setvehiclefx( "snowmobile", "snow", "treadfx/tread_snow_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile", "ice", "treadfx/tread_ice_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile", "slush", "treadfx/tread_snow_default_with_decals" );

	maps\_treadfx::setvehiclefx( "snowmobile_friendly", "snow", "treadfx/tread_snow_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile_friendly", "ice", "treadfx/tread_ice_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile_friendly", "slush", "treadfx/tread_snow_default_with_decals" );

	maps\_treadfx::setvehiclefx( "snowmobile_player", "snow", "treadfx/tread_snow_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile_player", "ice", "treadfx/tread_ice_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile_player", "slush", "treadfx/tread_snow_default_with_decals" );

	maps\_treadfx::setvehiclefx( "snowmobile_player_coop", "snow", "treadfx/tread_snow_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile_player_coop", "ice", "treadfx/tread_ice_default_with_decals" );
	maps\_treadfx::setvehiclefx( "snowmobile_player_coop", "slush", "treadfx/tread_snow_default_with_decals" );

}
