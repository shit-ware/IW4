#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "btr80", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_btr80", "vehicle_btr80_d" );
	build_deathmodel( "vehicle_btr80_snow", "vehicle_btr80_snow_d" );
	build_deathmodel( "vehicle_btr80_low", "vehicle_btr80_d" );

	btr80_death_fx = [];
	btr80_death_fx[ "vehicle_btr80" ] = "explosions/vehicle_explosion_btr80";
	btr80_death_fx[ "vehicle_btr80_snow" ] = "explosions/vehicle_explosion_btr80_snow";
	btr80_death_fx[ "vehicle_btr80_low" ] = "explosions/vehicle_explosion_btr80";
	
	build_deathfx( "fire/firelp_med_pm", "TAG_CARGOFIRE", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( btr80_death_fx[ model ], "tag_deathfx", "exp_armor_vehicle" );

	build_light( model, "headlight_L", 	"TAG_FRONT_LIGHT_LEFT", 	"misc/car_headlight_btr80", 		"running", 	0.0 );
	build_light( model, "taillight_L", 	"TAG_REAR_LIGHT_LEFT", 		"misc/car_taillight_btr80", 		"running", 	0.1 );
	build_light( model, "taillight_R", 	"TAG_REAR_LIGHT_RIGHT", 	"misc/car_taillight_btr80", 		"running", 	0.1 );

	build_light( model, "brakeight_R", 	"TAG_REAR_LIGHT_RIGHT", 	"misc/car_brakelight_btr80", 		"brake", 	0.0 );
  build_light( model, "brakelight_L", "TAG_REAR_LIGHT_LEFT", 		"misc/car_brakelight_btr80", 		"brake", 	0.0 );

	build_light( model, "spotlight", 		"TAG_FRONT_LIGHT_RIGHT","misc/spotlight_btr80", 	"spotlight", 			0.2 );
	build_light( model, "spotlight_turret", "TAG_TURRET_LIGHT", 	"misc/spotlight_btr80", 	"spotlight_turret", 	0.0 );

	build_drive( %BTR80_movement, %BTR80_movement_backwards, 10 );

	if ( issubstr( model, "_snow" ) )
		build_turret( "btr80_turret2", "tag_turret2", "vehicle_btr80_machine_gun_snow" );
	else
		build_turret( "btr80_turret2", "tag_turret2", "vehicle_btr80_machine_gun" );

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
	maps\_vehicle::lights_on( "running" );
	//self thread test_brake_lights();
}

test_brake_lights()
{
	self endon( "death");
	while ( true )
	{
		wait 5;
		maps\_vehicle::lights_on( "brake" );
		wait 3;
		maps\_vehicle::lights_off( "brake" );
	}
}

set_vehicle_anims( positions )
{

	// positions[ 0 ].vehicle_getinanim = %tigertank_hatch_open;
	// positions[ 1 ].vehicle_getoutanim = %tigertank_hatch_open;

	positions[ 0 ].vehicle_getoutanim = %BTR80_doorsL_open;
	positions[ 1 ].vehicle_getoutanim = %BTR80_doorsR_open;
	positions[ 2 ].vehicle_getoutanim = %BTR80_doorsL_open;
	positions[ 3 ].vehicle_getoutanim = %BTR80_doorsR_open;
	return positions;
}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_detach";
	positions[ 1 ].sittag = "tag_detach";
	positions[ 2 ].sittag = "tag_detach";
	positions[ 3 ].sittag = "tag_detach";

	positions[ 0 ].idle = %BTR80_crew_idle;
	positions[ 1 ].idle = %BTR80_crew_idle;
	positions[ 2 ].idle = %BTR80_crew_idle;
	positions[ 3 ].idle = %BTR80_crew_idle;

	positions[ 0 ].getout = %BTR80_exit_1; // left
	positions[ 1 ].getout = %BTR80_exit_2; // right
	positions[ 2 ].getout = %BTR80_exit_3; // left
	positions[ 3 ].getout = %BTR80_exit_4; // rigth

	positions[ 0 ].getin = %humvee_driver_climb_in;
	positions[ 1 ].getin = %humvee_passenger_in_L;
	positions[ 2 ].getin = %humvee_passenger_in_R;
	positions[ 3 ].getin = %humvee_passenger_in_R;

	return positions;
}

/*QUAKED script_vehicle_btr80 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER
Valid Light Groups:
running - taillights and tacticle headlight
brake - brighter taillight
spotlight - lower spotlight
spotlight_turret - spotlight on turret

Example Light Group Usage:
on vehicle nodes or vehicle: "script_vehicle_lights_on" "running spotlight"
on vehicle node: "script_vehicle_lights_off" "spotlight"
in script: vehicle lights_on( "spotlight" );
in script: vehicle lights_off( "spotlight" );

put this in your GSC:
maps\_btr80::main( "vehicle_btr80" );

and these lines in your CSV:
include,vehicle_btr80
sound,vehicle_btr80,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_btr80"
default:"vehicletype" "btr80"
default:"script_team" "axis"
default:"script_vehicle_lights_on" "spotlight running"
*/

/*QUAKED script_vehicle_btr80_low (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER
Valid Light Groups:
running - taillights and tacticle headlight
brake - brighter taillight
spotlight - lower spotlight
spotlight_turret - spotlight on turret

Example Light Group Usage:
on vehicle nodes or vehicle: "script_vehicle_lights_on" "running spotlight"
on vehicle node: "script_vehicle_lights_off" "spotlight"
in script: vehicle lights_on( "spotlight" );
in script: vehicle lights_off( "spotlight" );

put this in your GSC:
maps\_btr80::main( "vehicle_btr80_low" );

and these lines in your CSV:
include,vehicle_btr80_low
sound,vehicle_btr80,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_btr80_low"
default:"vehicletype" "btr80"
default:"script_team" "axis"
default:"script_vehicle_lights_on" "spotlight running"
*/

/*QUAKED script_vehicle_btr80_snow (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_btr80::main( "vehicle_btr80_snow" );

and these lines in your CSV:
include,vehicle_btr80_snow
sound,vehicle_btr80,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_btr80_snow"
default:"vehicletype" "btr80"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_btr80_snow_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_btr80::main( "vehicle_btr80_snow", "btr80_physics"  );

and these lines in your CSV:
include,vehicle_btr80_snow
sound,vehicle_btr80,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_btr80_snow"
default:"vehicletype" "btr80_physics"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_btr80_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_btr80::main( "vehicle_btr80", "btr80_physics" );

and these lines in your CSV:
include,vehicle_btr80
sound,vehicle_btr80,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_btr80"
default:"vehicletype" "btr80_physics"
default:"script_team" "axis"
*/
