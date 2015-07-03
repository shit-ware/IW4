main()
{
	maps\mp\mp_favela_precache::main();

	maps\createart\mp_favela_art::main();
	maps\mp\mp_favela_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_favela" );
	//setExpFog( 270, 11488, 0.8, 0.8, 0.8, 0.1, 0 );

	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 1.5;

	ambientPlay( "ambient_mp_favela" );

	switch ( level.gameType )
	{	
		case "oneflag":
			game[ "attackers" ] = "allies";
			game[ "defenders" ] = "axis";
			break;
		default:
			game[ "attackers" ] = "axis";
			game[ "defenders" ] = "allies";
			break;
	}

	setdvar( "r_specularcolorscale", "2.8" );
	setdvar( "compassmaxrange", "1500" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.25 );
	setdvar( "r_lightGridContrast", .45 );
}
