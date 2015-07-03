#include common_scripts\utility;
#include maps\_utility;

main()
{
	flag_init( "pullup_weapon" );
	flag_init( "introscreen_complete" );
	flag_init( "safe_for_objectives" );
	flag_init( "introscreen_complete" );
	delayThread( 10, ::flag_set, "safe_for_objectives" );
	level.linefeed_delay = 16;

	PreCacheShader( "black" );
	PreCacheShader( "white" );

	if ( GetDvar( "introscreen" ) == "" )
		SetDvar( "introscreen", "1" );

	//String1 = Title of the level
	//String2 = Place, Country or just Country
	//String3 = Month Day, Year
	//String4 = Optional additional detailed information
	//Pausetime1 = length of pause in seconds after title of level
	//Pausetime2 = length of pause in seconds after Month Day, Year
	//Pausetime3 = length of pause in seconds before the level fades in 

	if ( IsDefined( level.credits_active ) )
		return;

	switch( level.script )
	{
	case "roadkill":
		// "Team Player"
		PreCacheString( &"ROADKILL_LINE_1" );
		// Day 1 - 16:08:[{FAKE_INTRO_SECONDS:32}]
		PreCacheString( &"ROADKILL_LINE_2" );
		// PFC Joseph Allen
		PreCacheString( &"ROADKILL_LINE_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"ROADKILL_LINE_4" );
		// The Red Zone, Afghanistan
		PreCacheString( &"ROADKILL_LINE_5" );
		introscreen_delay();
		break;
	case "airport":
		// "No Russian"
		PreCacheString( &"AIRPORT_LINE1" );
		// Day 3, 08:40:[{FAKE_INTRO_SECONDS:32}]
		PreCacheString( &"AIRPORT_LINE2" );
		// PFC Joseph Allen a.k.a. Alexei Borodin
		PreCacheString( &"AIRPORT_LINE3" );
		// Zakhaev International Airport
		PreCacheString( &"AIRPORT_LINE4" );
		// Moscow, Russia
		PreCacheString( &"AIRPORT_LINE5" );
		introscreen_delay();
		break;
	case "invasion":
		// "Wolverines!"
		PreCacheString( &"INVASION_LINE1" );
		// Day 4 - 17:45:[{FAKE_INTRO_SECONDS:32}]
		PreCacheString( &"INVASION_LINE2" );
		// Pvt. James Ramirez
		PreCacheString( &"INVASION_LINE3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"INVASION_LINE4" );
		// Wolverines!""
		// Day 4 - 17:45:[{FAKE_INTRO_SECONDS:32}]
		// Pvt. James Ramirez
		// 1st Bn., 75th Ranger Regiment
		// Northeastern Virginia, U.S.A.
		//introscreen_delay(&"INVASION_LINE1", &"INVASION_LINE2", &"INVASION_LINE3", &"INVASION_LINE4", 2, 2, .5);
		break;
	case "oilrig":
		// "The Only Easy Day...Was Yesterday"
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_1" );
		// Day 5 - 05:47:[{FAKE_INTRO_SECONDS:12}]
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_4" );
		// Vikhorevka 36 Oil Platform, Russia
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "gulag":
		// "The Gulag"
		PreCacheString( &"GULAG_INTROSCREEN_1" );
		// Day 5 - 07:42:[{FAKE_INTRO_SECONDS:17}]
		PreCacheString( &"GULAG_INTROSCREEN_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"GULAG_INTROSCREEN_3" );
		// Task Force 141
		PreCacheString( &"GULAG_INTROSCREEN_4" );
		// 40 miles east of Petropavlovsk, Russia
		PreCacheString( &"GULAG_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "dcburning":
		// "Of Their Own Accord"
		PreCacheString( &"DCBURNING_INTROSCREEN_1" );
		// Day 5 - 18:34:[{FAKE_INTRO_SECONDS:33}]
		PreCacheString( &"DCBURNING_INTROSCREEN_2" );
		// Pvt. James Ramirez
		PreCacheString( &"DCBURNING_INTROSCREEN_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"DCBURNING_INTROSCREEN_4" );
		// Washington, D.C., U.S.A.
		PreCacheString( &"DCBURNING_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "trainer":
		// "S.S.D.D."
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_1" );
		//Day 1 - 15:30:[{FAKE_INTRO_SECONDS:25}]
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_2" );
		// PFC Joseph Allen
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_4" );
		// Fire Base Phoenix, Afghanistan
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "dcemp":
		// "Second Sun"
		PreCacheString( &"DCEMP_INTROSCREEN_1" );
		// Day 5 - 18:57:[{FAKE_INTRO_SECONDS:17}]
		PreCacheString( &"DCEMP_INTROSCREEN_2" );
		// Pvt. James Ramirez
		PreCacheString( &"DCEMP_INTROSCREEN_3" );
		// 75th Ranger Regiment
		PreCacheString( &"DCEMP_INTROSCREEN_4" );
		// Washington, D.C.
		PreCacheString( &"DCEMP_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "dc_whitehouse":
		// 'Whiskey Hotel'
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_1" );
		// Day 5, 19:31:[{FAKE_INTRO_SECONDS:22}] hrs
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_2" );
		// Pvt. James Ramirez
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_3" );
		// 75th Ranger Regiment
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_4" );
		// Washington, D.C.
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "killhouse":
		// string not found for KILLHOUSE_INTROSCREEN_LINE_1
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_1" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_2
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_2" );// not used
		// string not found for KILLHOUSE_INTROSCREEN_LINE_3
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_3" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_4
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_4" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_5
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_5" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_1
		// string not found for KILLHOUSE_INTROSCREEN_LINE_3
		// string not found for KILLHOUSE_INTROSCREEN_LINE_4
		// string not found for KILLHOUSE_INTROSCREEN_LINE_5
		introscreen_delay( &"KILLHOUSE_INTROSCREEN_LINE_1", &"KILLHOUSE_INTROSCREEN_LINE_3", &"KILLHOUSE_INTROSCREEN_LINE_4", &"KILLHOUSE_INTROSCREEN_LINE_5" );
		break;
	case "favela":
		// "Takedown"
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_1" );
		// Day 4 - 15:08:[{FAKE_INTRO_SECONDS:16}]
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_4" );
		// Rio de Janeiro, Brazil
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "arcadia":
		// 'Exodus'
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_1" );
		// Day 04 - 17:36:[{FAKE_INTRO_SECONDS:28}]
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_2" );
		// Pvt. James Ramirez
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_4" );
		// Northeastern Virginia, U.S.A.
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "favela_escape":
		// 'The Hornet's Nest'
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_1" );
		// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_4" );
		// Rio de Janeiro, 1700 F.S.L.
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "estate":
		// "Loose Ends"
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_1" );
		// Day 6 - [{FAKE_INTRO_TIME:15:36:07}]
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_2" );
		// Sgt. Gary Roach" Sanderson"
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_4" );
		// Georgian-Russian Border
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "boneyard":
		// "The Enemy of My Enemy"
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_1" );
		// Day 6 - [{FAKE_INTRO_TIME:16:03:21}]
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_2" );
		// Cpt. 'Soap' MacTavish
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_3" );
		// 160 miles SW of Kandahar, Afghanistan
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_4" );
		// U.S. Ordnance and Vehicle Disposal Yard 437
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;

	case "af_caves":
		// "Just Like Old Times"
		PreCacheString( &"AF_CAVES_LINE1" ); // "Just Like Old Times"
		// Day 7 - 16:40:[{FAKE_INTRO_SECONDS:22}]
		PreCacheString( &"AF_CAVES_LINE2" ); // Day 7 – 16:40:xx
		// 'Soap' MacTavish
		PreCacheString( &"AF_CAVES_LINE3" ); // 'Soap' MacTavish
		// Site Hotel Bravo, Afghanistan
		PreCacheString( &"AF_CAVES_LINE4" ); // Site Hotel Bravo, Afghanistan
		introscreen_delay();
		break;
	
	case "af_chase":
		// "You Can't Win A War With A Bullet"
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE1" ); 
		// Day 7 - 18:10:[{FAKE_INTRO_SECONDS:22}]
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE2" ); 
		// 'Soap' MacTavish
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE3" ); 
		// Site Hotel Bravo, Afghanistan
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE4" ); 
		//introscreen_delay();
		break;	
	
	case "example":
		/*
		PreCacheString(&"INTROSCREEN_EXAMPLE_TITLE");
		PreCacheString(&"INTROSCREEN_EXAMPLE_PLACE");
		PreCacheString(&"INTROSCREEN_EXAMPLE_DATE");
		PreCacheString(&"INTROSCREEN_EXAMPLE_INFO");
		introscreen_delay(&"INTROSCREEN_EXAMPLE_TITLE", &"INTROSCREEN_EXAMPLE_PLACE", &"INTROSCREEN_EXAMPLE_DATE", &"INTROSCREEN_EXAMPLE_INFO");
		*/
		break;


	case "bridge":
		thread flying_intro();
		break;
	default:
		// Shouldn't do a notify without a wait statement before it, or bad things can happen when loading a save game.
		wait 0.05;
		level notify( "finished final intro screen fadein" );
		wait 0.05;
		level notify( "starting final intro screen fadeout" );
		wait 0.05;
		level notify( "controls_active" );// Notify when player controls have been restored
		wait 0.05;
		flag_set( "introscreen_complete" );// Do final notify when player controls have been restored
		break;
	}
}


contingency_black_screen_intro()
{
	SetSavedDvar( "hud_drawhud", "0" );
	level.player FreezeControls( true );

	//thread maps\_introscreen::introscreen_generic_black_fade_in( 3.5, 1 );
	thread maps\_introscreen::introscreen_generic_black_fade_in( 5.3, 1 );

	lines = [];
	// Contingency""
	lines[ lines.size ] = &"CONTINGENCY_LINE1";
	// Day 4 - 16:35:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ]     = &"CONTINGENCY_LINE2";
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"CONTINGENCY_LINE3";
	// Task Force 141
	lines[ lines.size ] = &"CONTINGENCY_LINE4";
	// Eastern Russia
	lines[ lines.size ] = &"CONTINGENCY_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );

	wait 5;

	level.player FreezeControls( false );
	setSavedDvar( "hud_drawhud", "1" );
}

contingency_intro_text()
{
	wait .2;

	lines = [];
	// Contingency""
	lines[ lines.size ] = &"CONTINGENCY_LINE1";
	// Day 4 - 16:35:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ]     = &"CONTINGENCY_LINE2";
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"CONTINGENCY_LINE3";
	// Task Force 141
	lines[ lines.size ] = &"CONTINGENCY_LINE4";
	// Eastern Russia
	lines[ lines.size ] = &"CONTINGENCY_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );
}



cliffhanger_intro_text()
{
	wait 17;

	lines = [];
	// Cliffhanger""
	lines[ lines.size ] = &"CLIFFHANGER_LINE1";
	// Day 2 - 7:35:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ]     = &"CLIFFHANGER_LINE2";
	// Sgt. Gary Roach" Sanderson"
	lines[ lines.size ] = &"CLIFFHANGER_LINE3";
	// Task Force 141
	lines[ lines.size ] = &"CLIFFHANGER_LINE4";
	// Tian Shan Range, Kazakhstan
	lines[ lines.size ] = &"CLIFFHANGER_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );
}


introscreen_feed_lines( lines )
{
	keys = GetArrayKeys( lines );

	for ( i = 0; i < keys.size; i++ )
	{
		key = keys[ i ];
		interval = 1;
		time = ( i * interval ) + 1;
		delayThread( time, ::introscreen_corner_line, lines[ key ], ( lines.size - i - 1 ), interval, key );
	}
}

introscreen_generic_black_fade_in( time, fade_time, fade_in_time )
{
	introscreen_generic_fade_in( "black", time, fade_time, fade_in_time );
}

introscreen_generic_white_fade_in( time, fade_time, fade_in_time )
{
	introscreen_generic_fade_in( "white", time, fade_time, fade_in_time );
}

introscreen_generic_fade_in( shader, pause_time, fade_out_time, fade_in_time )
{
	if ( !isdefined( fade_out_time ) )
		fade_out_time = 1.5;

	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( shader, 640, 480 );

	if ( IsDefined( fade_in_time ) && fade_in_time > 0 )
	{
		introblack.alpha = 0;
		introblack FadeOverTime( fade_in_time );
		introblack.alpha = 1;
		wait( fade_in_time );
	}

	wait pause_time;

	// Fade out black
	if ( fade_out_time > 0 )
		introblack FadeOverTime( fade_out_time );

	introblack.alpha = 0;
	
	wait fade_out_time;
	SetSavedDvar( "com_cinematicEndInWhite", 0 );
}

introscreen_create_line( string )
{
	index = level.introstring.size;
	yPos = ( index * 30 );

	if ( level.console )
		yPos -= 60;

	level.introstring[ index ] = NewHudElem();
	level.introstring[ index ].x = 0;
	level.introstring[ index ].y = yPos;
	level.introstring[ index ].alignX = "center";
	level.introstring[ index ].alignY = "middle";
	level.introstring[ index ].horzAlign = "center";
	level.introstring[ index ].vertAlign = "middle";
	level.introstring[ index ].sort = 1;// force to draw after the background
	level.introstring[ index ].foreground = true;
	level.introstring[ index ].fontScale = 1.75;
	level.introstring[ index ] SetText( string );
	level.introstring[ index ].alpha = 0;
	level.introstring[ index ] FadeOverTime( 1.2 );
	level.introstring[ index ].alpha = 1;
}

introscreen_fadeOutText()
{
	for ( i = 0; i < level.introstring.size; i++ )
	{
		level.introstring[ i ] FadeOverTime( 1.5 );
		level.introstring[ i ].alpha = 0;
	}

	wait 1.5;

	for ( i = 0; i < level.introstring.size; i++ )
		level.introstring[ i ] Destroy();

}

introscreen_delay( string1, string2, string3, string4, pausetime1, pausetime2, timebeforefade )
{
	//Chaotically wait until the frame ends twice because handle_starts waits for one frame end so that script gets to init vars
	//and this needs to wait for handle_starts to finish so that the level.start_point gets set.
	waittillframeend;
	waittillframeend;

	/#
	skipIntro = !is_default_start();
	if ( GetDebugDvar( "introscreen" ) == "0" )
		skipIntro = true;

	if ( skipIntro )
	{
		waittillframeend;
		level notify( "finished final intro screen fadein" );
		waittillframeend;
		level notify( "starting final intro screen fadeout" );
		waittillframeend;
		level notify( "controls_active" );// Notify when player controls have been restored
		waittillframeend;
		flag_set( "introscreen_complete" );// Do final notify when player controls have been restored
		flag_set( "pullup_weapon" );
		return;
	}
	#/

	if ( flying_intro() )
	{
		return;
	}
	
	switch ( level.script )
	{
		case "airport":
			airport_intro();
			return;
		case "favela":
			favela_intro();
			return;
		case "favela_escape":
			favela_escape_intro();
			return;
		case "arcadia":
			arcadia_intro();
			return;
		case "oilrig":
			oilrig_intro();
			return;
		case "dcburning":
			dcburning_intro();
			return;
		case "trainer":
			trainer_intro();
			return;
		case "dcemp":
			dcemp_intro();
			return;
		case "dc_whitehouse":
			dc_whitehouse_intro();
			return;
		case "gulag":
			flag_set( "introscreen_complete" );// Notify when complete
			return;
		case "af_caves":
			af_caves_intro();
			return;
		case "roadkill":
			return;
	}

	level.introblack = NewHudElem();
	level.introblack.x = 0;
	level.introblack.y = 0;
	level.introblack.horzAlign = "fullscreen";
	level.introblack.vertAlign = "fullscreen";
	level.introblack.foreground = true;
	level.introblack SetShader( "black", 640, 480 );

	level.player FreezeControls( true );
	wait .05;

	level.introstring = [];

	//Title of level

	if ( IsDefined( string1 ) )
		introscreen_create_line( string1 );

	if ( IsDefined( pausetime1 ) )
	{
		wait pausetime1;
	}
	else
	{
		wait 2;
	}

	//City, Country, Date

	if ( IsDefined( string2 ) )
		introscreen_create_line( string2 );
	if ( IsDefined( string3 ) )
		introscreen_create_line( string3 );

	//Optional Detailed Statement

	if ( IsDefined( string4 ) )
	{
		if ( IsDefined( pausetime2 ) )
		{
			wait pausetime2;
		}
		else
		{
			wait 2;
		}
	}

	if ( IsDefined( string4 ) )
		introscreen_create_line( string4 );

	//if(isdefined(string5))
		//introscreen_create_line(string5);

	level notify( "finished final intro screen fadein" );

	if ( IsDefined( timebeforefade ) )
	{
		wait timebeforefade;
	}
	else
	{
		wait 3;
	}

	// Fade out black
	level.introblack FadeOverTime( 1.5 );
	level.introblack.alpha = 0;

	level notify( "starting final intro screen fadeout" );

	// Restore player controls part way through the fade in
	level.player FreezeControls( false );
	level notify( "controls_active" );// Notify when player controls have been restored

	// Fade out text
	introscreen_fadeOutText();

	flag_set( "introscreen_complete" );// Notify when complete
}

_CornerLineThread( string, size, interval, index_key )
{
	level notify( "new_introscreen_element" );

	if ( !isdefined( level.intro_offset ) )
		level.intro_offset = 0;
	else
		level.intro_offset++;

	y = _CornerLineThread_height();

	hudelem = NewHudElem();
	hudelem.x = 20;
	hudelem.y = y;
	hudelem.alignX = "left";
	hudelem.alignY = "bottom";
	hudelem.horzAlign = "left";
	hudelem.vertAlign = "bottom";
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem SetText( string );
	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.2 );
	hudelem.alpha = 1;

	hudelem.hidewheninmenu = true;
	hudelem.fontScale = 2.0;// was 1.6 and 2.4, larger font change
	hudelem.color = ( 0.8, 1.0, 0.8 );
	hudelem.font = "objective";
	hudelem.glowColor = ( 0.3, 0.6, 0.3 );
	hudelem.glowAlpha = 1;
	duration = Int( ( size * interval * 1000 ) + 4000 );
	hudelem SetPulseFX( 30, duration, 700 );// something, decay start, decay duration

	thread hudelem_destroy( hudelem );

	if ( !isdefined( index_key ) )
		return;
	if ( !isstring( index_key ) )
		return;
	if ( index_key != "date" )
		return;
}


_CornerLineThread_height()
{
	//return ( ( ( pos ) * 19 ) - 10 );
	return( ( ( level.intro_offset ) * 20 ) - 82 );// was 19 and 22 larger font change
}

introscreen_corner_line( string, size, interval, index_key )
{
	thread _CornerLineThread( string, size, interval, index_key );
}


hudelem_destroy( hudelem )
{
	wait( level.linefeed_delay );
	hudelem notify( "destroying" );
	level.intro_offset = undefined;

	time = .5;
	hudelem FadeOverTime( time );
	hudelem.alpha = 0;
	wait time;
	hudelem notify( "destroy" );
	hudelem Destroy();
}


cargoship_intro_dvars()
{
	wait( 0.05 );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "hud_drawhud", "0" );
}

favela_intro()
{
	level.player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
			// 'Takedown'
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_1";		// 'Takedown'
			// Day 4 - 14:30:[{FAKE_INTRO_SECONDS:16}]
	lines[ "date" ]     = &"FAVELA_INTROSCREEN_LINE_2";		// Day 4 - 14:30:[ {FAKE_INTRO_SECONDS:16} ]
			// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_3";		// Sgt. Gary 'Roach' Sanderson
			// Task Force 141
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_4";		// Task Force 141
			// Rio de Janeiro, Brazil
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_5";		// Rio de Janeiro, Brazil

	introscreen_feed_lines( lines );

	wait( 5.0 );
	level notify( "introscreen_complete" );

	level.player FreezeControls( false );
}

favela_escape_intro()
{
	level.player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	blacktime = 6;
	thread introscreen_generic_black_fade_in( blacktime );
	thread flag_set_delayed( "introscreen_start_dialogue", 1.0 );

	lines = [];
	// 'The Hornet's Nest'
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_1";// 'The Hornet's Nest'
			// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
	lines[ "date" ]		 = &"FAVELA_ESCAPE_INTROSCREEN_LINE_2";// Day 4 - 04:19:[ {FAKE_INTRO_SECONDS:40} ]
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_3";// Sgt. Gary 'Roach' Sanderson
	// Task Force 141
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_4";// Task Force 141
	// Rio de Janeiro, 1700 F.S.L.
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_5";// Rio de Janeiro, 7000 F.S.L.

	introscreen_feed_lines( lines );

	wait( blacktime );
	level notify( "introscreen_complete" );

	level.player FreezeControls( false );
}

arcadia_intro()
{
	level.player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
		// 'Exodus'
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_1";	// 'Contraflow'
		// Day 04 - 17:36:[{FAKE_INTRO_SECONDS:28}]
	lines[ "date" ]     = &"ARCADIA_INTROSCREEN_LINE_2";	// DC Invasion D + 1 - 15:22:[ {FAKE_INTRO_SECONDS:02} ]
		// Pvt. James Ramirez
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_3";	// PFC James Patterson
		// 1st Bn., 75th Ranger Regiment
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_4";	// U.S. Army 3rd Infantry Regiment
		// Northeastern Virginia, U.S.A.
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_5";	// Washington DC Suburbs

	introscreen_feed_lines( lines );

	wait( 5.0 );
	level notify( "introscreen_complete" );

	level.player FreezeControls( false );
}

boneyard_intro()
{
	lines = [];
			// 'The Enemy of My Enemy'
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_1";		// "The Enemy Of My Enemy"
					// Day 6 - 17:30:[{FAKE_INTRO_SECONDS:21}]
	lines[ "date" ] 	 = 	 &"BONEYARD_INTROSCREEN_LINE_2";	// Day 6 - 17:30:[ {FAKE_INTRO_SECONDS:41} ]
			// Cpt. 'Soap' MacTavish
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_3";		// Cpt. 'Soap' MacTavish
			// 160 miles SW of Kandahar, Afghanistan
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_4";		// 160 miles SW of Kandahar, Afghanistan
			// U.S. Vehicle Disposal Yard 437
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_5";		// U.S. Vehicle Disposal Yard 437

	introscreen_feed_lines( lines );

	level notify( "introscreen_complete" );
}

estate_intro()
{
	lines = [];
			// 'Loose Ends'
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";		// 'Loose Ends'
				// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
	lines[ "date" ] 	 = 	 &"ESTATE_INTROSCREEN_LINE_2";	// Day 6 - 14:30:[ {FAKE_INTRO_SECONDS:07} ]
			// Sgt. Gary Roach" Sanderson"
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";		// Sgt. Gary 'Roach' Sanderson
			// Task Force 141
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";		// Task Force 141
			// Georgian-Russian Border
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";		// Georgian - Russian Border

	introscreen_feed_lines( lines );

	level notify( "introscreen_complete" );
}

airport_intro()
{
	level.player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );
	
	time = 21 + 5.5;
//	thread introscreen_generic_black_fade_in( time );

	lines = [];

	// No Russian""
	lines[ lines.size ] = &"AIRPORT_LINE1";
		// Day 3, 08:40:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ] 	 = &"AIRPORT_LINE2";
	// PFC Joseph Allen a.k.a. Alexei Borodin
	lines[ lines.size ] = &"AIRPORT_LINE3";
	// Terminal 3, Domodedovo Int'l Airport
	lines[ lines.size ] = &"AIRPORT_LINE4";
	// Moscow, Russia
	lines[ lines.size ] = &"AIRPORT_LINE5";

	delayThread( 10.25 + 5.5, ::introscreen_feed_lines, lines );

	wait( time );

	wait 1;

	if ( !flag( "do_not_save" ) )
		thread autosave_now_silent();

	level notify( "introscreen_complete" );

	level.player FreezeControls( false );
}

oilrig_intro_dvars()
{
	//wait( 0.05 );
	SetSavedDvar( "ui_hidemap", 1 );
	SetSavedDvar( "hud_showStance", "0" );
	SetSavedDvar( "compass", "0" );
	//SetDvar( "old_compass", "0" );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "g_friendlyNameDist", 0 );
	//SetSavedDvar( "hud_showTextNoAmmo", "0" ); 
}

oilrig_intro()
{
	if ( !level.underwater )
		return;
	thread oilrig_intro_dvars();
	level.player FreezeControls( true );
	flag_wait( "open_dds_door" );
	wait( 2 );
	level.player FreezeControls( false );
}

oilrig_intro2()
{
	lines = [];

	// The Only Easy Day...Was Yesterday
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_1";
	// LANG_ENGLISH         Day 3 - [{FAKE_INTRO_TIME:06:58:21}] hrs"
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_2";
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_3";
	// Task Force 141
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_4";
	// Vikhorevka 36 Oil Platform
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_5";

	introscreen_feed_lines( lines );
}

char_museum_intro()
{
	lines = [];
	
	lines[ lines.size ] = &"CHAR_MUSEUM_LINE1";
	
	lines[ lines.size ] = &"CHAR_MUSEUM_LINE3";
	
	lines[ lines.size ] = &"CHAR_MUSEUM_LINE4";
	
	introscreen_feed_lines( lines );
}

estate_intro2()
{
	lines = [];

		// 'Loose Ends'
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";	// "'Loose Ends'"
			// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
	lines[ "date" ] 	 = &"ESTATE_INTROSCREEN_LINE_2";	// "Day 06 – 14:05:[{FAKE_INTRO_SECONDS:07}]"
		// Sgt. Gary Roach" Sanderson"
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";	// "Sgt. Gary 'Roach' Sanderson"
		// Task Force 141
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";	// "Task Force 141"
		// Georgian-Russian Border
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";	// "Georgian-Russian Border"

	introscreen_feed_lines( lines );
}


dcburning_intro()
{
	level.player DisableWeapons();
	thread dcburningIntroDvars();
	level.mortar_min_dist = 1;
	level.player FreezeControls( true );

	//cinematicingamesync( "scoutsniper_fade" );

	// Start
	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( "black", 640, 480 );
	wait 4.25;

//	introtime = NewHudElem();
//	introtime.x = 0;
//	introtime.y = 0;
//	introtime.alignX = "center";
//	introtime.alignY = "middle";
//	introtime.horzAlign = "center";
//	introtime.vertAlign = "middle";
//	introtime.sort = 1;
//	introtime.foreground = true;
	// 
//	introtime SetText( &"DCBURNING_MAIN_TITLE" );
//	introtime.fontScale = 1.6;
//	introtime.color = ( 0.8, 1.0, 0.8 );
//	introtime.font = "objective";
//	introtime.glowColor = ( 0.3, 0.6, 0.3 );
//	introtime.glowAlpha = 1;
//	introtime SetPulseFX( 30, 2000, 700 );// something, decay start, decay duration

	wait 3;

	// Fade out black

	level notify( "black_fading" );
	level.mortar_min_dist = undefined;
	introblack FadeOverTime( 1.5 );
	introblack.alpha = 0;

	wait( 1.5 );
	flag_set( "introscreen_complete" );
	 // Do final notify when player controls have been restored	
	level notify( "introscreen_complete" );
	level.player FreezeControls( false );
	level.player EnableWeapons();
	wait( .5 );

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "hud_showStance", 1 );

	flag_wait( "player_exiting_start_trench" );


	lines = [];
	// 'Of Their Own Accord'
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_1";
	// LANG_ENGLISH         Day 5 - [{FAKE_INTRO_TIME:18:12:09}] hrs"
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_2";
	// Pvt. James Ramirez
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_3";
	// 75th Ranger Regiment
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_4";
	// Washington, D.C.
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_5";

	introscreen_feed_lines( lines );
}

dcemp_intro()
{
	flag_wait( "player_crash_done" );

	lines = [];
	// 'Second Sun'
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_1";
	// Day 5, 19:02:[{FAKE_INTRO_SECONDS:38}] hrs
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_2";
	// Pvt. James Ramirez
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_3";
	// 75th Ranger Regiment
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_4";
	// Washington, D.C.
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_5";

	wait 1;
	maps\_introscreen::introscreen_feed_lines( lines );

	flag_set( "introscreen_complete" );
}

dc_whitehouse_intro()
{
	level.player DisableWeapons();
	level.player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
	// 'Whiskey Hotel'
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_1";
	// Day 5, 19:31:[{FAKE_INTRO_SECONDS:22}] hrs
	lines[ "date" ]     = &"DC_WHITEHOUSE_INTROSCREEN_2";
	// Pvt. James Ramirez
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_3";
	// 75th Ranger Regiment
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_4";
	// Washington, D.C.
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_5";

	introscreen_feed_lines( lines );

	wait( 5.0 );
	level notify( "introscreen_complete" );

	level.player FreezeControls( false );
	level.player EnableWeapons();
}

dcburningIntroDvars()
{
	wait( 0.05 );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
}



trainerIntroDvars()
{
	//wait( 0.05 );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
}

trainer_intro()
{
	thread trainerIntroDvars();
	level.player FreezeControls( true );
	// Start
	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( "black", 640, 480 );
	lines = [];
	// "S.S.D.D."
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_1";
	// Day 1 - 15:30:[{FAKE_INTRO_SECONDS:25}]
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_2";
	// PFC Joseph Allen
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_3";
	// 1st Bn., 75th Ranger Regiment
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_4";
	// Fire Base Phoenix, Afghanistan
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_5";

	introscreen_feed_lines( lines );

	wait( 10 );
	// Fade out black
	level notify( "black_fading" );
	introblack FadeOverTime( 2 );
	introblack.alpha = 0;
	flag_set( "start_anims" );
	wait( 2 );
	flag_set( "introscreen_complete" );
	 // Do final notify when player controls have been restored	
	level notify( "introscreen_complete" );
	level.player FreezeControls( false );
	wait( .5 );

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "hud_showStance", 1 );

}

af_caves_intro()
{
	SetSavedDvar( "compass", 0 );
	
	level.introblack = NewHudElem();
	level.introblack.x = 0;
	level.introblack.y = 0;
	level.introblack.horzAlign = "fullscreen";
	level.introblack.vertAlign = "fullscreen";
	level.introblack.foreground = false;
	level.introblack SetShader( "black", 640, 480 );

	wait( 0.05 );
	
	flag_set( "intro_dialogue_start" );

	flag_wait( "intro_fade_in" );

	fadeTime = 3;
	level.introblack FadeOverTime( fadeTime );
	level.introblack.alpha = 0;
	wait( fadeTime );
	level.introblack Destroy();
	
	SetSavedDvar( "compass", 1 );

	flag_set( "intro_faded_in" );

	thread autosave_by_name( "intro" );
	
	flag_wait( "introscreen_feed_lines" );
	
	lines = [];
	// Just Like Old Times""
	lines[ lines.size ] = &"AF_CAVES_LINE1";// "Just Like Old Times"
	// Day 7 - 16:40:[{FAKE_INTRO_SECONDS:22}]
	lines[ "date" ]     = &"AF_CAVES_LINE2";// Day 7 – 16:40:
	// 'Soap' MacTavish
	lines[ lines.size ] = &"AF_CAVES_LINE3";// 'Soap' MacTavish
	// Site Hotel Bravo, Afghanistan
	lines[ lines.size ] = &"AF_CAVES_LINE4";// Site Hotel Bravo, Afghanistan

	level thread maps\_introscreen::introscreen_feed_lines( lines );
}

af_chase_intro()
{
	lines = [];
	
	// "You Can't Win A War With A Bullet"
	lines[ lines.size ] = &"AF_CHASE_INTROSCREEN_LINE1";
	// Day 7 - 18:10:[{FAKE_INTRO_SECONDS:22}]
	lines[ "date" ]     = &"AF_CHASE_INTROSCREEN_LINE2";
	// 'Soap' MacTavish
	lines[ lines.size ] = &"AF_CHASE_INTROSCREEN_LINE3";
	// Site Hotel Bravo, Afghanistan
	lines[ lines.size ] = &"AF_CHASE_INTROSCREEN_LINE4";

	introscreen_feed_lines( lines );

	thread autosave_by_name( "intro" );
}

bog_intro_sound()
{
	wait( 0.05 );
	//level.player PlaySound( "ui_camera_whoosh_in" );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showstance", "0" );
	SetSavedDvar( "actionSlotsHide", "1" );
}

feedline_delay()
{
	wait( 2 );
}

flying_intro()
{
	flying_levels = [];
	flying_levels[ "killhouse" ] = true;
	flying_levels[ "cliffhanger" ] = true;
	//flying_levels[ "favela_escape" ] = true;
	flying_levels[ "estate" ] = true;
	
	if ( !getdvarint( "newintro" ) )
		flying_levels[ "roadkill" ] = true;
		
	flying_levels[ "boneyard" ] = true;

	override_angles = IsDefined( level.customIntroAngles );

	if ( !isdefined( flying_levels[ level.script ] ) )
		return false;

	if ( !isdefined( level.dontReviveHud ) )
		thread revive_ammo_counter();


	thread bog_intro_sound();
	thread weapon_pullout();

	level.player FreezeControls( true );
	feedline_delay_func = ::feedline_delay;

	zoomHeight = 16000;
	slamzoom = true;
	/#
	if ( GetDvar( "slamzoom" ) != "" )
		slamzoom = false;
	#/

	extra_delay = 0;
	special_save = false;

	if ( slamzoom )
	{
		lines = [];
		switch( level.script )
		{
			case "killhouse":
				special_save = true;
				//thread introscreen_generic_black_fade_in( 0.7, 0.20 );
				CinematicInGameSync( "killhouse_fade" );
				lines = [];
				// string not found for KILLHOUSE_INTROSCREEN_LINE_1
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_1";
					// string not found for KILLHOUSE_INTROSCREEN_LINE_2
			//	lines[ "date" ] 	= &"KILLHOUSE_INTROSCREEN_LINE_2";
				// string not found for KILLHOUSE_INTROSCREEN_LINE_3
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_3";
				// string not found for KILLHOUSE_INTROSCREEN_LINE_4
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_4";
				// string not found for KILLHOUSE_INTROSCREEN_LINE_5
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_5";
				break;

			case "estate":
				//thread introscreen_generic_black_fade_in( 0.05 );
				cinematicingamesync( "estate_fade" );
				lines = [];
				// 'Loose Ends'
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";
				// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_2";
				// Sgt. Gary Roach" Sanderson"
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";
				// Task Force 141
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";
				// Georgian-Russian Border
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";
				zoomHeight = 3500;// 2632
				SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );// air
				delayThread( 0.5, ::ramp_out_sunsample_over_time, 0.9 );
				break;

			case "boneyard":
				// thread introscreen_generic_black_fade_in( 0.05 );
				cinematicingamesync( "boneyard_fade" );
				lines = [];
				SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );// air
				delayThread( 0.5, ::ramp_out_sunsample_over_time, 0.9 );
				zoomHeight = 4000;
				break;

			case "roadkill":
				thread introscreen_generic_black_fade_in( 0.05 );
				lines = [];
				// Team Player
				lines[ lines.size ] = &"ROADKILL_LINE_1";
				// Day 1 - 16:08:[{FAKE_INTRO_SECONDS:07}]
				lines[ lines.size ] = &"ROADKILL_LINE_2";
				// PFC Joseph Allen
				lines[ lines.size ] = &"ROADKILL_LINE_3";
				// 3rd Bn, 75th Ranger Regiment
				lines[ lines.size ] = &"ROADKILL_LINE_4";
				// The Red Zone, Afghanistan
				lines[ lines.size ] = &"ROADKILL_LINE_5";
				feedline_delay = 21;

				feedline_delay_func = level.roadkill_feedline_delay;
				SetSavedDvar( "sm_sunSampleSizeNear", 2.0 );// air
				delayThread( 0.6, ::ramp_out_sunsample_over_time, 1.4 );
				break;
		}

		add_func( feedline_delay_func );
		add_func( ::introscreen_feed_lines, lines );
		thread do_funcs();
	}

	origin = level.player.origin;

	level.player PlayerSetStreamOrigin( origin );

	level.player.origin = origin + ( 0, 0, zoomHeight );
	ent = Spawn( "script_model", ( 69, 69, 69 ) );
	ent.origin = level.player.origin;

	ent SetModel( "tag_origin" );

	if ( override_angles )
	{
		ent.angles = ( 0, level.customIntroAngles[ 1 ], 0 );
	}
	else
	{
		ent.angles = level.player.angles;
	}

	level.player PlayerLinkTo( ent, undefined, 1, 0, 0, 0, 0 );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], 0 );

	wait( extra_delay );
	ent MoveTo( origin + ( 0, 0, 0 ), 2, 0, 2 );

	wait( 1.00 );
	wait( 0.5 );

	if ( override_angles )
	{
		ent RotateTo( level.customIntroAngles, 0.5, 0.3, 0.2 );
	}
	else
	{
		ent RotateTo( ( ent.angles[ 0 ] - 89, ent.angles[ 1 ], 0 ), 0.5, 0.3, 0.2 );
	}

	if ( !special_save )
		// string not found for AUTOSAVE_LEVELSTART
		SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );
	wait( 0.5 );
	flag_set( "pullup_weapon" );

	wait( 0.2 );
	level.player Unlink();
	level.player FreezeControls( false );

	level.player PlayerClearStreamOrigin();

	thread play_sound_in_space( "ui_screen_trans_in", level.player.origin );

	wait( 0.2 );

	thread play_sound_in_space( "ui_screen_trans_out", level.player.origin );

	wait( 0.2 );

	// Do final notify when player controls have been restored
	flag_set( "introscreen_complete" );

	wait( 2 );

	ent Delete();

	return true;
}

weapon_pullout()
{
	weap = level.player GetWeaponsListAll()[ 0 ];
    level.player DisableWeapons();
	flag_wait( "pullup_weapon" );
    level.player EnableWeapons();
//	level.player SwitchToWeapon( weap );
}

revive_ammo_counter()
{
	flag_wait( "safe_for_objectives" );
	if ( !isdefined( level.nocompass ) )
		SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
	SetSavedDvar( "hud_showstance", "1" );
}

ramp_out_sunsample_over_time( time, base_sample_size )
{
	sample_size = GetDvarFloat( "sm_sunSampleSizeNear" );
	if ( !isdefined( base_sample_size ) )
		base_sample_size = 0.25;

	range = sample_size - base_sample_size;// min sample size is 0.25

	frames = time * 20;
	for ( i = 0; i <= frames; i++ )
	{
		dif = i / frames;
		dif = 1 - dif;
		current_range = dif * range;
		current_sample_size = base_sample_size + current_range;
		SetSavedDvar( "sm_sunSampleSizeNear", current_sample_size );
		wait( 0.05 );
	}
}
