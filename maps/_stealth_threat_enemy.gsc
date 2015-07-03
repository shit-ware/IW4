#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;
#include maps\_stealth_animation_funcs;

stealth_threat_enemy_main()
{
	self enemy_init();

	self thread enemy_Threat_Loop();
}

/************************************************************************************************************/
/*													LOGIC													*/
/************************************************************************************************************/
enemy_Threat_Loop()
{
	self endon( "death" );
	self endon( "pain_death" );

	if ( self.type == "dog" )
		self thread enemy_threat_logic_dog();

	while ( 1 )
	{
		self waittill( "_stealth_enemy_alert_level_change", type );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		self enemy_alert_level_change_reponse( type );
	}
}

enemy_alert_level_change_reponse( type )
{
	self ent_flag_set( "_stealth_enemy_alert_level_action" );

	_type = type;
	if ( issubstr( type, "warning" ) )
		_type = "warning";

	switch( _type )
	{
		case "warning":
			self thread enemy_alert_level_warning_wrapper( type );
			break;
		case "attack":
			self thread enemy_alert_level_attack_wrapper();
			break;
		case "reset":
			self thread enemy_alert_level_reset_wrapper();
			break;
	}
}

// we do this because we assume dogs are sleeping...if so, then they'll never get an enemy
// because to make that assumption we set their ignorall to true in their init...so we need
// to give them the ability to find an enemy once they take damage...we might extend this in 
// the future to also do the same thing if an ai gets too close or makes too much noise
enemy_threat_logic_dog()
{
	self endon( "death" );
	self endon( "pain_death" );

	if ( !self ent_flag( "_stealth_behavior_asleep" ) )
		return;

	self enemy_threat_logic_dog_wait();
	wait .5;

	self delaythread( .6, ::ent_flag_clear, "_stealth_behavior_asleep" );
	self.ignoreall = false;
}

enemy_threat_logic_dog_wait()
{
	self endon( "pain" );
	self endon( "enemy" );

	array_thread( level.players, ::enemy_threat_logic_dog_wakeup_dist, self, 128 );

	while ( 1 )
	{
		self waittill( "event_awareness", type );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		if ( type == "heard_scream" || type == "bulletwhizby" || type == "projectile_impact" || type == "explode" )
			return;
	}
}

enemy_threat_logic_dog_wakeup_dist( dog, dist )
{
	dog endon( "death" );
	self endon( "death" );

	if ( !dog ent_flag( "_stealth_behavior_asleep" ) )
		return;
	dog endon( "_stealth_behavior_asleep" );

	distsqrd = dist * dist;

	while ( distancesquared( self.origin, dog.origin ) > distsqrd && self ent_flag( "_stealth_enabled" ) )
		wait .1;

	dog.ignoreall = false;
	dog.favoriteenemy = self;
	wait .1;
	dog.favoriteenemy = undefined;
}

/************************************************************************************************************/
/*												THREAT LEVELS												*/
/************************************************************************************************************/
enemy_alert_level_reset_wrapper()
{
	//this function is different than normal because if we want to change the behavior the enemies have
	//after losing a known enemy - we can set it up here...also we don't care about any previous knowledge of corpses
	//through this wrapper either and we make sure we wait for the spotted flag to clear before going back to normal.
	//this why this function exists instead of just using the normal wrapper
				
	self endon( "_stealth_enemy_alert_level_change" );
	self endon( "enemy_awareness_reaction" );//we'll end on a new event, but events will also end on a new threat
	self endon( "death" );
	self endon( "pain_death" );
	
	self stealth_group_spotted_flag_waitopen();//wait for everyone to lose their enemy too
	
	self enemy_stop_current_behavior();

	self ent_flag_clear( "_stealth_enemy_alert_level_action" ); 
	if( isdefined( self._stealth.plugins.corpse ) )
	{
		self ent_flag_clear( "_stealth_saw_corpse" ); 
		self ent_flag_clear( "_stealth_found_corpse" );
	}
	self ent_flag_clear( "_stealth_attack" );
	self ent_flag_set( "_stealth_normal" );
	
	function = ai_get_behavior_function( "threat", "reset" );	// default ::enemy_alert_level_normal
	self thread [[ function ]]();
}

enemy_alert_level_warning_wrapper( type )
{
	spotted_flag = self group_get_flagname( "_stealth_spotted" );

	self endon( "_stealth_enemy_alert_level_change" );
	level endon( spotted_flag );
	self endon( "death" );
	self endon( "pain_death" );

	self enemy_find_original_goal();
	self enemy_stop_current_behavior();

	function = ai_get_behavior_function( "threat", type );	// default ::enemy_alert_level_warning1, 2
	self [[ function ]]();

	// done with warning response behavior and still in warning state, return to normal
	self enemy_alert_level_normal_wrapper();
}


enemy_lookaround_for_time( time )
{
	oldfov = self.fovcosine;
	self.fovcosine = 0.1;
	self set_generic_idle_anim( "_stealth_look_around" );

	wait time;

	self clear_generic_idle_anim();
	self.fovcosine = oldfov;
}

