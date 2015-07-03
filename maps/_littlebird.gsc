#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

/*QUAKED script_vehicle_littlebird_armed (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

valid ai groups are:
"first_guys" - left and right side guys that need to be on first
"left" - all left guys
"right" - all right guys
"passengers" - everybody that can unload
"default"

put this in your GSC:
maps\_littlebird::main( "vehicle_little_bird_armed" );

and these lines in your CSV:
include,vehicle_littlebird_armed
sound,vehicle_littlebird,vehicle_standard,all_sp
include,_attack_heli


defaultmdl="vehicle_little_bird_armed"
default:"vehicletype" "littlebird"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_littlebird_bench (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

valid ai groups are:
"first_guys" - left and right side guys that need to be on first
"left" - all left guys
"right" - all right guys
"passengers" - everybody that can unload
"default"

put this in your GSC:
maps\_littlebird::main( "vehicle_little_bird_bench" );

and these lines in your CSV:
include,vehicle_littlebird_bench
sound,vehicle_littlebird,vehicle_standard,all_sp

defaultmdl="vehicle_little_bird_bench"
default:"vehicletype" "littlebird"
default:"script_team" "axis"
*/


armed( model )
{
	return model == "vehicle_little_bird_armed";
}

main( model, type )
{
	if ( armed( model ) )
	{
		maps\_attack_heli::preLoad();
	}
	
	build_template( "littlebird", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_little_bird_armed" );
	build_deathmodel( "vehicle_little_bird_bench" );
	build_drive( %mi28_rotors, undefined, 0, 3.0 );

	//Bullet damage Crash and Burn, spins out of control and explodes when it reaches destination
	build_deathfx( "explosions/helicopter_explosion_secondary_small", 	"tag_engine", 	"littlebird_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.0, 		true );
	build_deathfx( "fire/fire_smoke_trail_L", 							"tag_engine", 	"littlebird_helicopter_dying_loop", 	true, 				0.05, 			true, 			0.5, 		true );
	build_deathfx( "explosions/helicopter_explosion_secondary_small",	"tag_engine", 	"littlebird_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
	build_deathfx( "explosions/helicopter_explosion_little_bird", 		undefined, 		"littlebird_helicopter_crash", 			undefined, 	undefined,	undefined, 	- 1, 			undefined, 	"stop_crash_loop_sound" );
	
	//Death by Rocket effects, explodes immediatly
	build_rocket_deathfx( "explosions/aerial_explosion_littlebird", 	"tag_deathfx", 	"littlebird_helicopter_crash",undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );

	build_deathquake( 0.8, 1.6, 2048 ); 
	build_treadfx();
	build_life( 799 );
	build_team( "axis" );
	build_mainturret();
	build_unload_groups( ::unload_groups );
	build_aianims( ::setanims, ::set_vehicle_anims ); //hi this is text
	
	randomStartDelay = randomfloatrange( 0, 1 );
	build_light( model, "white_blink", 			"TAG_LIGHT_BELLY", 		"misc/aircraft_light_white_blink", 		"running", 		randomStartDelay );
	build_light( model, "red_blink1", 			"TAG_LIGHT_TAIL1", 		"misc/aircraft_light_red_blink", 		"running", 		randomStartDelay );
	build_light( model, "red_blink2", 			"TAG_LIGHT_TAIL2", 		"misc/aircraft_light_red_blink", 		"running", 		randomStartDelay );

	mapname = getdvar( "mapname" );
	if ( !isdefined( level.script ) )
		level.script = tolower( mapname );
	
	turret = "minigun_littlebird_spinnup";
	if ( use_old_turret() )
		turret = "minigun_littlebird";
	
	build_turret( turret, "TAG_MINIGUN_ATTACH_LEFT", "vehicle_little_bird_minigun_left" );
	build_turret( turret, "TAG_MINIGUN_ATTACH_RIGHT", "vehicle_little_bird_minigun_right" );
}

use_old_turret()
{
	return ( issubstr( level.script, "oilrig" ) );
}

init_local()
{
	self endon( "death" );
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );// TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	//self.delete_on_death = true;
	self.script_badplace = false;// All helicopters dont need to create bad places
	self.dontDisconnectPaths = true; //so it can land. pathing through heli's generally not a problem
		
	// set ent flag prep_unload before the unload node.
	self thread littlebird_landing();
	thread maps\_vehicle::lights_on( "running" );

	waittillframeend; // wait for turrets to get setup	

	if ( !use_old_turret() )
	{
		foreach ( turret in self.mgturret )
		{
			turret Setautorotationdelay( 4 );
		}
	}

	if ( armed( self.model ) )
		return;

		
	self mgOff();
	foreach ( turret in self.mgturret )
	{
		turret hide();
	}
}


set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	level.scr_anim[ "generic" ][ "stage_littlebird_right" ]	 = %little_bird_premount_guy3;
	level.scr_anim[ "generic" ][ "stage_littlebird_left" ]	 = %little_bird_premount_guy3;
	
	positions = [];
	for ( i = 0;i < 8;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_pilot1";
	positions[ 1 ].sittag = "tag_pilot2";
	positions[ 2 ].sittag = "tag_detach_right";
	positions[ 3 ].sittag = "tag_detach_right";
	positions[ 4 ].sittag = "tag_detach_right";
	positions[ 5 ].sittag = "tag_detach_left";
	positions[ 6 ].sittag = "tag_detach_left";
	positions[ 7 ].sittag = "tag_detach_left";
	
	positions[ 0 ].idle[ 0 ] = %helicopter_pilot1_idle;
	positions[ 0 ].idle[ 1 ] = %helicopter_pilot1_twitch_clickpannel;
	positions[ 0 ].idle[ 2 ] = %helicopter_pilot1_twitch_lookback;
	positions[ 0 ].idle[ 3 ] = %helicopter_pilot1_twitch_lookoutside;
	positions[ 0 ].idleoccurrence[ 0 ] = 500;
	positions[ 0 ].idleoccurrence[ 1 ] = 100;
	positions[ 0 ].idleoccurrence[ 2 ] = 100;
	positions[ 0 ].idleoccurrence[ 3 ] = 100;

	positions[ 1 ].idle[ 0 ] = %helicopter_pilot2_idle;
	positions[ 1 ].idle[ 1 ] = %helicopter_pilot2_twitch_clickpannel;
	positions[ 1 ].idle[ 2 ] = %helicopter_pilot2_twitch_lookoutside;
	positions[ 1 ].idle[ 3 ] = %helicopter_pilot2_twitch_radio;
	positions[ 1 ].idleoccurrence[ 0 ] = 450;
	positions[ 1 ].idleoccurrence[ 1 ] = 100;
	positions[ 1 ].idleoccurrence[ 2 ] = 100;
	positions[ 1 ].idleoccurrence[ 3 ] = 100;

	positions[ 2 ].idle[ 0 ] = %little_bird_casual_idle_guy1;
	positions[ 3 ].idle[ 0 ] = %little_bird_casual_idle_guy3;
	positions[ 4 ].idle[ 0 ] = %little_bird_casual_idle_guy2;
	positions[ 5 ].idle[ 0 ] = %little_bird_casual_idle_guy1;
	positions[ 6 ].idle[ 0 ] = %little_bird_casual_idle_guy3;
	positions[ 7 ].idle[ 0 ] = %little_bird_casual_idle_guy2;
	positions[ 2 ].idleoccurrence[ 0 ] = 100;
	positions[ 3 ].idleoccurrence[ 0 ] = 166;
	positions[ 4 ].idleoccurrence[ 0 ] = 122;
	positions[ 5 ].idleoccurrence[ 0 ] = 177;
	positions[ 6 ].idleoccurrence[ 0 ] = 136;
	positions[ 7 ].idleoccurrence[ 0 ] = 188;

	positions[ 2 ].idle[ 1 ] = %little_bird_aim_idle_guy1;
	positions[ 3 ].idle[ 1 ] = %little_bird_aim_idle_guy3;
	positions[ 4 ].idle[ 1 ] = %little_bird_aim_idle_guy2;
	positions[ 5 ].idle[ 1 ] = %little_bird_aim_idle_guy1;
//	positions[ 6 ].idle[ 1 ] = %little_bird_aim_idle_guy3;
	positions[ 7 ].idle[ 1 ] = %little_bird_aim_idle_guy2;
	positions[ 2 ].idleoccurrence[ 1 ] = 200;
	positions[ 3 ].idleoccurrence[ 1 ] = 266;
	positions[ 4 ].idleoccurrence[ 1 ] = 156;
	positions[ 5 ].idleoccurrence[ 1 ] = 277;
//	positions[ 6 ].idleoccurrence[ 1 ] = 246;
	positions[ 7 ].idleoccurrence[ 1 ] = 288;

	positions[ 2 ].idle_alert = %little_bird_alert_idle_guy1;
	positions[ 3 ].idle_alert = %little_bird_alert_idle_guy3;
	positions[ 4 ].idle_alert = %little_bird_alert_idle_guy2;

	positions[ 5 ].idle_alert = %little_bird_alert_idle_guy1;
	positions[ 6 ].idle_alert = %little_bird_alert_idle_guy3;
	positions[ 7 ].idle_alert = %little_bird_alert_idle_guy2;

	positions[ 2 ].idle_alert_to_casual = %little_bird_alert_2_aim_guy1;
	positions[ 3 ].idle_alert_to_casual = %little_bird_alert_2_aim_guy3;
	positions[ 4 ].idle_alert_to_casual = %little_bird_alert_2_aim_guy2;
                                                                   
	positions[ 5 ].idle_alert_to_casual = %little_bird_alert_2_aim_guy1;
	positions[ 6 ].idle_alert_to_casual = %little_bird_alert_2_aim_guy3;
	positions[ 7 ].idle_alert_to_casual = %little_bird_alert_2_aim_guy2;

	positions[ 2 ].getout = %little_bird_dismount_guy1;
	positions[ 3 ].getout = %little_bird_dismount_guy3;
	positions[ 4 ].getout = %little_bird_dismount_guy2;
	positions[ 5 ].getout = %little_bird_dismount_guy1;
	positions[ 6 ].getout = %little_bird_dismount_guy3;
	positions[ 7 ].getout = %little_bird_dismount_guy2;

	positions[ 2 ].littlebirde_getout_unlinks = true;
	positions[ 3 ].littlebirde_getout_unlinks = true;
	positions[ 4 ].littlebirde_getout_unlinks = true;
	
	positions[ 5 ].littlebirde_getout_unlinks = true;
	positions[ 6 ].littlebirde_getout_unlinks = true;
	positions[ 7 ].littlebirde_getout_unlinks = true;

	positions[ 2 ].getin = %little_bird_mount_guy1;
	positions[ 2 ].getin_enteredvehicletrack = "mount_finish";
	positions[ 3 ].getin = %little_bird_mount_guy3;
	positions[ 3 ].getin_enteredvehicletrack = "mount_finish";
	positions[ 4 ].getin = %little_bird_mount_guy2;
	positions[ 4 ].getin_enteredvehicletrack = "mount_finish";
	positions[ 5 ].getin = %little_bird_mount_guy1;
	positions[ 5 ].getin_enteredvehicletrack = "mount_finish";
	positions[ 6 ].getin = %little_bird_mount_guy3;
	positions[ 6 ].getin_enteredvehicletrack = "mount_finish";
	positions[ 7 ].getin = %little_bird_mount_guy2;
	positions[ 7 ].getin_enteredvehicletrack = "mount_finish";
	
	positions[ 2 ].getin_idle_func = ::guy_idle_alert;
	positions[ 3 ].getin_idle_func = ::guy_idle_alert;
	positions[ 4 ].getin_idle_func = ::guy_idle_alert;
	positions[ 5 ].getin_idle_func = ::guy_idle_alert;
	positions[ 6 ].getin_idle_func = ::guy_idle_alert;
	positions[ 7 ].getin_idle_func = ::guy_idle_alert;

	positions[ 2 ].pre_unload = %little_bird_aim_2_prelanding_guy1;
	positions[ 3 ].pre_unload = %little_bird_aim_2_prelanding_guy3;
	positions[ 4 ].pre_unload = %little_bird_aim_2_prelanding_guy2;
	                                                                 
	positions[ 5 ].pre_unload = %little_bird_aim_2_prelanding_guy1;
	positions[ 6 ].pre_unload = %little_bird_aim_2_prelanding_guy3;
	positions[ 7 ].pre_unload = %little_bird_aim_2_prelanding_guy2;

	positions[ 2 ].pre_unload_idle = %little_bird_prelanding_idle_guy1;
	positions[ 3 ].pre_unload_idle = %little_bird_prelanding_idle_guy3;
	positions[ 4 ].pre_unload_idle = %little_bird_prelanding_idle_guy2;
	
	positions[ 5 ].pre_unload_idle = %little_bird_prelanding_idle_guy1;
	positions[ 6 ].pre_unload_idle = %little_bird_prelanding_idle_guy3;
	positions[ 7 ].pre_unload_idle = %little_bird_prelanding_idle_guy2;
	
	positions[ 0 ].bHasGunWhileRiding = false;
	positions[ 1 ].bHasGunWhileRiding = false;

	return positions;

}


unload_groups()
{
	unload_groups = [];
	unload_groups[ "first_guy_left" ] = [];
	unload_groups[ "first_guy_right" ] = [];

	unload_groups[ "left" ] = [];
	unload_groups[ "right" ] = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "default" ] = [];

	unload_groups[ "first_guy_left" ][ 0 ] = 5;
	unload_groups[ "first_guy_right" ][ 0 ] = 2;
	
	unload_groups[ "stage_guy_left" ][ 0 ] = 7;
	unload_groups[ "stage_guy_right" ][ 0 ] = 4;

	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 5;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 6;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 7;
	
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 3;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 4;
	
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 2;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 3;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 4;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 5;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 6;
	unload_groups[ "passengers" ][ unload_groups[ "passengers" ].size ] = 7;

	unload_groups[ "default" ] = unload_groups[ "passengers" ];

	return unload_groups;
}

