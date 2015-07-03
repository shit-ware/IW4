#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

UPDATE_TIME = 0.05;		// Time between player input checks.
BLEND_TIME = 0.5;		// Blend time for lean animations.
CONST_MPHCONVERSION = 17.6;

SHOOT_BLEND_TIME = 0.1;
SHOOT_ARM_UP_DELAY = 1.0;
SHOOT_FIRE_TIME = 0.05;
SHOOT_AMMO_COUNT = 32;

SLEEVE_FLAP_SPEED = 65.0;
SLEEVE_FLAP_MAX_RATE = 1.5;
SLEEVE_FLAP_MIN_RATE = 0.75;
SLEEVE_FLAP_MAX_WEIGHT = 1.0;
SLEEVE_FLAP_MIN_WEIGHT = 0.1;

STEERING_BLEND_TIME = 0.08;

CLOSE_GUY_DIST = 62500;

zodiac_preLoad( playerHandModel )
{
	flag_init( "player_can_die_on_zodiac" );
	flag_init( "player_shot_on_zodiac" );
	flag_set( "player_can_die_on_zodiac" );

	// set player hand model
	if ( !isdefined( playerHandModel ) )
		level.zodiac_playerHandModel = "viewhands_player_udt";
	else
		level.zodiac_playerHandModel = playerHandModel;

	level.zodiac_playerZodiacModel = "vehicle_zodiac_viewmodel";

	// set gun
	level.zodiac_gunModel = "viewmodel_miniUZI";

	level.zodiac_gun = "uzi";

	// precahe models and itmes
	PreCacheModel( level.zodiac_playerHandModel );
	PreCacheModel( level.zodiac_playerZodiacModel );
	PreCacheModel( level.zodiac_gunModel );
	PreCacheItem( level.zodiac_gun );

	// load gun effects
	level.zodiac_gunFlashFx = LoadFX( "muzzleflashes/uzi_flash_view" );
	level.zodiac_gunShellFx = LoadFX( "shellejects/pistol_view" );

	level.zodiac_sound_overrides = [];
	level.zodiac_sound_overrides[ "weap_glock_fire_snowmobile" ] = "weap_miniuzi_fire_plr";

	zodiac_anims();

	// Hold ^3[{+speed_throw}]^7 to shoot.
	add_hint_string( "zodiac_attack", &"SCRIPT_PLATFORM_SNOWMOBILE_ATTACK", ::should_stop_zodiac_attack_hint );
	// Hold ^3[{+attack}]^7 to drive.
	add_hint_string( "zodiac_drive", &"SCRIPT_PLATFORM_SNOWMOBILE_DRIVE", ::should_stop_zodiac_drive_hint );
	
	add_hint_string( "zodiac_reverse" , &"SCRIPT_PLATFORM_SNOWMOBILE_REVERSE", ::should_stop_zodiac_reverse_hint );

}

drive_vehicle()
{
	Assert( self.code_classname == "script_vehicle" );
	vehicle = self;
	vehicle MakeUsable();

	self waittill( "vehicle_mount", player );
	Assert( IsDefined( player ) );
	Assert( player.classname == "player" );

	if ( !getdvarint( "scr_zodiac_test" ) && is_default_start() )
	{
		delayThread( 20, ::display_hint, "zodiac_attack" );
		delayThread( 3, ::display_hint, "zodiac_drive" );
	}

	player.vehicle = vehicle;

	vehicle.zodiac_3rdPersonModel = vehicle.model;
	vehicle.zodiacAmmoCount = SHOOT_AMMO_COUNT;

	vehicle.animname = "zodiac_player";
	vehicle assign_animtree();

	vehicle MakeUnusable();
	vehicle DontCastShadows();


	player thread reverse_hint( vehicle );	
	player thread drive_target_enemy( vehicle );
	player thread drive_crash_detection( vehicle );
	player thread drive_camera( vehicle );

	player thread drive_notetrack_sounds( vehicle, "pullout_anim" );
	player thread drive_notetrack_sounds( vehicle, "fire_anim" );
	player thread drive_notetrack_sounds( vehicle, "reload_anim" );
	player thread drive_notetrack_sounds( vehicle, "putaway_anim" );

	player drive_switch_to_1st_person( vehicle );
	vehicle waittill_either( "vehicle_dismount", "death" );
//	player drive_switch_to_3rd_person( vehicle );

	player.vehicle = undefined;
}



