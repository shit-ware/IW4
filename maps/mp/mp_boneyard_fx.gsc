main()
{
	//ambient fx
	level._effect[ "tanker_embers" ] 					= loadfx( "fire/tanker_embers" );
	level._effect[ "firelp_large_pm_nolight" ] 			= loadfx( "fire/firelp_large_pm_nolight" );
	level._effect[ "firelp_med_pm_nolight" ] 			= loadfx( "fire/firelp_med_pm_nolight" );
	level._effect[ "firelp_small_pm_a_nolight" ] 		= loadfx( "fire/firelp_small_pm_a_nolight" );

	level._effect[ "dust_wind_fast" ]					 = loadfx( "dust/dust_wind_fast" );
	level._effect[ "dust_wind_slow" ]					 = loadfx( "dust/dust_wind_slow_yel_loop" );
	level._effect[ "dust_wind_fast_light" ] 			= loadfx( "dust/dust_wind_fast_light" );
	level._effect[ "trash_spiral_runner" ] 				= loadfx( "misc/trash_spiral_runner" );

	level._effect[ "sand_spray_detail_oriented_runner" ]	= loadfx( "dust/sand_spray_detail_oriented_runner" );
	level._effect[ "sand_spray_cliff_oriented_runner" ] 	= loadfx( "dust/sand_spray_cliff_oriented_runner" );

	level._effect[ "room_smoke_200" ] 					= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ] 					= loadfx( "smoke/room_smoke_400" );
	level._effect[ "hallway_smoke_light" ] 				= loadfx( "smoke/hallway_smoke_light" );

 /#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_boneyard_fx::main();
#/

}