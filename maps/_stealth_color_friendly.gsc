#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;

stealth_color_friendly_main()
{
	self friendly_init();

	function = self._stealth.behavior.ai_functions[ "color" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "color_friendly" );

	function = self._stealth.behavior.ai_functions[ "color" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "color_friendly" );
}

/************************************************************************************************************/
/*												FRIENDLY LOGIC												*/
/************************************************************************************************************/
friendly_color_hidden()
{
	self disable_ai_color();
	self.fixednode		 = false;
}

friendly_color_spotted()
{
	self enable_ai_color();
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/

friendly_init()
{
	assertEX( isdefined( self._stealth ), "There is no self._stealth struct.  You ran stealth behavior before running the detection logic.  Run _stealth_logic::friendly_init() on this AI first" );

	self friendly_default_color_behavior();

	self._stealth.plugins.color_system = true;
}

friendly_custom_color_behavior( array )
{
	foreach ( key, func in array )
		self ai_create_behavior_function( "color", key, func );
	
	function = self._stealth.behavior.ai_functions[ "color" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "color_friendly" );

	function = self._stealth.behavior.ai_functions[ "color" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "color_friendly" );
}

friendly_default_color_behavior()
{
	array = [];
	array[ "hidden" ] = ::friendly_color_hidden;
	array[ "spotted" ] = ::friendly_color_spotted;

	self friendly_custom_color_behavior( array );
}