// 200 participation points are given to the player for killing an enemy
// 800 participation points are taken from the player for killing a friendly
// friendly damage removes points based on amount of damage done and distance
// a max of 1000 points is allowed
// the player will fail the mission when level.friendlyfire["min_participation"] is reached
#include maps\_utility;
main()
{
	level.friendlyfire[ "min_participation" ] 	 = -200;	// when the player hit this number of participation points the mission is failed
	level.friendlyfire[ "max_participation" ]	 = 1000;	// the player will stop gaining participation points once this amount is earned
	level.friendlyfire[ "enemy_kill_points" ]	 = 250;		// this many participation points are earned for killing an enemy
	level.friendlyfire[ "friend_kill_points" ] 	 = -650;	// participation point penalty for killing a friendly
	level.friendlyfire[ "point_loss_interval" ] = 1.25;		// amount of time a point lasts

	level.player.participation = 0;

	level.friendlyFireDisabled = 0;
	level.friendlyFireDisabledForDestructible = 0;// don't ever set this, it's used internally only and shouldn't be set by your script
	SetDvarIfUninitialized( "friendlyfire_dev_disabled", "0" );

	common_scripts\utility::flag_init( "friendly_fire_warning" );

	thread debug_friendlyfire();
	thread participation_point_flattenOverTime();
}

debug_friendlyfire()
{
/#
	SetDvarIfUninitialized( "debug_friendlyfire", "0" );

	friendly_fire = NewHudElem();
	friendly_fire.alignX = "right";
	friendly_fire.alignY = "middle";
	friendly_fire.x = 620;
	friendly_fire.y = 100;
	friendly_fire.fontScale = 2;
	friendly_fire.alpha = 0;

	for ( ;; )
	{
		if ( GetDebugDvar( "debug_friendlyfire" ) == "1" )
			friendly_fire.alpha = 1;
		else
			friendly_fire.alpha = 0;

		friendly_fire SetValue( level.player.participation );
		wait 0.25;
	}
#/
}

// every entity that influences friedly fire should run this thread (ai of both teams, vehicles of both teams)
friendly_fire_think( entity )
{
	if ( !isdefined( entity ) )
		return;
	if ( !isdefined( entity.team ) )
		entity.team = "allies";

	if ( IsDefined( level.no_friendly_fire_penalty ) )
		return;

	// if the mission is failed from another entity running this function then end this one
	level endon( "mission failed" );

	// wait until this entity dies
	level thread notifyDamage( entity );
	level thread notifyDamageNotDone( entity );
	level thread notifyDeath( entity );

	for ( ;; )
	{
		if ( !isdefined( entity ) )
			return;

		if ( entity.health <= 0 )
			return;

		entity waittill( "friendlyfire_notify", damage, attacker, direction, point, method, weaponName );
		
		if ( !isdefined( entity ) )
			return;

		// if we dont know who the attacker is we can't do much, so ignore it. This is seldom to happen, but not impossible
		if ( !isdefined( attacker ) )
			continue;

		// check to see if the death was caused by the player or the players turret
		bPlayersDamage = false;
		
		if ( !isdefined( weaponName ) )
			weaponName = entity.damageweapon;
		
		if ( IsPlayer( attacker ) )
		{
			bPlayersDamage = true;
			
			// player shot a red barrel or something similar and it blew up and damaged/killed this guy so just ignore it
			if ( isdefined( weaponName ) && ( weaponName == "none" ) )
				bPlayersDamage = false;
			
			// code doesn't give the correct weaponname on damage and death notifies when on a turret, so we have to workaround it here
			if ( attacker isUsingTurret() )
				bPlayersDamage = true;
		}
		else
		if ( ( IsDefined( attacker.code_classname ) ) && ( attacker.code_classname == "script_vehicle" ) )
		{
			owner = attacker GetVehicleOwner();
			if ( ( IsDefined( owner ) ) && ( IsPlayer( owner ) ) )
				bPlayersDamage = true;
		}

		// if the player didn't cause the damage then disregard
		if ( !bPlayersDamage )
			continue;

		if ( !isdefined( entity.team ) )
			continue;

		same_team = entity.team == level.player.team;
		
		civilianKilled = undefined;
		if( level.script != "airport" )
			civilianKilled = IsSubStr( entity.classname, "civilian" );
		else	
			civilianKilled = false;
		
		killed = damage == -1;

		// if an enemy was killed then incriment the players participation score
		if ( !same_team && !civilianKilled )
		{
			if ( killed )
			{
				level.player.participation += level.friendlyfire[ "enemy_kill_points" ];
				participation_point_cap();
				return;
			}
			continue;
		}

		//player killed/damaged a friendly
		if ( IsDefined( entity.no_friendly_fire_penalty ) )
			continue;

		if ( ( method == "MOD_PROJECTILE_SPLASH" ) && ( IsDefined( level.no_friendly_fire_splash_damage ) ) )
			continue;

		// don't cause friendly fire from claymores because it's probably the AI's fault not the players
		if ( IsDefined( weaponName ) && ( weaponName == "claymore" ) )
			continue;

		if ( killed )
		{
			level.player.participation += level.friendlyfire[ "friend_kill_points" ];
		}
		else
		{
			// friendly was damaged - figure out how many participation points to remove
			level.player.participation -= damage;
		}

		participation_point_cap();

		// dont fail the mission if death was caused by a grenade that was cooking durring an autosave
		if ( check_grenade( entity, method ) && savecommit_afterGrenade() )
		{
			if ( killed )
				return;
			else
				continue;
		}

		// fail the mission if the players participation has reached the minimum
		friendly_fire_checkPoints( civilianKilled );
	}
}

