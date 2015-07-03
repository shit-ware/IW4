#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_slowmo_breach;
#include maps\af_caves_code;
#include maps\_vehicle;
#include maps\_riotshield;
#using_animtree( "generic_human" );

main_af_caves_backhalf_preload()
{
	//thread destructible_management();
	PreCacheShellShock( "af_cave_collapse" );
	PreCacheItem( "hellfire_missile_af_caves_end" );
	PreCacheModel( "weapon_rpd_MG_Setup" );
	PreCacheItem( "m4_grenadier" );
	PreCacheModel( "com_computer_keyboard_obj" );
	
	level.overlookDudesDead = 0;
	level.ledgeKillfirmFinal = false;
	level.ledgeKillfirm = 0;
	level.ledgeEnemiesKilledByPlayer = 0;
	level.riotshields = GetEntArray( "riotshield", "targetname" );
	level.priceLedgeHelpCooldown = 2; //seconds you have to wait since the last time Price killed an enemy to give him super accuracy
	level.riotShieldInstructed = false;
	level.aColornodeTriggersBackhalf = [];
	level.gettingflankednaggiven = false;
	trigs = GetEntArray( "trigger_multiple", "classname" );
	foreach ( trigger in trigs )
	{
		if ( ( IsDefined( trigger.script_noteworthy ) ) && ( GetSubStr( trigger.script_noteworthy, 0, 19 ) == "colornodes_backhalf" ) )
			level.aColornodeTriggersBackhalf = array_add( level.aColornodeTriggersBackhalf, trigger );
	}
	
	setDvarIfUninitialized( "caves_fire", "1" );
	
	flag_init( "can_talk" );
	flag_set( "can_talk" );
	
	//ledge
	flag_init( "ledge_sequence_dialogue_over" );
	flag_init( "shephered_ledge_dialogue_starting" );
	flag_init( "shephered_ledge_dialogue_done" );
	
	//overlook
	flag_init( "unload_overlook_dudes" );
	flag_init( "overlook_dudes_decimated" );
	
	//skylight
	flag_init( "unload_skylight_dudes" );
	flag_init( "smoke_thrown" );
	flag_init( "price_has_given_flank_hint" );
	flag_init( "stop_smoke" );
	
	//Breach
	flag_init( "start_breach_nags" );
	flag_init( "breach_door_closed" );
	flag_init( "control_room_breached" );
	flag_init( "control_room_explosion" );
	flag_init( "control_room_getting_breached" );
	flag_init( "control_room_door_opened" );
	flag_init( "control_room_doors_closed" );
	flag_init( "keyboard_activated" );
	flag_init( "player_detonated_explosives" );
	flag_init( "price_at_the_keyboard" );
	
	//Airstrip
	flag_init( "start_airstrip_aftermath_fx" );
	flag_init( "end_cave_collapse" );
	flag_init( "player_escaped" );
	flag_init( "danger_close_dialogue_start" );
	flag_init( "danger_close_dialogue_end" );
	flag_init( "price_falling_back" );
	flag_init( "danger_close_moment_over" );
	flag_init( "danger_close_last_missile_has_hit" );
	flag_init( "unload_airstrip_blackhawk_dudes" );
	
	//objectives
	flag_init( "obj_ledge_traverse_given" );
	flag_init( "obj_ledge_traverse_complete" );
	flag_init( "obj_overlook_to_skylight_given" );
	flag_init( "obj_overlook_to_skylight_complete" );
	flag_init( "obj_breach_given" );
	flag_init( "obj_breach_complete" );
	flag_init( "obj_door_controls_given" );
	flag_init( "obj_door_controls_complete" );
	flag_init( "obj_escape_given" );
	flag_init( "obj_escape_complete" );
	flag_init( "obj_hummer_given" );
	flag_init( "obj_hummer_complete" );
	flag_init( "obj_hummer_gunner_given" );
	flag_init( "obj_hummer_gunner_complete" );
	flag_init( "obj_level_end_given" );
	flag_init( "obj_level_end_complete" );
}

main_af_caves_backhalf_postload()
{
	camo_right_damaged = getentarray( "camo_right_damaged", "targetname" );
	camo_left_damaged = getentarray( "camo_left_damaged", "targetname" );
	array_thread( camo_right_damaged, ::hide_entity );
	array_thread( camo_left_damaged, ::hide_entity );
	
	rock_rubble1 = GetEnt( "rock_rubble1", "targetname" );
	rock_rubble1 NotSolid();
	rock_rubble1 Hide();
	rock_rubble1 ConnectPaths();

	netting_destroyed = GetEntArray( "netting_destroyed", "targetname" );
	foreach ( destroyed_piece in netting_destroyed )
		destroyed_piece Hide();
	
	//
	generic_damage_triggers = GetEntArray( "generic_damage", "targetname" );
	array_thread( generic_damage_triggers,::generic_damage_triggers_think );
	//dialogue
	backhalf_dialogue();
	
	//vehicles
	aVehicleSpawners = maps\_vehicle::_getvehiclespawnerarray();
	array_thread( aVehicleSpawners, ::add_spawn_function, ::vehicle_think );
	array_thread( GetVehicleNodeArray( "plane_sound", "script_noteworthy" ), maps\_mig29::plane_sound_node );
	array_thread( GetVehicleNodeArray( "uav_sound", "script_noteworthy" ), maps\_ucav::plane_sound_node );
	array_thread( GetVehicleNodeArray( "fire_missile", "script_noteworthy" ), maps\_ucav::fire_missile_node );
	
	//Ledge	
	array_spawn_function_targetname( "hostiles_ledge_fight", ::AI_ledge_hostiles_think );
	array_spawn_function_noteworthy( "ledge_prone_guy", ::AI_ledge_prone_guy_think );
	
	
	//Overlook
	array_spawn_function_noteworthy( "overlook_heli_fastropers", ::AI_overlook_heli_fastropers_think );
	
	//Skylight
	array_spawn_function_noteworthy( "skylight_heli_fastropers", ::AI_skylight_heli_fastropers_think );
	array_spawn_function_noteworthy( "riotshield_flanker", ::AI_riotshield_flanker_think );
	array_spawn_function_noteworthy( "shotgun_flanker", ::AI_shotgun_flanker_think );
	
	//array_spawn_function_noteworthy( "riotshield_flanker_long", ::AI_riotshield_flanker_think, "longSprint" );

	//Control Room		
	//array_spawn_function_noteworthy( "flashlight", ::attach_flashlight );
	
	//Airstrip
	array_spawn_function_noteworthy( "airstrip_littlebird_hostiles", ::AI_airstrip_littlebird_hostiles_think );
	array_spawn_function_noteworthy( "airstrip_heli_fastropers", ::AI_airstrip_heli_fastropers_think );
	array_spawn_function_targetname( "ambient_airstrip", ::AI_ambient_airstrip_think );
	array_spawn_function_targetname( "airstrip_runners", ::AI_airstrip_runners_think );
	array_spawn_function_noteworthy( "ignored", ::AI_ignored_think );
	
	littlebird_airstrip = GetEnt( "littlebird_airstrip", "targetname" );
	littlebird_airstrip thread add_spawn_function( ::littlebird_airstrip_think );

	blackhawk_airstrip = GetEnt( "blackhawk_airstrip", "targetname" );
	blackhawk_airstrip thread add_spawn_function( ::blackhawk_airstrip_think );
	
	thread fx_management();
	

	
	
	//thread debug();
}

AA_backhalf_init()
{
	thread AA_ledge_init();

}

/****************************************************************************
    LEDGE FIGHT
****************************************************************************/ 
AA_ledge_init()
{
	flag_wait( "steamroom_halfway_point" );
	level.spawnerCallbackThread = ::AI_think;
	thread AAA_sequence_ledge_to_cave();
	thread dialogue_ledge_to_cave();
	thread obj_ledge_traverse();
	thread music_ledge_to_breach();

	flag_wait( "obj_ledge_traverse_complete" );
	thread AA_overlook_init();
}

music_ledge_to_breach()
{
	level endon( "control_room_explosion" );

	flag_wait( "player_clear_steamroom" );
	MusicStop();
	time = musicLength( "af_caves_goingloud" );
	while ( !flag( "control_room_explosion" ) )
	{
		MusicPlayWrapper( "af_caves_goingloud" );
		wait( time );
		//wait( 196 );
		music_stop( 1 );
		wait( 1.1 );
	}
}

AAA_sequence_ledge_to_cave()
{
	//to do ....remove door opening here, will be in Sean's script
	//thread steamroom_door_full_open();

	//flag_wait( "player_approaching_steamroom_exit" );
	flag_wait( "steamroom_done" );// SRS changed to a flag I can control in script

	turn_off_stealth();
	level.price.goalvolume = 64;
	level.price PushPlayer( false );
	level.price.pathrandompercent = 50;
	level.price enable_ai_color();
	level.price thread force_weapon_when_player_not_looking( "m4_grenadier" );

	triggersEnable( "colornodes_backhalf_ledge_start", "script_noteworthy", true );
	triggersEnable( "colornodes_backhalf_ledge", "script_noteworthy", true );
	activate_trigger_with_noteworthy( "colornodes_backhalf_ledge_start" );

	/*-----------------------
	CANYON VEHICLES
	-------------------------*/	
	thread convoy_loop( "canyon_convoy", "control_room_breached", 1.5, 2.2 );
	//flag_wait( "player_approaching_steamroom_exit" );  // SRS this flag wasn't doing anything since it was being checked earlier in the thread
	air_convoy_ledge = spawn_vehicles_from_targetname_and_drive( "air_convoy_ledge" );

	//get overlook fastropers ready
	thread blackhawk_overlook_rappel_think();

	flag_wait( "player_clear_steamroom" );

	thread autosave_by_name( "ledge_start" );
	zodiacs_canyon_start = spawn_vehicles_from_targetname_and_drive( "zodiacs_canyon_start" );
	zodiacs_canyon = spawn_vehicles_from_targetname_and_drive( "zodiacs_canyon" );

	flag_wait( "player_ledge_stairs_01" );
	level.price.ignoreme = true;
	level.price.IgnoreRandomBulletDamage = true;
	thread price_has_awesome_accuracy_while_player_is_using_shield( "ledge_gunners_dead" );
	uav_bridge_01 = spawn_vehicle_from_targetname_and_drive( "uav_bridge_01" );
	uav_bridge_01 thread uav_bridge_01_think();

	flag_wait( "player_ledge_corner_01" );
	thread spawn_vehicles_from_targetname_and_drive_on_flag( "jets_canyon_01", "shephered_ledge_dialogue_done" );

	flag_wait( "player_crossed_bridge" );
	level.priceLedgeHelpCooldown = .1;		// let Price be accurate more ofthen now that we're closer

	flag_wait( "player_ledge_last_stairs" );
	level.price.ignoreme = false;
	level.price.IgnoreRandomBulletDamage = false;

	flag_wait( "player_inside_overlook" );
	level.player notify( "done_with_ledge_sequence" );
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	level.price set_battlechatter( true );
	thread overlook_autosaves();
}

price_has_awesome_accuracy_while_player_is_using_shield( sFlagToEndOn )
{
	level.player endon( "death" );
	level.price endon( "death" );
	level.price.baseaccuracy = .1;
	level.price.old_baseaccuracy = level.price.baseaccuracy;
	level.lasttimePriceKilledEnemy = GetTime();
	wait( 0.05 );
	while ( !flag( sFlagToEndOn ) )
	{
		if ( ( player_is_using_riot_shield() ) && ( price_hasnt_killed_a_fool_in_the_last_few_seconds( level.priceLedgeHelpCooldown ) ) )
		{
			level.price.baseaccuracy = 50;
		}
		else
		{
			level.price.baseaccuracy = level.price.old_baseaccuracy;
		}
		//level.player waittill_either_or_timeout( "weapon_change", "done_with_ledge_sequence" );
		wait( 2 );
	}

	//make price have average accuracy
	level.price.baseaccuracy = 2;
}

price_hasnt_killed_a_fool_in_the_last_few_seconds( iSeconds )
{
	//only give Price awesome accuracy if it's been at lease XX seconds since his last kill
	currentTime = GetTime();
	timeElapsed = currentTime - level.lasttimePriceKilledEnemy;
	if ( currentTime == level.lasttimePriceKilledEnemy )
		return false;
	else if ( timeElapsed > ( iSeconds * 1000 ) )
		return true;
	else
		return false;
}

AI_ledge_prone_guy_think()
{
	self endon( "death" );
	self.ignoreme = true;
	flag_wait( "player_ledge_bridge_crossing" );
	self.ignoreme = false;
	
}

AI_ledge_hostiles_think()
{
	self.DropWeapon = false;
	baseaccuracyFactor = undefined;

	switch( level.gameSkill )
	{
		case 0:// easy
			doorFlashChanceFactor = 1;
			baseaccuracyFactor = 1000;
			break;
		case 1:// regular
			doorFlashChanceFactor = 1.3;
			baseaccuracyFactor = 1000;
			break;
		case 2:// hardened
			doorFlashChanceFactor = 1.5;
			baseaccuracyFactor = 1000;
			break;
		case 3:// veteran
			doorFlashChanceFactor = 1.5;
			baseaccuracyFactor = 1000;
			break;
	}
	self.interval = 0;
	self.ignoresuppression = true;
	self.suppressionwait = 0;
	self.disableBulletWhizbyReaction = true;
	self.baseaccuracy = self.baseaccuracy * baseaccuracyFactor;
	self.accuracy = self.accuracy * baseaccuracyFactor;
	while ( IsDefined( self ) )
	{
		self waittill( "death", attacker );

		//Final killfirm if all dead
		if ( flag( "ledge_gunners_dead" ) )
		{
			//Captain Price	We're clear. Move in.
			if ( ( !flag( "player_inside_overlook" ) ) && ( level.ledgeKillfirmFinal == false ) )
			{
				level.ledgeKillfirmFinal = true;
				radio_dialogue( "riot_killfirm_final" );
			}
		}

		if ( ( IsDefined( attacker ) ) && ( attacker == level.price ) )
		{
			if ( ( flag( "can_talk" ) ) && ( !flag( "ledge_gunners_dead" ) ) )
			{

				wait( 0.05 );


				//Otherwise, generic killfirm

				//Good night
				//He's down
				//Got 'em
				//Got one.
				flag_clear( "can_talk" );
				if ( level.ledgeKillfirm == 3 )
					level.ledgeKillfirm = 0;
				radio_dialogue( "riot_killfirm_0" + level.ledgeKillfirm );
				level.ledgeKillfirm++;
				flag_set( "can_talk" );
			}
			level.lasttimePriceKilledEnemy = GetTime();
		}
		else if ( ( IsDefined( attacker ) ) && ( IsPlayer( attacker ) ) )
		{
			level.ledgeEnemiesKilledByPlayer++;
			if ( level.ledgeEnemiesKilledByPlayer > 4 )
			{
				thread maps\_spawner::kill_spawnerNum( 71 );
			}
		}

	}
}