enemy_announce_alert()
{
	self endon( "death" );
	
	wait 0.25;

	if ( isdefined( self.enemy ) && self cansee( self.enemy ) )
	{
		self enemy_announce_snd( "huh" );
		self thread enemy_announce_attack();
	}
	else
	{
		self thread enemy_announce_huh();
	}
}

enemy_alert_level_warning1()
{
	if ( !isdefined( self.enemy ) )
		return;
		
	self thread enemy_announce_alert();
	
	if ( isdefined( self.script_patroller ) )
	{
		if ( self.type != "dog" )
		{
			type = "a";
			if ( cointoss() )
				type = "b";
			self set_generic_run_anim( "_stealth_patrol_search_" + type, true );
		}
		else
		{
			self set_dog_walk_anim();
			self.script_growl = 1;
		}
		self.disablearrivals = true;
		self.disableexits = true;
	}
	else if ( self.type == "dog" )
	{
		self set_dog_walk_anim();
		self.script_growl = 1;
		self.disablearrivals = true;
		self.disableexits = true;
	}

	vec = vectornormalize( self.enemy.origin - self.origin );
	dist = distance( self.enemy.origin, self.origin );

	dist *= .25;

	dist = clamp( dist, 64, 128 );

	vec = vector_multiply( vec, dist );

	spot = self.origin + vec + ( 0, 0, 16 );
	end = spot + ( ( 0, 0, -96 ) );

	spot = physicstrace( spot, end );
	if ( spot == end )
		return;

	self ent_flag_set( "_stealth_override_goalpos" );
	self setgoalpos( spot );
	self.goalradius = 64;
	
	// we do the timeout - because sometimes this puts his goal into a postion that
	// is invalid and he'll never actually hit his goal...so we time out after 2 seconds
	self waittill_notify_or_timeout( "goal", 2 );

	// if AI can't reach it's goal, at least face it.
	if ( !self isInGoal( self.origin ) )
		self.shootPosOverride = spot + ( 0, 0, 64 );

	enemy_lookaround_for_time( 10 );
	
	self.shootPosOverride = undefined;
}

enemy_alert_level_warning2()
{
	if ( !isdefined( self.enemy ) )
		return;
		
	self thread enemy_announce_alert();

	if ( self.type != "dog" )
		self set_generic_run_anim( "_stealth_patrol_cqb" );
	else
	{
		self clear_run_anim();
		self.script_nobark = 1;
		self.script_growl = 1;
	}
	self.disablearrivals = false;
	self.disableexits = false;
//	self.oldfixednode = self.fixednode;
//	self.fixednode = true;

	lastknownspot = self.enemy.origin;
	dist = distance( lastknownspot, self.origin );
		
	self ent_flag_set( "_stealth_override_goalpos" );
	self setgoalpos( lastknownspot );
	self.goalradius = dist * .5;
	self waittill( "goal" );

	if ( self.type != "dog" )
	{
		type = "_stealth_patrol_search_a";
		if ( cointoss() )
			type = "_stealth_patrol_search_b";
		self set_generic_run_anim( type, true );
	}
	else
	{
		self anim_generic_custom_animmode( self, "gravity", "_stealth_dog_stop" );
		self set_dog_walk_anim();
	}

	self setgoalpos( lastknownspot );
	self.goalradius = 64;
	self.disablearrivals = true;
	self.disableexits = true;

	self waittill( "goal" );

	enemy_lookaround_for_time( 15 );

//	self.fixednode = self.oldfixednode;

	if ( self.type != "dog" )
	{
		type = "a";
		if ( randomint( 100 ) > 50 )
			type = "b";
		self set_generic_run_anim( "_stealth_patrol_search_" + type, true );
	}
	else
	{
		self set_dog_walk_anim();
		self.script_growl = undefined;
	}
}

enemy_alert_level_attack_wrapper()
{
	self endon( "death" );
	self endon( "pain_death" );
	self endon( "_stealth_enemy_alert_level_change" );// - > this might not be a good idea - just added it recently - haven't tested
	
	self notify( "endNewEnemyReactionAnim" );
	self notify( "movemode" );

	self.disablearrivals = false;
	self.disableexits = false;
	
	self enemy_find_original_goal(); //should ALWAYS know what the original goal was just in case...if we dont have any warnings, we catch it here
	self ent_flag_set( "_stealth_attack" );
	
	function = ai_get_behavior_function( "threat", "attack" );	// default ::enemy_alert_level_attack
	self [[ function ]]();
}

enemy_alert_level_attack()
{
	self thread enemy_announce_spotted( self.origin );
	
	if ( isdefined( self.script_goalvolume ) )
		self thread maps\_spawner::set_goal_volume();
	else
		self enemy_close_in_on_target();
}

