#include maps\mp\_utility;

main()
{
	maps\mp\mp_compact_precache::main();
	maps\createart\mp_compact_art::main();
	maps\mp\mp_compact_fx::main();

	maps\mp\_destructible_dlc::main(); // call before _load
	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_compact" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.10 );
	setdvar( "r_lightGridContrast", 1 );
	setdvar( "compassmaxrange", "1700" );
	
	ambientPlay( "ambient_mp_compact" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	//doMagnet();
	
	//level thread crusherControl();
}

doMagnet()
{
	strength = 18000;
	if ( getdvar( "scr_compact_magnet_strength" ) != "" )
		strength = getdvarfloat( "scr_compact_magnet_strength" );
	if ( strength == 0 )
		return;
		
	radius = 250;
	if ( getdvar( "scr_compact_magnet_radius" ) != "" )
		radius = getdvarfloat( "scr_compact_magnet_radius" );
	if ( radius <= 0 )
		return;
	 
	magnet = getent( "magnetorg", "targetname" );
	Missile_CreateAttractorEnt( magnet, strength, radius );
}

crusherControl()
{
	//button = getEnt( "button01", "targetname" );
	crusher = getEnt( "crusher01", "targetname" );

	crushTop = getEnt( "crushtop01", "targetname" );
	playerDetector = getEnt( "onelevator", "targetname" );
	
	upOrigin = crusher getOrigin();
	downOrigin = upOrigin + (0,0,-128);

	//button.origin = button.origin + (0,0,20);

	crushTop thread triggerLinkThread( crusher );
	crushTop thread crushEmThread();
	playerDetector thread triggerLinkThread( crusher );
	playerDetector thread playerDetectorThread();

	//precacheString( &"MP_PRESS_TO_RAPPEL" ); 
	//button setHintString( &"MP_PRESS_TO_RAPPEL" );
	
	for ( ;; )
	{
		/*
		button makeUsable();
		button waittill ( "trigger", player );
		button playSound( "vending_machine_button_press" );
		button makeUnusable();
		*/
		
		// move down
		crusher playSound( "elev_run_start" );
		crusher playLoopSound( "elev_run_loop" );

		crusher moveTo( downOrigin, 10.0 );		
		crusher waittill ( "movedone" );

		crusher stopLoopSound( "elev_run_loop" );
		crusher playSound( "elev_run_end" );
		
		/*
		button makeUsable();
		button waittill ( "trigger", player );
		button playSound( "vending_machine_button_press" );
		button makeUnusable();
		*/
		
		wait 2;
		
		// wait until a player gets on
		playerDetector waittill( "trigger", player );
		
		// move up
		crusher playSound( "elev_run_start" );
		crusher playLoopSound( "elev_run_loop" );

		crusher moveTo( upOrigin, 10.0 );		
		crusher waittill ( "movedone" );

		crusher stopLoopSound( "elev_run_loop" );
		crusher playSound( "elev_run_end" );
		
		wait 2;
		
		// wait until no players are on
		while ( gettime() - playerDetector.triggertime <= 2000 )
			wait .05;
	}
}


triggerLinkThread( crusher )
{
	for ( ;; )
	{
		self.origin = crusher.origin;
		
		wait ( 0.05 );
	}
}

playerDetectorThread()
{
	self.triggertime = gettime();
	for ( ;; )
	{
		self waittill( "trigger", player );
		self.triggertime = gettime();
	}
}

crushEmThread()
{
	crushBottom = getEnt( "crushbtm01", "targetname" );

	for ( ;; )
	{
		self waittill ( "trigger", player );
		
		if ( player isTouching( crushBottom ) && isReallyAlive( player ) )
			player _suicide();
	}	
}