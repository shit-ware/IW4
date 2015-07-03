#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;


init()
{
	//should make hellfires no do friendly fire
	level.no_friendly_fire_splash_damage = true;

	if ( !isdefined( level.min_time_between_uav_launches ) )
	{
		level.min_time_between_uav_launches = 12 * 1000;
	}

	level.last_uav_launch_time = 0 - level.min_time_between_uav_launches;
//	level.last_uav_offline_time = 0;
	level.uav_radio_offline_called = false;

	PreCacheItem( "remote_missile_detonator" );
	PreCacheItem( "remote_missile" );
	PreCacheShader( "veh_hud_target" );
	PreCacheShader( "veh_hud_target_offscreen" );
	PreCacheShader( "veh_hud_missile_flash" );
	PreCacheShader( "ac130_overlay_grain" );
	PreCacheShader( "remotemissile_infantry_target" );
	PreCacheShader( "hud_fofbox_self_sp" );
	PreCacheShader( "dpad_killstreak_hellfire_missile_inactive" );
	precacheString( &"HELLFIRE_DRONE_VIEW" );
	precacheString( &"HELLFIRE_MISSILE_VIEW" );
	precacheString( &"HELLFIRE_FIRE" );
	

	// Predator Drone has been destroyed.
	add_hint_string( "hint_predator_drone_destroyed", &"HELLFIRE_DESTROYED", ::should_break_destroyed );
	// Predator Drone is unavailable.
	add_hint_string( "hint_predator_drone_4", 			&"HELLFIRE_USE_DRONE", 			::should_break_use_drone );
	add_hint_string( "hint_predator_drone_2", 			&"HELLFIRE_USE_DRONE_2", 		::should_break_use_drone );
	add_hint_string( "hint_predator_drone_not_available", &"HELLFIRE_DRONE_NOT_AVAILABLE", ::should_break_available );

//	array_thread( level.players, ::RemoteMissileDetonatorNotify );

	VisionSetMissilecam( "missilecam" );

	SetSavedDvar( "missileRemoteSpeedUp", "1000" );
	SetSavedDvar( "missileRemoteSpeedTargetRange", "6000 12000" );

	mapname = GetDvar( "mapname" );
	if ( mapname == "zzz" )
	{
	}
	else if ( mapname == "raymetest" )
	{
		SetSavedDvar( "missileRemoteSpeedUp", "500" );
		SetSavedDvar( "missileRemoteSpeedTargetRange", "3000 6000" );
	}

	add_global_spawn_function( "axis", ::missile_kill_ai );

	flag_init( "uav_reloading" );
	flag_init( "uav_collecting_stats" );
	flag_init( "uav_enabled" );
	flag_set( "uav_enabled" );
}


should_break_use_drone()
{
	break_hint = false;
	if ( isdefined( level.uav_is_destroyed ) )
	{
		break_hint = true;
	}

	if ( !isalive( level.uav ) )
	{
		break_hint = true;
	}

	if ( isdefined( self.is_flying_missile ) )
	{
		break_hint = true;
	}

	// Sniper Fi Support
	if ( flag_exist( "wave_wiped_out" ) && flag( "wave_wiped_out" ) )
	{
		break_hint = true;
	}

	if ( self ent_flag_exist( "coop_downed" ) && self ent_flag( "coop_downed" ) )
	{
		break_hint = true;
	}

	if( self getCurrentWeapon() == "remote_missile_detonator" )
	{
		break_hint = true;
	}
	
	return break_hint;	
}

init_radio_dialogue()
{
	if ( !IsDefined( level.scr_radio ) )
	{
		level.scr_radio = [];
	}

	level.uav_radio_initialized = true;

	// Offline / Online
	level.scr_radio[ "uav_reloading" ] 				= "cont_cmt_rearmhellfires";
	level.scr_radio[ "uav_offline" ] 				 = "cont_cmt_hellfiresoffline";
	level.scr_radio[ "uav_online" ] 				 = "cont_cmt_hellfireonline";
	level.scr_radio[ "uav_online_repeat" ] 			 = "cont_cmt_repeatonline";

	level.scr_radio[ "uav_down" ] 					 = "cont_cmt_uavdown";

	// AI Kills
	level.scr_radio[ "uav_multi_kill" ] 			 = "cont_cmt_mutlipleconfirmed";
	level.scr_radio[ "uav_multi_kill2" ] 			 = "cont_cmt_fivepluskias";
	level.scr_radio[ "uav_few_kills" ] 				 = "cont_cmt_theyredown";
	level.scr_radio[ "uav_3_kills" ] 				 = "cont_cmt_3kills";
	level.scr_radio[ "uav_1_kill" ] 				 = "cont_cmt_hesdown";

	// vehicle kills
	level.scr_radio[ "uav_btr_kill" ] 				 = "cont_cmt_mutlipleconfirmed";
	level.scr_radio[ "uav_few_kills" ] 				 = "cont_cmt_theyredown";
	level.scr_radio[ "uav_3_kills" ] 				 = "cont_cmt_3kills";
	level.scr_radio[ "uav_1_kill" ] 				 = "cont_cmt_hesdown";

	level.scr_radio[ "uav_multi_vehicle_kill" ] 	 = "cont_cmt_goodhitvehicles";
	level.scr_radio[ "uav_multi_vehicle_kill2" ] 	 = "cont_cmt_goodeffectkia";

	level.scr_radio[ "uav_helo_kill" ] 				 = "cont_cmt_directhitshelo";
	level.scr_radio[ "uav_btr_kill" ] 				 = "cont_cmt_btrdestroyed";
	level.scr_radio[ "uav_truck_kill" ] 			 = "cont_cmt_goodkilltruck";
	level.scr_radio[ "uav_jeep_kill" ] 				 = "cont_cmt_directhitjeep";
	level.scr_radio[ "uav_direct_hit" ] 			 = "cont_cmt_directhit";
}

