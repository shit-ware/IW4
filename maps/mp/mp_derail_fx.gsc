main()
{
	//Ambient fx
	level._effect[ "snow_spray_detail_oriented_runner" ]			= loadfx( "snow/snow_spray_detail_oriented_runner" );
	level._effect[ "snow_spray_detail_oriented_runner_large" ]		= loadfx( "snow/snow_spray_detail_oriented_large_runner" );
	level._effect[ "snow_clouds" ]									= loadfx( "snow/snow_clouds_mp_derail" );
	level._effect[ "room_smoke_200" ] 								= loadfx( "smoke/room_smoke_200" );
	level._effect[ "snow_spiral_runner" ]							= loadfx( "snow/snow_spiral_runner" );



/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_derail_fx::main();
#/

}
