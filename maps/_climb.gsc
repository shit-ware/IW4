#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_climb_anim;
#include maps\_vehicle;
#include maps\_hud_util;

CONST_min_stick_move = 0.5;

climb_init()
{

	if ( level.script == "climb" )
		level.friendly_init_cliffhanger = ::empty;
	player_jumpdown_block = GetEnt( "player_jumpdown_block", "targetname" );
	player_jumpdown_block NotSolid();

	level.price_climb_time = 0;
	level._effect[ "icepick_impact_rock" ] = LoadFX( "misc/ice_pick" );
	level._effect[ "icepick_impact_snow" ] = LoadFX( "misc/ice_pick" );
	level._effect[ "icepick_impact_ice" ] = LoadFX( "misc/ice_pick" );
	level._effect[ "ice_pick_scrape" ] = LoadFX( "misc/ice_pick_scrape" );
	level._effect[ "climbing_cracks_1" ] = LoadFX( "impacts/climbing_cracks_1" );
	level._effect[ "climbing_cracks_2" ] = LoadFX( "impacts/climbing_cracks_2" );
	level._effect[ "climbing_cracks_3" ] = LoadFX( "impacts/climbing_cracks_3" );
//	level._effect[ "climbing_cracks_4" ] = LoadFX( "impacts/climbing_cracks_4" );
//	level._effect[ "climbing_cracks_5" ] = LoadFX( "impacts/climbing_cracks_5" );
	SoundSetTimeScaleFactor( "Announcer", 0.0 );
	SoundSetTimeScaleFactor( "Music", 0 );

	level._effect[ "footstep_ice_climbing" ] = LoadFX( "impacts/footstep_ice_climbing" );

	//Player Climb Pick FX
	tracefx = add_trace_fx( "player_ice_pick" );
	tracefx.surface = "ice";
	tracefx.fx_array = [];
	tracefx.fx_array[ 0 ] = LoadFX( "impacts/climbing_cracks_1" );
	tracefx.fx_array[ 1 ] = LoadFX( "misc/ice_pick" );
	tracefx.rumble = "icepick_climb";
	tracefx.sound = "icepick_impact_ice";

	//Price Climb Pick FX
	tracefx = add_trace_fx( "ice_pick" );
	tracefx.surface = "ice";
	tracefx.fx = LoadFX( "misc/ice_pick_large" );
	tracefx.sound = "icepick_impact_ice_npc";

	//Price Climb Pick FX
	tracefx = add_trace_fx( "ice_pick_out" );
	tracefx.surface = "ice";
	tracefx.fx = LoadFX( "misc/ice_pick_large" );
	tracefx.sound = "icepick_pullout_ice_npc";



	//Player slide fx
	tracefx = add_trace_fx( "slide_fx" );
	tracefx.surface = "ice";
	tracefx.fx = LoadFX( "misc/ice_pick_scrape" );
	//tracefx.sound = "icepick_impact_ice";

	thread player_slides_off_cliff();
/* 
	//Price Climb Foot FX - Tried hooking up but didn't work very good since the feet are in the ground, so I just played fxontag
	tracefx = add_trace_fx( "footstep_ice_climbing" );
	tracefx.surface = "ice";
	tracefx.surface = "snow";
	tracefx.surface = "default";
	tracefx.surface = "rock";
	tracefx.fx = LoadFX( "impacts/footstep_ice_climbing" );
	tracefx.sound = "step_walk_ice";
*/
	level._effect[ "cigar_glow" ]						 = LoadFX( "fire/cigar_glow" );
	level._effect[ "cigar_glow_puff" ]					 = LoadFX( "fire/cigar_glow_puff" );
	level._effect[ "cigar_smoke_puff" ]					 = LoadFX( "smoke/cigarsmoke_puff" );
	level._effect[ "cigar_exhale" ]						 = LoadFX( "smoke/cigarsmoke_exhale" );

	level.trace_depth = 4.75;// 6.25;
	level.additive_weight = 0.2;
	level.additive_count = 0;
	level.additive_arm_boost = 4;
	level.climb_wrist_mod = 4.2;
	level.ice_pick_tags = [];
	level.ice_pick_tags[ "left" ] = "tag_weapon_left";
	level.ice_pick_tags[ "right" ] = "tag_weapon_right";
	PreCacheModel( "viewmodel_ice_picker" );
	PreCacheModel( "viewmodel_ice_picker_03" );
	//precacheModel( "weapon_m14_cloth_wrap_silencer" );
	PreCacheModel( "prop_price_cigar" );
	PreCacheModel( "weapon_ice_picker" );
	PreCacheItem( "ice_picker" );
	PreCacheItem( "ice_picker_bigjump" );
	PreCacheRumble( "icepick_slide" );
	PreCacheRumble( "icepick_hang" );
	PreCacheRumble( "icepick_climb" );
	PreCacheRumble( "icepick_release" );
	PreCacheRumble( "falling_land" );


	level.ice_pick_viewweapon = "ice_picker";

	create_dvar( "climb_thirdperson", 0 );
	create_dvar( "climb_add", 0 );
	create_dvar( "climb_automove", 0 );
	create_dvar( "climb_startdir", "up" );
	create_dvar( "climb_preview", 0 );
	player_animations();
	friendly_climb_anims();


	// Hold ^3[{+speed_throw}]^7 to swing your left icepick.
	add_hint_string( "left_icepick", &"CLIFFHANGER_LEFT_ICEPICK", ::should_stop_hanging_left_icepick_hint );
	// Hold ^3[{+attack}]^7 to swing your right icepick.
	add_hint_string( "right_icepick", &"CLIFFHANGER_RIGHT_ICEPICK", ::should_stop_hanging_right_icepick_hint );
	// Approach the ice and hold ^3[{+attack}]^7 to climb.
	add_hint_string( "how_to_climb", &"CLIFFHANGER_HOW_TO_CLIMB", ::should_stop_how_to_climb_hint );

	//trigger = GetEnt( "climb_trigger", "script_noteworthy" );
	//trigger SetHintString( "Hold &&1 to climb" );
	//level.climb_use_trigger = trigger;

	flag_init( "we_care_about_right_icepick" );
	flag_init( "finished_climbing" );
	flag_init( "reached_top" );
	flag_init( "flyin_complete" );
	flag_init( "player_hangs_on" );
	flag_init( "player_preps_for_jump" );
	flag_init( "player_makes_the_jump" );
	flag_init( "price_caught_player" );
	flag_init( "price_climbs_past_start" );
	flag_init( "player_begins_to_climb" );
	flag_init( "player_climbed_3_steps" );
	flag_init( "final_climb" );
	flag_init( "flying_in" );
	flag_init( "player_was_caught" );
	flag_init( "player_starts_climbing" );
	flag_init( "slam_zoom_started" );
	flag_init( "climbing_dof" );

	if ( GetDvarInt( "climb_preview" ) )
		run_thread_on_targetname( "climb_model", ::climb_preview_anim );
	else
		run_thread_on_targetname( "climb_model", ::self_delete );

	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	thread give_player_icepicker_ammo();
	thread blend_in_climbing_dof( 3 );

	climb_tests = GetEntArray( "climb_test", "targetname" );
	climb_catch = GetEnt( "climb_catch", "targetname" );
	climb_catch Hide();
	array_call( climb_tests, ::Hide );

	//thread earthquake_flyover();
	thread toggle_jump_ramp();
	//run_thread_on_targetname( "trace", ::trace_test );

	//NotifyOnCommand( "jump", "+gostand" );
	//NotifyOnCommand( "jump", "+moveup" );
}

toggle_jump_ramp()
{
	ramp_toggles_until_jump_over();
	player_ramp_block = GetEnt( "player_ramp_block", "targetname" );
	player_ramp_block Delete();
	triggers = getEntArrayWithFlag( "ramp_block_notsolid" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}
}

ramp_toggles_until_jump_over()
{
	level endon( "reached_top" );
	player_ramp_block = GetEnt( "player_ramp_block", "targetname" );
	for ( ;; )
	{
		flag_wait( "ramp_block_notsolid" );

		add_wait( ::player_stops_moving );
		add_wait( ::_wait, 0.5 );
		do_wait_any();

		player_ramp_block NotSolid();
		flag_waitopen( "ramp_block_notsolid" );
		player_ramp_block Solid();
	}
}

player_stops_moving()
{
	for ( ;; )
	{
		vel = level.player GetVelocity();
		velocity = Distance( ( vel[ 0 ], vel[ 1 ], 0 ), ( 0, 0, 0 ) );
		if ( velocity < 75 )
			return;
		wait( 0.05 );
	}
}

empty()
{

}

death_trigger()
{
	flag_clear( "fade_to_death" );
	flag_wait( "fade_to_death" );

	level.player PlaySound( "cliff_plyr_fall_scream" );
	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	//SetSavedDvar( "hud_drawhud", 0 );


	VisionSetNaked( "black_bw", 2.5 );
	wait( 2.5 );
	level.player PlayRumbleOnEntity( "falling_land" );
	wait( 0.5 );

	if ( flag( "ramp_block_notsolid" ) )
	{
		if ( !flag( "reached_top" ) )
		{
			if ( GetDvarInt( "hold_on_tight" ) )
			{
				// Hold on for dear life.
				SetDvar( "ui_deadquote", &"CLIFFHANGER_HOLD_ON_TIGHT" );
			}
			else
			{
				SetDvar( "hold_on_tight", 1 );
				// Nobody makes the first jump...
				SetDvar( "ui_deadquote", &"CLIFFHANGER_MAKES_FIRST_JUMP" );
			}
			maps\_utility::missionFailedWrapper();
		}
	}

	level.player Kill();
}

earthquake_flyover()
{
	flag_wait( "mig_flies_over" );
	mig_flies_over = getEntWithFlag( "mig_flies_over" );
	Earthquake( 0.5, 3, mig_flies_over.origin, 10000 );
}

give_player_icepicker_ammo()
{
	if ( flag( "reached_top" ) )
		return;
	level endon( "reached_top" );

	for ( ;; )
	{
		if ( player_has_weapon( level.ice_pick_viewweapon ) )
		{
			level.player GiveMaxAmmo( level.ice_pick_viewweapon );
			level.player SetWeaponAmmoClip( level.ice_pick_viewweapon, 90 );
		}
		wait( 1 );
	}
}

kill_on_slip()
{
	level endon( "reached_top" );
	if ( flag( "reached_top" ) )
		return;

	for ( ;; )
	{
		flag_waitopen( "flying_in" );
		if ( level.player.origin[ 2 ] < - 1000 )
			break;
		wait( 0.05 );
	}
	level.player Kill();
}


player_rig_test()
{
	wait( 1 );
	org = ( 0, 0, 0 );
	model = spawn_anim_model( "player_rig" );

	for ( ;; )
	{
		//model.origin = org + randomvector( 30 );
		model.angles = ( RandomIntRange( 0, 360 ), RandomIntRange( 0, 360 ), RandomIntRange( 0, 360 ) );
		//model.origin += (0,0,1 );
		wait( 0.05 );
	}
}

tag_flies_in_on_vehicle( vehicle )
{
	vehicle endon( "reached_end_node" );
	dest = GetEnt( "player_climb_start", "targetname" );

	timer = 0.2;
	for ( ;; )
	{
		self MoveTo( vehicle.origin, timer, 0, 0 );
		angles = VectorToAngles( dest.origin - self.origin );
		self.angles = angles;
		wait( timer );
	}
}

old_crazy_fly_in()
{
	slowmo_start();
	slowmo_setspeed_slow( 2 );
	slowmo_setlerptime_in( 0.05 );
	slowmo_lerp_in();

	level.player SetDepthOfField( 0, 0, 15000, 20000, 4, 4 );
	thread maps\_introscreen::introscreen_generic_white_fade_in( 1.25, 2 );
	thread maps\_blizzard::blizzard_level_transition_snowmobile( 0.05 );
	SetExpFog( 2000, 20000, level.fog_color[ "r" ], level.fog_color[ "g" ], level.fog_color[ "b" ], .47, 0 );


//	thread maps\_blizzard::blizzard_level_transition_climbing( .05 );
	maps\_blizzard::blizzard_overlay_clear();

	level.player TakeAllWeapons();
	flag_set( "flying_in" );

	//fly_in_spawner
	vehicle = spawn_vehicle_from_targetname_and_drive( "fly_in_spawner" );
	level.fly_in_vehicle = vehicle;
	helis = spawn_vehicles_from_targetname_and_drive( "fly_in_heli" );
	level.player PlayerLinkToDelta( vehicle, "tag_origin", 1, 0, 0, 0, 0 );
	//tag_origin tag_flies_in_on_vehicle( vehicle );
	//tag_origin Delete();
	//flag_wait( "fade_to_white" );
	wait( 16 );
	foreach ( heli in helis )
		heli Delete();

	thread maps\_introscreen::introscreen_generic_white_fade_in( 0.5, 1, 2 );
	slowmo_setlerptime_out( 0.5 );
	slowmo_lerp_out();
	slowmo_end();
	wait( 2.5 );
	vehicle Delete();

	vehicle = spawn_vehicle_from_targetname_and_drive( "fly_in_spawner_cliff_repeat" );
	level.player PlayerLinkToDelta( vehicle, "tag_origin", 1, 0, 0, 0, 0 );
//	thread maps\_introscreen::introscreen_generic_white_fade_in( 0.1, 1.0, 0 );

	wait( 4.5 );
	thread maps\_introscreen::introscreen_generic_white_fade_in( 2, 0.5, 1.5 );

	//vehicle waittill( "reached_end_node" );
	wait( 2.0 );
	vehicle Delete();
}

get_dof_from_distance_to_price( climb_cam )
{
	dist = Distance( level.player.origin, climb_cam.origin );

	dof[ "nearStart" ] = 1;
	dof[ "nearEnd" ] = dist - 4000;
	if ( dof[ "nearEnd" ] < 100 )
		dof[ "nearEnd" ] = 100;

	dof[ "nearBlur" ] = 5;
	dof[ "farStart" ] = dist + 1000;
	dof[ "farEnd" ] = dist + 2000;
	dof[ "farBlur" ] = 2;

	return dof;
}

keep_price_in_focus( original_dof )
{
	//level endon( "finished_slam_zoom" );
	mid_dof = original_dof;
	mid_dof[ "farStart" ] = 400;
	mid_dof[ "farEnd" ] = 600;
	mid_dof[ "farBlur" ] = 4;

	climb_cam = GetEnt( "player_climb_start", "targetname" );
	for ( ;; )
	{
		if ( flag( "nearing_top_of_slam_zoom" ) )
			break;
//		if ( Distance( climb_cam.origin, level.player.origin ) < 400 )
//			break;

		level.dofDefault = get_dof_from_distance_to_price( climb_cam );
		wait( 0.05 );
	}

	// blend back to normal dof	
	blend_dof( level.dofDefault, mid_dof, 0.5 );
	wait( 3 );
	blend_dof( level.dofDefault, original_dof, 2 );

}

blizzard_lead_fx()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( self.veh_speed > 50 )
		{
			PlayFX( level._effect[ "blizzard_level_1" ], self.origin );
//			wait( .3 );
		}

		wait( 0.1 );
	}
}

faux_player_on_mountain()
{
	spawner = GetEnt( "faux_player_spawner", "targetname" );
	guy = spawner StalingradSpawn();
	guy.team = "allies";
	ent = GetEnt( "faux_player_ent", "targetname" );

	guy gun_remove();
	ent anim_generic_first_frame( guy, "faux_player" );
	wait( 8 );
	ent thread anim_generic( guy, "faux_player" );
	wait( 4 );
	guy Delete();
	spawner Delete();
	ent Delete();
}

fly_up_the_mountain()
{
	thread maps\_introscreen::introscreen_generic_white_fade_in( 0.1, 1 );

	SetSavedDvar( "compass", "0" );

	original_dof = level.dofDefault;
	level.dofDefault[ "nearStart" ] = 1;
	level.dofDefault[ "nearEnd" ] = 1;
	level.dofDefault[ "nearBlur" ] = 4;
	level.dofDefault[ "farStart" ] = 10000;
	level.dofDefault[ "farEnd" ] = 20000;
	level.dofDefault[ "farBlur" ] = 2;

//	thread maps\_blizzard::blizzard_level_transition_snowmobile( 0.05 );
	maps\_blizzard::blizzard_overlay_clear();



	climb_cam = GetEnt( "player_climb_start", "targetname" );
	climb_cam.angles = ( 16.5, climb_cam.angles[ 1 ], 0 );

	level.player TakeAllWeapons();
	level.player GiveWeapon( level.ice_pick_viewweapon, 0, 1 );


	slam_zoom_path = GetVehicleNode( "slam_zoom_path", "targetname" );
	vehicle = spawn_vehicle_from_targetname( "fly_in_spawner" );
	fx_veh = spawn_vehicle_from_targetname( "fly_in_fx" );
	fx_veh thread blizzard_lead_fx();

	level.fly_in_vehicle = vehicle;
	vehicle AttachPath( slam_zoom_path );
	fx_veh AttachPath( slam_zoom_path );
	//vehicle thread blizzard_lead_fx();
	level.player PlayerLinkTo( vehicle, "tag_origin", 1, 0, 0, 0, 0, 0 );

	// disable rumble for the migs for the fly in
	old_rumble = level.vehicle_rumble[ "mig29" ];
	level.vehicle_rumble[ "mig29" ] = undefined;
	delayThread( 1.95, ::spawn_vehicles_from_targetname_and_drive, "slam_zoom_mig" );

	thread faux_player_on_mountain();

	start = level.dofDefault;
	end = get_dof_from_distance_to_price( climb_cam );
	blend_dof( start, end, 0.7 );

	//migs = spawn_vehicles_from_targetname_and_drive( "slam_zoom_mig" );

	fx_veh StartPath();
	vehicle StartPath();
	flag_set( "slam_zoom_started" );
	thread keep_price_in_focus( original_dof );
	vehicle waittill( "reached_end_node" );
	vehicle Delete();
	fx_veh Delete();
	wait( 0.5 );
	//level notify( "finished_slam_zoom" );

	level.player Unlink();
	flag_set( "can_save" );
	thread autosave_now_silent();
	thread death_trigger();


//	level.player Unlink();
//	maps\_introscreen::flying_intro( climb_cam.angles, climb_cam.origin );
	flag_clear( "flying_in" );

	level.vehicle_rumble[ "mig29" ] = old_rumble;

	SetSavedDvar( "compass", "1" );

//	*/
	/*
	climb_cam = GetEnt( "climb_cam", "targetname" );
	model = climb_cam spawn_tag_origin();
	timer = 0;
	level.player PlayerLinkToBlend( model, "tag_origin", 0, 0, 0 );
	climb_cam delayThread( 2, ::self_delete );
	climb_cam = GetEnt( climb_cam.target, "targetname" );
	timer = 4.5;
	model MoveTo( climb_cam.origin, timer, 0, timer );
	model RotateTo( climb_cam.angles, timer * 2, 0, timer );
	
	wait( 1.4 );
	timer = 0.5;
	model MoveTo( climb_cam.origin, timer, 0, timer );
	model RotateTo( climb_cam.angles, timer * 2, 0, timer );
	wait( timer - 0.05 );
	climb_cam = GetEnt( "player_climb_start", "targetname" );
	timer = 0.5;
	model MoveTo( climb_cam.origin, timer, 0, timer );
	model RotateTo( climb_cam.angles, timer * 2, 0, timer );
	
	wait( timer + 0.5 );
	model Delete();
	level.player Unlink();
	*/
}

