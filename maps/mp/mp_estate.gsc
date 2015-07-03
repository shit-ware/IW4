main()
{

	maps\mp\mp_estate_precache::main();
	maps\createart\mp_estate_art::main();
	maps\mp\mp_estate_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_estate" );

	ambientPlay( "ambient_mp_estate" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";

	setdvar( "r_specularcolorscale", "1.17" );
	setdvar( "compassmaxrange", "3500" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.3 );
	setdvar( "r_lightGridContrast", 0 );

	if ( level.ps3 )
		setdvar( "sm_sunShadowScale", "0.5" ); // ps3 optimization
	else
		setdvar( "sm_sunShadowScale", "0.7" ); // optimization
}