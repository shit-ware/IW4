main()
{

	level.tweakfile = false;

	//* Fog and vision section * 

	setDevDvar( "scr_fog_disable", "0" );

	ent = maps\_utility::create_vision_set_fog( "dcburning_bunker" );
	ent.startDist = 4430;
	ent.halfwayDist = 11791;
	ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
	ent.maxOpacity = 0.366379;
	ent.transitionTime = 0;
	/*
	ent.sunRed = 0.459065;
	ent.sunGreen = 0.301622;
	ent.sunBlue = 0.205715;
	ent.sunDir = (1, 0.069, 0.06);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 90;
	ent.normalFogScale = 1;
	*/
	
	ent = maps\_utility::create_vision_set_fog( "dcburning_trenches" );
	ent.startDist = 4430;
	ent.halfwayDist = 11791;
	ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
	ent.maxOpacity = 0.366379;
	ent.transitionTime = 0;
	/*
	ent.sunRed = 0.459065;
	ent.sunGreen = 0.301622;
	ent.sunBlue = 0.205715;
	ent.sunDir = (1, 0.069, 0.06);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 90;
	ent.normalFogScale = 1;
	*/
	ent = maps\_utility::create_vision_set_fog( "dcburning_commerce" );
	ent.startDist = 4430;
	ent.halfwayDist = 11791;
	ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
	ent.maxOpacity = 0.366379;
	ent.transitionTime = 0;
	/*
	ent.sunRed = 0.459065;
	ent.sunGreen = 0.301622;
	ent.sunBlue = 0.205715;
	ent.sunDir = (1, 0.069, 0.06);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 90;
	ent.normalFogScale = 1;
	*/
	ent = maps\_utility::create_vision_set_fog( "dcburning_rooftops" );
	ent.startDist = 4430;
	ent.halfwayDist = 11791;
	ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
	ent.maxOpacity = 0.366379;
	ent.transitionTime = 0;
	/*
	ent.sunRed = 0.459065;
	ent.sunGreen = 0.301622;
	ent.sunBlue = 0.205715;
	ent.sunDir = (1, 0.069, 0.06);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 90;
	ent.normalFogScale = 1;
	*/
	
	ent = maps\_utility::create_vision_set_fog( "dcburning_heliride" );
	ent.startDist = 4430;
    ent.halfwayDist = 24073.8;
    ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
    ent.maxOpacity = 0.568751;
    ent.transitionTime = 0;
    /*
    ent.sunRed = 0.459065;
    ent.sunGreen = 0.301622;
    ent.sunBlue = 0.205715;
    ent.sunDir = (1, 0.069, 0.06);
    ent.sunBeginFadeAngle = 0;
    ent.sunEndFadeAngle = 90;
    ent.normalFogScale = 1;
	*/
	ent = maps\_utility::create_vision_set_fog( "dcburning_crash" );
	ent.startDist = 4430;
    ent.halfwayDist = 24073.8;
    ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
    ent.maxOpacity = 0.568751;
    ent.transitionTime = 0;
    /*
    ent.sunRed = 0.459065;
    ent.sunGreen = 0.301622;
    ent.sunBlue = 0.205715;
    ent.sunDir = (1, 0.069, 0.06);
    ent.sunBeginFadeAngle = 0;
    ent.sunEndFadeAngle = 90;
    ent.normalFogScale = 1;
	*/
	maps\_utility::vision_set_fog_changes( "dcburning_bunker", 0 );

}

