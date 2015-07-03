#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "apache", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_apache" );
	build_deathmodel( "vehicle_apache_dark" );

	apache_death_fx = [];
	apache_death_fx[ "vehicle_apache" ] = "explosions/helicopter_explosion_apache";
	apache_death_fx[ "vehicle_apache_dark" ] = "explosions/helicopter_explosion_apache_dark";

	apache_aerial_death_fx = [];
	apache_aerial_death_fx[ "vehicle_apache" ] = "explosions/aerial_explosion_apache_mp";
	apache_aerial_death_fx[ "vehicle_apache_dark" ] = "explosions/aerial_explosion_apache_dark_mp";

	build_drive( %bh_rotors, undefined, 0 );
	
	//Bullet damage Crash and Burn, spins out of control and explodes when it reaches destination
	build_deathfx( "explosions/helicopter_explosion_secondary_small", 	"tag_engine_left", 	"apache_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.0, 		true );
	build_deathfx( "fire/fire_smoke_trail_L", 							"tag_engine_left", 	"apache_helicopter_dying_loop", 		true, 				0.05, 			true, 			0.5, 		true );
	build_deathfx( "explosions/helicopter_explosion_secondary_small",	"tag_engine_left", 	"apache_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
	build_deathfx( apache_death_fx[ model ], 							undefined, 			"apache_helicopter_crash", 			undefined, 			undefined,		undefined, 	- 1, 			undefined, 	"stop_crash_loop_sound" );

	//Death by Rocket effects, explodes immediatly
	build_rocket_deathfx( apache_aerial_death_fx[ model ], 	"tag_deathfx", 	"apache_helicopter_crash",	undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );

	//light effects
	build_light( model, "wingtip_green", 		"tag_light_L_wing", 	"misc/aircraft_light_wingtip_green", 	"running", 		0 );
	build_light( model, "wingtip_red", 			"tag_light_R_wing", 	"misc/aircraft_light_wingtip_red", 		"running", 		0.05 );
	build_light( model, "white_blink", 			"tag_light_belly", 		"misc/aircraft_light_white_blink", 		"running", 		0.1 );
	build_light( model, "white_blink_tail", 	"tag_light_tail", 		"misc/aircraft_light_red_blink", 		"running", 		0.25 );


	build_life( 999, 500, 1500 );
	build_compassicon( "helicopter", false );
	build_treadfx();


	build_team( "allies" );

}

init_local()
{
	self.script_badplace = false;// All helicopters dont need to create bad places
	maps\_vehicle::lights_on( "running" );
}

set_vehicle_anims( positions )
{

	return positions;
}


#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 11;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].getout_delete = true;

	return positions;
}



/*QUAKED script_vehicle_apache (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_apache::main( "vehicle_apache" );

and these lines in your CSV:
include,vehicle_apache_apache
sound,vehicle_apache,vehicle_standard,all_sp


defaultmdl="vehicle_apache"
default:"vehicletype" "apache"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_apache_dark (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_apache::main( "vehicle_apache_dark" );

and these lines in your CSV:
include,vehicle_apache_dark_apache
sound,vehicle_apache,vehicle_standard,all_sp


defaultmdl="vehicle_apache_dark"
default:"vehicletype" "apache"
default:"script_team" "allies"
*/