teleport_to_cave()
{
	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	thread maps\_introscreen::introscreen_generic_white_fade_in( 1.25, 2 );
	climb_cam = GetEnt( "player_climb_start", "targetname" );
	climb_cam.angles = ( 16.5, climb_cam.angles[ 1 ], 0 );

	level.player SetOrigin( climb_cam.origin + ( 0, 0, -12 ) );
	level.player SetPlayerAngles( climb_cam.angles );
	level.player Unlink();

	flag_clear( "price_begins_climbing" );
	flag_set( "flyin_complete" );
	level.player AllowProne( false );
	level.player AllowSprint( false );
	wait( 0.05 );// needed to set the stance > <
	level.player SetStance( "crouch" );
	level.player TakeAllWeapons();
	level.player GiveWeapon( level.ice_pick_viewweapon, 0, 1 );

}

player_mantles_top()
{
	for ( ;; )
	{
		if ( level.player CanMantle() )
		{
			level.player Unlink();
			level.player ForceMantle();
			//level.player.mantled = true;
			thread player_big_jump();
			return;
		}
		wait( 0.05 );
	}
}

climb_wall( start_org, start_ang )
{
	level.player SetMoveSpeedScale( 0.35 );
	//thread maps\_blizzard::blizzard_level_transition_climbing( .01 );
	//thread player_mantles_top();

	MusicPlayWrapper( "cliffhanger_climbing_music" );

	skip_first_wait = false;

	if ( !skip_first_wait )
	{
		flag_wait( "player_gets_on_wall" );
	}

	player_climb_blocker = GetEnt( "player_climb_blocker", "targetname" );
	player_climb_blocker Delete();

	starting_climb_brush = GetEnt( "starting_climb_brush", "targetname" );
	player_jump_blocker = GetEnt( "player_jump_blocker", "targetname" );

	for ( ;; )
	{
		player_jump_blocker Solid();
		starting_climb_brush NotSolid();

		if ( !skip_first_wait )
		{
			wait_until_player_climbs();
		}

		starting_climb_brush Solid();
		skip_first_wait = false;

		//self TakeAllWeapons();

		//level.climb_use_trigger trigger_off();
		player_jump_blocker NotSolid();

		if ( player_finishes_climbing( start_org, start_ang ) )
		{
			break;
		}

		level.player GiveWeapon( level.ice_pick_viewweapon, 0, 1 );
		level.player SwitchToWeapon( level.ice_pick_viewweapon );

		//level.climb_use_trigger trigger_on();
//		flag_clear( "player_gets_on_wall" );
//		flag_wait( "player_gets_on_wall" );
	}

	level.player SetMoveSpeedScale( 1 );
}

get_forward_from_ent( ent )
{
	ent_targ = GetEnt( ent.target, "targetname" );
	angles = VectorToAngles( ent_targ.origin - ent.origin );
	angles = ( 0, angles[ 1 ], 0 );
	return AnglesToForward( angles );
}

wait_until_player_climbs()
{
	player_climb_yaw_check = GetEnt( "player_climb_yaw_check", "targetname" );
	climb_forward = get_forward_from_ent( player_climb_yaw_check );

	autosaved = false;

	hint_time = GetTime() + 3000;
	displayed_hint = false;

	for ( ;; )
	{
		if ( !displayed_hint && GetTime() > hint_time )
		{
			displayed_hint = true;
			display_hint( "how_to_climb" );
		}

		if ( !flag( "player_in_position_to_climb" ) )
			level.player AllowFire( true );

		flag_wait( "player_in_position_to_climb" );
		if ( level.player GetStance() != "stand" )
		{
			level.player AllowFire( true );
			wait( 0.05 );
			continue;
		}

		player_angles = level.player GetPlayerAngles();
		if ( player_angles[ 0 ] >= 28 )
		{
			level.player AllowFire( true );
			wait( 0.05 );
			continue;
		}

		player_angles = ( 0, player_angles[ 1 ], 0 );
		player_forward = AnglesToForward( player_angles );
		dot = VectorDot( player_forward, climb_forward );
		if ( dot < 0.6 )
		{
			level.player AllowFire( true );
			wait( 0.05 );
			continue;
		}

		level.player AllowFire( false );

		level.player SwitchToWeapon( level.ice_pick_viewweapon );
		if ( !autosaved )
			thread autosave_now_silent();
		autosaved = true;


		if ( level.player rightSwingPressed() )
			return;

		if ( level.player leftSwingPressed() )
			return;


		wait( 0.05 );
	}
}

rightSwingPressed()
{
	return level.player buttonpressed( "mouse2" );// adsButtonPressed();
}

leftSwingPressed()
{
	return level.player buttonpressed( "mouse1" ); // attackButtonPressed();
}

set_normal_fov()
{
	SetSavedDvar( "cg_fov", 65 );
	/*
	fov = GetDvarInt( "cg_fov" );
	for ( i = fov; i >= 65; i-- )
	{
		SetSavedDvar( "cg_fov", i );
		wait( 0.05 );
	}*/

}

set_zoomed_fov()
{
	SetSavedDvar( "cg_fov", 78 );
	/*
	fov = GetDvarInt( "cg_fov" );
	for ( i = fov; i <= 78; i++ )
	{
		SetSavedDvar( "cg_fov", i );
		wait( 0.05 );
	}
	*/	
}

modellines( start_org, start_ang, model )
{

	for ( ;; )
	{
		Line( start_org, model GetTagOrigin( "tag_player" ), ( 1, 0, 0 ) );
		wait( 0.05 );
	}
}


player_finishes_climbing( start_org, start_ang, no_relink, skipRelink )
{
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );

	flag_set( "player_starts_climbing" );

	model = spawn_anim_model( "player_rig", start_org );
	//model DontInterpolate();
	model.angles = start_ang;

	//model Hide();
//	pick = spawn_anim_model( "icepick" );
//	pick LinkTo( model, "tag_weapon", (0,0,0), (0,0,0) );
//	anim_spawn_model( "viewmodel_ice_picker", "pick", anime, tag )
	model anim_spawn_tag_model( "viewmodel_ice_picker", "tag_weapon_right" );
	model anim_spawn_tag_model( "viewmodel_ice_picker_03", "tag_weapon_left" );
	/#
	model thread draw_ent_num();
	#/


	tag_origin = Spawn( "script_model", ( 0, 0, 0 ) );
	tag_origin SetModel( "tag_origin" );
	tag_origin Hide();
	tag_origin LinkTo( model, "tag_player" );
	// self PlayerSetGroundReferenceEnt( tag_origin );

	anims = [];

	thread set_zoomed_fov();



	////////////////////////////////////////////////////////////////////
	//		PLAYER LINKING
	////////////////////////////////////////////////////////////////////
//	fov = 90;
//	model thread lerp_player_view_to_tag_oldstyle( self, "tag_player", 0.2, 1, fov, fov, fov * 0.2, fov * ( 2 / 3 ) );
//	model thread maps\_debug::dragTagUntilDeath( "tag_player", (1,1,0) );
//	model thread maps\_debug::dragTagUntilDeath( "tag_origin", (1,0,0) );



	arms = [];
	arms[ arms.size ] = "left";
	arms[ arms.size ] = "right";

	button_functions = [];
	button_functions[ "left" ] = ::leftSwingPressed;
	button_functions[ "right" ] = ::rightSwingPressed;

	arm_ents = [];
	keys = [];
	keys[ "left" ] = "j";
	keys[ "right" ] = "k";

	angles = model.angles;
	forward = AnglesToForward( angles );
	up = AnglesToUp( angles );
	right = AnglesToRight( angles );

	// global arm vars that are not arm specific
	arm_globals = SpawnStruct();
	arm_globals.arm_weight = 0.01;

	arm_globals.fake_models = [];
	arm_globals.player = self;
	arm_globals.stab_notetrack = false;
	arm_globals.current_arm = "left";
	arm_globals.org_difference = ( 0, 0, 0 );
	arm_globals.climbing = true;
	arm_globals.ground_ref_ent_set = false;
	arm_globals.ground_ref_ent = tag_origin;
	arm_globals.climb_count = 0;

	flag_set( "climbing_dof" );
	// set the player's lookat angle info for determining stab angles
	//model thread test_player_angle( arm_globals );
	//model thread maps\_debug::drawTagForever( "tag_origin" );
	start_dir = GetDvar( "climb_startdir" );
	arm_globals.start_climb_time = 0;

	relink_time = 0;
	if ( level.gameskill <= 1 )
		relink_time = 10000;

	foreach ( arm in arms )
	{
		struct = Spawn( "script_origin", ( 0, 0, 0 ) );

		key = keys[ arm ];
		struct.key = key;
		struct.arm = arm;
		if ( IsDefined( no_relink ) )// && arm == "right" )
			struct.last_button_press = GetTime() + relink_time;
		else
			struct.last_button_press = 0;

		struct.stabbed = true;
		struct.viewmodel = model;
		struct.anims = anims[ arm ];
		struct.anims = get_anims_for_climbing_direction( struct.anims, start_dir, arm );
		struct.climb_dir = start_dir;
		struct.player = self;

		struct.buttonCheck = button_functions[ arm ];
		thread button_detection( struct );
		struct.globals = arm_globals;
		struct.additive_type = "additive_in";
		struct.additive_weight = 0;
		struct.surface_type = "ice";
		//thread generate_notetrack_times( struct );
		//thread spawn_additive_models( struct );

		fx_tag_name = get_icepick_tag_name( arm );
		struct.fx_tag = spawn_icepick_fx_tag( model, fx_tag_name );
		struct.fx_tag.swinging = false;
		struct thread icepick_impact_fx( struct.fx_tag, model );

		//struct.fx_tag thread maps\_debug::drawTagForever( "tag_origin" );
		//struct.fx_tag thread test_line();
		arm_ents[ arm ] = struct;
	}

	arm_globals.arm_ents = arm_ents;

	//wait( 2.5 );
	ent = arm_ents[ arm_globals.current_arm ];
	level.arm_ent_globals = arm_globals;
	thread sleeve_flap( ent.viewModel );

	// set up random waits
	assign_random_waits( ent );
	
	level.stabs_completed = 0;

	//arm_ent.viewModel SetAnimLimited( arm_ent.anims[ "climb" ], 1, 0, 1 );        
	other_arm_ent = get_other_arm_ent( ent );
	ent.viewModel SetAnim( other_arm_ent.anims[ "idle" ], 1, 0, 1 );
	//thread wrist_test( arm_ent );
	//thread right_add_test( arm_ent );

	ent.player.jumped = false;

	if ( !isdefined( no_relink ) )
	{
		flag_set( "we_care_about_right_icepick" );
		// used for the initial getting on the wall
		player_relinks_to_tag( ent );
	}
	else
	{
		if ( level.gameSkill < 2 )
			flag_clear( "we_care_about_right_icepick" );
		else
			flag_set( "we_care_about_right_icepick" );

		thread player_gets_back_into_climbing( ent );
		arm_globals.start_climb_time = GetTime();
	}

	//thread player_jump_check( ent );
	stabbed = true;// controls if you must hold for the first stab, to stay on

	fall_time = GetTime() + 8000;

	stop_climbing = false;

	thread track_trigger_pulls( arm_globals );
	climb_count = 0;
	e3_start = is_e3_start();
	e3_skipout_time = 0;

	for ( ;; )
	{
		if ( flag( "finished_climbing" ) )
		{
			stop_climbing = true;
			break;
		}

		if ( e3_start && flag( "final_climb" ) )
		{
			if ( climb_count == 2 && e3_skipout_time == 0 )
			{
				fade_time = 1.5;
				e3_skipout_time = GetTime();
				level.black_overlay = create_client_overlay( "black", 0, level.player );
				level.black_overlay FadeOverTime( fade_time );
				level.black_overlay.alpha = 1;

				// In the interest of time..
				level.e3_text_overlay = maps\cliffhanger_code::e3_text_hud( &"CLIFFHANGER_E3_INTEREST_OF_TIME" );
				level.e3_text_overlay FadeOverTime( fade_time );
				level.e3_text_overlay.alpha = 1;
			}
			else
			if ( climb_count >= 2 && GetTime() > e3_skipout_time + 2000 )
			{
				tag_origin Delete();
				level.player AllowFire( true );
				level.player AllowCrouch( true );
				level.player AllowProne( true );
				level.player AllowSprint( true );
				flag_set( "finished_climbing" );
				level.player disableweapons();
				ent.viewModel notify( "stop_crack" ); // stop the rumble
				flag_clear( "climbing_dof" );
				return true;
			}
		}


//		if ( IsDefined( level.player.mantled ) )
//			break;
		ent = arm_globals.arm_ents[ arm_globals.current_arm ];
		other_arm = get_other_arm( arm_globals.current_arm );
		other_arm_ent = arm_ents[ other_arm ];

		if ( should_fall( stabbed, fall_time, ent ) )
		{
			stop_climbing = player_falls_to_death( ent );
			break;
		}

		if ( arm_completes_stab( arm_ents[ arm_globals.current_arm ], skipRelink ) )
		{
			fall_time = GetTime() + 8000;
			// to require the player to release the button to stab again.
			ent.button_press_num_last = ent.button_press_num;
			// switch arms when you complete a stab
			arm_globals.current_arm = get_other_arm( arm_globals.current_arm );
			stabbed = true;

			climb_count++;
		}
		else
			wait( 0.05 );

		if ( flag( "finished_climbing" ) )
		{
			stop_climbing = true;
			break;
		}

		skipRelink = undefined;
		// special case situations
		if ( !arm_globals.climbing )
		{
			flag_wait( "climb_start" );
			flag_waitopen( "climb_pullup" );
			ent = arm_ents[ arm_globals.current_arm ];
			player_gets_back_on_wall( ent );
			// while ( movement_stick_pressed( arm_ent ) )
			while ( icepick_button_pressed( ent ) )
				wait( 0.05 );
		}
	}

	tag_origin Delete();
	if ( IsDefined( model ) )
		model Delete();

	if ( stop_climbing )
	{
		level.player AllowFire( true );
		level.player AllowCrouch( true );
		level.player AllowProne( true );
		level.player AllowSprint( true );
		thread set_normal_fov();
		flag_clear( "climbing_dof" );
	}

	return stop_climbing;
}

player_falls_to_death( ent )
{
	ent.viewModel notify( "stop_crack" );
	if ( flag( "final_climb" ) )
	{
		timer = 0.5;
		flag_clear( "can_save" );
		// throw the player off the cliff		
		movent = spawn_tag_origin();
		movent.origin = level.player.origin + ( 0, 0, 32 );
		movent.angles = ent.viewModel GetTagAngles( "tag_player" );

		level.player Unlink();
		ent.player PlayerSetGroundReferenceEnt( undefined );
		level.player SetPlayerAngles( movent.angles );
		wait( 0.1 );

//		ent.viewModel Hide();
		anims = ent.anims;
		mult = 2;
		ent.viewModel SetFlaggedAnimKnobAllRestart( "anim", anims[ "fall" ], anims[ "root" ], 1, 0.35, mult );
		ent.viewModel MoveTo( movent.origin, timer, 0.1, 0 );

		level.player PlayerLinkToBlend( movent, "tag_origin", 0.5, 0.1, 0 );

		wait( timer );
		movent Delete();
		cleanup_player_arms( ent );
		angles = ( -15, -100, 0 );
		forward = AnglesToForward( angles );
		level.player SetVelocity( forward * 50 );
		level.player BeginSliding();

		wait( 1.2 );
		flag_set( "fade_to_death" );
		level waittill( "foreverever" );
	}

	if ( flag( "player_climbs_past_safe_point" ) )
	{
		flag_clear( "can_save" );
		fall_to_your_death( ent );
		return true;
	}

	ent = get_other_arm_ent( ent );
	anims = ent.anims;
	ent.viewModel ClearAnim( anims[ "additive" ], 0.1 );
	ent.viewModel SetFlaggedAnimKnobAllRestart( "anim", anims[ "fall_small" ], anims[ "root" ], 1, 0.15, 1 );
	ent.viewModel waittillmatch( "anim", "end" );
	ent.viewModel Hide();
	player_recover = GetEnt( "player_recover", "targetname" );
	fall_dist = Distance( player_recover.origin, ent.viewModel.origin );
	fall_time = fall_dist * 0.0065 + 0.15;
	ent.viewModel MoveTo( player_recover.origin, fall_time, fall_time * 0.6 );
	ent.viewModel RotateTo( ( 70, 165, 0 ), fall_time, fall_time );

	wait( fall_time );
	wait( 0.05 );
	cleanup_player_arms( ent );

	return false;
}

