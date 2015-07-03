#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

//need to be able to save select dvar in menu (spending points while in the menu)
//need to be able to save select dvar from script (dvars track which items are found)
main()
{
	// &&1/30 pieces of enemy intel found.
	precachestring( &"SCRIPT_INTELLIGENCE_OF_FOURTYFIVE" );
	precachestring( &"SCRIPT_INTELLIGENCE_PREV_FOUND" );
	level.intel_items = create_array_of_intel_items();
	println( "intelligence.gsc:             intelligence items:", level.intel_items.size );

	setDvar( "ui_level_cheatpoints", level.intel_items.size );
	level.intel_counter = 0;	// intel counter for collected intel points for this mission
	setDvar( "ui_level_player_cheatpoints", level.intel_counter );
	
	level.table_origins = create_array_of_origins_from_table();
	initialize_intel();
	
	if( is_specialop() )
	{
		remove_all_intel();
		return;
	}

	intel_think();
	
	wait .05;
}

remove_all_intel()
{
	foreach ( index, trigger in level.intel_items )
	{
		if ( !isdefined( trigger.removed ) )
			trigger remove_intel_item();
	}
}

remove_intel_item()
{
	self.removed = true;
	self.item hide();
	self.item notsolid();
	self trigger_off();
	
	level.intel_counter++;
	setDvar( "ui_level_player_cheatpoints", level.intel_counter );
	
	self notify( "end_trigger_thread" );
	/#
	println( "^3Removed Intel: " + self.num );
	#/
}

initialize_intel()
{
	foreach ( index, trigger in level.intel_items )
	{
		origin = trigger.origin;
		trigger.num = get_nums_from_origins( origin );
	}
}

intel_think()
{
	foreach ( index, trigger in level.intel_items )
	{
		if ( trigger check_item_found() )
		{
			trigger remove_intel_item();
		}
		else
		{
			trigger thread wait_for_pickup();
			trigger thread poll_for_found();
		}
	}
}

//we poll constantly to see if the item's been picked up...this is because script only checks at the 
//beginning if the item was found or not...after that, it doesn't check anymore, however a player can
//pick up intel, die, reload an earlier part of script and then pick up intel again...this polling
//insures things like that dont happen.
poll_for_found()
{
	self endon( "end_loop_thread" );
	
	while( !self check_item_found() )	
		wait .1;
	
	self remove_intel_item();
}

check_item_found()
{
	foreach( player in level.players )
	{
		if( !player GetPlayerIntelIsFound( self.num ) )
			return false;
	}
	return true;
}

create_array_of_intel_items()
{
	intelligence_items = getentarray( "intelligence_item", "targetname" );
	for ( i = 0;i < intelligence_items.size;i++ )
	{
		println( intelligence_items[ i ].origin );
		intelligence_items[ i ].item = getent( intelligence_items[ i ].target, "targetname" );
		intelligence_items[ i ].found = false;
	}
	return intelligence_items;
}

create_array_of_origins_from_table()
{
	origins = [];
	for ( num = 1; num <= 64; num++ )
	{
		location = tablelookup( "maps/_intel_items.csv", 0, num, 4 );
		if ( isdefined( location ) && ( location != "undefined" ) )
		{
			locArray = strTok( location, "," );
			assert( locArray.size == 3 );
			for ( i = 0;i < locArray.size;i++ )
				locArray[ i ] = int( locArray[ i ] );
			origins [ num ] = ( locArray[ 0 ], locArray[ 1 ], locArray[ 2 ] );
		}
		else
		{
			origins [ num ] = undefined;
		}
	}
	return origins;
}

wait_for_pickup()
{
	self endon( "end_trigger_thread" );
	
	if( self.classname == "trigger_use" )
	{
		// Press and hold^3 &&1 ^7to secure the enemy intelligence.
		self setHintString( &"SCRIPT_INTELLIGENCE_PICKUP" );
		self usetriggerrequirelookat();
	}
	
	self waittill( "trigger", player );
	self notify( "end_loop_thread" );
	
	self intel_feedback( player );
	self save_intel_for_all_players();
	UpdateGamerProfileAll();
	
	waittillframeend;
	
	self remove_intel_item();
}

