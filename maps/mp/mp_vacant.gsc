main()
{
	maps\mp\mp_vacant_precache::main();
	maps\mp\mp_vacant_fx::main();
	maps\createart\mp_vacant_art::main();
	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_vacant_dlc" );
	
	AmbientPlay( "ambient_mp_vacant" );
	
	game["attackers"] = "axis";
	game["defenders"] = "allies";

	SetDvar( "r_specularcolorscale", "1" );
	SetDvar( "compassmaxrange", "1500" );
		
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.0 );
	setdvar( "r_lightGridContrast", 1 );
}
