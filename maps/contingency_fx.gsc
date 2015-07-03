#include common_scripts\utility;
#include maps\_utility;
#include maps\_debug;

main()
{
	level._effect[ "cold_breath" ]				 = loadfx( "misc/cold_breath" );
	
	//Vehcile DeathFX Overrides
	maps\_vehicle::build_deathfx_override( "gauntlet", "vehicle_sa15_gauntlet", "explosions/vehicle_explosion_gauntlet", undefined , "exp_armor_vehicle" );

//	build_deathfx( "explosions/large_vehicle_explosion", undefined, "exp_armor_vehicle" );

	//scripted fx
	level._effect[ "smoke_geotrail_icbm" ]		 					= loadfx( "smoke/smoke_geotrail_icbm" );
	level._effect[ "icbm_launch" ]				 					= loadfx( "smoke/icbm_launch" );
	
	
	level._effect[ "tree_explosion" ]								= loadfx( "explosions/tree_trunk_explosion" );
	level._effect[ "tree_explosion_small" ]							= loadfx( "explosions/tree_trunk_explosion" );
	
	level._effect[ "thermal_missle_flash_inverted" ]				= loadfx( "muzzleflashes/thermal_missle_flash_inverted" );
	level._effect[ "missle_flash" ]									= loadfx( "muzzleflashes/missile_flash_wv" );
	level._effect[ "uav_explosion" ]								= loadfx( "explosions/aerial_explosion_predator" );
	
	level._effect[ "btr_explosion" ]								= loadfx( "explosions/vehicle_explosion_btr80_snow" );
	level._effect[ "btr_spotlight" ]								= loadfx( "misc/spotlight_btr80" );
	
	level._effect[ "flashlight" ]									= loadfx( "misc/flashlight" );

	level._effect[ "tear_gas_submarine" ]							= loadfx( "smoke/tear_gas_submarine" );
	
	
	level._effect[ "tree_snow_dump_fast" ]							= loadfx( "snow/tree_snow_dump_fast" );
	level._effect[ "tree_snow_dump_fast_small" ]					= loadfx( "snow/tree_snow_dump_fast_small" );
	
	level._effect[ "tree_snow_fallen_heavy" ]						= loadfx( "snow/tree_snow_fallen_heavy" );
	level._effect[ "tree_snow_fallen" ]								= loadfx( "snow/tree_snow_fallen" );
	level._effect[ "tree_snow_fallen_small" ]						= loadfx( "snow/tree_snow_fallen_small" );

	//Price Sliding fx
	level._effect[ "price_landing" ]								= loadfx( "snow/snow_price_landing" );
	level._effect[ "price_sliding" ]								= loadfx( "snow/snow_price_sliding" );

	//Ambient fx
	level._effect[ "tree_snow_dump_runner" ]						= loadfx( "snow/tree_snow_dump_runner" );
	level._effect[ "snow_spray_detail_contingency_runner_0x400" ]	= loadfx( "snow/snow_spray_detail_contingency_runner_0x400" );
	level._effect[ "snow_spray_detail_oriented_runner_0x400" ]		= loadfx( "snow/snow_spray_detail_oriented_runner_0x400" );
	level._effect[ "snow_spray_detail_oriented_runner_400x400" ]	= loadfx( "snow/snow_spray_detail_oriented_runner_400x400" );
	level._effect[ "snow_spray_detail_oriented_runner" ]			= loadfx( "snow/snow_spray_detail_oriented_runner" );
	level._effect[ "snow_spray_detail_oriented_runner_large" ]		= loadfx( "snow/snow_spray_detail_oriented_large_runner" );
	level._effect[ "snow_spray_large_oriented_runner" ]				= loadfx( "snow/snow_spray_large_oriented_runner" );
	level._effect[ "snow_vortex_runner_cheap" ]						= loadfx( "snow/snow_vortex_runner_cheap" );
	level._effect[ "room_smoke_200" ] 								= LoadFX( "smoke/room_smoke_200" );


	//Player Footstep fx
	level._effect[ "footstep_snow_small" ]							= loadfx( "impacts/footstep_snow_small" );
	level._effect[ "footstep_snow" ]								= loadfx( "impacts/footstep_snow" );

	//Player snow
	level._effect[ "snow_light" ]								 	= loadfx( "snow/snow_light_contingency" );
	
	level thread treadfx_override();
	level thread playerEffect();
	level thread footStepEffects();
	
	maps\createfx\contingency_fx::main();

}

