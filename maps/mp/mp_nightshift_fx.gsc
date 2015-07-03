main()
{
	//ambient fx
	level._effect[ "dust_wind_fast_light" ] 			= loadfx( "dust/dust_wind_fast_light" );
	level._effect[ "trash_spiral_runner" ] 				= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "hallway_smoke_light" ] 				= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "battlefield_smokebank_S" ] 			= loadfx( "smoke/battlefield_smokebank_S" );
	level._effect[ "room_smoke_200" ] 					= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ] 					= loadfx( "smoke/room_smoke_400" );
	level._effect[ "ground_fog_mp_highrise_far" ]		= loadfx( "smoke/ground_fog_mp_highrise_far" );
	level._effect[ "drips_fast" ]	 					= loadfx( "misc/drips_fast" );
	level._effect[ "ground_smoke_1200x1200" ]			= loadfx( "smoke/ground_smoke1200x1200" );


 /#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_nightshift_fx::main();
#/

}

