#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;

stealth_visibility_enemy_main()
{
	self enemy_init();

	self thread enemy_threat_logic();

}

/************************************************************************************************************/
/*													ENEMY LOGIC												*/
/************************************************************************************************************/
MIN_TIME_TO_LOSE_ENEMY = 20 * 1000;

enemy_threat_logic()
{
	self endon( "death" );
	self endon( "pain_death" );

	while ( 1 )
	{
		self ent_flag_wait( "_stealth_enabled" );

		self waittill( "enemy" );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		if ( !isalive( self.enemy ) )
			continue;

		if ( !self stealth_group_spotted_flag() )
		{
			if ( !self enemy_alert_level_logic( self.enemy ) )
				continue;
		}
		else
		{
			// if we hit this line it means we're not the first ones to find the enemy
			self maps\_stealth_threat_enemy::enemy_alert_level_change( "attack" );
		}

		self thread enemy_threat_set_spotted();

		//wait a minimum of 10 seconds before trying to lose your enemy
		wait 10;

		// must not have gotten any event from enemy for MIN_TIME_TO_LOSE_ENEMY and must be out of maxVisibleDist
		while ( isdefined( self.enemy ) && self ent_flag( "_stealth_enabled" ) )
		{
			time_past_last_event = gettime() - self lastKnownTime( self.enemy );
			
			if ( MIN_TIME_TO_LOSE_ENEMY > time_past_last_event )
			{
				wait ( ( MIN_TIME_TO_LOSE_ENEMY - time_past_last_event ) * 0.001 );
				continue;
			}
			
			if ( distance( self.origin, self.enemy.origin ) > self.enemy.maxVisibleDist )
				break;

			wait .5;
		}

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;
			
		//if we ever break out - if means everyone actually managed to hide...unbelievable
		if ( isdefined( self.enemy ) )
			enemy_alert_level_forget( self.enemy, 0 );
			
		self clearenemy();
		self maps\_stealth_threat_enemy::enemy_alert_level_change( "reset" );
	}
}

enemy_alert_level_logic_start_attacking( enemy )
{
	//the first check means that a gun shot or something equally bad happened	
	//the second check is to see if you've been spotted already twice before	
	if ( self ent_flag( "_stealth_bad_event_listener" ) || enemy._stealth.logic.spotted_list[ self.unique_id ] > self._stealth.logic.alert_level.max_warnings )
	{
		 /#
			if ( self ent_flag( "_stealth_bad_event_listener" ) )
				self stealth_debug_print( "BROKEN STEALTH. Received ent '" + enemy.unique_id + "' as an enemy from code. Attacked because the reason was a bad_event_listener...ie a gunshot or something equally bad" );
			else
				self stealth_debug_print( "BROKEN STEALTH. Received ent '" + enemy.unique_id + "' as an enemy from code. Attacked because " + enemy.unique_id + " had been spotted more than the max_warning amount of " + self._stealth.logic.alert_level.max_warnings );
		#/
		self maps\_stealth_threat_enemy::enemy_alert_level_change( "attack" );
		return true;
	}
	
	return false;
}


enemy_recheck_time = 500;

enemy_alert_level_logic( enemy )
{
	// enemy is not stealthy one bit
	if ( !isdefined( enemy._stealth ) )
		return true;

	//add this ai to this spotted list
	if ( !isdefined( enemy._stealth.logic.spotted_list[ self.unique_id ] ) )
		enemy._stealth.logic.spotted_list[ self.unique_id ] = 0;

	while (1)
	{
		enemy._stealth.logic.spotted_list[ self.unique_id ]++;

		if ( enemy_alert_level_logic_start_attacking( enemy ) )
			return true;

		//this makes the ai look smart by being aware of your presence
		number = enemy._stealth.logic.spotted_list[ self.unique_id ];
		self maps\_stealth_threat_enemy::enemy_alert_level_change( "warning" + number );

	    //forget about him after a while
	    self thread enemy_alert_level_forget( enemy );
		//give the player a chance to hide with this
		self enemy_alert_level_waittime( enemy );
		
		if ( gettime() - self lastKnownTime( enemy ) > enemy_recheck_time )
		{
			self clearenemy();
			return false;
		}
	}
}

enemy_threat_set_spotted()
{
	self endon( "death" );
	self endon( "pain_death" );

	enemy = self.enemy;
	self.dontEverShoot = undefined;
	
	self [[ self._stealth.logic.pre_spotted_func ]]();
	
	if ( isdefined( enemy ) )
		level._stealth.group.spotted_enemy[ self.script_stealthgroup ] = enemy;
		
	self group_flag_set( "_stealth_spotted" );
}

enemy_prespotted_func_default()
{
	wait 2.25;// randomfloatrange( 2, 2.5 ); // used to be .25, .5
}