friendly_fire_checkPoints( civilianKilled )
{
	if ( ( IsDefined( level.failOnFriendlyFire ) ) && ( level.failOnFriendlyFire ) )
	{
		level thread missionfail( civilianKilled );
		return;
	}

	if ( level.friendlyFireDisabledForDestructible == 1 )
		return;

	if ( level.friendlyFireDisabled == 1 )
		return;

	if ( level.player.participation <= ( level.friendlyfire[ "min_participation" ] ) )
		level thread missionfail( civilianKilled );
}

check_grenade( entity, method )
{
	if ( !isdefined( entity ) )
		return false;

	// check if the entity was killed by a grenade
	wasGrenade = false;
	if ( ( IsDefined( entity.damageweapon ) ) && ( entity.damageweapon == "none" ) )
		wasGrenade = true;
	if ( ( IsDefined( method ) ) && ( method == "MOD_GRENADE_SPLASH" ) )
		wasGrenade = true;

	// if the entity was not killed by a grenade then exit
	return wasGrenade;
}

savecommit_afterGrenade()
{
	currentTime = GetTime();
	if ( currentTime < 4500 )
	{
		PrintLn( "^3aborting friendly fire because the level just loaded and saved and could cause a autosave grenade loop" );
		return true;
	}
	else
	if ( ( currentTime - level.lastAutoSaveTime ) < 4500 )
	{
		PrintLn( "^3aborting friendly fire because it could be caused by an autosave grenade loop" );
		return true;
	}
	return false;
}

participation_point_cap()
{
	if ( level.player.participation > level.friendlyfire[ "max_participation" ] )
		level.player.participation = level.friendlyfire[ "max_participation" ];
	if ( level.player.participation < level.friendlyfire[ "min_participation" ] )
		level.player.participation = level.friendlyfire[ "min_participation" ];
}

participation_point_flattenOverTime()
{
	level endon( "mission failed" );
	for ( ;; )
	{
		if ( level.player.participation > 0 )
		{
			level.player.participation--;
		}
		else if ( level.player.participation < 0 )
		{
			level.player.participation++;
		}
		wait level.friendlyfire[ "point_loss_interval" ];
	}
}


TurnBackOn()
{
	level.friendlyFireDisabled = 0;
}


TurnOff()
{
	level.friendlyFireDisabled = 1;
}


missionfail( civilianKilled )
{
	if ( !isdefined( civilianKilled ) )
		civilianKilled = false;

	if ( level.script == "airport" )
	{
		if ( civilianKilled )
			return;

		common_scripts\utility::flag_set( "friendly_fire_warning" );
		return;
	}

	if ( GetDvar( "friendlyfire_dev_disabled" ) == "1" )
		return;

	level.player endon( "death" );
	level endon( "mine death" );
	level notify( "mission failed" );
	level notify( "friendlyfire_mission_fail" );

	waittillframeend;

	SetSavedDvar( "hud_missionFailed", 1 );

	if ( IsDefined( level.player.failingMission ) )
		return;

	if ( civilianKilled )
			// You shot a civilian. Watch your fire!
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_CIVILIAN_KILLED" );	// You shot a civilian. Watch your fire!
	else if ( IsDefined( level.custom_friendly_fire_message ) )
		SetDvar( "ui_deadquote", level.custom_friendly_fire_message );		// friendly fire will not be tolerated
	else if ( level.campaign == "british" )
			// Friendly fire will not be tolerated!
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_BRITISH" );	// Friendly fire will not be tolerated!
	else if ( level.campaign == "russian" )
			// You are a traitor to the motherland!
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_RUSSIAN" );	// You are a traitor to the motherland!
	else
			// Friendly fire will not be tolerated!
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_AMERICAN" );	// Friendly fire will not be tolerated!

	// shader if specified
	if ( IsDefined( level.custom_friendly_fire_shader ) )
		thread maps\_load::special_death_indicator_hudelement( level.custom_friendly_fire_shader, 64, 64, 0 );

	//logString( "failed mission: Friendly fire" );

	maps\_utility::missionFailedWrapper();
}

notifyDamage( entity )
{
	level endon( "mission failed" );
	entity endon( "death" );
	for ( ;; )
	{
		entity waittill( "damage", damage, attacker, direction, point, method, modelName, tagName, partName, dFlags, weaponName );
		entity notify( "friendlyfire_notify", damage, attacker, direction, point, method, weaponName );
	}
}

notifyDamageNotDone( entity )
{
	level endon( "mission failed" );
	entity waittill( "damage_notdone", damage, attacker, direction, point, method );
	entity notify( "friendlyfire_notify", -1, attacker, undefined, undefined, method );
}

notifyDeath( entity )
{
	level endon( "mission failed" );
	entity waittill( "death", attacker, method, weaponName );
	entity notify( "friendlyfire_notify", -1, attacker, undefined, undefined, method, weaponName );
}

detectFriendlyFireOnEntity( entity )
{
	/*
	if ( !isdefined( entity ) )
		return;
	AssertEx( IsDefined( entity.team ), "You must set .team to allies or axis for an entity calling detectFriendlyFire()" );
	
	entity SetCanDamage( true );
	level thread friendly_fire_think( entity );
	*/
}
