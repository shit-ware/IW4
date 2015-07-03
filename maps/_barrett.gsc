#include maps\_hud_util;
#include maps\_utility;
#include maps\_debug;
#include animscripts\utility;
#include common_scripts\utility;
#include maps\_anim;

#using_animtree( "script_model" );
barrett_init()
{
	/*
	
	ADD TO YOUR CSV:!!!!!!!!!!!!!!
	
	xmodel,weapon_m82_MG_Setup
	rawfile,animtrees/script_model.atr
	rawfile,maps/_barrett.gsc
	xanim,sniper_escape_flag_wave_down
	xanim,sniper_escape_flag_wave_up
	xmodel,prop_car_flag
	weapon,sp/barrett_fake
	rawfile,shock/barrett.shock
	fx,smoke/smoke_geotrail_barret
	*/

	//precacheitem( "barrett_fake" );
	precacheshellshock( "barrett" );
	// Press forwards or backwards to adjust zoom.
	add_hint_string( "barrett", &"WEAPON_PRESS_FORWARDS_OR_BACKWARDS", ::should_break_zoom_hint );

	flag_init( "player_is_on_turret" );
	flag_init( "player_on_barret" );
	flag_init( "player_used_zoom" );
	flag_init( "can_use_turret" );
	flag_init( "player_gets_off_turret" );

	level._effect[ "bullet_geo" ]					 = loadfx( "smoke/smoke_geotrail_barret" );
	thread exchange_trace_converter();
	thread exchange_barrett_trigger();// get on and off

	//thread exchange_dof();

	// the turret dvars dont exist onthe first frame
	wait( 0.05 );
	//setsaveddvar( "turretScopeZoomMin", "1.5" );
	//setsaveddvar( "turretScopeZoomMax", "70" );
	//setsaveddvar( "turretScopeZoom", "70" );

	level.barrett_exists = true;
}



exchange_barrett_trigger()
{
	barrett_trigger = getent( "barrett_trigger", "targetname" );
	// Press and hold^3 &&1 ^7to use the M82 .50 Caliber Sniper Rifle
	barrett_trigger sethintstring( &"WEAPON_BARRETT_USE" );
	turret = getent( "turret2", "targetname" );

	targ = getent( turret.target, "targetname" );
	turret makeUnusable();
	turret hide();
	turret.origin = targ.origin;

	while ( 1 )
	{
		barrett_trigger waittill( "trigger" );
		level.player.original_org = level.player.origin;
		
		level.player setplayerangles( ( turret.angles[ 0 ], turret.angles[ 1 ], level.player.angles[ 2 ] ) ); 
		
		turret useby( level.player );

		setsaveddvar( "ui_hideMap", "1" );
		setsaveddvar( "compass", 0 );
		SetSavedDvar( "ammoCounterHide", "1" );
		SetSavedDvar( "hud_showStance", 0 );

		level.player_can_fire_turret_time = gettime() + 1000;
		setsaveddvar( "sv_znear", "100" );// 100
		//should maybe be the real target
		setsaveddvar( "sm_sunShadowCenter", getent( turret.target, "targetname" ).origin );
		flag_set( "player_is_on_turret" );
		level.player disableWeapons();
		if ( level.script == "dcburning" )
		{
			level.player SetActionSlot( 1, "" );
			level.player NightVisionForceOff();
		}
		
		//level.player allowCrouch( false );
		//level.player allowStand( false );
		thread player_learns_to_zoom();
		if ( !flag( "player_used_zoom" ) )
		{
			level.player thread display_hint( "barrett" );
		}

		level.level_specific_dof = true;
		// compensate for intro view in the ground, simulating prone
		player_org = level.player.origin + ( 0, 0, 60 );


		for ( ;; )
		{
			if ( !isdefined( turret getturretowner() ) )
				break;
			wait( 0.05 );
		}
		//flag_wait( "player_gets_off_turret" );

		//level.player EnableTurretDismount();
		//barrett_trigger = getent( "barrett_trigger", "targetname" );
		//barrett_trigger delete();
		//turret useby( level.player );
		//turret delete();

		setsaveddvar( "compass", 1 );
		SetSavedDvar( "ammoCounterHide", "0" );
		setsaveddvar( "ui_hideMap", "0" );
		SetSavedDvar( "hud_showStance", 1 );

		setsaveddvar( "sv_znear", "0" );
		setsaveddvar( "sm_sunShadowCenter", ( 0, 0, 0 ) );
		flag_clear( "player_is_on_turret" );
		level.player enableWeapons();
		if ( level.script == "dcburning" )
		{
			level.player SetActionSlot( 1, "nightvision" );
		}
		//level.player allowCrouch( true );
		//level.player allowStand( true );
		level.level_specific_dof = false;


		// clear blur in case we were on min spec pc and holding key
		setblur( 0, 0.05 );


		level.player setorigin( level.player.original_org + ( 0, 0, 10 ) );
		//wait 1.5;//weird bounce
		//level.player enableweapons();
	}
}

