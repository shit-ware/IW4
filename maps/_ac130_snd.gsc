#include maps\_utility;
main()
{
	//-------------------------------------------------------------------------------------------------

	// 1 ) Check your fire, you're shootin' at friendlies - watch for the blinking strobes those are our guys!
	// 2 ) Uh, you're firing too close to the friendlies, I repeat, you're firing too close to the friendlies. Watch for those IR strobes.
	// 3 ) Be careful! You almost killed our guys there!
	level.scr_sound[ "fco" ][ "ac130_fco_firingtoclose" ] 		 = "ac130_fco_firingtoclose";

	//-------------------------------------------------------------------------------------------------

	//CONTEXT SENSATIVE DIALOG
	//-------------------------------------------------------------------------------------------------
	
	add_context_sensative_dialog( "ai", "in_sight", 0, "ac130_fco_moreenemy" );			// More enemy personnel.
	add_context_sensative_dialog( "ai", "in_sight", 1, "ac130_fco_getthatguy" );		// Get that guy.
	add_context_sensative_dialog( "ai", "in_sight", 2, "ac130_fco_guymovin" );			// Roger, guy movin'.
	add_context_sensative_dialog( "ai", "in_sight", 3, "ac130_fco_getperson" );			// Get that person.
	add_context_sensative_dialog( "ai", "in_sight", 4, "ac130_fco_guyrunnin" );			// Guy runnin'.
	add_context_sensative_dialog( "ai", "in_sight", 5, "ac130_fco_gotarunner" );		// Uh, we got a runner here.
	add_context_sensative_dialog( "ai", "in_sight", 6, "ac130_fco_backonthose" );		// Get back on those guys.
	add_context_sensative_dialog( "ai", "in_sight", 7, "ac130_fco_gonnagethim" );		// You gonna get him?
	add_context_sensative_dialog( "ai", "in_sight", 8, "ac130_fco_personnelthere" );	// Personnel right there.
	add_context_sensative_dialog( "ai", "in_sight", 9, "ac130_fco_nailthoseguys" );		// Nail those guys.
	add_context_sensative_dialog( "ai", "in_sight", 10, "ac130_fco_clearedtoengage" );	// Cleared to engage enemy personnel.
	add_context_sensative_dialog( "ai", "in_sight", 11, "ac130_fco_lightemup" );		// Light ‘em up.
	add_context_sensative_dialog( "ai", "in_sight", 12, "ac130_fco_takehimout" );		// Yeah take him out.
	add_context_sensative_dialog( "ai", "in_sight", 13, "ac130_plt_clearedtoengage" );	// Cleared to engage all of those.
	add_context_sensative_dialog( "ai", "in_sight", 14, "ac130_plt_yeahcleared" );		// Yeah, cleared to engage.
	add_context_sensative_dialog( "ai", "in_sight", 15, "ac130_plt_copysmoke" );		// Copy, smoke ‘em.
	add_context_sensative_dialog( "ai", "in_sight", 16, "ac130_fco_rightthere" );		// Right there...tracking.
	add_context_sensative_dialog( "ai", "in_sight", 17, "ac130_fco_tracking" );			// Tracking.

	add_context_sensative_dialog( "ai", "wounded_crawl", 0, "ac130_fco_movingagain" );		// Ok he’s moving again.
	add_context_sensative_timeout( "ai", "wounded_crawl", undefined, 6 );

	add_context_sensative_dialog( "ai", "wounded_pain", 0, "ac130_fco_doveonground" );		// Yeah, he just dove on the ground.
	add_context_sensative_dialog( "ai", "wounded_pain", 1, "ac130_fco_knockedwind" );		// Probably just knocked the wind out of him.
	add_context_sensative_dialog( "ai", "wounded_pain", 2, "ac130_fco_downstillmoving" );	// That guy's down but still moving.
	add_context_sensative_dialog( "ai", "wounded_pain", 3, "ac130_fco_gettinbackup" );		// He's gettin' back up.
	add_context_sensative_dialog( "ai", "wounded_pain", 4, "ac130_fco_yepstillmoving" );	// Yep, that guy’s still moving.
	add_context_sensative_dialog( "ai", "wounded_pain", 5, "ac130_fco_stillmoving" );		// He's still moving.
	add_context_sensative_timeout( "ai", "wounded_pain", undefined, 12 );

	add_context_sensative_dialog( "weapons", "105mm_ready", 0, "ac130_gnr_gunready1" );

	add_context_sensative_dialog( "weapons", "105mm_fired", 0, "ac130_gnr_shot1" );

	add_context_sensative_dialog( "plane", "rolling_in", 0, "ac130_plt_rollinin" );

	add_context_sensative_dialog( "explosion", "secondary", 0, "ac130_nav_secondaries1" );
	add_context_sensative_dialog( "explosion", "secondary", 1, "ac130_tvo_directsecondary1" );
	add_context_sensative_dialog( "explosion", "secondary", 1, "ac130_tvo_directsecondary2" );
	add_context_sensative_timeout( "explosion", "secondary", undefined, 7 );

	add_context_sensative_dialog( "kill", "single", 0, "ac130_plt_gottahurt" );			// Ooo that's gotta hurt.
	add_context_sensative_dialog( "kill", "single", 1, "ac130_fco_iseepieces" );		// Yeah, good kill. I see lots of little pieces down there.
	add_context_sensative_dialog( "kill", "single", 2, "ac130_fco_oopsiedaisy" );		// ( chuckling ) Oopsie - daisy.
	add_context_sensative_dialog( "kill", "single", 3, "ac130_fco_goodkill" );			// Good kill good kill.
	add_context_sensative_dialog( "kill", "single", 4, "ac130_fco_yougothim" );			// You got him.
	add_context_sensative_dialog( "kill", "single", 5, "ac130_fco_yougothim2" );		// You got him!
	add_context_sensative_dialog( "kill", "single", 6, "ac130_fco_thatsahit" );			// That's a hit.
	add_context_sensative_dialog( "kill", "single", 7, "ac130_fco_directhit" );			// Direct hit.
	add_context_sensative_dialog( "kill", "single", 8, "ac130_fco_rightontarget" );		// Yep, that was right on target.
	add_context_sensative_dialog( "kill", "single", 9, "ac130_fco_okyougothim" );		// Ok, you got him. Get back on the other guys.
	add_context_sensative_dialog( "kill", "single", 10, "ac130_fco_within2feet" );		// All right you got the guy. That might have been within two feet of him.

	add_context_sensative_dialog( "kill", "small_group", 0, "ac130_fco_nice" );			// ( chuckling ) Niiiice.
	add_context_sensative_dialog( "kill", "small_group", 1, "ac130_fco_directhits" );	// Yeah, direct hits right there.
	add_context_sensative_dialog( "kill", "small_group", 2, "ac130_fco_iseepieces" );	// Yeah, good kill. I see lots of little pieces down there.
	add_context_sensative_dialog( "kill", "small_group", 3, "ac130_fco_goodkill" );		// Good kill good kill.
	add_context_sensative_dialog( "kill", "small_group", 4, "ac130_fco_yougothim" );	// You got him.
	add_context_sensative_dialog( "kill", "small_group", 5, "ac130_fco_yougothim2" );	// You got him!
	add_context_sensative_dialog( "kill", "small_group", 6, "ac130_fco_thatsahit" );	// That's a hit.
	add_context_sensative_dialog( "kill", "small_group", 7, "ac130_fco_directhit" );	// Direct hit.
	add_context_sensative_dialog( "kill", "small_group", 8, "ac130_fco_rightontarget" );// Yep, that was right on target.
	add_context_sensative_dialog( "kill", "small_group", 9, "ac130_fco_okyougothim" );	// Ok, you got him. Get back on the other guys.

	add_context_sensative_dialog( "kill", "large_group", 0, "ac130_fco_hotdamn1" );		// Hot damn!
	add_context_sensative_dialog( "kill", "large_group", 0, "ac130_fco_hotdamn2" );		// Hot damn!
	add_context_sensative_dialog( "kill", "large_group", 0, "ac130_fco_hotdamn3" );		// Hot damn!
	add_context_sensative_dialog( "kill", "large_group", 1, "ac130_tvo_whoa1" );		// Whoa!!!
	add_context_sensative_dialog( "kill", "large_group", 1, "ac130_tvo_whoa2" );		// Whoa!!!
	add_context_sensative_dialog( "kill", "large_group", 1, "ac130_tvo_whoa3" );		// Whoa!!!
	add_context_sensative_dialog( "kill", "large_group", 2, "ac130_fco_kaboom" );		// Ka - boom.

	add_context_sensative_dialog( "location", "car", 0, "ac130_fco_guybycar" );			// There’s a guy by that car.
	add_context_sensative_timeout( "location", "car", undefined, 40 );

	add_context_sensative_dialog( "location", "truck", 0, "ac130_fco_guybytruck" );		// There’s one by that truck.
	add_context_sensative_timeout( "location", "truck", undefined, 12 );

	add_context_sensative_dialog( "location", "building", 0, "ac130_fco_nailbybuilding1" );
	add_context_sensative_timeout( "location", "building", undefined, 20 );

	add_context_sensative_dialog( "location", "wall", 0, "ac130_tvo_coverbywall1" );
	add_context_sensative_timeout( "location", "wall", undefined, 20 );

	add_context_sensative_dialog( "location", "field", 0, "ac130_fco_crossingfield" );	// Enemies crossing the field.
	add_context_sensative_timeout( "location", "field", undefined, 20 );

	add_context_sensative_dialog( "location", "road", 0, "ac130_fco_enemyonroad" );		// Enemy personnel on the road.
	add_context_sensative_timeout( "location", "road", undefined, 20 );

	add_context_sensative_dialog( "location", "church", 0, "ac130_fco_outofchurch" );	// There's armed personnel running out of the church.
	add_context_sensative_timeout( "location", "church", undefined, 20 );

	add_context_sensative_dialog( "location", "ditch", 0, "ac130_fco_headinforditch" );	// Yeah, he’s headin’ for the ditch.
	add_context_sensative_timeout( "location", "ditch", undefined, 20 );

	add_context_sensative_dialog( "vehicle", "incoming", 0, "ac130_fco_movingvehicle" );	// We got a moving vehicle here.
	add_context_sensative_dialog( "vehicle", "incoming", 1, "ac130_fco_vehicleonmove" );	// We got a vehicle on the move.
	add_context_sensative_dialog( "vehicle", "incoming", 2, "ac130_plt_engvehicle" );		// You are cleared to engage the moving vehicle.
	add_context_sensative_dialog( "vehicle", "incoming", 3, "ac130_fco_getvehicle" );		// Crew, get the moving vehicle.

	add_context_sensative_dialog( "vehicle", "death", 0, "ac130_fco_confirmed" );	// Confirmed, vehicle neutralized.
	add_context_sensative_dialog( "vehicle", "death", 1, "ac130_fco_fulltank" );	// ( chuckling ) Shit, must've been a full tank of gas.

	add_context_sensative_dialog( "misc", "action", 0, "ac130_plt_scanrange" );		// Set scan range.
	add_context_sensative_timeout( "misc", "action", 0, 70 );

	add_context_sensative_dialog( "misc", "action", 1, "ac130_plt_cleanup" );		// Clean up that signal.
	add_context_sensative_timeout( "misc", "action", 1, 80 );

	add_context_sensative_dialog( "misc", "action", 2, "ac130_plt_targetreset" );	// Target reset.
	add_context_sensative_timeout( "misc", "action", 2, 55 );

	add_context_sensative_dialog( "misc", "action", 3, "ac130_plt_azimuthsweep" );	// Recalibrate azimuth sweep angle. Adjust elevation scan.
	add_context_sensative_timeout( "misc", "action", 3, 100 );
}

