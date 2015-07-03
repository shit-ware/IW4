#include common_scripts\utility;
//#include maps\_hud_util;
#using_animtree( "sentry_gun" );

/*QUAKED script_model_pickup_sentry_gun (1 0 0) (-32 -16 0) (32 16 24) ORIENT_LOD NO_SHADOW  NO_STATIC_SHADOWS
defaultmdl="sentry_gun_folded"
default:"model" "sentry_gun_folded"
*/

/*QUAKED script_model_pickup_sentry_minigun (1 0 0) (-32 -16 0) (32 16 24) ORIENT_LOD NO_SHADOW  NO_STATIC_SHADOWS
defaultmdl="sentry_minigun_folded"
default:"model" "sentry_minigun_folded"
*/

/*
code support:
-physics on turrets

todo:
-make hint print while in placement mode
-hit max number of turrets at 32, but I could limit the number allowed
-get behind turret and change team
*/

/*
	Constants
*/

// default
sentry_updateTime 				 = 0.05;
shielded_sentry_health 			 = 350;// direct hit from an RPG
shielded_sentry_bullet_armor 	 = 2000;
minigun_sentry_health 			 = 190;// frag grenade does 200 inner damage
minigun_sentry_bullet_armor 	 = 1200;
minigun_sentry_bullet_armor_enemy 	 = 0;

// mp
shielded_sentry_bullet_armor_mp	 = 300;
minigun_sentry_bullet_armor_mp	 = 300;

sentry_mode_name_on				 = "sentry";
sentry_mode_name_off			 = "sentry_offline";

main()
{
	precacheModel( "sentry_minigun" );
	precacheModel( "sentry_minigun_obj" );
	precacheModel( "sentry_minigun_obj_red" );
	precacheModel( "sentry_minigun_folded_obj" );
	precacheModel( "sentry_minigun_destroyed" );
	precacheModel( "sentry_gun" );
	precacheModel( "sentry_gun_obj" );
	precacheModel( "sentry_gun_obj_red" );
	precacheModel( "sentry_gun_folded_obj" );
	precacheModel( "sentry_gun_destroyed" );
	precacheModel( "tag_laser" );

	if ( isSP() )
	{
		precacheTurret( "sentry_gun" );
		precacheTurret( "sentry_minigun" );
		precacheTurret( "sentry_minigun_enemy" );
	}
	else
	{
		precacheTurret( "sentry_gun_mp" );
		precacheTurret( "sentry_minigun_mp" );
	}

	// LANG_ENGLISH		Press and hold ^3&&1^7 to move the turret."
	precacheString( &"SENTRY_MOVE" );
	// Press and hold ^3&&1^7 to pick up the turret.
	precacheString( &"SENTRY_PICKUP" );
	precacheString( &"SENTRY_PLACE" );
	precacheString( &"SENTRY_CANNOT_PLACE" );

	level._effect[ "sentry_turret_overheat_smoke_sp" ]		= loadfx( "smoke/sentry_turret_overheat_smoke_sp" );
	level._effect[ "sentry_turret_explode" ]				 = loadfx( "explosions/sentry_gun_explosion" );
	level._effect[ "sentry_turret_explode_smoke" ]			 = loadfx( "smoke/car_damage_blacksmoke" );

	level.sentry_settings = [];

	level.sentry_settings[ "sentry_gun" ] 					 = spawnStruct();
	sentry_gun_default_settings( "sentry_gun" );

	level.sentry_settings[ "sentry_minigun" ] 				 = spawnStruct();
	sentry_minigun_default_settings( "sentry_minigun" );

	if ( isSP() )
	{
		// sentry overheat override settings
		level.sentry_overheating_speed = 1; // 1 heat points per second
		level.sentry_cooling_speed = 1; // 1 heat points cooling per second
		
		if ( !isdefined( level.sentry_fire_time ) )
			level.sentry_fire_time = 8; // seconds of continous fire ( aka heat points )
		if ( !isdefined( level.sentry_cooldown_time ) )
			level.sentry_cooldown_time = 4; // seconds of continous fire ( aka heat points )
	}

	level.sentryTurretSettings[ "easy" ][ "convergencePitchTime" ] 	= 2.5;
	level.sentryTurretSettings[ "easy" ][ "convergenceYawTime" ] 	= 2.5;
	level.sentryTurretSettings[ "easy" ][ "suppressionTime" ] 		= 3.0;
	level.sentryTurretSettings[ "easy" ][ "aiSpread" ] 				= 2.0;
	level.sentryTurretSettings[ "easy" ][ "playerSpread" ] 			= 0.5;

	// for pre-placed guns
	guns = getentarray( "sentry_gun", "targetname" );
	mini_guns = getentarray( "sentry_minigun", "targetname" );
	foreach( gun in guns )
	{
		gun sentry_init( undefined, "sentry_gun" );
	}
	
	foreach( minigun in mini_guns )
	{
		minigun sentry_init( undefined, "sentry_minigun" );
	}

	array_thread( getentarray( "script_model_pickup_sentry_gun", "classname" ), ::sentry_pickup_init, "sentry_gun" );
	array_thread( getentarray( "script_model_pickup_sentry_minigun", "classname" ), ::sentry_pickup_init, "sentry_minigun" );
}