dialogue_ledge_to_cave()
{
	//flag_wait( "player_approaching_steamroom_exit" );
	flag_wait( "steamroom_done" );// SRS changed to a script controlled flag

	flag_set( "obj_ledge_traverse_given" );

	//Shadow Company HQ	Avatar One this is Oxide, we've lost contact with multiple squads near the steam room. I need a camera sweep of the catwalk, over.		stealth wiretap
	//radio_dialogue( "afcaves_schq_catwalk" );

	//Shadow Company 4	Roger that Oxide, UAV is online. Standby.		stealth wiretap
	//radio_dialogue( "afcaves_sc4_uavonline" );

	flag_wait( "player_clear_steamroom" );
	flag_wait( "steamroom_ambush_finish_dialogue_ended" );
	//flag_wait( "player_ledge_riotshields" );

	////Captain Price	Grab a riot shield...we'll need cover out here.
	radio_dialogue( "afcaves_pri_pickupriotsheild" );

	delayThread( 2, ::dialogue_nag_riotshield, "ledge_gunners_dead", "player_crossed_bridge" );
	
	wait( 1 );
	
	flag_wait( "can_talk" );

	flag_clear( "can_talk" );

	flag_set( "shephered_ledge_dialogue_starting" );
	
	//Shadow Company 4	Oxide, Avatar One. We have unauthorized personnel on the catwalk. I repeat, we have unauthorized personnel on the catwalk.
	radio_dialogue( "afcaves_sc4_gettingthis" );
	
	flag_set( "shephered_ledge_dialogue_done" );
	
	flag_set( "can_talk" );

	/*-----------------------
	LEDGE GUNNERS DEAD
	-------------------------*/	
	flag_wait( "ledge_gunners_dead" );
	level.player notify( "done_with_ledge_sequence" );

	wait( 3 );
	flag_set( "ledge_sequence_dialogue_over" );

}

dialogue_nag_riotshield( sFlagToEndOn1, sFlagToEndOn2 )
{
	flag_wait( "player_ledge_stairs_01" );
	iRiotShieldPickupHintNumber = 0;
	iRiotShieldCrouchHintNumber = 0;
	iRiotShieldSwitchHintNumber = 0;
	iRiotShieldMoveUpNumber = 0;
	iCatWalkChatterNumber = 0;
	while ( true )
	{
		if ( ( flag( sFlagToEndOn1 ) ) || ( flag( sFlagToEndOn2 ) ) )
			return;

		//No riot shield, but near a pickup
		if ( ( !player_has_riot_shield() ) && ( player_is_near_a_riot_shield_pickup() ) )
		{
			if ( flag( "can_talk" ) )
			{
				flag_clear( "can_talk" );
				if ( iRiotShieldPickupHintNumber == 3 )
					iRiotShieldPickupHintNumber = 0;
				//Captain Price	Soap, grab a riot shield and lead the way. I'll take care of any shooters!
				//Captain Price	11	5	Soap, grab a riot shield. We'll need all the cover we can get.
				//Grab a riot shield. We're completely exposed out here.
				radio_dialogue( "pickupriotsheild_0" + iRiotShieldPickupHintNumber );
				iRiotShieldPickupHintNumber++;
				flag_set( "can_talk" );
				level.player waittill_notify_or_timeout( "weapon_change", 5 );
			}
		}

		//Player has the shield
		else if ( player_has_riot_shield() )
		{
			//Have we given the general instruction yet?
			if ( level.riotShieldInstructed == false )
			{

				if ( flag( "can_talk" ) )
				{
					flag_clear( "can_talk" );
					//Captain Price	11	3	Take point with the riot shield. I'll take care of any resistance.
					radio_dialogue( "afcaves_pri_takepoint2" );
					level.riotShieldInstructed = true;
					flag_set( "can_talk" );
				}
			}
			//Player has it, but is not using it
			else if ( !player_is_using_riot_shield() )
			{
				if ( flag( "can_talk" ) )
				{
					flag_clear( "can_talk" );
					if ( iRiotShieldSwitchHintNumber == 2 )
						iRiotShieldSwitchHintNumber = 0;
					//Switch to the shield, we're exposed out here!
					//Bring up the riot shield, Soap!
					//Give us some cover with that riot shield, Soap!
					radio_dialogue( "switchriotsheild_0" + iRiotShieldSwitchHintNumber );
					iRiotShieldSwitchHintNumber++;
					flag_set( "can_talk" );
				}
			}
			//Player is using it, but not crouched
			else if ( !player_is_crouched() )
			{
				if ( flag( "can_talk" ) )
				{

					flag_clear( "can_talk" );
					if ( iRiotShieldCrouchHintNumber == 2 )
						iRiotShieldCrouchHintNumber = 0;
					//Captain Price	11	3	Stay low with that shield so I can get a clean shot
					//Captain Price	11	3	Keep low with that shield.
					//Crouch down with that shield, Soap! I'll take care of the shooters.
					radio_dialogue( "crouchriotsheild_0" + iRiotShieldCrouchHintNumber );
					iRiotShieldCrouchHintNumber++;
					flag_set( "can_talk" );
				}
			}
			else if ( level.riotShieldInstructed == true )
			{
				if ( ( iCatWalkChatterNumber < 3 ) && ( flag( "can_talk" ) ) )
				{
					//Shadow Company 5	Oxide, Disciple Nine, we've got hostile contact approximately 50 meters from the nest, over.		stealth wiretap
					//Shadow Company HQ	All personnel - be advised, we have two enemy foot-mobiles on the catwalk heading to the crow's nest.		stealth wiretap
					//Shadow Company HQ	Terminate with extreme prejudice.
					flag_clear( "can_talk" );
					radio_dialogue( "catwalk_enemy_chatter_0" + iCatWalkChatterNumber );
					iCatWalkChatterNumber++;
					if ( iCatWalkChatterNumber == 0 )
					{
						radio_dialogue( "catwalk_enemy_chatter_0" + iCatWalkChatterNumber );
						iCatWalkChatterNumber++;
					}
					flag_set( "can_talk" );
				}
				else
				{
					if ( flag( "can_talk" ) )
					{
	
						flag_clear( "can_talk" );
						if ( iRiotShieldMoveUpNumber == 1 )
							iRiotShieldMoveUpNumber = 0;
						//Captain Price	Move up.
						//Captain Price	Take point with the shield and draw their fire. I'll cover you.
						radio_dialogue( "riotsheildmove_0" + iRiotShieldMoveUpNumber );
						iRiotShieldMoveUpNumber++;
						flag_set( "can_talk" );
					}
				}
			}
		}
		level.player waittill_notify_or_timeout( "weapon_change", 1 );
		wait( 1 );
	}
}

uav_bridge_01_think()
{
	while ( IsDefined( self ) )
		wait( 2 );
	uav_bridge_02 = spawn_vehicle_from_targetname_and_drive( "uav_bridge_02" );
}

player_is_crouched()
{
	if ( level.player GetStance() == "crouch" )
		return true;
	else
		return false;
}

player_is_using_riot_shield()
{
	if ( !player_has_riot_shield() )
		return false;
	else
	{
		currentWeapon = level.player GetCurrentWeapon();
		if ( currentWeapon == "riotshield" )
			return true;
		else
			return false;
	}
}

player_has_riot_shield()
{
	weapons = level.player GetWeaponsListAll();
	if ( !isdefined( weapons ) )
		return false;
	foreach ( weapon in weapons )
	{
		if ( IsSubStr( weapon, "riotshield" ) )
			return true;
	}
	return false;
}

player_is_near_a_riot_shield_pickup()
{
	playerDistSquared = 1024 * 1024;
	foreach ( weapon in level.riotshields )
	{
		if ( !isdefined( weapon ) )
			continue;
		if ( DistanceSquared( weapon.origin, level.player.origin ) < playerDistSquared )
			return true;
	}

	return false;
}

/****************************************************************************
    OVERLOOK FIGHT
****************************************************************************/ 

AA_overlook_init()
{
	thread AAA_sequence_overlook_to_breach();
	thread dialogue_overlook_to_breach();
	thread obj_overlook_to_skylight();

	flag_wait( "player_enter_skylight" );
	thread AA_breach_init();
}

AAA_sequence_overlook_to_breach()
{
	flag_wait( "obj_ledge_traverse_complete" );
	triggersEnable( "colornodes_backhalf_overlook_to_breach", "script_noteworthy", true );

	level.price cqb_walk( "off" );
	level.price.neverEnableCQB = true;
	level.price.sprint = undefined;
	level.price.fixednodesaferadius = 1024;
	level.fixednodesaferadius_default = 1024;

	/*-----------------------
	OVERLOOK CAVE
	-------------------------*/	
	//get fastropers ready for skylight area
	blackhawk_skylight_01 = spawn_vehicle_from_targetname_and_drive( "blackhawk_skylight_01" );
	rappelSoundOrg = blackhawk_skylight_01.origin;
	
	/*-----------------------
	SKYLIGHT AREA - FASTROPERS
	-------------------------*/	
	flag_wait( "player_enter_skylight" );
	
	//thread overlook_grenade_hints();
	flag_set( "unload_skylight_dudes" );
	
	/*-------------------------
	SKYLIGHT - MAKE ALL IN OVERLOOK SEEK THE PLAYER
	-------------------------*/	
	volume_overlook = GetEnt( "volume_overlook", "targetname" );
	aAI = volume_overlook get_ai_touching_volume( "axis" );
	array_thread( aAI, ::AI_player_seek );
	
	aSmokeOrgs = GetEntArray( "smoke_org_skylight", "targetname" );
	thread smoke_throw( aSmokeOrgs, "stop_smoke" );
	wait( 1 );
	flag_set( "smoke_thrown" );
	
	if ( isdefined( blackhawk_skylight_01 ) )
	{
		//Butcher Two roping into sector Papa Quebec!
		delaythread( 2,::play_sound_in_space, "afcaves_sc5_papaquebec", rappelSoundOrg );
	}
	
	thread dialougue_nag_smokefight();
	
	/*-----------------------
	SKYLIGHT AREA - CLEANUP
	-------------------------*/	
	flag_wait( "obj_overlook_to_skylight_complete" );
	
	
	if ( isdefined( blackhawk_skylight_01 ) )
	{
		skylight1_heli_depart = getstruct( "skylight1_heli_depart", "targetname" );
		blackhawk_skylight_01 thread vehicle_paths_then_delete( skylight1_heli_depart );
	}
}


//overlook_grenade_hints()
//{
//	if ( level.gameskill > 1 )
//		return;
//	level endon( "player_in_skylight_area" );
//	
//	thread player_grenade_usage_monitor();
//}
//
//player_grenade_usage_monitor()
//{
//	level endon( "player_in_skylight_area" );
//	level.player endon( "death" );
//	level endon( "player_used_flash" );
//	while ( true )
//	{
//		flag_wait_or_timeout( "player_used_flash", 120 );
//		if ( !flag( "player_used_flash" ) )
//		{
//			hint
//		}
//	}
//}

overlook_autosaves()
{
	thread overlook_to_skylight_autosaves_every_3_dudes();
	level endon( "player_in_skylight_area" );
	flag_wait( "overlook_dudes_dead" );
	thread autosave_by_name( "overlook_dudes_dead" );
}

overlook_to_skylight_autosaves_every_3_dudes()
{
	
	dudesKilled = 0;
	level endon( "player_in_skylight_area" );
	while( true )
	{
		level waittill( "player_killed_an_enemy" );
		dudesKilled++;
		if ( dudesKilled > 2 )
		{
			thread autosave_by_name( "overlook_timed_autosave" );
			dudesKilled = 0;
		}
	}
}

vehicle_paths_then_delete( node )
{
	if ( !isdefined( self) )
		return;
	self endon( "death" );
	self thread vehicle_paths( node );
	self waittill( "reached_dynamic_path_end" );
	self Delete();
}

dialogue_overlook_to_breach()
{
	flag_wait( "ledge_sequence_dialogue_over" );

	//Shadow Company HQ	Butcher One-Five, rendezvous at the nest and prepare to escort Gold Eagle to the LZ.
	radio_dialogue( "afcaves_schq_escourtgoldeagle" );
	
	//Captain Price	Gold Eagle must be Shepherd! We're running out of time, let's go!
	radio_dialogue( "afcaves_pri_mustbeshepherd" );
	
	flag_wait( "player_inside_overlook" );
	
	//Strategy nags
	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;
		
	wait( 10 );
	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;
	
	if( player_has_frags() )
	{
		//Captain Price	They're using shields! Throw some frags!	
		level.price dialogue_execute( "afcaves_pri_sheildsthrowfrags" );
	
		if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
			return;
		wait( 10 );
	}
	else if( player_has_flash() )
	{
		//Captain Price	They're using shields! Use flash grenades!	
		level.price dialogue_execute( "afcaves_pri_sheildsuseflash" );
	
		if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
			return;
		wait( 10 );
	}
	
	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;
		
	//Captain Price	Try to flank them!	
	level.price dialogue_execute( "afcaves_pri_trytoflank" );

	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;
	wait( 10 );
	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;

		
	//Captain Price	Soap! Hit them from the sides!	
	level.price dialogue_execute( "afcaves_pri_hitfromsides" );

	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;
	wait( 10 );
	if ( ( flag( "player_in_skylight_area" ) ) || ( flag( "overlook_dudes_decimated" ) ) )
		return;
		
	//Captain Price	Try to flank and hit them from the sides!	
	level.price dialogue_execute( "afcaves_pri_flankandhitsides" );
	
	//flag_wait( "unload_overlook_dudes" );
	//radio_dialogue( "afcaves_sc5_rapellingin" );
	
	// SRS we play this earlier now per steve.  maybe check a flag to see if we weren't able to play it earlier?
	//Shepherd	Backup priority items and burn the rest. Fire teams - just delay 'em until we're ready to pull out. 	
	//radio_dialogue( "afcaves_shp_burntherest" );

}

player_has_frags()
{
	if ( level.player GetWeaponAmmoStock( "fraggrenade" ) > 0 )
		return true;
	else
		return false;
}

player_has_flash()
{
	if ( level.player GetWeaponAmmoStock( "flash_grenade" ) > 0 )
		return true;
	else
		return false;
}