cleanup_player_arms( ent )
{
	ent.player PlayerSetGroundReferenceEnt( undefined );
	ent.player Unlink();
	ent.viewModel Delete();
}

fall_to_your_death( ent )
{
	ent = get_other_arm_ent( ent );
	anims = ent.anims;
	mult = 2;
	ent.viewModel SetFlaggedAnimKnobAllRestart( "anim", anims[ "fall" ], anims[ "root" ], 1, 0.15, mult );
	animlength = GetAnimLength( anims[ "fall" ] );
	animlength /= mult;
	wait( animlength * 0.5 );
	flag_set( "fade_to_death" );
	level waittill( "foreverever" );
}

should_fall( stabbed, fall_time, ent )
{
	if ( is_e3_start() )
		return false;

	if ( !stabbed )
		return false;

	if ( GetTime() > fall_time )
		return true;

//	if ( icepick_button_pressed( ent ) )
//		return false;

	ent = get_other_arm_ent( ent );

	if ( GetTimeSinceLastPaused() < 10000 )
		return false;

	return !icepick_button_pressed( ent );
}

player_jump_check( ent )
{
	for ( ;; )
	{
		ent.player.jumped = false;
		ent.player waittill( "jump" );
		ent.player.jumped = true;
		ent.player waittill( "climbing" );
	}
}

get_other_arm_ent( ent )
{
	other_arm = get_other_arm( ent.arm );
	return ent.globals.arm_ents[ other_arm ];
}

get_other_arm( current_arm )
{
	arms[ "left" ] = "right";
	arms[ "right" ] = "left";
	return arms[ current_arm ];
}

/*
finished_stabbing( ent )
{
	anims = ent.anims;
	if ( ent.viewModel GetAnimTime( anims[ "stab" ] ) >= 1.0 )
		return true;
	
	if ( !ent.globals.stab_notetrack )
		return false;
		
	if ( movement_stick_pressed( ent ) )
		return false;
		 
	// check to see if we're pressing the other arm
	other_arm = get_other_arm( ent.arm );
	other_arm_ent = ent.globals.arm_ents[ other_arm ];
	return !icepick_button_pressed( other_arm_ent );
}
*/

assign_random_waits( ent )
{
	ent.globals.random_wait_index = 0;
	ent.globals.random_waits = [];
	steps = 10;
	for ( i = 0; i < steps; i++ )
	{
		random_wait = i / steps;
		random_wait *= 0.25;
		ent.globals.random_waits[ i ] = random_wait;
	}

	ent.globals.random_waits = array_randomize( ent.globals.random_waits );
}

get_random_wait( ent )
{
	if ( ent.globals.random_wait_index >= ent.globals.random_waits.size )
	{
		assign_random_waits( ent );
	}

	random_wait = ent.globals.random_waits[ ent.globals.random_wait_index ];
	ent.globals.random_wait_index++;
	return random_wait;
}

add_icepicks()
{
	self anim_spawn_tag_model( "viewmodel_ice_picker", "tag_weapon_right" );
	self anim_spawn_tag_model( "viewmodel_ice_picker_03", "tag_weapon_left" );
}

right_add_test( ent )
{
	arm_models = [];
	arm_anims = [];
	arm_tags = [];
	additive_strength = [];

	arm = ent.arm;
	arm_anims[ arm ] = ent.anims;
	additive_strength[ arm ][ "additive_in" ] = ent.anims[ "additive_in_strength" ];
	additive_strength[ arm ][ "additive_out" ] = ent.anims[ "additive_out_strength" ];

	arm_models[ arm ] = get_fake_model( ent, "stab" );
	arm_models[ arm ] SetAnimTime( arm_anims[ arm ][ "stab" ], 1 );
	arm_models[ arm ] add_icepicks();
	arm_models[ arm ] Show();
	arm_models[ arm ].origin = ( 230, 200, 200 );

	ent = get_other_arm_ent( ent );

	arm = ent.arm;
	arm_anims[ arm ] = ent.anims;
	additive_strength[ arm ][ "additive_in" ] = ent.anims[ "additive_in_strength" ];
	additive_strength[ arm ][ "additive_out" ] = ent.anims[ "additive_out_strength" ];

	arm_models[ arm ] = get_fake_model( ent, "stab" );
	arm_models[ arm ] SetAnimTime( arm_anims[ arm ][ "stab" ], 1 );
	arm_models[ arm ] add_icepicks();
	arm_models[ arm ] Show();
	arm_models[ arm ].origin = ( 200, 200, 200 );

	steps = 40;
	add_types = [];
	add_types[ "additive_in" ] = "additive_out";
	add_types[ "additive_out" ] = "additive_in";
	add = "additive_in";

	left = arm_models[ "left" ];
	right = arm_models[ "right" ];
	left_anims = arm_anims[ "left" ];
	right_anims = arm_anims[ "right" ];

	Print3d( left.origin, left GetEntNum(), ( 1, 1, 0 ), 1, 0.3, 50000 );
	Print3d( right.origin, right GetEntNum(), ( 0, 1, 1 ), 1, 0.3, 50000 );
	left_tag_name = get_icepick_tag_name( "left" );
	right_tag_name = get_icepick_tag_name( "right" );

	extra_boost = level.additive_arm_boost;

	for ( ;; )
	{
		add = add_types[ add ];
		left SetAnimKnob( left_anims[ add ], 1, 0, 1 );
		//right SetAnimKnob( right_anims[ "correct_down" ], 1, 0, 1 );
		right SetAnimKnob( right_anims[ add ], 1, 0, 1 );

		for ( i = 0; i < steps; i++ )
		{
			index = i;
			weight = index / steps;
			if ( add == "additive_in" )
				weight = 1 - weight;
			weight = 1 - weight;
			weight *= extra_boost;

			//weight *= 4;

			left SetAnimLimited( left_anims[ "additive" ], weight * additive_strength[ "left" ][ add ], 0, 1 );
			right SetAnimLimited( right_anims[ "additive" ], weight * additive_strength[ "right" ][ add ], 0, 1 );

			//right SetAnimLimited( right_anims[ "vertical_corrector" ], weight * 0.2, 0, 1 );

			left_org = left GetTagOrigin( left_tag_name );
			right_org = right GetTagOrigin( right_tag_name );
			Print3d( left_org, ".", ( 1, 1, 0 ), 1, 0.2, 100 );
			Print3d( right_org, ".", ( 0, 1, 1 ), 1, 0.2, 100 );
			//Print3d( <origin>, <text>, <color>, <alpha>, <scale>, <duration> );
			wait( 0.05 );
		}
	}
}


wrist_test( ent )
{
	anims = ent.anims;
	fake_model = get_fake_model( ent, "stab" );
	fake_model SetAnimTime( anims[ "stab" ], 1 );
	fake_model add_icepicks();
	fake_model Show();
	fake_model.origin += ( 0, 200, 100 );

	types = [];
	types[ "wrist_in" ] = "wrist_in";
	types[ "wrist_out" ] = "wrist_in";

	add = [];
	add[ "wrist_in" ] = "additive_out";
	add[ "wrist_out" ] = "additive_in";

	add_adjust = [];
	add_adjust[ "wrist_out" ] = 1.7;
	add_adjust[ "wrist_in" ] = 8;


	type = "wrist_in";
	//fake_model thread maps\_debug::dragTagUntilDeath( "J_Wrist_LE", ( 0, 1, 0 ) );
	fake_model thread draw_ent_num();

	wait( 0.05 );
	fx_tag_name = get_icepick_tag_name( ent.arm );
	past_tag = spawn_icepick_fx_tag( fake_model, fx_tag_name );
	past_tag Unlink();
	past_tag move_forward( level.trace_depth );
	forward = AnglesToForward( past_tag.angles );
	//past_tag thread maps\_debug::dragTagUntilDeath( "tag_origin", (0,1,0) );

	current_tag = spawn_icepick_fx_tag( fake_model, fx_tag_name );
	current_tag Unlink();
	current_tag move_forward( level.trace_depth );
	current_tag LinkTo( fake_model, fx_tag_name );
	//current_tag thread maps\_debug::dragTagUntilDeath( "tag_origin", (1,1,0) );
	SetDvarIfUninitialized( "climb_float", 2.5 );

	fake_model thread fix_org( current_tag, past_tag );

	for ( ;; )
	{
		start = RandomFloatRange( 0, 1 );
		start = 1;
		/*
		type = types[ type ];
		arm_type = add[ type ];
		climb_float = add_adjust[ type ];
		*/

		// out 4.2


		wrist_types = [];
		wrist_types[ "additive_in" ] = "wrist_in";
		wrist_types[ "additive_out" ] = "wrist_out";
		additive_type = "additive_out";
		wrist_type = wrist_types[ additive_type ];

		fake_model ClearAnim( anims[ "wrist" ], 0 );
		fake_model SetAnimLimited( anims[ "wrist" ], 0, 0, 1 );

		fake_model SetAnimKnob( anims[ additive_type ], 1, 0, 1 );
		fake_model SetAnimLimited( anims[ "additive" ], level.additive_arm_boost * anims[ additive_type + "_strength" ] * start, 0, 1 );

		climb_float = anims[ additive_type + "_strength" ] * start * level.climb_wrist_mod;// 4.2;
		climb_float *= 0.2;

		wait( 0.7 );
		lerp_time = 1;
		fake_model ClearAnim( anims[ "additive" ], lerp_time );
		fake_model SetAnimKnob( anims[ wrist_type ], 1, 0, 1 );
		fake_model SetAnimLimited( anims[ "wrist" ], 0, 0, 1 );
		fake_model SetAnimLimited( anims[ "wrist" ], climb_float, lerp_time, 1 );

		wait( lerp_time );
		wait( 1.5 );
		fake_model SetAnimLimited( anims[ "wrist" ], climb_float * 0.35, lerp_time, 1 );
		wait( 1.2 );

		/*
		steps = 30;
		for ( i = 0; i < steps; i++ )
		{
			dif = ( i / steps );
			dif = 1 - dif;
			
			//weight = 1 - dif;
			weight = 1 - dif;
//			fake_model SetAnimLimited( anims[ "wrist" ], 0, 0, 1 );
//			fake_model SetAnimLimited( anims[ "additive" ], 0, 0, 1 );
			fake_model SetAnimLimited( anims[ "wrist" ], weight * climb_float, 0, 1 );
			fake_model SetAnimLimited( anims[ "additive" ], level.additive_arm_boost * dif, 0, 1 );
			wait( 0.05 );
			org_dif = past_tag.origin - current_tag.origin;
			fake_model.origin += org_dif;
				
			wait( 0.1 );
		}
		*/		
	}
}

fix_org( current_tag, past_tag )
{
	for ( ;; )
	{
		wait( 0.05 );
		org_dif = past_tag.origin - current_tag.origin;
		self.origin += org_dif;
	}
}

blend_out_additive_and_in_wrist( ent, fake_model, lerp_time )
{
	//wait( 0.05 ); // for up/down sillyness on right only bleh
	climb_float = ent.additive_weight / level.additive_arm_boost * level.climb_wrist_mod;// 4.2;
	climb_float *= 0.4;
	//climb_float = 0;

	if ( ent.climb_dir != "up" )
	{
		climb_float = 0;
	}
	//climb_float = 0;

	other_arm_ent = get_other_arm_ent( ent );
	anims = other_arm_ent.anims;
	other_arm_ent.viewModel ClearAnim( anims[ "wrist_in" ], lerp_time );
	other_arm_ent.viewModel ClearAnim( anims[ "wrist_out" ], lerp_time );
	fake_model ClearAnim( anims[ "wrist_in" ], lerp_time );
	fake_model ClearAnim( anims[ "wrist_out" ], lerp_time );

	anims = ent.anims;
	wrist_types = [];
	wrist_types[ "additive_in" ] = "wrist_in";
	wrist_types[ "additive_out" ] = "wrist_out";
	wrist_additive = wrist_types[ ent.additive_type ];

	ent.corrector_type = undefined;

	fake_model ClearAnim( anims[ "additive" ], lerp_time );
	if ( IsDefined( anims[ "vertical_corrector" ] ) )
	{
		fake_model ClearAnim( anims[ "vertical_corrector" ], lerp_time );
	}

	fake_model SetAnimKnob( anims[ wrist_additive ], 1, 0, 1 );
	fake_model SetAnimLimited( anims[ "wrist" ], 0, 0, 1 );
	fake_model SetAnimLimited( anims[ "wrist" ], climb_float, lerp_time, 1 );

	wait( 0.05 );

	ent.viewModel ClearAnim( anims[ "additive" ], lerp_time );
	if ( IsDefined( anims[ "vertical_corrector" ] ) )
		ent.viewModel ClearAnim( anims[ "vertical_corrector" ], lerp_time );

	ent.viewModel SetAnimKnob( anims[ wrist_additive ], 1, 0, 1 );
	ent.viewModel SetAnimLimited( anims[ "wrist" ], 0, 0, 1 );
	ent.viewModel SetAnimLimited( anims[ "wrist" ], climb_float, lerp_time, 1 );

	wait( lerp_time );
	/*
	fake_model SetAnimLimited( anims[ "wrist" ], 0, lerp_time, 1 );
	wait( 0.05 );	
	ent.viewModel SetAnimLimited( anims[ "wrist" ], 0, lerp_time, 1 );
	wait( lerp_time );
	*/
	fake_model notify( "stop_fixing_origin" );

}

move_forward( dist )
{
	forward = AnglesToForward( self.angles );
	self.origin += forward * dist;
}

arm_completes_stab( ent, skipRelink )
{
	if ( GetTime() < ent.globals.start_climb_time + 500 )
		return false;

	if ( ent.button_press_num == ent.button_press_num_last )
		return false;

	ent.viewModel notify( "stop_crack" );

	if ( !icepick_button_pressed( ent ) )
		return false;

	/*
	if ( !movement_stick_pressed( ent ) )
		return false;
	*/

	stab_success = arm_stabs( ent, skipRelink );
	if ( !stab_success )
		flag_set( "finished_climbing" );

	if ( GetDvarInt( "climb_automove" ) )
		wait( 0.5 );


	/*
	if ( stab_success )
	{
		if ( !flag( "final_climb" ) )
		{
			delay_for_reaching_top();
		}
	}
	*/
	return stab_success;
}

delay_for_reaching_top()
{
	max_height = 730;
	min_height = 550;
	max_wait = 0.4;
	range = max_height - min_height;

	
	height = level.player.origin[2] - min_height;
	if ( height <= 0 )
		return;
	if ( height > range )
		height = range;
	
	/*
	height
	range	max_wait
	*/
	
	wait_time = max_wait * height / range;
	wait( wait_time );	
}


GetStick( ent )
{
	movement = self GetNormalizedMovement();
	if ( GetDvarInt( "climb_automove" ) )
	{
		if ( ent.climb_dir == "up" )
			movement = ( 1, 0, 0 );
		if ( ent.climb_dir == "right" )
			movement = ( 0, 1, 0 );
		if ( ent.climb_dir == "left" )
			movement = ( 0, -1, 0 );
		return movement;
	}

	vert = movement[ 0 ];
	horz = movement[ 1 ];

	if ( ent.player ButtonPressed( "DPAD_UP" ) )
	{
		vert = 1;
	}
	if ( ent.player ButtonPressed( "DPAD_LEFT" ) )
	{
		horz = -1;
	}
	if ( ent.player ButtonPressed( "DPAD_RIGHT" ) )
	{
		horz = 1;
	}

	movement = ( vert, horz, 0 );
	return movement;
}