sentry_gun_default_settings( type )
{
	level.sentry_settings[ type ].burst_shots_min 	 = 10;
	level.sentry_settings[ type ].burst_shots_max 	 = 35;
	level.sentry_settings[ type ].burst_pause_min 	 = 0.2;
	level.sentry_settings[ type ].burst_pause_max 	 = 0.8;
	level.sentry_settings[ type ].model 			 = "sentry_gun";
	level.sentry_settings[ type ].destroyedModel 	 = "sentry_gun_destroyed";
	level.sentry_settings[ type ].pickupModel 		 = "sentry_gun_folded";
	level.sentry_settings[ type ].pickupModelObj 	 = "sentry_gun_folded_obj";
	level.sentry_settings[ type ].placementmodel 	 = "sentry_gun_obj";
	level.sentry_settings[ type ].placementmodelfail = "sentry_gun_obj_red";
	level.sentry_settings[ type ].health 			 = shielded_sentry_health;

	if ( isSP() )
	{
		level.sentry_settings[ type ].damage_smoke_time = 15;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_gun";
		level.sentry_settings[ type ].targetname 		 = "sentry_gun";
	}
	else
	{
		level.sentry_settings[ type ].damage_smoke_time = 5;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_gun_mp";
		level.sentry_settings[ type ].targetname 		 = "sentry_gun_mp";
	}
}

sentry_minigun_default_settings( type )
{
	level.sentry_settings[ type ].burst_shots_min 	 = 20;
	level.sentry_settings[ type ].burst_shots_max 	 = 60;
	level.sentry_settings[ type ].burst_pause_min 	 = 0.5;
	level.sentry_settings[ type ].burst_pause_max 	 = 1.3;
	level.sentry_settings[ type ].model 			 = "sentry_minigun";
	level.sentry_settings[ type ].destroyedModel 	 = "sentry_minigun_destroyed";
	level.sentry_settings[ type ].pickupModel 		 = "sentry_minigun_folded";
	level.sentry_settings[ type ].pickupModelObj 	 = "sentry_minigun_folded_obj";
	level.sentry_settings[ type ].placementmodel 	 = "sentry_minigun_obj";
	level.sentry_settings[ type ].placementmodelfail = "sentry_minigun_obj_red";
	level.sentry_settings[ type ].health 			 = minigun_sentry_health;

	if ( isSP() )
	{
		level.sentry_settings[ type ].damage_smoke_time = 15;
		level.sentry_settings[ type ].anim_loop 		 = %minigun_spin_loop;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_minigun";
		level.sentry_settings[ type ].targetname 		 = "sentry_minigun";
	}
	else
	{
		level.sentry_settings[ type ].damage_smoke_time = 5;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_minigun_mp";
		level.sentry_settings[ type ].targetname 		 = "sentry_minigun_mp";
	}
}

sentry_pickup_init( sentryType )
{
	assert( isdefined( sentryType ) );
	assert( isdefined( level.sentry_settings[ sentryType ] ) );
	self setModel( self.model );
	self.sentryType = sentryType;

	self setCursorHint( "HINT_NOICON" );
	// Press and hold ^3&&1^7 to pick up the turret.
	self setHintString( &"SENTRY_PICKUP" );
	self makeUsable();

	self thread folded_sentry_use_wait( sentryType );
}

giveSentry( sentryType )
{
	assert( isdefined( level.sentry_settings ) );
	assert( isdefined( level.sentry_settings[ sentryType ] ) );

	self.last_sentry = sentryType;
	self thread spawn_and_place_sentry( sentryType );
}

sentry_init( team, sentryType, owner )
{
	if ( !isdefined( team ) )
	{
		assert( isdefined( self.script_team ) );
		if ( !isdefined( self.script_team ) )
			self.script_team = "axis";
		team = self.script_team;
	}
	
	assert( isDefined( team ) );
	assert( isDefined( sentryType ) );
	
	self setTurretModeChangeWait( true );
	self makeSentrySolid();
	self makeTurretInoperable();
	self SentryPowerOn();
	self setCanDamage( true );
	self setDefaultDropPitch( -89.0 );	// setting this mainly prevents Turret_RestoreDefaultDropPitch() from running
	
	if ( isSP() || level.teambased )
		self setTurretTeam( team );

	self.sentryType = sentryType;
	self.isSentryGun = true;
	self.kill_reward_money = 350;
	self.kill_melee_reward_money = 400;
	self.sentry_battery_timer = 60;	// sec

	//bullet armor acts as an extra pool of health for bullet damage. 
	//once its removed bullet damage affects the sentry like other kinds of damage.
	if ( isSP() )
	{
		if ( self.weaponinfo == "sentry_gun" )// sentry_minigun and sentry_minigun_enemy get the same settings
			self.bullet_armor = shielded_sentry_bullet_armor;
		else
		{
			self.bullet_armor = minigun_sentry_bullet_armor;
		}
	}
	else
	{
		if ( self.weaponinfo == "sentry_gun" )
			self.bullet_armor = shielded_sentry_bullet_armor_mp;
		else
			self.bullet_armor = minigun_sentry_bullet_armor_mp;
	}

	if ( isSP() )
	{
		self call [[ level.makeEntitySentient_func ]]( team );
		self self_func( "useanimtree", #animtree );
		if ( isdefined( self.script_team ) && self.script_team == "axis" )
			self thread enemy_sentry_difficulty_settings();
	}

	self.health = level.sentry_settings[ sentryType ].health;

	self sentry_badplace_create();
	self thread sentry_beep_sounds();
	self thread sentry_enemy_wait();
	self thread sentry_death_wait();
	if ( !isSP() )
	{
		self thread sentry_emp_wait();
		self thread sentry_emp_damage_wait();
	}
	self thread sentry_health_monitor();
	self thread sentry_player_use_wait();
	
	if ( !isdefined( owner ) )
	{
		if( isSP() )
			owner = level.player;
	}
	assert( isdefined( owner ) );
	self sentry_set_owner( owner );
	self thread sentry_destroy_on_owner_leave( owner );
	
	if ( !isdefined( self.damage_functions ) )
		self.damage_functions = [];

	if ( getdvar( "money_enable", "0" ) == "1" && self.team == "axis" )
	{
		if ( isdefined( level.sentry_money_init_func ) )
			self thread [[ level.sentry_money_init_func ]]();
	}
}

sentry_death_wait()
{
	self endon( "deleted" );
	
	//self waittill_player_or_sentry_death();
	self waittill( "death", attacker, cause );

	if ( isdefined( level.stat_track_kill_func ) && isdefined( attacker ) )
		attacker [[ level.stat_track_kill_func ]]( self, cause );

	if ( !isSP() )
	{
		self removeFromTurretList();
		self thread sentry_place_mode_reset();
	}

	self thread sentry_burst_fire_stop();

	if ( isdefined( level.laserOff_func ) )
		self call [[ level.laserOff_func ]]();

	assert( isdefined( level.sentry_settings[ self.sentryType ] ) );
	assert( isdefined( level.sentry_settings[ self.sentryType ].destroyedModel ) );
	self setmodel( level.sentry_settings[ self.sentryType ].destroyedModel );
	self SentryPowerOff();
	
	if ( isSP() )
		self call [[ level.freeEntitySentient_func ]]();

	if ( !isSP() &&  isDefined( attacker ) && isPlayer( attacker ) )
	{
		if ( isDefined( self.owner ) )
			self.owner thread [[level.leaderDialogOnPlayer_func]]( "destroy_sentry", "sentry_status" );
		attacker thread [[ level.onXPEvent ]]( "kill" );
	}

	self setSentryCarried( false );
	self SetCanDamage( true );
	self.ignoreMe = false;
	self makeUnusable();
	self SetSentryOwner( undefined );
	self SetTurretMinimapVisible( false );
	self playsound( "sentry_explode" );
	playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );
	
	if ( isSP() )
		self setContents( 0 );
	
	wait 1.5;
	self playsound( "sentry_explode_smoke" );
	timeToSteam = level.sentry_settings[ self.sentryType ].damage_smoke_time * 1000;
	startTime = getTime();
	for ( ;; )
	{
		playfxOnTag( getfx( "sentry_turret_explode_smoke" ), self, "tag_aim" );
		wait .4;
		if ( getTime() - startTime > timeToSteam )
			break;
	}

	if ( !isSP() )
		self thread removeDeadSentry();
}

