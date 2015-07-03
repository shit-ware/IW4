#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );


/*QUAKED script_vehicle_suburban_minigun_viewmodel (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_suburban_minigun::main( "vehicle_suburban_minigun_viewmodel" );

and these lines in your CSV:
include,vehicle_suburban_minigun_viewmodel
sound,vehicle_pickup,vehicle_standard,all_sp
sound,weapon_minigun,vehicle_standard,all_sp


defaultmdl="vehicle_suburban_minigun_viewmodel"
default:"vehicletype" "suburban_minigun"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_suburban_minigun_technical (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_suburban_minigun::main( "vehicle_suburban_technical" );

and these lines in your CSV:
include,vehicle_suburban_minigun_technical
sound,vehicle_pickup,vehicle_standard,all_sp
sound,weapon_minigun,vehicle_standard,all_sp


defaultmdl="vehicle_suburban_technical"
default:"vehicletype" "suburban_minigun"
default:"script_team" "allies"
*/

main( model, type )
{
	build_template( "suburban_minigun", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_suburban_minigun_viewmodel", "vehicle_suburban_destroyed" );
	build_deathmodel( "vehicle_suburban_technical", "vehicle_suburban_destroyed" );

	build_deathfx( "fire/firelp_med_pm", "TAG_CAB_FIRE", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( "explosions/vehicle_explosion_suburban_minigun", "TAG_DEATH_FX", "explo_metal_rand" );

	build_drive( %technical_driving_idle_forward, %technical_driving_idle_backward, 10 );
	build_treadfx();
	//build_life( 100 );
	build_life( 3000, 500, 3000 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::Unload_Groups );

	build_turret( "suburban_minigun", "tag_turret", "weapon_suburban_minigun", undefined, "sentry", 0.2 );
	build_bulletshield( true ); // minigun vehicle is bulletproof

	build_radiusdamage( ( 0, 0, 32 ), 300, 200, 0, false );
}

init_local()
{

}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
/*	positions[ 0 ].vehicle_getoutanim = %uaz_driver_exit_into_run_door;
	positions[ 1 ].vehicle_getoutanim = %uaz_rear_driver_exit_into_run_door;
	positions[ 2 ].vehicle_getoutanim = %uaz_passenger_exit_into_run_door;
	positions[ 3 ].vehicle_getoutanim = %uaz_passenger2_exit_into_run_door;

	positions[ 0 ].vehicle_getinanim = %uaz_driver_enter_from_huntedrun_door;
	positions[ 1 ].vehicle_getinanim = %uaz_rear_driver_enter_from_huntedrun_door;
	positions[ 2 ].vehicle_getinanim = %uaz_passenger_enter_from_huntedrun_door;
	positions[ 3 ].vehicle_getinanim = %uaz_passenger2_enter_from_huntedrun_door;
*/
	positions[ 0 ].vehicle_getoutanim = %suburban_dismount_frontL_door;
	positions[ 1 ].vehicle_getoutanim = %suburban_dismount_frontR_door;
	positions[ 2 ].vehicle_getoutanim = %suburban_dismount_backL_door;
	positions[ 3 ].vehicle_getoutanim = %suburban_dismount_backR_door;

	return positions;
}


#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 7;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy1";
	positions[ 3 ].sittag = "tag_guy2";
	positions[ 4 ].sittag = "tag_guy3";
	positions[ 5 ].sittag = "tag_guy4";
	positions[ 6 ].sittag = "tag_guy_turret";

	// new idles
	positions[ 0 ].idle = %suburban_idle_frontL;
	positions[ 1 ].idle = %suburban_idle_frontR;
	positions[ 2 ].idle = %suburban_idle_backL;
	positions[ 3 ].idle = %suburban_idle_backR;
	// old anims for pos 4 and 5.
	positions[ 4 ].idle = %humvee_passenger_idle_R;
	positions[ 5 ].idle = %humvee_passenger_idle_L;

	// new exits
	positions[ 0 ].getout = %suburban_dismount_frontL;
	positions[ 1 ].getout = %suburban_dismount_frontR;
	positions[ 2 ].getout = %suburban_dismount_backL;
	positions[ 3 ].getout = %suburban_dismount_backR;
	// old anims for pos 4 and 5. These won't work correctly
	positions[ 4 ].getout = %humvee_passenger_out_L;
	positions[ 5 ].getout = %humvee_passenger_out_R;

	// turret gunner
	positions[ 6 ].getout = %humvee_turret_2_passenger;
	positions[ 6 ].exittag = "tag_passenger";
	positions[ 6 ].getout_secondary = %humvee_passenger_out_R;
	positions[ 6 ].getout_secondary_tag = "tag_passenger";

	positions[ 0 ].getin = %humvee_driver_climb_in;
	positions[ 1 ].getin = %humvee_passenger_in_R;
	positions[ 2 ].getin = %humvee_passenger_in_R;
	positions[ 3 ].getin = %humvee_passenger_in_L;
	positions[ 4 ].getin = %humvee_passenger_in_L;
	positions[ 5 ].getin = %humvee_passenger_in_R;
	positions[ 6 ].getin = %humvee_passenger_in_R; // turret guy

	positions[ 6 ].mgturret = 0;// which of the turrets is this guy going to use

	return positions;

/*	OLD ANIMS
	positions[ 0 ].idle[ 0 ] = %humvee_driver_twitch_1;
	positions[ 0 ].idle[ 1 ] = %humvee_driver_climb_idle;
	positions[ 0 ].idleoccurrence[ 0 ] = 100;
	positions[ 0 ].idleoccurrence[ 1 ] = 1000;

//	positions[ 0 ].death = %uaz_driver_death; removed this so that the driver can't die.

	positions[ 1 ].idle[ 0 ] = %humvee_passenger_twitch_1_R;
	positions[ 1 ].idle[ 1 ] = %humvee_passenger_idle_L;
	positions[ 1 ].idleoccurrence[ 0 ] = 100;
	positions[ 1 ].idleoccurrence[ 1 ] = 1000;

	positions[ 2 ].idle = %humvee_passenger_idle_L;
	positions[ 3 ].idle = %humvee_passenger_idle_R;
	positions[ 4 ].idle = %humvee_passenger_idle_R;
	positions[ 5 ].idle = %humvee_passenger_idle_L;
//	positions[ 6 ].idle = %humvee_passenger_idle_R; // no idle for the turret guy

	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_R;
	positions[ 3 ].getout = %humvee_passenger_out_L;
*/
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "all" ] = [];
	unload_groups[ "everyone" ] = [];

	group = "passengers";
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;

	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;

	// made a new group that unloades the mgguy as well as everyone else.
	// didn't want to change the current behaviour. - Roger
	group = "everyone";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
	unload_groups[ group ][ unload_groups[ group ].size ] = 6;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}
