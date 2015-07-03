#include maps\_utility;
#include maps\_vehicle;
#include common_scripts\utility;
#include maps\_anim;
#include maps\af_chase_code;
#include maps\_hud_util;
#include maps\_vehicle_spline_zodiac;

main()
{

	enemy_pickup_heli = GetEnt( "enemy_pickup_heli", "targetname" );
	enemy_pickup_heli add_spawn_function( ::setup_enemy_pickup_heli );

	pre_rapids_trigger = GetEnt( "pre_rapids_trigger", "targetname" );
	pre_rapids_trigger thread trigger_pre_rapids();

	trigger_just_before_boatride_end = GetEnt( "trigger_just_before_boatride_end", "targetname" );
	trigger_just_before_boatride_end thread trigger_just_before_boatride_end();
	
	trigger_pavelow_pilot_dialogue = getent( "trigger_pavelow_pilot_dialogue", "targetname" );
	trigger_pavelow_pilot_dialogue thread trigger_pavelow_pilot_dialogue();
	

	over_waterfall = GetVehicleNode( "over_waterfall_test", "script_noteworthy" );
	over_waterfall thread trigger_over_waterfall();

	zodiac_blend_target = GetEnt( "zodiac_blend_target", "targetname" );
	zodiac_blend_target Hide();

	thread player_in_sight_of_boarding_trigger();

	weapon_pullout_before_waterfall = GetEnt( "weapon_pullout_before_waterfall", "targetname" );
	weapon_pullout_before_waterfall thread trigger_steady_the_boat();
	
	trigger_stop_boat_nagging = getent( "trigger_stop_boat_nagging", "targetname" );
	trigger_stop_boat_nagging thread trigger_stop_boat_nagging();
	

	thread slow_enemy_zodiac_for_player();
	init_flags_here();
}

init_flags_here()
{
	flag_init( "steady_shot" );
	flag_init( "idle_over_waterfall" );
	flag_init( "boat_freeze" );
	flag_init( "player_in_position_for_boarding_sequence" );

	flag_init( "price_steady1" );
	flag_init( "price_steady2" );
	flag_init( "price_steady3" );
	flag_init( "price_steady_shoot" );
	flag_init( "test_boat_is_on_spline" );
	flag_init( "rocky_bumps" );
	flag_init( "release_the_brakes" );

	flag_init( "pickup_heli_ok_to_delete_now" );
	flag_init( "price_fired_all_his_shots_at_heli" );

}

rumbly_rocks_bumps()
{
	while ( 1 )
	{
		wait randomfloatrange( .1, .4 );
		if( ! flag( "rocky_bumps" ) )
			continue;
		if ( cointoss() )
			level.player PlayRumbleOnEntity( "damage_heavy" );
		else
			level.player PlayRumbleOnEntity( "damage_light" );
			
	}
}

clear_rapids_junk()
{
	level notify ( "clear_rapids_junk" );
	level.player stoprumble( "damage_heavy" );
	level.player stoprumble( "damage_light" );
	level.player thread stop_loop_sound_on_entity( "zodiac_waterfall_idle" );
	level.player thread stop_loop_sound_on_entity( "zodiac_waterfall_sustain" );
	
	level.rumbler_ent delete();
}

create_ent_for_going_over_edge()
{
	ent = spawn_tag_origin();
//	ent thread boatline();
	level.over_edge_ent = ent;
	
	trigger = getentwithflag( "full_brake_until_waterfall_end" );
	struct = getstruct( trigger.target, "targetname" );
	targ = getstruct( struct.target, "targetname" );
	dist = distance( struct.origin, targ.origin );
	speed = 175; //111
	time = dist / speed;
	
	
	ent.origin = struct.origin;
	ent thread update_position_on_spline();
	
	flag_wait( "full_brake_until_waterfall_end" );
	
	ent moveto( targ.origin, time, 0, 0 );
}

boatline()
{
	self endon( "death" );
	
	for ( ;; )
	{
		line( self.origin, level.player.origin );
		wait 0.05;
	}
}

fail_of_too_long_without_progress()
{
	if ( flag( "player_brakes_on_waterfall" ) )
		return;
	level endon( "player_brakes_on_waterfall" );
	wait 15;
	// taking too long
	bread_crumb_fail();
}

