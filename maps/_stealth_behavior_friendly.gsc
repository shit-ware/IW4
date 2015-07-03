#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;

stealth_behavior_friendly_main()
{
	self friendly_init();

	function = self._stealth.behavior.ai_functions[ "state" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "friendly_behavior"  );

	function = self._stealth.behavior.ai_functions[ "state" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "friendly_behavior"  );
}

/************************************************************************************************************/
/*												FRIENDLY LOGIC												*/
/************************************************************************************************************/
friendly_state_hidden()
{
	self thread set_battlechatter( false );

	self._stealth.behavior.oldgrenadeammo	 = self.grenadeammo;
	self.grenadeammo	 = 0;

	self.forceSideArm 	 = undefined;
	//used to be ignore all - but that makes him not aim at enemies when exposed - which isn't good...also 
	//after stealth groups were created we want to differentiate between who should be shot at and who shouldn't
	//so we don't all of a sudden alert another stealth group by shooting at them
	//self.dontevershoot 	= true; 
	self.ignoreme 		 = true;
}

friendly_state_spotted()
{
	//-->NEW ASSERT COME GRAB MO IF THIS HITS
	assert( !isplayer( self ) );
	//if ( isplayer( self ) )
	//	return;

	self thread set_battlechatter( true );

	if( isdefined( self._stealth.behavior.oldgrenadeammo ) )
		self.grenadeammo 	 = self._stealth.behavior.oldgrenadeammo;
	else
		self.grenadeammo = 3;
	//used to be ignore all - but that makes him not aim at enemies when exposed - which isn't good...also 
	//after stealth groups were created we want to differentiate between who should be shot at and who shouldn't
	//so we don't all of a sudden alert another stealth group by shooting at them	
	//self.dontevershoot 	= undefined;
	//self.ignoreall 	 = false;
	self.ignoreme 	 	 = false;

	//self.disablearrivals 	 = true;
	//self.disableexits 	 = true;

	self pushplayer( false );
	self disable_cqbwalk();

	self thread friendly_spotted_getup_from_prone();
	self allowedstances( "prone", "crouch", "stand" );
	self anim_stopanimscripted();
}

friendly_spotted_getup_from_prone( angles )
{
	self endon( "death" );

	if ( self._stealth.logic.stance != "prone" )
		return;

	self ent_flag_set( "_stealth_custom_anim" );
	anime = "_stealth_prone_2_run_roll";

	if ( isdefined( angles ) )
		self orientMode( "face angle", angles[ 1 ] + 20 );
		// self thread friendly_spotted_getup_from_prone_rotate( angles, anime );

	self thread anim_generic_custom_animmode( self, "gravity", anime );
	length = getanimlength( getanim_generic( anime ) );
	wait( length - .2 );
	self notify( "stop_animmode" );
	self ent_flag_clear( "_stealth_custom_anim" );
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/

friendly_init()
{
	assertEX( isdefined( self._stealth ), "There is no self._stealth struct.  You ran stealth behavior before running the detection logic.  Run _stealth_logic::friendly_init() on this AI first" );

	self ent_flag_init( "_stealth_custom_anim" );
	self ent_flag_init( "_stealth_override_goalpos" );

	// AI FUNCTIONS
	// this is our behavior struct inside of _stealth...everything we do will go in here.
	self._stealth.behavior = spawnstruct();
	self._stealth.behavior.ai_functions = [];

	self friendly_default_state_behavior();

	self._stealth.plugins = spawnstruct();
	
	self thread ai_stealth_pause_handler();
}

friendly_custom_state_behavior( array )
{
	foreach ( key, func in array )
		self ai_create_behavior_function( "state", key, func );
		
	
	function = self._stealth.behavior.ai_functions[ "state" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "friendly_behavior" );

	function = self._stealth.behavior.ai_functions[ "state" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "friendly_behavior" );
}

friendly_default_state_behavior()
{
	array = [];
	array[ "hidden" ] = ::friendly_state_hidden;
	array[ "spotted" ] = ::friendly_state_spotted;

	self friendly_custom_state_behavior( array );
}