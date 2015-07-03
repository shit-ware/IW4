main()
{
	maps\mp\mp_invasion_precache::main();
	maps\createart\mp_invasion_art::main();
	maps\mp\mp_invasion_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_invasion" );

	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 1.5;

	ambientPlay( "ambient_mp_urban" );

	game[ "attackers" ] = "axis";
	game[ "defenders" ] = "allies";

	setdvar( "r_specularcolorscale", "2.5" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.25 );
	setdvar( "r_lightGridContrast", .5 );
	setdvar( "compassmaxrange", "2500" );


}