player_relinks_to_tag( ent )
{
	anims = ent.anims;
	ent.player endon( "stop_climbing" );
	/*
	if ( !isdefined( level.climb_first_link ) )
	{
		 // is it the main arms or debug arms?
		climb_normal_start_org = GetEnt( "climb_normal_start_org", "targetname" );
		fly_in = Distance( ent.viewModel.origin, climb_normal_start_org.origin ) < 150;
		fly_in = false;
		if ( fly_in )
		{
			ent.viewModel Hide();
			level.climb_first_link = true;
			climb_cam = GetEnt( "climb_cam", "targetname" );
			model = climb_cam spawn_tag_origin();
			timer = 0;
			ent.player PlayerLinkToBlend( model, "tag_origin", 0, 0, 0 );
			climb_cam delayThread( 2, ::self_delete );
			climb_cam = GetEnt( climb_cam.target, "targetname" );
			timer = 4.5;
			model MoveTo( climb_cam.origin, timer, 0, timer );
			model RotateTo( climb_cam.angles, timer * 2, 0, timer );
			
			wait( timer - 0.5 );
			ent.viewModel Show();
			ent.player PlayerLinkToBlend( ent.viewModel, "tag_player", timer, 0, timer );
			climb_cam delayThread( 2, ::self_delete );
			model delayThread( 2, ::self_delete );
		}
		else
		{
		}
	}
	else
	{
		timer = .6;
		ent.player PlayerLinkToBlend( ent.viewModel, "tag_player", timer, timer * 0.2, timer * 0.2 );
	}
	*/

	if ( !ent.globals.ground_ref_ent_set )
	{
		if ( level.player GetStance() == "crouch" )
		{
			level.player SetStance( "stand" );
			wait( 1 );
		}

		//start_climb_left
		//start_climb_right
		//early_climb_left
		//early_climb_right

		prefix = "start";
		if ( GetTime() < level.price_climb_time + 22000 )
			prefix = "early";

		start_climb = prefix + "_climb_left";
		ent.globals.current_arm = "right";
		if ( level.player rightSwingPressed() )
		{
			start_climb = prefix + "_climb_right";
			ent.globals.current_arm = "left";
		}

		thread start_climb_hint( ent );

		ent = ent.globals.arm_ents[ ent.globals.current_arm ];
		// put the hands in the first frame
		ent.viewModel SetFlaggedAnimKnobAll( "start_climb", anims[ start_climb ], anims[ "root" ], 1, 0, 0 );
		other_arm_ent = get_other_arm_ent( ent );
		thread start_climb_sfx( other_arm_ent );
		timer = 0.5;
		ent.player PlayerLinkToBlend( ent.viewModel, "tag_player", timer, timer * 0.2, timer * 0.2 );

		if ( start_climb == prefix + "_climb_left" )
		{
			other_arm_ent = get_other_arm_ent( ent );
			other_arm_ent.additive_type = "additive_out";
			other_arm_ent.additive_weight = 0.5;
			thread blend_in_additive( other_arm_ent );
		}

		//wait( timer - 0.05 );
		//ent.player PlayerLinkToDelta( ent.viewModel, "tag_player", 1, 0,0,0,0 );

		if ( !ent.globals.ground_ref_ent_set )
		{
			ent.player PlayerSetGroundReferenceEnt( ent.globals.ground_ref_ent );
			ent.globals.ground_ref_ent_set = true;
			wait .05;
		}

		ent.viewModel Show();
		level.player TakeAllWeapons();

		ent.viewModel SetFlaggedAnim( "start_climb", anims[ start_climb ], 1, 0, 1 );
		delayThread( 1.2, ::flag_set, "player_begins_to_climb" );
		SetSavedDvar( "sm_sunsamplesizenear", 0.0625 );

		for ( ;; )
		{
			if ( ent.viewModel GetAnimTime( anims[ start_climb ] ) > 0.97 )
				break;
			wait( 0.05 );
		}
		//ent.viewModel waittillmatch( "start_climb", "end" );

		other_arm_ent = get_other_arm_ent( ent );
		playerlinktodeltaWide( other_arm_ent, "tag_player" );
		return;
	}

	thread player_relinks_to_tag_threaded( ent );
	tag_angles = ent.viewModel GetTagAngles( "tag_view" );
	player_angles = ent.player GetPlayerAngles();
	tag_forward = AnglesToForward( tag_angles );
	player_forward = AnglesToForward( player_angles );
	dot = VectorDot( tag_forward, player_forward );
	level.dot = dot;
	if ( dot < 0.85 )
		wait( 0.2 );
}

playerlinktodeltaWide( ent, tag )
{
	if ( ent.arm == "right" )
		ent.player PlayerLinkToDelta( ent.viewModel, tag, 1, 22, 60, 40, 40, true );
	else
		ent.player PlayerLinkToDelta( ent.viewModel, tag, 1, 70, 28, 40, 40, true );
}

start_climb_sfx( ent )
{
	// special fx and sound for when you start climbing
	//ent.fx_tag thread maps\_debug::dragTagUntilDeath( "tag_origin", (0,1,0) );

	ent.viewModel waittillmatch( "start_climb", "stab" );
	ent.fx_tag traceFX_on_tag( "player_ice_pick", "tag_origin", 10 );

	ent.fx_tag PlaySound( "icepick_inactive_cracking" );
	ent.viewModel waittill( "stop_crack" );
	ent.fx_tag PlaySound( "icepick_inactive_cracking_stop" );
//	thread play_sound_in_space( "icepick_inactive_cracking", ent.fx_tag.origin );
}

player_relinks_to_tag_threaded( ent )
{
	ent.player endon( "stop_climbing" );

	timer = 0.3;
	ent.player PlayerLinkToBlend( ent.viewModel, "tag_player", timer, timer * 0.2, timer * 0.2 );
	wait( timer );
	ent.player PlayerLinkToDelta( ent.viewModel, "tag_player", 1, 0, 0, 0, 0, true );
	wait( 0.5 );
	playerlinktodeltaWide( ent, "tag_player" );
}


arm_stabs( ent, skipRelink )
{
	if ( !isdefined( skipRelink ) )
		player_relinks_to_tag( ent );
	// limit the player's fov while stabbing
	directions = [];
	directions[ 0 ] = "left";
	directions[ 1 ] = "right";
	ent.viewModel notify( "arm_stabs" );

	/*
	climb_dir = directions[ ent.globals.player_right ];
	
	movement = ent.player GetStick( ent );
	if ( movement[ 0 ] > CONST_min_stick_move )
	{
		climb_dir = "up";
	}
	else
	if ( movement[ 1 ] > CONST_min_stick_move )
	{
		climb_dir = "right";
	}
	else
	if ( movement[ 1 ] < CONST_min_stick_move * -1 )
	{
		climb_dir = "left";
	}
	else
	{
		if ( ent.globals.player_up )
			climb_dir = "up";
	}
	
	*/
	climb_dir = "up";// forcing up now

	// change the anims in use based on the current climbing direction
	set_ent_anims_for_climbing_direction( ent, climb_dir );
	arm_stab_begins( ent );

	anims = ent.anims;

	ent.globals.org_offset = undefined;
	thread calc_org_offset( ent );
	stab_length = GetAnimLength( anims[ "stab" ] );
	level.player PlaySound( "player_climb_effort" );
	wait( stab_length );
	stab_success = penetrable_surface( ent );

	surface = ent.surface_type;
	fx = "icepick_impact_" + surface;
	if ( fxExists( fx ) )
	{
		PlayFX( getfx( fx ), ent.hit_pos, ent.normal );
	}
	ent.viewModel thread climbing_cracks_think( ent, ent.hit_pos, ent.normal );

	thread play_sound_in_space( "icepick_impact_ice", ent.hit_pos );
			
	level.stabs_completed++;
	if ( level.stabs_completed == 3 )
	{
		level notify( "fourth_swing" );
		flag_set( "price_climb_continues" );
	}

	if ( reached_drop_down_spot( ent ) )
		return false;

	if ( stab_success )
	{
		level.player PlayRumbleOnEntity( "icepick_climb" );
		fake_model = get_fake_model( ent, "settle", undefined, ent.globals.fake_model );
		fake_model thread draw_ent_num( -60 );
		fake_model.origin += ent.globals.org_offset;
		//fake_model Show();
		ent.globals.fake_model = fake_model;

		//ent.viewModel waittillmatch( "stabbing", "end" );
		//ent.viewModel thread maps\_debug::drawTagTrails( "tag_origin", (1,0,0) );
		//ent.viewModel thread maps\_debug::drawTagTrails( "tag_player", (0,0,1) );

		level.settle = anims[ "settle" ];


		// now do the pull out and settle anim
		fake_model SetFlaggedAnimKnobRestart( "stabbing", anims[ "settle" ], 1, 0, 1 );
		ent.viewModel SetFlaggedAnimKnobRestart( "stabbing", anims[ "settle" ], 1, 0, 1 );
		thread modify_viewmodel_based_on_fakemodel( ent, fake_model );
		thread pop_origin( ent );
		delayThread( 0.05, ::blend_out_additive_and_in_wrist, ent, fake_model, 0.5 );

		ent.globals.climb_count++;
		if ( ent.globals.climb_count == 3 )
		{
			flag_set( "player_climbed_3_steps" );
		}

		ent.viewModel waittillmatch( "stabbing", "release" );

		level.player PlayRumbleOnEntity( "icepick_release" );

		ent.viewModel waittillmatch( "stabbing", "settle" );
		//blend_out_additive_and_in_wrist( ent, fake_model, 0.1 );
		//fake_model Delete();
		//fake_model notify( "stop_fixing_origin" );
		thread arm_idles( ent );

		if ( ent.climb_dir == "up" || ent.climb_dir != ent.arm )
		{
			random_wait = get_random_wait( ent );
			if ( random_wait > 0 )
				wait( random_wait );
		}
	}
	else
	{
		//level.player PlayRumbleOnEntity( "damage_heavy" );
		fail = "fail";
		ent.viewModel SetFlaggedAnimKnobRestart( "stabbing", anims[ fail ], 1, 0, 1 );
		ent.viewModel waittillmatch( "stabbing", "end" );

		// play the old idle because we didnt complete the swing
		other_arm_ent = get_other_arm_ent( ent );
		anims = other_arm_ent.anims;
		ent.viewModel SetAnimKnobAllRestart( anims[ "idle" ], anims[ "root" ], 1, 0.2, 1 );
	}
	// by now, all additives are blended out
	return stab_success;
}

modify_viewmodel_based_on_fakemodel( ent, fake_model )
{
	/*
	wait( 0.05 );
	waittillframeend;
	waittillframeend;
	*/

	//ent = get_other_arm_ent( ent );
	fx_tag_name = get_icepick_tag_name( ent.arm );
	past_tag = spawn_icepick_fx_tag( fake_model, fx_tag_name );
	past_tag Unlink();
	past_tag move_forward( level.trace_depth );
	forward = AnglesToForward( past_tag.angles );
	// past_tag thread maps\_debug::dragTagUntilDeath( "tag_origin", (0,1,0) );

	current_tag = spawn_icepick_fx_tag( fake_model, fx_tag_name );
	current_tag Unlink();
	current_tag move_forward( level.trace_depth );
	current_tag LinkTo( fake_model, fx_tag_name );
	//current_tag thread maps\_debug::dragTagUntilDeath( "tag_origin", (1,1,0) );

	fix_origins_until_death( ent, fake_model, past_tag, current_tag );

	anims = ent.anims;
	fake_model ClearAnim( anims[ "root" ], 0 );

	//current_tag Unlink();
	current_tag Delete();
	past_tag Delete();
}

player_gets_back_on_wall( ent )
{
	climb_get_on = GetEnt( "climb_get_on", "targetname" );
	ent.globals.climbing = true;
	ent.player notify( "climbing" );
	player_relinks_to_tag( ent );

	//// temp overwrite for the view until andrew can fix the change to ground plane ent
	ent.player PlayerLinkToDelta( ent.viewModel, "tag_player", 1, 0, 0, 0, 0, false );
	wait( 0.05 );


	playerlinktodeltaWide( ent, "tag_player" );
	ent.viewModel Show();
}

player_got_off_cliff( ent )
{
//	if ( IsDefined( ent.player.mantled ) )
//		return true;

//	if ( ent.player CanMantle() )
//		return true;
	if ( flag( "climb_pullup" ) )
		return true;

	if ( ent.player.jumped )
		return true;

	if ( !flag( "climb_drop_down" ) )
		return false;

	if ( ent.arm != "right" )
		return false;

	if ( ent.climb_dir != "right" )
		return false;

	return true;
}


detach_pick_2( player_arms )
{
	player_arms Detach( "viewmodel_ice_picker_03", "tag_weapon_left" );
	/*
	org = player_arms GetTagOrigin( "tag_weapon_right" );
	ang = player_arms GetTagAngles( "tag_weapon_right" );
	pick = Spawn( "script_model", org );
	pick SetModel( "weapon_ice_picker" );
	pick.angles = ang;
	pick PhysicsLaunchClient( pick.origin, ( 0, 0, -1 ) );
	*/
}

detach_pick( player_arms )
{
	player_arms Detach( "viewmodel_ice_picker", "tag_weapon_right" );
	org = player_arms GetTagOrigin( "tag_weapon_right" );
	ang = player_arms GetTagAngles( "tag_weapon_right" );
	pick = Spawn( "script_model", org );
	pick SetModel( "viewmodel_ice_picker" );
	pick.angles = ang;
	pick PhysicsLaunchClient( pick.origin, ( 0, 0, -1 ) );
}

free_ground_ref( timer )
{
	wait( timer );
	level.player PlayerSetGroundReferenceEnt( undefined );
}

reached_drop_down_spot( ent )
{
	if ( !player_got_off_cliff( ent ) )
		return false;

	if ( flag( "final_climb" ) && flag( "climb_pullup" ) )
	{
		ent.viewModel notify( "stop_crack" );

		anims = ent.anims;
		thread free_ground_ref( 1.5 );
		//ent.viewModel RotateTo( ( 0, ent.viewModel.angles[ 1 ], 0 ), 0.2 );
		struct = getstruct( "player_icepicker_bigjump_end_getup", "targetname" );
		//ent.viewModel moveto( struct.origin, 0.2 );
		//ent.viewModel rotateto( struct.angles, 0.2 );
		
		//ent.viewModel SetFlaggedAnimKnobAllRestart( "anim", anims[ "climb_finish" ], anims[ "root" ], 1, 0.15, 1 );
		//thread start_notetrack_wait( ent.viewModel, "anim", "climbing" );
		timer = 0.5;
	
		
		animation = ent.viewmodel getanim( "climb_finish" );
//		time = getanimlength( animation );

		//maps\_debug::drawArrow( ent.viewmodel.origin, ent.viewmodel.angles, (1,0,0), 5000 );
		org = GetStartOrigin( struct.origin, struct.angles, animation );
		ang = GetStartAngles( struct.origin, struct.angles, animation );
		//maps\_debug::drawArrow( org, ang, (0,0,1), 5000 );

		ent.viewmodel hide();
		ent.viewmodel delaycall( 0.1, ::show );		
		ent.player PlayerLinkToBlend( ent.viewmodel, "tag_origin", timer, timer * 0.2, timer * 0.2 );
		struct anim_single_solo( ent.viewmodel, "climb_finish" );

//		level.player delaycall( ::PlayerSetGroundReferenceEnt, undefined );
	
		//ent.viewModel waittillmatch( "anim", "end" );
		ent.viewModel Hide();
		ent.player Unlink();
		wait( 0.05 );
		PrintLn( "Origin " + level.player.origin );
		ent.player SetMoveSpeedScale( 1 );
		ent.player notify( "stop_climbing" );
		return true;
	}

	ent.player notify( "stop_climbing" );

	/*
	anims = ent.anims;

	// player drops down and stops climbing
	ent.viewModel SetFlaggedAnimKnobRestart( "jump", anims[ "jump_down_start" ], 1, 0, 1 );
	timer = GetAnimLength( anims[ "jump_down_start" ] );
	//wait( timer * 0.45 ); // drops too far so clip the end
	//ent.player Unlink();
	*/

	ent.globals.climbing = false;
	ent.globals.ground_ref_ent_set = false;

	if ( flag( "climb_pullup" ) && !flag( "final_climb" ) )
	{
		ent.viewModel notify( "stop_crack" );
		level.player PlayerLinkToDelta( ent.viewModel, "tag_player", 1, 0, 0, 0, 0 );
		/*
		model = undefined;
		ent.viewModel Hide();
		climb_to_ridge = GetEnt( "climb_to_ridge", "targetname" );
		model = climb_to_ridge spawn_tag_origin();
		timer = 1;
		ent.player PlayerLinkToBlend( model, "tag_origin", timer, timer * 0.5, timer * 0.5 );
		wait( timer );

		ent.player PlayerSetGroundReferenceEnt( undefined );
		*/

		climb_jump_org = GetEnt( "climb_jump_org", "targetname" );
		animation = ent.viewModel getanim( "first_pullup_" + ent.globals.current_arm );
		org = GetStartOrigin( climb_jump_org.origin, climb_jump_org.angles, animation );
		ang = GetStartAngles( climb_jump_org.origin, climb_jump_org.angles, animation );

		ent.viewmodel.origin = org;
		ent.viewmodel.angles = ang;
		anims = ent.anims;
		blendTime = 0;
		ent.viewmodel ClearAnim( anims[ "root" ], blendTime );
		//ent.viewmodel MoveTo( org, blendTime );
		//ent.viewmodel RotateTo( ang, blendTime );
		ent.viewmodel SetFlaggedAnimKnob( "animdone", animation, 1, blendTime, 1 );
		thread start_notetrack_wait( ent.viewModel, "animdone", "climbing" );

		ent.viewmodel waittillmatch( "animdone", "end" );
		//climb_jump_org anim_single_solo( ent.viewModel, "first_pullup_" + ent.globals.current_arm );
		ent.player Unlink();
//		model Delete();
		ent.player SetMoveSpeedScale( 1 );
		ent.viewModel Hide();


		thread player_big_jump();

		return true;
	}

	ent.viewModel Hide();

	ent.player PlayerSetGroundReferenceEnt( undefined );
	ent.player SetMoveSpeedScale( 0.35 );

//	if ( IsDefined( ent.player.mantled ) )
//		return true;
	/*
	if ( ent.player CanMantle() )
	{
		ent.player Unlink();
		ent.player ForceMantle();
		wait( 1550 );
		return true;
	}
	*/

	jump_down_org = GetEnt( "jump_down_org", "targetname" );
	model = jump_down_org spawn_tag_origin();
	model.origin = jump_down_org.origin + ( 0, 0, 1 );
	timer = 0.4;
	ent.player PlayerLinkToBlend( model, "tag_origin", timer, timer * 0.2, timer * 0.2 );
	wait( timer );
	wait( 0.1 );// settle
	ent.player Unlink();
	model Delete();

	// prep the get-back-on	
	climb_get_on = GetEnt( "climb_get_on", "targetname" );
	ent.viewModel.origin = climb_get_on.origin;
	ent.viewModel.angles = climb_get_on.angles;
	ent.globals.current_arm = "left";
	set_ent_anims_for_climbing_direction( ent, "up" );
	anims = ent.anims;
	ent.viewModel ClearAnim( anims[ "player_climb_root" ], 0 );
	ent.viewModel SetFlaggedAnimKnobRestart( "stabbing", anims[ "idle" ], 1, 0, 1 );

	return true;
}