dialougue_nag_smokefight()
{
	while ( !flag( "player_in_skylight_area" ) )
		wait( 3 );
	
	thread autosave_by_name( "skylight" );
	//Captain Price	The're using thermal through the smoke!	
	level.price dialogue_execute( "afcaves_pri_usingthermal" );

	//Captain Price	Soap! They're digging in, Shepherd must be close! We have to break through!		
	level.price dialogue_execute( "afcaves_pri_moveright" );

	flag_set( "price_has_given_flank_hint" );

	wait( 5 );

	if ( ( flag( "player_going_around_skylight_flank" ) ) || ( flag( "player_on_other_side_skylight" ) ) || ( flag( "player_approaching_breach" ) ) )
	{
		flag_set( "stop_smoke" );
		return;
	}

	skylight_flanker = GetEnt( "skylight_flanker", "script_noteworthy" );
	skylight_flanker notify( "trigger", level.player );

	if ( flag( "can_talk" ) )
	{
		flag_clear( "can_talk" );
		//Captain Price	I'll draw their fire through the smoke! Watch for flanking routes!	
		level.price dialogue_execute( "afcaves_pri_drawfire" );
		flag_set( "can_talk" );
	}

	wait( 15 );

	if ( ( flag( "player_going_around_skylight_flank" ) ) || ( flag( "player_on_other_side_skylight" ) ) || ( flag( "player_approaching_breach" ) ) )
	{
		flag_set( "stop_smoke" );
		return;
	}

	if ( flag( "can_talk" ) )
	{
		flag_clear( "can_talk" );
		//Captain Price	Switching to thermal! Keep an eye on our flanks!
		level.price dialogue_execute( "afcaves_pri_switchingtotherm" );
		flag_set( "can_talk" );
	}
}

AI_overlook_heli_fastropers_think()
{
	//called from spawn func
	self endon( "death" );
	self.ignoreme = true;
	self waittill( "jumpedout" );
	self.ignoreme = false;
}


AI_think( guy )
{
	if ( guy.team == "axis" )
		guy thread AI_axis_death_think();
}

AI_axis_death_think()
{
	self waittill( "death", attacker );
	if ( ( isdefined( attacker ) ) && ( isplayer( attacker ) ) )	
		level notify( "player_killed_an_enemy" );
		
	if ( ( isdefined( self.script_deathflag ) ) && ( self.script_deathflag == "overlook_dudes_dead" ) )
	{
		level.overlookDudesDead++;
		if ( level.overlookDudesDead > 4 )
		{
			flag_set( "overlook_dudes_decimated" );
		}
	}
}

AI_skylight_heli_fastropers_think()
{
	//called from spawn func
	self endon( "death" );
	self.ignoreme = true;
	self waittill( "jumpedout" );
	self.ignoreme = false;
	if ( self.code_classname == "actor_enemy_riotshield" )
	{
		self riotshield_sprint_on();
		wait( RandomFloatRange( 4.8, 5.2 ) );
		self riotshield_sprint_off();
	}
}

AI_riotshield_flanker_think( longSprint )
{
	self endon( "death" );
	self.useChokePoints = false;
	//self.goalradius = 128;
	//self.script_moveoverride = 1;
	if ( self.code_classname == "actor_enemy_riotshield" )
	{
		self riotshield_sprint_on();
		wait( RandomFloatRange( 4.8, 5.2 ) );
		if ( IsDefined( longSprint ) )
		{
			wait( RandomFloatRange( 7, 8 ) );
		}
		self riotshield_sprint_off();
	}
}

AI_shotgun_flanker_think()
{
	self endon( "death" );
	self.goalradius = 64;

}

blackhawk_overlook_rappel_think()
{
	/*-----------------------
	OVERLOOK HELI
	-------------------------*/	
	blackhawk_overlook_rappel = spawn_vehicle_from_targetname_and_drive( "blackhawk_overlook_rappel" );
	blackhawk_overlook_rappel endon( "death" );

	/*-----------------------
	OVERLOOK HELI FASTROPERS
	-------------------------*/	
	flag_wait( "player_inside_overlook" );
	flag_set( "unload_overlook_dudes" );

	/*-----------------------
	OTHER AMBIENT BLACKHAWK
	-------------------------*/	
	blackhawk_overlook_01 = spawn_vehicle_from_targetname_and_drive( "blackhawk_overlook_01" );

	/*-----------------------
	OVERLOOK HELI FASTROPERS
	-------------------------*/	
	//heli takes off
	blackhawk_overlook_rappel waittill( "unloaded" );
	wait( 5 );
	
	if ( isdefined( blackhawk_overlook_rappel ) )
	{
		overlook_heli_depart = getstruct( "overlook_heli_depart", "targetname" );
		blackhawk_overlook_rappel thread vehicle_paths_then_delete( overlook_heli_depart );
	}
}

/****************************************************************************
    BREACH CONTROL ROOM
****************************************************************************/ 
AA_breach_init()
{
	thread AAA_sequence_breach_to_airstrip();
	thread breach_room_tvs();
	thread controlroom_sheppard_close_the_door();
	thread controlroom_breach_destruction();
	thread music_control_room();
	thread obj_breach();
	thread obj_door_controls();
	thread obj_escape();
	thread leftover_skylight_enemies_seek_player();
	thread dialogue_breach_to_airstrip();
	thread breach_nags();

	flag_wait( "obj_escape_complete" );
	thread AA_airstrip_init();
}

breach_room_tvs()
{
	flag_wait( "obj_door_controls_given" );
	CinematicInGame( "afcaves_countdown_hires" );

}

leftover_skylight_enemies_seek_player()
{
	level endon( "skylight_dudes_dead" );

	flag_wait( "player_enter_skylight" );

	flag_wait_either( "player_on_other_side_skylight", "player_has_flanked_skylight" );


	aAI = GetAIArray( "axis" );
	array_thread( aAI,::leftover_skylight_enemies_think );

}

leftover_skylight_enemies_think()
{
	self endon( "death" );
	volume_skylight_defend = getent( "volume_skylight_defend", "targetname" );
	volume_skylight_breach_hall = getent( "volume_skylight_breach_hall", "targetname" );
	
	//track the player when he is in their volume, otherwise, fight from the smoke volume
	
	while( true )
	{
		wait( 1 );
		if ( ( level.player istouching( volume_skylight_defend ) ) || ( level.player istouching( volume_skylight_breach_hall ) ) )
		{
			self thread AI_player_seek();
			level.price.baseaccuracy = 50;
		}
		else
		{
			self notify( "stop_seeking" );
			self SetGoalPos( self.origin );
			self SetGoalVolumeAuto( volume_skylight_defend );
			self.goalradius = 2048;
			level.price.baseaccuracy = 2;
		}
	}	
}

AAA_sequence_breach_to_airstrip()
{
	level endon( "mission failed" );

	flag_wait_either( "player_right_near_breach", "skylight_dudes_dead" );
	thread autosave_by_name( "breach" );

	flag_set( "stop_smoke" );
	flag_set( "obj_overlook_to_skylight_complete" );

	/*-----------------------
	SKYLIGHT - MAKE ALL IN SKYLIGHT SEEK THE PLAYER
	-------------------------*/	
	breach_safe_volume = GetEnt( "breach_safe_volume", "targetname" );
	aAI = breach_safe_volume get_ai_touching_volume( "axis" );
	array_thread( aAI, ::AI_player_seek );

	/*-----------------------
	PRICE HEADS TOWARDS BREACH
	-------------------------*/
	triggersEnable( "skylight_finished_colornodes", "script_noteworthy", true );
	activate_trigger_with_noteworthy( "skylight_finished_colornodes" );

	/*------------------------
	GUY CLOSES BREACH DOOR
	-------------------------*/
	flag_wait( "breach_door_closed" );
	level.slomoBasevision = "af_caves_indoors_breachroom";
	level.price.fixednodesaferadius = 64;
	level.fixednodesaferadius_default = undefined;

	triggersEnable( "colornodes_backhalf_breach_start", "script_noteworthy", true );
	activate_trigger_with_noteworthy( "colornodes_backhalf_breach_start" );

	/*-----------------------
	SETUP ROOM
	-------------------------*/	
	c4_packs = GetEntArray( "c4barrelPacks", "targetname" );
	array_thread( c4_packs, ::c4_packs_think );

	
	flag_wait( "control_room_getting_breached" );
	aAI = getaiarray( "axis" );
	array_thread( aAI,::breach_enemies_think );
	
	flag_wait( "control_room_breached" );
	level.player SetMoveSpeedScale( 1 );
	//control_room_runners = array_spawn( getentarray( "control_room_runners", "targetname" ), true );
	//array_thread( control_room_runners,::control_room_runners_think );
	thread c4_barrels();
	thread control_room_cleared_monitor();
	/*-----------------------
	AUTO DOOR CLOSES
	-------------------------*/	
	exitdoor_left = make_door_from_prefab( "exitdoor_left" );
	exitdoor_right = make_door_from_prefab( "exitdoor_right" );
	exitdoor_left.openangles = 90;
	exitdoor_right.openangles = -90;
	exitdoor_left.closeangles = -90;
	exitdoor_right.closeangles = 90;
	exitdoor_left thread control_door_close( "left" );
	exitdoor_right thread control_door_close( "right", "control_room_doors_closed" );

	flag_wait( "control_room_cleared" );
	
	
	thread price_control_room_think();

	
	/*-----------------------
	KEYBOARD OBJECTIVE
	-------------------------*/	
	flag_wait( "obj_door_controls_given" );
	thread escape_timer_invisible( 20 );

	keyboards = GetEntArray( "keyboard", "targetname" );
	array_thread( keyboards, ::keyboard_think );

	flag_wait( "keyboard_activated" );

	exitdoor_left thread control_door_open( "left" );
	exitdoor_right thread control_door_open( "right" );
	flag_set( "control_room_door_opened" );


	/*-----------------------
	PRE-EXPLOSION
	-------------------------*/	
	flag_wait( "player_approaching_exit_to_airstrip" );
	
	thread pre_self_destruct_explosions(); 

	node_price_escape_final = GetNode( "node_price_escape_final", "targetname" );
	level.price SetGoalNode( node_price_escape_final );
	
	/*-----------------------
	PLAYER ESCAPED
	-------------------------*/	
	flag_wait( "player_touching_cave_exit" );
	wait( .3 );
	kill_timer();
	flag_set( "player_escaped" );
}

breach_enemies_think()
{
	self endon( "death" );
	wait( .5 );
	self.health = 1;
	
	//only have extra guys on vet
	if ( level.gameskill < 3 )
	{
		if ( ( isdefined( self.script_noteworthy ) ) && ( self.script_noteworthy == "veteran" ) )
		{
			self delete();
		}
			
	}
	while( true )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		if ( ( isdefined( attacker ) ) && ( isplayer( attacker ) ) )
			self kill();
	}
	
}
	
price_control_room_think()
{
	flag_wait( "control_room_cleared" );
	//give price regular baseaccuracy in case it was jacked way up during skylight fight
	level.price.baseaccuracy = 2;
	
	thread autosave_now();
	
	level.price cqb_walk( "off" );
	level.price.neverEnableCQB = true;
	level.price PushPlayer( true );
	price_computer_node = getent( "price_computer_node", "targetname" );
	price_computer_node anim_reach_solo( level.price, "laptop_stand_idle_start" );
	
	thread price_keyboard_anim();

	//triggersEnable( "colornodes_backhalf_door_control", "script_noteworthy", true );
	//activate_trigger_with_noteworthy( "colornodes_backhalf_door_control" );
	
	level.price thread keyboard_sounds();
	flag_wait( "control_room_door_opened" );

	/*-----------------------
	DOOR OPENED, PRICE TAKES OFF
	-------------------------*/	
	level.price disable_ai_color();
	price_computer_node notify( "stop_idle" );
	level.price anim_stopanimscripted();
	node_price_escape_cover = GetNode( "node_price_escape_cover", "targetname" );
	level.price SetGoalNode( node_price_escape_cover );
}

price_keyboard_anim()
{
	price_computer_node = getent( "price_computer_node", "targetname" );
	level.price endon( "stop_loop" );
	while( !flag( "control_room_door_opened" ) )
	{
		price_computer_node thread anim_loop_solo( level.price, "laptop_stand_idle", "stop_idle" );
		level.price waittill( "nag_anim" );
		price_computer_node notify( "stop_idle" );
		price_computer_node anim_single_solo( level.price, "laptop_stand_yell" );
	}
}

keyboard_sounds()
{
	org = spawn( "script_origin", self.origin + ( 0, 0, 32 ) );
	org thread delete_on_flag( "control_room_door_opened" );
	org endon( "death" );
	level endon( "control_room_door_opened" );
	while( true )
	{
		self waittillmatch( "looping anim", "end" );
		org playsound( "scn_afcaves_enter_code_typing" );
	}
}

delete_on_flag( sFlag )
{
	self endon( "death" );
	flag_wait( sFlag );
	self StopSounds();
	wait( .1 );
	self delete();
}

control_room_cleared_monitor()
{
	flag_wait( "breach_room_guys_dead" );
	
	flag_set( "control_room_cleared" );
}

//control_room_runners_think()
//{
//	self endon( "death" );
//	self.health = 1;
//	self.disablelongdeath = 1;
//	self.ignoreme = true;
//	self.ignoreall = true;
//	self.goalradius = 64;
//	self cqb_walk( "off" );
//	self.neverEnableCQB = true;
//	flag_wait( "control_room_cleared" );
//	
//	control_room_volume = getent( "control_room_volume", "script_noteworthy" );
//	if ( !self istouching( control_room_volume ) )
//	{
//		self.diequietly = true;
//		self kill();
//	}
//	else
//	{
//		self.ignoreme = false;
//		self.ignoreall = false;
//		
//	}
//	aAI_to_delete = [];
//	aAI_to_delete[ 0 ] = self;
//	thread AI_delete_when_out_of_sight( aAI_to_delete, 256 );
//	wait( 2 );
//	self setgoalpos( self.origin );
//}
	
pre_self_destruct_explosions()
{
	level notify ( "pre_explosion_happening" );
	timesLooped = 0;
	while( true )
	{
		thread exploder( "escape_tunnel_pre_explosion" );
		thread play_sound_in_space( "af_caves_selfdestruct", level.player.origin );
		level.player PlayRumbleOnEntity( "damage_heavy" );
		
		if ( flag( "player_touching_cave_exit" ) )
			break;
		
		timesLooped++;
		if ( timesLooped > 6 )
		{
			level thread mission_failed_out_of_time();
			break;
		}
		
		if ( timesLooped == 1 )
		{
			Earthquake( .2, 1.75, level.player.origin, 1000 );
			wait( 1 );
		}
		else if ( timesLooped == 2 )
		{
			Earthquake( .3, 1.75, level.player.origin, 1000 );
			wait( 1.5 );
		}
		else if ( timeslooped == 5 )
		{
			exploder( "control_room_detonate" );
			Earthquake( .3, 1.75, level.player.origin, 1000 );
			wait( 1 );
		}
		else
		{
			Earthquake( .4, 1.75, level.player.origin, 1000 );
			wait( .75 );
		}

	}
}

