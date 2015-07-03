#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_anim;


#using_animtree( "vehicles" );
main( model, type, no_death )
{
	//precachemodel( "fastrope_arms" );
	
	build_template( "blackhawk_minigun", model, type );
	build_localinit( ::init_local );

	//build_deathmodel( "vehicle_blackhawk_minigun_hero" );

	build_drive( %bh_rotors, undefined, 0 );

	if ( !isdefined( no_death ) )
	{
		blackhawk_death_fx = [];
		blackhawk_death_fx[ "vehicle_blackhawk_minigun_low" ] 					 = "explosions/helicopter_explosion";
		blackhawk_death_fx[ "vehicle_blackhawk_minigun_hero" ] 					 = "explosions/helicopter_explosion";

		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_engine_left", 		"blackhawk_helicopter_hit", 			undefined, 			undefined, 		undefined, 		0.2, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"elevator_jnt", 		"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.5, 		true );
		build_deathfx( "fire/fire_smoke_trail_L", 								"elevator_jnt", 		"blackhawk_helicopter_dying_loop", 		true, 				0.05, 			true, 			0.5, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_engine_right", 	"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_deathfx", 			"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		4.0 );
		build_deathfx( blackhawk_death_fx[ model ], 								undefined, 			"blackhawk_helicopter_crash", 			undefined, 			undefined, 		undefined, 		 - 1, 		undefined, 	"stop_crash_loop_sound" );

		build_rocket_deathfx( "explosions/aerial_explosion_heli_large", 	"tag_deathfx", 	"blackhawk_helicopter_crash",undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );
	}

	build_treadfx();

	build_life( 999, 500, 1500 );

	build_team( "allies" );

	build_aianims( ::setanims, ::set_vehicle_anims );

	build_attach_models( ::set_attached_models );

	build_unload_groups( ::Unload_Groups );
	build_compassicon( "helicopter", false );


	randomStartDelay = randomfloatrange( 0, 1 );
	build_light( model, "cockpit_blue_cargo01", 	"tag_light_cargo01", 	"misc/aircraft_light_cockpit_red", 		"interior", 	0.0 );
	build_light( model, "cockpit_blue_cockpit01", 	"tag_light_cockpit01", 	"misc/aircraft_light_cockpit_blue", 	"interior", 	0.0 );
	build_light( model, "white_blink", 				"tag_light_belly", 		"misc/aircraft_light_white_blink", 		"running", 	randomStartDelay );
	build_light( model, "white_blink_tail", 		"tag_light_tail", 		"misc/aircraft_light_white_blink", 		"running", 	randomStartDelay );
	build_light( model, "wingtip_green", 			"tag_light_L_wing", 	"misc/aircraft_light_wingtip_green", 	"running", 	randomStartDelay );
	build_light( model, "wingtip_red", 				"tag_light_R_wing", 	"misc/aircraft_light_wingtip_red", 		"running", 	randomStartDelay );

}

init_local()
{
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );// TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	//self.originheightoffset = 256;
	self.fastropeoffset = 762;// TODO - FIXME: this is ugly. If only there were a getanimendorigin() command

	self.script_badplace = false;// All helicopters dont need to create bad places
	//maps\_vehicle::lights_on( "running" );
	//maps\_vehicle::lights_on( "interior" ); 
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
//	positions[ 0 ].vehicle_getinanim = %tigertank_hatch_open;

	for ( i = 0;i < positions.size;i++ )
		positions[ i ].vehicle_getoutanim = %bh_idle;

	return positions;
}

