main()
{

	level._effect[ "ground_fog_mp_highrise_far" ]		= loadfx( "smoke/ground_fog_mp_highrise_far" );
	level._effect[ "fog_highrise_night" ]				= loadfx( "smoke/fog_highrise_night" );

	level._effect[ "hallway_smoke" ]					= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "dust_wind_fast_light" ] 			= loadfx( "dust/dust_wind_fast_light" );
	level._effect[ "room_smoke_200" ]					= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ]					= loadfx( "smoke/room_smoke_400" );


 /#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_highrise_fx::main();
#/
}
