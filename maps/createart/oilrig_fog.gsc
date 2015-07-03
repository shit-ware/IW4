main()
{

	level.tweakfile = false;

	//* Fog and vision section * 

	setDevDvar( "scr_fog_disable", "0" );

	/*-----------------------
	//oilrig_underwater.vision
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_underwater" );
	ent.startDist = 0;
	ent.halfwayDist = 852;
	ent.red = 0.0431373;
	ent.green = 0.219608;
	ent.blue = 0.247059;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;

	ent.sunRed = 0.0370898;
	ent.sunGreen = 0.0748127;
	ent.sunBlue = 0.125266;
	ent.sunDir = ( -0.0563281, 0.0228246, -1 );
	ent.sunBeginFadeAngle = 85;
	ent.sunEndFadeAngle = 101.5;
	ent.normalFogScale = 1;

	/*-----------------------
	//oilrig_exterior_deck0.vision
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_exterior_deck0" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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
	
	/*-----------------------
	//oilrig_interior.vision
	//Triggered walking up to the first breach area and all other interiors
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_interior" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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

	/*-----------------------
	//oilrig_exterior_deck1.vision
	//triggered coming out on deck 1 for the first time
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_exterior_deck1" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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
	

	/*-----------------------
	//oilrig_exterior_deck2.vision
	//Up the stairs to deck 2
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_exterior_deck2" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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
	

	/*-----------------------
	//oilrig_exterior_deck3.vision
	//Heading to the stairs to deck3
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_exterior_deck3" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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


	/*-----------------------
	//oilrig_exterior_deck4.vision
	//Out the last building to the helipad
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_exterior_deck4" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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
	
	/*-----------------------
	//oilrig_exterior_heli.vision
	//Triggered over 5 seconds when you get on the heli at the end
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_exterior_heli" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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
	
	
	/*-----------------------
	//oilrig_interior2.vision
	//Triggered in second interior
	-------------------------*/	
	ent = maps\_utility::create_vision_set_fog( "oilrig_interior2" );
	ent.startDist = 903.412;
	ent.halfwayDist = 2990.19;
	ent.red = 0.175482;
	ent.green = 0.221931;
	ent.blue = 0.293875;
	ent.maxOpacity = 0.751126;
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
	
	
	//maps\_utility::vision_set_fog_changes( "oilrig_exterior_deck0", 0 );

}

