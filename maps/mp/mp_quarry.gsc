main()
{
	maps\mp\mp_quarry_precache::main();
	maps\mp\mp_quarry_fx::main();
	maps\createart\mp_quarry_art::main();
	maps\mp\_load::main();
	maps\mp\_explosive_barrels::main();
	maps\mp\_compass::setupMiniMap( "compass_map_mp_quarry" );
	setdvar( "compassmaxrange", "2800" );

	//setExpFog( 900, 3500, 0.631373, 0.568627, 0.54902, 1, 0 );
	//setExpFog( 900, 3500, 0.631373, 0.568627, 0.34902, 1, 0, 1, 0.803922, 0.564706, (0, .5, 1), 0, 	15.2331, 0.961894 );
	
	ambientPlay( "ambient_mp_desert" );
	VisionSetNaked( "mp_quarry" );

	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 2;

	game[ "attackers" ] = "axis";
	game[ "defenders" ] = "allies";
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.22 );
	setdvar( "r_lightGridContrast", .67 );
}
