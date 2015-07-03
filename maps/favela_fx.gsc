#include common_scripts\utility;
#include maps\_utility;

main()
{
	//scripted FX
	level._effect[ "jumper_cables" ]					= loadfx( "misc/jumper_cable_sparks" );
	level._effect[ "blood" ]					 		= loadfx( "impacts/sniper_escape_blood" );
	level._effect[ "blood_dashboard_splatter" ]					= loadfx( "impacts/blood_dashboard_splatter" );
	level._effect[ "glass_exit" ]						= loadfx( "impacts/glass_exit_car" );
	level._effect[ "car_glass_interior" ]				= loadfx( "props/car_glass_interior_favela" );
	level._effect[ "plant_large_thrower" ]				= loadfx( "props/plant_large_thrower" );
	level._effect[ "plant_medium_thrower" ]				= loadfx( "props/plant_medium_thrower" );
	level._effect[ "plant_small_thrower" ]				= loadfx( "props/plant_small_thrower" );
	level._effect[ "falling_dust" ]						= loadfx( "dust/ceiling_dust_default" );
	level._effect[ "cash_trail" ]					 	= loadfx( "props/cash_trail" );
	level._effect[ "cash_drop" ]					 	= loadfx( "props/cash_drop" );

	//Ending
	level._effect[ "glass_dust_trail" ]					= loadfx( "dust/glass_dust_trail_emitter" );
	level._effect[ "car_crush_glass_med" ]				= loadfx( "props/car_glass_med" );
	level._effect[ "car_crush_glass_large" ]			= loadfx( "props/car_glass_large" );
	level._effect[ "car_crush_dust" ]					= loadfx( "dust/car_crush_dust" );

	
	//ambient fx
	level._effect[ "insects_carcass_runner" ]			= loadfx( "misc/insects_carcass_runner" );

	level._effect[ "firelp_med_pm" ]					= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm" ]				 	= loadfx( "fire/firelp_small_pm" );
	level._effect[ "firelp_small_pm_a" ]				= loadfx( "fire/firelp_small_pm_a" );
	level._effect[ "firelp_large_pm" ]					= loadfx( "fire/firelp_large_pm" );

	level._effect[ "dust_wind_fast" ]					= loadfx( "dust/dust_wind_fast" );
	level._effect[ "dust_wind_slow" ]					= loadfx( "dust/dust_wind_slow_yel_loop" );
	level._effect[ "trash_spiral_runner" ]				= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "leaves_fall_gentlewind" ]		 	= loadfx( "misc/leaves_fall_gentlewind" );

	level._effect[ "hallway_smoke_light" ]				= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "battlefield_smokebank_S" ]			= loadfx( "smoke/battlefield_smokebank_S" );
	level._effect[ "thin_black_smoke_M" ]			 	= LoadFX( "smoke/thin_black_smoke_M" );
	level._effect[ "thin_black_smoke_L" ]			 	= LoadFX( "smoke/thin_black_smoke_L_nofog" );
	
	footstep_effects();
	treadfx_override();
	maps\createfx\favela_fx::main();
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
}
