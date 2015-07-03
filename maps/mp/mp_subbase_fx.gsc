main()
{
	level._effect[ "snow_light" ]		 = loadfx( "snow/snow_light_mp_subbase" );
	level._effect[ "snow_wind" ]		 = loadfx( "snow/snow_wind" );

/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_subbase_fx::main();
#/

}