is_radio_defined( alias )
{
	return IsDefined( level.scr_radio[ alias ] ) || IsDefined( level.scr_radio[ alias + "_variant" ] );
}

should_break_available()
{
	if ( IsDefined( level.uav_is_not_available ) )
		return false;
	else
		return true;
}

should_break_destroyed()
{
	if ( IsDefined( level.uav_is_destroyed ) )
		return false;
	else
		return true;
}

enable_uav( do_radio, restore )
{
	if ( !IsDefined( do_radio ) )
	{
		do_radio = true;
	}

	if ( !flag( "uav_enabled" ) )
	{
		flag_set( "uav_enabled" );

		if ( !flag( "uav_reloading" ) && do_radio )
		{
			thread remotemissile_radio( "uav_online" );
		}
	}

	if ( IsDefined( restore ) )
	{
		restore_uav_weapon( restore );
	}
}

disable_uav( do_radio, remove )
{
	if ( !IsDefined( do_radio ) )
	{
		do_radio = true;
	}

	if ( flag( "uav_enabled" ) )
	{
		flag_clear( "uav_enabled" );

		if ( !flag( "uav_reloading" ) && do_radio )
		{
			thread remotemissile_radio( "uav_offline" );
		}
	}

	if ( IsDefined( remove ) )
	{
		remove_uav_weapon();
	}
}

restore_uav_weapon( restore )
{
	if ( IsDefined( level.uav_is_destroyed ) )
	{
		return;
	}

	if ( IsString( restore ) )
	{
		weapon = restore;
	}
	else if ( IsDefined( self.uav_weaponname ) )
	{
		weapon = self.uav_weaponname;
	}
	else
	{
		return;
	}

	if ( !self HasWeapon( weapon ) )
	{
		return;
	}

	self SetWeaponHudIconOverride( "actionslot" + self get_remotemissile_actionslot(), "none" );
	self SetActionSlot( self get_remotemissile_actionslot(), "weapon", weapon );
}

remove_uav_weapon()
{
	self SetWeaponHudIconOverride( "actionslot" + self get_remotemissile_actionslot(), "dpad_killstreak_hellfire_missile_inactive" );
	self SetActionSlot( self get_remotemissile_actionslot(), "" );
}

is_remote_missile_weapon( weap )
{
	if ( !IsDefined( weap ) )
	{
		return false;
	}

	if ( weap == "remote_missile_detonator" )
	{
		return true;
	}

	if ( weap == "remote_missile_detonator_finite" )
	{
		return true;
	}

	return false;
}

give_remotemissile_weapon( weapon_name )
{
	self set_remotemissile_actionslot();
	self SetActionSlot( self get_remotemissile_actionslot(), "weapon", weapon_name );
	self GiveWeapon( weapon_name );

	self thread RemoteMissileDetonatorNotify();
}

// Sets the proper dpad depending if they have the claymore or not
set_remotemissile_actionslot()
{
	if ( !self HasWeapon( "claymore" ) )
	{
		// Move the claymore (since we do not have it yet) to the down dpad
		self.remotemissile_actionslot = 4;
	}
	else
	{
		self.remotemissile_actionslot = 2;
	}
}

get_remotemissile_actionslot()
{
	AssertEx( IsDefined( self.remotemissile_actionslot ), "self.remotemissile_actionslot is undefined, you need to use the give_remotemissile_weapon() function in here to give the player the weapon properly." );
	return self.remotemissile_actionslot;
}

remotemissile_weapon_change()
{
	self.using_uav = false;

	while ( 1 )
	{
		self waittill( "weapon_change", weap );

		if ( is_remote_missile_weapon( weap ) )
		{
			self.using_uav = true;

			if ( IsDefined( level.uav_is_destroyed ) )
			{
				thread remotemissile_offline( false, "uav_down" );
				self SwitchToWeapon( self.last_weapon );
				self.using_uav = false;
				continue;
			}

			if ( self ent_flag_exist( "coop_downed" ) && self ent_flag( "coop_downed" ) )
			{
				self SwitchBackToMainWeapon();
				self.using_uav = false;
				continue;
			}

			self.uav_weaponname = weap;
	
			self thread cancel_on_player_damage();
			if ( IsDefined( level.remote_missile_hide_stuff_func ) )
			{
				[[ level.remote_missile_hide_stuff_func ]]();
			}
	
			level.uav_user = self;
			level.uav_killstats = [];
	
			UAVRemoteLauncherSequence( self, weap );

			level.uav_user = undefined;

			self.using_uav = false;
	
			if ( IsDefined( level.remote_missile_show_stuff_func ) )
			{
				[[ level.remote_missile_show_stuff_func ]]();
			}
	
			thread remotemissile_reload();
		}
	}
}

RemoteMissileDetonatorNotify()
{
	Assert( self.classname == "player" );
	self NotifyOnPlayerCommand( "switch_to_remotemissile", "+actionslot " + self get_remotemissile_actionslot() );
	self thread remotemissile_weapon_change();

	for ( ;; )
	{
		self waittill( "switch_to_remotemissile" );

		if ( self.using_uav )
		{
			continue;
		}

		if ( !is_remote_missile_weapon( self GetCurrentWeapon() ) )
		{
			self.last_weapon = self GetCurrentWeapon();
		}

		if ( IsDefined( level.uav_is_destroyed ) )
		{
			thread remotemissile_offline( false, "uav_down" );
		}
		else if ( flag( "uav_reloading" ) || !flag( "uav_enabled" ) )
		{
			thread remotemissile_offline( true );
		}
	}
}