keyboard_think()
{
	self glow();
	self MakeUsable();
	// Hold ^3&&1^7 to override the door lock.
	self SetHintString( &"AF_CAVES_USE_KEYBOARD" );

	self waittill( "trigger" );
	//self thread play_sound_in_space( "scn_afcaves_enter_code_typing" );
	keyboards = GetEntArray( "keyboard", "targetname" );
	array_notify( keyboards, "trigger" );
	self MakeUnusable();
	self stopGlow();

	if ( !flag( "keyboard_activated" ) )
		flag_set( "keyboard_activated" );
}

dialogue_breach_to_airstrip()
{
	flag_wait( "obj_overlook_to_skylight_complete" );
	flag_set( "obj_breach_given" );

	wait( randomfloatrange( 1, 1.25 ) );

	if ( !flag( "control_room_breached" ) )
	{
		//Shadow Company 6	Oxide, Butcher Five-Actual. I've got a severed det cord - we're gonna need ten mikes to get the trunk rigged and the EBC primed, over.
		radio_dialogue( "afcaves_sc6_severeddet" );
	}

	if ( !flag( "control_room_getting_breached" ) )
	{
		//Shadow Company HQ	Negative, Gold Eagle wants those charges hot in less than three mikes. Get it done, out.
		radio_dialogue( "afcaves_schq_chargeshot" );
	}
	
	flag_set( "start_breach_nags" );
	
	flag_wait( "control_room_cleared" );
	//flag_wait( "control_room_runners_dead" );
	wait( 1 );

	//Shepherd	All units be advised this is Gold Eagle. The site has been compromised.
	radio_dialogue( "afcaves_shp_sitecompromised" );

	//Shepherd	I am executing directive one-one-six bravo. If you're still inside, your service will be honored. Shepherd out.		echoing P.A. announcement
	radio_dialogue( "afcaves_shp_directive116" );
	
	control_room_volume = getent( "control_room_volume", "script_noteworthy" );
	if ( level.player istouching( control_room_volume ) )
	{
		thread autosave_by_name( "timer_start" );
	}

	//Captain Price	Overide the door controls! Hurry!	
	level.price dialogue_execute( "afcaves_pri_overridecontrol" );
	level.price notify( "nag_anim" );
	
	flag_set( "obj_door_controls_given" );

	thread dialogue_nag_control_room_door();

	flag_wait( "control_room_door_opened" );
	
	wait( 2 );
	//Captain Price	RUUNN!!!
	level.price dialogue_execute( "afcaves_pri_run" );

	flag_set( "obj_escape_given" );

	wait( .5 );

	if ( !flag( "player_touching_cave_exit" ) )
	{
		//Captain Price	Keep moving! This place is gonna blow!!	
		level.price dialogue_execute( "afcaves_pri_gonnablow" );
	}
}

breach_nags()
{
	level endon( "control_room_getting_breached" );
	level endon( "control_room_breached" );
	level endon( "control_room_cleared" );

	flag_wait( "breach_door_closed" );
	flag_wait( "start_breach_nags" );
	
	wait( 1 );
	iNagNumber = 0;
	while( true )
	{
		level.price dialogue_execute( "breach_nag_0" + iNagNumber );
		iNagNumber++;
		if ( iNagNumber > 3 )
			iNagNumber = 0;
		wait( randomfloatrange( 10, 15 ) );
	}
}

control_door_open( side, sFlagToSet )
{
	angles = self.openangles;
	time = 4;
	self RotateTo( self.angles + ( 0, angles, 0 ), 4, 1.5, 1.5 );
	self thread play_sound_on_entity( "af_caves_escape_door_open" );
	wait( time );
	if ( IsDefined( sFlagToSet ) )
		flag_set( sFlagToSet );
}

control_door_close( side, sFlagToSet )
{
	angles = self.closeangles;
	time = 7;
	self RotateTo( self.angles + ( 0, angles, 0 ), time, .5, .5 );
	wait( time - 1 );
	if ( side == "left" )
		self thread play_sound_on_entity( "af_caves_escape_door_close" );
	if ( IsDefined( sFlagToSet ) )
		flag_set( sFlagToSet );
}

dialogue_nag_control_room_door()
{
	price_computer_node = getent( "price_computer_node", "targetname" );
	level.player endon( "death" );
	while ( true )
	{
		wait( 6 );
		if ( flag( "control_room_door_opened" ) )
			break;

		//Captain Price Override the door controls! Use the keyboard!	
		level.price dialogue_execute( "afcaves_pri_usekeyboard" );
		level.price notify( "nag_anim" );
		
		wait( 6 );
		if ( flag( "control_room_door_opened" ) )
			break;
		
		level.price notify( "nag_anim" );
		//Price Open the door! We're running out of time!
		level.price dialogue_execute( "afcaves_pri_openthedoor" );
		
		wait( 6 );
		if ( flag( "control_room_door_opened" ) )
			break;
		
		level.price notify( "nag_anim" );
		//Price Come onnn...come onnn...
		level.price dialogue_execute( "afcaves_pri_comeoncomeon" );
		
		wait( 6 );
		if ( flag( "control_room_door_opened" ) )
			break;
		
		level.price notify( "nag_anim" );
		//Captain Price	Soap! Get that door open!
		level.price dialogue_execute( "afcaves_pri_getdooropen" );
	}
}

music_control_room()
{
	//level endon( "end_cave_collapse" );
	flag_wait( "control_room_explosion" );
	MusicStop();
	time = musicLength( "af_caves_controlroom" );
	flag_wait( "control_room_cleared" );
	while ( true )
	{
		MusicPlayWrapper( "af_caves_controlroom" );
		wait( time );
		//wait( 279 );
		music_stop( 1 );
		wait( 1.1 );
	}
}

controlroom_sheppard_close_the_door()
{
	/*-----------------------
	BREACH SETUP
	-------------------------*/	
	icon_trigger = GetEnt( "trigger_breach_icon", "targetname" );
	icon_trigger trigger_off();

	wait( 2 );
	//hide the breach door model for now
	breach_door = level.breach_doors[ 2 ];
	breach_door Hide();

	breach_path_clip = GetEnt( "breach_solid", "targetname" );
	breach_path_clip NotSolid();
	breach_path_clip ConnectPaths();

	old_door = GetEnt( "blast_door_slam", "targetname" );// this is the wood door
	old_door.origin = breach_door.origin;
	startAngles = old_door.angles;
	old_door.angles += ( 0, -74, 0 );

	/*-----------------------
	GUY CLOSES BREACH DOOR
	-------------------------*/	
	flag_wait( "player_approaching_breach" );

	guy = spawn_targetname( "control_room_door_close_guy", true );
	guy set_ignoreme( true );
	guy set_ignoreall( true );
	guy thread magic_bullet_shield();

	node = GetNode( "sheppard_door_peek", "targetname" );

	node anim_generic_reach( guy, "alert2look_cornerR" );
	node anim_generic( guy, "alert2look_cornerR" );

	flag_set( "breach_door_closed" );

	old_door RotateYaw( 74, .50 );

	old_door thread play_sound_in_space( "scn_afcaves_doorslam_brace", old_door.origin );

	breach_path_clip Solid();
	breach_path_clip DisconnectPaths();

	wait( .66 );

	old_door Hide();
	old_door NotSolid();
	breach_door Show();

	wait .5;
	icon_trigger trigger_on();


	if ( IsDefined( guy ) )
	{
		guy stop_magic_bullet_shield();
		guy Delete();
	}
}

controlroom_breach_destruction()
{
	level waittill( "A door in breach group 1 has been activated." );
	level notify( "breach_activated" );
	flag_set( "control_room_getting_breached" );
	wait( 2.3 );
	flag_set( "control_room_explosion" );
	wait( .7 );
	flag_set( "control_room_breached" );

}

controlroom_guys_think()// making the guys in the rear wait till the slowmo has ended before they shoot.
{
	self endon( "death" );
	self.dontEverShoot = true;

	level waittill( "A door in breach group 1 has been activated." );
	wait 12;

	self.dontEverShoot = undefined;
}

/****************************************************************************
    AIRSTRIP
****************************************************************************/ 
AA_airstrip_init()
{
	thread AAA_sequence_airstrip();
	thread airstip_owned_enemies();
	thread airstrip_damage_state();
	thread dialogue_airstrip();
	thread airstrip_tower_destruction();
	thread tower_explosion();
	thread music_airstrip();
	thread obj_level_end();
}

tower_explosion()
{
	flag_wait( "tower_explosion" );
	trig = GetEnt( "tower_trigger", "targetname" );
	trig notify( "trigger" );
}

airstip_owned_enemies()
{
	flag_wait( "danger_close_dialogue_end" );
	wait( 2 );
	airstrip_runners = GetEntArray( "airstrip_runners", "targetname" );
	array_spawn( airstrip_runners, true );

	flag_wait( "danger_close_last_missile_has_hit" );
	ambient_airstrip = GetEntArray( "ambient_airstrip", "targetname" );
	array_spawn( ambient_airstrip, true );
}

airstrip_damage_state()
{
	camo_right_damaged = getentarray( "camo_right_damaged", "targetname" );
	camo_left_damaged = getentarray( "camo_left_damaged", "targetname" );
	
	camo_right_pristine = getentarray( "camo_right_pristine", "targetname" );
	camo_left_pristine = getentarray( "camo_left_pristine", "targetname" );
	
	flag_wait( "danger_close_last_missile_has_hit" );
	
	array_thread( camo_right_pristine, ::hide_entity );
	array_thread( camo_left_pristine, ::hide_entity );

	array_thread( camo_right_damaged, ::show_entity );
	array_thread( camo_left_damaged, ::show_entity );
}