handle_sentry_on_carrier_death( sentry )
{
	level endon( "game_ended" );
	self endon( "sentry_placement_finished" );
	self waittill( "death" );

	if ( isSp() )
	{
		sentry notify( "death" );
		return;
	}

	if ( !self.canPlaceEntity )
	{	
		sentry sentry_place_mode_reset();
		sentry notify( "deleted" );
		
		waittillframeend;
		sentry delete();
		
		return;
	}
	
	if ( !isSp() )
	{	
		self thread place_sentry( sentry );
	}
	
}

kill_sentry_on_carrier_disconnect( sentry )
{
	level endon( "game_ended" );
	self endon( "sentry_placement_finished" );
	self waittill( "disconnect" );

	sentry notify( "death" );
}

sentry_player_use_wait()
{
	level endon( "game_ended" );
	self endon( "death" );
	
	assert( isDefined( self.sentryType ) );

	if ( self.health <= 0 )
		return;

	for ( ;; )
	{
		self waittill( "trigger", player );

		if ( isDefined( player.placingSentry ) )
			continue;

		// only owner of sentry can move sentry in MP
		if ( !isSP() )
		{
			// Checked through code now; Assert left for reference.
			assert( isDefined( self.owner ) );
			assert( player == self.owner );
		}

		break;
	}

	player thread handle_sentry_on_carrier_death( self );
	player thread kill_sentry_on_carrier_disconnect( self );
	player thread sentry_placement_endOfLevel_cancel_monitor( self );

	if ( !isSP() && !isAlive( player ) )
		return;
		
	if ( !isSP() )
		self sentry_team_hide_icon();
		
	self SentryPowerOff();// makes the turret non - operational while being moved
	player.placingSentry = self;
	self setSentryCarried( true );
	self.ignoreMe = true;
	self SetCanDamage( false );
	
	player _disableWeapon();
	//player _disableUsability();
	self makeSentryNotSolid();
	self sentry_badplace_delete();
	player thread move_sentry_wait( self );
	player thread updateSentryPositionThread( self );
}

sentry_badplace_create()
{
	if ( !isSP() )
		return;
	self.badplace_name = "" + getTime();
	call [[ level.badplace_cylinder_func ]]( self.badplace_name, 0, self.origin, 32, 128, self.team, "neutral" );
}

sentry_badplace_delete()
{
	if ( !isSP() )
		return;
	assert( isdefined( self.badplace_name ) );
	call [[ level.badplace_delete_func ]]( self.badplace_name );
	self.badplace_name = undefined;
}

move_sentry_wait( sentry )
{
	level endon( "game_ended" );
	sentry endon( "death" );
	sentry endon( "deleted" );

	self endon( "death" );
	self endon( "disconnect" );
	assert( isdefined( sentry ) );

	for ( ;; )
	{
		//debounce
		self waitActivateButton( false );

		// wait for button press
		self waitActivateButton( true );

		updateSentryPosition( sentry );
		if ( self.canPlaceEntity )
			break;
	}
	
	place_sentry( sentry );
}

