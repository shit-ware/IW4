main()
{

	level.tweakfile = false;

	//* Fog and vision section * 

	setDevDvar( "scr_fog_disable", "0" );
	
	ent = maps\_utility::create_vision_set_fog( "dcburning_crash" );
	ent.startDist = 4430;
    ent.halfwayDist = 24073.8;
    ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
    ent.maxOpacity = 0.568751;
    ent.transitionTime = 0;
   	
   	ent = maps\_utility::create_vision_set_fog( "dcemp_iss" );
	ent.startDist = 10;
    ent.halfwayDist = 50000;
    ent.red = 0.0;
	ent.green = 0.0;
	ent.blue = 0.0;
    ent.maxOpacity = 0.0;
    ent.transitionTime = 0;
    
    ent = maps\_utility::create_vision_set_fog( "dcemp_emp" );
	ent.startDist = 4430;
    ent.halfwayDist = 24073.8;
    ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
    ent.maxOpacity = 0.568751;
    ent.transitionTime = 0;
    
    ent = maps\_utility::create_vision_set_fog( "dcemp_postemp" );
    ent.startDist = 4430;
    ent.halfwayDist = 24073.8;
    ent.red = 0.0992;
	ent.green = 0.0791;
	ent.blue = 0.0711;
    ent.maxOpacity = 0.568751;
    ent.transitionTime = 0;
    
    ent = maps\_utility::create_vision_set_fog( "dcemp_postemp2" );
    ent.startDist = 0;
    ent.halfwayDist = 4500;
    ent.red = 0.0;
    ent.green = 0.0;
    ent.blue = 0.0;
    ent.maxOpacity = 1.0;
    ent.transitionTime = 0;
    
    ent = maps\_utility::create_vision_set_fog( "dcemp_office" );
    ent.startDist = 0;
    ent.halfwayDist = 4500;
    ent.red = 0.0;
    ent.green = 0.0;
    ent.blue = 0.0;
    ent.maxOpacity = 1.0;
    ent.transitionTime = 0;
    
    ent = maps\_utility::create_vision_set_fog( "dcemp_parking" );
    ent.startDist = 0;
    ent.halfwayDist = 4500;
    ent.red = 0.0;
    ent.green = 0.0;
    ent.blue = 0.0;
    ent.maxOpacity = 1.0;
    ent.transitionTime = 0;
    ent.sunRed = 0;
    ent.sunGreen = 0;
    ent.sunBlue = 0;
    ent.sunDir = ( .672, -.741, -.006 );
    ent.sunBeginFadeAngle = 0;
    ent.sunEndFadeAngle = 96;
    ent.normalFogScale = 10;
    
    ent = maps\_utility::create_vision_set_fog( "dcemp_parking_lightning" );
    ent.startDist = 4000;
    ent.halfwayDist = 20000;
    ent.red = 0.345;
    ent.green = 0.390;
    ent.blue = 0.460;
    ent.maxOpacity = .5;
    ent.transitionTime = 0;
    ent.sunRed = 1;
    ent.sunGreen = 1;
    ent.sunBlue = 1;
    ent.sunDir = ( .406, .487, .773 );
    ent.sunBeginFadeAngle = 0;
    ent.sunEndFadeAngle = 57.5;
    ent.normalFogScale = 1;
            
    ent = maps\_utility::create_vision_set_fog( "dcemp" );
    ent.startDist = 3321.8;
    ent.halfwayDist = 24073.8;
    ent.red = 0.289314;
    ent.green = 0.230781;
    ent.blue = 0.208076;
    ent.maxOpacity = 0.568751;
    ent.transitionTime = 0;
    ent.sunRed = 0.459065;
    ent.sunGreen = 0.301622;
    ent.sunBlue = 0.205715;
    ent.sunDir = (1, 0.069, 0.06);
    ent.sunBeginFadeAngle = 0;
    ent.sunEndFadeAngle = 90;
    ent.normalFogScale = 1;

    ent = maps\_utility::create_vision_set_fog( "whitehouse" );
    ent.startDist = 5882;
    ent.halfwayDist = 4070;
    ent.red = 0.217;
    ent.green = 0.136;
    ent.blue = 0.101;
    ent.maxOpacity = 0.58;
    ent.transitionTime = 0;

    ent = maps\_utility::create_vision_set_fog( "dcemp_tunnels" );
    ent.startDist = 5882;
    ent.halfwayDist = 4070;
    ent.red = 0.217;
    ent.green = 0.136;
    ent.blue = 0.101;
    ent.maxOpacity = 0.58;
    ent.transitionTime = 0;
}