add_context_sensative_dialog( name1, name2, group, soundAlias )
{
	assert( isdefined( name1 ) );
	assert( isdefined( name2 ) );
	assert( isdefined( group ) );
	assert( isdefined( soundAlias ) );
	assert( soundexists( soundAlias ) == true );

	if ( ( !isdefined( level.scr_sound[ name1 ] ) ) || ( !isdefined( level.scr_sound[ name1 ][ name2 ] ) ) || ( !isdefined( level.scr_sound[ name1 ][ name2 ][ group ] ) ) )
	{
		// creating group for the first time
		level.scr_sound[ name1 ][ name2 ][ group ] = spawnStruct();
		level.scr_sound[ name1 ][ name2 ][ group ].played = false;
		level.scr_sound[ name1 ][ name2 ][ group ].sounds = [];
	}

	//group exists, add the sound to the array
	index = level.scr_sound[ name1 ][ name2 ][ group ].sounds.size;
	level.scr_sound[ name1 ][ name2 ][ group ].sounds[ index ] = soundAlias;
}

add_context_sensative_timeout( name1, name2, groupNum, timeoutDuration )
{
	if ( !isdefined( level.context_sensative_dialog_timeouts ) )
		level.context_sensative_dialog_timeouts = [];

	createStruct = false;
	if ( !isdefined( level.context_sensative_dialog_timeouts[ name1 ] ) )
		createStruct = true;
	else if ( !isdefined( level.context_sensative_dialog_timeouts[ name1 ][ name2 ] ) )
		createStruct = true;
	if ( createStruct )
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ] = spawnStruct();

	if ( isdefined( groupNum ) )
	{
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ].groups = [];
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ] = spawnStruct();
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "timeoutDuration" ] = timeoutDuration * 1000;
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "lastPlayed" ] = ( timeoutDuration * - 1000 );
	}
	else
	{
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "timeoutDuration" ] = timeoutDuration * 1000;
		level.context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "lastPlayed" ] = ( timeoutDuration * - 1000 );
	}
}