place_sentry( sentry )
{
	if ( !isSP() )
	{
		self endon( "death" );
		level endon( "end_game" );
	}
	
	self.placingSentry = undefined;
	sentry setSentryCarried( false );
	sentry SetCanDamage( true );
	sentry.ignoreMe = false;
	
	if ( !maps\_utility::is_coop() || !maps\_utility::is_player_down_and_out( self ) )
	{
		self _enableWeapon();
		//self _enableUsability();
	}
	else
	{
		// Manually decrease the disabledWeapon count because we didn't actually call _enableWeapon()
		// This is necessary because co-op revive needs to prevent the enable from happening, but sentries need to 
		// still keep count as if they did get re-enabled so that the next time you place a turret it works.
		self.disabledWeapon--;
	}
	
	sentry makeSentrySolid();
	sentry setmodel( level.sentry_settings[ sentry.sentryType ].model );
	sentry sentry_badplace_create();
	assert( isdefined( sentry.contents ) );
	sentry setContents( sentry.contents );
	self notify( "sentry_placement_finished", sentry );
	
	sentry notify( "sentry_carried" );
	sentry.overheated = false;
	self sentry_placement_hint_hide();
	
	if ( !isSP() )
		sentry sentry_team_show_icon();
		
	sentry SentryPowerOn();
	thread play_sound_in_space( "sentry_gun_plant", sentry.origin );
	
	//debounce	
	self waitActivateButton( false );
	sentry thread sentry_player_use_wait();	
}

sentry_enemy_wait()
{
	level endon( "game_ended" );
	self endon( "death" );
	self thread sentry_overheat_monitor();
	
	for ( ;; )
	{
		self waittill_either( "turretstatechange", "cooled" );

		if ( self isFiringTurret() )
		{
			self thread sentry_burst_fire_start();
			if ( isdefined( level.laserOn_func ) )
				self call [[ level.laserOn_func ]]();
		}
		else
		{
			self thread sentry_burst_fire_stop();
			if ( isdefined( level.laserOff_func ) )
				self call [[ level.laserOff_func ]]();
		}
	}
}

// Sentry overheat behavoir for SP ====================================================
// Note: 	To enable for mp, take out the isSP() check in main() function for overheat override variables.
//				However, there might be some unseen behavoiral conflicts with battery timer, currently SP only - Julian

// Note 2:  Turrets now have a code ersion of doing this, we probably don't want to mix and match both, so this should be 
//			cleaned up / removed after MW2
sentry_overheat_monitor()
{
	self endon( "death" );
	
	assert( isDefined( self ) );
	assert( isDefined( self.sentryType ) );
	if ( self.sentryType != "sentry_minigun" )
		return;
	
	if ( !isdefined( level.sentry_overheating_speed ) )
		return;
	
	self.overheat = 0;
	self.overheated = false;
	
	if ( getdvarint( "sentry_overheat_debug" ) == 1 )
		self thread sentry_overheat_debug();

	while ( true )
	{
		if ( self.overheat >= ( level.sentry_fire_time * 10 ) )
		{
			self thread sentry_overheat_deactivate();
			self waittill_either( "cooled", "sentry_carried" );
		}

		if ( self IsFiringTurret() )
		{
			self.overheat += 1;
		}
		else
		{
			if ( self.overheat > 0 )
				self.overheat -= 1;
		}
		
		wait 0.1/level.sentry_overheating_speed;
	}
}

sentry_cooling()
{
	self endon( "death" );

	while ( self.overheated )
	{
		if ( self.overheat > 0 )
			self.overheat -= 1;
		
		wait 0.1/level.sentry_overheating_speed;
	}
}

sentry_overheat_debug()
{
	self endon( "death" );
	while( true )
	{
		overheat_value = self.overheat / (level.sentry_fire_time*10);
		overheat_print_l = "[ ";
		overheat_print_r = " ]";
		if( self.overheated ) 
		{
			overheat_print_l = "{{{ ";
			overheat_print_r = " }}}";
		}
		
		print3d( self.origin + ( 0,0,45 ), overheat_print_l + self.overheat + " / " + level.sentry_fire_time*10 + overheat_print_r, ( 0+overheat_value, 1-overheat_value, 1-overheat_value ), 1, 0.35, 4 );
		wait 0.2;
	}
}

sentry_overheat_deactivate()
{
	self endon( "death" );
	
	self notify( "overheated" );
	self.overheated = true;
	self sentry_burst_fire_stop();
	
	self thread sentry_overheat_reactivate();
}

sentry_overheat_reactivate()
{
	self endon( "death" );
	self endon( "sentry_carried" );
	
	self thread sentry_cooling();
	
	wait level.sentry_cooldown_time;
	self notify( "cooled" );
	self.overheat = 0;
	self.overheated = false;
}

// END of sentry overheat behavoir for SP =================================================

sentry_burst_fire_start()
{
	self endon( "death" );
	level endon( "game_ended" );

	if ( isdefined( self.overheated ) && self.overheated )
		return;
	
	self thread fire_anim_start();

	self endon( "stop_shooting" );
	self notify( "shooting" );

	assert( isdefined( self.weaponinfo ) );
	fireTime = weaponFireTime( self.weaponinfo );
	assert( isdefined( fireTime ) && fireTime > 0 );

	for ( ;; )
	{		
		self turret_start_anim_wait();
		numShots = randomintrange( level.sentry_settings[ self.sentryType ].burst_shots_min, level.sentry_settings[ self.sentryType ].burst_shots_max );
		for ( i = 0 ; i < numShots ; i++ )
		{
			if ( self canFire() )
				self shootTurret();

			wait fireTime;
		}
		wait randomfloatrange( level.sentry_settings[ self.sentryType ].burst_pause_min, level.sentry_settings[ self.sentryType ].burst_pause_max );
	}
}

sentry_allowFire( bAllow, timeOut )
{
	self notify( "allowFireThread" );
	self endon( "allowFireThread" );
	self endon( "death" );

	self.taking_damage = bAllow;

	if ( isdefined( timeOut ) && !bAllow )
	{
		wait timeOut;
		if ( isdefined( self ) )
			self thread sentry_allowFire( true );
	}
}

