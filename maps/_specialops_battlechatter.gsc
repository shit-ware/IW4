#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

init()
{
	anim.so = spawnstruct();  // holds all of our SO-specific bc stuff
	
	anim.so.eventTypes = [];
	anim.so.eventTypes[ "check_fire" ]		= "threat_friendly_fire";
	anim.so.eventTypes[ "reload" ]			= "inform_reload_generic";
	anim.so.eventTypes[ "frag_out" ]		= "inform_attack_grenade";
	anim.so.eventTypes[ "flash_out" ]		= "inform_attack_flashbang";
	anim.so.eventTypes[ "smoke_out" ]		= "inform_attack_smoke";
	anim.so.eventTypes[ "c4_plant" ]		= "inform_attack_c4";
	anim.so.eventTypes[ "claymore_plant" ]	= "inform_plant_claymore";
	anim.so.eventTypes[ "downed" ]			= "inform_suppressed";
	anim.so.eventTypes[ "bleedout" ]		= "inform_bleedout";
	anim.so.eventTypes[ "reviving" ]		= "inform_reviving";
	anim.so.eventTypes[ "revived" ]			= "inform_revived";
	anim.so.eventTypes[ "sentry_out" ]		= "inform_place_sentry";
	anim.so.eventTypes[ "area_secure" ]		= "inform_area_secure";

	// Supported, but not currently used anywhere.
	anim.so.eventTypes[ "kill_generic" ]	= "inform_kill_generic";
	anim.so.eventTypes[ "kill_infantry" ]	= "inform_kill_infantry";
	anim.so.eventTypes[ "affirmative" ]		= "inform_roger";
	anim.so.eventTypes[ "negative" ]		= "inform_negative";
	anim.so.eventTypes[ "on_comms" ]		= "inform_comms";
	anim.so.eventTypes[ "mark_dropzone" ]	= "inform_markdz";
	anim.so.eventTypes[ "glowstick_out" ]	= "inform_use_glowstick";

	anim.so.eventTypeMinWait = [];
	anim.so.eventTypeMinWait[ "check_fire" ]		= 4;
	anim.so.eventTypeMinWait[ "reload" ]			= 8;
	anim.so.eventTypeMinWait[ "frag_out" ]			= 3;
	anim.so.eventTypeMinWait[ "flash_out" ]			= 3;
	anim.so.eventTypeMinWait[ "smoke_out" ]			= 3;
	anim.so.eventTypeMinWait[ "c4_plant" ]			= 2;
	anim.so.eventTypeMinWait[ "claymore_plant" ]	= 2;
	anim.so.eventTypeMinWait[ "downed" ]			= 0.5;
	anim.so.eventTypeMinWait[ "bleedout" ]			= 0.5;
	anim.so.eventTypeMinWait[ "reviving" ]			= 2;
	anim.so.eventTypeMinWait[ "revived" ]			= 2;
	anim.so.eventTypeMinWait[ "sentry_out" ]		= 3;

	anim.so.eventTypeMinWait[ "kill_generic" ]		= 2;
	anim.so.eventTypeMinWait[ "kill_infantry" ]		= 2;
	anim.so.eventTypeMinWait[ "area_secure" ]		= 0.5;
	anim.so.eventTypeMinWait[ "affirmative" ]		= 2;
	anim.so.eventTypeMinWait[ "negative" ]			= 2;
	anim.so.eventTypeMinWait[ "on_comms" ]			= 0.5;
	anim.so.eventTypeMinWait[ "mark_dropzone" ]		= 0.5;
	anim.so.eventTypeMinWait[ "glowstick_out" ]		= 3;
	
	anim.so.skipDistanceCheck = [];
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "affirmative";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "negative";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "area_secure";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "on_comms";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "mark_dropzone";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "downed";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "bleedout";
	anim.so.skipDistanceCheck[ anim.so.skipDistanceCheck.size ] = "check_fire";
	
	anim.so.noReloadCalloutWeapons = [];
	anim.so.noReloadCalloutWeapons[ anim.so.noReloadCalloutWeapons.size ] = "m79";
	anim.so.noReloadCalloutWeapons[ anim.so.noReloadCalloutWeapons.size ] = "ranger";
	anim.so.noReloadCalloutWeapons[ anim.so.noReloadCalloutWeapons.size ] = "claymore";
	anim.so.noReloadCalloutWeapons[ anim.so.noReloadCalloutWeapons.size ] = "rpg";
	anim.so.noReloadCalloutWeapons[ anim.so.noReloadCalloutWeapons.size ] = "rpg_player";
	
	anim.so.bcMaxDistSqd = 800 * 800;  // units
	
	anim.so.bcPrintFailPrefix = "^3***** BCS FAILURE: ";

	array_thread( level.players, ::enable_chatter_on_player );
	enable_chatter();
}

enable_chatter()
{
	level.so_player_chatter_enabled = true;	
}

disable_chatter()
{
	level.so_player_chatter_enabled = false;	
}

