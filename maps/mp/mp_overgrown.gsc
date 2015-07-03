main()
{
	maps\mp\mp_overgrown_precache::main();
	maps\mp\mp_overgrown_fx::main();
	maps\createart\mp_overgrown_art::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_overgrown_dlc" );

	AmbientPlay( "ambient_mp_overgrown" );

	game["attackers"] = "axis";
	game["defenders"] = "allies";

	SetDvar( "r_specularcolorscale", "1" );
	SetDvar( "compassmaxrange", "2200" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.0 );
	setdvar( "r_lightGridContrast", 1 );
}
