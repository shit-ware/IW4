main()
{

	level.tweakfile = false;

	//* Fog and vision section * 

	setDevDvar( "scr_fog_disable", "0" );


	ent = maps\_utility::create_vision_set_fog( "trainer_start" );
	ent.startDist = 397.849;
	ent.halfwayDist = 5634.92;
	ent.red = 0.59127;
	ent.green = 0.516798;
	ent.blue = 0.510139;
	ent.maxOpacity = 0.510139;
	ent.transitionTime = 0;
	ent.sunRed = 0.59127;
	ent.sunGreen = 0.516798;
	ent.sunBlue = 0.510139;
	ent.sunDir = (1, 0.069, 0.06);
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 90;
	ent.normalFogScale = 1;

	ent = maps\_utility::create_vision_set_fog( "trainer_pit" );
	ent.startDist = 190;
	ent.halfwayDist = 2027;
	ent.red = 0.59127;
	ent.green = 0.516798;
	ent.blue = 0.510139;
	ent.maxOpacity = 0.354791;
	ent.transitionTime = 0;
	ent.sunRed = 0.664398;
	ent.sunGreen = 0.530552;
	ent.sunBlue = 0.369598;
	ent.sunDir = (-0.00230909, -0.00172138, -0.40625);
	ent.sunBeginFadeAngle = 65;
	ent.sunEndFadeAngle = 90;
	ent.normalFogScale = 2;
	
	maps\_utility::vision_set_fog_changes( "trainer_start", 0 );

}