AAA_sequence_airstrip()
{
	flag_wait( "obj_escape_complete" );
	
	battlechatter_off( "allies" );
	
	/*-----------------------
	CAVE COLLAPSE AND PLAYER SHELLSHOCK
	-------------------------*/	
	//exploder( "control_room_detonate" );
	//wait( 1 );
	
	level.player PlayLocalSound( "af_caves_selfdestruct" );
	
	cave_exit_playerview_02 = GetEnt( "cave_exit_playerview_02", "targetname" );
	cave_exit_playerview_01 = GetEnt( "cave_exit_playerview_01", "targetname" );
	dummy = spawn_tag_origin();
	dummy.origin = level.player.origin;
	dummy.angles = cave_exit_playerview_01.angles;
	PlayFXOnTag( getfx( "cave_explosion_exit" ), dummy, "tag_origin" );
	Earthquake( 1, 1, level.player.origin, 100 );
	level notify( "player_invulnerable" );
	zoffset = ( 0, 0, 10 );
	playerOrg = spawn_tag_origin();
	playerOrg.origin = level.player.origin + zoffset;
	playerOrg.angles = cave_exit_playerview_01.angles + ( 0, -10, 70 );
	level.player PlayerLinkToBlend( playerOrg, "tag_player", 1 );
	level.player AllowSprint( false );
	level.player DisableWeapons();
	level.player setMoveSpeedScale( .2 );
	level.player enableinvulnerability();
	wait( .5 );
	PlayFXOnTag( getfx( "player_cave_escape" ), dummy, "tag_origin" );
	wait( .5 );
	
	/*-----------------------
	FIRST CUT TO BLACKOUT 
	-------------------------*/	
	level.black_overlay = create_client_overlay( "black", 1 );
	level.black_overlay.foreground = false;
	array_thread( level.fx_start_to_ledge, ::pauseEffect );
	array_thread( level.fx_ledge_to_airstrip, ::pauseEffect );
	
  	level.price.IgnoreRandomBulletDamage = true;
	level.price disable_pain();
	level.price.ignoreall = true;
	level.price PushPlayer( true );
  	
	airstrip_danger_close_shooters = array_spawn( getentarray( "airstrip_danger_close_shooters", "targetname" ), true );
	array_thread ( airstrip_danger_close_shooters,::airstrip_danger_close_shooters_think );
	
	flag_set( "player_detonated_explosives" );		// turn off the barrels below
	//level.player PlayerLinkToDelta( playerOrg, "tag_player", 1, 0, 20, 10, 10 );
	shellshockTime = 17;
	level.player ShellShock( "af_cave_collapse", shellshockTime );
	thread autosave_now( true );
	level.player AllowStand( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );
	level.player AllowJump( false );
	level.player AllowCrouch( true );
	
	SetBlur( 2, .1 );
	SetSavedDvar( "ui_hidemap", 1 );
	SetSavedDvar( "hud_showStance", "0" );
	//SetSavedDvar( "compass", "1" );

	thread airstrip_heli_crash_destruction();

	/*-----------------------
	BLOCK EXIT
	-------------------------*/	
	rock_rubble1 = GetEnt( "rock_rubble1", "targetname" );
	rock_rubble1 Solid();
	rock_rubble1 Show();
	rock_rubble1 DisconnectPaths();

	/*-----------------------
	PRICE RUNS FORWARD
	-------------------------*/	
	level.price.moveplaybackrate = .5;
	SetSavedDvar( "g_friendlyNameDist", 0 );
	
	//price_fallforward = GetEnt( "price_fallforward", "targetname" );
	//price_fallforward anim_first_frame_solo( level.price, price_fallforward.animation );
	
	price_fighting_cave_exit = GetEnt( "price_fighting_cave_exit", "targetname" );
	price_fighting_cave_exit anim_first_frame_solo( level.price, price_fighting_cave_exit.animation );

	wait( .1 );
	dummy Delete();
	wait( 2 );
	playerOrg.origin = cave_exit_playerview_01.origin;
	level.player unlink();
	level.player.origin = playerOrg.origin;
	level.player SetOrigin( playerOrg.origin );
	level.player PlayerLinkToBlend( playerOrg, "tag_player", 1 );
	flag_set( "danger_close_dialogue_start" );
	wait( 1 );
	
	/*-----------------------
	FIRST BLACKOUT FADE UP
	-------------------------*/	
	level.black_overlay FadeOverTime( 2 );
	level.black_overlay.alpha = 0;
	
	wait( 1 );
	//price_fallforward thread anim_custom_animmode_solo( level.price, "gravity", price_fallforward.animation );
	price_fighting_cave_exit thread anim_custom_animmode_solo( level.price, "gravity", price_fighting_cave_exit.animation );
	//wait( 0.05 );
	//level.price SetAnimTime( level.scr_anim[ "price" ][ price_fallforward.animation ], .6 );
	//node_price_fallforward = GetNode( "node_price_fallforward", "targetname" );
	level.price disable_ai_color();
	level.price cqb_walk( "off" );
	level.price.neverEnableCQB = true;
	//level.price SetGoalNode( node_price_fallforward );
	
	wait( 2.5 );
	SetBlur( .2, 1.5 );
	
	wait( 1 );
	playerOrg RotateTo( playerOrg.angles + ( 40, 0, -70 ), 12, 5, 5 );
	SetBlur( 2, 1.5 );
	wait( 1.5 );
	SetBlur( .2, 1 );

	thread exploder( "under_fire_2" );
	wait( 1 );
	thread exploder( "under_fire" );
	SetBlur( 3, 1 );
	wait( 2 );
	
	/*-----------------------
	BLACKOUT BEGIN
	-------------------------*/	
	level.black_overlay FadeOverTime( 2 );
	level.black_overlay.alpha = 1;
	SetBlur( 3, .5 );
	//flag_set( "danger_close_dialogue_start" );
	wait( 2 );
	level.player Unlink();
	level.player SetOrigin( cave_exit_playerview_01.origin );
	level.player SetPlayerAngles( cave_exit_playerview_01.angles );
	level.player FreezeControls( true );
	level.player AllowStand( true );
	level.player AllowSprint( true );
	level.player AllowJump( true );
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	//level.player SetStance( "stand" );
	
	
	/*-----------------------
	SETUP PRICE FALLING BACK
	-------------------------*/
	price_fallback = GetEnt( "price_fallback", "targetname" );
	level.price anim_stopanimscripted();
	price_fallback anim_first_frame_solo( level.price, "launchfacility_a_c4_plant_short" );

	flag_wait( "danger_close_dialogue_end" );
	
	wait( 1.5 );
	
	/*-----------------------
	PRICE RUNS BACKWARDS
	-------------------------*/	
	flag_set_delayed( "price_falling_back", .1 );
	price_fallback thread anim_custom_animmode_solo( level.price, "gravity", "launchfacility_a_c4_plant_short" );
	//level.price SetAnimTime( level.scr_anim[ "price" ][ price_fallback.animation ], .2 );
	node_price_fallback = GetNode( "node_price_fallback", "targetname" );
	level.price SetGoalNode( node_price_fallback );
	level.price.goalradius = 32;

	wait( .5 );
	/*-----------------------
	BLACKOUT END
	-------------------------*/	
	level.black_overlay FadeOverTime( 2 );
	level.black_overlay.alpha = 0;

	wait( 1 );
	SetBlur( 0, 3 );
	level.player FreezeControls( false );

	/*-----------------------
	DANGER CLOSE MOMENT
	-------------------------*/	
	thread danger_close_firestorm();
	
	wait( 1 );
	SetSavedDvar( "ui_hidemap", 0 );
	SetSavedDvar( "hud_showStance", "1" );
	wait( 1 );
	SetSavedDvar( "g_friendlyNameDist", 15000 );
	level.price.moveplaybackrate = 1.0;
	level.player setMoveSpeedScale( 1 );
	
	//thread danger_close_firestorm();

	wait( 3 );
	level.player EnableWeapons();
	level.player disableinvulnerability();

	/*-----------------------
	PRICE LEADS PLAYER OUT
	-------------------------*/	
	wait( 3 );
  	level.price.IgnoreRandomBulletDamage = false;
	level.price enable_pain();
	level.price.ignoreall = false;
	level.price cqb_walk( "off" );
	level.price.neverEnableCQB = true;
  	level.price enable_ai_color();
  	level.price.fixednodesaferadius = 0;
	level.fixednodesaferadius_default = 0;

	triggersEnable( "colornodes_backhalf_airstrip_start", "script_noteworthy", true );
	activate_trigger_with_noteworthy( "colornodes_backhalf_airstrip_start" );
	triggersEnable( "colornodes_backhalf_airstrip", "script_noteworthy", true );

	/*-----------------------
	AIRSTRIP START
	-------------------------*/	
	thread spawn_vehicles_from_targetname_and_drive_on_flag( "littlebird_airstrip", "player_airstrip_start" );
	delayThread( 1, ::spawn_vehicle_from_targetname_and_drive, "blackhawk_airstrip" );

	flag_wait( "player_airstrip_start" );
	level.price PushPlayer( false );
	
	/*-----------------------
	AIRSTRIP MIDPOINT
	-------------------------*/	
	flag_wait( "player_airstrip_midpoint" );

	
	thread autosave_by_name( "airstrip_fight_start" );
	level.price.fixednodesaferadius = 1024;
	level.fixednodesaferadius_default = 1024;
	
	/*-----------------------
	AIRSTRIP END TENT
	-------------------------*/	
	flag_wait( "player_approaching_end_tent" );
	thread autosave_by_name( "airstrip_fight_start" );
	
	flag_wait( "player_entering_end_tent" );
	
	/*-----------------------
	LEVEL END
	-------------------------*/	
	flag_wait( "level_exit" );

  	level.price.IgnoreRandomBulletDamage = true;
	level.price disable_pain();
  	level.price set_ignoreme( true );
  	level.price set_ignoreall( false );
  	
  	level.player enableinvulnerability();
  	level.player.ignoreme = true;
  	level.black_overlay FadeOverTime( 3 );
	level.black_overlay.alpha = 1;
	
	//delaythread( 3,::freeze_player_at_end );
	//Captain Price	Shepherd mentioned Zodiacs...there must riveracess nearby - let's go!
	level.price dialogue_execute( "afcaves_pri_rivernearby" );
	
	maps\_loadout::SavePlayerWeaponStatePersistent( "af_caves" );
	nextmission();
}

freeze_player_at_end()
{
	level.player FreezeControls( true );
}

airstrip_danger_close_shooters_think()
{
	self endon( "death" );
	self.grenadeammo = 0;
	while( !flag( "danger_close_last_missile_has_hit" ) )
	{
		self.goalradius = 32;
		wait( .1 );
	}
	flag_wait( "danger_close_last_missile_has_hit" );
	self kill();
}

blackhawk_airstrip_think()
{
	self endon( "death" );
	//self.enableRocketDeath = true;
	
	self thread blackhawk_airstrip_crash_locations();
	flag_set( "unload_airstrip_blackhawk_dudes" );

	self waittill( "unloaded" );

	blackhawk_airstrip_heli_depart = getstruct( "blackhawk_airstrip_heli_depart", "targetname" );
	self thread vehicle_paths( blackhawk_airstrip_heli_depart );
	self Vehicle_SetSpeed( 50 );
	self waittill( "reached_dynamic_path_end" );
	self Delete();
	
}

blackhawk_airstrip_crash_locations()
{
	self endon( "death" );
	blackhawk_crash_locs = getentarray( "blackhawk_crash_loc", "script_noteworthy" );
	while( true )
	{
		self.perferred_crash_location = getClosest( self.origin, blackhawk_crash_locs );
		wait( 1 );
	}
}

AI_airstrip_runners_think()
{
	self endon( "death" );
	self.ignoreme = true;
	self.ignoreall = true;
	flag_wait( "danger_close_last_missile_has_hit" );
	self DoDamage( self.health + 1000, self.origin );
}

littlebird_airstrip_think()
{
	self endon( "death" );
	self.enableRocketDeath = true;

	self waittill( "unloaded" );
	self Vehicle_SetSpeed( 10 );
	self thread vehicle_liftoff( 32 );
	wait( 2 );
	self Vehicle_SetSpeed( 50 );

	airstrip_littlebird_01_depart = getstruct( "airstrip_littlebird_01_depart", "targetname" );
	self thread vehicle_paths( airstrip_littlebird_01_depart );
	self waittill( "reached_dynamic_path_end" );
	self Delete();
}

AI_airstrip_heli_fastropers_think()
{
	self endon( "death" );
	self cqb_walk( "on" );
	self.ignoreme = true;
	self waittill( "jumpedout" );
	self.ignoreme = false;
}

AI_airstrip_littlebird_hostiles_think()
{
	self endon( "death" );
	self cqb_walk( "on" );
	self.ignoreme = true;
	self waittill( "jumpedout" );
	self.ignoreme = false;
	//self thread AI_player_seek();	
}

danger_close_firestorm()
{
	missileOrgs = GetEntArray( "missileOrgs", "targetname" );
	missileOrgs = get_array_of_farthest( level.player.origin, missileOrgs );
	lastMissile = undefined;
	i = 0;
	foreach ( missileOrg in missileOrgs )
	{
		i++;
		targetOrg = GetEnt( missileOrg.target, "targetname" );
		missile = MagicBullet( "hellfire_missile_af_caves_end", missileOrg.origin, targetOrg.origin );
		missile thread play_sound_on_entity( "scn_afcaves_incoming" );
		if ( i == missileOrgs.size )
			lastMissile = true;
		missile thread missile_impact_think( lastMissile );
		wait( .2 );
	}
	wait( 2 );
	flag_set( "start_airstrip_aftermath_fx" );
	wait( 2 );
	flag_set( "danger_close_moment_over" );

	//array_thread( level.createfxent, ::restartEffect );

}

missile_impact_think( lastMissile )
{
	dummy = Spawn( "script_origin", self.origin );
	dummy LinkTo( self );
	self waittill( "death" );
	//scale duration
	if ( IsDefined( lastMissile ) )
	{
		flag_set( "danger_close_last_missile_has_hit" );
		dummy thread play_sound_in_space( "exp_javelin_armor_destroy" );
		Earthquake( .5, 1.5, level.player.origin, 5000 );
		//thread exploder( "escape_cave_exit" );
		thread exploder( "rpg_damage" );
		RadiusDamage( dummy.origin, 512, 1000, 1000 );
	}
	else
	{
		Earthquake( .2, 2.5, level.player.origin, 5000 );
	}

	level.player PlayRumbleOnEntity( "damage_heavy" );
	//RadiusDamage( dummy.origin, 512, 1000, 1000 );
	wait( 0.05 );
	dummy Delete();
	
	if ( IsDefined( lastMissile ) )
	{
		SetBlur( 3, .1 );
		wait( 1 );
		SetBlur( 0, 3 );
	}
}

dialogue_airstrip()
{
	flag_wait( "obj_escape_complete" );

	/*-----------------------
	DANGER CLOSE DIALOGUE
	-------------------------*/	
	flag_wait( "danger_close_dialogue_start" );
	//Shepherd	Excalibur, this is Gold Eagle. Fire mission - target package Romeo - danger close.	
	radio_dialogue( "afcaves_shp_dangerclose" );

	//Shadow Company HQ	That's within a hundred meters of your position sir!
	radio_dialogue( "afcaves_schq_100meters" );

	flag_set( "danger_close_dialogue_end" );
	
	//Shepherd	That's not a suggestion! Send it!
	radio_dialogue( "afcaves_shp_sendit" );

	//Shadow Company HQ	Roger, fire mission danger close!
	thread radio_dialogue( "afcaves_schq_firemissionclose" );

	flag_wait( "price_falling_back" );
	//Captain Price	Soaap!! Incomiiing!!! Get down! Get down!
	level.price thread dialogue_execute( "afcaves_pri_fallback2" );

	/*-----------------------
	LEVEL END DIALOGUE
	-------------------------*/	
	flag_wait( "danger_close_moment_over" );

	//Captain Price	Since when does Shepherd care about danger close... 
	level.price dialogue_execute( "afcaves_pri_sincewhen" );

	thread autosave_by_name( "airstrip_fight_start" );
	wait( 1.5 );

	flag_set( "obj_level_end_given" );
	//Captain Price	Let's go! Stay close and follow me!		
	level.price dialogue_execute( "afcaves_pri_stayclose" );

	battlechatter_on( "allies" );
	level.price set_battlechatter( true );

	wait( 2 );

	if ( !flag( "player_airstrip_start" ) )
	{
		//Captain Price	To the west, Soap, Go!	
		level.price thread dialogue_execute( "afcaves_pri_tothewest" );
	}
	
	flag_wait( "player_airstrip_start" );
	
	//Shadow Company HQ	Sir, sandstorm activity is picking up here. It's too risky for flight ops.
	radio_dialogue( "afcaves_schq_riskyforflightops" );

	//Shepherd	Understood. Head for the tunnel. We'll take the Zodiacs.		stealth wiretap
	radio_dialogue( "afcaves_shp_takezodiacs" );

	//Shadow Company HQ	Yes sir!		stealth wiretap
	radio_dialogue( "afcaves_schq_yessir2" );
	
	
	/*-----------------------
	AIRSTRIP MIDPOINT
	-------------------------*/	
	flag_wait( "player_airstrip_midpoint" );

	/*-----------------------
	AIRSTRIP END TENT
	-------------------------*/	

	/*-----------------------
	LEVEL END DIALOGUE
	-------------------------*/	
	flag_wait( "player_entering_end_tent" );

	//Captain Price	Head for the tunnel! He's getting away!		
	level.price dialogue_execute( "afcaves_pri_gettingaway2" );
	
	wait( 10 );

	if ( !flag( "level_exit" ) )
	{
		//Captain Price	Soap! Follow me! Let's go!	
		level.price dialogue_execute( "afcaves_pri_followmeletsgo" );
	}


}

music_airstrip()
{
	//musicstop();

}

airstrip_tower_destruction()
{
	trig = GetEnt( "tower_trigger", "targetname" );
	trig waittill( "trigger" );

	RadiusDamage( trig.origin, 256, 1000, 900 );
	Earthquake( 0.2, 1, level.player.origin, 1024 );
	level.player PlayRumbleOnEntity( "damage_light" );

	trig thread play_sound_in_space( "explo_wood_tower", trig.origin );
//	exploder( "tower" );

	volume = GetEnt( "tower_victims", "targetname" );

	mg = GetEnt( "tower_mg", "script_noteworthy" );
	owner = mg GetTurretOwner();
	if ( IsAlive( owner ) )
		owner notify( "stop_using_built_in_burst_fire" );

	mg Hide();

	volume = GetEnt( "tower_victims", "targetname" );
	array_thread( GetCorpseArray(), ::delete_corpse_in_volume, volume );
}

littlebird_on_fire()
{
	self endon( "death" );
	while ( true )
	{
		playfxOnTag( getfx( "littlebird_fire_trail" ), self, "tag_deathfx" );
		wait( .1 );
	}
}

airstrip_heli_crash_destruction()
{
	littlebird_crasher = spawn_vehicle_from_targetname_and_drive( "littlebird_crasher" );
	littlebird_crasher.perferred_crash_location = GetEnt( "airstip_crash", "script_noteworthy" );
	
	
	littlebird_crasher SetLookAtEnt( level.player );
	littlebird_crasher godon();
	flag_wait( "danger_close_moment_over" );
	
	littlebird_crasher thread littlebird_on_fire();
	wait( 2.5 );
	littlebird_crasher godoff();
	littlebird_crasher notify( "death" );
	littlebird_crasher ClearLookAtEnt();
	littlebird_crasher waittill( "crash_done" );

	exploder( "helicrash_01" );
	Earthquake( 0.3, 1, level.player.origin, 1024 );
	level.player PlayRumbleOnEntity( "damage_light" );

	pristine_netting = GetEntArray( "netting_pristine", "targetname" );
	foreach ( nondestroyed_piece in pristine_netting )
	{
		nondestroyed_piece Hide();
	}

	netting_destroyed = GetEntArray( "netting_destroyed", "targetname" );
	foreach ( destroyed_piece in netting_destroyed )
	{
		destroyed_piece Show();
	}
	
	flag_wait( "player_approaching_end_tent" );
	

}

