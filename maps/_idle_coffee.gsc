#include maps\_props;

#using_animtree( "generic_human" );
main()
{
	level.scr_anim[ "generic" ][ "coffee_idle" ][ 0 ]				 = %cargoship_stunned_coffee_react_idle;
	level.scr_anim[ "generic" ][ "coffee_react" ]				 = %exposed_idle_twitch_v4;
	script_models();
}

#using_animtree( "script_model" );
script_models()
{
	level.scr_anim[ "chair" ][ "sleep_react" ]					 = %parabolic_guard_sleeper_react_chair;
	level.scr_animtree[ "chair" ] 								 = #animtree;
	level.scr_model[ "chair" ] 									 = "com_folding_chair";
}