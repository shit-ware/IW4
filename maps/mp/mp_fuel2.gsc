main()
{
	maps\mp\mp_fuel2_precache::main();
	maps\mp\mp_fuel2_fx::main();
	//maps\createart\mp_fuel2_art::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_fuel2" );
	setExpFog( 500, 8000, 0.501961, 0.501961, 0.45098, 0.5, 0 );

	ambientPlay( "ambient_mp_fuel" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}
