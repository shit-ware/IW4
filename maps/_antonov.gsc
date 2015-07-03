#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "antonov", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_antonov_fly" );

	level._effect[ "engineeffect" ]				= loadfx( "fire/jet_engine_anatov" );

	build_deathfx( "explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_life( 999, 500, 1500 );
	build_rumble( "mig_rumble", 0.1, 0.2, 11300, 0.05, 0.05 );
	build_team( "allies" );
	build_compassicon( "plane", false );

	randomStartDelay = randomfloatrange( 0, 1 );
	build_light( model, "wingtip_green", 	"TAG_LEFT_WINGTIP", 	"misc/aircraft_light_wingtip_green", 	"running", 		randomStartDelay );
	build_light( model, "wingtip_red", 		"TAG_RIGHT_WINGTIP", 	"misc/aircraft_light_wingtip_red", 		"running", 		randomStartDelay );
	build_light( model, "tail_red", 		"TAG_TAIL", 			"misc/aircraft_light_white_blink", 		"running", 		randomStartDelay );
	build_light( model, "white_blink", 		"TAG_LIGHT_BELLY", 		"misc/aircraft_light_red_blink", 		"running", 		randomStartDelay );

}

init_local()
{
	thread playEngineEffects();
	maps\_vehicle::lights_on( "running" );
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
		playfxontag( engineeffects, self, "tag_engine_right_2" );
		playfxontag( engineeffects, self, "tag_engine_left" );
		playfxontag( engineeffects, self, "tag_engine_left_2" );
		self ent_flag_waitopen( "engineeffects" );
		StopFXOnTag( engineeffects, self, "tag_engine_left" );
		StopFXOnTag( engineeffects, self, "tag_engine_left_2" );
		StopFXOnTag( engineeffects, self, "tag_engine_right" );
		StopFXOnTag( engineeffects, self, "tag_engine_right_2" );
	}
}


/*QUAKED script_vehicle_antonov (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_antonov::main( "vehicle_antonov_fly" );

and these lines in your CSV:
include,vehicle_antonov
sound,vehicle_antonov,vehicle_standard,all_sp

defaultmdl="vehicle_antonov_fly"
default:"vehicletype" "antonov"
default:"script_team" "allies"
*/