remotemissile_offline( extra_check, alias )
{
	if ( !IsDefined( alias ) )
	{
		alias = "uav_offline";
	}

	curr_time = GetTime();

	// Only use extra_check if you don't want the dialogue to happen just before the hellfire "online" is about to
	// play
	if ( extra_check && ( ( level.last_uav_launch_time + level.min_time_between_uav_launches ) - curr_time < 2000 ) || level.min_time_between_uav_launches < 5000 )
	{
		// These 2 checks are specific to levels. 
		// SO_ROOFTOP_CONTINGENCY needs dialogue if out of ammo.
		// All other levels need uav_is_destroyed
		if ( !IsDefined( level.uav_is_destroyed ) && ( IsDefined( self.uav_weaponname ) && self GetWeaponAmmoClip( self.uav_weaponname ) > 0 ) )
		{
			return;
		}
	}

	if( flag( "uav_reloading" ) )
	{
		if( isdefined( level.scr_radio[ "uav_reloading" ] 	) )
		{
			alias = "uav_reloading";
		}
	}

//	if ( !flag( "uav_collecting_stats" ) && curr_time > level.last_uav_offline_time + 1000 )
	if ( !flag( "uav_collecting_stats" ) && !level.uav_radio_offline_called )
	{
		level.uav_radio_offline_called = true;
		remotemissile_radio( alias );
		level.uav_radio_offline_called = false;
	}
}

remotemissile_reload()
{
	level endon( "stop_uav_reload" );
	level endon( "special_op_terminated" );

	// Wait for reload
	if ( flag( "uav_reloading" ) )
	{
		if ( IsDefined( level.uav_is_destroyed ) )
		{
			return;
		}

		remove_uav_weapon();

		if ( flag( "uav_collecting_stats" ) )
		{
			level waittill( "uav_collecting_stats" );
			play_kills_dialogue();
		}

		if ( IsDefined( level.uav_is_destroyed ) )
		{
			return;
		}

		// Make uav_user undefined so missile_kill_ai returns immediately.
		level.uav_user = undefined;

		//z: dont want to hear hellfire off line after each shot
		// Only do the dialogue if we have enough time between reloads.
		//if ( level.min_time_between_uav_launches > 5000 )
		//{
		//	thread remotemissile_offline( false );
		//}

		// Waiting for the flag_clear() notify
		if ( flag( "uav_reloading" ) )
		{
			level waittill( "uav_reloading" );
		}

		if ( IsDefined( level.uav_is_destroyed ) )
		{
			return;
		}

		if ( !flag( "uav_enabled" ) )
		{
			return;
		}

		if ( self GetWeaponAmmoClip( self.uav_weaponname ) < 1 )
		{
			disable_uav();
			return;
		}

		restore_uav_weapon();
		thread remotemissile_radio( "uav_online" );

		thread remotemissile_radio_reminder();
	}
}

remotemissile_radio_reminder()
{
	level notify( "stop_remotemissile_radio_reminder" );

	level endon( "special_op_terminated" );
	level endon( "starting_predator_drone_control" );
	level endon( "stop_remotemissile_radio_reminder" );

	while( 1 )
	{
		wait( 7 + RandomInt( 4 ) );

		if ( flag_exist( "special_op_terminated" ) && flag( "special_op_terminated" ) )
		{
			return;
		}

		if ( IsDefined( level.uav_is_destroyed ) )
		{
			return;
		}

		if ( flag( "uav_reloading" ) )
		{
			return;
		}

		if ( !flag( "uav_enabled" ) )
		{
			return;
		}

		remotemissile_radio( "uav_online_repeat" );
		
		wait( 15 + RandomInt( 10 ) );

		if ( flag_exist( "special_op_terminated" ) && flag( "special_op_terminated" ) )
		{
			return;
		}
		
		if ( IsDefined( level.uav_is_destroyed ) )
		{
			return;
		}
		
		if ( IsDefined( level.no_remote_missile_reminders ) )
		{
			return;
		}
	
		remotemissile_radio( "uav_online" );
		self thread display_hint_timeout( "hint_predator_drone_" + self get_remotemissile_actionslot(), 6 );
		
	}
}

