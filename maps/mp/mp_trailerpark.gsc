
main()
{
	maps\mp\mp_trailerpark_precache::main();
	maps\createart\mp_trailerpark_art::main();
	maps\mp\mp_trailerpark_fx::main();

	maps\mp\_destructible_dlc2::main(); // call before _load
	maps\mp\_destructible_dlc::main(); // call before _load

	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_trailerpark" );
	
	
	setdvar( "r_lightGridEnableTweaks", 1 );
//	setdvar( "r_specularcolorscale", "1.7" );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	setdvar( "compassmaxrange", "1700" );
	
	AmbientPlay( "ambient_mp_trailerpark" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
}