rapids_scene()
{
	boat = level.players_boat;

	flag_wait_or_timeout( "player_on_final_ride", 5 );
	if ( !flag( "player_on_final_ride" ) )
	{
		// taking too long
		bread_crumb_fail();
		return;
	}
	
	/*
	trigger = getentwithflag( "player_on_final_ride" );
	struct = getstruct( trigger.target, "targetname" );
	targ = getstruct( struct.target, "targetname" );
	angles = vectortoangles( targ.origin - struct.origin );
	forward = anglestoforward( angles );
	
	player_angles = boat.angles;
	player_angles = set_y( (0,0,0), boat.angles[1] );
	player_forward = anglestoforward( player_angles );
	
	if ( vectordot( player_forward, forward ) < 0.3 )
	{
		// going backwards or some bs
		bread_crumb_fail();
		return;
	}
	*/
//	fov = getdvarint( "cg_fov" );
	if ( !level.player WorldPointInReticle_Circle( level.enemy_boat.origin, 65, 1000 ) )
	{
		// going backwards or some bs
		bread_crumb_fail();
		return;
	}
	
	thread fail_of_too_long_without_progress();
	
	autosave_by_name( "end_of_boatride" );
	
	players_boat_end_path = GetVehicleNode( "players_boat_end_path_test", "targetname" );

	level endon ( "clear_rapids_junk" );
	
	childthread rumbly_rocks_bumps();
	rumble_ent = level.player get_rumble_ent();
	rumble_ent.intensity = .025;
	level.rumbler_ent = rumble_ent;

	
	//level.players_boat.veh_pathtype = "constrained";
	level.players_boat endon( "death" );
	level notify( "new_river_current" );


	level.VehPhys_SetConveyorBelt_speed = 0;
	boat VehPhys_SetConveyorBelt( 0, 0 );
	
	ent = spawn_tag_origin();
	level.POS_LOOKAHEAD_DIST = 0;	
	lookahead = 500;
	
	flag_set( "steady_boat_participating" );
	flag_set( "rocky_bumps" );
	
	thread create_ent_for_going_over_edge();

	min_speed = 0;
	max_speed = 40;
	
	dist_ahead = -80;
	speed_ahead = min_speed;

	dist_behind = -300;
	speed_behind = max_speed;
	

	input_multiplier = 25;
	goal_offset_range = 350;
	goal_offset = level.player.offset;
		
		
	min_brake = 0;
	max_brake = 1;
	
	brake_dist_ahead = -60;
	brake_ahead = max_brake;

	brake_dist_behind = -70;
	brake_behind = min_brake;
	
	goal_blend_time = 2;
	goal_blend_time *= 1000;
	start_time = gettime();

	was_driving = false;
		
	for ( ;; )
	{
		//line( boat.origin, level.test_boat.origin );
		
		input = level.player GetNormalizedMovement()[1];
		goal_offset += input * input_multiplier;
		goal_offset = clamp( goal_offset, goal_offset_range * -1, goal_offset_range );
		//println( input + " " + goal_offset );
				
		//targ = get_player_targ();
		//next_targ = targ.next_node;
		
		targ = get_player_targ();
		progress = get_player_progress();
		touching_edge = flag( "boat_hits_right_side" ) || flag( "boat_hits_left_side" );
		if ( touching_edge )
		{
			goal_offset *= 0.85;
			//println( goal_offset );
		}
			
			
		used_offset = goal_offset;
		if ( abs( used_offset ) < 200 )
		{
			// give it some sway
			sway = sin( gettime() * 0.10 ) * 80;
			used_offset += sway;
			used_offset = clamp( used_offset, -200, 200 );
			//println( used_offset );
		}

		goal = get_position_from_spline_unlimited( targ, progress + lookahead, used_offset );
		goal = set_z( goal, boat.origin[2] );
		
		//old_goal = goal;
		//// blend from the original goal to the goal over time
		//original_goal = boat.origin + player_forward * lookahead;
		//time_passed = gettime() - start_time;
		//time_passed = clamp( time_passed, 0, goal_blend_time );
		//goal = graph_position( time_passed, 0, original_goal, goal_blend_time, goal );
		//
		//if ( time_passed == goal_blend_time )
		//{
		//	assertex( goal == old_goal, "Got wrong goal" );
		//}
		
		//Line( boat.origin, goal, (1,0,0) );

		speed = 35;

		if ( flag( "test_boat_is_on_spline" ) )
		{
			test_ent = level.test_boat;
			if ( flag( "full_brake_until_waterfall_end" ) )
			{
				// get the dif from a spawned entity that is more representative of the scene
				// since the boat anim has insanity imbedded in it.
				test_ent = level.over_edge_ent;
			}

			dif = progress_dif( targ, progress, test_ent.targ, test_ent.progress );
			speed = graph_position( dif, dist_ahead, speed_ahead, dist_behind, speed_behind );
			speed = clamp( speed, min_speed, max_speed );
			
			if ( flag( "full_brake_until_waterfall_end" ) )
			{
				brakes = graph_position( dif, brake_dist_ahead, brake_ahead, brake_dist_behind, brake_behind );
				brakes = clamp( brakes, min_brake, max_brake );
				boat.veh_brake = brakes;
			}
			else
			if ( flag( "player_brakes_on_waterfall" ) )
			{
				brakes = graph_position( dif, brake_dist_ahead, brake_ahead, brake_dist_behind, brake_behind );
				brakes = clamp( brakes, min_brake, max_brake );
				boat.veh_brake = brakes;
			}
		}

		//println( "speed " + speed + ", brakes " + boat.veh_brake );
		time_passed = gettime() - start_time;
		if ( time_passed > 1000 || touching_edge )
		{
			boat vehicleDriveTo( goal, speed );
			if ( !was_driving )
			{
				was_driving = true;
				boat.veh_brake = 0;	
			}
		}

		wait 0.05;
	}

	if ( 1 ) return;

	level.players_boat thread vehicle_paths( players_boat_end_path );
	level.players_boat StartPath( players_boat_end_path );
//	level.players_boat delayCall( .2, ::resumespeed, 20 );
	level.players_boat delayCall( .2, ::Vehicle_SetSpeed, 35,15,15 );
	level.players_boat Vehicle_TurnEngineOff();

	jolt_time = .3;
	jolt_count = 0;
//	level.player ShellShock( "af_chase_boatdrive_end", 60 );
	
	childthread rumbly_rocks_bumps();
	
	flag_set( "rocky_bumps" );
	
	rumble_ent = level.player get_rumble_ent();
	rumble_ent.intensity = .025;
	
	level.rumbler_ent = rumble_ent;

	while ( 1 )
	{
		if ( player_steadies_boat() )
		{
			flag_set( "steady_boat_participating" );
			level.player thread stop_loop_sound_on_entity( "zodiac_waterfall_idle" );
//			level.player thread play_sound_on_entity( "zodiac_player_rampup" );
			level.player thread play_loop_sound_on_entity( "zodiac_waterfall_sustain" );
//			level.player StopRumble( "tank_rumble" );
			level.players_boat.driftdir = 1;
			flag_clear( "rocky_bumps" );
			rumble_ent.intensity = .225;
//			level.player stopshellshock();
			while ( player_steadies_boat() )
				wait .05;
			rumble_ent.intensity = .0001;
			flag_set( "rocky_bumps" );
//			level.player ShellShock( "af_chase_boatdrive_end", 60 );
			level.player thread stop_loop_sound_on_entity( "zodiac_waterfall_sustain" );
			level.player thread play_loop_sound_on_entity( "zodiac_waterfall_idle" );
			jolt_count = 0;
		}
		else
		{
			level.players_boat.driftdir = -1;
			flag_clear( "steady_boat_participating" );
//			level.player PlayRumbleOnEntity( "tank_rumble" );
			jolt_count += .05;
		}

		if ( jolt_count > jolt_time )
		{
			jolt_count = 0;
			level.players_boat JoltBody( ( level.players_boat.origin + ( 0, 0, 64 ) + randomvector( 32 ) ), 0.1 );
		}
		wait .05;
	}
}

