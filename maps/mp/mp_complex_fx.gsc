main()
{

	level._effect[ "battlefield_smokebank_S_warm" ] 			= loadfx( "smoke/battlefield_smokebank_S_warm" );
	level._effect[ "battlefield_smokebank_S_warm_thick" ] 		= loadfx( "smoke/battlefield_smokebank_S_warm_thick" );

	level._effect[ "firelp_large_pm" ]							= loadfx( "fire/firelp_large_pm" );
	level._effect[ "firelp_large_pm_far" ] 						= loadfx( "fire/firelp_large_pm_far" );
	level._effect[ "firelp_small_pm_complex" ]					= loadfx( "fire/firelp_small_pm_complex" );
	level._effect[ "fire_falling_runner_point_infrequent_mp" ] 	= loadfx( "fire/fire_falling_runner_point_infrequent_mp" );

	level._effect[ "insect_trail_runner_icbm" ] 				= loadfx( "misc/insect_trail_runner_icbm" );
	level._effect[ "insects_carcass_runner" ] 					= loadfx( "misc/insects_carcass_runner" );
	level._effect[ "insects_light_invasion" ] 					= loadfx( "misc/insects_light_complex" );

	level._effect[ "leaves_fall_gentlewind" ] 					= loadfx( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_ground_gentlewind" ] 				= loadfx( "misc/leaves_ground_gentlewind" );
	level._effect[ "leaves_spiral_runner" ] 					= loadfx( "misc/leaves_spiral_runner" );

	level._effect[ "powerline_runner_cheap_complex" ] 			= loadfx( "explosions/powerline_runner_cheap_complex" );

	level._effect[ "room_smoke_200" ] 							= loadfx( "smoke/room_smoke_200" );
	level._effect[ "smoke_plume02" ] 							= loadfx( "smoke/smoke_plume02" );

	level._effect[ "trash_spiral_runner" ] 						= loadfx( "misc/trash_spiral_runner" );


/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_complex_fx::main();
#/

}