//#using_animtree( "fastrope" );
//setplayer_anims( positions )
//{
//	positions[ 3 ].player_idle = %bh_player_idle;
//	positions[ 3 ].player_getout_sound = "fastrope_start_plr";
//	positions[ 3 ].player_getout_sound_loop = "fastrope_loop_plr";
//	positions[ 3 ].player_getout_sound_end = "fastrope_end_plr";
//
//	positions[ 3 ].player_getout = %bh_player_drop;
//	//positions[ 3 ].player_getout = %bh_2_drop;
//	positions[ 3 ].player_animtree = #animtree;
//
//
//	positions[ 2 ].player_idle = %bh_player_idle;
//	positions[ 2 ].player_getout_sound = "fastrope_start_plr";
//	positions[ 2 ].player_getout_sound_loop = "fastrope_loop_plr";
//	positions[ 2 ].player_getout_sound_end = "fastrope_end_plr";
//
//	positions[ 2 ].player_getout = %bh_player_drop;
//	positions[ 2 ].player_animtree = #animtree;
//
//	positions[ 6 ].player_idle = %bh_player_idle;
//	positions[ 6 ].player_getout_sound = "fastrope_start_plr";
//	positions[ 6 ].player_getout_sound_loop = "fastrope_loop_plr";
//	positions[ 6 ].player_getout_sound_end = "fastrope_end_plr";
//
//	positions[ 6 ].player_getout = %bh_player_drop;
//	//positions[ 6 ].player_getout = %bh_player_drop_P1;
//	//positions[ 6 ].player_getout = %bh_player_drop_P2;
//	positions[ 6 ].player_animtree = #animtree;
//
//	return positions;
//}

//#using_animtree( "generic_human" );
//
//set_coop_player_anims( positions )
//{
//	//positions[ 3 ].player_getout = %bh_player_drop;
//	positions[ 3 ].player_getout = %bh_2_drop;
//	positions[ 3 ].player_animtree = #animtree;
//
//	//positions[ 6 ].player_getout = %bh_player_drop;
//	positions[ 6 ].player_getout = %bh_8_drop;
//	positions[ 6 ].player_animtree = #animtree;
//
//	return positions;
//}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 8;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].idle = %bh_Pilot_idle;
	positions[ 1 ].idle = %bh_coPilot_idle;

	// 1, 2, 4, 5, 8,  6
	positions[ 2 ].idle = %bh_1_idle;
	positions[ 3 ].idle = %bh_2_idle;
	positions[ 4 ].idle = %bh_4_idle;
	positions[ 5 ].idle = %bh_5_idle;
	positions[ 6 ].idle = %bh_8_idle;
	positions[ 7 ].idle = %bh_6_idle;


	positions[ 0 ].sittag = "tag_detach";
	positions[ 1 ].sittag = "tag_detach";
	positions[ 2 ].sittag = "tag_detach";
	positions[ 3 ].sittag = "tag_detach";
	positions[ 4 ].sittag = "tag_detach";
	positions[ 5 ].sittag = "tag_detach";
	positions[ 6 ].sittag = "tag_detach";
	positions[ 7 ].sittag = "tag_detach";


	// 1, 2, 4, 5, 8,  6
	positions[ 2 ].getout = %bh_1_drop;
	positions[ 3 ].getout = %bh_2_drop;
	positions[ 4 ].getout = %bh_4_drop;
	positions[ 5 ].getout = %bh_5_drop;
	positions[ 6 ].getout = %bh_8_drop;
	positions[ 7 ].getout = %bh_6_drop;

	positions[ 2 ].getoutstance = "crouch";
	positions[ 3 ].getoutstance = "crouch";
	positions[ 4 ].getoutstance = "crouch";
	positions[ 5 ].getoutstance = "crouch";
	positions[ 6 ].getoutstance = "crouch";
	positions[ 7 ].getoutstance = "crouch";


	positions[ 2 ].ragdoll_getout_death = true;
	positions[ 3 ].ragdoll_getout_death = true;
	positions[ 4 ].ragdoll_getout_death = true;
	positions[ 5 ].ragdoll_getout_death = true;
	positions[ 6 ].ragdoll_getout_death = true;
	positions[ 7 ].ragdoll_getout_death = true;

	positions[ 2 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 3 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 4 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 5 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 6 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 7 ].ragdoll_fall_anim = %fastrope_fall;

	positions[ 1 ].rappel_kill_achievement = 1;
	positions[ 2 ].rappel_kill_achievement = 1;
	positions[ 3 ].rappel_kill_achievement = 1;
	positions[ 4 ].rappel_kill_achievement = 1;
	positions[ 5 ].rappel_kill_achievement = 1;
	positions[ 6 ].rappel_kill_achievement = 1;
	positions[ 7 ].rappel_kill_achievement = 1;