play_kills_dialogue()
{
	if ( IsDefined( level.dont_use_global_uav_kill_dialog ) )
		return;

	if ( !IsDefined( level.uav_radio_initialized ) )
	{
		return;
	}

// "Good hit. Multiple vehicles destroyed."					level.scr_radio[ "multi_vehicle_kill" ] = "cont_cmt_goodhitvehicles";
// "Good effect on target. Multiple enemy vehicles KIA." 	level.scr_radio[ "multi_vehicle_kill2" ] = "cont_cmt_goodeffectkia";

// "Direct hit on the enemy helo. Nice shot Roach."			level.scr_radio[ "helo_kill" ] = "cont_cmt_directhitshelo";
// "Good effect on target. BTR destroyed."					level.scr_radio[ "btr_kill" ] = "cont_cmt_btrdestroyed";
// "Good kill. Truck destroyed."							level.scr_radio[ "truck_kill" ] = "cont_cmt_goodkilltruck";
// "Direct hit on that jeep."								level.scr_radio[ "jeep_kill" ] = "cont_cmt_directhitjeep";
// "Direct hit."											level.scr_radio[ "direct_hit" ] = "cont_cmt_directhit";

// "Five plus KIAs. Good hit. Good hit.						level.scr_radio[ "multi_kill2" ] = "cont_cmt_fivepluskias";
// "Multiple confirmed kills. Nice work."					level.scr_radio[ "multi_kill" ] = "cont_cmt_mutlipleconfirmed";
// "They're down."											level.scr_radio[ "few_kills" ] = "cont_cmt_theyredown";
// "Good hit. Looks like at least three kills."				level.scr_radio[ "3_kills" ] = "cont_cmt_3kills";
// "He's down."												level.scr_radio[ "1_kill" ] = "cont_cmt_hesdown";

	ai_alias = undefined;
	ai_kills = 0;

	if ( IsDefined( level.uav_killstats[ "ai" ] ) )
	{
		ai_kills = level.uav_killstats[ "ai" ];
	}

	if ( ai_kills > 5 )
	{
		ai_alias = "uav_multi_kill";

		if ( is_radio_defined( "uav_multi_kill2" ) && cointoss() )
		{
			ai_alias = "uav_multi_kill2";
		}
	}
	else if ( ai_kills >= 3 )
	{
		ai_alias = "uav_3_kills";
	}
	else if ( ai_kills > 1 )
	{
		ai_alias = "uav_few_kills";
	}
	else if ( ai_kills > 0 )
	{
		ai_alias = "uav_1_kill";
	}

	vehicle_alias = undefined;
	btr_kills = 0;

	vehicle_kills = 0;
	btr_kills = 0;
	helo_kills = 0;
	jeep_kills = 0;
	truck_kills = 0;

	foreach ( index, kills in level.uav_killstats )
	{
		if ( index == "ai" )
		{
			continue;
		}

		if ( kills  > 0 )
		{
			vehicle_kills = vehicle_kills + kills;

			if ( index == "btr" )
			{
				btr_kills = kills;
			}
			else if ( index == "helo" )
			{
				helo_kills = kills;
			}
			else if ( index == "jeep" )
			{
				jeep_kills = kills;
			}
			else if ( index == "truck" )
			{
				truck_kills = kills;
			}
		}
	}

	alias = ai_alias;

	if ( btr_kills > 0 )
	{
		alias = "uav_btr_kill";
	}
	else if ( helo_kills > 0 )
	{
		alias = "uav_helo_kill";
	}
	else if ( vehicle_kills > 1 )
	{
		alias = "uav_multi_vehicle_kill";

		if ( is_radio_defined( "uav_multi_vehicle_kill2" ) && cointoss() )
		{
			alias = "uav_multi_vehicle_kill2";
		}
	}
	else if ( jeep_kills > 0 )
	{
		alias = "uav_jeep_kill";

		if ( ai_kills > 2 && ai_kills <= 5 && is_radio_defined( "uav_direct_hit" ) && cointoss() )
		{
			alias = "uav_direct_hit";
		}
	}
	else if ( truck_kills > 0 )
	{
		alias = "uav_truck_kill";

		if ( ai_kills > 2 && ai_kills <= 5 && is_radio_defined( "uav_direct_hit" ) && cointoss() )
		{
			alias = "uav_direct_hit";
		}
	}

	if ( !IsDefined( alias ) )
	{
		return;
	}

	if ( flag_exist( "special_op_terminated" ) && flag( "special_op_terminated" ) )
	{
		return;
	}

	remotemissile_radio( alias );
	level notify( "remote_missile_kill_dialogue" );
}

set_variant_remotemissile_radio( alias )
{
	if ( IsDefined( level.scr_radio[ alias + "_variant" ] ) && IsArray( level.scr_radio[ alias + "_variant" ] ) )
	{
		level.scr_radio[ alias ] = level.scr_radio[ alias + "_variant" ][ RandomInt( level.scr_radio[ alias + "_variant" ].size ) ];
	}
}

remotemissile_radio( alias )
{
	if ( !IsDefined( level.uav_radio_initialized ) )
	{
		return;
	}

	if ( IsDefined( level.uav_radio_disabled ) && level.uav_radio_disabled )
	{
		return;
	}

	if ( !is_radio_defined( alias ) )
	{
		return;
	}

	if ( flag_exist( "special_op_terminated" ) && flag( "special_op_terminated" ) )
	{
		return;
	}

	set_variant_remotemissile_radio( alias );
	radio_dialogue( alias );
}

cancel_on_player_damage()
{
	self.took_damage = false;
	//self waittill( "damage" );
	self waittill_any( "damage", "dtest", "force_out_of_uav" );
	self.took_damage = true;
}


text_TitleCreate()
{
	level.text1 = self createClientFontString( "objective", 2.0 );
	level.text1 setPoint( "CENTER", undefined, 0, -175 );
}


text_TitleSetText( text )
{
	level.text1 SetText( text );
}


text_TitleFadeout()
{
	level.text1 FadeOverTime( 0.25 );
	level.text1.alpha = 0;
}


text_TitleDestroy()
{
	if ( !IsDefined( level.text1 ) )
		return;
	level.text1 Destroy();
	level.text1 = undefined;
}


display_wait_to_fire( time_till_reload )
{
	text_NoticeDestroy();
	// MISSILE RELOADED IN: 
	self text_LabelCreate( &"HELLFIRE_RELOADING_WITH_TIME", time_till_reload );
	wait( 1 );
	text_NoticeDestroy();
}

text_LabelCreate( text, time )
{
	level.text2 = self createClientFontString( "objective", 1.85 );
	level.text2 SetPoint( "CENTER", undefined, 0, -120 );
	level.text2.label = text;
	level.text2 SetValue( time );
	level.text2.color = ( 0.85, 0.85, 0.85 );
	level.text2.alpha = 0.75;
}


text_NoticeCreate( text )
{
	level.text2 = self createClientFontString( "objective", 1.85 );
	level.text2 SetPoint( "CENTER", undefined, 0, -120 );
	level.text2 SetText( text );
	level.text2.color = ( 0.85, 0.85, 0.85 );
	level.text2.alpha = 0.75;
}


text_NoticeFadeout()
{
	if ( !IsDefined( level.text2 ) )
		return;
	level.text2 FadeOverTime( 0.25 );
	level.text2.alpha = 0;
}


text_NoticeDestroy()
{
	if ( !IsDefined( level.text2 ) )
		return;
	level.text2 Destroy();
	level.text2 = undefined;
}