fix_origins_until_death( ent, fake_model, past_tag, current_tag )
{
	//fake_model endon( "death" );
	fake_model endon( "stop_fixing_origin" );

	for ( ;; )
	{
		wait( 0.05 );
		//org_dif = model1_tag.origin - viewModel_tag.origin;
		//viewModel_org_tag.origin += org_dif;
		// TransformMove( <position T1>, <angles T1>, <position T2>, <angles T2>, <position E>, <angles E> )

		org_dif = past_tag.origin - current_tag.origin;
		array = TransformMove( past_tag.origin, past_tag.angles, current_tag.origin, current_tag.angles, fake_model.origin, fake_model.angles );
		//ent.viewModel.origin = array[ "origin" ];
		fake_model.origin += org_dif;
		ent.viewModel.origin += org_dif;
		dist = Distance( ( 0, 0, 0 ), org_dif );
		dist *= 10;
		dist = Int( dist );
		dist *= 0.1;
		//println( "Org dif " + dist );

		pitch = array[ "angles" ][ 0 ];
		if ( pitch > 200 )
		{
			// dont slant to the wall if it slants back
			pitch = 0;
		}
		//pitch = 0;

		fake_model.angles = ( pitch, array[ "angles" ][ 1 ], 0 );
		ent.viewModel.angles = ( pitch, array[ "angles" ][ 1 ], 0 );

	}
}

calc_org_offset( ent )
{
	wait( 0.05 );
	anims = ent.anims;
	fake_stab = get_fake_model( ent, "stab" );
	fake_settle = get_fake_model( ent, "settle" );
	fake_stab SetAnimTime( anims[ "stab" ], 1.0 );
	fake_settle SetAnimTime( anims[ "settle" ], 0.0 );
	wait( 0.05 );

	stab_org = fake_stab GetTagOrigin( "tag_player" );
	settle_org = fake_settle GetTagOrigin( "tag_player" );
	ent.globals.org_offset = stab_org - settle_org;
	fake_stab Delete();
	fake_settle Delete();

	//ent.globals.org_offset *= 0.5;
}

pop_origin( ent )
{
	AssertEx( IsDefined( ent.globals.org_offset ), "no org offset to pop" );
	ent.viewModel DontInterpolate();
	ent.viewModel.origin += ent.globals.org_offset;
}

arm_idles( ent )
{
	anims = ent.anims;
	ent.viewModel endon( "arm_stabs" );
	ent.viewModel waittillmatch( "stabbing", "end" );
	ent.viewModel SetAnimKnobAllRestart( anims[ "idle" ], anims[ "root" ], 1, 0, 1 );
}

set_ent_anims_for_climbing_direction( ent, climb_dir )
{
	// change the anims in use based on the current climbing direction
	ent.anims = get_anims_for_climbing_direction( ent.anims, climb_dir, ent.arm );
	ent.climb_dir = climb_dir;
	other_arm = get_other_arm( ent.arm );
	other_arm_ent = ent.globals.arm_ents[ other_arm ];

	other_arm_ent.anims = get_anims_for_climbing_direction( other_arm_ent.anims, climb_dir, other_arm_ent.arm );
}

arm_stab_begins( ent )
{
	anims = ent.anims;

	blendTime = 0.2;
	ent.viewModel ClearAnim( anims[ "root" ], blendTime );
	ent.viewModel SetFlaggedAnimKnobRestart( "stabbing", anims[ "stab" ], 1, blendTime, 1 );
	thread catch_stab_notetrack( ent );
	thread calculate_additive( ent );

	//println( "difference " + ( ent.viewModel GetTagOrigin( "tag_player" ) - ent.old_org ) );
	//ent.player DontInterpolate();
	//ent.viewModel DontInterpolate();
//	ent.viewModel.origin += ent.viewModel GetTagOrigin( "tag_player" ) - ent.old_org;
	ent.old_origin = ent.viewModel.origin;
}

catch_stab_notetrack( ent )
{
	ent notify( "searching_for_new_stab_notetrack" );
	ent endon( "searching_for_new_stab_notetrack" );

	anims = ent.anims;
	ent.globals.stab_notetrack = false;
	ent.viewModel waittillmatch( "stabbing", "stab" );
	ent.globals.stab_notetrack = true;
}

blend_in_corrector( ent, additive_mod )
{
	if ( ent.corrector_weight <= 0 )
		return;
	anims = ent.anims;

	if ( additive_mod != 0 )
	{
		apply_additive_mod_to_ent( ent, additive_mod );
		ent.viewModel SetAnimKnob( anims[ ent.additive_type ], 1, 0, 1 );
		ent.viewModel SetAnimLimited( anims[ "additive" ], ent.additive_weight, 0, 1 );
	}

	ent.viewModel SetAnimKnob( anims[ ent.corrector_type ], 1, 0, 1 );
	ent.viewModel SetAnimLimited( anims[ "vertical_corrector" ], ent.corrector_weight, 0, 1 );
}

blend_in_additive( ent )
{
	anims = ent.anims;
	ent.viewModel SetAnimKnob( anims[ ent.additive_type ], 1, 0, 1 );
	ent.viewModel SetAnimLimited( anims[ "additive" ], ent.additive_weight, 0, 1 );
}

calculate_additive( ent )
{
	//ent = get_other_arm_ent( ent );
	old_org = ent.viewModel.origin;

	// make fake arms that trial the various degrees of additive to find out which one will strike the surface
	hits = SpawnStruct();
	hits.calcs = [];
	hits.surface_types = [];
	hits.normals = [];
	hits.hit_pos = [];

	weights = [];
	weight_type = [];
	extra_boost = level.additive_arm_boost;
	anims = ent.anims;

	additive_type = "additive_in";
	//steps = ent.additive_models[ additive_type ].size;
	steps = 40;
	for ( i = 0; i < steps; i++ )
	{
		additive_weight = i / steps * extra_boost * anims[ additive_type + "_strength" ];// "additive_in_strength / additive_out_strength"
		weights[ i ] = additive_weight;
		weight_type[ i ] = additive_type;

		hits thread calculate_add_penetration( ent, i, additive_weight, additive_type );
	}

	additive_type = "additive_out";
	for ( i = 0; i < steps; i++ )
	{
		additive_weight = i / steps * extra_boost * anims[ additive_type + "_strength" ];// "additive_in_strength / additive_out_strength"
		index = i + steps;
		weights[ index ] = additive_weight;
		weight_type[ index ] = additive_type;

		hits thread calculate_add_penetration( ent, index, additive_weight, additive_type );
	}

	wait( 0.05 );	// takes a frame for animations to take effect
	waittillframeend;// wait until all calcs are finished
	additive_weight = 0;
	highest_hit_depth = 1000;

	hits.hit_index = 0;
	found_penetratable = false;
	desired_hit_depth = 0.98;
	hit_depth_difference = 1000;

	foreach ( index, hit_depth in hits.calcs )
	{
		/*
		if ( !legal_hit_depth( hit_depth ) )
		{
			// did not impact the surface
			continue;
		}
		*/

		penetrable = penetrable_surface( ent, hits.surface_types[ index ] );
		if ( !penetrable )
			continue;

		abs_difference_between_hit_depth_and_desired_hit_depth = abs( hit_depth - desired_hit_depth );

		if ( abs_difference_between_hit_depth_and_desired_hit_depth > hit_depth_difference )
			continue;

		hit_depth_difference = abs_difference_between_hit_depth_and_desired_hit_depth;

		/*
		//if ( index > hits.hit_index )
		if ( hit_depth >= highest_hit_depth )
			continue;
		*/


		found_penetratable = penetrable;

		highest_hit_depth = hit_depth;
		additive_weight = weights[ index ];
		hits.hit_index = index;
		additive_type = weight_type[ index ];
	}

	if ( !isdefined( hits.hit_index ) )
	{
		// didnt hit anything so jam it all the way in.
		additive_weight = 1 * extra_boost;
		additive_type = "additive_in";
		ent.surface_type = "none";
	}
	else
	{
		ent.surface_type = hits.surface_types[ hits.hit_index ];
		ent.normal = hits.normals[ hits.hit_index ];
		ent.hit_pos = hits.hit_pos[ hits.hit_index ];
	}

	ent.additive_type = additive_type;
	ent.additive_weight = additive_weight;

	if ( !penetrable_surface( ent ) )
	{
		try_to_do_vertical_correction( ent );
	}

	//assertex( old_org == ent.viewModel.origin, "arm model origin changed" );
	thread blend_in_additive( ent );
}

try_to_do_vertical_correction( ent )
{
	if ( ent.climb_dir == "up" )
		return;
	if ( ent.arm != ent.climb_dir )
		return;

	hits = SpawnStruct();
	hits.calcs = [];
	hits.surface_types = [];
	hits.normals = [];
	hits.hit_pos = [];

	additive_mods = [];
	weights = [];
	weight_type = [];

	anims = ent.anims;
	additive_strength = 1;
	extra_boost = 2;
	steps = 10;
	inward_steps = 6;
	half_step = inward_steps * 0.5;



	waittillframeend;// for old models to get deleted

	additive_type = undefined;
	for ( p = 0; p < inward_steps; p++ )
	{
		additive_mod = ( p - half_step ) / inward_steps;
		additive_type = "correct_up";
		for ( i = 0; i < steps; i++ )
		{
			additive_weight = i / steps * extra_boost * additive_strength;
			index = i + p * steps;
			weights[ index ] = additive_weight;
			weight_type[ index ] = additive_type;
			additive_mods[ index ] = additive_mod;

			hits thread calculate_add_vertical_correction( ent, index, additive_weight, additive_type, additive_mod );
		}
		additive_type = "correct_down";
		for ( i = 0; i < steps; i++ )
		{
			additive_weight = i / steps * extra_boost * additive_strength;
			index = inward_steps * steps + i + p * steps;
			weights[ index ] = additive_weight;
			weight_type[ index ] = additive_type;
			additive_mods[ index ] = additive_mod;

			hits thread calculate_add_vertical_correction( ent, index, additive_weight, additive_type, additive_mod );
		}
	}
	wait( 0.05 );
	waittillframeend;// wait until all calcs are finished
	additive_weight = 0;
	highest_hit_depth = 1000;

	hits.hit_index = 0;
	additive_mod = 0;

	foreach ( index, hit_depth in hits.calcs )
	{
		if ( !penetrable_surface( ent, hits.surface_types[ index ] ) )
			continue;

		if ( !legal_hit_depth( hit_depth ) )
			continue;

		//if ( index > hits.hit_index )
		if ( hit_depth < highest_hit_depth )
		{
			highest_hit_depth = hit_depth;
			additive_weight = weights[ index ];
			hits.hit_index = index;
			additive_type = weight_type[ index ];
			additive_mod = additive_mods[ index ];
		}
	}

	if ( !isdefined( hits.hit_index ) )
	{
		return;
	}
	else
	{
		ent.surface_type = hits.surface_types[ hits.hit_index ];
		ent.normal = hits.normals[ hits.hit_index ];
		ent.hit_pos = hits.hit_pos[ hits.hit_index ];
	}

	ent.corrector_type = additive_type;
	ent.corrector_weight = additive_weight;

	//assertex( old_org == ent.viewModel.origin, "arm model origin changed" );
	thread blend_in_corrector( ent, additive_mod );
}

legal_hit_depth( hit_depth )
{
	if ( hit_depth <= 0.9 )
		return false;
	if ( hit_depth >= 0.98 )
		return false;
	return true;
}

set_arm_weight( ent, weight )
{
	ent.globals.arm_weight = weight;
}

get_arm_weight( ent )
{
	return ent.globals.arm_weight;
}

get_fake_model( ent, anim_type, override_ent, optional_model )
{
	// create a copy of the existing arms
	anims = ent.anims;
	model = ent.viewModel;

	additive_weight = [];
	additive_type = [];

	corrector_type = [];
	corrector_weight = [];

	foreach ( arm, arm_ent in ent.globals.arm_ents )
	{
		if ( arm == ent.arm )
		{
			additive_type[ arm ] = ent.globals.arm_ents[ arm ].additive_type;
			additive_weight[ arm ] = ent.globals.arm_ents[ arm ].additive_weight;
			if ( IsDefined( ent.globals.arm_ents[ arm ].corrector_type ) )
			{
				corrector_type[ arm ] = ent.globals.arm_ents[ arm ].corrector_type;
				corrector_weight[ arm ] = ent.globals.arm_ents[ arm ].corrector_weight;
			}
		}
		else
		{
			additive_type[ arm ] = ent.globals.arm_ents[ arm ].additive_type;
			additive_weight[ arm ] = 0;
		}
	}

	// override values to make new arm positions
	if ( IsDefined( override_ent ) )
	{
		if ( IsDefined( override_ent.additive_weight ) )
		{
			foreach ( arm, add_weight in override_ent.additive_weight )
			{
				additive_weight[ arm ] = add_weight;
			}
		}

		if ( IsDefined( override_ent.additive_type ) )
		{
			foreach ( arm, add_type in override_ent.additive_type )
			{
				additive_type[ arm ] = add_type;
			}
		}
	}

	fake_model = optional_model;
	if ( !isdefined( optional_model ) )
		fake_model = spawn_anim_model( "player_rig" );

	fake_model Hide();
	fake_model.origin = ent.viewModel.origin;
	fake_model.angles = ent.viewModel.angles;


	fake_model ClearAnim( anims[ "root" ], 0 );
	fake_model SetAnimKnobRestart( anims[ anim_type ], 1, 0, 0 );

	foreach ( arm, arm_ent in ent.globals.arm_ents )
	{
		anims = arm_ent.anims;
		add_type = additive_type[ arm ];
		add_weight = additive_weight[ arm ];
		cor_type = corrector_type[ arm ];
		cor_weight = corrector_weight[ arm ];

		fake_model SetAnimLimited( anims[ "additive" ], add_weight, 0, 1 );
		fake_model SetAnimLimited( anims[ add_type ], add_weight, 0, 1 );

		if ( IsDefined( cor_type ) )
		{
			fake_model SetAnimLimited( anims[ "vertical_corrector" ], cor_weight, 0, 1 );
			fake_model SetAnimLimited( anims[ cor_type ], cor_weight, 0, 1 );
		}
	}

	return fake_model;
}

trace_test()
{
	for ( ;; )
	{
		targ = GetEnt( self.target, "targetname" );
		trace = BulletTrace( self.origin, targ.origin, false, undefined );
		//line( self.origin, trace[ "position" ], ( 0.4, 0.4, 0.5 ), 1, 1, 5000 );
//		Line( trace[ "position" ], trace[ "position" ] + trace[ "normal" ] * 15, ( 0.3, 0.85, 0.53 ), 1, 1, 5000 );
		Line( trace[ "position" ], trace[ "position" ] + trace[ "normal" ] * 15, ( 0.9, 0.3, 0.2 ), 1, 1, 5000 );
		Print3d( trace[ "position" ], trace[ "surfacetype" ], ( 1, 1, 0 ), 1, 0.5 );

		wait( 0.05 );
//		self.origin += randomvector( 64 );
//		targ.origin += randomvector( 64 );
	}
}


get_time_for_notetrack( ent, anim_type, notetrack )
{
	if ( !isdefined( ent.notetrack_times[ anim_type ] ) )
		return 1;
	if ( !isdefined( ent.notetrack_times[ anim_type ][ notetrack ] ) )
		return 1;
	return ent.notetrack_times[ anim_type ][ notetrack ];
}

set_time_to_notetrack( ent, anim_type, notetrack )
{
	anims = ent.anims;
	time = get_time_for_notetrack( ent, anim_type, notetrack );
	self SetAnimTime( anims[ anim_type ], time );
}

calculate_add_penetration( ent, index, additive_weight, additive_type )
{
	anims = ent.anims;
	model = ent.viewModel;

	arm = ent.arm;
	overrides = SpawnStruct();
	overrides.additive_weight[ arm ] = additive_weight;
	overrides.additive_type[ arm ] = additive_type;
	fake_model = get_fake_model( ent, "stab", overrides );
	//fake_model set_time_to_notetrack( ent, "stab", "stab" );
	fake_model SetAnimTime( anims[ "stab" ], 1.0 );
	/#
	fake_model add_icepicks();
	#/

	//fake_model.org.origin = ent.viewModel.origin;
	//fake_model.org.angles = ent.viewModel.angles;
	//fake_model SetAnimLimited( anims[ "additive" ], additive_weight, 0, 1 );
	//fake_model SetAnimLimited( anims[ additive_type ], additive_weight, 0, 1 );

	fx_tag_name = get_icepick_tag_name( ent.arm );
	fx_tag = spawn_icepick_fx_tag( fake_model, fx_tag_name );

	wait( 0.05 );

	forward = AnglesToForward( fx_tag.angles );
	trace_depth = level.trace_depth;
	start = fx_tag.origin + forward * ( trace_depth * -5 );
	end = fx_tag.origin + forward * trace_depth;
	trace = BulletTrace( start, end, false, undefined );
	/*
	if ( trace[ "fraction" ] < 1 )
	{
		frac = trace[ "fraction" ];
		frac *= 10;
		frac = Int( frac );
		frac *= 0.1;
		Print3d( trace[ "position" ], frac, ( 1, 0, 0 ), 1, 0.4, 5000 );
	}
	*/
	self.calcs[ index ] = trace[ "fraction" ];
	self.surface_types[ index ] = trace[ "surfacetype" ];
	self.normals[ index ] = trace[ "normal" ];
	self.hit_pos[ index ] = trace[ "position" ];


	/#
	wait( 0.05 );
	if ( GetDvarInt( "climb_add" ) )// && legal_hit_depth( trace[ "fraction" ] ) )
	{
		fake_model Show();
		line_time = 50;
		depthTest = false;
		if ( !isdefined( self.hit_index ) )
		{
			//line( start, trace[ "position" ], (1,0,0), 1, depthTest, line_time );
		}
		else
		{
			if ( self.hit_index == index )
			{
				Line( start + ( 1, 1, 0 ), trace[ "position" ] + ( 1, 1, 0 ), ( 1, 0, 0 ), 1, depthTest, line_time );
				frac = trace[ "fraction" ];
				frac *= 10;
				frac = Int( frac );
				frac *= 0.1;
				Print3d( trace[ "position" ], frac, ( 1, 0, 0 ), 1, 0.4, 5000 );
				wait( 0.8 );
			}
			else
			{
				//line( start, trace[ "position" ], (0,0,1), 1, depthTest, line_time );
	//			fake_model Delete();
			}
		}
	}
	//wait( 3 );
	#/

	fake_model Delete();
	fx_tag Delete();
	/*
	if ( trace[ "fraction" ] < 1 )
	{
		Line( fx_tag.origin, trace[ "position" ], (1,1,1), 1, 1, 5000 );
	}
	*/
}