enemy_alert_level_waittime( enemy )
{
	//this makes sure that if someone else spots you...then this quits earler
	//than the givin amount of time for the player to try and hide again
	if ( self stealth_group_corpse_flag() || self ent_flag( "_stealth_bad_event_listener" ) )
		return;

	timefrac = distance( self.origin, enemy.origin ) * .0005;
	waittime = level._stealth.logic.min_alert_level_duration + timefrac;
	
	self stealth_debug_print( "WARNING time = " + waittime );
	//iprintlnbold( waittime );

	level endon( group_get_flagname( "_stealth_spotted" ) );
	self endon( "_stealth_bad_event_listener" );
	
	wait( waittime );
}

/************************************************************************************************************/
/*													EVENTS													*/
/************************************************************************************************************/
enemy_event_listeners_logic( type )
{
	self endon( "death" );
	
	while ( 1 )
	{
		self waittill( type, subtype, param );	// subtype and param for debugging

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		if ( self ent_flag_exist( "_stealth_behavior_asleep" ) && self ent_flag( "_stealth_behavior_asleep" ) )
			continue;

		self ent_flag_set( "_stealth_bad_event_listener" );
	}
}

//this function resets all event listeners after they happen...so that we can detect each one multiple times
enemy_event_listeners_proc()
{
	self endon( "death" );
	
	while ( 1 )
	{
		self ent_flag_wait( "_stealth_bad_event_listener" );

		wait .65;
		//this time is set so high because apparently the ai can take up to .5 seconds to 
		//detect you as an enemy after they have received an event listener...
		//EDIT: after testing i've noticed that they still miss the event because they 
		//receive an enemy even after .65 seconds of receiving the event...but it's more
		//fun this way actually...to get away with it once in a while.
		self ent_flag_clear( "_stealth_bad_event_listener" );
	}
}

enemy_event_awareness_notify( type, param )
{
	self ent_flag_clear( "_stealth_normal" );

	self._stealth.logic.event.awareness_param[ type ] = param;
	self notify( "event_awareness", type );
	level notify( "event_awareness", type );
}

// for major categories with subtypes (ai_event, awareness_alert_level, awareness_corpse)
enemy_event_category_awareness( type )
{
	self endon( "death" );
	self endon( "pain_death" );

	while ( 1 )
	{
		self waittill( type, subtype, param );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;
			
		//
		// special check for dogs deleted from here, see revision history #15
		//
		
		switch( type )
		{
			case "awareness_alert_level":
				break;
				
			case "ai_event":
				if ( !isdefined( self._stealth.logic.event.aware_aievents[ subtype ] ) )
					continue;
				//this makes sure that magic bullets and friendly bullets that don't cause an enemy notify don't cause guys to break out of animations	
				if( subtype == "bulletwhizby" && ( !isdefined( param.team ) || param.team == self.team ) )
					continue;
				// fall through
				
			default:
				group_flag_set( "_stealth_event" );
				level thread enemy_event_handle_clear( self.script_stealthgroup );
				break;
		}

		enemy_event_awareness_notify( subtype, param );

		waittillframeend;// wait a frame to make sure stealth_spotted didn't get set this frame
	}
}

// for special awareness events
enemy_event_awareness( type )
{
	self endon( "death" );
	self endon( "pain_death" );

	//just to create the key so it exists so other scripts (mainly behavior)
	//can reference it and see what awareness options it has
	self._stealth.logic.event.awareness_param[ type ] = true;

	while ( 1 )
	{
		self waittill( type, param );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		group_flag_set( "_stealth_event" );
		level thread enemy_event_handle_clear( self.script_stealthgroup );

		enemy_event_awareness_notify( type, param );

		waittillframeend;// wait a frame to make sure stealth_spotted didn't get set this frame
	}
}

enemy_event_handle_clear( name )
{
	end_msg = "enemy_event_handle_clear:" + name + " Proc";
	wait_msg = "enemy_event_handle_clear:" + name + " Cleared";

	level notify( end_msg );
	level endon( end_msg );

	wait 2;

	ai = group_get_ai_in_group( name );

	if ( ai.size )
	{
		level add_wait( ::array_wait, ai, "event_awareness_waitclear_ai" );
		level add_endon( end_msg );
		level add_func( ::send_notify, wait_msg );
		level thread do_wait();

		array_thread( ai, ::event_awareness_waitclear_ai, end_msg );

		level waittill( wait_msg );
	}

	group_flag_clear( "_stealth_event", name );
}

event_awareness_waitclear_ai( end_msg )
{
	level endon( end_msg );

	self event_awareness_waitclear_ai_proc();
	self notify( "event_awareness_waitclear_ai" );
}

event_awareness_waitclear_ai_proc()
{
	self endon( "death" );

	waittillframeend;// make sure these flag's are set;

	check1 = false;
	if ( isdefined( self.ent_flag[ "_stealth_behavior_first_reaction" ] ) )
		check1 = self ent_flag( "_stealth_behavior_first_reaction" );

	check2 = false;
	if ( isdefined( self.ent_flag[ "_stealth_behavior_reaction_anim" ] ) )
		check1 = self ent_flag( "_stealth_behavior_reaction_anim" );

	if ( !check1 && !check2 )
		return;

	self add_wait( ::waittill_msg, "death" );
	self add_wait( ::waittill_msg, "going_back" );
	do_wait_any();

	self endon( "goal" );

	allies = array_combine( getaiarray( "allies" ), level.players );
	dist = level._stealth.logic.detect_range[ "hidden" ][ "crouch" ];
	distsquared = dist * dist;
	loop = true;

	if ( loop )
	{
		loop = false;
		foreach ( actor in allies )
		{
			if ( distancesquared( self.origin, actor.origin ) < distsquared )
				continue;
			loop = true;
		}
		wait 1;
	}
}