WaitWithAbortOnDamage( time )
{
	finishTime = GetTime() + ( time * 1000 );
	while ( GetTime() < finishTime )
	{
		if ( self.took_damage )
		{
			return false;
		}

		if ( IsDefined( level.uav_is_destroyed ) )
		{
			return false;
		}

		if ( !flag( "uav_enabled" ) )
		{
			return false;
		}

		wait 0.05;
	}
	return true;
}


NotifyOnMissileDeath( missile )
{
	timeWeFired = GetTime();
	level.remoteMissileFireTime = timeWeFired;

	if ( IsDefined( missile ) )
	{
		level.remoteMissile = missile;
		missile waittill( "death" );
	}

	//defensive check; make sure we're this is still the latest remote missile
	if ( IsDefined( level.remoteMissileFireTime ) && ( level.remoteMissileFireTime == timeWeFired ) )
	{
		level notify( "remote_missile_exploded" );
		level.remoteMissile = undefined;
	}

	level delayThread( 0.2, ::send_notify, "delayed_remote_missile_exploded" );
}

AbortLaptopSwitch( player )
{
	player VisionSetNakedForPlayer( level.lvl_visionset, 0.5 );
	player VisionSetThermalForPlayer( level.visionThermalDefault, 0.5 );

	player SwitchBackToMainWeapon();
	player FreezeControls( false );
	player EnableOffhandWeapons();

	level.uavTargetEnt = undefined;

	wait 0.1;
	HudItemsShow();
}


UAVRemoteLauncherSequence( player, weap )
{
	if ( weap == "remote_missile_detonator" )
	{
		player GiveMaxAmmo( weap );
	}

	level notify( "starting_predator_drone_control" );
	delay_switch_into_missile = false;
	return_to_uav_after_impact = false;

	level.VISION_BLACK = "black_bw";
	if ( !isdefined( level.VISION_UAV ) )
	{
		level.VISION_UAV = "ac130";
	}

	level.VISION_MISSILE = "missilecam";

	level.uavPlayerOrigin = player GetOrigin();
	level.uavPlayerAngles = player GetPlayerAngles();

	player DisableOffhandWeapons();
	player FreezeControls( true );

	noDamage = player WaitWithAbortOnDamage( 1.0 );
	if ( !noDamage )
	{
		AbortLaptopSwitch( player );
		return;
	}

	trans_time = .25;
	player VisionSetNakedForPlayer( level.VISION_BLACK, trans_time );
	player VisionSetThermalForPlayer( level.VISION_BLACK, trans_time );
	HudItemsHide();
	if ( IsDefined( level.remote_missile_targets ) && ( level.remote_missile_targets.size > 0 ) )
	{
		foreach ( thing in level.remote_missile_targets )
		{
			if ( !isalive( thing ) )
				level.remote_missile_targets = array_remove( level.remote_missile_targets, thing );
		}
	}

	noDamage = WaitWithAbortOnDamage( trans_time );
	if ( !noDamage )
	{
		AbortLaptopSwitch( player );
		return;
	}

	player.is_controlling_UAV = true;
	level notify( "player_is_controlling_UAV" );
	if( isdefined( level.uav ) )
	{
		if ( is_specialop() )
		{
			level.uav HideOnClient( self );
		}
		else
		{
			level.uav Hide();
		}
	}
	player PlayerLinkWeaponViewToDelta( level.uavRig, "tag_player", 1.0, 4, 4, 4, 4 );
	player FreezeControls( false );
	player HideViewModel();
	wait 0.05;

	player text_TitleCreate();
	// CAMERA: UAV_DRONE_011
	text_TitleSetText( &"HELLFIRE_DRONE_VIEW" );

	maps\_load::thermal_EffectsOn();
	player ThermalVisionOn();
	player SetPlayerAngles( level.uavRig GetTagAngles( "tag_origin" ) );
	player VisionSetNakedForPlayer( level.lvl_visionset, 0.25 );
	player VisionSetThermalForPlayer( level.VISION_UAV, 0.25 );
	thread DrawTargetsStart();
	wait 0.2;

	doAttack = WaitForAttackCommand( player );
	if ( !doAttack )
	{
		ExitFromCamera_UAV( player, player.took_damage );
		return;
	}

	level.last_uav_launch_time = GetTime();
	thread uav_reload();

	level notify( "player_fired_remote_missile" );
	missile = FireMissileFromUAVPlayer( player );
	missile thread do_physics_impact_on_explosion( player );

	if ( delay_switch_into_missile )
	{
		// -MISSILE LAUNCHED-
		player text_NoticeCreate( &"HELLFIRE_FIRE" );
		noDamage = WaitWithAbortOnDamage( 1.2 );
		if ( !noDamage )
		{
			ExitFromCamera_UAV( player, true );
			return;
		}

		text_NoticeFadeout();
		DrawTargetsEnd();
		//player VisionSetThermalForPlayer( level.VISION_BLACK, 0.25 );
		wait 0.25;
	}

	player.is_flying_missile = true;// used to break the hint
	// CAMERA: HELLFIRE
	text_TitleSetText( &"HELLFIRE_MISSILE_VIEW" );
	text_NoticeDestroy();
	SwitchBackToMainWeaponFast();
	player RemoteCameraSoundscapeOn();
	player Unlink();
	//player VisionSetThermalForPlayer( level.VISION_MISSILE, 0.5 );
	player DisableWeapons();
	player CameraLinkTo( missile, "tag_origin" );
	player ControlsLinkTo( missile );

	noDamage = WaitWithAbortOnDamage( 0.2 );
	if ( !noDamage )
	{
		ExitFromCamera_Missile( player, true );
		return;
	}

	thread DrawTargetsStart();
	while ( IsDefined( level.remoteMissile ) )
	{
		wait 0.05;
		if ( IsDefined( level.uav_is_destroyed ) )
		{
			ExitFromCamera_Missile( player, true );
			return;
		}

		if ( player.took_damage )
		{
			ExitFromCamera_Missile( player, true );
			return;
		}

		if ( !flag( "uav_enabled" ) )
		{
			ExitFromCamera_Missile( player, true );
			return;
		}
	}

	if ( !isdefined( level.uav ) )
	{
		ExitFromCamera_Missile( player, false );
		return;
	}

	if ( return_to_uav_after_impact )
	{
		//new - go back to uav to see explosion
		level.uav Hide();
		SetSavedDvar( "cg_fov", 26 );
		player.fov_is_altered = true;
		player.is_flying_missile = undefined;
		player ControlsUnlink();
		player CameraUnlink();
		player RemoteCameraSoundscapeOff();
		player PlayerLinkWeaponViewToDelta( level.uavRig, "tag_player", 1.0, 4, 4, 4, 4 );
		player SetPlayerAngles( level.uavRig GetTagAngles( "tag_origin" ) );

		noDamage = WaitWithAbortOnDamage( 2 );
		if ( !noDamage )
		{
			ExitFromCamera_UAV( player, player.took_damage );
			return;
		}

		ExitFromCamera_UAV( player, false );
	}
	else
	{
		ExitFromCamera_Missile( player, false );
	}
}