canFire()
{
	if ( !isdefined( self.taking_damage ) )
		return true;

	return self.taking_damage;
}

sentry_burst_fire_stop()
{
	self thread fire_anim_stop();
	self notify( "stop_shooting" );
	self thread sentry_steam();
}

sentry_steam()
{
	self endon( "shooting" );
	self endon( "deleted" );

	wait randomfloatrange( 0.0, 1.0 );

	timeToSteam = 6 * 1000;
	startTime = getTime();
	
	// temp sound fx
	if ( isdefined( self ) )
		self playsound( "sentry_steam" );
		
	while ( isdefined( self ) )
	{
		playfxOnTag( getfx( "sentry_turret_overheat_smoke_sp" ), self, "tag_flash" );
		wait .3;
		if ( getTime() - startTime > timeToSteam )
			break;
	}
}

turret_start_anim_wait()
{
	if ( isdefined( self.allow_fire ) && self.allow_fire == false )
		self waittill( "allow_fire" );
}

fire_anim_start()
{
	self notify( "anim_state_change" );
	self endon( "anim_state_change" );
	self endon( "stop_shooting" );
	self endon( "deleted" );
	level endon( "game_ended" );
	self endon( "death" );

	if ( !isdefined( level.sentry_settings[ self.sentryType ].anim_loop ) )
		return;

	self.allow_fire = false;

	//ramp up the animation from 0.1 speed to 1.0 speed over time
	if ( !isdefined( self.momentum ) )
		self.momentum = 0;

	self thread fire_sound_spinup();
	for ( ;; )
	{
		if ( self.momentum >= 1.0 )
			break;
		self.momentum += 0.1;
		self.momentum = cap_value( self.momentum, 0.0, 1.0 );
		if ( isSP() )
			self self_func( "setanim", level.sentry_settings[ self.sentryType ].anim_loop, 1.0, 0.2, self.momentum );
		wait 0.2;
	}
	self.allow_fire = true;
	self notify( "allow_fire" );
}

delete_sentry_turret()
{
	self notify( "deleted" );
	wait .05;
	self notify( "death" );

	if ( isDefined( self.obj_overlay ) )
		self.obj_overlay delete();

	if ( isDefined( self.cam ) )
		self.cam delete();
		
	self delete();
}

fire_anim_stop()
{
	self notify( "anim_state_change" );
	self endon( "anim_state_change" );

	if ( !isdefined( level.sentry_settings[ self.sentryType ].anim_loop ) )
		return;

	self thread fire_sound_spindown();

	self.allow_fire = false;

	for ( ;; )
	{
		if ( !isdefined( self.momentum ) )
			break;
		if ( self.momentum <= 0.0 )
			break;
		self.momentum -= 0.1;
		self.momentum = cap_value( self.momentum, 0.0, 1.0 );
		if ( isSP() )
			self self_func( "setanim", level.sentry_settings[ self.sentryType ].anim_loop, 1.0, 0.2, self.momentum );
		wait 0.2;
	}
}

