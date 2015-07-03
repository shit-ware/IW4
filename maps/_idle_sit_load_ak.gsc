#include maps\_props;
#include maps\_anim;

#using_animtree( "generic_human" );
main()
{

	add_sit_load_ak_notetracks( "generic" );
	level.scr_anim[ "generic" ][ "sit_load_ak_idle" ][ 0 ]		= %sitting_guard_loadAK_idle;
	level.scr_anim[ "generic" ][ "sit_load_ak_react" ]			= %sitting_guard_loadAK_react1;
	addNotetrack_customFunction( "generic", "detach clip left" , ::load_ak_deathanim , "sit_load_ak_react" );
	//level.scr_anim[ "generic" ][ "phone_react" ]				= %sitting_guard_loadAK_react2;
	script_models();
}

load_ak_deathanim( guy )
{
	guy.deathanim = %exposed_death_nerve;
	
	guy endon( "death" );
	
	wait 2;
	
	guy.deathanim = undefined;
}

#using_animtree( "script_model" );
script_models()
{
	level.scr_anim[ "chair_ak" ][ "sit_load_ak_react" ]				 = %sitting_guard_loadAK_idle_chair;
	level.scr_animtree[ "chair_ak" ] 								 = #animtree;
	level.scr_model[ "chair_ak" ] 									 = "com_folding_chair";
}
