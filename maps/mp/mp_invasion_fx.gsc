main()
{


	level._effect[ "firelp_med_pm" ]					 	= loadfx( "fire/firelp_med_pm_nodistort" );
	level._effect[ "firelp_small_pm" ]				 		= loadfx( "fire/firelp_small_pm" );
	level._effect[ "dust_wind_fast" ]					 	= loadfx( "dust/dust_wind_fast" );
	level._effect[ "dust_wind_slow" ]					 	= loadfx( "dust/dust_wind_slow_yel_loop" );
	level._effect[ "dust_wind_spiral" ]				 		= loadfx( "dust/dust_spiral_runner" );
	level._effect[ "battlefield_smokebank_S" ]		 		= loadfx( "smoke/battlefield_smokebank_S" );
	level._effect[ "hallway_smoke_light" ]		 			= loadfx( "smoke/hallway_smoke_light" );
		
	level._effect[ "trash_spiral_runner" ] 					= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "trash_spiral_runner_far" ] 				= loadfx( "misc/trash_spiral_runner_far" );
	level._effect[ "room_smoke_200" ] 						= loadfx( "smoke/room_smoke_200" );
	level._effect[ "leaves_spiral_runner" ] 				= loadfx( "misc/leaves_spiral_runner" );
	level._effect[ "leaves_ground_gentlewind_dust" ]		= loadfx( "misc/leaves_ground_gentlewind_dust" );
	level._effect[ "insect_trail_runner_icbm" ]				= loadfx( "misc/insect_trail_runner_icbm" );
	level._effect[ "falling_brick_runner" ]					= loadfx( "misc/falling_brick_runner" );
	level._effect[ "falling_brick_runner_line_400" ]		= loadfx( "misc/falling_brick_runner_line_400" );
	                                          
/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_invasion_fx::main();
#/

}
