main()
{
	thread setDeadQuote();
}

setDeadQuote()
{
	level endon( "mine death" );

	// kill any deadquotes already running
	level notify( "new_quote_string" );
	level endon( "new_quote_string" );

	// player can be dead if the player died at the same point that setDeadQuote was called from another script
	if ( isalive( level.player ) )
		level.player waittill( "death" );
	
	if ( !level.missionfailed )
	{
		deadQuoteSize = ( Int( TableLookup( "sp/deathQuoteTable.csv", 1, "size", 0 ) ) );
		deadQuoteIndex = randomInt( deadQuoteSize );

		// This is used for testing
		if ( GetDvar( "cycle_deathquotes" ) != "" )
		{
			if ( GetDvar( "ui_deadquote_index" ) == "" )
				SetDvar( "ui_deadquote_index", "0" );

			deadQuoteIndex = GetDvarInt( "ui_deadquote_index" );

			SetDvar( "ui_deadquote", lookupDeathQuote( deadQuoteIndex ) );

			deadQuoteIndex++;
			if ( deadQuoteIndex > (deadQuoteSize - 1) )
				deadQuoteIndex = 0;
			
			SetDvar( "ui_deadquote_index", deadQuoteIndex );
		}
		else
		{
			SetDvar( "ui_deadquote", lookupDeathQuote( deadQuoteIndex ) );
		}
	}
}

lookupDeathQuote( index )
{
	return TableLookup( "sp/deathQuoteTable.csv", 0, index, 1 );
}

setDeadQuote_so()
{
	level notify( "new_quote_string" );

	deadquotes = [];
	deadquotes = so_buildDeadQuote();
	deadquotes = maps\_utility::array_randomize( deadquotes );
	
	i = randomInt( deadquotes.size );
	
	// Only works in local games. Online the dvars are unreliable so don't bother with them.
	if ( !maps\_utility::is_coop_online() )
	{
		keep_searching = ( deadquotes.size > 1 );
		original_i = i;
		while( keep_searching )
		{
			if ( deadquote_recently_used( deadquotes[ i ] ) )
			{
				i++;
				if ( i >= deadquotes.size )
					i = 0;
				if ( i == original_i )
					keep_searching = false;
			}
			else
			{
				keep_searching = false;
			}
		}

		setdvar( "ui_deadquote_v3", getdvar( "ui_deadquote_v2" ) );
		setdvar( "ui_deadquote_v2", getdvar( "ui_deadquote_v1" ) );
		setdvar( "ui_deadquote_v1", deadquotes[ i ] );
	}
	
	// A few deadquotes have icons attached to them.
	switch ( deadquotes[ i ] )
	{
		case "@DEADQUOTE_SO_ICON_PARTNER":
			maps\_specialops_code::so_special_failure_hint_reset_dvars( "ui_icon_partner" );
			break;
		case "@DEADQUOTE_SO_ICON_OBJ":
			maps\_specialops_code::so_special_failure_hint_reset_dvars( "ui_icon_obj" );
			break;
		case "@DEADQUOTE_SO_ICON_OBJ_OFFSCREEN":
			maps\_specialops_code::so_special_failure_hint_reset_dvars( "ui_icon_obj_offscreen" );
			break;
		case "@DEADQUOTE_SO_STAR_RANKINGS":
			maps\_specialops_code::so_special_failure_hint_reset_dvars( "ui_icon_stars" );
			break;
		case "@DEADQUOTE_SO_CLAYMORE_POINT_ENEMY":
		case "@DEADQUOTE_SO_CLAYMORE_ENEMIES_SHOOT":
			maps\_specialops_code::so_special_failure_hint_reset_dvars( "ui_icon_claymore" );
			break;
		case "@DEADQUOTE_SO_STEALTH_STAY_LOW":
			maps\_specialops_code::so_special_failure_hint_reset_dvars( "ui_icon_stealth_stance" );
			break;
	}

	setdvar( "ui_deadquote", deadquotes[ i ] );
}

deadquote_recently_used( deadquote )
{
	if ( deadquote == getdvar( "ui_deadquote_v1" ) )
		return true;
	
	if ( deadquote == getdvar( "ui_deadquote_v2" ) )
		return true;
		
	if ( deadquote == getdvar( "ui_deadquote_v3" ) )
		return true;

	return false;
}

so_buildDeadQuote()
{
	if ( should_use_custom_deadquotes() )
		return level.so_deadquotes;

	deadquotes = [];
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_TRY_NEW_DIFFICULTY";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_BEAT_BEST_TIME";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_TEXT_COLOR_DIFFICULTY";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_SEARCH_FOR_WEAPONS";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_TOGGLE_WEAP_ALT_MODE";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_RED_FIND_COVER";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_THROW_FLASHBANG";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_GRENADES_ROLL";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_STAR_RANKINGS";
	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_ICON_OBJ";
//	deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_ICON_OBJ_OFFSCREEN";

	if ( isdefined( self.so_infohud_toggle_state ) && self.so_infohud_toggle_state != "none" )
	{
		deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_TOGGLE_TIMER";
	}

	if ( maps\_utility::is_coop() )
	{
		deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_CRAWL_TO_TEAMMATE";
		deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_STAY_NEAR_TEAMMATE";
		deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_FRIENDLY_FIRE_HINT";
		deadquotes[ deadquotes.size ]  = "@DEADQUOTE_SO_ICON_PARTNER";
	}
	
	return deadquotes;
}

should_use_custom_deadquotes()
{
	if ( !isdefined( level.so_deadquotes ) )
		return false;
	
	if ( level.so_deadquotes.size <= 0 )
		return false;
		
	assertex( isdefined( level.so_deadquotes_chance ), "level.so_deadquotes had contents, but level.so_deadquote_chance was undefined." );	

	// Set level.so_deadquotes_chance to 1.0 to guarantee the contents will be used.
	return ( level.so_deadquotes_chance >= randomfloat( 1.0 ) );
}