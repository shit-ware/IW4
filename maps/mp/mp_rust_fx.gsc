main()
{
	//ambient fx
	level._effect[ "sand_storm_light" ]						= loadfx( "weather/sand_storm_mp_rust" );
	level._effect[ "sand_spray_detail_runner0x400" ]	 	= loadfx( "dust/sand_spray_detail_runner_0x400" );
	level._effect[ "sand_spray_detail_runner400x400" ]	 	= loadfx( "dust/sand_spray_detail_runner_400x400" );
	level._effect[ "sand_spray_detail_oriented_runner" ]	= loadfx( "dust/sand_spray_detail_oriented_runner" );
	level._effect[ "sand_spray_cliff_oriented_runner" ] 	= loadfx( "dust/sand_spray_cliff_oriented_runner" );

/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_rust_fx::main();
#/

}