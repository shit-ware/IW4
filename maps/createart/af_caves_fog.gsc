main()
{

	level.tweakfile = false;

	//* Fog and vision section * 

	setDevDvar( "scr_fog_disable", "0" );

	ent = maps\_utility::create_vision_set_fog( "af_caves_outdoors" );
	ent.startDist = 3764.17;
	ent.halfwayDist = 19391;
	ent.red = 0.661137;
	ent.green = 0.554261;
	ent.blue = 0.454014;
	ent.maxOpacity = 0.7;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;

	ent = maps\_utility::create_vision_set_fog( "af_caves_indoors" );
	ent.startDist = 3764.17;
	ent.halfwayDist = 19391;
	ent.red = 0.661137;
	ent.green = 0.554261;
	ent.blue = 0.454014;
	ent.maxOpacity = 0.7;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;
	
	ent = maps\_utility::create_vision_set_fog( "af_caves_indoors_steamroom" );
	ent.startDist = 0;
	ent.halfwayDist = 15242;
	ent.red = 0.807;
	ent.green = 0.8225;
	ent.blue = 0.8262;
	ent.maxOpacity = 0.7682;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;
	
	ent = maps\_utility::create_vision_set_fog( "af_caves_indoors_steamroom_dark" );
	ent.startDist = 0;
	ent.halfwayDist = 4110;
	ent.red = 0.73311;
	ent.green = 0.2763;
	ent.blue = 0.288116;
	ent.maxOpacity = 0.7682;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;
	
	ent = maps\_utility::create_vision_set_fog( "af_caves_indoors_overlook" );
	ent.startDist = 3764.17;
	ent.halfwayDist = 19391;
	ent.red = 0.661137;
	ent.green = 0.554261;
	ent.blue = 0.454014;
	ent.maxOpacity = 0.7;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;
	
	ent = maps\_utility::create_vision_set_fog( "af_caves_indoors_skylight" );
	ent.startDist = 3764.17;
	ent.halfwayDist = 19391;
	ent.red = 0.661137;
	ent.green = 0.554261;
	ent.blue = 0.454014;
	ent.maxOpacity = 0.7;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;

	ent = maps\_utility::create_vision_set_fog( "af_caves_indoors_breachroom" );
	ent.startDist = 3764.17;
	ent.halfwayDist = 19391;
	ent.red = 0.661137;
	ent.green = 0.554261;
	ent.blue = 0.454014;
	ent.maxOpacity = 0.7;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;
	
	ent = maps\_utility::create_vision_set_fog( "af_caves_outdoors_airstrip" );
	ent.startDist = 2044.09;
	ent.halfwayDist = 16810;
	ent.red = 0.67451;
	ent.green = 0.67451;
	ent.blue = 0.713726;
	ent.maxOpacity = 0.778285;
	ent.transitionTime = 0;
	//ent.sunRed = 0;
	//ent.sunGreen = 0;
	//ent.sunBlue = 0;
	//ent.sunDir = (0, 0, 0);
	//ent.sunBeginFadeAngle = 0;
	//ent.sunEndFadeAngle = 0;
	//ent.normalFogScale = 0;
	
	maps\_utility::vision_set_fog_changes( "af_caves_outdoors", 0 );

}

