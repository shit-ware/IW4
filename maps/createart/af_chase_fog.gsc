main()
{
	setDevDvar( "scr_fog_disable", "0" );

	
	/* original start fog in the caves */

	ent = maps\_utility::create_fog( "afch_fog_start" );
	ent.startDist = 250;
	ent.halfwayDist = 8000;
	ent.red = .37;
	ent.green = .33;
	ent.blue = .25;
	ent.maxOpacity = 0.8;
	ent.transitionTime = 0;

	/* Fog for opening drive section, caves and gorge */
	
	ent = maps\_utility::create_fog( "afch_fog_caves" );
	ent.startDist = 1000;
	ent.halfwayDist = 8000;
	ent.red = 0.6;
	ent.green = 0.5;
	ent.blue = 0.4;
	ent.maxOpacity = 0.45;
	ent.transitionTime = 0;

	/* Fog for the resevoir as you come out of the cave */

	ent = maps\_utility::create_fog( "afch_fog_resevoir_1" );
	ent.startDist = 8080;
	ent.halfwayDist = 128471;
	ent.red = 0.6;
	ent.green = 0.5;
	ent.blue = 0.4;
	ent.maxOpacity = 0.3;
	ent.transitionTime = 0;
	ent.sunRed = 0.610391;
	ent.sungreen = 0.631817;
	ent.sunblue = 0.645881;
	ent.sundir = ( .702681, -0.705381, 0.09315 ); 
	ent.sunBeginFadeAngle = 2;
	ent.sunEndFadeAngle = 178;
	ent.normalFogScale = 10;

	/* Fog change halfway through the resevoir */

	ent = maps\_utility::create_fog( "afch_fog_resevoir_2" );
	ent.startDist = 8080;
	ent.halfwayDist = 128471;
	ent.red = 0.6;
	ent.green = 0.5;
	ent.blue = 0.4;
	ent.maxOpacity = 0.3;
	ent.transitionTime = 0;
	ent.sunRed = 0.610391;
	ent.sungreen = 0.631817;
	ent.sunblue = 0.645881;
	ent.sundir = ( .702681, -0.705381, 0.09315 ); 
	ent.sunBeginFadeAngle = 1;
	ent.sunEndFadeAngle = 172;
	ent.normalFogScale = 10;	

	/* Fog change at the rapids */

	ent = maps\_utility::create_fog( "afch_fog_rapids" );
	ent.startDist = 4200;
	ent.halfwayDist = 17000;
	ent.red = 0.6;
	ent.green = 0.5;
	ent.blue = 0.4;
	ent.maxOpacity = 0.55;
	ent.transitionTime = 0;
	
	/* Fog change at the bottom of the gorge */

	ent = maps\_utility::create_fog( "afch_fog_gorge" );
	ent.startDist = 1500;
	ent.halfwayDist = 15000;
	ent.red = 0.6;
	ent.green = 0.5;
	ent.blue = 0.4;
	ent.maxOpacity = 0.45;
	ent.transitionTime = 0;

	/* Fog change at the top of the waterfall */

	ent = maps\_utility::create_fog( "afch_fog_waterfall" );
	ent.startDist = 10000;
	ent.halfwayDist = 50000;
	ent.red = 0.6;
	ent.green = 0.5;
	ent.blue = 0.4;
	ent.maxOpacity = 0.75;
	ent.transitionTime = 0;

	/* Fog change on the dunes */

	ent = maps\_utility::create_fog( "afch_fog_dunes" );
	ent.startDist = 0;
	ent.halfwayDist = 840;
	ent.red = 0.661137;
	ent.Green = 0.554261;
	ent.Blue = 0.454014;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	
	
	ent = maps\_utility::create_fog( "afch_fog_dunes_far" );
	ent.startDist = 0;
	ent.halfwayDist = 8340;
	ent.red = 0.661137;
	ent.Green = 0.554261;
	ent.Blue = 0.454014;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;

	/* Fog Pulse on the dunes, meant to blank the screen. */

	ent = maps\_utility::create_fog( "afch_fog_dunes_pulse_fog" );
	ent.startDist = 0;
	ent.halfwayDist = 30;
	ent.red = 0.661137;
	ent.Green = 0.554261;
	ent.Blue = 0.454014;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunDir = ( 0.919475, -0.206657, 0.334451 );
	
		/* Fog Pulse on the dunes, meant to blank the screen. */

	ent = maps\_utility::create_fog( "afch_fog_dunes_pulse_fog_mid" );
	ent.startDist = 0;
	ent.halfwayDist = 155;
	ent.red = 0.661137;
	ent.Green = 0.554261;
	ent.Blue = 0.454014;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;


		/* underwater..  */

	ent = maps\_utility::create_fog( "afch_fog_underwater" );
	ent.startDist = 0;
	ent.halfwayDist = 155;
	ent.red = 0.661137;
	ent.Green = 0.554261;
	ent.Blue = 0.454014;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	ent.sunRed = 0.01;
	ent.sungreen = 0.45;
	ent.sunblue = 0.39;
	ent.sundir = ( 0, 0, -1 ); 
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 180;
	ent.normalFogScale = 10;
	
	
	maps\_utility::fog_set_changes( "afch_fog_start", 0 );
	
	
}
