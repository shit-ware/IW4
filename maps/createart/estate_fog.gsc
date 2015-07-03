main()
{
	setDevDvar( "scr_fog_disable", "0" );
	
	ent = maps\_utility::create_vision_set_fog( "estate_hilltop" );
	ent.startDist = 1600;
	ent.halfwayDist = 6164;
	ent.red = 0.333;
	ent.green = 0.421;
	ent.blue = 0.482;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
	
	
	ent = maps\_utility::create_vision_set_fog( "estate_forest" );
	ent.startDist = 1117;
	ent.halfwayDist = 2252;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.49;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_ambush_clearing" );
		ent.startDist = 650;
	ent.halfwayDist = 1000;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.49;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "estate_house_approach" );
	ent.startDist = 3650;
	ent.halfwayDist = 12000;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.402;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_house_interior" );
	ent.startDist = 780;
	ent.halfwayDist = 2000;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.80;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_forest_clearing" );
	ent.startDist = 1196;
	ent.halfwayDist = 4600;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.402;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_house_backyard" );
	ent.startDist = 500;
	ent.halfwayDist = 8000;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.402;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "estate_birchfield" );
	ent.startDist = 331;
	ent.halfwayDist = 853;
	ent.red = 0.342;
	ent.green = 0.393;
	ent.blue = 0.48;
	ent.maxOpacity = 0.434;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_finalfield" );
	ent.startDist = 450;
	ent.halfwayDist = 6318;
    ent.red = 0.350;
	ent.green = 0.434;
	ent.blue = 0.575;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_dragplayer" );
	ent.startDist = 3650;
	ent.halfwayDist = 12000;
    ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.402;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_throwplayer" );
	ent.startDist = 3650;
	ent.halfwayDist = 12000;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.402;
	ent.transitionTime = 0;

	
	ent = maps\_utility::create_vision_set_fog( "estate_burnplayer" );
	ent.startDist = 3650;
	ent.halfwayDist = 12000;
	ent.red = 0.309;
	ent.green = 0.383;
	ent.blue = 0.509;
	ent.maxOpacity = 0.402;
	ent.transitionTime = 0;

	
	maps\_utility::vision_set_fog_changes( "estate_hilltop", 0 );
}