/****************************************************************************
    OBJECTIVES
****************************************************************************/ 

obj_ledge_traverse()
{
	flag_wait( "obj_ledge_traverse_given" );
	objective_number = 6;

	// Traverse the rock bridge
	Objective_Add( objective_number, "active", &"AF_CAVES_OBJ_LEDGE_TRAVERSE" );
	Objective_Current( objective_number );
	Objective_OnEntity( objective_number, level.price, ( 0, 0, 70 ) );
	// Capt. MacTavish
	//Objective_SetPointerTextOverride( objective_number, &"OILRIG_OBJ_SOAP" );

	flag_wait( "player_ledge_stairs_01" );

	Objective_Position( objective_number, ( 0, 0, 0 ) );

	obj_position = GetEnt( "obj_ledge_gunners", "targetname" );
	Objective_Position( objective_number, obj_position.origin );
	//Objective_SetPointerTextOverride( objective_number );

	flag_wait( "player_ledge_end" );

	Objective_Position( objective_number, ( 0, 0, 0 ) );
	Objective_OnEntity( objective_number, level.price, ( 0, 0, 70 ) );

	Objective_State( objective_number, "done" );

	flag_set( "obj_ledge_traverse_complete" );
}

obj_overlook_to_skylight()
{
	flag_wait( "obj_ledge_traverse_complete" );
	objective_number = 6;

	// Locate Shepherd.\n
	Objective_Add( objective_number, "active", &"AF_CAVES_LOCATE_SHEPHERD" );
	Objective_Current( objective_number );
	Objective_OnEntity( objective_number, level.price, ( 0, 0, 70 ) );

	flag_wait_any( "price_has_given_flank_hint", "obj_overlook_to_skylight_complete" );
	
	Objective_String_NoMessage( objective_number, &"AF_CAVES_OBJ_FLANK_AND_KILL" );
	
	Objective_Position( objective_number, ( 0, 0, 0 ) );
	obj_position = GetEnt( "obj_flank_skylight_01", "targetname" );
	Objective_Position( objective_number, obj_position.origin );

	flag_wait_any( "player_going_around_skylight_flank", "player_on_other_side_skylight", "obj_overlook_to_skylight_complete" );
	
	obj_position = GetEnt( "obj_flank_skylight_02", "targetname" );
	Objective_Position( objective_number, obj_position.origin );

	flag_wait_any( "skylight_dudes_dead", "player_right_near_breach", "obj_overlook_to_skylight_complete" );

	Objective_State( objective_number, "done" );

	if ( !flag( "obj_overlook_to_skylight_complete" ) )
		flag_set( "obj_overlook_to_skylight_complete" );
}

obj_breach()
{
	//"breach the control room"
	flag_wait( "obj_breach_given" );

	objective_number = 6;

	// Reach Shepherd's Command Center
	Objective_Add( objective_number, "active", &"AF_CAVES_OBJ_BREACH", ( 0, 0, 0 ) );

	breach_positions = GetEntArray( "obj_breach", "targetname" );

	// grab the script_slow_breach index off the nearest breach and put it on the entity
	assign_script_breachgroup_to_ents( breach_positions );

	// find out which breaches should be added to the objective positions
	breach_indices = get_breach_indices_from_ents( breach_positions );

	// add positions for these breaches
	objective_breach( objective_number, breach_indices[ 0 ], breach_indices[ 1 ], breach_indices[ 2 ], breach_indices[ 3 ] );

	Objective_Current( objective_number );

	flag_wait( "control_room_breached" );

	objective_clearAdditionalPositions( objective_number );

	flag_wait( "control_room_cleared" );
	//flag_wait( "control_room_runners_dead" );
	
	Objective_State( objective_number, "done" );

	flag_set( "obj_breach_complete" );
}

obj_door_controls()
{
	//"override the door controls"
	flag_wait( "obj_door_controls_given" );

	objective_number = 7;

	obj_position = GetEnt( "keyboard", "targetname" );
	// Override the door controls
	Objective_Add( objective_number, "active", &"AF_CAVES_OBJ_DOOR_CONTROLS", obj_position.origin );
	Objective_Current( objective_number );

	flag_wait( "control_room_door_opened" );

	Objective_State( objective_number, "done" );

	flag_set( "obj_door_controls_complete" );
}

obj_escape()
{
	//"escape from the cave"
	flag_wait( "obj_escape_given" );

	objective_number = 8;

	// Escape from the cave
	Objective_Add( objective_number, "active", &"AF_CAVES_OBJ_ESCAPE" );
	Objective_Current( objective_number );
	Objective_OnEntity( objective_number, level.price, ( 0, 0, 70 ) );

	flag_wait( "player_escaped" );
	Objective_Position( objective_number, ( 0, 0, 0 ) );
	Objective_State( objective_number, "done" );

	flag_set( "obj_escape_complete" );
}

obj_level_end()
{
	//"escape from the cave"
	flag_wait( "obj_level_end_given" );

	objective_number = 6;

	// Follow Price.
	Objective_Add( objective_number, "active", &"AF_CAVES_LOCATE_SHEPHERD" );
	Objective_Current( objective_number );
	Objective_OnEntity( objective_number, level.price, ( 0, 0, 70 ) );

	flag_wait( "level_exit" );

	flag_set( "obj_level_end_complete" );
}

obj_hummer()
{
	//"mount the humvee turret"
	flag_wait( "obj_hummer_given" );

	flag_wait( "obj_hummer_complete" );
}

obj_hummer_gunner()
{
	//"eliminate all enemy resistance"
	flag_wait( "obj_hummer_gunner_given" );

	flag_wait( "obj_hummer_gunner_complete" );
}


