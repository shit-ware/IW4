#include maps\_utility;

precacheLevelStuff()
{
	// Press ^3[{weapnext}]^7 to cycle through weapons.
	precachestring( &"AC130_HINT_CYCLE_WEAPONS" );
	// You have not been cleared to fire. Mission failed.
	precachestring( &"AC130_DO_NOT_ENGAGE" );
	// You damaged the church. Mission failed.
	precachestring( &"AC130_CHURCH_DAMAGED" );
	// The friendly escape convoy was destroyed. Mission failed.
	precachestring( &"AC130_ESCAPEVEHICLE_DESTROYED" );
	// \n0         A-G        MAN    NARO
	precachestring( &"AC130_HUD_TOP_BAR" );
	// RAY\nFF 30\nLIR\n\nBORE
	precachestring( &"AC130_HUD_LEFT_BLOCK" );
	// N\nT\n\nS\nF\n\nQ\nZ\n\nT\nG\nT
	precachestring( &"AC130_HUD_RIGHT_BLOCK" );
	// L1514    RDY
	precachestring( &"AC130_HUD_BOTTOM_BLOCK" );
	// WHOT
	precachestring( &"AC130_HUD_THERMAL_WHOT" );
	// BHOT
	precachestring( &"AC130_HUD_THERMAL_BHOT" );
	// 105 mm
	precachestring( &"AC130_HUD_WEAPON_105MM" );
	// 40 mm
	precachestring( &"AC130_HUD_WEAPON_40MM" );
	// 25 mm
	precachestring( &"AC130_HUD_WEAPON_25MM" );
	// &&1 AGL
	precachestring( &"AC130_HUD_AGL" );
	// Friendlies: &&1
	precachestring( &"AC130_DEBUG_FRIENDLY_COUNT" );
	// Too many friendlies have been KIA. Mission failed.
	precachestring( &"AC130_FRIENDLIES_DEAD" );
	// Friendly fire will not be tolerated!\nWatch for blinking IR strobes on friendly units!
	precachestring( &"AC130_FRIENDLY_FIRE" );
	// You attacked a friendly helicopter!
	precachestring( &"AC130_FRIENDLY_FIRE_HELICOPTER" );
	// You harmed a civilian! Mission failed.
	precachestring( &"AC130_CIVILIAN_FIRE" );
	// You attacked a civilian vehicle! Mission failed.
	precachestring( &"AC130_CIVILIAN_FIRE_VEHICLE" );
	// Provide AC-130 air support for friendly SAS ground units.
	precachestring( &"AC130_OBJECTIVE_SUPPORT_FRIENDLIES" );
	// 'Death From Above'
	precachestring( &"AC130_INTROSCREEN_LINE_1" );
	// Day 2 - 04:20:[{FAKE_INTRO_SECONDS:16}]
	precachestring( &"AC130_INTROSCREEN_LINE_2" );
	// Western Russia
	precachestring( &"AC130_INTROSCREEN_LINE_3" );
	// Thermal Imaging TV Operator
	precachestring( &"AC130_INTROSCREEN_LINE_4" );
	// AC-130H Spectre Gunship
	precachestring( &"AC130_INTROSCREEN_LINE_5" );

	// Pull [{+speed}] to control zoom and  pull [{+attack}] to fire.
	precachestring( &"SCRIPT_PLATFORM_AC130_HINT_ZOOM_AND_FIRE" );
	// Press [{+usereload}] to toggle thermal vision\nbetween white hot and black hot.
	precachestring( &"SCRIPT_PLATFORM_AC130_HINT_TOGGLE_THERMAL" );

	// Provide AC-130 air support for friendly ground units.
	precachestring( &"CO_AC130_OBJECTIVE_COOP_AC130_GUNNER" );
	// Regroup with any survivors from Bravo Team at the crash site.
	precachestring( &"CO_AC130_OBJECTIVE_COOP_GROUND_PLAYER" );

	precacheShader( "popmenu_bg" );

	precacheModel( "tag_laser" );
}

vehicleScripts()
{
	maps\_mi17::main( "vehicle_mi17_woodland_fly_cheap" );
}

laser_targeting_device( player )
{
	player endon( "remove_laser_targeting_device" );
	
	player.lastUsedWeapon = undefined;
	player.laserForceOn = false;
	player setWeaponHudIconOverride( "actionslot4", "dpad_laser_designator" );
	
	player notifyOnPlayerCommand( "use_laser", "+actionslot 4" );
	player notifyOnPlayerCommand( "fired_laser", "+attack" );
	
	for ( ;; )
	{
		player waittill( "use_laser" );

		player ent_flag_set( "player_used_laser" );

		if ( player.laserForceOn )
		{
			player notify( "cancel_laser" );
			player laserForceOff();
//			player allowFire( true );
			player.laserForceOn = false;
		}
		else
		{
			player laserForceOn();
//			player allowFire( false );
			player.laserForceOn = true;		
//			player thread laser_designate_target();
		}
		
		wait 0.05;
	}
}

/*
laser_targeting_device()
{
	setDvarIfUninitialized( "ac130_force_perspective_laser", "1" );

	self.lastUsedWeapon = undefined;
	self.laserForceOn = false;

	for ( ;; )
	{
		while ( self getcurrentweapon() != "laser_targeting_device" )
		{
			self.lastUsedWeapon = self GetCurrentWeapon();
			wait 0.05;
		}

		if ( self.laserForceOn )
		{
			self laserForceOff();
			self.laserForceOn = false;

			if ( isdefined( self.fake_laser ) )
			{
				self.fake_laser laserForceOff();
				self.fake_laser delete();
				self notify( "laser_off" );
			}
		}
		else
		{
			self laserForceOn();
			self LaserHideFromClient( level.ac130gunner );
			self.laserForceOn = true;

			if ( getdvar( "ac130_force_perspective_laser" ) == "1" )
			{
				self.fake_laser = spawn( "script_model", self getEye() );
				self.fake_laser.angles = self getplayerangles();
				self.fake_laser setmodel( "tag_laser" );
				self thread update_laser();
				//self.fake_laser linkto( self );
				self.fake_laser laserForceOn();
				self.fake_laser LaserHideFromClient( level.ground_player );
				
				// turn off hint when laser used, if there is a hint
				if( self ent_flag_exist( "player_used_laser" ) )
					self ent_flag_set( "player_used_laser" );
			}
		}

		self giveBackWeapon();

		while ( self getcurrentweapon() == "laser_targeting_device" )
			wait 0.05;
	}
}
*/

update_laser()
{
	self endon( "laser_off" );
	while( 1 )
	{
		self.fake_laser.origin = self getEye();
		self.fake_laser.angles = self getplayerangles();
		wait 0.05;
	}
}


giveBackWeapon()
{
	if ( ( isdefined( self.lastUsedWeapon ) ) && ( self HasWeapon( self.lastUsedWeapon ) ) )
	{
		self switchToWeapon( self.lastUsedWeapon );
	}
	else
	{
		weaponList = self GetWeaponsListPrimaries();
		if ( isdefined( weaponList[ 0 ] ) )
			self switchToWeapon( weaponList[ 0 ] );
	}
}