save_intel_for_all_players()
{
	assert( ! self check_item_found() );
	
	foreach( player in level.players )
	{
		if( player GetPlayerIntelIsFound( self.num ) )
			continue;
			
		player SetPlayerIntelFound( self.num );
	}	
	logString( "found intel item " + self.num );
	
	// updates percent complete
    /#
    PrintLn( ">> SP PERCENT UPDATE - save_intel_for_all_players()" );
    #/
    maps\_endmission::updateSpPercent();
}

give_point()
{
	//give_points
	curValue = ( self GetLocalPlayerProfileData( "cheatPoints" ));
	self SetLocalPlayerProfileData( "cheatPoints", curValue + 1 );	
}

intel_feedback( found_by_player )
{
	self.item hide();
	self.item notsolid();
	level thread play_sound_in_space( "intelligence_pickup", self.item.origin );

	display_time = 3000;
	fade_time = 700;
	delete_time = display_time + fade_time / 1000;
	
	foreach( player in level.players )
	{
		//if i did NOT find it, but I already had it, print nothing
		if( found_by_player != player && player GetPlayerIntelIsFound( self.num ) )	
			continue;
			
		remaining_print = player createClientFontString( "objective", 1.5 );
		remaining_print.glowColor = ( 0.7, 0.7, 0.3 );
		remaining_print.glowAlpha = 1;
		remaining_print setup_hud_elem();
		remaining_print.y = -60;
		remaining_print SetPulseFX( 60, display_time, fade_time );
		
		intel_found = 0;
		
		//if I found it and I already had it
		if( found_by_player == player && player GetPlayerIntelIsFound( self.num ) )
			remaining_print.label = &"SCRIPT_INTELLIGENCE_PREV_FOUND";
		else
		{
			// &&1/30 pieces of enemy intel found.
			remaining_print.label = &"SCRIPT_INTELLIGENCE_OF_FOURTYFIVE";
			player give_point();
			intel_found = ( player GetLocalPlayerProfileData( "cheatPoints" ));
			remaining_print setValue( intel_found );
		}

		if ( intel_found == 22 )
			player maps\_utility::player_giveachievement_wrapper( "THE_ROAD_LESS_TRAVELED" );
	
		if ( intel_found == 45 )
			player maps\_utility::player_giveachievement_wrapper( "LEAVE_NO_STONE_UNTURNED" );

		remaining_print delaycall( delete_time, ::Destroy );
	}
}

setup_hud_elem()
{
	self.color = ( 1, 1, 1 );
	self.alpha = 1;
	self.x = 0;
	self.alignx = "center";
	self.aligny = "middle";
	self.horzAlign = "center";
	self.vertAlign = "middle";
	self.foreground = true;
}

assert_if_identical_origins()
{
	origins = [];
	for ( i = 1;i < 65;i++ )
	{
		location = tablelookup( "maps/_intel_items.csv", 0, i, 4 );
		locArray = strTok( location, "," );
		//assert( locArray.size == 3 );
		for ( i = 0;i < locArray.size;i++ )
			locArray[ i ] = int( locArray[ i ] );
		origins [ i ] = ( locArray[ 0 ], locArray[ 1 ], locArray[ 2 ] );


		//if ( distancesquared( first.origin, second.origin ) < 4 );
	}

	for ( i = 0;i < origins.size;i++ )
	{
		if ( ! isdefined( origins [ i ] ) )
			continue;
		if ( origins [ i ] == "undefined" )
			continue;
		for ( j = 0;j < origins.size;j++ )
		{
			if ( ! isdefined( origins [ j ] ) )
				continue;
			if ( origins [ j ] == "undefined" )
				continue;
			if ( i == j )
				continue;
			if ( origins [ i ] == origins[ j ] )
				assertmsg( "intel items in maps/_intel_items.csv with identical origins (" + origins[ i ] + ") " );
		}
	}
}

get_nums_from_origins( origin )
{
	for ( i = 1;i < level.table_origins.size + 1;i++ )
	{
		if ( !isdefined( level.table_origins [ i ] ) )
			continue;
		if ( distancesquared( origin, level.table_origins[ i ] ) < squared( 75 ) )
			return i;
	}

	assertmsg( "Add the origin of this intel item ( " + origin + " ) to maps/_intel_items.csv file" );
}