uav_reload()
{
	level endon( "stop_uav_reload" );

	flag_set( "uav_reloading" );

	wait( level.min_time_between_uav_launches * 0.001 );

	flag_clear( "uav_reloading" );
}

do_physics_impact_on_explosion( player )
{
	player.fired_hellfire_missile = true;

	player waittill( "projectile_impact", weaponName, position, radius );

	level thread missile_kills( player );

	level.uavTargetPos = position;

	physicsSphereRadius = 1000;
	physicsSphereForce = 6.0;
	Earthquake( .3, 1.4, position, 8000 );

	wait 0.1;
	PhysicsExplosionSphere( position, physicsSphereRadius, physicsSphereRadius / 2, physicsSphereForce );

	wait 2;
	level.uavTargetPos = undefined;
	player.fired_hellfire_missile = undefined;
	//level notify ( "player_missile_finished_impact" );
}

missile_kills( player )
{
	flag_set( "uav_collecting_stats" );

//	ai_array = GetAIArray( "axis" );
//	foreach ( ai in ai_array )
//	{
//		ai thread missile_kill_ai( player );
//	}

	vehicles = getVehicleArray();
	foreach ( vehicle in vehicles )
	{
		vehicle thread missile_kill_vehicle( player );
	}

	wait( 1 );
	flag_clear( "uav_collecting_stats" );
}

missile_kill_ai( attacker )
{
	if ( !IsDefined( level.uav_radio_initialized ) )
	{
		return;
	}

	self waittill( "death", attacker, cause );

	if ( !IsDefined( level.uav_user ) )
	{
		return;
	}

	if ( !IsDefined( level.uav_killstats[ "ai" ] ) )
	{
		level.uav_killstats[ "ai" ] = 0;
	}

	if ( IsDefined( attacker ) && IsDefined( level.uav_user ) )
	{
		if ( attacker == level.uav_user || ( IsDefined( attacker.attacker ) && attacker.attacker == level.uav_user ) )
		{
			level.uav_killstats[ "ai" ]++;
			if( isplayer( level.uav_user ) && level.uav_killstats[ "ai" ] == 10 )
				level.uav_user player_giveachievement_wrapper( "TEN_PLUS_FOOT_MOBILES" );
		}
	}
}

missile_kill_vehicle( player )
{
	if ( !IsDefined( level.uav_radio_initialized ) )
	{
		return;
	}

	level endon( "delayed_remote_missile_exploded" );

	type = undefined;

	switch( self.vehicletype )
	{
		case "btr80":
		case "btr80_physics":
			type = "btr";
			break;

		case "ucav":
		case "hind":
		case "mi17":
		case "mi17_noai":
		case "mi17_bulletdamage":
			type = "helo";
			break;

		case "uaz":
		case "uaz_physics":
			type = "jeep";
			break;

		case "bm21":
		case "bm21_drivable":
		case "bm21_troops":
			type = "truck";
			break;

		default:
			type = "vehicle";
			break;
	}

	if ( !IsDefined( level.uav_killstats[ type ] ) )
	{
		level.uav_killstats[ type ] = 0;
	}

	self waittill( "death", attacker, cause );

	if ( ( type == "helo" || type == "btr" ) || IsDefined( self.riders ) && self.riders.size > 0 )
	{
		if ( IsDefined( attacker ) && attacker == player )
		{
			level.uav_killstats[ type ]++;
		}
	}
}


ExitFromCamera_Missile( player, reasonIsPain )
{
	player.is_flying_missile = undefined;
	text_TitleDestroy();
	DrawTargetsEnd();

	if ( IsDefined( level.uav_is_destroyed ) )
		thread staticEffect( .5 );

	player ControlsUnlink();
	player CameraUnlink();
	maps\_load::thermal_EffectsOff();
	player ThermalVisionOff();
	player RemoteCameraSoundscapeOff();
	player VisionSetThermalForPlayer( level.visionThermalDefault, 0 );

	if ( IsDefined( level.uav ) )
	{
		if ( is_specialop() )
		{
			level.uav ShowOnClient( self );
		}
		else
		{
			level.uav Show();
		}
	}

	if ( reasonIsPain )
	{
		//fast switch back - go right to weapon, no flash
		player VisionSetNakedForPlayer( level.VISION_BLACK, 0 );
		wait 0.05;
		player VisionSetNakedForPlayer( level.lvl_visionset, 0.4 );
		player EnableWeapons();
		player FreezeControls( false );
		player ShowViewModel();
		wait 0.2;

		HudItemsShow();
		player EnableOffhandWeapons();
	}
	else
	{
		//slow switch back - flash from missile explosion
		player VisionSetNakedForPlayer( "coup_sunblind", 0 );
		player FreezeControls( true );
		wait 0.05;

		player VisionSetNakedForPlayer( level.lvl_visionset, 1.0 );
		player EnableWeapons();
		player ShowViewModel();
		wait 0.5;

		HudItemsShow();
		player EnableOffhandWeapons();
		player FreezeControls( false );
	}

	player.is_controlling_UAV = undefined;

	level.uavTargetEnt = undefined;
}

