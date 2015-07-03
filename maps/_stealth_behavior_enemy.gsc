#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;
#include maps\_stealth_animation_funcs;

stealth_behavior_enemy_main()
{
	self enemy_init();

	function = self._stealth.behavior.ai_functions[ "state" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "enemy_behavior" );

	function = self._stealth.behavior.ai_functions[ "state" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "enemy_behavior" );

	self thread enemy_Animation_Loop();
}

/************************************************************************************************************/
/*												ENEMY LOGIC													*/
/************************************************************************************************************/
enemy_Animation_Loop()
{
	self endon( "death" );
	self endon( "pain_death" );
	self endon( "damage" );

	while ( 1 )
	{
		self waittill( "event_awareness", type );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		//put inside the loop so we can check every time
		wrapper_func = self._stealth.behavior.ai_functions[ "animation" ][ "wrapper" ];// enemy_animation_wrapper

		self thread [[ wrapper_func ]]( type );
	}
}

enemy_state_hidden()
{
	self.fovcosine = .5;// 60 degrees to either side...120 cone...2 / 3 of the default
	self.fovcosinebusy = .1;
	self.favoriteenemy = undefined;
	self.dontattackme = true;
	self.dontevershoot = true; 
	self thread set_battlechatter( false );

	if ( self.type == "dog" )
		return;

	self.dieQuietly = true;
	self clearenemy();
}

enemy_state_spotted( internal )
{
	self.fovcosine = .01;// 90 degrees to either side...180 cone...default view cone
	self.ignoreall = false;
	self.dontattackme = undefined;
	self.dontevershoot = undefined; 
	if ( isdefined( self.oldfixednode ) )
		self.fixednode = self.oldfixednode;

	self thread set_battlechatter( true );

	if ( self.type != "dog" )
	{
		self.dieQuietly 	 = false;

		if ( !isdefined( internal ) )
		{
			self clear_run_anim();
			self enemy_stop_current_behavior();
		}
	}
	else
	{
		self.script_growl 	 = undefined;
		self.script_nobark 	 = undefined;
	}

	if ( isdefined( internal ) )
		return;
		
	enemy = level._stealth.group.spotted_enemy[ self.script_stealthgroup ];
	if ( isdefined( enemy ) )
		self getEnemyInfo( enemy );
}


/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/

enemy_init()
{
	assertEX( isdefined( self._stealth ), "There is no self._stealth struct.  You ran stealth behavior before running the detection logic.  Run _stealth_logic::enemy_init() on this AI first" );

	self ent_flag_init( "_stealth_override_goalpos" );
	self ent_flag_init( "_stealth_enemy_alert_level_action" );
	self ent_flag_init( "_stealth_running_to_corpse" );

	self ent_flag_init( "_stealth_behavior_reaction_anim" );
	self ent_flag_init( "_stealth_behavior_first_reaction" );
	self ent_flag_init( "_stealth_behavior_reaction_anim_in_progress" );

	// this is our behavior struct inside of _stealth...everything we do will go in here.
	self._stealth.behavior = spawnstruct();
	
	// to prevent AI doing melee right away
	self.a.noFirstFrameMelee = true;
	
	// AI FUNCTIONS
	self._stealth.behavior.ai_functions = [];

	self enemy_default_state_behavior();
	self enemy_default_anim_behavior();

	self._stealth.behavior.event = spawnstruct();

	if ( self.type == "dog" )
		self enemy_dog_init();

	self._stealth.plugins = spawnstruct();
	
	self thread ai_stealth_pause_handler();
}

enemy_dog_init()
{
	if ( threatbiasgroupexists( "dog" ) )
		self setthreatbiasgroup( "dog" );

	if ( isdefined( self.enemy ) || isdefined( self.favoriteenemy ) )
		return;

	self ent_flag_init( "_stealth_behavior_asleep" );

	if ( isdefined( self.script_pet ) || isdefined( self.script_patroller ) )
		return;

	self.ignoreme = true;
	self.ignoreall = true;
	self.allowdeath = true;

	// we do this because we assume dogs are sleeping...
	self thread anim_generic_custom_animmode_loop( self, "gravity", "_stealth_dog_sleeping" );
	self ent_flag_set( "_stealth_behavior_asleep" );
}

enemy_custom_state_behavior( array )
{
	foreach ( key, value in array )
		self ai_create_behavior_function( "state", key, value );
		
	
	function = self._stealth.behavior.ai_functions[ "state" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "enemy_behavior" );

	function = self._stealth.behavior.ai_functions[ "state" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "enemy_behavior" );
}

enemy_default_state_behavior()
{
	array = [];
	array[ "hidden" ]	 = ::enemy_state_hidden;
	array[ "spotted" ]	 = ::enemy_state_spotted;

	self enemy_custom_state_behavior( array );
}

enemy_default_anim_behavior()
{
	self ai_create_behavior_function( "animation", "wrapper", 			::enemy_animation_wrapper );

	if ( self.type == "dog" )
	{
		self ai_create_behavior_function( "animation", "grenade danger", 	::dog_animation_wakeup_fast );
		self ai_create_behavior_function( "animation", "bulletwhizby", 		::dog_animation_wakeup_fast );
		self ai_create_behavior_function( "animation", "gunshot_teammate", 	::dog_animation_wakeup_fast );
		self ai_create_behavior_function( "animation", "projectile_impact", ::dog_animation_wakeup_slow );
	}
	else
	{
		self ai_create_behavior_function( "animation", "grenade danger", 	::enemy_animation_nothing );
		self ai_create_behavior_function( "animation", "bulletwhizby", 		::enemy_animation_nothing );
		self ai_create_behavior_function( "animation", "gunshot_teammate", 	::enemy_animation_nothing );
		self ai_create_behavior_function( "animation", "projectile_impact", ::enemy_animation_nothing );
	}
}