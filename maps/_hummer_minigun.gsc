#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

main( model, type, turret_type )
{
	if ( !IsDefined( type ) )
	{
		type = "hummer_minigun";
	}
	
	build_template( "hummer_minigun", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_hummer", "vehicle_hummer_destroyed" );

	build_deathfx( "fire/firelp_med_pm", "TAG_CAB_FIRE", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( "explosions/vehicle_explosion_hummer_minigun", "tag_deathfx", "car_explode", undefined, undefined, undefined, 0 );


	build_drive( %humvee_50cal_driving_idle_forward, %humvee_50cal_driving_idle_backward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::Unload_Groups );
	build_compassicon( "automobile", false );
	
//	build_turret( "minigun_hummer", "tag_turret", "weapon_suburban_minigun_no_doors", undefined, undefined, 0.2 );

	if ( !isdefined( turret_type ) )
		turret_type = "minigun_hummer";
	build_turret( turret_type, "tag_turret", "weapon_suburban_minigun_no_doors", undefined, undefined, 0.2, 20, -14 );
}

#using_animtree( "vehicles" );
init_local()
{
	if ( issubstr( self.vehicletype, "physics" ) )
	{
		anims = [];
		anims[ "idle" ] = %humvee_antennas_idle_movement;
		anims[ "rot_l" ] = %humvee_antenna_L_rotate_360;
		anims[ "rot_r" ] = %humvee_antenna_R_rotate_360;
		thread humvee_antenna_animates( anims );
		
		//thread maps\_debug::drawTagForever( "tag_antenna" );
		//thread maps\_debug::drawTagForever( "tag_antenna2" );		
	}
	
	self hidepart( "tag_blood" );
}


#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0; i < 5; i++ )
	{
		positions[ i ] = spawnstruct();
	}

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";
	positions[ 4 ].sittag = "tag_passenger";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].idle = %humvee_idle_frontL;
	positions[ 1 ].idle = %humvee_idle_frontR;
	positions[ 2 ].idle = %humvee_idle_backL;
	positions[ 3 ].idle = %humvee_idle_backR;
	
	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_L;
	positions[ 3 ].getout = %humvee_passenger_out_R;
	
	// turret gunner
	positions[ 4 ].getout = %humvee_turret_2_passenger;
	positions[ 4 ].exittag = "tag_guy1";
	positions[ 4 ].getout_secondary = %humvee_passenger_out_R;
	positions[ 4 ].getout_secondary_tag = "tag_guy1";

	positions[ 0 ].getin = %humvee_mount_frontL;
	positions[ 1 ].getin = %roadkill_hummer_mount_frontR;
	positions[ 2 ].getin = %humvee_mount_backL; 
	positions[ 3 ].getin = %humvee_mount_backR;
	positions[ 4 ].getin = %humvee_mount_frontR;
	
	
	positions[ 4 ].mgturret = 0;// which of the turrets is this guy going to use
	
	positions[ 4 ].passenger_2_turret_func = ::humvee_turret_guy_gettin_func;

	return positions;
}

humvee_turret_guy_gettin_func( vehicle, guy, pos, turret )
{
	animation = %humvee_passenger_2_turret;
	guy animscripts\hummer_turret\common::guy_goes_directly_to_turret( vehicle, pos, turret, animation );	
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
	positions[ 0 ].vehicle_getoutanim = %uaz_driver_exit_into_run_door;
	positions[ 1 ].vehicle_getoutanim = %uaz_rear_driver_exit_into_run_door;
	positions[ 2 ].vehicle_getoutanim = %uaz_passenger_exit_into_run_door;
	positions[ 3 ].vehicle_getoutanim = %uaz_passenger2_exit_into_run_door;

	positions[ 0 ].vehicle_getinanim = %humvee_mount_frontL_door;
	positions[ 1 ].vehicle_getinanim = %roadkill_hummer_mount_frontR_door;
	positions[ 2 ].vehicle_getinanim = %humvee_mount_backL_door;
	positions[ 3 ].vehicle_getinanim = %humvee_mount_backR_door;
	positions[ 4 ].vehicle_getinanim = %humvee_mount_frontR_door;
	
	positions[ 0 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 1 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 2 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 3 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 4 ].vehicle_getoutsound = "hummer_door_open";

	positions[ 0 ].vehicle_getinsound = "hummer_door_close";
	positions[ 1 ].vehicle_getinsound = "hummer_door_close";
	positions[ 2 ].vehicle_getinsound = "hummer_door_close";
	positions[ 3 ].vehicle_getinsound = "hummer_door_close";
	positions[ 4 ].vehicle_getinsound = "hummer_door_close";
	
	return positions;
}

unload_groups()
{
	unload_groups = [];

	group = "passengers";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	group = "passengers_and_gunner";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4; 	// turret gunner

	group = "all";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4; 	// turret gunner

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}


/*QUAKED script_vehicle_hummer_minigun (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_hummer_minigun::main( "vehicle_hummer" );

and these lines in your CSV:
include,vehicle_hummer_minigun
sound,weapon_minigun,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer"
default:"vehicletype" "hummer_minigun"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_minigun_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_hummer_minigun::main( "vehicle_hummer", "hummer_minigun_physics" );

and these lines in your CSV:
include,vehicle_hummer_minigun
sound,weapon_minigun,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer"
default:"vehicletype" "hummer_minigun_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_minigun_physics_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_hummer_minigun::main( "vehicle_hummer", "hummer_minigun_physics_player", "minigun_hummer_player" );

and these lines in your CSV:
include,vehicle_hummer_minigun
sound,weapon_minigun,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer"
default:"vehicletype" "hummer_minigun_physics_player"
default:"script_team" "allies"
*/
