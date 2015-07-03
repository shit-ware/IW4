main()
{
	maps\mp\mp_subbase_precache::main();
	maps\createart\mp_subbase_art::main();
	maps\mp\mp_subbase_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_subbase" );

	ambientPlay( "ambient_mp_snow" );

	game[ "defenders"] = "axis";
	game[ "attackers"] = "allies";


	setdvar( "r_specularcolorscale", "2.9" );
	setdvar( "compassmaxrange", "2500" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 2 );
	//setdvar( "r_lightGridContrast", 0 );
}
