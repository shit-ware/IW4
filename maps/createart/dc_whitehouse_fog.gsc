main()
{

	level.tweakfile = false;

	//* Fog and vision section * 

	setDevDvar( "scr_fog_disable", "0" );

    ent = maps\_utility::create_vision_set_fog( "dc_whitehouse_tunnel" );
    ent.startDist = 5882;
    ent.halfwayDist = 4070;
    ent.red = 0.217;
    ent.green = 0.136;
    ent.blue = 0.101;
    ent.maxOpacity = 0.58;
    ent.transitionTime = 0;

    ent = maps\_utility::create_vision_set_fog( "dc_whitehouse_lawn" );
    ent.startDist = 5882;
    ent.halfwayDist = 4070;
    ent.red = 0.217;
    ent.green = 0.136;
    ent.blue = 0.101;
    ent.maxOpacity = 0.58;
    ent.transitionTime = 0;

    ent = maps\_utility::create_vision_set_fog( "dc_whitehouse_interior" );
    ent.startDist = 5882;
    ent.halfwayDist = 4070;
    ent.red = 0.217;
    ent.green = 0.136;
    ent.blue = 0.101;
    ent.maxOpacity = 0.58;
    ent.transitionTime = 0;

    ent = maps\_utility::create_vision_set_fog( "dc_whitehouse_roof" );
    ent.startDist = 10;
    ent.halfwayDist = 3000;
    ent.red = 0.25098;
    ent.green = 0.1098;
    ent.blue = 0.0431;
    ent.maxOpacity = 0.4;
    ent.transitionTime = 0;
}