//#using_animtree( "generic_human" );

price_does_steady_boat_anims_and_sound()
{
	level.price delaythread( 0.666, ::play_sound_on_entity, "afchase_pri_holdsteady" );
	level.players_boat anim_generic( level.price, "zodiac_rapids_sniper", "tag_guy2" );
	level.players_boat thread anim_generic_loop( level.price, "zodiac_rapids_sniper_aimidle", "end_aim", "tag_guy2" );
	level.price delaythread( 0, ::play_sound_on_entity, "afchase_pri_steady1" );
	level.price delaythread( 3, ::play_sound_on_entity, "afchase_pri_steady1" );
}

price_snipes_from_boat()
{
	level.price endon( "death" );

	level.price radio_dialogue_stop();
	level.price linkto( level.players_boat, "tag_guy2", (0,0,0),(0,0,0) );

	thread price_does_steady_boat_anims_and_sound();


//	if ( !flag( "steady_shot" ) )
//		return player_fail_at_waterfall();

	flag_wait( "price_steady_shoot" );
	thread fail_if_not_going_over_falls();
	
	level.players_boat notify( "end_aim" );
	level.price Shoot();
	level.price thread play_sound_on_tag( "price_sniper_fire_at_helicopter", "tag_flash" );
	level.players_boat anim_generic( level.price, "zodiac_rapids_sniper_fire", "tag_guy2" );
	level.price Shoot();
	level.price thread play_sound_on_tag( "price_sniper_fire_at_helicopter", "tag_flash" );
	level.players_boat anim_generic( level.price, "zodiac_rapids_sniper_fire", "tag_guy2" );
	level.players_boat thread anim_generic_loop( level.price, "zodiac_rapids_sniper_aimidle", "end_aim", "tag_guy2" );
	wait .6;
	level.price Shoot();
	level.players_boat notify( "end_aim" );
	level.enemy_pickup_heli delaythread( .05, ::pickup_heli_kill);
	level.price thread play_sound_on_tag( "price_sniper_fire_at_helicopter", "tag_flash" );
	
	fx = getfx( "explosions/large_vehicle_explosion" );
	heli = level.enemy_ending_seaknight;
	PlayFXOnTag( fx, heli, "tag_guy0" );
	
	level.players_boat anim_generic( level.price, "zodiac_rapids_sniper_fire", "tag_guy2" );
	

	flag_set( "price_fired_all_his_shots_at_heli" );

	thread over_idle();
	
	scene = "zodiac_rapids_sniper_waterfall";
	animation = level.price getgenericanim( scene );
	time = getanimlength( animation );
	
	delaythread( time * 1.05, ::flag_set, "release_the_brakes" );
	
	level.players_boat thread play_sound_on_entity( "zodiac_player_reverse" );
	level.players_boat anim_generic( level.price, scene, "tag_guy2" );

	flag_set( "idle_over_waterfall" );
}

