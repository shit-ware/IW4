#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "bmp", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_bmp", "vehicle_bmp_dsty" );
	build_deathmodel( "vehicle_bmp_winter", "vehicle_bmp_woodland_dsty" );
	build_deathmodel( "vehicle_bmp_woodland", "vehicle_bmp_woodland_dsty" );
	build_deathmodel( "vehicle_bmp_woodland_low", "vehicle_bmp_dsty_low" );
	build_deathmodel( "vehicle_bmp_woodland_jeepride", "vehicle_bmp_dsty" );
	build_deathmodel( "vehicle_bmp_desert", "vehicle_bmp_dsty" );
	build_deathmodel( "vehicle_bmp_thermal", "vehicle_bmp_thermal_dsty" );
	build_deathmodel( "vehicle_bmp_low", "vehicle_bmp_dsty_low" );

	bmp_death_fx = [];
	bmp_death_fx[ "vehicle_bmp" ] = "explosions/vehicle_explosion_bmp";
	bmp_death_fx[ "vehicle_bmp_winter" ] = "explosions/vehicle_explosion_bmp";
	bmp_death_fx[ "vehicle_bmp_woodland" ] = "explosions/vehicle_explosion_bmp";
	bmp_death_fx[ "vehicle_bmp_woodland_jeepride" ] = "explosions/vehicle_explosion_bmp";
	bmp_death_fx[ "vehicle_bmp_woodland_low" ] = "explosions/vehicle_explosion_bmp_low";
	bmp_death_fx[ "vehicle_bmp_desert" ] = "explosions/vehicle_explosion_bmp";
	bmp_death_fx[ "vehicle_bmp_thermal" ] = "explosions/large_vehicle_explosion_IR";
	bmp_death_fx[ "vehicle_bmp_low" ] = "explosions/vehicle_explosion_bmp_low";

// 	build_deathfx( effect, tag,	sound, bEffectLooping, delay, bSoundlooping, waitDelay, stayontag, notifyString )
	build_deathfx( "fire/firelp_med_pm", "tag_deathfx" );
	build_deathfx( "fire/firelp_med_pm", "tag_cargofire", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( bmp_death_fx[ model ], undefined, "exp_armor_vehicle", undefined, undefined, undefined, 0 );
	build_drive( %bmp_movement, %bmp_movement_backwards, 10 );

	if ( issubstr( model, "_low" ) )
		build_turret( "bmp_turret2", "tag_turret2", "vehicle_bmp_machine_gun_low" );
	else
		build_turret( "bmp_turret2", "tag_turret2", "vehicle_bmp_machine_gun" );

	build_radiusdamage( ( 0, 0, 53 ), 512, 300, 20, false );

	build_treadfx();

	build_life( 999, 500, 1500 );

	build_team( "axis" );

	build_compassicon( "automobile", false );

	build_aianims( ::setanims, ::set_vehicle_anims );

	build_frontarmor( .33 );// regens this much of the damage from attacks to the front

	build_bulletshield( true );
	
	build_grenadeshield( true );
}

init_local()
{
	maps\_utility::ent_flag_init( "no_riders_until_unload" ); 
}

set_vehicle_anims( positions )
{

	// positions[ 0 ].vehicle_getinanim = %tigertank_hatch_open;
	// positions[ 1 ].vehicle_getoutanim = %tigertank_hatch_open;

	positions[ 0 ].vehicle_getoutanim = %bmp_doors_open;
	positions[ 0 ].vehicle_getoutanim_clear = false;
	return positions;
}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_guy1";
	positions[ 1 ].sittag = "tag_guy2";
	positions[ 2 ].sittag = "tag_guy3";
	positions[ 3 ].sittag = "tag_guy4";

	positions[ 0 ].idle = %bmp_idle_1;
	positions[ 1 ].idle = %bmp_idle_2;
	positions[ 2 ].idle = %bmp_idle_3;
	positions[ 3 ].idle = %bmp_idle_4;

	positions[ 0 ].getout = %bmp_exit_1;
	positions[ 1 ].getout = %bmp_exit_2;
	positions[ 2 ].getout = %bmp_exit_3;
	positions[ 3 ].getout = %bmp_exit_4;

	positions[ 0 ].getin = %humvee_driver_climb_in;
	positions[ 1 ].getin = %humvee_passenger_in_L;
	positions[ 2 ].getin = %humvee_passenger_in_R;
	positions[ 3 ].getin = %humvee_passenger_in_R;

	return positions;
}

/*QUAKED script_vehicle_bmp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp" );

and these lines in your CSV:
include,vehicle_bmp_bmp
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_winter_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_winter", "bmp_physics" );

and these lines in your CSV:
include,vehicle_bmp_winter
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_winter"
default:"vehicletype" "bmp_physics"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_winter (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_winter" );

and these lines in your CSV:
include,vehicle_bmp_winter
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_winter"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_desert (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_desert" );

and these lines in your CSV:
include,vehicle_bmp_desert_bmp
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_desert"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_low (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_low" );
sound,vehicle_armor_exp,vehicle_standard,all_sp

and these lines in your CSV:
include,vehicle_bmp_low_bmp
sound,vehicle_bmp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_low"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_thermal (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_thermal" );

and these lines in your CSV:
include,vehicle_bmp_thermal_bmp
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_thermal"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_woodland (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_woodland" );

and these lines in your CSV:
include,vehicle_bmp_woodland_bmp
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_woodland"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_woodland_jeepride (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_woodland_jeepride" );

and these lines in your CSV:
include,vehicle_bmp_woodland_jeepride_bmp
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_woodland_jeepride"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_bmp_woodland_low (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bmp::main( "vehicle_bmp_woodland_low" );

and these lines in your CSV:
include,vehicle_bmp_woodland_low_bmp
sound,vehicle_bmp,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bmp_woodland_low"
default:"vehicletype" "bmp"
default:"script_team" "axis"
*/