get_ai_for_player()
{
	return GetAIArray( "bad_guys" );
}

get_ai_for_price()
{
	return GetAIArray( "bad_guys" );
}


drive_target_enemy( vehicle )
{
	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );
	vehicle endon( "stop_targetting" );

	check_dist_for_hargroves_boat[ "player" ] = 700*700;
	check_dist_for_enemy_boat[ "player" ] = 1300*1300;
	check_dist_for_stationary_guys[ "player" ] = 1300*1300;

	check_dist_for_hargroves_boat[ "price" ] = 1000*1000;
	check_dist_for_enemy_boat[ "price" ] = 3800*3800;
	check_dist_for_stationary_guys[ "price" ] = 4300*4300;

	ai_get_func[ "player" ] = ::get_ai_for_player;
	ai_get_func[ "price" ] = ::get_ai_for_price;
	
	baseYawSettings[ "price" ][ "right" ] = spawnstruct();
	baseYawSettings[ "price" ][ "right" ].min = -80;
	baseYawSettings[ "price" ][ "right" ].max = 5;
	baseYawSettings[ "price" ][ "right" ].ideal = -25;
	baseYawSettings[ "price" ][ "right" ].retainEnemyMin = -55;
	baseYawSettings[ "price" ][ "right" ].retainEnemyMax = 5;
	baseYawSettings[ "price" ][ "left" ] = spawnstruct();
	baseYawSettings[ "price" ][ "left" ].min = -5;
	baseYawSettings[ "price" ][ "left" ].max = 80;
	baseYawSettings[ "price" ][ "left" ].ideal = 25;
	baseYawSettings[ "price" ][ "left" ].retainEnemyMin = -5;
	baseYawSettings[ "price" ][ "left" ].retainEnemyMax = 55;
	
	baseYawSettings[ "player" ] = spawnstruct();
	baseYawSettings[ "player" ].min = -20;
	baseYawSettings[ "player" ].max = 20;
	baseYawSettings[ "player" ].ideal = 0;
	
	checking = "player";
	
	for ( ;; )
	{
		check_dist = check_dist_for_hargroves_boat[ checking ];
		ai = [[ ai_get_func[ checking ] ]]();
		bestAngle = 180.1;
		enemy = undefined;
		
		currentguy = self;
		if ( checking == "price" )
			currentguy = level.price;
		
		my_org = currentguy.origin;
		
		yawSettings = baseYawSettings[ "player" ];
		if ( checking == "price" )
		{
			if ( !isdefined( currentguy.a.boat_pose ) )
			{
				// Price hasn't started his boat AI anim script yet
				checking = "player";
				wait .05;
				continue;
			}
			yawSettings = baseYawSettings[ "price" ][ currentguy.a.boat_pose ];
		}
		
		foreach ( guy in ai )
		{
			his_org = guy.origin;

			if ( IsDefined( guy.ridingvehicle ) )
			{
				if ( guy.ridingvehicle == level.enemy_boat )
					check_dist = check_dist_for_hargroves_boat[ checking ];
				check_dist = check_dist_for_enemy_boat[ checking ];
			}
			else
				check_dist = check_dist_for_stationary_guys[ checking ];// helps make death animations more visible for those guys that are stationary.
			
			dist = distancesquared( his_org, my_org );
			if ( dist > check_dist )
				continue;
			
			anglesToGuy = vectorToAngles( his_org - my_org );
			pitch = AngleClamp180( anglesToGuy[0] );
			if ( abs( pitch ) > 15 )
				continue;
			
			yaw = AngleClamp180( anglesToGuy[1] - currentguy.angles[1] );
			
			if ( yaw < yawSettings.min || yaw > yawSettings.max )
				continue;
			
			if ( checking == "price" )
			{
				// price should always shoot the guys in close proximity (if he can aim at them)
				if ( dist < CLOSE_GUY_DIST )
				{
					enemy = guy;
					break;
				}
				// don't change price's enemy if the old one is still good
				if ( isDefined( currentguy.zodiac_enemy ) && guy == currentguy.zodiac_enemy && yaw >= yawSettings.retainEnemyMin && yaw <= yawSettings.retainEnemyMax )
				{
					enemy = guy;
					break;
				}
			}
			
			yaw = abs( AngleClamp180( yaw - yawSettings.ideal ) );
			if ( yaw < bestAngle )
			{
				bestAngle = yaw;
				enemy = guy;
			}
		}
		
		currentguy.zodiac_enemy = enemy;
		
		//if( checking == "price" && IsDefined( currentguy.zodiac_enemy ) )
		//	thread draw_line_from_ent_to_ent_for_time( currentguy.zodiac_enemy, currentguy, 1 , 1 , 1 , .2 );
		wait( 0.1 );
		
		if ( checking == "price" )
			checking = "player";
		else
			checking = "price";
	}
}

