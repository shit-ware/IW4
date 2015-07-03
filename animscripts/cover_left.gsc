#include maps\_utility;
#include animscripts\Combat_utility;
#include animscripts\utility;
#using_animtree( "generic_human" );

// (Note that animations called right are used with left corner nodes, and vice versa.)

main()
{
	self.animArrayFuncs = [];
	self.animArrayFuncs[ "hiding" ][ "stand" ] = ::set_animarray_standing_left;
	self.animArrayFuncs[ "hiding" ][ "crouch" ] = ::set_animarray_crouching_left;

	self endon( "killanimscript" );
    animscripts\utility::initialize( "cover_left" );

	animscripts\corner::corner_think( "left", 90 );
}

end_script()
{
	animscripts\corner::end_script_corner();
	animscripts\cover_behavior::end_script( "left" );
}

set_animarray_standing_left() /* void */ 
{
	array = [];

	array[ "alert_idle" ] = %corner_standL_alert_idle;
	array[ "alert_idle_twitch" ] = array(
		%corner_standL_alert_twitch01,
		%corner_standL_alert_twitch02,
		%corner_standL_alert_twitch03,
		%corner_standL_alert_twitch04,
		%corner_standL_alert_twitch05,
		%corner_standL_alert_twitch06,
		%corner_standL_alert_twitch07
	 );
	array[ "alert_idle_flinch" ] = array( %corner_standL_flinch );

	//array["alert_to_C"] = %corner_standL_trans_alert_2_C;
	//array["B_to_C"] = %corner_standL_trans_B_2_C;
	//array["C_to_alert"] = %corner_standL_trans_C_2_alert;
	//array["C_to_B"] = %corner_standL_trans_C_2_B;
	array[ "alert_to_A" ] = array( %corner_standL_trans_alert_2_A );
	array[ "alert_to_B" ] = array( %corner_standL_trans_alert_2_B_v2 );
	array[ "A_to_alert" ] = array( %corner_standL_trans_A_2_alert_v2 );
	array[ "A_to_alert_reload" ] = array();
	array[ "A_to_B" ] = array( %corner_standL_trans_A_2_B_v2 );
	array[ "B_to_alert" ] = array( %corner_standL_trans_B_2_alert_v2 );
	array[ "B_to_alert_reload" ] = array( %corner_standL_reload_B_2_alert );
 	array[ "B_to_A" ] = array( %corner_standL_trans_B_2_A_v2 );
	array[ "lean_to_alert" ] = array( %CornerStndL_lean_2_alert );
	array[ "alert_to_lean" ] = array( %CornerStndL_alert_2_lean );
	array[ "look" ] = %corner_standL_look;
	array[ "reload" ] = array( %corner_standL_reload_v1 );// , %corner_standL_reload_v2 );
	array[ "grenade_exposed" ] = %corner_standL_grenade_A;
	array[ "grenade_safe" ] = %corner_standL_grenade_B;

	array[ "blind_fire" ] = array( %corner_standL_blindfire_v1, %corner_standL_blindfire_v2 );
	
	array[ "alert_to_look" ] = %corner_standL_alert_2_look;
	array[ "look_to_alert" ] = %corner_standL_look_2_alert;
	array[ "look_to_alert_fast" ] = %corner_standl_look_2_alert_fast_v1;
	array[ "look_idle" ] = %corner_standL_look_idle;
	array[ "stance_change" ] = %CornerCrL_stand_2_alert;

	array[ "lean_aim_down" ] = %CornerStndL_lean_aim_2;
	array[ "lean_aim_left" ] = %CornerStndL_lean_aim_4;
	array[ "lean_aim_straight" ] = %CornerStndL_lean_aim_5;
	array[ "lean_aim_right" ] = %CornerStndL_lean_aim_6;
	array[ "lean_aim_up" ] = %CornerStndL_lean_aim_8;
	array[ "lean_reload" ] = %CornerStndL_lean_reload;

	array[ "lean_idle" ] = array( %CornerStndL_lean_idle );

	array[ "lean_single" ] = %CornerStndL_lean_fire;
	//array["lean_burst"] = %CornerStndL_lean_autoburst;
	array[ "lean_fire" ] = %CornerStndL_lean_auto;

	if ( isDefined( anim.ramboAnims ) )
	{
		//array[ "rambo" ] = array( %corner_standL_rambo_set, %corner_standL_rambo_jam );
		array[ "rambo90" ] = anim.ramboAnims.coverleft90;
		array[ "rambo45" ] = anim.ramboAnims.coverleft45;
		array[ "grenade_rambo" ] = anim.ramboAnims.coverleftgrenade;
	}
	
	self.hideYawOffset = 90;
	self.a.array = array;
}