fire_sound_spinup()
{
	self notify( "sound_state_change" );
	self endon( "sound_state_change" );
	self endon( "deleted" );

	if ( self.momentum < 0.25 )
	{
		self playsound( "sentry_minigun_spinup1" );
		wait 0.6;
		self playsound( "sentry_minigun_spinup2" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup3" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 0.5 )
	{
		self playsound( "sentry_minigun_spinup2" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup3" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 0.75 )
	{
		self playsound( "sentry_minigun_spinup3" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 1 )
	{
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}

	thread fire_sound_spinloop();
}

fire_sound_spinloop()
{
	self endon( "death" );
	self notify( "sound_state_change" );
	self endon( "sound_state_change" );

	while ( 1 )
	{
		self playsound( "sentry_minigun_spin" );
		wait 2.5;
	}
}

fire_sound_spindown()
{
	self notify( "sound_state_change" );
	self endon( "sound_state_change" );
	self endon( "deleted" );

	if ( !isdefined( self.momentum ) )
		return;

	if ( self.momentum > 0.75 )
	{
		self stopsounds();
		self playsound( "sentry_minigun_spindown4" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown3" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown2" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
	else
	if ( self.momentum > 0.5 )
	{
		self playsound( "sentry_minigun_spindown3" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown2" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
	else
	if ( self.momentum > 0.25 )
	{
		self playsound( "sentry_minigun_spindown2" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
	else
	{
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
}

sentry_beep_sounds()
{
	self endon( "death" );
	for ( ;; )
	{
		wait randomfloatrange( 3.5, 4.5 );
		self thread play_sound_in_space( "sentry_gun_beep", self.origin + ( 0, 0, 40 ) );
	}
}

spawn_and_place_sentry( sentryType )
{
	level endon( "game_ended" );

	assert( self.classname == "player" );
	assert( isdefined( sentryType ) );
	assert( isdefined( level.sentry_settings[ sentryType ] ) );
	assert( isdefined( level.sentry_settings[ sentryType ].placementmodel ) );
	assert( isdefined( level.sentry_settings[ sentryType ].placementmodelfail ) );	

	if ( isdefined( self.placingSentry ) )
		return;
	
	self _disableWeapon();
	//self _disableUsability();
	self notify( "placingSentry" );
	
	assert( isdefined( level.sentry_settings[ sentryType ] ) );
	assert( isdefined( level.sentry_settings[ sentryType ].weaponInfo ) );
	assert( isdefined( level.sentry_settings[ sentryType ].model ) );
	assert( isdefined( level.sentry_settings[ sentryType ].targetname ) );
	
	sentry_gun = spawnTurret( "misc_turret", self.origin, level.sentry_settings[ sentryType ].weaponInfo );
	sentry_gun setmodel( level.sentry_settings[ sentryType ].placementModel );
	sentry_gun.weaponinfo = level.sentry_settings[ sentryType ].weaponInfo;    
    sentry_gun.targetname = level.sentry_settings[ sentryType ].targetname;
    sentry_gun.weaponName = level.sentry_settings[ sentryType ].weaponInfo;
    sentry_gun.angles = self.angles;
	sentry_gun.team = self.team;
	sentry_gun.attacker = self;
	sentry_gun.sentryType = sentryType;

	sentry_gun makeTurretInoperable();
	sentry_gun sentryPowerOff();
	sentry_gun setCanDamage( false );
	sentry_gun sentry_set_owner( self );
	sentry_gun setDefaultDropPitch( -89.0 );	// setting this mainly prevents Turret_RestoreDefaultDropPitch() from running

	self.placingSentry = sentry_gun;
	sentry_gun setSentryCarried( true );
	sentry_gun SetCanDamage( false );
	sentry_gun.ignoreMe = true;

	if ( !isSP() )
		sentry_gun addToTurretList();
	
	// wait to delete the sentry when cancelled
	self thread sentry_placement_cancel_monitor( sentry_gun );
	
	// wait to delete the sentry on end of level
	self thread sentry_placement_endOfLevel_cancel_monitor( sentry_gun );

	// wait until the player plants the sentry
	self thread sentry_placement_initial_wait( sentry_gun );

	// keep the indicator model positioned with traces forever until the thread is ended
	self thread updateSentryPositionThread( sentry_gun );
	
	// wait until the turret placement has been finished or canceled
	if ( !isSP() )
		self waittill_any( "sentry_placement_finished", "sentry_placement_canceled", "death" );
	else
		self waittill_any( "sentry_placement_finished", "sentry_placement_canceled" );

	self sentry_placement_hint_hide();

	if ( !maps\_utility::is_coop() || !maps\_utility::is_player_down_and_out( self ) )
	{
		self _enableWeapon();
		//self _enableUsability();
	}
	else
	{
		// Manually decrease the disabledWeapon count because we didn't actually call _enableWeapon()
		// This is necessary because co-op revive needs to prevent the enable from happening, but sentries need to 
		// still keep count as if they did get re-enabled so that the next time you place a turret it works.
		self.disabledWeapon--;
	}
	
	self.placingSentry = undefined;
	sentry_gun setSentryCarried( false );
	self SetCanDamage( true );
	sentry_gun.ignoreMe = false;
}


sentry_placement_cancel_monitor( sentry_gun )
{
	self endon ( "sentry_placement_finished" );
	
	if ( !isSP() )
		self waittill_any( "sentry_placement_canceled", "death", "disconnect");
	else
		self waittill_any( "sentry_placement_canceled" );
	
	waittillframeend;
	sentry_gun delete();
}

sentry_placement_endOfLevel_cancel_monitor( sentry_gun )
{
	self endon ( "sentry_placement_finished" );
	
	if ( isSP() )
		return;
			
	level waittill( "game_ended" );
	
	if ( !isDefined( sentry_gun ) )
		return;
	
	//sentry_gun notify( "deleted" );
	if ( !self.canPlaceEntity )
	{	
		sentry_gun notify( "deleted" );
		
		waittillframeend;
		sentry_gun delete();
		return;
	}

	self thread place_sentry( sentry_gun );
}


sentry_restock_wait()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "restock_reset" );

	// Cancel/restock on death or when toggling the killstreak
	self notifyOnPlayerCommand( "cancel sentry", "+actionslot 4" );
	self waittill_any( "death", "cancel sentry" );
	assert( isdefined( self.last_sentry ) );
	
	self notify( "sentry_placement_canceled" );
}


sentry_placement_initial_wait( sentry_gun )
{
	level endon( "game_ended" );

	self endon( "sentry_placement_canceled" );

	if ( !isSP() )
	{
		self endon( "disconnect" );
		//self endon( "death" );
		sentry_gun thread sentry_reset_on_owner_death();
		self thread sentry_restock_wait();
	}

	//debounce from picking up the gun
	while ( self useButtonPressed() )
		wait 0.05;

	for ( ;; )
	{
		// couldn't place entity so wait until the buttons are unpressed before trying again
		self waitActivateButton( false );

		// wait until the button is pressed
		self waitActivateButton( true );

		updateSentryPosition( sentry_gun );
		if ( self.canPlaceEntity )
			break;
	}

	if ( !isSP() ) //&& isAlive( self ) )
		self notify( "restock_reset" );

	if ( !isSP() )
	{
		sentry_gun.lifeId = self.lifeId;
		self sentry_team_setup( sentry_gun );
	}

	thread play_sound_in_space( "sentry_gun_plant", sentry_gun.origin );

	assert( isdefined( self.team ) );
	sentry_gun setmodel( level.sentry_settings[ sentry_gun.sentryType ].model );
	sentry_gun thread sentry_init( self.team, sentry_gun.sentryType, self );

	self notify( "sentry_placement_finished", sentry_gun );
	waittillframeend;	// wait so self.placingSentry can get cleared before notifying script that we can give the player another turret

	if ( !isSP() )
		sentry_gun thread sentry_die_on_batteryout();
}

updateSentryPositionThread( sentry_entity )
{
	level endon( "game_ended" );

	sentry_entity notify( "sentry_placement_started" );
	self endon( "sentry_placement_canceled" );
	self endon( "sentry_placement_finished" );

	sentry_entity endon( "death" );
	sentry_entity endon( "deleted" );

	if ( !isSP() )
	{
		self endon( "disconnect" );
		self endon( "death" );
	}

	for ( ;; )
	{
		updateSentryPosition( sentry_entity );		
		wait sentry_updateTime;
	}
}

updateSentryPosition( sentry_entity )
{
	placement = self canPlayerPlaceSentry();
	sentry_entity.origin = placement[ "origin" ];
	sentry_entity.angles = placement[ "angles" ];		
	self.canPlaceEntity = self isonground() && placement[ "result" ];
	self sentry_placement_hint_show( self.canPlaceEntity );

	if ( self.canPlaceEntity )
		sentry_entity setModel( level.sentry_settings[ sentry_entity.sentryType ].placementmodel );
	else
		sentry_entity setModel( level.sentry_settings[ sentry_entity.sentryType ].placementmodelfail );
}

sentry_placement_hint_show( hint_valid )
{
	assert( isDefined( self ) );
	assert( isDefined( hint_valid ) );
	
	// return if not changed
	if ( isdefined( self.forced_hint ) && (self.forced_hint == hint_valid) )
		return;

	self.forced_hint = hint_valid;

	if ( self.forced_hint )
		self ForceUseHintOn( &"SENTRY_PLACE" );
	else
		self ForceUseHintOn( &"SENTRY_CANNOT_PLACE" );
}

sentry_placement_hint_hide()
{
	assert( isDefined( self ) );
	
	// return if hidden already
	if ( !isdefined( self.forced_hint ) )
		return;

	self ForceUseHintOff();
	self.forced_hint = undefined;	
}

folded_sentry_use_wait( sentryType )
{
	// spawn another copy of the model so that it's not translucent
	self.obj_overlay = spawn( "script_model", self.origin );
	self.obj_overlay.angles = self.angles;
	self.obj_overlay setModel( level.sentry_settings[ sentryType ].pickupModelObj );

	for ( ;; )
	{
		self waittill( "trigger", player );

		if ( !isdefined( player ) )
			continue;

		if ( isDefined( player.placingSentry ) )
			continue;

		if ( !isSP() )
		{
			assert( isdefined( self.owner ) );
			if ( player != self.owner )
				continue;
		}

		break;
	}

	self thread play_sound_in_space( "sentry_pickup" );
	self.obj_overlay delete();
	self delete();

	// put the player into placement mode
	player thread spawn_and_place_sentry( sentryType );
}

sentry_health_monitor()
{
	self.healthbuffer = 20000;
	self.health += self.healthbuffer;
	self.currenthealth = self.health;
	attacker = undefined;
	type = undefined;

	while ( self.health > 0 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName );

		if ( !isSP() && isdefined( attacker ) && isplayer( attacker ) && attacker sentry_attacker_is_friendly( self ) )
		{
			self.health = self.currenthealth;
			return;
		}

		if ( isdefined( level.stat_track_damage_func ) && isdefined( attacker ) )
			attacker [[ level.stat_track_damage_func ]]();

		assertex( isdefined( level.func[ "damagefeedback" ] ), "damagefeedback display function is undefined" );
		if ( isdefined( attacker ) && isplayer( attacker ) )
		{
			if ( !isSP() )
				attacker [[ level.func[ "damagefeedback" ] ]]( "false" );
			/* no more hit indicator in SP, commenting this out and replacing with the line above for MP only
			if ( isSP() )
				attacker [[ level.func[ "damagefeedback" ] ]]( self );
			else
				attacker [[ level.func[ "damagefeedback" ] ]]( "false" );
			*/
			self thread sentry_allowFire( false, 2.0 );
		}

		if ( self sentry_hit_bullet_armor( type ) )
		{
			//damage was to bullet armor, restore health and decrement bullet armor.
			self.health = self.currenthealth;
			self.bullet_armor -= amount;
		}
		else
			self.currenthealth = self.health;

		if ( self.health < self.healthbuffer )
			break;
	}

	if ( !isSP() &&  attacker sentry_attacker_can_get_xp( self ) )
		attacker thread [[ level.onXPEvent ]]( "kill" );

	self notify( "death", attacker, type );
}

sentry_hit_bullet_armor( type )
{
	if ( self.bullet_armor <= 0 )
		return false;
	if ( !( isdefined( type ) ) )
		return false;
	if ( ! issubstr( type, "BULLET" ) )
		return false;
	else
		return true;
}

enemy_sentry_difficulty_settings()
{
	difficulty = "easy";
	
	self SetConvergenceTime( level.sentryTurretSettings[ difficulty ][ "convergencePitchTime" ], "pitch" );	
    self SetConvergenceTime( level.sentryTurretSettings[ difficulty ][ "convergenceYawTime" ], "yaw" );    
	self SetSuppressionTime( level.sentryTurretSettings[ difficulty ][ "suppressionTime" ] );
	self SetAiSpread( level.sentryTurretSettings[ difficulty ][ "aiSpread" ] );
	self SetPlayerSpread( level.sentryTurretSettings[ difficulty ][ "playerSpread" ] );

	self.maxrange = 1100;
	self.bullet_armor = minigun_sentry_bullet_armor_enemy;
}

waitActivateButton( bCheck )
{
	if ( !isSP() )
	{
		self endon( "death" );
		self endon( "disconnect" );
	}

	assert( isdefined( bCheck ) );

	if ( bCheck == true )
	{
		while ( !self attackButtonPressed() && !self useButtonPressed() )
			wait 0.05;
	}
	else if ( bCheck == false )
	{
		while ( self attackButtonPressed() || self useButtonPressed() )
			wait 0.05;
	}
}

makeSentrySolid()
{
	self makeTurretSolid();
}

makeSentryNotSolid()
{
	self.contents = self setContents( 0 );
}


SentryPowerOn()
{
	self setMode( sentry_mode_name_on );
	self.battery_usage = true;
}

SentryPowerOff()
{
	self setMode( sentry_mode_name_off );
	self.battery_usage = false;
}

// =============================================================================
// MP functions:
// =============================================================================


// MP sentry team and head icons
sentry_team_setup( sentry_gun )
{
	// self == player

	assert( isDefined( sentry_gun ) );
	assert( isDefined( sentry_gun.sentryType ) );
	
	if ( isdefined( self.pers[ "team" ] ) )
		sentry_gun.pers[ "team" ] = self.pers[ "team" ];

	sentry_gun sentry_team_show_icon();
}


sentry_team_show_icon()
{
	assert( isdefined( level.func[ "setTeamHeadIcon" ] ) );

	sentry_headicon_offset = ( 0, 0, 65 );
	if ( self.sentryType == "sentry_gun" )
		sentry_headicon_offset = ( 0, 0, 75 );

	self [[ level.func[ "setTeamHeadIcon" ] ]]( self.pers[ "team" ], sentry_headicon_offset );
}


// MP clear team and head icons
sentry_team_hide_icon()
{
	assert( isdefined( level.func[ "setTeamHeadIcon" ] ) );
	self [[ level.func[ "setTeamHeadIcon" ] ]]( "none", (0, 0, 0) );
}


// resets sentry placement mode when owner carrying sentry dies
sentry_place_mode_reset()
{
	if ( !isDefined(self.owner) )
		return;
		
	if ( isDefined( self.owner.placingSentry ) && (self.owner.placingSentry == self) )
	{
		self.owner notify( "sentry_placement_canceled" );
		self.owner _enableWeapon();
		//self.owner _enableUsability();
		self.owner.placingSentry = undefined;
		self setSentryCarried( false );
		self SetCanDamage( true );
		self.ignoreMe = false;
	}
}

sentry_set_owner( owner )
{
	assert( isdefined( owner ) );
	assert( isPlayer( owner ) );
	
	// don't need to set it twice. will happen for non-static sentries
	if ( isDefined ( self.owner ) && self.owner == owner )
		return;

	owner.debug_sentry			 = self;// for debug
	self.owner 					 = owner;
	self SetSentryOwner( owner );
	self SetTurretMinimapVisible( true );
}

sentry_destroy_on_owner_leave( owner )
{
	level endon( "game_ended" );
	self endon( "death" );

	owner waittill_any( "disconnect", "joined_team", "joined_spectators" );
	self notify( "death" );
}

// battery monitor, batter only used while sentry is on
sentry_die_on_batteryout()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "deleted" );

	// only one instance
	self notify( "battery_count_started" );
	self endon( "battery_count_started" );

	while ( self.sentry_battery_timer >= 0 )
	{
		if ( self.battery_usage )
			self.sentry_battery_timer -= 1;
		wait 1;
	}

	self notify( "death" );
}

removeDeadSentry()
{
	self playsound( "sentry_explode" );
	playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );
	self delete_sentry_turret();
}


sentry_reset_on_owner_death()
{
	// self is sentry
	assert( isDefined( self ) );
	self endon( "death" );
	self endon( "deleted" );

	assert( isdefined( self.owner ) );
	self.owner waittill_any( "death", "disconnect" );

	if ( isDefined( self.owner.placingSentry ) && (self.owner.placingSentry == self) )
	{
		self.owner.placingSentry = undefined;
		self setSentryCarried( false );
		self SetCanDamage( true );
		self.ignoreMe = false;
		self notify( "death" );
	}
}

sentry_attacker_can_get_xp( sentry )
{
	assert( isdefined( sentry.owner ) );

	// defensive much?
	if ( !isdefined( self ) )
		return false;

	if ( !isPlayer( self ) )
		return false;

	if ( !isdefined( level.onXPEvent ) )
		return false;

	if ( !isdefined( self.pers[ "team" ] ) )
		return false;

	if ( !isdefined( sentry.team ) )
		return false;

	if ( !level.teambased && self == sentry.owner )
		return false;

	if ( level.teambased && ( self.pers[ "team" ] == sentry.team ) )
		return false;

	return true;
}


sentry_attacker_is_friendly( sentry )
{
	assert( isdefined( sentry.owner ) );

	// defensive much?
	if ( !isdefined( self ) )
		return false;

	if ( !isPlayer( self ) )
		return false;

	if ( !level.teamBased )
		return false;
	
	if ( self == sentry.owner )
		return false;

	if ( self.team != sentry.team )
		return false;

	return true;	
}


sentry_emp_damage_wait()
{
	self endon( "deleted" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "emp_damage", attacker, duration );

		// TODO: friendly fire check here

		self thread sentry_burst_fire_stop();

		if ( isdefined( level.laserOff_func ) )
			self call [[ level.laserOff_func ]]();

		self SentryPowerOff();
		playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );

		wait( duration );

		self SentryPowerOn();
	}
}


sentry_emp_wait()
{
	self endon( "deleted" );
	self endon( "death" );

	for ( ;; )
	{
		level waittill( "emp_update" );

		// TODO: make this work in FFA
		if ( level.teamEMPed[self.team] )
		{
			self thread sentry_burst_fire_stop();
	
			if ( isdefined( level.laserOff_func ) )
				self call [[ level.laserOff_func ]]();
	
			self SentryPowerOff();
			playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );
		}
		else
		{
			self SentryPowerOn();
		}
	}
}

addToTurretList()
{
	level.turrets[self getEntityNumber()] = self;	
}

removeFromTurretList()
{
	level.turrets[self getEntityNumber()] = undefined;
}

dual_waittill( ent1, msg1, ent2, msg2 )
{
	ent1 endon ( msg1 );
	ent2 endon ( msg2 );
	
	level waittill ( "hell_freezes_over_AND_THEN_thaws_out" );
}