backhalf_dialogue()
{
	/*-----------------------
	LEDGE
	-------------------------*/
	//****Captain Price	The clock's ticking! Let's go!		stealth
	//level.scr_radio[ "afcaves_pri_clocksticking" ] = "afcaves_pri_clocksticking";
	
	//Shadow Company HQ	Avatar One this is Oxide, we've lost contact with multiple squads near the steam room. I need a camera sweep of the catwalk, over.		stealth wiretap
	level.scr_radio[ "afcaves_schq_catwalk" ] = "afcaves_schq_catwalk";
	
	//Shadow Company 4	Roger that Oxide, UAV is online. Standby.		stealth wiretap
	level.scr_radio[ "afcaves_sc4_uavonline" ] = "afcaves_sc4_uavonline";

	//Captain Price	Grab a riot shield...we'll need cover out here.
	level.scr_radio[ "afcaves_pri_pickupriotsheild" ] = "afcaves_pri_pickupriotsheild";
	
	//Captain Price	Take point with the riot shield. I'll take care of any resistance.		stealth
	level.scr_radio[ "afcaves_pri_takepoint2" ] = "afcaves_pri_takepoint2";

	//Shadow Company 4	Oxide, Avatar One. We have unauthorized personnel on the catwalk. I repeat, we have unauthorized personnel on the catwalk.
	level.scr_radio[ "afcaves_sc4_gettingthis" ] = "afcaves_sc4_gettingthis";

	//****Shadow Company HQ	Avatar One, divert your camera feed to the facial recognition database at Langley. Break. Standby for fur- ( further orders. )		stealth wiretap
	level.scr_radio[ "afcaves_schq_facialrecog" ] = "afcaves_schq_facialrecog";
	
	//****Shepherd	Backup priority items and burn the rest. Fire teams - just delay 'em until we're ready to pull out. 	
	level.scr_radio[ "afcaves_shp_burntherest" ] = "afcaves_shp_burntherest";
	
	//Shepherd	It's Price. Backup priority items and burn the rest. All fire teams - just delay 'em until we're ready to leave. Shepherd out.		stealth wiretap
	level.scr_radio[ "afcaves_shp_shepout" ] = "afcaves_shp_shepout";
	
	//***Captain Price	We're exposed! Go loud!!		
	//level.scr_radio[ "afcaves_pri_exposedgoloud" ] = "afcaves_pri_exposedgoloud";

	//Shadow Company 5	Oxide, Disciple Nine, we've got hostile contact approximately 50 meters from the nest, over.
	level.scr_radio[ "catwalk_enemy_chatter_00" ] = "afcaves_sc5_50meters";

	//Shadow Company HQ	Terminate with extreme prejudice.
	level.scr_radio[ "catwalk_enemy_chatter_01" ] = "afcaves_schq_prejudice";
	
	//Shadow Company HQ	All personnel - be advised, we have two enemy foot-mobiles on the catwalk heading to the crow's nest.
	level.scr_radio[ "catwalk_enemy_chatter_02" ] = "afcaves_schq_2enemies";


	/*-----------------------
	RIOT ----- MOVE UP
	-------------------------*/
	//Captain Price	Move up.	
	level.scr_radio[ "riotsheildmove_00" ] = "afcaves_pri_moveup";
	
	//Captain Price	Take point with the shield and draw their fire. I'll cover you.	
	level.scr_radio[ "riotsheildmove_01" ] = "afcaves_pri_takepointdraw";
	
	
	/*-----------------------
	RIOT ----- NEED TO CROUCH
	-------------------------*/
	//Captain Price	Stay low with that shield so I can get a clean shot!		stealth
	level.scr_radio[ "crouchriotsheild_00" ] = "afcaves_pri_staylow";

	//Captain Price	Keep low with that shield!		stealth
	level.scr_radio[ "crouchriotsheild_01" ] = "afcaves_pri_keeplow";

	//Captain Price	Crouch down with that shield, Soap! I'll take care of the shooters.		stealth
	level.scr_radio[ "crouchriotsheild_02" ] = "afcaves_pri_crouchdown";

	/*-----------------------
	RIOT ----- NEED TO SWITCH
	-------------------------*/
	//Captain Price	Switch to the shield, we're exposed out here!		stealth
	level.scr_radio[ "switchriotsheild_00" ] = "afcaves_pri_switchtosheild";

	//Captain Price	Bring up the riot shield, Soap!		stealth
	level.scr_radio[ "switchriotsheild_01" ] = "afcaves_pri_bringup";

	//Captain Price	Give us some cover with that riot shield, Soap!		stealth
	level.scr_radio[ "switchriotsheild_02" ] = "afcaves_pri_giveuscover";

	/*-----------------------
	RIOT ----- NEED TO PICKUP
	-------------------------*/
	//Captain Price	Soap, grab a riot shield and lead the way. I'll take care of any shooters!
	level.scr_radio[ "pickupriotsheild_00" ] = "afcaves_pri_pickupriotsheild2";

	//Captain Price	Soap, grab a riot shield. We'll need all the cover we can get.
	level.scr_radio[ "pickupriotsheild_01" ] = "afcaves_pri_pickupriotsheild3";

	//Captain Price	Grab a riot shield. We're completely exposed out here.
	level.scr_radio[ "pickupriotsheild_02" ] = "afcaves_pri_grabasheild";

	/*-----------------------
	RIOT ----- KILLFIRMS
	-------------------------*/
	//Captain Price	We're clear. Move in.		stealth
	level.scr_radio[ "riot_killfirm_final" ] = "afcaves_pri_wereclearmove";

	//Captain Price	Good night		stealth
	level.scr_radio[ "riot_killfirm_00" ] = "afcaves_pri_goodnight2";

	//Captain Price	He's down		stealth
	level.scr_radio[ "riot_killfirm_01" ] = "afcaves_pri_hesdown2";

	//Captain Price	Got 'em		stealth
	level.scr_radio[ "riot_killfirm_02" ] = "afcaves_pri_gotem";

	//Captain Price	Got one.		stealth
	level.scr_radio[ "riot_killfirm_03" ] = "afcaves_pri_gotone2";

	/*-----------------------
	OVERLOOK
	-------------------------*/	
	//Shadow Company HQ	Butcher One-Five, rendezvous at the nest and prepare to escort Gold Eagle to the LZ.
	level.scr_radio[ "afcaves_schq_escourtgoldeagle" ] = "afcaves_schq_escourtgoldeagle";

	//Captain Price	Gold Eagle must be Shepherd! We're running out of time, let's go!		
	level.scr_radio[ "afcaves_pri_mustbeshepherd" ] = "afcaves_pri_mustbeshepherd";

	//Shadow Company 5	Disciple Three rapelling in!		stealth wiretap
	level.scr_radio[ "afcaves_sc5_rapellingin" ] = "afcaves_sc5_rapellingin";


	/*-----------------------
	OVERLOOK STRATEGY NAGS
	-------------------------*/	
	//Captain Price	Try to flank them!	
	level.scr_sound[ "price" ][ "afcaves_pri_trytoflank" ] = "afcaves_pri_trytoflank";
	
	//Captain Price	They're using shields! Use flash grenades!	
	level.scr_sound[ "price" ][ "afcaves_pri_sheildsuseflash" ] = "afcaves_pri_sheildsuseflash";
	
	//Captain Price	Soap! Hit them from the sides!	
	level.scr_sound[ "price" ][ "afcaves_pri_hitfromsides" ] = "afcaves_pri_hitfromsides";
	
	//Captain Price	They're using shields! Throw some frags!	
	level.scr_sound[ "price" ][ "afcaves_pri_sheildsthrowfrags" ] = "afcaves_pri_sheildsthrowfrags";
	
	//Captain Price	Try to flank and hit them from the sides!	
	level.scr_sound[ "price" ][ "afcaves_pri_flankandhitsides" ] = "afcaves_pri_flankandhitsides";
	
	/*-----------------------
	BREACH
	-------------------------*/	
	//Shadow Company 6	Oxide, Butcher Five-Actual. I've got a severed det cord - we're gonna need ten mikes to get the trunk rigged and the EBC primed, over.		stealth wiretap
	level.scr_radio[ "afcaves_sc6_severeddet" ] = "afcaves_sc6_severeddet";

	//Shadow Company HQ	Negative, Gold Eagle wants those charges hot in less than three mikes. Get it done, out.		stealth wiretap
	level.scr_radio[ "afcaves_schq_chargeshot" ] = "afcaves_schq_chargeshot";


	/*-----------------------
	BREACH NAGS
	-------------------------*/	

	//Captain Price	They've sealed the control room. Get a frame charge on the door!	
	level.scr_sound[ "price" ][ "breach_nag_00" ] = "afcaves_pri_getframecharge";
	
	//Captain Price	Soap! We've got to go now! Breach the door!	
	level.scr_sound[ "price" ][ "breach_nag_01" ] = "afcaves_pri_breachthedoor";
	
	//Captain Price	Blow the door! We can't let Shepherd escape!	
	level.scr_sound[ "price" ][ "breach_nag_02" ] = "afcaves_pri_blowthedoor";
	
	//Captain Price	Get a charge on the door! Do it!	
	level.scr_sound[ "price" ][ "breach_nag_03" ] = "afcaves_pri_chargedoit";
	


	//Shadow Company HQ	All fire teams, be advised - we have a positive ID. Enemy operators are ex-SAS and Task Force 141. Approach with extreme caution, over.		stealth wiretap
	//level.scr_radio[ "" ] = "";

	//****Shadow Company HQ	All fire teams, be advised - enemy operators are ex-SAS and Task Force 141. Approach with extreme caution, over.		stealth wiretap
	//level.scr_radio[ "afcaves_schq_exsas" ] = "afcaves_schq_exsas";
	
	/*-----------------------
	SKYLIGHT
	-------------------------*/	
	//Captain Price	I'm popping smoke! Move around the right flank!		
	//level.scr_radio[ "afcaves_pri_poppingsmoke" ] = "afcaves_pri_poppingsmoke";

	//Captain Price	I'll draw their fire through the smoke! Watch for flanking routes!	
	level.scr_sound[ "price" ][ "afcaves_pri_drawfire" ] = "afcaves_pri_drawfire";

	//Captain Price	Soap! They're digging in, Shepherd must be close! We have to break through!	
	level.scr_sound[ "price" ][ "afcaves_pri_moveright" ] = "afcaves_pri_moveright";

	//Captain Price	The're using thermal through the smoke!		
	level.scr_sound[ "price" ][ "afcaves_pri_usingthermal" ] = "afcaves_pri_usingthermal";

	//Captain Price	Switching to thermal! Keep an eye on our flanks!	
	level.scr_sound[ "price" ][ "afcaves_pri_switchingtotherm" ] = "afcaves_pri_switchingtotherm";

	/*-----------------------
	SKYLIGHT - GETTING FLANKED - TODO
	-------------------------*/	
	//Captain Price	Eyes up! They're flanking us!	
	level.scr_sound[ "price" ][ "afcaves_pri_eyesup" ] = "afcaves_pri_eyesup";
	

	/*-----------------------
	BREACH ROOM
	-------------------------*/	
	//Captain Price	Soap! Get that door open over there! Hit the panel!		
	level.scr_sound[ "price" ][ "afcaves_pri_dooropen" ] = "afcaves_pri_dooropen";

	//Captain Price	Overide the door controls! Hurry!		
	level.scr_sound[ "price" ][ "afcaves_pri_overridecontrol" ] = "afcaves_pri_overridecontrol";

	//Captain Price	Soap! Get that door open!		
	level.scr_sound[ "price" ][ "afcaves_pri_getdooropen" ] = "afcaves_pri_getdooropen";

	//Captain Price	Override the door controls! Use the keyboard!		
	level.scr_sound[ "price" ][ "afcaves_pri_usekeyboard" ] = "afcaves_pri_usekeyboard";

	//Captain Price	Open the door! We're running out of time!		
	level.scr_sound[ "price" ][ "afcaves_pri_openthedoor" ] = "afcaves_pri_openthedoor";

	//Captain Price	Come onnn...come onnn...		
	level.scr_sound[ "price" ][ "afcaves_pri_comeoncomeon" ] = "afcaves_pri_comeoncomeon";

	//Shepherd	All units be advised this is Gold Eagle. The site has been compromised.
	level.scr_radio[ "afcaves_shp_sitecompromised" ] = "afcaves_shp_sitecompromised";

	//Shepherd	I am executing directive one-one-six bravo. If you're still inside, your service will be honored. Shepherd out.		echoing P.A. announcement
	level.scr_radio[ "afcaves_shp_directive116" ] = "afcaves_shp_directive116";

	/*-----------------------
	ESCAPE
	-------------------------*/	
	//Captain Price	RUUNN!!!		
	level.scr_sound[ "price" ][ "afcaves_pri_run" ] = "afcaves_pri_run";

	//Captain Price	Keep moving! This place is gonna blow!!!		
	level.scr_sound[ "price" ][ "afcaves_pri_gonnablow" ] = "afcaves_pri_gonnablow";

	/*-----------------------
	AIRSTRIP - ALL
	-------------------------*/	
	//****Shadow Company 6	Get ready to move in!		evil marine radio through a gas mask
	//level.scr_radio[ "afcaves_sc6_getready" ] = "afcaves_sc6_getready";
	
	//****Shadow Company 9	Weapons free, take 'em out!		evil marine radio through a gas mask
	//level.scr_radio[ "afcaves_sc9_weaponsfree" ] = "afcaves_sc9_weaponsfree";
	
	//****Shadow Company 8	Low vis from the tower, you'll have to take 'em on the ground!		evil marine radio through a gas mask
	//level.scr_radio[ "afcaves_sc8_lowvis" ] = "afcaves_sc8_lowvis";
	
	//****Shadow Company 9	Oscar and Romeo teams, sweep the blast zone, pattern Papa Alpha.		evil marine radio through a gas mask
	//level.scr_radio[ "afcaves_sc9_blastzone" ] = "afcaves_sc9_blastzone";
	//radio_dialogue( "afcaves_sc9_blastzone" );
	
	//****Shadow Company 9	Roger that.		evil marine radio through a gas mask
	//level.scr_radio[ "afcaves_sc9_rogerthat" ] = "afcaves_sc9_rogerthat";
	//radio_dialogue( "afcaves_sc9_rogerthat" );

	/*-----------------------
	AIRSTRIP - STORY DIALOGUE
	-------------------------*/
	//Shadow Company HQ	Sir, sandstorm activity is picking up here. It's too risky for flight ops.		stealth wiretap
	level.scr_radio[ "afcaves_schq_riskyforflightops" ] = "afcaves_schq_riskyforflightops";

	//Shepherd	Understood. Head for the tunnel. We'll take the Zodiacs.		stealth wiretap
	level.scr_radio[ "afcaves_shp_takezodiacs" ] = "afcaves_shp_takezodiacs";

	//Shadow Company HQ	Yes sir!		stealth wiretap
	level.scr_radio[ "afcaves_schq_yessir2" ] = "afcaves_schq_yessir2";

	//Captain Price	Head for the tunnel! He's getting away!		
	level.scr_sound[ "price" ][ "afcaves_pri_gettingaway2" ] = "afcaves_pri_gettingaway2";

	//Captain Price	Shepherd mentioned Zodiacs...there must riveracess nearby - let's go!
	level.scr_sound[ "price" ][ "afcaves_pri_rivernearby" ] = "afcaves_pri_rivernearby";

	/*-----------------------
	AIRSTRIP - PRICE GUIDANCE
	-------------------------*/
	//Captain Price	Let's go! Stay close and follow me!		
	level.scr_sound[ "price" ][ "afcaves_pri_stayclose" ] = "afcaves_pri_stayclose";

	//Captain Price	Head for that humvee, I'll cover you!		
	level.scr_sound[ "price" ][ "afcaves_pri_headforhumvee" ] = "afcaves_pri_headforhumvee";

	//Captain Price	Soap! Follow me! Let's go!		
	level.scr_sound[ "price" ][ "afcaves_pri_followmeletsgo" ] = "afcaves_pri_followmeletsgo";

	//Captain Price	To the west, Soap, Go!		
	level.scr_sound[ "price" ][ "afcaves_pri_tothewest" ] = "afcaves_pri_tothewest";

	//Captain Price	Come to me, I'll cover you. Go!		
	level.scr_sound[ "price" ][ "afcaves_pri_cometome" ] = "afcaves_pri_cometome";

	//Captain Price	Make a run for that tower, dead ahead! I'll cover you!		
	level.scr_sound[ "price" ][ "afcaves_pri_towerahead" ] = "afcaves_pri_towerahead";

	//Captain Price	Move forward to that tower!		
	level.scr_sound[ "price" ][ "afcaves_pri_forwardtotower" ] = "afcaves_pri_forwardtotower";

	//Captain Price	Move west towards the tower! Follow me!		
	level.scr_sound[ "price" ][ "afcaves_pri_movewesttower" ] = "afcaves_pri_movewesttower";

	/*-----------------------
	AIRSTRIP - HUMMER GAMEPLAY
	-------------------------*/

	//Captain Price	Targets to the west! Light em up!		
	level.scr_sound[ "price" ][ "afcaves_pri_targetswest" ] = "afcaves_pri_targetswest";

	//Captain Price	Sniper from from the tower! Take it out!		
	level.scr_sound[ "price" ][ "afcaves_pri_sniperfromtower" ] = "afcaves_pri_sniperfromtower";

	/*-----------------------
	AIRSTRIP - DANGER CLOSE
	-------------------------*/
	//Shepherd	Excalibur, this is Gold Eagle. Fire mission - target package Romeo - danger close.		stealth wiretap
	level.scr_radio[ "afcaves_shp_dangerclose" ] = "afcaves_shp_dangerclose";

	//Shadow Company HQ	That's within a hundred meters of your position sir!		stealth wiretap
	level.scr_radio[ "afcaves_schq_100meters" ] = "afcaves_schq_100meters";

	//Shepherd	That's not a suggestion! Send it!		stealth wiretap
	level.scr_radio[ "afcaves_shp_sendit" ] = "afcaves_shp_sendit";

	//Shadow Company HQ	Roger, fire mission danger close!		stealth wiretap
	level.scr_radio[ "afcaves_schq_firemissionclose" ] = "afcaves_schq_firemissionclose";

	//Captain Price	Soaap!! Incomiiing!!! Fall baack, fall baaack!!!		
	//level.scr_sound[ "price" ][ "afcaves_pri_fallback" ] = "afcaves_pri_fallback";
	
	
	//Captain Price	Soaap!! Incomiiing!!! Get down! Get down
	level.scr_sound[ "price" ][ "afcaves_pri_fallback2" ] = "afcaves_pri_fallback2";
	
	//Get the hell out...Artillery inbound
	//level.scr_sound[ "price" ][ "afcaves_pri_fallback3" ] = "afcaves_pri_fallback3";
	

	//Captain Price	Since when does Shepherd care about danger close... 		
	level.scr_sound[ "price" ][ "afcaves_pri_sincewhen" ] = "afcaves_pri_sincewhen";
}


/****************************************************************************
    UTILITY
****************************************************************************/ 
riot_shield_quick_sprint()
{
	self endon( "death" );
	self riotshield_sprint_on();
	wait( RandomFloatRange( 2.8, 3.2 ) );
//	self waittill( "goal" );
	self riotshield_sprint_off();
}

vehicle_think()
{
	switch( self.vehicletype )
    {
		case "zodiac":
   			self thread vehicle_zodiac_think();
    		break;
    	case "littlebird":
    		self thread vehicle_littlebird_think();
    		break;
    }
}

vehicle_zodiac_think()
{
	PlayFXOnTag( getfx( "zodiac_wake_geotrail_oilrig" ), self, "tag_origin" );
}

vehicle_littlebird_think()
{
	self endon( "death" );
	if ( self.classname == "script_vehicle_littlebird_armed" )
	{
		self thread maps\_attack_heli::heli_default_missiles_on();
		waittillframeend;
		foreach ( turret in self.mgturret )
		{
			turret SetMode( "manual" );
			turret StopFiring();
		}
	}
}

triggersEnable( triggerName, noteworthyOrTargetname, bool )
{
	AssertEx( IsDefined( bool ), "Must specify true/false parameter for triggersEnable() function" );
	aTriggers = GetEntArray( triggername, noteworthyOrTargetname );
	AssertEx( IsDefined( aTriggers ), triggerName + " does not exist" );
	if ( bool == true )
		array_thread( aTriggers, ::trigger_on );
	else
		array_thread( aTriggers, ::trigger_off );
}

dialogue_execute( sLineToExecute )
{
	self endon( "death" );
	self dialogue_queue( sLineToExecute );
}

dialogue_execute_temp( sLineToExecute )
{
	hint_temp( sLineToExecute, 3 );

}

radio_dialogue_temp( sLineToExecute )
{
	hint_temp( sLineToExecute, 1.5 );
}

hint_temp( string, timeOut )
{
	hintfade = 0.5;

	level endon( "clearing_hints" );

	if ( IsDefined( level.tempHint ) )
		level.tempHint destroyElem();

	level.tempHint = createFontString( "default", 1.5 );
	level.tempHint setPoint( "BOTTOM", undefined, 0, -60 );
	level.tempHint.color = ( 1, 1, 1 );
	level.tempHint SetText( string );
	level.tempHint.alpha = 0;
	level.tempHint FadeOverTime( 0.5 );
	level.tempHint.alpha = 1;
	level.tempHint.sort = 2;
	wait( 0.5 );
	level.tempHint endon( "death" );

	if ( IsDefined( timeOut ) )
		wait( timeOut );
	else
		return;

	level.tempHint FadeOverTime( hintfade );
	level.tempHint.alpha = 0;
	wait( hintfade );

	level.tempHint destroyElem();
}

AI_player_seek()
{
	if ( !isdefined( self ) )
		return;
	self endon( "death" );
	self ClearGoalVolume();
	self endon( "stop_seeking" );
	if ( self.code_classname == "actor_enemy_riotshield" )
		self thread riot_shield_quick_sprint();
	//self enable_danger_react( 3 );
	//self.fixednode = false;
	//self.ignoreSuppression = true;
	//self.goalradius = 800;
	//self.interval = 0;
	//self.baseaccuracy = 5;
	//self.neverEnableCQB = true;
	//self.grenadeawareness = 0;
	//self.ignoreSuppression = true;
	//self.goalheight = 100;
	//self.aggressivemode = true;	//dont linger at cover when you cant see your enemy
	newGoalRadius = Distance( self.origin, level.player.origin );
	while ( IsAlive( self ) )
	{
		wait 1;
		self.goalradius = newGoalRadius;
		//self SetGoalPos( self LastKnownPos( level.player ) );
		self SetGoalEntity( level.player );
		//self SetGoalPos( level.player.origin );
		newGoalRadius -= 175;
		if ( newGoalRadius < 512 )
		{
			newGoalRadius = 512;
			return;
		}
	}
}


smoke_throw( aSmokeOrgs, sFlagToStop )
{
	level endon( sFlagToStop );
	while ( true )
	{
		smokeTarget = undefined;
		foreach ( org in aSmokeOrgs )
		{
			//MagicGrenade( "smoke_grenade_american_no_visblock", org.origin, org.origin + ( 0, 0, 1), RandomFloat( 1.1 ) );
			PlayFX( getfx( "smokescreen" ), org.origin );
			org thread play_sound_in_space( "smokegrenade_explode_default" );
			wait( RandomFloatRange( .1, .3 ) );
		}
		wait( 28 );
		if ( flag( sFlagToStop ) )
			break;
	}

}