playerEffect()
{
	level endon( "stop_snow" );
	player = getentarray( "player", "classname" )[ 0 ];
	for ( ;; )
	{
		playfx( level._effect[ "snow_light" ], player.origin + ( 0, 0, 300 ), player.origin + ( 0, 0, 350 ) );
		wait( 0.075 );
	}
}

footStepEffects()
{
	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "snow",				loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setFootstepEffect( "ice",				loadfx ( "impacts/footstep_ice" ) );
	animscripts\utility::setFootstepEffect( "slush",			loadfx ( "impacts/footstep_snow_slush" ) );
	
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "snow",		loadfx ( "impacts/footstep_snow_small" ) );
	animscripts\utility::setFootstepEffectSmall( "ice",			loadfx ( "impacts/footstep_ice" ) );
	animscripts\utility::setFootstepEffectSmall( "slush",		loadfx ( "impacts/footstep_snow_slush_small" ) );
	
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"snow",		loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"ice",		loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	//animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"slush",		loadfx ( "impacts/bodyfall_snow_small_runner" ), "bodyfall_", "_small" );
	
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"snow",		loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"ice",		loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	//animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"slush",		loadfx ( "impacts/bodyfall_snow_large_runner" ), "bodyfall_", "_large" );
	
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"snow",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"ice",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"slush",		loadfx ( "impacts/footstep_snow" ) );
	
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"snow",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"ice",		loadfx ( "impacts/footstep_snow" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"slush",		loadfx ( "impacts/footstep_snow" ) );
}

treadfx_override()
{
	
	maps\_treadfx::setvehiclefx( "bm21_troops", "brick", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "bark", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "carpet", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "cloth", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "concrete", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "dirt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "flesh", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "foliage", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "glass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "grass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "gravel", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "ice", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "mud", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "paper", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "plaster", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "rock", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "sand", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "snow", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "water", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "wood", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "asphalt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "ceramic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "plastic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "rubber", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "cushion", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "fruit", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "painted metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "bm21_troops", "default", "treadfx/tread_snow_slush_uaz" );
	maps\_treadfx::setvehiclefx( "bm21_troops", "none", "treadfx/tread_snow_slush_uaz" );
	
	
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

	
	maps\_treadfx::setvehiclefx( "uaz_physics", "brick", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "bark", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "carpet", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "cloth", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "concrete", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "dirt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "flesh", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "foliage", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "glass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "grass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "gravel", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "ice", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "mud", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "paper", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "plaster", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "rock", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "sand", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "snow", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "water", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "wood", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "asphalt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "ceramic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "plastic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "rubber", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "cushion", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "fruit", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "painted metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "default", "treadfx/tread_snow_slush_uaz" );
	maps\_treadfx::setvehiclefx( "uaz_physics", "none", "treadfx/tread_snow_slush_uaz" );


	maps\_treadfx::setvehiclefx( "brt80", "brick", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "bark", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "carpet", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "cloth", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "concrete", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "dirt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "flesh", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "foliage", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "glass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "grass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "gravel", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "ice", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "mud", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "paper", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "plaster", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "rock", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "sand", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "snow", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "water", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "wood", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "asphalt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "ceramic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "plastic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "rubber", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "cushion", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "fruit", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "painted metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80", "default", "treadfx/tread_snow_slush_uaz" );
	maps\_treadfx::setvehiclefx( "brt80", "none", "treadfx/tread_snow_slush_uaz" );
	
	 
	maps\_treadfx::setvehiclefx( "brt80_physics", "brick", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "bark", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "carpet", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "cloth", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "concrete", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "dirt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "flesh", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "foliage", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "glass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "grass", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "gravel", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "ice", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "mud", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "paper", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "plaster", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "rock", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "sand", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "snow", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "water", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "wood", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "asphalt", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "ceramic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "plastic", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "rubber", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "cushion", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "fruit", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "painted metal", "treadfx/tread_snow_slush_uaz" );
 	maps\_treadfx::setvehiclefx( "brt80_physics", "default", "treadfx/tread_snow_slush_uaz" );
	maps\_treadfx::setvehiclefx( "brt80_physics", "none", "treadfx/tread_snow_slush_uaz" );


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


	maps\_treadfx::setvehiclefx( "mi17", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "mi17", "none", flying_tread_fx );

}
