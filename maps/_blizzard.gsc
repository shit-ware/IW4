#include maps\_utility;
#include common_scripts\utility;

blizzard_main()
{
	blizzard_flags();
	fx_init();
	blizzard_level_set( "none" );
	thread blizzard_start();
	
	level.global_ambience_blend_func = ::blizzard_ice_overlay_blend;
}

blizzard_flags()
{
	flag_init( "pause_blizzard_ground_fx" );
}

blizzard_start()
{
	if ( !isdefined( level.players ) )
		level waittill( "level.players initialized" );

	array_thread( level.players, ::blizzard_start_proc );
	thread pause_blizzard_ground_fx();
}

blizzard_start_proc()
{
	while ( 1 )
	{
		if ( is_coop() )
			PlayFXOnTagForClients( level._effect[ "blizzard_main" ], self, "tag_origin", self );
		else
			playfx( level._effect[ "blizzard_main" ], self.origin );
		wait( .3 );
	}
}

fx_init()
{
	setsaveddvar( "r_outdoorfeather", "32" ); //helps keep blizzard close to the ground while allowing outdoor only particles to work. -RoBoTg

	level._effect[ "blizzard_level_0" ]	 = loadfx( "misc/blank" );
	level._effect[ "blizzard_level_1" ]	 = loadfx( "snow/snow_climbing" );
	level._effect[ "blizzard_level_2" ]	 = loadfx( "snow/snow_climbing_up" );
	level._effect[ "blizzard_level_3" ]	 = loadfx( "snow/snow_snowmobile" );
	level._effect[ "blizzard_level_4" ]	 = loadfx( "snow/snow_light" );
	level._effect[ "blizzard_level_5" ]	 = loadfx( "snow/snow_medium" );
	level._effect[ "blizzard_level_6" ]	 = loadfx( "snow/snow_medium_2" );
	level._effect[ "blizzard_level_7" ]	 = loadfx( "snow/snow_medium_3" );
	level._effect[ "blizzard_level_8" ]	 = loadfx( "snow/snow_heavy" );
	level._effect[ "blizzard_level_9" ]	 = loadfx( "snow/snow_heavy" );
	level._effect[ "blizzard_level_10" ] = loadfx( "snow/snow_extreme" );

	level.fog_color = [];
	level.fog_color[ "r" ] = 0.699094;
	level.fog_color[ "g" ] = 0.741239;
	level.fog_color[ "b" ] = 0.82818;

	level.default_sun = GetMapSunLight();
	level.sun_intensity = 1.0;
	level.blizzard_overlay_alpha = 0;
}

blizzard_level_set( type )
{
	level.snowLevel = blizzard_level_get_count( type );

	blizzard_set_fx();
}


/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_none( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_none( time )
{
	blizzard_set();
	thread blizzard_level_transition( "none", time );
	setExpFog( 6552, 25874, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], 1, time );
	maps\_utility::set_vision_set( "cliffhanger", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0 );
	resetsunlight();
}