player_fail_at_waterfall()
{
	wait 2;
	missionFailedWrapper();
}

over_idle()
{
	level.players_boat endon ( "death" );
	flag_wait( "idle_over_waterfall" );
	level.players_boat thread anim_generic_loop( level.price, "zodiac_rapids_sniper_rapididle", "end_aim", "tag_guy2" );
}

trigger_steady_the_boat()
{
	self waittill( "trigger" );

	thread miniguns_on_pickup_heli();

}


water_fall_edge()
{
	trigger = GetEnt( "water_fall_edge_trigger", "targetname" );

	level.players_boat notify( "stop_targetting" );

	level.player AllowStand( true );
	level.player AllowCrouch( false );
	level.player AllowProne( false );

	PlayFXOnTag( getfx( "splash_over_waterfall" ), level.players_boat, "tag_guy2" );

	level.players_boat notify( "kill_treadfx" );

	cleanup_stuff_on_players_boat();

	targent = GetEnt( trigger.target, "targetname" );
	on_foot_destination = GetEnt( "on_foot_destination", "targetname" );

	level.player DisableWeapons();
	level notify( "player_over_the_waterfall" );

	height = targent.origin[ 2 ] + 250;
	height = targent.origin[ 2 ] + 270;

	level.player PlayerLinkToBlend( level.players_boat, "tag_player", .15, .05, .05 );

    level.player SetEqLerp( 1, level.eq_main_track );
    level thread maps\af_chase_knife_fight_code::eq_blender();
	thread maps\_ambient::use_eq_settings( "fadeout_noncritical", level.eq_mix_track );
 
	while ( level.player.origin[ 2 ] > height )
		wait .05;
		
	player_dismount();
	
	flag_set( "pickup_heli_ok_to_delete_now" );

	level notify( "stop_music_at_splash" );
	if( isdefined( level.music_emitter ) )
	{
	 	level.music_emitter StopSounds();
		level.music_emitter delaycall( .05, ::delete );
	}
	
	thread send_player_to_blend_boat();

	move_to_origin = set_z( level.player_linkent.origin, targent.origin[ 2 ] - 55 );

	level.players_boat Delete();
	
	script_vehicle_zodiacs = GetEntArray( "script_vehicle_zodiac", "classname" );
	script_vehicle_zodiac_physics = GetEntArray( "script_vehicle_zodiac_physics", "classname" ) ;
	array_call( script_vehicle_zodiacs, ::delete );
	array_call( script_vehicle_zodiac_physics, ::delete );
	
	level.player_linkent.origin = move_to_origin;
	level.player Unlink();
	level.player PlayerLinkTodelta( level.player_linkent, "tag_player", 1,0,0,0,0 );
	
	flag_set( "boat_freeze" );

	AmbientStop();
//	set_ambient( "af_chase_caves" );

	SetBlur( 6, 1.5 );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	
	thread play_sound_in_space( "scn_afchase_player_plunge", level.player.origin );
	fog_set_changes( "afch_fog_underwater", 0 );
	Earthquake( .3, 3.5, level.player.origin, 1000 );
	level.player SetWaterSheeting( 3, 3 );

	if ( IsDefined( level.price.function_stack ) )
		level.price function_stack_clear();// mo said too. keep his function stack from continuing after he's dead.

	level.price stop_magic_bullet_shield();
	level.players_boat notify( "end_aim" );

	array_call( GetAIArray(), ::Delete );

	level.player thread waterfx();
	
	thread maps\af_chase_fx::play_underwater_fx();
	
	wait 1;
	if ( !	flag( "killed_pickup_heli" ) )
	{
		// Shepherd escaped on the Helicopter.
		SetDvar( "ui_deadquote", &"AF_CHASE_FAILED_TO_SHOOT_DOWN" );
		missionFailedWrapper();
		return;
	}

	black_overlay = create_client_overlay( "black", 0, level.player );
	black_overlay FadeOverTime( 3 );
	black_overlay.alpha = 1;

	AmbientStop( 2 );

	level.eq_ent MoveTo( (1,0,0), 5, 0, 0 ); 
	
	wait 2;
	setdvar( "ui_char_museum_mode", "credits_1" );	
	nextmission();
		
	wait 7;
/*	
	set_ambient( "af_chase_ext" );
	level.player Unlink();
	level.player PlayerSetGroundReferenceEnt( undefined );
	level.player teleport_player( on_foot_destination );

	flag_set( "player_gets_up_after_waterfall" );
	flag_wait( "end_heli_crashed" );

	level.player EnableWeapons();

	flag_set( "water_cliff_jump_splash_sequence" );

	black_overlay delayCall( .05, ::Destroy );// leave it for a frame, then knife fight takes over with new overlays.
	

	flag_set( "fell_off_waterfall" );
*/
}