drive_crash_detection( vehicle )
{
	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );
	level endon( "avalanche_begins" );

	vehicle waittill_vehicle_crashes();

	yaw_velocity = vehicle Vehicle_GetSpeed();
	yaw_velocity *= CONST_MPHCONVERSION;
	velocity = ( 0, yaw_velocity, 64 );

	self thread drive_crash_slide( vehicle, velocity );
	self player_dismount_vehicle();
}

waittill_vehicle_crashes()
{
	level endon( "player_crashes" );// from triggers in the map
	self waittill( "veh_collision" );
}


drive_crash_slide( vehicle, velocity )
{
	vehicle waittill( "vehicle_dismount" );

	self BeginSliding( velocity );

	if ( flag( "player_can_die_on_zodiac" ) )
		self kill_wrapper();

	wait( 1.0 );

	//self EndSliding();
}


drive_camera( vehicle )
{
	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );

	for ( ;; )
	{
		vehicle waittill( "third_person" );
		self drive_switch_to_3rd_person( vehicle );

		vehicle waittill( "first_person" );
		self drive_switch_to_1st_person( vehicle );
	}
}


drive_notetrack_sounds( vehicle, animflag )
{
	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );

	for ( ;; )
	{
		vehicle waittill( animflag, notetrack );

		prefix = GetSubStr( notetrack, 0, 3 );

		if ( prefix == "ps_" )
		{
			alias = GetSubStr( notetrack, 3 );

			if ( IsDefined( level.zodiac_sound_overrides[ alias ] ) )
				alias = level.zodiac_sound_overrides[ alias ];

			vehicle PlaySound( alias );
			continue;
		}
	}
}


drive_switch_to_1st_person( vehicle )
{
	if ( IsDefined( vehicle.firstPerson ) )
		return;

	vehicle SetModel( level.zodiac_playerZodiacModel );
	vehicle Attach( level.zodiac_playerHandModel, "tag_player" );
	vehicle ClearAnim( vehicle getanim( "root" ), 0 );

	vehicle.firstPerson = true;

	self thread drive_firstperson_anims( vehicle );
}


drive_switch_to_3rd_person( vehicle )
{
	if ( !isDefined( vehicle.firstPerson ) )
		return;

	if ( IsDefined( vehicle.gun_attached ) )
	{
		vehicle Detach( level.zodiac_gunModel, "tag_weapon_left" );
		vehicle.gun_attached = undefined;
	}

	vehicle Detach( level.zodiac_playerHandModel, "tag_player" );
	vehicle SetModel( vehicle.zodiac_3rdPersonModel );
	vehicle ClearAnim( vehicle getanim( "root" ), 0 );

	vehicle.firstPerson = undefined;

	vehicle notify( "kill_anims" );
}


drive_firstperson_anims( vehicle )
{
	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );
	vehicle endon( "kill_anims" );
	vehicle endon( "cleanup" );

	self childthread drive_shooting_anims( vehicle );
}

shootable_stuff_assist_damage( obj )
{
	// don't assist destruction of these objects.
	dont_assist_destructible_destruction_here = getstructarray( "dont_assist_destructible_destruction_here", "targetname" );
	foreach ( spot in dont_assist_destructible_destruction_here )
	{
		Assert( IsDefined( spot.radius ) );
		if ( Distance( spot.origin, obj.origin ) < spot.radius )
			return;
	}

	self notify( "new_shootable_stuff_assist" );
	self endon( "new_shootable_stuff_assist" );

	obj waittill( "damage", ammount, attacker, dvec, p, type );
	for ( i = 0; i < 10; i++ )
	{
		wait .05;
		obj notify( "damage", ammount, level.player, dvec, p, type );
	}
}