enable_chatter_on_player()
{
	self.so_isSpeaking = false;
	self.bc_eventTypeLastUsedTime = [];
	
	self thread revive_tracking();
	self thread claymore_tracking();
	self thread reload_tracking();
	self thread grenade_tracking();
	self thread friendlyfire_tracking();
	self thread friendlyfire_whizby_tracking();
	self thread sentry_tracking();
	self thread kill_generic_tracking();
	self thread kill_infantry_tracking();
	self thread area_secure_tracking();
	self thread affirmative_tracking();
	self thread negative_tracking();
	self thread on_comms_tracking();
	self thread mark_dropzone_tracking();
	self thread glowstick_tracking();
}

revive_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	while( 1 )
	{
		note = self waittill_any_return( "so_downed", "so_bleedingout", "so_reviving", "so_revived" );
		
		if( note == "so_downed" )
		{
			self play_so_chatter( "downed" );
		}
		else if( note == "so_bleedingout" )
		{
			self play_so_chatter( "bleedout" );
		}
		else if( note == "so_reviving" )
		{
			self play_so_chatter( "reviving" );
		}
		else if( note == "so_revived" )
		{
			self play_so_chatter( "revived" );
		}
	}
}

claymore_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "begin_firing" );
		weaponName = self GetCurrentWeapon();
		if ( weaponName == "claymore" )
		{
			self play_so_chatter( "claymore_plant" );
		}
	}
}

sentry_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "sentry_placement_finished" );

		self play_so_chatter( "sentry_out" );
	}
}

kill_generic_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_kill_generic" );

		self play_so_chatter( "kill_generic" );
	}
}

kill_infantry_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_kill_infantry" );

		self play_so_chatter( "kill_infantry" );
	}
}

area_secure_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_area_secure" );

		self play_so_chatter( "area_secure" );
	}
}

affirmative_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_affirmative" );

		self play_so_chatter( "area_secure" );
	}
}

negative_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_negative" );

		self play_so_chatter( "negative" );
	}
}

on_comms_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_on_comms" );

		self play_so_chatter( "on_comms" );
	}
}

mark_dropzone_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		self waittill( "so_bcs_mark_dropzone" );

		self play_so_chatter( "mark_dropzone" );
	}
}

glowstick_tracking()
{
	// Currently glowsticks aren't used or supported.
}

reload_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "reload_start" );
		
		weaponName = self GetCurrentWeapon();
		if( weapon_no_reload_callout( weaponName ) )
		{
			continue;
		}
		
		// sounds dumb for a player to chatter about reloading when he's downed
		if( self is_downed() )
		{
			continue;
		}
		
		self play_so_chatter( "reload" );
	}
}

weapon_no_reload_callout( weaponName )
{
	foreach( weap in anim.so.noReloadCalloutWeapons )
	{
		if( weaponName == weap )
		{
			return true;
		}
	}
	
	return false;
}

grenade_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while( 1 )
	{
		self waittill( "grenade_fire", grenade, weaponName );
		
		eventType = undefined;

		if ( weaponName == "fraggrenade" )
		{
			eventType = "frag_out";
		}
		else if ( weaponName == "semtex_grenade" )
		{
			eventType = "frag_out";
		}
		else if ( weaponName == "flash_grenade" )
		{
			eventType = "flash_out";
		}
		else if ( weaponName == "smoke_grenade_american" )
		{
			eventType = "smoke_out";
		}
		else if ( weaponName == "c4" )
		{
			eventType = "c4_plant";
		}
		
		if( IsDefined( eventType ) )
		{
			self play_so_chatter( eventType );
		}
	}
}

friendlyfire_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type );
		
		if ( !friendlyfire_is_valid( damage, attacker, type ) )
		{
			continue;
		}
		
		self play_so_chatter( "check_fire" );
	}
}

friendlyfire_is_valid( damage, attacker, type )
{
	if ( damage <= 0 )
	{
		return false;
	}

	if ( !isplayer( attacker ) )
	{
		return false;
	}

	if ( attacker == self )
	{
		return false;
	}

	if( type == "MOD_MELEE" )
	{
		return false;
	}

	if( isdefined( level.friendlyfire_warnings ) && !level.friendlyfire_warnings )
	{
		return false;
	}

	return true;
}

friendlyfire_whizby_tracking()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	self AddAiEventListener( "bulletwhizby" );
	
	while( 1 )
	{
		self waittill( "ai_event", event, shooter, whizByOrigin );
		
		if( event == "bulletwhizby" )
		{
			if( !friendlyfire_whizby_is_valid( shooter, whizByOrigin ) )
			{
				continue;
			}
		
			self play_so_chatter( "check_fire" );
		}
	}
}