ExitFromCamera_UAV( player, reasonIsPain )
{
	DrawTargetsEnd();
	text_TitleFadeout();
	text_NoticeFadeout();
	player VisionSetNakedForPlayer( level.VISION_BLACK, 0.25 );
	player VisionSetThermalForPlayer( level.VISION_BLACK, 0.25 );
	if ( IsDefined( level.uav_is_destroyed ) )
		player thread staticEffect( .5 );
	wait 0.15;

	wait 0.35;

	text_TitleDestroy();
	text_NoticeDestroy();
	player Unlink();
	player VisionSetThermalForPlayer( level.visionThermalDefault, 0 );

	maps\_load::thermal_EffectsOff();
	player ThermalVisionOff();

	if ( IsDefined( player.fov_is_altered ) )
		SetSavedDvar( "cg_fov", 65 );

	if ( IsDefined( level.uav ) )
	{
		if ( is_specialop() )
		{
			level.uav ShowOnClient( self );
		}
		else
		{
			level.uav Show();
		}
	}

	if ( reasonIsPain )
	{
		//fast switch back - go right to weapon
		player SwitchBackToMainWeaponFast();
		player FreezeControls( true );
		wait 0.15;
		player VisionSetNakedForPlayer( level.lvl_visionset, 0.4 );
		player EnableWeapons();
		player ShowViewModel();
		wait 0.10;

		HudItemsShow();
		player EnableOffhandWeapons();
		player FreezeControls( false );
	}
	else
	{
		//slow switch back - show laptop, etc
		player FreezeControls( true );
		wait 0.05;
		player VisionSetNakedForPlayer( level.lvl_visionset, 0.75 );
		player EnableWeapons();
		player ShowViewModel();
		wait 0.5;

		HudItemsShow();
		player SwitchBackToMainWeapon();
		player EnableOffhandWeapons();
		player FreezeControls( false );
	}

	player.is_controlling_UAV = undefined;

	level.uavTargetEnt = undefined;
	return;
}


WaitForAttackCommand( player )
{
	// I'd like to use GetCommandFromKey to make this "proper" incase of different keybindings
	// but it's not mp friendly...
//	dpad_left = GetCommandFromKey( "DPAD_LEFT" );
//	dpad_left = GetCommandFromKey( "BUTTON_Y" );
//	dpad_left = GetCommandFromKey( "BUTTON_B" );

//	player NotifyOnPlayerCommand( "abort_remote_missile", "+actionslot 3" ); 		// DPad Left
	player NotifyOnPlayerCommand( "abort_remote_missile", "weapnext" );				// BUTTON_Y
	player NotifyOnPlayerCommand( "abort_remote_missile", "+stance" );				// BUTTON_B

	player NotifyOnPlayerCommand( "launch_remote_missile", "+attack" );				// BUTTON_RTRIG

	player thread wait_for_other();
	player thread wait_for_command_thread( "abort_remote_missile", "abort" );
	player thread wait_for_command_thread( "launch_remote_missile", "launch" );

	player waittill( "remote_missile_attack", val );

	if ( val == "launch" )
	{
		return true;
	}
	else
	{
		return false;
	}
}

wait_for_command_thread( msg, val )
{
	self endon( "remote_missile_attack" );
	self waittill( msg );

	self notify( "remote_missile_attack", val );
}

wait_for_other()
{
	self endon( "remote_missile_attack" );

	for ( ;; )
	{
		wait( 0.05 );
		if ( self.took_damage )
		{
			break;
		}

		if ( !flag( "uav_enabled" ) )
		{
			break;
		}

		if ( IsDefined( level.uav_is_destroyed ) )
		{
			break;
		}
	}

	self notify( "remote_missile_attack", "abort" );
}


HudItemsHide()
{
	if ( level.players.size > 0 )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if( isdefined( level.players[ i ].using_uav ) && level.players[ i ].using_uav )
				setdvar( "ui_remotemissile_playernum", (i+1) ); // 0 = no uav, 1 = player1, 2 = player2
		}
	}
	else
	{
		SetSavedDvar( "compass", "0" );
		SetSavedDvar( "ammoCounterHide", "1" );
		SetSavedDvar( "actionSlotsHide", "1" );
	}
}


HudItemsShow()
{
	if( level.players.size > 0 )
	{
		setdvar( "ui_remotemissile_playernum", 0 ); // 0 = no uav, 1 = player1, 2 = player2
	}
	else
	{
		SetSavedDvar( "compass", "1" );
		SetSavedDvar( "ammoCounterHide", "0" );
		SetSavedDvar( "actionSlotsHide", "0" );
	}
}


FireMissileFromUAVPlayer( player )
{
	Earthquake( 0.4, 1, level.uavRig.origin, 5000 );

	org = level.uavRig.origin;
	playerAngles = player GetPlayerAngles();
	forward = AnglesToForward( playerAngles );
	right = AnglesToRight( playerAngles );
	start = org + ( right * 700.0 ) + ( forward * -300.0 );
	end = start + forward * 10.0;

	if ( IsDefined( level.remote_missile_snow ) )
	{
		missile = MagicBullet( "remote_missile_snow", start, end, player );
	}	
	else 
	{
		if ( IsDefined( level.remote_missile_invasion ) )
			missile = MagicBullet( "remote_missile_invasion", start, end, player );
		else
			missile = MagicBullet( "remote_missile", start, end, player );
	}

	thread NotifyOnMissileDeath( missile );
	return missile;
}