SHOOTABLE_STUFF_COS = 0.965925;// Cos( 15 )
drive_magic_bullet_get_end( vehicle, start, noshot )
{
	end = SpawnStruct();

	if ( IsAlive( self.zodiac_enemy ) )
	{
		end.obj = self.zodiac_enemy;
		end.origin = self.zodiac_enemy GetShootAtPos() + randomvectorrange( -10, 10 ) + (0,0,-1*randomfloat(40 ) );
		return end;
	}

	shootable_stuff = array_combine( GetEntArray( "destructible_toy", "targetname" ), GetEntArray( "explodable_barrel", "targetname" ) );

	//try to shoot stuff ahead when there aren't any snowmbobile_enemy's.. 
	foreach ( obj in shootable_stuff )
	{
		if ( Distance( level.player.origin, obj.origin ) > 2300 )
			continue;

		if ( ! within_fov_2d( level.player.origin, level.player.angles, obj.origin, SHOOTABLE_STUFF_COS ) )
			continue;

		if ( ! level.player SightConeTrace( obj GetShootAtPos(), obj ) )
			continue;

		end.obj = obj;
		end.origin = obj.origin;

		thread shootable_stuff_assist_damage( obj );
		return end;
	}

	//target the last remaining boat drivers
	shootable_boat_drivers = get_shootable_boatdrivers();

	foreach ( obj in shootable_boat_drivers )
	{
		if ( Distance( level.player.origin, obj.origin ) > 1300 )
			continue;

		if ( ! within_fov_2d( level.player.origin, level.player.angles, obj.origin, Cos( 15 ) ) )
			continue;

		if ( ! level.player SightConeTrace( obj.origin + ( 0, 0, 16 ), obj ) )
			continue;

		end.obj = obj;
		end.origin = obj.origin;
		end.shootable_driver = true;
		return end;
	}

	if ( IsDefined( noshot ) )
		return end;

	angles = vehicle GetTagAngles( "tag_flash" );
	forward = AnglesToForward( angles );
	end.origin = start + forward * 1500;

	return end;

}

get_shootable_boatdrivers()
{
	boats = GetEntArray( "script_vehicle_zodiac_physics", "classname" );

	boatdrivers = [];
	foreach ( boat in boats )
	{
		if ( boat  == level.players_boat )
			continue;
		if ( boat  == level.enemy_boat )
			continue;


		if ( IsSpawner( boat ) )
			continue;

		if ( boat.riders.size > 1 )
			continue;

		if ( !boat.riders.size )
			continue;

		if ( IsDefined( boat.script_noteworthy ) && boat.script_noteworthy == "bobbing_boat" )
			continue;

		boat thread wipeout_when_not_in_fov();

		Assert( boat.riders[ 0 ].vehicle_position == 0 );
		Assert( IsDefined( boat.riders[ 0 ].ridingvehicle ) );
		boatdrivers[ boatdrivers.size ] = boat.riders[ 0 ];
	}
	return boatdrivers;

}

FOV_FOR_WIPEOUT = 0.5;// Cos( 60 );

wipeout_when_not_in_fov()
{
	self notify( "wipeout_when_not_in_fov" );
	self endon( "wipeout_when_not_in_fov" );
	self endon( "death" );

	while ( within_fov_of_players( self.origin, FOV_FOR_WIPEOUT ) )
		wait .05;

	self.wipeout = true;
}

drive_magic_bullet_trace( obj, start, end )
{
	trace = BulletTrace( start, end, false, self );
	if ( !isdefined( trace[ "entity" ] ) )
		return false;
	if ( trace[ "entity" ] != obj )
		return false;
	return true;
}



drive_magic_bullet( vehicle )
{
	start = vehicle GetTagOrigin( "tag_flash" );

	end = drive_magic_bullet_get_end( vehicle, start );

	if( flag( "player_in_sight_of_boarding" ) )
		MagicBullet( level.zodiac_gun, start, start + ( 0, 0, 255 ), self );
	else
		MagicBullet( level.zodiac_gun, start, end.origin, self );
		
	PlayFXOnTag( level.zodiac_gunFlashFx, vehicle, "tag_flash" );
	PlayFXOnTag( level.zodiac_gunShellFx, vehicle, "tag_brass" );
	
	level.player PlayRumbleOnEntity( "smg_fire" );



	if ( !isdefined( end.obj ) )
		return;

	if ( !isai( end.obj ) )
		end.obj notify( "damage", 50, level.player, self.origin, end.obj.origin, "MOD_PISTOL_BULLET", "", "" );

	if ( IsDefined( end.shootable_driver ) )
	{
		driver_death( end.obj );
		return;
	}
//		end.obj common_scripts\_destructible::force_explosion();
}