send_player_to_blend_boat()
{

	zodiac_blend_target = GetEnt( "zodiac_blend_target", "targetname" );
	level.players_boat MakeUsable();
	level.player PlayerLinkToBlend( zodiac_blend_target, "tag_player", .05, 0, 0 );
//	player_dismount();
	level.player PlayerLinkToBlend( zodiac_blend_target, "tag_player", .05, 0, 0 );
	level.players_boat MakeUnusable();
	level.player_linkent = zodiac_blend_target;
}

pickup_heli_kill()
{
	flag_set( "killed_pickup_heli" );
	self thread play_sound_on_entity( "scn_afchase_pavelow_downed" );
	self Vehicle_TurnEngineOff();
	self.script_crashtypeoverride = "none";
	self.crashing = true;// halts vehicles script from freeing the vehicle.
	self godoff();
	self notify( "death" );

	flag_wait( "pickup_heli_ok_to_delete_now" );
	flag_set( "end_heli_crashed" );

	self notify( "stop_crash_loop_sound" );
	self notify( "crash_done" );
	self notify( "nodeath_thread" );
	wait .1;// let the sound thread stop..

	self Delete();
}

trigger_pre_rapids()
{
	self waittill( "trigger" );
	level.price.use_auto_pose = undefined;
	level.price.scripted_boat_pose = "left";
}

