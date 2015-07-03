main()
{
	//ambient fx
	level._effect[ "dust_cloud_mp_afghan" ]					= loadfx( "dust/dust_cloud_mp_afghan" );
	level._effect[ "sand_spray_detail_oriented_runner" ]	= loadfx( "dust/sand_spray_detail_oriented_runner" );
	level._effect[ "sand_spray_cliff_oriented_runner" ] 	= loadfx( "dust/sand_spray_cliff_oriented_runner" );
	level._effect[ "room_smoke_200" ] 						= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ] 						= loadfx( "smoke/room_smoke_400" );
	level._effect[ "drips_fast" ]	 						= loadfx( "misc/drips_fast" );
	level._effect[ "light_shaft_motes_airport" ]			= loadfx( "dust/light_shaft_motes_airport" );
	level._effect[ "light_glow_white_bulb" ]			 	= loadfx( "misc/light_glow_white_bulb" );

/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_afghan_fx::main();
#/

}