exchange_trace_converter()
{
	firetime = -5000;

	for ( ;; )
	{
		flag_wait( "player_is_on_turret" );
		wait_for_buffer_time_to_pass( firetime, 1.0 );

		if ( !level.player attackbuttonpressed() )
		{
			wait( 0.05 );
			continue;
		}

		thread exchange_player_fires();
		firetime = gettime();

		// wait for the player to release the fire, as its a semi auto weapon
		while ( level.player attackbuttonpressed() )
		{
			wait( 0.05 );
		}
	}
}

exchange_player_fires()
{
	if ( gettime() < level.player_can_fire_turret_time )
		return;

//	min_zoom = .5;// was 1.5
//	max_zoom = 20;
//	min_eq = 0.15;
//	max_eq = 0.80;
//
//	zoom = getdvarfloat( "turretScopeZoom" );
//	eq = ( zoom - min_zoom ) * ( max_eq - min_eq ) / ( max_zoom - min_zoom );
//	eq += min_eq;

	level.player shellshock( "barrett", 1.3 );
//	level.fired_barrett = true;
//
//	angles = level.player getplayerangles();
//	start = level.player geteye();
//
//	forward = anglestoforward( angles );
//	end = start + vector_multiply( forward, 15000 );

//	thread linedraw( eye, end, (1,0,1), 25 );

//	trace = BulletTrace( start, end, false, undefined );
//	level.trace = trace;

//	if ( trace[ "surfacetype" ] != "default" )
//	{
////		thread Linedraw( start, trace[ "position" ], (0,1,0) );
//		return;
//	}
//
////	thread Linedraw( start, trace[ "position" ], (1,0,0) );
//
//	start = trace[ "position" ] + vector_multiply( forward, 10 );
//	end = trace[ "position" ] + vector_multiply( forward, 15000 );
//
//	skill_drift = [];
//	skill_drift[ 0 ] = 0.025;
//	skill_drift[ 1 ] = 0.025;
//	skill_drift[ 2 ] = 0.025;
//	skill_drift[ 3 ] = 0.025;
//
//
//	pos = start;
//	move_distance = 314.245;
//	move_vec = vector_multiply( forward, move_distance );
//	waittillframeend;
////	eye = level.player.origin + ( -3.62, 0, -66 );
//	turret = getent( "turret2", "targetname" );
//	if ( !isdefined( turret ) )
//		return;
////	eye = turret.origin + ( getdvarfloat( "ax" ), getdvarfloat( "ay" ), getdvarfloat( "az" ) );
//	eye = turret.origin + ( -0.1, 0, 15 );
////	eye = level.player.origin + ( getdvarfloat( "ax" ), getdvarfloat( "ay" ), getdvarfloat( "az" ) );
//
//	bullet = spawn( "script_model", eye );
//	bullet setmodel( "tag_origin" );
//
//	playfxontag( getfx( "bullet_geo" ), bullet, "tag_origin" );
////	println( "start " + start + " firetime " + gettime() );
//	count_max = 10;
//	count = 0;
//
//	bullet_last_org = bullet.origin;
//
//	trace = undefined;
//	tried_lock = false;
//	lock_on_steps = undefined;
//	achieved_lock = false;
//	current_step = 0;
//	drift = ( 0, 0, 0 );
//
//	for ( ;; )
//	{
//		endpos = pos + move_vec;
//		drift = vector_multiply( level.wind_vec, skill_drift[ level.gameskill ] );
//
////		thread linedraw( pos, endpos, ( 1, 0.2, 0 ), 5 );
//
//		trace = bullettrace( pos, endpos, true, undefined );
//		final_origin = trace[ "position" ];
//		if ( trace[ "fraction" ] < 1 )
//		{
//			//exchange_impact_alert( trace[ "position" ] );
//			angles = vectortoangles( endpos - pos );
//			break;
//		}
//
//		view_frac = count / count_max;
////		view_frac -= 0.1;
//		if ( view_frac < 0 )
//			view_frac = 0;
//		if ( view_frac > 1.0 )
//			view_frac = 1.0;
//		count++ ;
//
//		level.view_frac = view_frac;
//		oldorg = bullet.origin;
//
//		oldeye = eye;
//		eye += move_vec;
////		thread linedraw( oldeye, eye, (1,0,0), 25 );
//
//		bullet_last_org = bullet.origin;
//		bullet.origin = vector_multiply( final_origin, view_frac ) + vector_multiply( eye, 1.0 - view_frac );
//
//
//		pos += move_vec + drift;
//
////		line( eye, bullet.origin, (1,1,1) );
//		wait( 0.05 );
//	}
//
//	println( "hittime " + gettime() );
//	forward = anglestoforward( angles );
//	// scale it way out for bullet penetration purposes
//	pop_vec = vector_multiply( forward, 5 );
//	move_vec = vector_multiply( forward, 15000 );
//	MagicBullet( "barrett_fake", pos, pos + move_vec );
//
//	wait( 0.25 );
//	bullet delete();

}