player_dismount()
{
	level.players_boat Vehicle_TurnEngineOff();
	level.player DismountVehicle();
	level.players_boat SetModel( "vehicle_zodiac" );
	level.player.drivingVehicle = undefined;
}


delete_end_seaknight()
{
	foreach ( rider in self.riders )
		rider stop_magic_bullet_shield();
	self Delete();
}


#using_animtree( "vehicles" );
enemy_pickup_boat_spot()
{
	anim_scene = getstruct( "rapids_anim_scene", "targetname" );
	anim_scene.angles = ( 0, 0, 0 );
	enemy_heli = self;
	level.enemy_ending_seaknight = self;
	enemy_heli.animname = "pavelow";
	boat = level.players_boat;

	boat = Spawn( "script_model", level.players_boat.origin );
	boat SetModel( level.players_boat.model );
	boat.animname = "zodiac_player";
	boat hide();
	boat UseAnimTree( #animtree );
	boat NotSolid();
	
	
	level.test_boat = boat;

	guys = [];
	guys[ "heli" ] = enemy_heli;
	guys[ "boat" ] = boat;
	
	enemy_heli Vehicle_TurnEngineOff();


	anim_scene thread anim_loop_solo( enemy_heli, "sniper_waterfall_idle", "stop_loop_solo" );
	anim_scene notify( "stop_loop_solo" );

	flag_wait( "enemy_boat_boarded_seaknight" );
	flag_wait( "player_in_position_for_boarding_sequence" );

	boat thread update_position_on_spline();

	level.enemy_boat delayThread( 10, ::delete_end_seaknight );
	dummy = level.enemy_boat vehicle_to_dummy();
	level.enemy_boat Vehicle_SetSpeedImmediate( 500, 500, 500 );
	level.enemy_boat vehicleDriveTo( ( 25648, 26920, -10168 ), 500 );
	//level.enemy_boat notsolid();
	
	heli_linker = spawn( "script_origin", enemy_heli.origin );
	heli_linker linkto ( enemy_heli, "tag_body", (0,0,0), (0,0,0) );
	dummy delaycall( .05, ::LinkTo, heli_linker );
	
	level.player thread play_sound_on_entity( "afchase_plp_onboard" );

	level.price notify( "stop_boatrider_targets" );
	level.price SetEntityTarget( enemy_heli );

	animation = boat getanim( "sniper_waterfall" );
	startang =  GetStartAngles( anim_scene.origin, anim_scene.angles, animation );
	startorg =  GetStartOrigin( anim_scene.origin, anim_scene.angles, animation );


	thread match_position_of_animated_boat( boat );
	
	enemy_heli thread helicopter_sound_blend();

	thread price_snipes_from_boat();

	level.player delaythread( 4, ::play_sound_on_entity, "afchase_plp_thelongway" );
	flag_set( "test_boat_is_on_spline" );


	anim_scene thread anim_single_solo( enemy_heli, "sniper_waterfall" );	
	anim_scene anim_single_solo( boat, "sniper_waterfall" );	
	//boat anim_single_solo( boat, "waterfall_over" );	

	
}


movetotag( ent, tag, time )
{
	thread movetotag_internal( ent, tag, time );
}

movetotag_internal( ent, tag, time )
{
	self notify( "new_move_to_tag" );
	self endon( "new_move_to_tag" );
	timer = GetTime() + ( time * 1000 );
	tag_origin = ent GetTagOrigin( tag );
	self Unlink();
	self MoveTo( tag_origin, time );
	while ( GetTime() < timer )
	{
		updated_tag_origin = ent GetTagOrigin( tag );
		if ( updated_tag_origin != tag_origin )
		{
			tag_origin = updated_tag_origin;
			time = ( timer - GetTime() ) / 1000;
			self MoveTo( tag_origin, time );
		}
		wait .05;
	}
	self LinkToBlendToTag( ent, tag );

}


setup_enemy_pickup_heli()
{
	level.enemy_pickup_heli = self;
	self thread godon();
	while ( !isdefined( level.players_boat ) )
		wait .05;
	self thread enemy_pickup_boat_spot();
}

miniguns_on_pickup_heli()
{
	heli = level.enemy_pickup_heli;

	turret = SpawnTurret( "misc_turret", heli.origin, "minigun_littlebird_spinnup" );
	turret SetModel( "vehicle_little_bird_minigun_right" );
	turret LinkTo( heli, "tag_gunner_right", ( 33, 0, 0 ), ( 60, 76, 0 ) );


//		turret.isvehicleattached = true;// lets mgturret know not to mess with this turret
		turret.ownerVehicle = self;
		turret SetLeftArc( 85 );
		turret SetRightArc( 85 );
		turret SetBottomArc( 55 );
		turret SetTopArc( 85 );
		turret.script_team = "axis";
		turret SetMode( "manual" );
		turret thread maps\_mgturret::burst_fire_unmanned();
		turret MakeUnusable();
		turret SetTurretTeam( "axis" );
		level thread maps\_mgturret::mg42_setdifficulty( turret, getDifficulty() );
		turret SetAISpread( .4 );
		turret SetConvergenceTime( 1 );
		turret.accuracy = 0;

//		turret SetTargetEntity( level.players_boat, ( -256, 0, 0)  );

	level.end_heli_turret = turret;

	turret thread minigun_path();

	heli waittill( "death" );
	turret Delete();

}

minigun_path()
{
	minigun_path = getstruct( "minigun_path", "targetname" );
	target_ent = Spawn( "script_origin", minigun_path.origin );
//	target_ent SetModel( "body_desert_tf141_zodiac" );
//	target_ent NotSolid();

	minigun_splasher = getent( "minigun_splasher", "targetname" );
	minigun_splasher thread minigun_splasher_think();
	self endon( "death" );
	self SetTargetEntity( target_ent );

	flag_wait( "price_steady1" );
	self StartFiring();
	while ( !flag( "price_fired_all_his_shots_at_heli" ) )
	{
		if ( !isdefined( minigun_path.target ) )
			return;
		minigun_path = getstruct( minigun_path.target, "targetname" );
		if ( !isdefined( minigun_path ) )
			return;
		target_ent MoveTo( minigun_path.origin, 1, 0, 0 );
		target_ent waittill( "movedone" );
	}
	target_ent MoveTo( level.player.origin, 2.5, 0, 0 );
//	target_ent waittill( "movedone" );
	self SetTargetEntity( level.player );
	self SetAISpread( .4 );
	self SetConvergenceTime( 3 );
	self.accuracy = 1;
}

player_in_sight_of_boarding_trigger()
{
	flag_wait( "player_in_sight_of_boarding" );
	level.price.use_auto_pose = undefined;
	level.price.scripted_boat_pose = "left";
	
	thread rapids_scene();
	level notify( "quit_bread_crumb" );// kills failure from falling behind script.
	remove_extra_autosave_check( "boat_check_trailing" );
	remove_extra_autosave_check( "boat_check_player_speeding_along" );

}

trigger_just_before_boatride_end()
{
	self waittill( "trigger" );
	level notify( "no_more_reverse_hints" );
	flag_set( "no_more_physics_effects" );
}

trigger_pavelow_pilot_dialogue()
{
	self waittill( "trigger" );
	level notify( "price_stops_talking_about_helicopters" );
	// Avatar One, gimme a sitrep, over!
	radio_dialogue( "afchase_shp_sitrep" );
	// I have Warhorse 5-1 standing by. Pave Low's downriver sir.		
	radio_dialogue( "afchase_uav_downriver" );
	// Copy that! Warhorse 5-1, be advised, we're comin' in hot!		
	radio_dialogue( "afchase_shp_comininhot" );
	// Roger - dropping the hatch - keep it above 30 knots and watch the vertical clearance.		
	radio_dialogue( "afchase_plp_above30knots" );
	
//	level.player thread play_sound_on_entity( "afchase_plp_above30knots" );
}


slow_enemy_zodiac_for_player()
{
	trigger = GetVehicleNode( "slow_enemy_zodiac_for_player", "script_noteworthy" );
	trigger waittill( "trigger", zodiac );
	flag_set( "zodiac_boarding" );
	zodiac Vehicle_SetSpeed( 0, 30, 44 );
	flag_wait( "player_in_sight_of_boarding" );
	zodiac ResumeSpeed( 12 );
}


trigger_over_waterfall()
{
	flag_wait( "going_over_waterfall" );
	thread water_fall_edge();
	boat = level.players_boat;
	node = Spawn( "script_origin", boat.origin );
	node.angles = flat_angle( boat.angles );

	anim_name = "waterfall_over";

	thread clear_rapids_junk();
	node thread anim_single_solo( boat, anim_name );
}

fail_if_not_going_over_falls()
{
	wait 15;
	if ( !flag( "going_over_waterfall" ) )
	{
		bread_crumb_fail();
	}
}

match_position_of_animated_boat( animated_boat )
{
	catchup_speed = 5;
	fall_back_speed = 6;
	players_boat = level.players_boat;
	players_boat endon( "death" );
	wait .1;// animation is not in place yet
	last_animated_boat_spot = animated_boat GetTagOrigin( "tag_body" );
	ahead = 2;
	speed_to_go = 45;
	while ( 1 )
	{
		wait .05;
		origin = animated_boat GetTagOrigin( "tag_body" );// cause I don't trust tag_origin
		angles = animated_boat GetTagAngles( "tag_body" );// cause I don't trust tag_origin
		speed_of_animatedboat = Distance( last_animated_boat_spot, origin ) * 20 / 17.6;

		level.speed_of_animatedboat = speed_of_animatedboat ;
		origin2 =  level.players_boat GetTagOrigin( "tag_body" );
		dot = get_dot( origin, angles, origin2 );
		last_animated_boat_spot = origin;

		if ( dot > 0 )
		{
			speed_to_go = speed_of_animatedboat - fall_back_speed;
		}
		else if ( dot < 0 )
		{
			if ( Distance( origin, origin2 ) < 86 )
				speed_to_go = speed_of_animatedboat;
			else
				speed_to_go = speed_of_animatedboat + catchup_speed;
		}
		speed_to_go = cap_value( speed_to_go, 5, 60 );
		players_boat Vehicle_SetSpeed( speed_to_go, 8, 8 );
	}
}

minigun_splasher_think()
{
	effect = getfx( "pavelow_minigunner_splash_add" );
	while(1)
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		if ( attacker.code_classname != "misc_turret" )
			continue;
		ang = attacker GetTagAngles( "tag_flash" );
		org = attacker GetOrigin( "tag_flash" );
		vect = AnglesToForward( ang ) * 3000;
		
		trace = BulletTrace( org, org+vect, false, attacker );
		
		if( trace[ "fraction" ] == 1.0 )
			continue;
		
		if( isdefined( trace[ "entity" ] ) )
			continue;
			
		playfx( effect, trace[ "position" ] );
	}
}

trigger_stop_boat_nagging()
{
	self waittill ("trigger");
	flag_set ( "stop_boat_dialogue" );
}


helicopter_sound_blend()
{
	
	fly = "afchase_pavelow_fly";
	idle = "afchase_pavelow_idle";

	flyblend = spawn( "sound_blend", ( 0.0, 0.0, 0.0 ) );
	flyblend thread manual_linkto( self, ( 0, 0, 0 ) );

	idleblend = spawn( "sound_blend", ( 0.0, 0.0, 0.0 ) );
	idleblend thread manual_linkto( self, ( 0, 0, 64 ) );

	idleblend thread mix_up( idle );
	
	idleblend SetSoundBlend( idle, idle + "_off", 0 );

	wait 1;

	idleblend thread mix_down( idle );
	flyblend thread mix_up( fly );
	
	flag_wait ( "end_heli_crashed" );

	idleblend thread mix_down( idle );
	flyblend thread mix_down( fly );
	
}