enemy_close_in_on_target()
{
	radius = 2048;
	self.goalradius = radius;

	if ( isdefined( self.script_stealth_dontseek ) &&  self.script_stealth_dontseek == true )
		return;

	self endon( "death" );

	self ent_flag_set( "_stealth_override_goalpos" );

	while ( isdefined( self.enemy ) && self ent_flag( "_stealth_enabled" ) )
	{
		self setgoalpos( self.enemy.origin );
		self.goalradius = radius;

		if ( radius > 600 )
			radius *= .75;
		else
			return;

		wait 15;
	}
}

enemy_alert_level_normal_wrapper()
{
	enemy_set_alert_level( "reset" );

	self ent_flag_clear( "_stealth_enemy_alert_level_action" );

	if ( self ent_flag_exist( "_stealth_saw_corpse" ) )
		self ent_flag_waitopen( "_stealth_saw_corpse" );

	//to make sure found corpse is set
	wait .05;

	if ( self ent_flag_exist( "_stealth_found_corpse" ) )
		self ent_flag_waitopen( "_stealth_found_corpse" );

	self ent_flag_set( "_stealth_normal" );
	
	function = ai_get_behavior_function( "threat", "normal" );	// default ::enemy_alert_level_normal
	self [[ function ]]();
}

enemy_alert_level_normal()
{
	self thread enemy_announce_hmph();

	self enemy_go_back();
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/

enemy_init()
{
	self enemy_default_threat_behavior();
	self enemy_default_threat_anim_behavior();

	self._stealth.plugins.threat = true;
	self.script_stealth_dontseek = true;
	
	self.alertLevel = "noncombat";
	
	self.newEnemyReactionDistSq = squared( level._stealth.logic.ai_event[ "ai_eventDistFootstepSprint" ][ "hidden" ] );
}

enemy_default_threat_behavior()
{
	array = [];
	array[ "reset" ] 	 = ::enemy_alert_level_normal;
	array[ "warning1" ] = ::enemy_alert_level_warning1;
	array[ "warning2" ] = ::enemy_alert_level_warning2;
	array[ "attack" ] 	 = ::enemy_alert_level_attack;
	array[ "normal" ]	 = ::enemy_alert_level_normal;

	if ( !isdefined( level._stealth.logic.alert_level_table ) )
	{	
		level._stealth.logic.alert_level_table = [];
		level._stealth.logic.alert_level_table[ "reset" ] = "noncombat";
		level._stealth.logic.alert_level_table[ "warning" ] = "alert";
		level._stealth.logic.alert_level_table[ "attack" ] = "combat";
	}

	self enemy_set_threat_behavior( array );
}

// set the code alert level
enemy_set_alert_level( type )
{
	assertEx( isdefined( level._stealth.logic.alert_level_table[ type ] ), "unsupported alert_level" );	// may need a way to custom alert_level_table
	self.alertLevel = level._stealth.logic.alert_level_table[ type ];
}

enemy_set_threat_behavior( array )
{
	//clear the array
	self._stealth.behavior.ai_functions[ "threat" ] = [];

	if ( !isdefined( array[ "reset" ] ) )
		array[ "reset" ] = ::enemy_alert_level_normal;
	if ( !isdefined( array[ "attack" ] ) )
		array[ "attack" ] = ::enemy_alert_level_attack;
	if ( !isdefined( array[ "normal" ] ) )
		array[ "normal" ] = ::enemy_alert_level_normal;

	foreach ( key, function in array )
		self ai_create_behavior_function( "threat", key, function );

	self._stealth.logic.alert_level.max_warnings = array.size - 3;// sub 2 for reset, normal, and attack
}

enemy_alert_level_change( type )
{
	self notify( "_stealth_enemy_alert_level_change", type );	// calls ::enemy_alert_level_change_reponse but one frame later. Must be after enemy_Animation_Loop thread process... messy

	if ( !isdefined( self._stealth.plugins.threat ) )
	{
		// from _stealth_visibility_enemy::enemy_alert_level_nothing()
		self.goalradius = level.default_goalradius;
		return;
	}

	if ( issubstr( type, "warning" ) )
		type = "warning";
		
	enemy_set_alert_level( type );
	
	self notify( "awareness_alert_level", type );
}

enemy_threat_anim_defaults()
{
	array = [];
	array[ "reset" ]	 = ::enemy_animation_nothing;
	array[ "warning" ]	 = ::enemy_animation_nothing;

	if ( self.type == "dog" )
		array[ "attack" ]		 = ::dog_animation_generic;
	else
		array[ "attack" ]		 = ::enemy_animation_attack;

	return array;
}

enemy_set_threat_anim_behavior( array )
{
	def = enemy_threat_anim_defaults();

	//set defautls for reset and attack if they're not there
	if ( !isdefined( array[ "reset" ] ) )
		array[ "reset" ] = def[ "reset" ];
	if ( !isdefined( array[ "warning" ] ) )
		array[ "warning" ] = def[ "warning" ];
	if ( !isdefined( array[ "attack" ] ) )
		array[ "attack" ] = def[ "attack" ];

	foreach ( key, func in array )
		self ai_create_behavior_function( "animation", key, func );
}

enemy_default_threat_anim_behavior()
{
	array = enemy_threat_anim_defaults();
	self enemy_set_threat_anim_behavior( array );
}