friendlyfire_whizby_is_valid( shooter, whizByOrigin )
{
	if( !IsPlayer( shooter ) )
	{
		return false;
	}
	
	if( shooter == self )
	{
		return false;
	}
	
	// downed guys don't notice friendlyfire whizbys
	if( self is_downed() )
	{
		return false;
	}
	
	// hack - the whizby notify for a player gives us an origin, not a distance like it does when an AI calls it
	if( abs( whizByOrigin[ 2 ] - self.origin[ 2 ] > 128 ) )
	{
		// throw away whizbys that are way too high or low
		return false;
	}
	whizByDist = Distance2D( self.origin, whizByOrigin );
	
	// make distance checks consistent with SP
	if( !animscripts\battlechatter_ai::friendlyfire_whizby_distances_valid( shooter, whizbyDist ) )
	{
		return false;
	}

	if( isdefined( level.friendlyfire_warnings ) && !level.friendlyfire_warnings )
	{
		return false;
	}
	
	return true;
}

play_revive_nag()
{
	type = self get_nag_event_type();
	ASSERT( IsDefined( type ) );
	
	self play_so_chatter( type );
}

// depending on where we are in the bleedout sequence, we play lines with different intensity
get_nag_event_type()
{
	type = "downed";
	
	currentTime = self.coop.bleedout_time;
	totalTime = self.coop.bleedout_time_default;
	
	if ( currentTime < ( totalTime * level.coop_bleedout_stage2_multiplier ) )
	{
		type = "bleedout";
	}
	
	return type;
}

can_say_current_nag_event_type()
{
	type = self get_nag_event_type();
	
	return self can_say_event_type( type );
}

play_so_chatter( eventType )
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	if( !self can_say_event_type( eventType ) )
	{
		return;
	}

	if ( !self close_enough_to_other_player( eventType ) )
	{
		return;
	}

	soundalias = get_player_team_prefix( self ) + anim.so.eventTypes[ eventType ];
	
	soundalias = check_overrides( eventType, soundalias );
	if( !IsDefined( soundalias ) )
	{
		return;
	}
	
	if( !SoundExists( soundalias ) )
	{
		PrintLn( anim.so.bcPrintFailPrefix + "soundalias " + soundalias + " doesn't exist." );
		return;
	}
	
	self.so_isSpeaking = true;
	self PlaySound( soundalias, "bc_done", true );
	self waittill( "bc_done" );
	self.so_isSpeaking = false;
	
	self update_event_type( eventType );
}

can_say_event_type( eventType )
{
	if ( !isdefined( level.so_player_chatter_enabled ) || !level.so_player_chatter_enabled )
	{
		return false;
	}
	
	if( self.so_isSpeaking )
	{
		return false;
	}
	
	if( !IsDefined( self.bc_eventTypeLastUsedTime[ eventType ] ) )
	{
		return true;
	}
	
	lastUsedTime = self.bc_eventTypeLastUsedTime[ eventType ];
	minWaitTime = anim.so.eventTypeMinWait[ eventType ] * 1000;
		
	if( ( GetTime() - lastUsedTime ) >= minWaitTime )
	{
		return true;
	}
	
	return false;
}

update_event_type( eventType )
{
	self.bc_eventTypeLastUsedTime[ eventType ] = GetTime();
}

check_overrides( soundtype, defaultAlias )
{
	if( soundtype == "reload" )
	{
		if ( isdefined( level.so_override[ "skip_inform_reloading" ] ) && level.so_override[ "skip_inform_reloading" ] )
		{
			return undefined;
		}
		
		if ( isdefined( level.so_override[ "inform_reloading" ] ) )
		{
			return level.so_override[ "inform_reloading" ];
		}
	}
	
	return defaultAlias;
}

get_player_team_prefix( player )
{
	assertex( isdefined( level.so_campaign ), "level.so_campaign must be set in order to play co-op team chatter." );

	stealth = "";
	if ( isdefined( level.so_stealth ) && level.so_stealth )
		stealth = "STEALTH_";

	player_num = "1";
	if ( player == level.player2 )
		player_num = "2";
		
	switch( level.so_campaign )
	{
		case "ranger":
			return "SO_US_" + player_num + "_" + stealth;
		case "seal":
			return "SO_NS_" + player_num + "_" + stealth;
		case "arctic":
		case "desert":
		case "woodland":
		case "ghillie":
			return "SO_UK_" + player_num + "_" + stealth;
		default:
			ASSERTMSG( "level.so_campaign was set to an invalid value, '" + level.so_campaign + "'." );
	}
}

close_enough_to_other_player( eventType )
{
	if ( isdefined( eventType ) )
	{
		foreach( event in anim.so.skipDistanceCheck )
		{
			if ( event == eventType )
				return true;
		}
	}
	
	other_player = get_other_player( self );

	if ( DistanceSquared( other_player.origin, self.origin ) > anim.so.bcMaxDistSqd )
	{
		return false;
	}

	return true;
}

is_downed()
{
	if( self ent_flag_exist( "coop_downed" ) && self ent_flag( "coop_downed" ) )
	{
		return true;
	}
	
	return false;
}