driver_death( guy )
{
	guy notify( "newanim" );
	Assert( !IsAI( guy ) );
	guy StartRagdoll();
	guy.ridingvehicle.wipeout = true;
}

drive_blend_anims_with_steering( vehicle, animflag, endNotify, leftAnim, centerAnim, rightAnim )
{
	vehicle endon( endNotify );

	vehicle SetFlaggedAnimRestart( animflag, vehicle getanim( leftAnim ), 0.001, STEERING_BLEND_TIME, 1.0 );
	vehicle SetFlaggedAnimRestart( animflag, vehicle getanim( centerAnim ), 0.001, STEERING_BLEND_TIME, 1.0 );
	vehicle SetFlaggedAnimRestart( animflag, vehicle getanim( rightAnim ), 0.001, STEERING_BLEND_TIME, 1.0 );

	for ( ;; )
	{
		steerValue = vehicle Vehicle_GetSteering() * -1.0;

		// never set a weight to zero so that all the anims continue to play
		if ( steerValue >= 0.0 )
		{
			leftWeight = 0.001;
			centerWeight = -0.999 * steerValue + 1.0;
			rightWeight = 0.999 * steerValue + 0.001;
		}
		else
		{
			leftWeight = -0.999 * steerValue + 0.001;
			centerWeight = 0.999 * steerValue + 1.0;
			rightWeight = 0.001;
		}

		vehicle SetFlaggedAnim( animflag, vehicle getanim( leftAnim ), leftWeight, STEERING_BLEND_TIME, 1.0 );
		vehicle SetFlaggedAnim( animflag, vehicle getanim( centerAnim ), centerWeight, STEERING_BLEND_TIME, 1.0 );
		vehicle SetFlaggedAnim( animflag, vehicle getanim( rightAnim ), rightWeight, STEERING_BLEND_TIME, 1.0 );

		wait UPDATE_TIME;
	}
}