//exchange_dof()
//{
//	for ( ;; )
//	{
//		flag_wait( "player_is_on_turret" );
//		exchange_scale_dof_while_on_turret();
//		flag_waitopen( "player_is_on_turret" );
//		level.player SetDepthOfField( 0, 0, 0, 0, 8, 8 );
//	}
//}

//exchange_scale_dof_while_on_turret()
//{
//	level.fired_barrett = false;
//	level endon( "player_is_on_turret" );
////	SetDepthOfField( <near start>, <near end>, <far start>, <far end>, <near blur>, <far blur> )
//	olddist = getdvarint( "turretscopezoom" );
//
//	zoom[ 9 ] = 6750;
//
//	depthdist = 500;
//
//	max_depthdist = 24000;
//	min_depthdist = 6500;
//	clear_rate = 300;
//	focus_rate = 300;
//	fog_rate = 1000;
//
//	depth_near = 6000;
//
//	max_blurring = 14000;
//
//	fired_barrett_dist = 6500;
//
//	level.blur = 0;
//	blur_barret_fired = 8.0;
//	blur_stable_rate = -0.2;
//	blur_in_rate = 0.10;
//	blur_out_rate = -0.25;
//
//	stable = false;
//	for ( ;; )
//	{
//		dist = getdvarint( "turretscopezoom" );
//
//		if ( dist < olddist )
//		{
//			if ( dist >= max_blurring )
//			{
//				dist = max_blurring;
//			}
//
//			// zooming in, so bring the fog in
//			depthdist -= fog_rate;
//
//			level.blur += blur_in_rate;
//			stable = false;
//		}
//		else
//		if ( dist == olddist )
//		{
//			if ( stable )
//			{
//				// stable, focus the eyes
//				depthdist += focus_rate;
//
//				level.blur = level.blur * 0.9;
//				if ( level.blur < 0.1 )
//					level.blur = 0;
//			}
//			stable = true;
//		}
//		else
//		{
//			stable = false;
//			// zooming out, sharpen things up quick
//			depthdist += clear_rate;
//
//			level.blur += blur_out_rate;
//		}
//
//		if ( level.fired_barrett )
//		{
//			level.fired_barrett = false;
//			depthdist = fired_barrett_dist;
//			level.blur = blur_barret_fired;
//		}
//
//		if ( level.blur > 12 )
//			level.blur = 12;
//		if ( level.blur < 0 )
//			level.blur = 0;
//
//		far_min = depthdist - depth_near;
//		if ( far_min < 0 )
//			far_min = 0;
//
//		if ( depthdist > max_depthdist )
//			depthdist = max_depthdist;
//		else
//		if ( depthdist < min_depthdist )
//			depthdist = min_depthdist;
//
////		println( "dofdist " + depthdist + " zoom " + dist );		
//		level.player SetDepthOfField( 0, 0, far_min, depthdist, 8, 8 );
//		if ( getdvarint( "r_dof_enable" ) != true )
//		{
//			setblur( level.blur, 0.05 );
//		}
//		olddist = dist;
//		wait( 0.05 );
//	}
//}

should_break_zoom_hint()
{
	assert( isplayer( self ) );

	if ( !flag( "player_is_on_turret" ) )
		return true;

	return flag( "player_used_zoom" );
}

player_learns_to_zoom()
{

	flag_clear( "player_used_zoom" );		//make sure we show hint anytime player gets on the rifle
	movement = level.player GetNormalizedMovement();
	
	while( true )
	{
		wait( 0.05 );
		movement = level.player GetNormalizedMovement();	//needs to move stick forward to learn
		if ( movement[ 0 ] > 0.2 )
			break;
		//iprintlnbold( movement[ 0 ] + " : " + movement[ 1 ] );
	}
	wait( 6 );
	flag_set( "player_used_zoom" );
}

