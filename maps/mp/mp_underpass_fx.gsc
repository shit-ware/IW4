main()
{
	//ambient fx
	level._effect[ "rain_mp_underpass" ]					= loadfx( "weather/rain_mp_underpass" );
	level._effect[ "rain_noise_splashes" ]					= loadfx( "weather/rain_noise_splashes" );
	level._effect[ "rain_splash_lite_64x64" ]				= loadfx( "weather/rain_splash_lite_64x64" );
	level._effect[ "rain_splash_lite_128x128" ]				= loadfx( "weather/rain_splash_lite_128x128" );
	level._effect[ "river_splash_small" ]					= loadfx( "water/river_splash_small" );
	level._effect[ "drips_fast" ]							= loadfx( "misc/drips_fast" );
	level._effect[ "lightning" ]							= loadfx( "weather/lightning_mp_underpass" );


/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_underpass_fx::main();
#/

}
