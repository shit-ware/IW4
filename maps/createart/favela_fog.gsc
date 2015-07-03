main()
{
	setDevDvar( "scr_fog_disable", "0" );
	
	ent = maps\_utility::create_vision_set_fog( "favela" );
	ent.startDist = 200;
	ent.halfwayDist = 22000;
	ent.red = 0.562109;
	ent.green = 0.600449;
	ent.blue = 0.678415;
	ent.maxOpacity = 0.5;
	ent.transitionTime = 10;
	ent.sunRed = 0.88;
	ent.sunGreen = 0.88;
	ent.sunBlue = 0.864;
	ent.sunDir = ( 0.89008, -0.302316, -0.341119 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 1.8;
	
	ent = maps\_utility::create_vision_set_fog( "favela_shanty" );
	ent.startDist = 200;
	ent.halfwayDist = 25000;
	ent.red = 0.562109;
	ent.green = 0.600449;
	ent.blue = 0.678415;
	ent.maxOpacity = 0.5;
	ent.transitionTime = 10;
	ent.sunRed = 0.88;
	ent.sunGreen = 0.88;
	ent.sunBlue = 0.864;
	ent.sunDir = ( 0.89008, -0.302316, -0.341119 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 1.8;

	maps\_utility::vision_set_fog_changes( "favela", 0 );
}