drive_shooting_update_anims( vehicle )
{
	// start pull out anim
	vehicle SetAnimKnobLimited( vehicle getanim( "gun_pullout_root" ), 1.0, 0.0, 1.0 );
	self childthread drive_blend_anims_with_steering( vehicle, "pullout_anim", "pullout_done", "gun_pullout_L", "gun_pullout", "gun_pullout_R" );

	// attach the gun
	vehicle waittillmatch( "pullout_anim", "attach_gun" );
	vehicle Attach( level.zodiac_gunModel, "tag_weapon_left" );

	//"viewmodel_miniUZI"
	vehicle HidePart( "TAG_ACOG_2", level.zodiac_gunModel );
	vehicle HidePart( "TAG_RAIL", level.zodiac_gunModel );
	vehicle HidePart( "TAG_RED_DOT", level.zodiac_gunModel );
	vehicle HidePart( "TAG_EOTECH", level.zodiac_gunModel );
	vehicle HidePart( "TAG_SILENCER", level.zodiac_gunModel );
	vehicle HidePart( "TAG_THERMAL_SCOPE", level.zodiac_gunModel );
	vehicle HidePart( "TAG_RETICLE_RED_DOT", level.zodiac_gunModel );
	vehicle HidePart( "TAG_EOTECH_RETICLE", level.zodiac_gunModel );
	vehicle HidePart( "TAG_RETICLE_ACOG", level.zodiac_gunModel );
	vehicle HidePart( "TAG_RETICLE_THERMAL_SCOPE", level.zodiac_gunModel );
	

	vehicle.gun_attached = true;

	vehicle waittillmatch( "pullout_anim", "end" );
	vehicle notify( "pullout_done" );

	// start gun anim
	vehicle SetAnim( vehicle getanim( "uzi" ), 1.0, 0.0, 1.0 );

	// start idle
	vehicle SetAnimKnobLimited( vehicle getanim( "gun_idle" ), 1.0, 0.0, 1.0 );

	vehicle.zodiacShootTimer = SHOOT_ARM_UP_DELAY;

	for ( ;; )
	{
		if ( vehicle.zodiacShootTimer <= 0.0 )
			break;

		shootButtonPressed = is_shoot_button_pressed();

		if ( shootButtonPressed && ( vehicle.zodiacAmmoCount > 0 ) )
		{
			flag_set( "player_shot_on_zodiac" );
			// play gun fire anims
			vehicle SetFlaggedAnimKnobLimitedRestart( "fire_anim", vehicle getanim( "gun_fire" ), 1.0, 0.0, 1.0 );

			if ( vehicle.zodiacAmmoCount == 1 )
				vehicle SetAnimKnobLimitedRestart( vehicle getanim( "uzi_last_fire" ), 1.0, 0.0, 1.0 );
			else
				vehicle SetAnimKnobLimitedRestart( vehicle getanim( "uzi_fire" ), 1.0, 0.0, 1.0 );

			// fire bullet
			self drive_magic_bullet( vehicle );

			wait( SHOOT_FIRE_TIME );

			vehicle.zodiacAmmoCount -= 1;
			vehicle.zodiacShootTimer = SHOOT_ARM_UP_DELAY;
		}
		else if ( vehicle.zodiacAmmoCount <= 0 )
		{
			// play reload anims
			vehicle SetFlaggedAnimKnobLimitedRestart( "reload_anim", vehicle getanim( "gun_reload" ), 1.0, 0.0, 1.0 );
			vehicle SetAnimKnobLimitedRestart( vehicle getanim( "uzi_reload" ), 1.0, 0.0, 1.0 );

			vehicle waittillmatch( "reload_anim", "end" );

			vehicle.zodiacAmmoCount = SHOOT_AMMO_COUNT;
			vehicle.zodiacShootTimer = SHOOT_ARM_UP_DELAY;
		}
		else
		{
			// play idle
			vehicle SetAnimKnobLimited( vehicle getanim( "gun_idle" ), 1.0, 0.0, 1.0 );
			vehicle.zodiacShootTimer -= UPDATE_TIME;
		}

		wait UPDATE_TIME;
	}

	// start put away anim
	vehicle SetAnimKnobLimited( vehicle getanim( "gun_putaway_root" ), 1.0, 0.0, 1.0 );
	self childthread drive_blend_anims_with_steering( vehicle, "putaway_anim", "putaway_done", "gun_putaway_L", "gun_putaway", "gun_putaway_R" );

	// detach the gun
	vehicle waittillmatch( "putaway_anim", "detach_gun" );
	if ( IsDefined( vehicle.gun_attached ) )
	{
		vehicle Detach( level.zodiac_gunModel, "tag_weapon_left" );
		vehicle.gun_attached = undefined;
	}

	vehicle waittillmatch( "putaway_anim", "end" );
	vehicle notify( "putaway_done" );
	vehicle notify( "drive_shooting_done" );
}


drive_shooting_anims( vehicle )
{
	vehicle SetAnim( vehicle getanim( "drive_left_arm" ), 1.0, SHOOT_BLEND_TIME, 1.0 );
	vehicle SetAnim( vehicle getanim( "shoot_left_arm" ), 0.0, SHOOT_BLEND_TIME, 1.0 );

	for ( ;; )
	{
		shootButtonPressed = is_shoot_button_pressed();

		if ( shootButtonPressed )
		{
			vehicle SetAnim( vehicle getanim( "drive_left_arm" ), 0.001, SHOOT_BLEND_TIME, 1.0 );
			vehicle SetAnim( vehicle getanim( "shoot_left_arm" ), 1.0, SHOOT_BLEND_TIME, 1.0 );

			self childthread drive_shooting_update_anims( vehicle );

			vehicle waittill( "drive_shooting_done" );
		}

		vehicle SetAnim( vehicle getanim( "drive_left_arm" ), 1.0, SHOOT_BLEND_TIME, 1.0 );
		vehicle SetAnim( vehicle getanim( "shoot_left_arm" ), 0.0, SHOOT_BLEND_TIME, 1.0 );

		wait UPDATE_TIME;
	}
}

is_shoot_button_pressed()
{
	// pc
	return self AttackButtonPressed();
}



