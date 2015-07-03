#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "harrier", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_av8b_harrier_jet" );

	//special for harrier/////
	level._effect[ "engineeffect" ]				= loadfx( "fire/jet_afterburner_harrier" );
	level._effect[ "afterburner" ]				= loadfx( "fire/jet_afterburner_ignite" );
	level._effect[ "contrail" ]					= loadfx( "smoke/jet_contrail" );
	////////////////////////

	build_deathfx( "explosions/aerial_explosion_harrier", "tag_deathfx", "explo_metal_rand", undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	build_life( 999, 500, 1500 );
	build_rumble( "mig_rumble", 0.05, 0.2, 7500, 0.05, 0.05 );
	build_team( "allies" );
	build_compassicon( "harrier", false );
	build_treadfx();
	
	build_light( model, "wingtip_green", 	"tag_light_L_wing", 	"misc/aircraft_light_wingtip_green", 	"running", 		0.00 );
	build_light( model, "wingtip_red", 		"tag_light_R_wing", 	"misc/aircraft_light_wingtip_red", 		"running", 		0.05 );
	build_light( model, "white_blink_tail", "TAG_LIGHT_TAIL", 		"misc/aircraft_light_white_blink", 		"running", 		0.10 );
	build_light( model, "white_blink_tail", "TAG_LIGHT_BELLY", 		"misc/aircraft_light_red_blink", 		"running", 		0.15 );

}

init_local()
{
	thread playEngineEffects();
	maps\_vehicle::lights_on( "running" );
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
	return positions;
}


#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();

	return positions;
}

playEngineEffects()
{
	self endon( "death" );
	self endon( "stop_engineeffects" );

	self ent_flag_init( "engineeffects" );
	self ent_flag_set( "engineeffects" );
	engineeffects = getfx( "engineeffect" );

	for ( ;; )
	{
		self ent_flag_wait( "engineeffects" );
		playfxontag( engineeffects, self, "tag_engine_right" );
		playfxontag( engineeffects, self, "tag_engine_left" );
		wait .05;
		playfxontag( engineeffects, self, "tag_engine_right2" );
		playfxontag( engineeffects, self, "tag_engine_left2" );
		self ent_flag_waitopen( "engineeffects" );
		StopFXOnTag( engineeffects, self, "tag_engine_left" );
		StopFXOnTag( engineeffects, self, "tag_engine_right" );
		wait .05;
		StopFXOnTag( engineeffects, self, "tag_engine_left2" );
		StopFXOnTag( engineeffects, self, "tag_engine_right2" );
	}
}

playerisinfront( other )
{
		forwardvec = anglestoforward( flat_angle( other.angles ) );
		normalvec = vectorNormalize( flat_origin( level.player.origin ) - other.origin );
		dot = vectordot( forwardvec, normalvec );
		if ( dot > 0 )
			return true;
		else
			return false;
}

plane_sound_node()
{
		self waittill( "trigger", other );
		other endon( "death" );
		self thread plane_sound_node();// spawn new thread for next plane that passes through this pathnode
		other thread play_loop_sound_on_entity( "veh_mig29_dist_loop" );
		while ( playerisinfront( other ) )
			wait .05;
		wait .5;// little delay for the boom
		other thread play_sound_in_space( "veh_mig29_sonic_boom" );
		other waittill( "reached_end_node" );
		other stop_sound( "veh_mig29_dist_loop" );
		other delete();
}

stop_sound( alias )
{
	self notify( "stop sound" + alias );
}


/*QUAKED script_vehicle_harrier (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_harrier::main( "vehicle_av8b_harrier_jet" );

and these lines in your CSV:
include,vehicle_harrier
sound,vehicle_harrier,vehicle_standard,all_sp


defaultmdl="vehicle_av8b_harrier_jet"
default:"vehicletype" "harrier"
default:"script_team" "allies"
*/