//	positions[ 2 ].getoutsnd = "fastrope_loop_npc";
//	positions[ 3 ].getoutsnd = "fastrope_loop_npc";
//	positions[ 4 ].getoutsnd = "fastrope_loop_npc";
//	positions[ 5 ].getoutsnd = "fastrope_loop_npc";
//	positions[ 6 ].getoutsnd = "fastrope_loop_npc";
//	positions[ 7 ].getoutsnd = "fastrope_loop_npc";

	positions[ 2 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 3 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 4 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 5 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 6 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 7 ].getoutloopsnd = "fastrope_loop_npc";

	// 1, 2, 4, 5, 6, & 8
	positions[ 2 ].fastroperig = "TAG_FastRope_RI";// 1 %bh_1_drop
	positions[ 3 ].fastroperig = "TAG_FastRope_RI";	// 2 %bh_2_drop
	positions[ 4 ].fastroperig = "TAG_FastRope_LE";	// 4 %bh_4_drop
	positions[ 5 ].fastroperig = "TAG_FastRope_LE";	// 5 %bh_5_drop
	positions[ 6 ].fastroperig = "TAG_FastRope_RI";// 8 %bh_8_drop
	positions[ 7 ].fastroperig = "TAG_FastRope_LE";// 6 %bh_6_drop
	
	return positions;
	//return setplayer_anims( positions );
	//return set_coop_player_anims( positions );
}



//WIP.. posible to unload different sets of people wirh vehicle notify( "unload", set ); sets defined here.
unload_groups()
{
	unload_groups = [];
	unload_groups[ "left" ] = [];
	unload_groups[ "right" ] = [];
	unload_groups[ "both" ] = [];

	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 4;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 5;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 7;

	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 3;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 6;

	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 2;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 3;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 4;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 5;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 6;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 7;

	unload_groups[ "default" ] = unload_groups[ "both" ];

	return unload_groups;

}


set_attached_models()
{
	array = [];
	array[ "TAG_FastRope_LE" ] = spawnstruct();
	array[ "TAG_FastRope_LE" ].model = "rope_test";
	array[ "TAG_FastRope_LE" ].tag = "TAG_FastRope_LE";
	array[ "TAG_FastRope_LE" ].idleanim = %bh_rope_idle_le;
	array[ "TAG_FastRope_LE" ].dropanim = %bh_rope_drop_le;

	array[ "TAG_FastRope_RI" ] = spawnstruct();
	array[ "TAG_FastRope_RI" ].model = "rope_test_ri";
	array[ "TAG_FastRope_RI" ].tag = "TAG_FastRope_RI";
	array[ "TAG_FastRope_RI" ].idleanim = %bh_rope_idle_ri;
	array[ "TAG_FastRope_RI" ].dropanim = %bh_rope_drop_ri;

	strings = getarraykeys( array );

	for ( i = 0;i < strings.size;i++ )
	{
		precachemodel( array[ strings[ i ] ].model );
	}

	return array;
}


//use this function to fastrope the player out of the heli from the gunner position