make_door_from_prefab( sTargetname )
{
	ents = GetEntArray( sTargetname, "targetname" );
	door_org = undefined;
	door_models = [];
	door_brushes = [];
	foreach ( ent in ents )
	{
		if ( ent.code_classname == "script_brushmodel" )
		{
			door_brushes[ door_brushes.size ] = ent;
			if ( ( IsDefined( self.script_noteworthy ) ) && ( self.script_noteworthy == "blocker" ) )
				door_blocker = ent;
			continue;
		}
		if ( ent.code_classname == "script_model" )
		{
			door_models[ door_models.size ] = ent;
			continue;
		}

	}
	door_org = Spawn( "script_origin", ( 0, 0, 0 ) );
	door_org.origin = door_brushes[ 0 ].origin;
	door_org.angles = door_brushes[ 0 ].angles;

	foreach ( model in door_models )
		model LinkTo( door_org );
	foreach ( brush in door_brushes )
		brush LinkTo( door_org );

	door = door_org;

	return door;
}

escape_timer_invisible( iSeconds )
{
	level endon( "obj_escape_complete" );
	level endon( "kill_timer" );

	/*-----------------------
	TIMER SETUP
	-------------------------*/		
	//level.hudTimerIndex = 20;
	//level.timer = maps\_hud_util::get_countdown_hud();
	//level.timer SetPulseFX( 30, 900000, 700 );// something, decay start, decay duration
	// Reach exit in: 
	//level.timer.label = &"AF_CAVES_TIME_REMAINING";
	//level.timer SetTenthsTimer( iSeconds );

	/*-----------------------
	TIMER EXPIRED
	-------------------------*/	
	thread timer_tick();
	wait( iSeconds );
	//level.timer Destroy();
	level thread mission_failed_out_of_time();
}

timer_tick()
{
	level endon( "obj_escape_complete" );
	level endon( "kill_timer" );
	while ( true )
	{
		wait( 1 );
		level.player thread play_sound_on_entity( "countdown_beep" );
	}
}

mission_failed_out_of_time()
{
	level.player endon( "death" );
	level endon( "kill_timer" );
	level notify( "mission failed" );
	MusicStop( 1 );
	// Mission failed
	level.player PlayLocalSound( "af_caves_selfdestruct" );
	//exploder( "control_room_detonate" );
	PlayFX( getfx( "player_death_explosion" ), level.player.origin );
	Earthquake( 1, 1, level.player.origin, 100 );
	// You did not reach the cave exit in time.
	SetDvar( "ui_deadquote", &"AF_CAVES_RAN_OUT_OF_TIME" );
	level notify( "mission failed" );
	maps\_utility::missionFailedWrapper();
	level.player kill();
	level notify( "kill_timer" );
	
}

kill_timer()
{
	level notify( "kill_timer" );
	//if ( IsDefined( level.timer ) )
		//level.timer Destroy();
}

cooking_destructible_think()
{
	//vehicle_slamraam_destroyed
}

generic_damage_triggers_think()
{

}

spawn_vehicles_from_targetname_and_drive_on_flag( sTargetname, sFlag )
{
	flag_wait( sFlag );
	spawn_vehicles_from_targetname_and_drive( sTargetname );
}

AI_ambient_airstrip_think()
{
	self endon( "death" );
	self.health = 1;
	self.noragdoll = true;
	self.ignoreall = true;
	self.diequietly = true;
	self disable_pain();
	self set_allowdeath( true );
	self gun_remove();
	self thread AI_ambient_airstrip_ignored_by_price();
	reference = self.spawner;
	animation = self.spawner.animation;
	self.deathanim = level.scr_anim[ "generic" ][ animation + "_death" ];

	self.fxSmokeTag = [];
	self.fxFireTag = [];

	/*-----------------------
	WAIT FOR A FLAG, IF APPLICABLE
	-------------------------*/	
	if ( IsDefined( self.script_flag ) )
	{
		reference anim_generic_first_frame( self, animation );
		flag_wait( self.script_flag );
	}

	/*-----------------------
	SPECIFICS PER ANIM
	-------------------------*/	
	slowDownRate = undefined;
	timesLooped = undefined;
	switch( animation )
	{
		case "civilian_leaning_death":
			break;
		case "hunted_dazed_walk_B_blind":
			self.fxSmokeTag[ 0 ] = "tag_origin";
			timesLooped = 2;
			break;
		case "hunted_dazed_walk_C_limp":
			timesLooped = 4;
			slowDownRate = .7;
			self.fxSmokeTag[ 0 ] = "tag_origin";
			break;
		case "civilian_crawl_2":
			slowDownRate = .5;
			self.fxSmokeTag[ 0 ] = "tag_bipod";
//			self.fxFireTag[ 0 ] = "tag_stowed_hip_rear";
//			self.fxFireTag[ 0 ] = "tag_stowed_hip_le";
			self.fxFireTag[ 0 ] = "tag_shield_back";
//			self.fxFireTag[ 1 ] = "tag_reflector_arm_ri";
//			self.fxFireTag[ 4 ] = "tag_reflector_arm_le";
			self.a.pose = "prone";
			break;
		case "civilian_crawl_1":
			self.fxSmokeTag[ 0 ] = "tag_origin";
			self.fxFireTag[ 0 ] = "tag_shield_back";
			self.a.pose = "prone";
			break;
	}

	if ( self.fxSmokeTag.size )
		self thread play_looping_fx_on_tags( self.fxSmokeTag, "smoke" );
	if ( self.fxFireTag.size )
		self thread play_looping_fx_on_tags( self.fxFireTag, "fire" );
	if ( IsDefined( slowDownRate ) )
	{
		reference thread anim_generic_custom_animmode( self, "gravity", animation );
		wait( .1 );
		self SetAnim( level.scr_anim[ "generic" ][ animation ], 1, 0.2, slowDownRate );
		time = GetAnimLength( level.scr_anim[ "generic" ][ animation ] );
		if ( !isdefined( timesLooped ) )
			timesLooped = 3;
		wait( time * timesLooped );
	}
	else
	{
		reference anim_generic_custom_animmode( self, "gravity", animation );
		if ( isdefined( timesLooped ) )
			anim_generic_custom_animmode( self, "gravity", animation );
	}

	/*-----------------------
	PRE-DEATH SPECIFICS
	-------------------------*/	
	switch( animation )
	{
		case "civilian_leaning_death":
			self.a.nodeath = true;
			break;
	}
	//self.a.nodeath = true;
	self.deathanim = undefined;
	self anim_stopanimscripted();
	self.skipDeathAnim = true;
	self Kill();
}

play_looping_fx_on_tags( aTags, sType )
{

	if ( getdvar( "caves_fire" ) == "0" )
		return;
	
	self endon( "death" );
	fx = undefined;
	if ( sType == "fire" )
	{
		fx = getfx( "body_fire_01" );
	}
	else if ( sType == "smoke" )
	{
		fx = getfx( "body_smoke_01" );
	}
	foreach ( tag in aTags )
	{
		self thread play_fx_on_tag_till_dead( fx, tag, sType );
	}
}

play_fx_on_tag_till_dead( fx, tag, sType )
{
	additionalDelay = 0;
	if ( sType == "smoke" )
		additionalDelay = 3;		// if somoke, wait an additional X time before playing fx again

	self endon( "death" );
	while ( true )
	{
		wait( additionalDelay );
		PlayFXOnTag( fx, self, tag );
		wait( .2 );
		StopFXOnTag( fx, self, tag );
	}
}

AI_ambient_airstrip_ignored_by_price()
{
	self endon( "death" );
	self.ignoreme = true;
//	distsquared = 128 * 128;
//	while( true )
//	{
//		wait( .3 );
//		if ( DistanceSquared( self.origin, level.price.origin ) < distsquared )
//			break;
//	}
//	self.ignoreme = false;
}


backhalf_loadout()
{
	// SRS take weapons so the player doesn't have 4 weapons when using a start point
	level.player TakeWeapon( level.primaryweapon );
	level.player TakeWeapon( level.secondaryweapon );

	level.player GiveWeapon( "masada_digital_eotech" );
	level.player GiveWeapon( "deserteagle" );
	level.player SwitchToWeapon( "masada_digital_eotech" );
}

debug()
{
	wait( .2 );
	airstrip_player = GetEnt( "airstrip_player", "targetname" );
	level.player SetOrigin( airstrip_player.origin );
	level.player SetPlayerAngles( airstrip_player.angles );
	wait( 1 );
	ambient_airstrip = GetEntArray( "ambient_airstrip", "targetname" );
	array_spawn( ambient_airstrip, true );
}

c4_barrels()
{
	c4_barrels = GetEntArray( "c4_barrel", "targetname" );
	array_thread( c4_barrels, ::c4_barrels_think );
}

c4_barrels_think()
{
	level endon( "mission failed" );
	level endon( "missionfailed" );
	level endon( "player_detonated_explosives" );
	level endon( "pre_explosion_happening" );
	level endon( "player_touching_cave_exit" );
	level endon( "player_escaped" );
	level endon( "player_invulnerable" );
	
	eDamageTrigger = self;
	eDamageTrigger SetCanDamage( true );
	//determine barrel hitpoints based on difficulty
	eDamageTrigger.hitpoints = undefined;
	switch( level.gameSkill )
	{
		case 0:// easy
			eDamageTrigger.hitpoints = 5;
			break;
		case 1:// regular
			eDamageTrigger.hitpoints = 4;
			break;
		case 2:// hardened
			eDamageTrigger.hitpoints = 2;
			break;
		case 3:// veteran
			eDamageTrigger.hitpoints = 1;
			break;
	}

	while ( !flag( "player_detonated_explosives" ) )
	{
		
		eDamageTrigger waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags );
		if ( ( isdefined( attacker ) ) && ( isplayer( attacker ) ) )
		{
			if ( idFlags & 8 ) // bullet penetration occurred
				continue;
			//dont explode if you shot through an enemy...unless on veteran
			if ( ( IsDefined( level.last_player_damage ) ) && ( level.last_player_damage == GetTime() ) && ( level.gameskill != 3 ) )
				continue;
			//knock hitpoints down one
			if ( eDamageTrigger.hitpoints > 0 )
				eDamageTrigger.hitpoints -= 1;
			//remove all hitpoints if it was a grenade, etc
			if ( IsDefined( type ) && ( IsSubStr( type, "MOD_GRENADE" ) || IsSubStr( type, "MOD_EXPLOSIVE" ) || IsSubStr( type, "MOD_PROJECTILE" ) ) )
				break;
			//blow up the barrel if hitpoints is zero
			if ( eDamageTrigger.hitpoints == 0 )
				break;
		}
	}

	thread c4_barrel_explode();
	flag_set( "player_detonated_explosives" );
}

c4_barrel_explode()
{
	level notify( "c4_barrels_exploding" );
	level endon( "c4_barrels_exploding" );
	level endon ( "pre_explosion_happening" );
	level endon ( "player_touching_cave_exit" );
	level endon ( "player_escaped" );
	level endon ( "player_invulnerable" );
	level.player PlayLocalSound( "af_caves_selfdestruct" );
	PlayFX( getfx( "player_death_explosion" ), level.player.origin );
	Earthquake( 1, 1, level.player.origin, 100 );
	// Mission Failed.\nYou shot and detonated the rigged explosives.
	SetDvar( "ui_deadquote", &"AF_CAVES_MISSIONFAIL_EXPLOSIVES" );
	level notify( "mission failed" );
	maps\_utility::missionFailedWrapper();
	level.player kill();
}

c4_packs_think()
{
	self thread c4_barrels_think();	//make rigged c4 explosive as well
	wait( RandomFloatRange( 0, .6 ) );
	if ( cointoss() )
	{
		PlayFXOnTag( getfx( "light_c4_blink_nodlight" ), self, "tag_fx" );
	}
	else
	{
		PlayFXOnTag( getfx( "c4_light_blink_dlight" ), self, "tag_fx" );
	}
	flag_wait( "end_cave_collapse" );
	//stopFXOnTag( getfx( "light_c4_blink_nodlight" ), self, "tag_fx" );
	self Delete();
}

AI_ignored_think()
{
	self.ignoreme = true;
}


fx_management()
{
	/*-----------------------
	CREATE ARRAYS OF FX FOR THE LEVEL
	-------------------------*/	
	level.fx_start_to_ledge = [];
	level.fx_ledge_to_airstrip = [];
	
	/*-----------------------
	GET VOLUMES THAT ENCOMPASS EFFECTS
	-------------------------*/	
	fx_volume_start_to_ledge = getent( "fx_volume_start_to_ledge", "targetname" );
	fx_volume_ledge_to_airstrip = getent( "fx_volume_ledge_to_airstrip", "targetname" );

	
	/*-----------------------
	CATALOG ALL FX BY VOLUME
	-------------------------*/	
	dummy = spawn( "script_origin", ( 0, 0, 0 ) );
	for ( i = 0;i < level.createfxent.size;i++ )
	{
		EntFx = level.createfxent[ i ];
		dummy.origin = EntFx.v[ "origin" ];
		if ( dummy istouching( fx_volume_start_to_ledge ) )
		{
			level.fx_start_to_ledge[ level.fx_start_to_ledge.size ] = EntFx;
			continue;
		}
		if ( dummy istouching( fx_volume_ledge_to_airstrip ) )
		{
			level.fx_ledge_to_airstrip[ level.fx_ledge_to_airstrip.size ] = EntFx;
			continue;
		}

	}
	dummy delete();

}


//destructible_management()
//{
//	/*-----------------------
//	TURN OFF ALL DESTRUCTIBLES IN MY HALF
//	-------------------------*/	
//	fx_volume_ledge_to_airstrip = getentarray( "fx_volume_ledge_to_airstrip", "targetname" );
//	thread mask_destructibles_in_volumes( fx_volume_ledge_to_airstrip );
//	thread mask_interactives_in_volumes( fx_volume_ledge_to_airstrip );
//	
//	flag_wait( "steamroom_halfway_point" );
//
//	/*-----------------------
//	TURN OFF ALL DESTRUCTIBLES IN START, RE-ENABLE ONES IN SECOND HALF
//	-------------------------*/	
//	fx_volume_start_to_ledge = getentarray( "fx_volume_start_to_ledge", "targetname" );
//	mask_destructibles_in_volumes( fx_volume_start_to_ledge );
//	mask_interactives_in_volumes( fx_volume_start_to_ledge );
//	
//	activate_destructibles_in_volume( fx_volume_ledge_to_airstrip );
//	activate_interactives_in_volume( fx_volume_ledge_to_airstrip );
//}