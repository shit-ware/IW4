#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;

stealth_accuracy_friendly_main()
{
	self friendly_init();

	function = self._stealth.behavior.ai_functions[ "accuracy" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "accuracy_friendly" );

	function = self._stealth.behavior.ai_functions[ "accuracy" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "accuracy_friendly" );
}

/************************************************************************************************************/
/*												FRIENDLY LOGIC												*/
/************************************************************************************************************/
friendly_acc_hidden()
{
	self.baseAccuracy 	 = self._stealth.behavior.goodaccuracy;
	self.Accuracy 		 = self._stealth.behavior.goodaccuracy;
}

friendly_acc_spotted()
{
	self.baseAccuracy 	 = self._stealth.behavior.old_baseAccuracy;
	self.Accuracy 		 = self._stealth.behavior.old_Accuracy;
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/

friendly_init()
{
	assertEX( isdefined( self._stealth ), "There is no self._stealth struct.  You ran stealth behavior before running the detection logic.  Run _stealth_logic::friendly_init() on this AI first" );

	self._stealth.behavior.goodAccuracy 		 = 50;
	self._stealth.behavior.old_baseAccuracy 	 = self.baseAccuracy;
	self._stealth.behavior.old_Accuracy 	 	 = self.Accuracy;

	self friendly_default_acc_behavior();

	self._stealth.plugins.accaracy_mod = true;
}

friendly_custom_acc_behavior( array )
{
	foreach ( key, func in array )
		self ai_create_behavior_function( "accuracy", key, func );
		
	
	function = self._stealth.behavior.ai_functions[ "accuracy" ][ "hidden" ];
	self thread ai_message_handler_hidden( function, "accuracy_friendly" );

	function = self._stealth.behavior.ai_functions[ "accuracy" ][ "spotted" ];
	self thread ai_message_handler_spotted( function, "accuracy_friendly" );
}

friendly_default_acc_behavior()
{
	array = [];
	array[ "hidden" ] = ::friendly_acc_hidden;
	array[ "spotted" ] = ::friendly_acc_spotted;

	self friendly_custom_acc_behavior( array );
}