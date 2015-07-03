#include maps\_props;

#using_animtree( "generic_human" );
main()
{
	level.scr_anim[ "generic" ][ "sleep_idle" ][ 0 ]			 = %parabolic_guard_sleeper_idle;
	level.scr_anim[ "generic" ][ "sleep_react" ]				 = %parabolic_guard_sleeper_react;
	script_models();
}

#using_animtree( "script_model" );
script_models()
{
	level.scr_anim[ "chair" ][ "sleep_react" ]					 = %parabolic_guard_sleeper_react_chair;
	level.scr_animtree[ "chair" ] 								 = #animtree;
	level.scr_model[ "chair" ] 									 = "com_folding_chair";
}