/*
=============
///ScriptDocBegin
"Name: blizzard_no_fog( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_no_fog( time )
{
	blizzard_set();
	thread blizzard_level_transition( "none", time );
	setExpFog( 100, 27955, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .57, time );
	maps\_utility::set_vision_set( "cliffhanger", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0.25 );
	resetsunlight();
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_climbing( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_climbing( time )
{
	blizzard_set();
	thread blizzard_level_transition( "climbing", time );
	setExpFog( 24472, 15873, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .901075, time );
	maps\_utility::set_vision_set( "cliffhanger", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0.25 );
/*
	intensity = .16;
	thread blizzard_set_sunlight( intensity, time );
*/
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_climbing_up( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_climbing_up( time )
{
	blizzard_set();
	thread blizzard_level_transition( "climbing_up", time );
	setExpFog( 25, 1200, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .5, time );
	maps\_utility::set_vision_set( "cliffhanger", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0.45 );

/*
	intensity = .16;
	thread blizzard_set_sunlight( intensity, time );
*/
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_snowmobile( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_snowmobile( time )
{
	blizzard_set();
	thread blizzard_level_transition( "snowmobile", time );
	setExpFog( 2000, 10000, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .47, time );
	maps\_utility::set_vision_set( "cliffhanger_snowmobile", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0.5 );
/*
  intensity = .85;
	thread blizzard_set_sunlight( intensity, time );
*/
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_light( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_light( time )
{
	blizzard_set();
	thread blizzard_level_transition( "light", time );
	setExpFog( 2000, 10000, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .47, time );
	maps\_utility::set_vision_set( "cliffhanger", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0.45 );
	thread blizzard_set_sunlight( 1.0, time );
/*
	intensity = .555;
	thread blizzard_set_sunlight( intensity, time );
*/
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_med( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_med( time )
{
	blizzard_set();
	thread blizzard_level_transition( "med", time );
	setExpFog( 0, 500, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .8, time );
	maps\_utility::set_vision_set( "cliffhanger", time );
	thread blizzard_set_culldist( 0, 0 );
	SetHalfResParticles( false );
	flag_set( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 0.6 );
/*
	intensity = .16;
	thread blizzard_set_sunlight( intensity, time );
*/
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_hard( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_hard( time )
{
	blizzard_set();
	thread blizzard_level_transition( "hard", time );
	setExpFog( 470, 500, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], 1, time );
	maps\_utility::set_vision_set( "cliffhanger_heavy", time );

	intensity = 1;
	thread blizzard_set_sunlight( intensity, time );
	thread blizzard_set_culldist( time, 3000 );
	SetHalfResParticles( false );

	//flag_clear( "pause_blizzard_ground_fx" );
	
	blizzard_overlay_alpha( time, 0.7 );
}

/*
=============
///ScriptDocBegin
"Name: blizzard_level_transition_extreme( <time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_level_transition_extreme( time )
{
	blizzard_set();
	thread blizzard_level_transition( "extreme", time );
	setExpFog( 470, 500, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], 1, time );
	maps\_utility::set_vision_set( "cliffhanger_extreme", time );

	intensity = 0.5;
	thread blizzard_set_sunlight( intensity, time );
	thread blizzard_set_culldist( time, 3000 );
	SetHalfResParticles( true );
	flag_clear( "pause_blizzard_ground_fx" );
	blizzard_overlay_alpha( time, 1 );
}

blizzard_set_culldist( time, range )
{
	level notify( "blizzard_set_culldist" );
	level endon( "blizzard_set_culldist" );

	//iprintlnBold( "Wait:" + time );
	//iprintlnBold( "Range:" + range );
	wait time;
	SetCullDist( range );
}

blizzard_set_sunlight( intensity, time )
{
	level notify( "blizzard_set_sunlight" );
	level endon( "blizzard_set_sunlight" );
		 
	interval = int( time * 20 );
	
	diff = intensity - level.sun_intensity;
	fraction = diff / interval;
	
	while( interval )
	{
		level.sun_intensity += fraction;
		new_sun = vector_multiply( level.default_sun, level.sun_intensity );
			
		setsunlight( new_sun[ 0 ], new_sun[ 1 ], new_sun[ 2 ] );
		interval--;
		
		wait .05;
	}
	
	level.sun_intensity = intensity;
//	iprintlnbold( "Sun Intensity =" + intensity );
	new_sun = vector_multiply( level.default_sun, level.sun_intensity );
			
	setsunlight( new_sun[ 0 ], new_sun[ 1 ], new_sun[ 2 ] );
}

blizzard_level_transition( type, time )
{
	level notify( "blizzard_level_change" );
	level endon( "blizzard_level_change" );

	newlevel = blizzard_level_get_count( type );

	if ( level.snowLevel > newlevel )
	{
		interval = level.snowLevel - newlevel;
		time /= interval;

		for ( i = 0; i < interval; i++ )
		{
			wait( time );
			level.snowLevel -- ;
			blizzard_set_fx();
		}
		assert( level.snowLevel == newlevel );
	}
	if ( level.snowLevel < newlevel )
	{
		interval = newlevel - level.snowLevel;
		time /= interval;

		for ( i = 0; i < interval; i++ )
		{
			wait( time );
			level.snowLevel++ ;
			blizzard_set_fx();
		}
		assert( level.snowLevel == newlevel );
	}
}

blizzard_set_fx()
{
	level._effect[ "blizzard_main" ] = level._effect[ "blizzard_level_" + level.snowLevel ];
}

blizzard_level_get_count( type )
{
	switch( type )
	{
		case "none":
			return 0;
		case "climbing":
			return 1;
		case "climbing_up":
			return 2;
		case "snowmobile":
			return 3;
		case "light":
			return 4;
		case "med":
			return 6;
		case "hard":
			return 9;
		case "extreme":
			return 10;
	}
}

/*
=============
///ScriptDocBegin
"Name: blizzard_overlay_alpha( <time> , <alpha>, <skipCap> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_overlay_alpha( time, alpha, skipCap )
{
	player = self;
	if ( !isplayer( player ) )
		player = level.player;
	
	if( !isdefined( alpha ) )
		alpha = 1;
	
	// skipcap lets us modify the overlay without setting a new cap
	if ( !isdefined( skipCap ) )
		level.blizzard_overlay_alpha_cap = alpha;
	
	
	overlay = get_frozen_overlay( player );
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( "overlay_frozen", 640, 480 );
	overlay.sort = 50;
	overlay.lowresbackground = true;
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = level.blizzard_overlay_alpha;
	overlay fadeovertime( time );
	overlay.alpha = alpha; // should be 1 but the image is black
	
	level.blizzard_overlay_alpha = alpha;
}

/*
=============
///ScriptDocBegin
"Name: blizzard_overlay_clear( <timer> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blizzard_overlay_clear( timer )
{
	if ( !isdefined( timer ) || !timer )
	{
		player = self;
		if ( !isplayer( player ) )
			player = level.player;
		overlay = get_frozen_overlay( player );
		overlay destroy();
		return;
	}
	
	blizzard_overlay_alpha( timer, 0 );
}


get_frozen_overlay( player )
{
	if ( !isdefined( player.overlay_frozen ) )
		player.overlay_frozen = newClientHudElem( player );

	return player.overlay_frozen;	
}

pause_blizzard_ground_fx()
{
	fx = [];
	fx = getfxarraybyID( "lighthaze_snow" );
	fx = array_combine( fx, getfxarraybyID( "lighthaze_snow_headlights" ));
	fx = array_combine( fx, getfxarraybyID( "snow_spray_detail_runner400x400" ));
	fx = array_combine( fx, getfxarraybyID( "snow_spray_detail_runner0x400" ));
	fx = array_combine( fx, getfxarraybyID( "snow_spray_detail_runner400x0" ));

	wait( 0.1 ); // must wait until fx are started	
	for ( ;; )
	{
		flag_wait( "pause_blizzard_ground_fx" );
		//iprintlnbold( "Stop Ground FX" );
		foreach ( oneshot in fx )
			oneshot pauseEffect();
		flag_waitopen( "pause_blizzard_ground_fx" );
		foreach ( oneshot in fx )
			oneshot restartEffect();
	}
}

blizzard_set()
{
	// added this common function so its easier to debug blizzard changes
	level notify( "blizzard_changed" );
	level notify( "blizzard_set_sunlight" );
}

blizzard_ice_overlay_blend( progress, inner, outer )
{
	cap = level.blizzard_overlay_alpha_cap;
	if ( !isdefined( cap ) )
		cap = 1;
	// find the exterior 
	if ( issubstr( inner, "exterior" ) )
	{
		blizzard_overlay_alpha( 1, ( 1 - progress ) * cap, true );
		return;
	}
	if ( issubstr( outer, "exterior" ) )
	{
		blizzard_overlay_alpha( 1, progress * cap, true );
	}
}