apply_additive_mod( arm, overrides, additive_mod )
{
	overrides.additive_weight[ arm ] += additive_mod;
	if ( overrides.additive_weight[ arm ] >= 0 )
		return;

	overrides.additive_weight[ arm ] *= -1;
	if ( overrides.additive_type[ arm ] == "additive_in" )
		overrides.additive_type[ arm ] = "additive_out";
	else
		overrides.additive_type[ arm ] = "additive_in";
}

apply_additive_mod_to_ent( ent, additive_mod )
{
	ent.additive_weight += additive_mod;
	if ( ent.additive_weight >= 0 )
		return;

	ent.additive_weight *= -1;
	if ( ent.additive_type == "additive_in" )
		ent.additive_type = "additive_out";
	else
		ent.additive_type = "additive_in";
}

calculate_add_vertical_correction( ent, index, additive_weight, additive_type, additive_mod )
{
	anims = ent.anims;
	model = ent.viewModel;

	arm = ent.arm;
	overrides = SpawnStruct();
	overrides.additive_weight[ arm ] = ent.additive_weight;
	overrides.additive_type[ arm ] = ent.additive_type;

	apply_additive_mod( arm, overrides, additive_mod );

	fake_model = get_fake_model( ent, "stab", overrides );
	fake_model SetAnimTime( anims[ "stab" ], 1.0 );
	/#
	fake_model add_icepicks();
	#/

	fake_model SetAnimLimited( anims[ "vertical_corrector" ], additive_weight, 0, 1 );
	fake_model SetAnimKnob( anims[ additive_type ], additive_weight, 0, 1 );

	fx_tag_name = get_icepick_tag_name( ent.arm );
	fx_tag = spawn_icepick_fx_tag( fake_model, fx_tag_name );

	wait( 0.05 );

	forward = AnglesToForward( fx_tag.angles );
	trace_depth = level.trace_depth;
	start = fx_tag.origin + forward * ( trace_depth * -5 );
	end = fx_tag.origin + forward * trace_depth;
	trace = BulletTrace( start, end, false, undefined );

	self.calcs[ index ] = trace[ "fraction" ];
	self.surface_types[ index ] = trace[ "surfacetype" ];
	self.normals[ index ] = trace[ "normal" ];
	self.hit_pos[ index ] = trace[ "position" ];

	wait( 0.05 );

	/#
	if ( GetDvarInt( "climb_add" ) )
	//if ( trace[ "surfacetype" ] != "none" )
	{
		fake_model Show();
		line_time = 50;
		depthTest = false;
		if ( !isdefined( self.hit_index ) )
		{
			Line( start, trace[ "position" ], ( 1, 0, 0 ), 1, depthTest, line_time );
		}
		else
		{
			if ( self.hit_index == index )
			{
				Line( start + ( 1, 1, 0 ), trace[ "position" ] + ( 1, 1, 0 ), ( 1, 0, 0 ), 1, depthTest, line_time );
				frac = trace[ "fraction" ];
				frac *= 10;
				frac = Int( frac );
				frac *= 0.1;
				Print3d( trace[ "position" ], frac, ( 1, 0, 0 ), 1, 0.4, 5000 );
			}
			else
			{
				Line( start, trace[ "position" ], ( 0, 0, 1 ), 1, depthTest, line_time );
	//			fake_model Delete();
			}
		}
		wait( 0.8 );
	}
	#/

	fake_model Delete();
	fx_tag Delete();
	/*
	if ( trace[ "fraction" ] < 1 )
	{
		Line( fx_tag.origin, trace[ "position" ], (1,1,1), 1, 1, 5000 );
	}
	*/
}

arm_transitioning( ent )
{
	anims = ent.anims;

	//if ( ent.viewModel GetAnimTime( anims[ "low_release" ] ) >= 0.95 )
	//	return false;

	if ( ent.viewModel GetAnimTime( anims[ "stab" ] ) > 0 )
		return true;

	//if ( ent.viewModel GetAnimTime( anims[ "high_release" ] ) < 1 )
	//	return true;

	return false;
}

movement_stick_pressed( ent )
{
	movement = ent.player GetStick( ent );
	if ( abs( movement[ 0 ] ) > CONST_min_stick_move )
		return true;
	return abs( movement[ 1 ] ) > CONST_min_stick_move;
}

button_detection( ent )
{
	ent.button_pressed = icepick_button_pressed( ent );
	ent.button_press_num = 0;
	ent.button_press_num_last = 0;

	held_at_start = false;
	if ( ent.button_pressed || icepick_button_pressed_instant( ent ) )
	{
		ent.button_press_num_last++;
		held_at_start = true;
	}

	for ( ;; )
	{
		if ( icepick_button_pressed_instant( ent ) || held_at_start )
		{
			ent.button_press_num++;
			ent.button_pressed = true;
			while ( icepick_button_pressed_instant( ent ) )
			{
				wait( 0.05 );
			}
		}
		held_at_start = false;
		ent.button_pressed = false;
		wait( 0.05 );
	}
}

track_trigger_pulls( globals )
{
	ent = globals.arm_ents[ "left" ];
	ent.viewModel endon( "death" );
	for ( ;; )
	{
		ent = globals.arm_ents[ "left" ];
		if ( ent.player [[ ent.buttonCheck ]]() )
		{
			ent.last_button_press = GetTime();
			if ( !flag( "we_care_about_right_icepick" ) )
			{
				flag_set( "we_care_about_right_icepick" );
				ent = globals.arm_ents[ "right" ];
				ent.last_button_press = GetTime();
			}
		}

		if ( flag( "we_care_about_right_icepick" ) )
		{
			ent = globals.arm_ents[ "right" ];
			if ( ent.player [[ ent.buttonCheck ]]() )
				ent.last_button_press = GetTime();
		}
		wait( 0.05 );
	}
}

icepick_button_pressed( ent )
{
	if ( ent.player ButtonPressed( ent.key ) )
		return true;
	return ent.last_button_press + 750 > GetTime();
}

icepick_button_pressed_instant( ent )
{
	if ( ent.player ButtonPressed( ent.key ) )
		return true;
	return ent.player [[ ent.buttonCheck ]]();
}

link_model( model )
{
	SetDvar( "b1", "0" );
	SetDvar( "b2", "90" );
	SetDvar( "b3", "40" );
	for ( ;; )
	{
		b1 = GetDvarInt( "b1" );
		b2 = GetDvarInt( "b2" );
		b3 = GetDvarInt( "b3" );
		//self LinkTo( model, "tag_player", (0,0,0), (b1,b2,b3) );
		angles = model GetTagAngles( "tag_player" );
		yaw = angles[ 1 ];
		self.angles = ( 0, yaw, 0 );
		self.origin = model GetTagOrigin( "tag_player" );
		if ( 1 )
			return;
		wait( 0.05 );
	}
}

track_model( model )
{
//	self.angles = (0,-90,0);
	z = model.origin[ 2 ] - 1000;
	for ( ;; )
	{

		org1 = model GetTagOrigin( "j_wrist_le" );
		org2 = model GetTagOrigin( "j_wrist_ri" );
		org = org1 * 0.5 + org2 * 0.5;
		forward = AnglesToForward( model.angles );
		move_vec = forward * -145;
		move_vec = ( move_vec[ 0 ], move_vec[ 1 ], 0 );
		org += move_vec;

		// never climb downwards
		if ( org[ 2 ] < z )
		{
			org = ( org[ 0 ], org[ 1 ], z );
		}
		z = org[ 2 ];

		self MoveTo( org + ( 0, 0, -60 ), 0.3 );
		view_angles = VectorToAngles( model.origin - org );
		self RotateTo( ( 0, view_angles[ 1 ], 0 ), 0.3 );
		wait( 0.3 );
	}
}


test_player_angle( global )
{
	for ( ;; )
	{
		player_angles = global.player GetPlayerAngles();
		tag_angles = self GetTagAngles( "tag_player" );

		//maps\_debug::drawArrow( ent.globals.player.origin, player_angles, ( 1,1,1 ) );
		//maps\_debug::drawArrow( ent.globals.player.origin, tag_angles, ( 0.4,0.4,1 ) );

		//player_angles = ( tag_angles[ 0 ], player_angles[ 1 ], player_angles[ 2 ] );

		player_forward = AnglesToForward( player_angles );
		tag_forward = AnglesToForward( tag_angles );

		player_right = AnglesToRight( player_angles );
		player_up = AnglesToUp( player_angles );

		global.player_dot = VectorDot( player_forward, tag_forward );
		global.player_right = VectorDot( player_right, tag_forward ) < 0;
		global.player_up_dot = VectorDot( player_up, tag_forward );
		global.player_up = global.player_up_dot < 0.2;


		/*
		angles = VectorToAngles( second_point - first_point );
		forward = AnglesToForward( angles );
	
		end = first_point;
		difference = VectorNormalize( end - start );
		dot = VectorDot( forward, difference );
		*/
		wait( 0.05 );
	}
}

penetrable_surface( ent, override_surface )
{
	surface = ent.surface_type;
	if ( IsDefined( override_surface ) )
		surface = override_surface;

	if ( ( ent.climb_dir == "right" || ent.climb_dir == "left" ) && ent.climb_dir != ent.arm )
	{
		// can always penetrate these odd arm catchups
		//if ( surface != "none" )
			return true;
	}

	penetrable_surfaces = [];
	penetrable_surfaces[ "ice" ] = true;
	penetrable_surfaces[ "plaster" ] = true;
	penetrable_surfaces[ "rock" ] = true;
	penetrable_surfaces[ "snow" ] = true;

	return IsDefined( penetrable_surfaces[ surface ] );
}

test_line()
{
	for ( ;; )
	{
		forward = AnglesToForward( self.angles );
		trace = BulletTrace( self.origin, self.origin + forward * 6.25, false, undefined );
		Line( self.origin, trace[ "position" ] );
		wait( 0.05 );
	}
}

spawn_icepick_fx_tag( model, fx_tag_name )
{
	fx_tag = Spawn( "script_model", ( 0, 0, 0 ) );
	fx_tag SetModel( "tag_origin" );
	fx_tag Hide();

	fx_tag.origin = model GetTagOrigin( fx_tag_name );
	fx_tag.angles = model GetTagAngles( fx_tag_name );

	// translate the posts into the proper positions for the animations
	ent = SpawnStruct();
	ent.entity = fx_tag;
	ent.forward = 2;
	ent.up = 15.35;
	ent.right = 0;
	ent.yaw = 0;
	ent.pitch = 41;
	ent translate_local();
	fx_tag LinkTo( model, fx_tag_name );

	return fx_tag;
}

spawn_player_icepick_fx_tag( model, fx_tag_name )
{
	fx_tag = Spawn( "script_model", ( 25, 25, -25 ) );
	fx_tag SetModel( "tag_origin" );
	fx_tag Hide();

	fx_tag.origin = model GetTagOrigin( fx_tag_name );
	fx_tag.angles = model GetTagAngles( fx_tag_name );

	// translate the posts into the proper positions for the animations
	ent = SpawnStruct();
	ent.entity = fx_tag;
	ent.forward = 2;
	ent.up = 8.35;
	ent.right = -1;
	ent.yaw = 0;
	ent.pitch = 41;
	ent translate_local();
	fx_tag LinkTo( model, fx_tag_name );

	return fx_tag;
}

icepick_impact_fx( fx_tag, model )
{
	model endon( "death" );
	impacted = false;
	trace_depth = level.trace_depth;

	for ( ;; )
	{
		wait( 0.05 );

		forward = AnglesToForward( fx_tag.angles );
		trace = BulletTrace( fx_tag.origin, fx_tag.origin + forward * trace_depth, false, undefined );
		//Line( fx_tag.origin, fx_tag.origin + forward * trace_depth, ( 0, 1, 0 ), 1, 0 );

		if ( self.stabbed )
			continue;

		if ( impacted )
		{
			// check to see if we're still impacted
			if ( trace[ "fraction" ] < 1 )
				continue;

			// we're free!
			impacted = false;
			wait( 0.8 );// debounce off a pull out
		}

		// didn't hit anything
		if ( trace[ "fraction" ] >= 1 )
			continue;

		impacted = true;
		surface = trace[ "surfacetype" ];
		fx = "icepick_impact_" + surface;
		if ( fxExists( fx ) )
		{
			PlayFX( getfx( fx ), trace[ "position" ], trace[ "normal" ] );
			fx_tag PlaySound( "icepick_impact_ice" );
			level.player PlayRumbleOnEntity( "icepick_climb" );
		}
	}
}

get_icepick_tag_name( arm )
{
	return level.ice_pick_tags[ arm ];
}

spawn_additive_models( ent )
{
	ent.additive_models = [];
	spawn_additive_models_of_type( ent, "additive_in" );
	spawn_additive_models_of_type( ent, "additive_out" );
}

spawn_additive_models_of_type( ent, additive_type )
{
	ent.additive_models[ additive_type ] = [];
	steps = 20;
	for ( i = 0; i < steps; i++ )
	{
		level.additive_count++;
		thread spawn_additive_models_of_type_and_depth( ent, additive_type );
	}
}

spawn_additive_models_of_type_and_depth( ent, additive_type )
{
	model = spawn_anim_model( "player_rig" );
	AssertEx( model.origin == ( 0, 0, 0 ), "model wrong origin" );
	//model Hide();

	additive_weight = 2;
	model SetAnimLimited( ent.anims[ "additive" ], additive_weight, 0, 1 );
	model SetAnimLimited( ent.anims[ additive_type ], additive_weight, 0, 1 );

	// let the anim play until the notetrack, then pause it there
	animation = ent.anims[ "stab" ];
	model SetFlaggedAnimKnobRestart( "anim", animation, 1, 0, 1 );
	model waittillmatch( "anim", "stab" );
	model SetAnim( animation, 1.0, 0, 0 );

	// need an anchor so we get the right delta offset for the model's origin
	org = Spawn( "script_origin", ( 0, 0, 0 ) );
	model LinkTo( org );
	model.org = org;

	//model thread maps\_debug::dragTagUntilDeath( "tag_origin", (0.3, 0.3, 0.3 ) );
	//org thread maps\_debug::drawOrgForever( ( 0.5, 0.2, 0.2 ) );

	ent.additive_models[ additive_type ][ ent.additive_models[ additive_type ].size ] = model;
	level.additive_count--;
	if ( level.additive_count == 0 )
	{
		level notify( "additives_created" );
	}
}

generate_notetrack_times( ent )
{
	ent.notetrack_times = [];

	generate_notetrack_times_for_anim( ent, "stab" );
}

generate_notetrack_times_for_anim( ent, anim_type )
{
	anims = ent.anims;
	model = spawn_anim_model( "player_rig" );
	model Hide();
	model SetFlaggedAnimKnobRestart( "anim", anims[ anim_type ], 1, 0, 1 );
	ent.notetrack_times[ anim_type ] = [];

	start_time = GetTime();
	total_time = GetAnimLength( anims[ anim_type ] );

	for ( ;; )
	{
		model waittill( "anim", notetrack );
		current_time = GetTime() - start_time;
		ent.notetrack_times[ anim_type ][ notetrack ] = current_time / total_time * 0.001;
		if ( notetrack == "end" )
			break;
		AssertEx( ent.notetrack_times[ anim_type ][ notetrack ] <= 1.0, "Notetrack time exceeded 1" );
	}
}


draw_ent_num( offset )
{
	/#
	if ( !isdefined( offset ) )
		offset = -30;
	self endon( "death" );
	self notify( "draw_ent_num" );
	self endon( "draw_ent_num" );
	for ( ;; )
	{
		Print3d( self.origin + ( 0, 0, offset ), self GetEntNum(), ( 0.3, 0.9, 0.5 ), 1, 0.25 );
		wait( 0.05 );
	}
	#/
}

play_crack_fx_on_arm( arm )
{
	fx_tag_name = get_icepick_tag_name( arm );
	fx_tag = spawn_icepick_fx_tag( self, fx_tag_name );

	wait( 0.05 );
	sound = false;
	org = Spawn( "script_origin", ( self.origin ) );
	fx = [];
	fx[ 0 ] = 1;
	fx[ 1 ] = 2;
	fx[ 2 ] = 3;
	fx[ 3 ] = 1;
	fx[ 4 ] = 4;
	fx[ 5 ] = 5;
	fx[ 6 ] = 1;
	fx[ 7 ] = 2;
	fx[ 8 ] = 4;
	fx[ 9 ] = 3;
	fx[ 10 ] = 1;
	fx[ 11 ] = 5;
	fx[ 12 ] = 2;
	fx[ 13 ] = 1;
	fx[ 14 ] = 3;


	for ( count = 1; count < fx.size; count++ )
	{
		forward = AnglesToForward( fx_tag.angles );
		trace_depth = level.trace_depth;
		start = fx_tag.origin + forward * ( trace_depth * -2 );
		end = fx_tag.origin + forward * trace_depth * 2;
		trace = BulletTrace( start, end, false, undefined );

		hit_pos = trace[ "position" ];
		normal = trace[ "normal" ];
		PlayFX( getfx( "climbing_cracks_" + fx[ count ] ), hit_pos, normal );

		if ( !sound )
		{
			org.origin = hit_pos;
			org thread play_sound_on_entity( "icepick_inactive_cracking" );
		}
		sound = true;
		wait( 0.1 );
	}
	fx_tag Delete();
	org Delete();
}

climbing_cracks_think( ent, hit_pos, normal )
{
	org = Spawn( "script_origin", hit_pos );
	org thread climbing_cracks_fx( ent, hit_pos, normal );
	rumble = get_rumble_ent( "icepick_hang" );
	rumble.intensity = 0;
	rumble delayThread( 2, ::rumble_ramp_on, 4.5 );

	ent.viewModel waittill( "stop_crack" );
	rumble Delete();
	org PlaySound( "icepick_inactive_cracking_stop" );
	wait( 0.05 );
	org Delete();
}