setup_remote_missile_target()
{
	if ( !isdefined( level.remote_missile_targets ) )
		level.remote_missile_targets = [];

	level.remote_missile_targets[ level.remote_missile_targets.size ] = self;


	if ( IsDefined( level.player.draw_red_boxes ) && !isdefined( level.uav_is_destroyed ) )
		self draw_target();

	self waittill( "death" );

	if ( !isdefined( self ) )
		return;

	if ( IsDefined( self.has_target_shader ) )
	{
		self.has_target_shader = undefined;
		Target_Remove( self );
	}
	level.remote_missile_targets = array_remove( level.remote_missile_targets, self );
}

DrawTargetsStart()
{
	level.player.draw_red_boxes = true;
	level endon( "uav_destroyed" );
	level endon( "draw_target_end" );
	//level.player ThermalVisionFOFOverlayOn();
	targets_per_frame = 4;
	targets_drawn = 0;
	time_between_updates = .05;

	if ( !isdefined( level.remote_missile_targets ) )
		return;

	foreach ( tgt in level.remote_missile_targets )
	{
		if ( IsAlive( tgt ) )
		{
			tgt draw_target();
			targets_drawn++;
			if ( targets_drawn >= targets_per_frame )
			{
				targets_drawn = 0;
				wait time_between_updates;
			}
		}
		else
		{
			level.remote_missile_targets = array_remove( level.remote_missile_targets, tgt );
		}
	}
}


draw_target()
{
	self.has_target_shader = true;

	if ( IsDefined( self.helicopter_predator_target_shader ) )
	{
		Target_Set( self, ( 0, 0, -96 ) );
	}
	else
	{
		Target_Set( self, ( 0, 0, 64 ) );
	}

	if ( IsAI( self ) )
	{
		Target_SetShader( self, "remotemissile_infantry_target" );
	}
	else if ( IsPlayer( self ) )// Make sure you add the player to the level.remote_missile_targets before use
	{
		Target_SetShader( self, "hud_fofbox_self_sp" );
	}
	else
	{
		Target_SetShader( self, "veh_hud_target" );
	}

	// There is an order of execution issue, which is why this is commented out.
	// If player 2 ( level.players[ 1 ] ) runs the Target_ShowToPlayer() last, then player 1 will be able
	// to see the targets.
	// So, the work around is to figure out who is controlling the UAV, then call to Target_ShowToPlayer() 
	// before Target_HideFromPlayer()
//	foreach( player in level.players )
//	{
//		if( IsDefined( player.is_controlling_UAV ) && player.is_controlling_UAV )
//			Target_ShowToPlayer( self, player );
//		else
//			Target_HideFromPlayer( self, player );
//	}

	uav_controller = undefined;
	non_uav_controller = undefined;

	foreach ( player in level.players )
	{
		if ( IsDefined( player.is_controlling_UAV ) && player.is_controlling_UAV )
		{
			uav_controller = player;
		}
		else
		{
			non_uav_controller = player;
		}
	}

	Target_ShowToPlayer( self, uav_controller );

	if ( IsDefined( non_uav_controller ) )
	{
		Target_HideFromPlayer( self, non_uav_controller );
	}
}


DrawTargetsEnd()
{
	level notify( "draw_target_end" );
	//level.player ThermalVisionFOFOverlayOff();
	waittillframeend;// was colliding with self waittill death which also removes the target
	level.player.draw_red_boxes = undefined;
	if ( IsDefined( level.remote_missile_targets ) )
	{
		foreach ( tgt in level.remote_missile_targets )
		{
			if ( !isdefined( tgt ) )
			{
				level.remote_missile_targets = array_remove( level.remote_missile_targets, tgt );
			}
			if ( IsDefined( tgt ) )
			{
				if ( IsDefined( tgt.has_target_shader ) )
				{
					tgt.has_target_shader = undefined;
					Target_Remove( tgt );
				}
			}
		}
	}
}


SwitchBackToMainWeapon()
{
	return SwitchBackToMainWeapon_internal( ::_switcher );
}

SwitchBackToMainWeaponFast()
{
	return SwitchBackToMainWeapon_internal( ::_switcherNow );
}

_switcher( weapName )
{
	self SwitchToWeapon( weapName );
}

_switcherNow( weapName )
{
	self SwitchToWeaponImmediate( weapName );
}

SwitchBackToMainWeapon_internal( func )
{
	if ( self ent_flag_exist( "coop_downed" ) && self ent_flag( "coop_downed" ) )
	{
		return;
	}

	//"primary", "offhand", "item", "altmode", and "exclusive".
	weapons = self GetWeaponsList( "primary", "altmode" );
	foreach ( weapon in weapons )
	{
		if ( self.last_weapon == weapon )
		{
			self [[ func ]]( self.last_weapon );
			return;
		}
	}

	if ( weapons.size > 0 )
		self [[ func ]]( weapons[ 0 ] );
}


staticEffect( duration )
{
	org = Spawn( "script_origin", ( 0, 0, 1 ) );
	org.origin = self.origin;
	org PlaySound( "predator_drone_static", "sounddone" );

	static = NewClientHudElem( self );
	static.horzAlign = "fullscreen";
	static.vertAlign = "fullscreen";
	static SetShader( "ac130_overlay_grain", 640, 480 );

	wait( duration );

	static Destroy();

	wait( 3 );

	org StopSounds();
	wait( 1 );
	org Delete();
}