//blackhawk_minigun_player_fastrope_think()
//{
//	animfudgetime = 0;
//	position = 3;
//	AssertMessage = "In order for the player to fastrope out of the heli at " + self.origin + ", it must have at least one vehicle rider in script_startingposition '" + position + "' with script_drone set to '1' and 'drone_delete_on_unload' set to '1'";
//	self endon( "death" );
//	/*-----------------------
//	FIND THE RIDER THE PLAYER WILL POSESS
//	-------------------------*/
//	dummy = undefined;
//	assertex( isdefined( self.riders ), AssertMessage );
//	foreach ( AI in self.riders )
//	{
//		if ( AI.vehicle_position == position )
//		{
//			dummy = AI;
//			dummy.drone_delete_on_unload = true;
//			dummy.playerpiggyback = true;
//			break;
//		}
//	}
//	assertex( isdefined( dummy ), AssertMessage );
//	assertex( !isai( dummy ), AssertMessage );
//	animpos = maps\_vehicle_aianim::anim_pos( self, position );
//
//	/*-----------------------
//	HIDE THE DUMMY RIDER
//	-------------------------*/
//	dummy notsolid();
//	dummy notify( "newanim" );
//	dummy detachall();
//	dummy setmodel( "fastrope_arms" );
//	dummy useanimtree( animpos.player_animtree );
//	dummy hide();
//	thread maps\_vehicle_aianim::guy_idle( dummy, position );
//	wait .1;
//
//	animtime = getanimlength( animpos.getout );
//	animtime -= animfudgetime;
//
//	/*-----------------------
//	LERP PLAYER VIEW TO DUMMY FASTROPING
//	-------------------------*/
//	self waittill( "unloading" );
//	self player_dismount_blackhawk_gun();
//	level.player PlayerLinkToBlend( dummy, "tag_player", 1, 0, 0 );
//	//dummy lerp_player_view_to_tag( level.player, "tag_player", 1, 1, 30, 30, 30, 30 );
//	
//								//( <linkto entity>, <tag>, <viewpercentag fraction>, <right arc>, <left arc>, <top arc>, <bottom arc>, <use tag angles> )
//	//level.player playerlinktodelta( dummy, "tag_player", 0.35, 60, 28, 30, 30, false );
//	
//	//dummy show();
//
//	wait animtime;
//
//	level.player unlink();
//	thread hud_hide( false );
//	level.player enableweapons();
//   	level.player allowprone( true );
//   	level.player allowcrouch( true );
//   	
//   	self notify( "player_fastroped_out" );
//}


player_mount_blackhawk_gun( nolerp, player, hide_hud )
{
	if( !IsDefined( player ) )
	{
		player = level.player;
	}

	self.minigunUser = player;
	
	//self ==> the vehicle being used by the player
	if ( !isdefined( hide_hud ) )
		hide_hud = true;
	thread hud_hide( hide_hud );
   	player allowprone( false );
   	player allowcrouch( false );
    if ( !isdefined( nolerp ) )
    {
    	player disableWeapons();
    		//lerp_player_view_to_tag( player, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc )
    	self lerp_player_view_to_tag( player, "tag_player", 1, 1, 30, 30, 30, 30 );

    }

	self useby( player );
	tagAngles = self gettagangles( "tag_player" );
	player setplayerangles( tagAngles + ( 0, 0, 0 ) );	
	flag_set( "player_on_minigun" );
	self thread maps\_minigun::minigun_think();
	//thread maps\_minigun::minigun_hints_on();
}

player_dismount_blackhawk_gun()
{
	//self ==> the vehicle being used by the player
	self useby( self.minigunUser );
	self.minigunUser unlink();
	level notify( "player_off_blackhawk_gun" );
	//level.player playerlinktodelta( self, "tag_player", 1, 50, 50, 30, 45 );
	//wait( .05 );
	//self turret_reset();
	//thread maps\_minigun::minigun_hints_off();
	//self lerp_player_view_to_tag( "tag_turret_exit", 1, 0.9, 25, 25, 45, 0 );
   // level.player unlink();
    //level.player enableWeapons();

	//level.player DisableInvulnerability();
   	//level.player allowprone( true );
   	//level.player allowcrouch( true );
	//flag_set( "player_off_minigun" );
}



hud_hide( state )
{
	wait 0.05;
	if ( state )
	{
		setsaveddvar( "ui_hidemap", 1 );
		SetSavedDvar( "hud_showStance", "0" );
		SetSavedDvar( "compass", "0" );
		SetDvar( "old_compass", "0" );
		SetSavedDvar( "ammoCounterHide", "1" );
	}
	else
	{
		setsaveddvar( "ui_hidemap", 0 );
		setSavedDvar( "hud_drawhud", "1" );
		SetSavedDvar( "hud_showStance", "1" );
		SetSavedDvar( "compass", "1" );
		SetDvar( "old_compass", "1" );
		SetSavedDvar( "ammoCounterHide", "0" );
	}
}