#using_animtree( "vehicles" );
zodiac_anims()
{
	level.scr_animtree[ "zodiac_player" ]	 = #animtree;
	level.scr_model[ "zodiac_player" ]		 = level.zodiac_playerHandModel;
	level.scr_anim[ "zodiac_player" ][ "root" ]	 = %root;
	level.scr_anim[ "zodiac_player" ][ "left_arm" ]				 = %player_snowmobile_left_arm;
	level.scr_anim[ "zodiac_player" ][ "drive_left_arm" ]		 = %player_snowmobile_drive_left_arm;
	level.scr_anim[ "zodiac_player" ][ "shoot_left_arm" ]		 = %player_snowmobile_shoot_left_arm;
	level.scr_anim[ "zodiac_player" ][ "gun_fire" ]				 = %player_snowmobile_gun_fire;
	level.scr_anim[ "zodiac_player" ][ "gun_idle" ]				 = %player_snowmobile_gun_idle;
	level.scr_anim[ "zodiac_player" ][ "gun_pullout_root" ]		 = %player_snowmobile_gun_pullout_root;
	level.scr_anim[ "zodiac_player" ][ "gun_pullout_L" ]		 = %player_snowmobile_gun_pullout_L;
	level.scr_anim[ "zodiac_player" ][ "gun_pullout" ]			 = %player_snowmobile_gun_pullout;
	level.scr_anim[ "zodiac_player" ][ "gun_pullout_R" ]		 = %player_snowmobile_gun_pullout_R;
	level.scr_anim[ "zodiac_player" ][ "gun_putaway_root" ]		 = %player_snowmobile_gun_putaway_root;
	level.scr_anim[ "zodiac_player" ][ "gun_putaway_L" ]		 = %player_snowmobile_gun_putaway_L;
	level.scr_anim[ "zodiac_player" ][ "gun_putaway" ]			 = %player_snowmobile_gun_putaway;
	level.scr_anim[ "zodiac_player" ][ "gun_putaway_R" ]		 = %player_snowmobile_gun_putaway_R;
	level.scr_anim[ "zodiac_player" ][ "gun_reload" ]			 = %player_snowmobile_gun_reload;

	level.scr_anim[ "zodiac_player" ][ "right_arm" ]			 = %player_snowmobile_right_arm;

	level.scr_anim[ "zodiac_player" ][ "uzi" ]			 = %snowmobile_glock;
	level.scr_anim[ "zodiac_player" ][ "uzi_fire" ]		 = %snowmobile_glock_fire;
	level.scr_anim[ "zodiac_player" ][ "uzi_last_fire" ]	 = %snowmobile_glock_last_fire;
	level.scr_anim[ "zodiac_player" ][ "uzi_reload" ]		 = %snowmobile_glock_reload;

	level.scr_anim[ "zodiac_player" ][ "sleeve_pose" ]		 = %player_sleeve_pose;
	level.scr_anim[ "zodiac_player" ][ "sleeve_flapping" ]	 = %player_sleeve_flapping;
}

should_stop_zodiac_attack_hint()
{
	if ( !isdefined( level.player.vehicle ) )
		return true;

	return flag( "player_shot_on_zodiac" );
}


should_stop_zodiac_drive_hint()
{
	if ( !isdefined( level.player.vehicle ) )
		return true;

	return level.player.vehicle.veh_speed > 10;
}


reverse_hint( vehicle )
{
	self endon( "death" );
	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );
	
	level endon ( "no_more_reverse_hints" );

	vehicle wait_for_vehicle_to_move();
	
	vehicle.hint_brake_count = 0;
	for ( ;; )
	{
		if ( abs( vehicle.veh_speed ) < 5 )
		{
			vehicle.hint_brake_count++;
			if ( vehicle.hint_brake_count >= 3 )
			{
				vehicle display_hint( "zodiac_reverse" );
			}
		}
		else
		{
			vehicle.hint_brake_count = 0;
		}
		wait( 1 );
	}
}

wait_for_vehicle_to_move()
{
	for ( ;; )
	{
		if ( self.veh_speed > 40 )
			return;
		wait( 1 );
	}
}

should_stop_zodiac_reverse_hint()
{
	if ( !isdefined( self.vehicle ) )
		return true;
	return self.vehicle.hint_brake_count < 3;
}