climbing_cracks_fx( ent, hit_pos, normal )
{
	self endon( "death" );
	ent.viewModel endon( "stop_crack" );

	for ( count = 1; count <= 3; count++ )
	{
		PlayFX( getfx( "climbing_cracks_" + count ), hit_pos, normal );
		self PlaySound( "icepick_inactive_cracking" );
		wait( RandomFloatRange( 1, 2 ) );

		// more cracks come later
		if ( !flag( "player_climbs_past_safe_point" ) )
			return;

	}
}

safe_price_delete( price )
{
	if ( !isalive( price ) )
		return;
	if ( IsDefined( price.magic_bullet_shield ) )
		price stop_magic_bullet_shield();
	if ( IsDefined( price.fakegun ) )
		price.fakegun Delete();
	price Delete();
}

get_me_captain_price()
{
	safe_price_delete( level.price );

	spawner = level.price_spawner;
	spawner.count = 1;
	price = spawner StalingradSpawn();
	spawn_failed( price );
	price.animname = "price";
	level.price = price;
	level.friendlyFireDisabled = true;
	price disable_pain();
	price thread magic_bullet_shield();
	SetSavedDvar( "g_friendlyfiredist", 0 );

	price gun_remove();
	//price anim_spawn_tag_model( "weapon_m14_cloth_wrap_silencer", "TAG_WEAPON_CHEST" );
	//price anim_spawn_tag_model( "weapon_m21SD_wht", "TAG_WEAPON_CHEST" );

	fakegun = Spawn( "script_model", price.origin );
	fakegun SetModel( "weapon_m14ebr_arctic" );
	fakegun HidePart( "TAG_THERMAL_SCOPE" );
	fakegun HidePart( "TAG_FOREGRIP" );
	fakegun HidePart( "TAG_ACOG_2" );
	fakegun HidePart( "TAG_HEARTBEAT" );
	
	fakegun LinkTo( price, "TAG_WEAPON_CHEST", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	price.fakegun = fakegun;
	//price anim_spawn_tag_model( "weapon_m14ebr_arctic", "TAG_WEAPON_CHEST" );

	return price;
	/*
	
	if ( !isalive( level.price ) )
	{
		price_spawner = GetEnt( "climbing_price", "targetname" );
		price_spawner.count = 1;
		price = price_spawner spawn_ai();
		price.animname = "price";
		level.price = price;
	}
	return level.price;
	*/
}

cliff_scene_with_price()
{
	do_flyin = false;
	/#
	if ( level.start_point == "cave" )
		do_flyin = false;
	if ( level.start_point == "climb" )
	{
		do_flyin = false;
		player_recover = GetEnt( "player_recover", "targetname" );
		level.player SetOrigin( player_recover.origin + ( 10, 0, -30 ) );
		level.player TakeAllWeapons();
		level.player GiveWeapon( level.ice_pick_viewweapon, 0, 1 );
		level.player SwitchToWeapon( level.ice_pick_viewweapon );
		flag_set( "player_gets_on_wall" );
		flag_set( "player_in_position_to_climb" );
	}
	#/

	thread maps\_blizzard::blizzard_level_transition_climbing( .05 );

	if ( do_flyin )
	{
		thread fly_up_the_mountain();
	}
	else
	{
		thread teleport_to_cave();
		thread death_trigger();

	}

	SetSavedDvar( "sm_sunsamplesizenear", 0.0625 );

//		thread old_crazy_fly_in();


	flag_set( "can_save" );

	/*
	if ( level.start_point == "cave" || do_flyin )
		teleport_to_cave();
	*/



	//maps\_blizzard::blizzard_overlay_full( 1 );
	/#
		if ( level.start_point == "climb" )
		{
			flag_wait( "reached_top" );

			level.player AllowProne( true );
			level.player AllowSprint( true );
			battlechatter_off( "allies" );
			battlechatter_on( "axis" );
			return;
		}
	#/


//	wait( 0.05 );
	price = get_me_captain_price();
	price PlayLoopSound( "gear_jacket_flapping_loop" );

	animation = price getanim( "price_climb_intro" );
	animLength = GetAnimLength( animation );
	//price delayThread( animLength * 0.42, ::dialogue_queue, "breaksover" );

	price anim_spawn_tag_model( "prop_price_cigar", "tag_inhand" );
	PlayFXOnTag( level._effect[ "cigar_glow" ], price, "tag_cigarglow" );

	node = GetEnt( "cliffhanger_cliff", "targetname" );
	/*
	if ( do_flyin )
		flag_wait( "flyin_complete" );
	*/

	thread autosave_now_silent();
	if ( do_flyin )
		flag_wait( "slam_zoom_started" );

	//wait( 1.0 ); // 2.0
	delayThread( 6, ::spawn_vehicles_from_targetname_and_drive, "climb_mig_distant_spawner" );

	//node anim_first_frame_solo( price, "price_climb_intro" );
	//wait( 2.5 ); // 2.5

	level delayThread( 10, ::send_notify, "follow_price_obj" );
	level delayThread( 10, ::_setsaveddvar, "g_friendlyNameDist", 0 );

	// break's over soap, let's go
	level.player thread play_loop_sound_on_entity( "gear_jacket_flapping_plr_loop" );
	delayThread( 0.1, ::autosave_now );

	node anim_single_solo( price, "price_climb_intro" );
	/*
	wait( 0.05 );
	price SetAnimTime( price getanim( "price_climb_intro" ), 0.08 );
	for ( ;; )
	{
		if ( price GetAnimTime( price getanim( "price_climb_intro" ) ) > 0.98 )
			break;
		wait( 0.05 );
	}
	*/

	node thread anim_loop_solo( price, "price_climb_intro_idle", "stop_idle" );
	flag_wait( "price_begins_climbing" );
	flag_clear( "price_climb_continues" );

	node notify( "stop_idle" );
//	level.player delayCall( 7.2, ::switchtoweapon, level.ice_pick_viewweapon );
	delay_time = 7.2;
	level.player delayCall( delay_time, ::SetStance, "stand" );
	level.player delayCall( delay_time, ::allowcrouch, false );
	level.player delayCall( delay_time, ::allowprone, false );


	// pop Price up the cliff cause he's so slow
	price thread delete_player_climb_blocker_and_set_time();

	level.price_climb_time = GetTime();
	node thread anim_single_solo( price, "price_climb_start" );
	node add_wait( ::waittill_msg, "price_climb_start" );
	level add_wait( ::waittill_msg, "fourth_swing" );
	do_wait_any();
	flag_set( "price_climbs_past_start" );

	node anim_first_frame_solo( price, "price_climb_mid" );
	flag_wait( "price_climb_continues" );

	SetSavedDvar( "g_friendlyNameDist", 0 );

	// whoosh
	delayThread( 6.8, ::activate_trigger_with_targetname, "mig_flyover_trigger" );
	delayThread( 4, ::exploder, 3 );// mig29 flys overhead and fires a snow blowing effect using exploder #3


	anim_length = GetAnimLength( level.scr_anim[ price.animname ][ "price_climb_mid" ] );
	seconds_in = 5.5;
	anim_progress_percent = seconds_in / anim_length;
	delayThread( 0.05, ::set_anim_time, price, "price_climb_mid", anim_progress_percent );

	thread maps\_blizzard::blizzard_level_transition_climbing_up( 2 );

	node anim_single_solo( price, "price_climb_mid" );

	safe_price_delete( price );

	flag_wait( "reached_top" );
}

delete_player_climb_blocker_and_set_time()
{
	animation = self getanim( "price_climb_start" );
	for ( ;; )
	{
		if ( self GetAnimTime( animation ) > 0.5 )
			break;
		wait( 0.05 );
	}
	flag_set( "player_gets_on_wall" );
	flag_wait( "player_begins_to_climb" );
	if ( flag( "price_climbs_past_start" ) )
		return;
	if ( self GetAnimTime( animation ) < 0.75 )
	{
		self SetAnimTime( animation, 0.75 );
		//println( "POP" );
	}
	flag_wait( "player_climbed_3_steps" );
	if ( flag( "price_climbs_past_start" ) )
		return;
	if ( self GetAnimTime( animation ) < 0.99 )
	{
		self SetAnimTime( animation, 0.99 );
		//println( "POP" );
	}

}

gaz_catches_player( player )
{

	//gaz_spawner = GetEnt( "climbing_gaz", "targetname" );
	[[ level.friendly_init_cliffhanger ]]();
	gaz = level.price;
	gaz.dontavoidplayer = true;
	gaz PushPlayer( true );

	//get_me_captain_price(); // gaz_spawner spawn_ai();
	spawn_failed( gaz );
	if ( IsAlive( level.jumping_price ) && gaz != level.jumping_price )
	{
		safe_price_delete( level.jumping_price );
		gaz gun_remove();

		fakegun = Spawn( "script_model", gaz.origin );
		fakegun SetModel( "weapon_m14ebr_arctic" );
		fakegun HidePart( "TAG_THERMAL_SCOPE" );
		fakegun HidePart( "TAG_FOREGRIP" );
		fakegun HidePart( "TAG_ACOG_2" );
		fakegun HidePart( "TAG_HEARTBEAT" );
		
		fakegun LinkTo( gaz, "TAG_WEAPON_CHEST", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		gaz.fakegun = fakegun;

		//gaz anim_spawn_tag_model( "weapon_m21SD_wht", "TAG_WEAPON_CHEST" );
	}
	else
	{
		self notify( "stop_idle" );
	}
	level.climbing_gaz = gaz;

	//climbing_gaz.team = "allies";
	//climbing_gaz.animname = "gaz";

	gaz endon( "death" );
	thread slowmo_gaz();

	self anim_single_solo( level.climbing_gaz, "climb_catch" );

	if ( !isalive( gaz ) )
		return;

	//gaz Detach( "weapon_m21SD_wht", "TAG_WEAPON_CHEST" );
	gaz.fakegun Delete();
	gaz detach_picks();
	gaz gun_recall();
	//level.player Unlink();

	gaz disable_ai_color();
	gaz enable_ai_color();

	flag_wait( "reached_top" );
	wait( 8 );
	gaz.dontavoidplayer = false;
	gaz PushPlayer( false );
}

slowmo_gaz()
{

	//exploder( 4 ); // price slomo dives to catch you, effects fall off him as he skids on the ice

	wait( 0.5 );
	if ( !flag( "player_hangs_on" ) )
		return;

	level.player PlaySound( "scn_cliffhanger_bigjump_slowdown" );
	slowmo_start();
	slowmo_setspeed_slow( 0.25 );
	slowmo_setlerptime_in( 0.05 );
	slowmo_lerp_in();
//	level.player delayThread( 2.5, ::play_sound_on_entity, "slomo_whoosh" );
	//wait( animation_length * 0.005 );
	wait( 0.2 );
	slowmo_setlerptime_out( 0.01 );
	level.player PlaySound( "scn_cliffhanger_bigjump_speedup" );
	slowmo_lerp_out();
	slowmo_end();
	flag_set( "price_caught_player" );
}

price_tells_you_to_jump()
{
	lines = [];
//	lines[ lines.size ] = "letsgo";
//	lines[ lines.size ] = "12metergap";
//	lines[ lines.size ] = "dicey";
	lines[ lines.size ] = "thefarside";

	// Let’s go.	
	// Hmph. Twelve meter gap. Piece o’ piss.	
	// This could get dicey Soap. Mind the gap.	
	// Good luck mate - see you on the far side.	

	jump_line = random( lines );
	wait( 1.5 );
	level.price dialogue_queue( jump_line );
}

price_makes_the_jump( climb_jump_org )
{
	price = get_me_captain_price();
	level.jumping_price = price;
	price endon( "death" );
	climb_jump_org endon( "stop_idle" );
	maps\_climb_anim::attach_pick( price );
	//thread maps\_blizzard::blizzard_level_transition_climbing( .01 );	

	// price will sit at this time until the player looks at him
	climb_jump_org anim_first_frame_solo( price, "price_jump" );

	climb_jump_org = GetEnt( "climb_jump_org", "targetname" );
	climb_jump_org waittill_player_lookat( 0.4, 0, true );
	delayThread( 1, ::autosave_by_name, "price_jump" );

	//thread price_tells_you_to_jump();
	climb_jump_org anim_single_solo( price, "price_jump" );
	climb_jump_org thread anim_loop_solo( price, "price_idle", "stop_idle" );
	flag_wait( "player_makes_the_jump" );
	climb_jump_org notify( "stop_idle" );
	climb_jump_org anim_single_solo( price, "price_reach" );

	safe_price_delete( price );
	wait( 1.0 );
	flag_set( "price_jumped" );
}

set_anim_time( character, anime, time_percent )
{
	animation = character getanim( anime );
	character SetAnimTime( animation, time_percent );
}

set_anim_rate( character, anime, rate )
{
	animation = character getanim( anime );
	character SetFlaggedAnim( "single anim", animation, 1, 0, rate );

}

player_leaps( jump_forward )
{
	if ( flag( "climb_icepick_slide" ) )
	{
		// player managed to hit the slide trigger without "leaping" properly
		// so he falls to his death
		level.player BeginSliding();

		level waittill( "foreverever" );
	}
	if ( !flag( "climb_big_jump" ) )
		return false;
	if ( level.player GetStance() != "stand" )
		return false;

	// gotta jump straight
	player_angles = level.player GetPlayerAngles();
	player_angles = ( 0, player_angles[ 1 ], 0 );
	player_forward = AnglesToForward( player_angles );
	dot = VectorDot( player_forward, jump_forward );
	if ( dot < 0.94 )
	{
		flag_clear( "climb_big_jump" );
		return false;
	}

	vel = level.player GetVelocity();
	velocity = Distance( ( vel[ 0 ], vel[ 1 ], 0 ), ( 0, 0, 0 ) );
	if ( velocity < 162 )
	{
		flag_clear( "climb_big_jump" );
		return false;
	}
	/*
		
	vel = level.player GetVelocity();
	if ( vel[ 0 ] > -167 )
		return false;

	if ( vel[ 2 ] < 20 )
		return false;
	*/


	level.player SetVelocity( ( vel[ 0 ] * 1.5, vel[ 1 ] * 1.5, vel[ 2 ] ) );
	return true;
}


player_slides_off_cliff()
{
	level endon( "stop_force_sliding_the_player" );
	flag_wait( "climb_icepick_slide" );
	// player managed to hit the slide trigger without "leaping" properly
	// so he falls to his death
	level.player BeginSliding();
}

player_big_jump()
{
	if ( flag( "player_preps_for_jump" ) )
		return;

	player_jumpdown_block = GetEnt( "player_jumpdown_block", "targetname" );
	player_jumpdown_block Solid();

	flag_set( "player_preps_for_jump" );
	level.player TakeAllWeapons();

//	delayThread( 0.1, ::autosave_now );

	level.player GiveWeapon( level.ice_pick_viewweapon, 0, 1 );
	level.player SwitchToWeapon( level.ice_pick_viewweapon );

	level.player notify( "stop_climbing" );
	level.player PlayerSetGroundReferenceEnt( undefined );
	level.player SetMoveSpeedScale( 1 );

	climb_jump_org = GetEnt( "climb_jump_org", "targetname" );

	flag_init( "price_jumped" );
	thread price_makes_the_jump( climb_jump_org );
	thread track_player_button_presses_for_holding_on();

	level.price = getaiarray( "allies" )[0];
	Objective_OnEntity( obj( "obj_follow_price" ), level.price );
	
	setsaveddvar( "compass", 1 ); // see where Soap is

	flag_wait( "climb_jump_prep" );

	if ( level.gameskill <= 1 )
	{
		// on easy and normal you don't have to jump
		trigger = getEntWithFlag( "climb_big_jump" );
		trigger.origin += ( 0, 0, -40 );
	}

	flag_clear( "climb_big_jump" );
	flag_wait( "climb_big_jump" );

	big_jump_yaw = GetEnt( "big_jump_yaw", "targetname" );
	big_jump_yaw_targ = GetEnt( big_jump_yaw.target, "targetname" );
	jump_angles = VectorToAngles( big_jump_yaw_targ.origin - big_jump_yaw.origin );
	jump_angles = ( 0, jump_angles[ 1 ], 0 );
	jump_forward = AnglesToForward( jump_angles );

	level notify( "stop_force_sliding_the_player" );

	for ( ;; )
	{
		if ( player_leaps( jump_forward ) )
			break;
		wait( 0.05 );
	}
	
	// player grunts as he jumps
	level.player PlaySound( "scn_cliffhanger_player_make_bigjump" );

	SetDvar( "hold_on_tight", 1 );
	// if the player is going too fast, he may clip through the slope, so slow him down
	vel = level.player GetVelocity();
	speed = Distance( vel, ( 0, 0, 0 ) );
	max_speed = 300;
	if ( speed > max_speed )
	{
		ratio = max_speed / speed;
		new_vel = ( vel[ 0 ] * ratio, vel[ 1 ] * ratio, vel[ 2 ] * ratio );
		level.player SetVelocity( new_vel );
	}

	level.player SetStance( "stand" );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player AllowSprint( false );
	//level.player TakeWeapon( level.ice_pick_viewweapon );
	//level.player GiveWeapon( "ice_picker_bigjump" );
	//level.player SwitchToWeapon( "ice_picker_bigjump" );

	flag_set( "player_makes_the_jump" );

	/*
	flag_wait( "climb_icepick_slide" );
	
	level.arm_ent_globals
	
	//if ( !flag( "price_jumped" ) )


	*/
	/*
	if ( 1 )
	{
		return;
	}
	*/



	wait( 0.4 );
//	level.player TakeAllWeapons();

	player_arms = spawn_anim_model( "player_rig" );
	player_arms add_icepicks();
	player_arms Hide();
	//player_arms	thread maps\_debug::dragTagUntilDeath( "tag_player", (0,1,0) );

	level.playeR_arms = player_arms;


	anim_both_in = player_arms getanim( "big_jump_both_in" );
	anim_left = player_arms getanim( "big_jump_left" );
	anim_right = player_arms getanim( "big_jump_right" );
	anim_both_out = player_arms getanim( "big_jump_both_out" );

	start_org = GetStartOrigin( climb_jump_org.origin, climb_jump_org.angles, anim_both_in );
	start_ang = GetStartAngles( climb_jump_org.origin, climb_jump_org.angles, anim_both_in );

	player_arms.origin = start_org;
	player_arms.angles = start_ang;

	anim_both_in_controller = player_arms getanim( "controller_both_in" );
	anim_both_out_controller = player_arms getanim( "controller_both_out" );
	anim_right_controller = player_arms getanim( "controller_right" );
	anim_left_controller = player_arms getanim( "controller_left" );
	anim_slide_controller = player_arms getanim( "controller_slide" );
	anim_climb_controller = player_arms getanim( "controller_climb" );

	player_arms SetAnimLimited( anim_slide_controller, 0.999, 0, 1 );
	player_arms SetAnimLimited( anim_both_in_controller, 0.999, 0, 1 );
	player_arms SetAnimLimited( anim_both_out_controller, 0.001, 0, 1 );
	player_arms SetAnimLimited( anim_left_controller, 0.001, 0, 1 );
	player_arms SetAnimLimited( anim_right_controller, 0.001, 0, 1 );

	level.slip_rate = 1.6;
	rate = level.slip_rate;
	player_arms SetFlaggedAnimLimited( "slide", anim_both_in, 1, 0, rate );
	player_arms SetAnimLimited( anim_both_out, 1, 0, rate );
	player_arms SetAnimLimited( anim_left, 1, 0, rate );
	player_arms SetAnimLimited( anim_right, 1, 0, rate );

	//player_arms SetAnimLimited( big_jump_anim, 0.001, 0, 0 );
	//player_arms SetAnimLimited( anim_climb_controller, 0.001, 0, 1 );

	SetSavedDvar( "sm_sunsamplesizenear", 0.0625 );
	player_arms thread arms_animated_relative_to_input();
	
	timer = 0.7;
	//thread ice_cracks( player_arms ); // soon!
	level.player PlayerLinkToBlend( player_arms, "tag_player", timer, timer * 0.7, 0 );
	wait( timer - 0.05 );
	player_arms Show();
	thread sleeve_flap( player_arms );
	thread play_sound_in_space( "scn_cliffhanger_player_bigjump_bodyfall", level.player.origin );
	level.player.impacted = true;

	wait( 0.05 );
	level.player TakeAllWeapons();
	thread price_shouts();
	//level.player PlayerLinkToDelta( player_arms, "tag_player", 1, 90, 90, 40, 40, false );

	//player_arms SetAnim( big_jump_anim, 0.001, 0, 0 );
	//player_arms SetAnimTime( big_jump_anim, 0.15 );

	wait( 0.05 );


	//player_arms waittillmatch( "slide", "end" );
	for ( ;; )
	{
		if ( player_arms GetAnimTime( anim_both_in ) >= 0.99 )
			break;
		wait( 0.05 );
	}

	// player hangs sound
	level.player PlaySound( "scn_cliffhanger_snow_breakaway" );

	setsaveddvar( "compass", 0 ); 
	flag_set( "player_hangs_on" );

	exploder( 5 );

	if ( player_arms.left_looping )
		player_arms StopLoopSound( "scn_cliffhanger_icepick_scrape_left" );
	if ( player_arms.right_looping )
		player_arms StopLoopSound( "scn_cliffhanger_icepick_scrape_right" );
	level.player.impacted = false;

	player_arms notify( "stop_weights" );
	player_arms notify( "stop_fx" );

	climb_jump_org thread anim_single_solo( player_arms, "big_jump" );

	level.rumble_ent = get_rumble_ent( "icepick_hang" );
	level.rumble_ent.intensity = 0;
	level.rumble_ent delayThread( 2, ::rumble_ramp_on, 4.5 );

	animation = player_arms getanim( "big_jump" );

	e3_start = is_e3_start();

	anim_end_time = 0.95;
//	if ( e3_start )
//		anim_end_time = 0.62;

	for ( ;; )
	{
		if ( player_arms GetAnimTime( animation ) > anim_end_time )
			break;
//		if ( flag( "price_caught_player" ) )
//			break;
		if ( level.gameSkill > 1 )
		{
			// don't fall on easy/normal
			if ( !flag( "player_was_caught" ) && GetTime() > level.player.last_button_pressed_time + 1000 )
			{
				flag_clear( "player_hangs_on" );
				level.player Unlink();
				//level.player GiveWeapon( level.ice_pick_viewweapon, 0, 1 );
				//level.player SwitchToWeapon( level.ice_pick_viewweapon );
				playeR_arms Hide();
				return;
			}
		}
		wait( 0.05 );
	}

	if ( IsDefined( level.rumble_ent ) )
		level.rumble_ent Delete();


//	thread play_sound_in_space( "scn_cliffhanger_player_bigjump", player_arms.origin );


	player_arms notify( "stop_weights" );

	climb_catch = GetEnt( "climb_catch", "targetname" );

	start_org = climb_catch.origin;
	start_ang = climb_catch.angles;
	climb_catch Delete();
	flag_clear( "climb_pullup" );
	flag_clear( "finished_climbing" );
	flag_set( "final_climb" );

	player_arms	Hide();
	player_arms delayThread( 0.5, ::self_delete );
	PrintLn( "Origin " + level.player.origin );

	for ( ;; )
	{
		if ( level.player player_finishes_climbing( start_org, start_ang, true, true ) )
		{
			break;
		}

		if ( flag( "finished_climbing" ) )
			break;
	}

	if ( !flag( "can_save" ) )
		return;

	if ( e3_start )
	{
		fade_time = 1.5;

		wait( fade_time );
		thread set_normal_fov();

		level.player PlayerSetGroundReferenceEnt( undefined );

		//flag_clear( "climb_pullup" );
		//flag_clear( "finished_climbing" );
		//flag_set( "final_climb" );
		//player_arms	Hide();
		//player_arms delayThread( 0.5, ::self_delete );
		//player_arms notify( "stop_weights" );

	}

	flag_set( "reached_top" );
	Objective_OnEntity( obj( "obj_follow_price" ), level.price );
	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", 0 );
	SetSavedDvar( "actionSlotsHide", 0 );
	SetSavedDvar( "hud_showStance", 1 );
	SetSavedDvar( "hud_drawhud", 1 );

	SetSavedDvar( "sm_sunsamplesizenear", 0.25 );
	SetSavedDvar( "g_friendlyNameDist", 15000 );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player AllowSprint( true );

	battlechatter_off( "allies" );
	battlechatter_on( "axis" );

	level.player notify( "stop sound" + "gear_jacket_flapping_plr_loop" );
	level.price StopLoopSound( "gear_jacket_flapping_loop" );

	// You look like you’ve seen a ghost, Soap.	
	//level.price dialogue_queue( "seenaghost" );
	thread set_normal_fov();
	level.player AllowFire( true );
	player_jumpdown_block Delete();
}

stop_complaining_about_goal()
{
	self endon( "death" );
	for ( ;; )
	{
		self SetGoalPos( self.origin );
		wait( 0.05 );
	}
}

wait_and_then_transition_to_next_part()
{
	level notify( "player_in_base" );
	for ( ;; )
	{
		if ( flag( "one_c4_planted" ) )
			break;

		if ( level.player.health < 50 )
			break;
		wait( 0.05 );
	}

	flag_set( "mig_c4_planted" );
	flag_set( "one_c4_planted" );

	thread spam_max_health();

	flag_set( "tarmac_escape" );// kill price dialogue
	fade_time = 1.5;
	level.black_overlay = create_client_overlay( "black", 0, level.player );
	level.black_overlay.alpha = 0;

	// Things do not always go as planned..
	level.e3_text_overlay = maps\cliffhanger_code::e3_text_hud( &"CLIFFHANGER_E3_NOT_AS_PLANNED" );
	level.e3_text_overlay.alpha = 0;

	level.black_overlay FadeOverTime( fade_time );
	level.black_overlay.alpha = 1;


	wait( fade_time );
	level.e3_text_overlay FadeOverTime( fade_time );
	level.e3_text_overlay.alpha = 1;

	level.black_overlay delayCall( 0.1, ::Destroy );// a new one is created in the other start

	level.price thread stop_complaining_about_goal();

	if ( IsAlive( level.price ) )
	{
		if ( IsDefined( level.price.magic_bullet_shield ) )
			level.price stop_magic_bullet_shield();
		level.price Delete();
	}

	ai = GetAIArray( "axis" );
	foreach ( guy in ai )
	{
		guy Delete();
	}

	thread maps\cliffhanger::start_ch_tarmac( true );
	wait( 3 );
	level notify( "stop_spamming_max_health" );
	maps\cliffhanger::cliffhanger_tarmac_main();
	maps\cliffhanger_snowmobile::snowmobile_main();


	//level.player EnableDeathShield( false );

	//maps\cliffhanger_snowmobile::start_snowmobile( true );
	//maps\cliffhanger_snowmobile::snowmobile_main();
}

spam_max_health()
{
	level endon( "stop_spamming_max_health" );
	for ( ;; )
	{
		level.player SetNormalHealth( 100 );
		wait( 0.05 );
	}
}


player_gets_back_into_climbing( ent )
{
	thread climbing_cracks_think( ent, ( 0, 0, 0 ), ( 1, 0, 0 ) );

	wait( 0.1 );
	ent.player PlayerLinkToBlend( ent.viewModel, "tag_player", 0.2 );
	wait( 0.2 );
	//ent.player PlayerLinkToDelta( ent.viewModel, "tag_player", 1, 0,0,0,0 );
	ent.player PlayerSetGroundReferenceEnt( ent.globals.ground_ref_ent );
	SetSavedDvar( "sm_sunsamplesizenear", 0.0625 );
	ent.globals.ground_ref_ent_set = true;
//	ent.viewModel Show();

}

price_shouts()
{
	wait( 0.5 );
	// Hold on! Don't let go!

	level.price play_sound_on_entity( "cliff_pri_holdon" );
}

track_player_button_presses_for_holding_on()
{
	level endon( "reached_top" );
	level.player.last_button_pressed_time = 0;
	for ( ;; )
	{
		left_pressed = level.player leftSwingPressed();
		right_pressed = level.player rightSwingPressed();

		if ( left_pressed || right_pressed )
			level.player.last_button_pressed_time = GetTime();
		wait( 0.05 );
	}
}

sleeve_flap( model )
{
	model endon( "death" );
	anims = get_anims_for_climbing_direction( [], "up", "right" );

	for ( ;; )
	{
		rate = RandomFloatRange( 1.0, 1.8 );
		model SetAnim( anims[ "sleeve_flap" ], 1, 0, rate );
		wait( RandomFloatRange( 0.2, 5 ) );
	}
}

ice_cracks( player_arms )
{
	wait( 0.2 );
	player_arms thread play_crack_fx_on_arm( "left" );
	player_arms thread play_crack_fx_on_arm( "right" );
}

arms_animated_relative_to_input()
{
	self endon( "stop_weights" );
	level.player.impacted = false;

	controller_both_in = self getanim( "controller_both_in" );
	controller_left = self getanim( "controller_left" );
	controller_right = self getanim( "controller_right" );
	controller_both_out = self getanim( "controller_both_out" );

	anim_both_in = self getanim( "big_jump_both_in" );
	anim_left = self getanim( "big_jump_left" );
	anim_right = self getanim( "big_jump_right" );
	anim_both_out = self getanim( "big_jump_both_out" );


	all_anims = [];
	all_anims[ all_anims.size ] = controller_both_in;
	all_anims[ all_anims.size ] = controller_left;
	all_anims[ all_anims.size ] = controller_right;
	all_anims[ all_anims.size ] = controller_both_out;

	anims = [];
	anims[ 1 ][ 1 ] = controller_both_in;
	anims[ 1 ][ 0 ] = controller_left;
	anims[ 0 ][ 1 ] = controller_right;
	anims[ 0 ][ 0 ] = controller_both_out;

	pressed_rates = [];
	pressed_rates[ 0 ] = 4;
	pressed_rates[ 1 ] = 2;
	pressed_rates[ 2 ] = level.slip_rate;

	current_rate = 1;
	ent = SpawnStruct();
	ent.pressed[ "left" ] = false;
	ent.pressed[ "right" ] = false;
	thread sliding_fx( ent );

	self.left_looping = false;
	self.right_looping = false;

	for ( ;; )
	{
		pressed = 0;
		right_pressed = level.player rightSwingPressed();
		left_pressed = level.player leftSwingPressed();
	
		
		ent.pressed[ "left" ] = left_pressed;
		ent.pressed[ "right" ] = right_pressed;

		if ( level.player.impacted )
		{

			if ( left_pressed )
			{
				if ( !self.left_looping )
					self PlayLoopSound( "scn_cliffhanger_icepick_scrape_left" );
				self.left_looping = true;
			}
			else
			{
				if ( self.left_looping )
					self StopLoopSound( "scn_cliffhanger_icepick_scrape_left" );
				self.left_looping = false;
			}

			if ( right_pressed )
			{
				if ( !self.right_looping )
					self PlayLoopSound( "scn_cliffhanger_icepick_scrape_right" );
				self.right_looping = true;
			}
			else
			{
				if ( self.right_looping )
					self StopLoopSound( "scn_cliffhanger_icepick_scrape_right" );
				self.right_looping = false;
			}
		}

		if ( left_pressed )
			pressed++;
		if ( right_pressed )
			pressed++;

		slide_rumble( pressed, anim_both_in );

		animation = anims[ left_pressed ][ right_pressed ];


		foreach ( other_animation in all_anims )
		{
			if ( other_animation == animation )
				continue;
			self SetAnimLimited( other_animation, 0.001, 0.1, 1 );
		}

		self SetAnimLimited( animation, 0.999, 0.1, 1 );


		rate = pressed_rates[ pressed ];

		if ( rate > current_rate )
		{
			current_rate = rate;
		}
		else
		{
			dif = 0.9;
			current_rate = current_rate * dif + rate * ( 1 - dif );
		}

		self SetAnimLimited( anim_both_in, 1, 0, current_rate );
		self SetAnimLimited( anim_both_out, 1, 0, current_rate );
		self SetAnimLimited( anim_left, 1, 0, current_rate );
		self SetAnimLimited( anim_right, 1, 0, current_rate );

		wait( 0.05 );
	}
}

sliding_fx( ent )
{
	self endon( "stop_fx" );

	for ( ;; )
	{
		foreach ( arm, pressed in ent.pressed )
		{
			if ( pressed )
			{
				fx_tag_name = get_icepick_tag_name( arm );
				fx_tag = spawn_player_icepick_fx_tag( self, fx_tag_name );
				fx_tag traceFX_on_tag( "slide_fx", "tag_origin", 10 );
				fx_tag Delete();
				wait( RandomFloatRange( 0.05, 0.1 ) );
			}
		}
		wait( 0.05 );
	}
}

slide_rumble( pressed, anim_both_in, player_arms )
{
	if ( self GetAnimTime( anim_both_in ) >= 0.90 )
		return;
	if ( pressed == 0 )
		return;
	if ( !level.player.impacted )
		return;
	level.player PlayRumbleOnEntity( "icepick_slide" );
}

start_climb_hint( ent )
{
	if ( level.gameSkill > 1 )
	{
		wait( 5 );
	}
	else
	{
		wait( 2 );
	}
	// "right_icepick", "left_icepick"
	display_hint( ent.globals.current_arm + "_icepick" );
}

should_stop_hanging_left_icepick_hint()
{
	return stop_hanging_arm_hint( "left" );
}

should_stop_hanging_right_icepick_hint()
{
	return stop_hanging_arm_hint( "right" );
}

stop_hanging_arm_hint( arm )
{
	other_arm = get_other_arm( arm );
	if ( !level.player [[ level.arm_ent_globals.arm_ents[ other_arm ].buttonCheck ]]() )
		return true;

	return level.player [[ level.arm_ent_globals.arm_ents[ arm ].buttonCheck ]]();
}

should_stop_how_to_climb_hint()
{
	return flag( "player_starts_climbing" );
}

cliff_plane_sound_node( loop, sonic_boom )
{
	maps\_mig29::plane_sound_players( "veh_mig29_cliff_dist_loop", "veh_mig29_cliff_sonic_boom" );
}

is_e3_start()
{
	return maps\cliffhanger_code::is_e3_start();
}

blend_in_climbing_dof( time )
{
	start = level.dofDefault;
	end[ "nearStart" ] = 15;
	end[ "nearEnd" ] = 24;
	end[ "nearBlur" ] = 4;

	end[ "farStart" ] = level.dofDefault[ "farStart" ];
	end[ "farEnd" ] = level.dofDefault[ "farEnd" ];
	end[ "farBlur" ] = level.dofDefault[ "farBlur" ];
	
	for ( ;; )
	{
		flag_wait( "climbing_dof" );
		delay_then_blend_dof( start, end, time );

//		set_far_dof_dist_to_price();
		flag_waitopen( "climbing_dof" );
		current = level.dofDefault;
		blend_dof( current, start, 1 );
	}
}

delay_then_blend_dof( start, end, time )
{
	level endon( "climbing_dof" );
	wait( 5 );
	blend_dof( start, end, time );
}


set_far_dof_dist_to_price()
{
	for ( ;; )
	{
		if ( !flag( "climbing_dof" ) )
			return;
		if ( !isalive( level.price ) )
			return;
		dist = distance( level.player.origin, level.price.origin );
		
		level.dofDefault[ "farStart" ] = dist - 50;
		level.dofDefault[ "farEnd" ] = dist + 100;
		wait( 0.05 );
	}
}