enemy_event_declare_to_team( type, name )
{
	other = undefined;
	team = self.team;

	while ( 1 )
	{
		if ( !isalive( self ) )
			return;

		self waittill( type, var1, var2 );

		if ( isalive( self ) && !self ent_flag( "_stealth_enabled" ) )
			continue;

		switch( type )
		{
			case "death":
				other = var1;
				break;
			case "damage":
				other = var2;
				break;
		}

		if ( !isdefined( other ) )
			continue;

		if ( isplayer( other ) || ( isdefined( other.team ) && other.team != team ) )
			break;
	}

	if ( !isdefined( self ) )
	{
	 	// in case of deletion
		return;
	}

	ai = getaispeciesarray( "bad_guys", "all" );

	check = int( level._stealth.logic.ai_event[ name ][ level._stealth.logic.detection_level ] );

	for ( i = 0; i < ai.size; i++ )
	{
		if ( !isalive( ai[ i ] ) )
			continue;
		if ( !isdefined( ai[ i ]._stealth ) )
			continue;
		if ( distance( ai[ i ].origin, self.origin ) > check )
			continue;
		if ( ai[ i ] ent_flag_exist( "_stealth_behavior_asleep" ) && ai[ i ] ent_flag( "_stealth_behavior_asleep" ) )
			continue;
		ai[ i ] ent_flag_set( "_stealth_bad_event_listener" );
	}
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/
enemy_init()
{
	assertex( !isdefined( self._stealth ), "you called maps\_stealth_logic::enemy_init() twice on the same ai" );

	self clearenemy();
	self._stealth = spawnstruct();
	self._stealth.logic = spawnstruct();

	self ent_flag_init( "_stealth_enabled" );
	self ent_flag_set( "_stealth_enabled" );
	
	self ent_flag_init( "_stealth_normal" );
	self ent_flag_set( "_stealth_normal" );
	
	self ent_flag_init( "_stealth_attack" );

	self group_flag_init( "_stealth_spotted" );
	self group_flag_init( "_stealth_event" );
	self group_flag_init( "_stealth_found_corpse" );

	self group_add_to_global_list();
	if ( !isdefined( level._stealth.behavior.sound[ "spotted" ][ self.script_stealthgroup ] ) )
		level._stealth.behavior.sound[ "spotted" ][ self.script_stealthgroup ] = false;

	self._stealth.logic.alert_level 				 = spawnstruct();
	self._stealth.logic.alert_level.max_warnings	 = 0;
	self enemy_alert_level_default_pre_spotted_func();

	self enemy_event_listeners_init();
}

enemy_event_listeners_init()
{
	self ent_flag_init( "_stealth_bad_event_listener" );

	self._stealth.logic.event = spawnstruct();
	
	self addAIEventListener( "grenade danger" );
	self addAIEventListener( "gunshot" );
	self addAIEventListener( "gunshot_teammate" );
	self addAIEventListener( "silenced_shot" );
	self addAIEventListener( "bulletwhizby" );
	self addAIEventListener( "projectile_impact" );

	self thread enemy_event_listeners_logic( "ai_event" );	// catch all of the above eventListener events
		
	self thread enemy_event_declare_to_team( "damage", "ai_eventDistPain" );
	self thread enemy_event_declare_to_team( "death", "ai_eventDistDeath" );
	
	self thread enemy_event_listeners_proc();

	self._stealth.logic.event.awareness_param = [];

	//a lot of these overlap with event listeners - because even though the event 
	//listeners above will cause a spotted state - we still want to know
	//why the ai got an enemy and perhaps do specific animations based on that	

	self._stealth.logic.event.aware_aievents = [];
	self._stealth.logic.event.aware_aievents[ "bulletwhizby" ] = true;
	self._stealth.logic.event.aware_aievents[ "projectile_impact" ] = true;
	self._stealth.logic.event.aware_aievents[ "gunshot_teammate" ] = true;
	self._stealth.logic.event.aware_aievents[ "grenade danger" ] = true;

	self thread enemy_event_category_awareness( "ai_event" );
	self thread enemy_event_category_awareness( "awareness_alert_level" );	// this is actually notified in this script
	self thread enemy_event_category_awareness( "awareness_corpse" );		// this is called from corpse

	 /#
		//these are for extra debug prints
		self thread enemy_event_debug_print( "awareness_alert_level" );
		self thread enemy_event_debug_print( "awareness_corpse" );
		self thread enemy_event_debug_print( "ai_event" );
	#/
}

enemy_alert_level_set_pre_spotted_func( func )
{
	self._stealth.logic.pre_spotted_func = func;
}

enemy_alert_level_default_pre_spotted_func()
{
	self._stealth.logic.pre_spotted_func = ::enemy_prespotted_func_default;
}