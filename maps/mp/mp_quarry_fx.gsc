main()
{
	//ambient fx
	level._effect[ "dust_wind_fast" ]						= loadfx( "dust/dust_wind_fast" );
	level._effect[ "dust_wind_slow" ]						= loadfx( "dust/dust_wind_slow_yel_loop" );
	level._effect[ "dust_spiral_runner" ] 					= loadfx( "dust/dust_spiral_runner" );
	level._effect[ "trash_spiral_runner" ] 					= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "dust_spray_detail_oriented_runner" ]	= loadfx( "dust/dust_spray_detail_oriented_runner" );

	level._effect[ "light_shaft_motes_quarry" ]				= loadfx( "dust/light_shaft_motes_quarry" );

	level._effect[ "room_smoke_200" ] 						= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ] 						= loadfx( "smoke/room_smoke_400" );
	level._effect[ "hallway_smoke_light" ] 					= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "battlefield_smokebank_S" ]				= loadfx( "smoke/battlefield_smokebank_S" );

	level._effect[ "drips_slow" ]							= loadfx( "misc/drips_slow" );
	level._effect[ "drips_fast" ]							= loadfx( "misc/drips_fast" );



/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_quarry_fx::main();
#/

}
