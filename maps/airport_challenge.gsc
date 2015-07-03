#include maps\_utility;
#include common_scripts\utility;
#include maps\_riotshield;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#include maps\airport_code;
#include maps\airport;

ap_ch_main()
{
	flag_init( "game_type_challenge" );
	
	//CHALLENGES
	//add_start( "challenge_tarmac_ggs",	::start_challenge_ggs, 	"[challenge 1] -> Airport Tarmac: Play as riotshield police" );
}

start_challenge_ggs()
{
	add_global_spawn_function( "axis", ::switch_teams );
	add_global_spawn_function( "allies", ::switch_teams );
	start_common_ap_ch();
	
	activate_trigger( "tarmac_enemies_wave1", "target" );
	
	foreach( player in level.players )
	{
		player.maxhealth = 100;	
		player.health = 100;	
	}
		
	ap_teleport_player();
	ap_teleport_team( getstructarray( "tarmac_start_nodes", "targetname" ) );
	
	thread tarmac_main();
}

start_common_ap_ch()
{	
	flag_set( "game_type_challenge" );
	
	array_thread( getentarray( "team", "targetname" ), ::add_spawn_function, ::team_init );
	array_thread( getentarray( "team", "targetname" ), ::add_spawn_function, ::team_init_ch );
	activate_trigger( "team", "target" );
	thread flag_set_delayed( "team_initialized", .05 );
		
	ai = getaiarray( "allies" );
	foreach( actor in ai )
	{
		if( actor is_hero() )
			continue;
		actor delete();			
	}
}

team_init_ch()
{
	wait .05;
	self thread stop_magic_bullet_shield();
	self thread unmake_hero();	
}

switch_teams()
{
	if( self.team == "axis" )
		self.team = "allies";
	else
		self.team = "axis";
}