set_animarray_crouching_left()
{
	array = [];

	array[ "alert_idle" ] = %CornerCrL_alert_idle;
	array[ "alert_idle_twitch" ] = array();
	array[ "alert_idle_flinch" ] = array();

	//array["alert_to_C"] = %CornerCrL_trans_alert_2_C;
	//array["B_to_C"] = %CornerCrL_trans_B_2_C;
	//array["C_to_alert"] = %CornerCrL_trans_C_2_alert;
	//array["C_to_B"] = %CornerCrL_trans_C_2_B;
	array[ "alert_to_A" ] = array( %CornerCrL_trans_alert_2_A );
	array[ "alert_to_B" ] = array( %CornerCrL_trans_alert_2_B );
	array[ "A_to_alert" ] = array( %CornerCrL_trans_A_2_alert );
	array[ "A_to_alert_reload" ] = array();
	array[ "A_to_B" ] = array( %CornerCrL_trans_A_2_B );
	array[ "B_to_alert" ] = array( %CornerCrL_trans_B_2_alert );
 	array[ "B_to_alert_reload" ] = array();
	array[ "B_to_A" ] = array( %CornerCrL_trans_B_2_A );
	array[ "lean_to_alert" ] = array( %CornerCrL_lean_2_alert );
	array[ "alert_to_lean" ] = array( %CornerCrL_alert_2_lean );
	
	array[ "look" ] = %CornerCrL_look_fast;
	array[ "reload" ] = array( %CornerCrL_reloadA, %CornerCrL_reloadB );
	array[ "grenade_safe" ] = %CornerCrL_grenadeA;
	array[ "grenade_exposed" ] = %CornerCrL_grenadeB;

	array[ "alert_to_over" ] = array( %CornerCrL_alert_2_over );
	array[ "over_to_alert" ] = array( %CornerCrL_over_2_alert );
	array[ "over_to_alert_reload" ] = array();
	array[ "blind_fire" ] = array();

	array[ "rambo90" ] = array();
	array[ "rambo45" ] = array();

	//array["alert_to_look"] = %CornerCrL_alert_idle; // TODO
	//array["look_to_alert"] = %CornerCrL_alert_idle; // TODO
	//array["look_to_alert_fast"] = %CornerCrL_alert_idle; // TODO
	//array["look_idle"] = %CornerCrL_alert_idle; // TODO
	array[ "stance_change" ] = %CornerCrL_alert_2_stand;

	array[ "lean_aim_down" ] = %CornerCrL_lean_aim_2;
	array[ "lean_aim_left" ] = %CornerCrL_lean_aim_4;
	array[ "lean_aim_straight" ] = %CornerCrL_lean_aim_5;
	array[ "lean_aim_right" ] = %CornerCrL_lean_aim_6;
	array[ "lean_aim_up" ] = %CornerCrL_lean_aim_8;

	array[ "lean_idle" ] = array( %CornerCrL_lean_idle );

	array[ "lean_single" ] = %CornerCrL_lean_fire;
	array[ "lean_fire" ] = %CornerCrL_lean_auto;

	self.hideYawOffset = 90;
	self.a.array = array;
}

