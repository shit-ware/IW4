#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	if ( !isDefined( game["gamestarted"] ) )
	{
		//setMatchDataDef( "mp/matchdata_" + level.gametype + ".def" );
		setMatchDataDef( "mp/matchdata.def" );
		setMatchData( "map", level.script );
		setMatchData( "gametype", level.gametype );
		setMatchData( "buildVersion", getBuildVersion() );
		setMatchData( "buildNumber", getBuildNumber() );
		setMatchData( "dateTime", getSystemTime() );
	}

	level.MaxLives = 250; // must match MaxKills in matchdata definition
	level.MaxNameLength = 21; // must match Player xuid size in clientmatchdata definition
	level.MaxEvents = 150;
	level.MaxKillstreaks = 125;
	level.MaxLogClients = 128;
	
	level thread gameEndListener();
}


logKillstreakEvent( event, position )
{
	assertEx( isPlayer( self ), "self is not a player: " + self.code_classname );
	
	if ( !matchMakingGame() || !canLogClient( self ) || !canLogKillstreak() )
		return;

	eventId = getMatchData( "killstreakCount" );
	setMatchData( "killstreakCount", eventId+1 );
	
	setMatchData( "killstreaks", eventId, "eventType", event );
	setMatchData( "killstreaks", eventId, "player", self.clientid );
	setMatchData( "killstreaks", eventId, "eventTime", getTime() );	
	setMatchData( "killstreaks", eventId, "eventPos", 0, int( position[0] ) );	
	setMatchData( "killstreaks", eventId, "eventPos", 1, int( position[1] ) );	
	setMatchData( "killstreaks", eventId, "eventPos", 2, int( position[2] ) );	
}


logGameEvent( event, position )
{
	assertEx( isPlayer( self ), "self is not a player: " + self.code_classname );

	if ( !matchMakingGame() || !canLogClient( self ) || !canLogEvent() )
		return;
		
	eventId = getMatchData( "eventCount" );
	setMatchData( "eventCount", eventId+1 );
	
	setMatchData( "events", eventId, "eventType", event );
	setMatchData( "events", eventId, "player", self.clientid );
	setMatchData( "events", eventId, "eventTime", getTime() );	
	setMatchData( "events", eventId, "eventPos", 0, int( position[0] ) );	
	setMatchData( "events", eventId, "eventPos", 1, int( position[1] ) );	
	setMatchData( "events", eventId, "eventPos", 2, int( position[2] ) );	
}


logKillEvent( lifeId, eventRef )
{
	if ( !matchMakingGame() || !canLogLife( lifeId ) )
		return;

	setMatchData( "lives", lifeId, "modifiers", eventRef, true );
}


logMultiKill( lifeId, multikillCount )
{
	if ( !matchMakingGame() || !canLogLife( lifeId ) )
		return;

	setMatchData( "lives", lifeId, "multikill", multikillCount );
}


logPlayerLife( lifeId )
{
	if ( !matchMakingGame() || !canLogClient( self ) || !canLogLife( lifeId ) )
		return;
		
	setMatchData( "lives", lifeId, "player", self.clientid );
	setMatchData( "lives", lifeId, "spawnPos", 0,  int( self.spawnPos[0] ) );
	setMatchData( "lives", lifeId, "spawnPos", 1,  int( self.spawnPos[1] ) );
	setMatchData( "lives", lifeId, "spawnPos", 2,  int( self.spawnPos[2] ) );
	setMatchData( "lives", lifeId, "wasTacticalInsertion", self.wasTI );
	setMatchData( "lives", lifeId, "team", self.team );
	setMatchData( "lives", lifeId, "spawnTime", self.spawnTime );	
	setMatchData( "lives", lifeId, "duration", getTime() - self.spawnTime );
		
	self logLoadout( lifeId );
}


logLoadout( lifeId )
{
	if ( !matchMakingGame() || !canLogClient( self ) || !canLogLife( lifeId ) )
		return;

	class = self.curClass;

	if ( class == "copycat" )
	{
		clonedLoadout = self.pers["copyCatLoadout"];

		loadoutPrimary = clonedLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = clonedLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = clonedLoadout["loadoutPrimaryAttachment2"] ;
		loadoutPrimaryCamo = clonedLoadout["loadoutPrimaryCamo"];
		loadoutSecondary = clonedLoadout["loadoutSecondary"];
		loadoutSecondaryAttachment = clonedLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = clonedLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryCamo = clonedLoadout["loadoutSecondaryCamo"];
		loadoutEquipment = clonedLoadout["loadoutEquipment"];
		loadoutPerk1 = clonedLoadout["loadoutPerk1"];
		loadoutPerk2 = clonedLoadout["loadoutPerk2"];
		loadoutPerk3 = clonedLoadout["loadoutPerk3"];
		loadoutOffhand = clonedLoadout["loadoutOffhand"];
		loadoutDeathStreak = "specialty_copycat";
	}
	else if( isSubstr( class, "custom" ) )
	{
		class_num = maps\mp\gametypes\_class::getClassIndex( class );

		loadoutPrimary = maps\mp\gametypes\_class::cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = maps\mp\gametypes\_class::cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::cac_getWeaponAttachmentTwo( class_num, 0 );

		loadoutSecondary = maps\mp\gametypes\_class::cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = maps\mp\gametypes\_class::cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::cac_getWeaponAttachmentTwo( class_num, 1 );

		loadoutOffhand = maps\mp\gametypes\_class::cac_getOffhand( class_num );

		loadoutEquipment = maps\mp\gametypes\_class::cac_getPerk( class_num, 0 );
		loadoutPerk1 = maps\mp\gametypes\_class::cac_getPerk( class_num, 1 );
		loadoutPerk2 = maps\mp\gametypes\_class::cac_getPerk( class_num, 2 );
		loadoutPerk3 = maps\mp\gametypes\_class::cac_getPerk( class_num, 3 );
	}
	else
	{
		class_num = maps\mp\gametypes\_class::getClassIndex( class );
		
		loadoutPrimary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, class_num, 0 );
		loadoutPrimaryAttachment = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 0 , 0);
		loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );

		loadoutSecondary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, class_num, 1 );
		loadoutSecondaryAttachment = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 1 , 0);
		loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );;

		loadoutOffhand = maps\mp\gametypes\_class::table_getOffhand( level.classTableName, class_num );

		loadoutEquipment = maps\mp\gametypes\_class::table_getEquipment( level.classTableName, class_num, 0 );
		loadoutPerk1 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 1 );
		loadoutPerk2 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 2 );
		loadoutPerk3 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 3 );
	}
	
	setMatchData( "lives", lifeId, "primaryWeapon", loadoutPrimary );
	setMatchData( "lives", lifeId, "primaryAttachments", 0, loadoutPrimaryAttachment );
	setMatchData( "lives", lifeId, "primaryAttachments", 1, loadoutPrimaryAttachment2 );

	setMatchData( "lives", lifeId, "secondaryWeapon", loadoutSecondary );
	setMatchData( "lives", lifeId, "secondaryAttachments", 0,  loadoutSecondaryAttachment );
	setMatchData( "lives", lifeId, "secondaryAttachments", 1,  loadoutSecondaryAttachment );

	setMatchData( "lives", lifeId, "offhandWeapon", loadoutOffhand );

	setMatchData( "lives", lifeId, "equipment", loadoutEquipment );
	setMatchData( "lives", lifeId, "perks", 0, loadoutPerk1 );
	setMatchData( "lives", lifeId, "perks", 1, loadoutPerk2 );
	setMatchData( "lives", lifeId, "perks", 2, loadoutPerk3 );
}


logPlayerDeath( lifeId, attacker, iDamage, sMeansOfDeath, sWeapon, sPrimaryWeapon, sHitLoc )
{	
	if ( !matchMakingGame() || !canLogClient( self ) || ( isPlayer( attacker ) && !canLogClient( attacker ) ) || !canLogLife( lifeId ) )
		return;
	
	if ( lifeId >= level.MaxLives )
		return;
	
	if ( sWeapon == "none" )
	{
		sWeaponType = "none";
		sWeaponClass = "none";
	}
	else
	{
		sWeaponType = weaponInventoryType( sWeapon );
		sWeaponClass = weaponClass( sWeapon );
	}
	
	if ( isDefined( sWeaponType ) && (sWeaponType == "primary" || sWeaponType == "altmode") && (sWeaponClass == "pistol" || sWeaponClass == "smg" || sWeaponClass == "rifle" || sWeaponClass == "spread" || sWeaponClass == "mg" || sWeaponClass == "grenade" || sWeaponClass == "rocketlauncher" || sWeaponClass == "sniper") )
	{
		sWeaponOriginal = undefined;
		
		if ( sWeaponType == "altmode" )
		{
			sWeaponOriginal = sWeapon;
			sWeapon = sPrimaryWeapon;
			
			setMatchData( "lives", lifeId, "altMode", true );
		}
		
		weaponTokens = strTok( sWeapon, "_" );

		/#
		if ( !(weaponTokens.size > 1 && weaponTokens.size <= 4) )
		{
			PrintLn( "attacker: ", attacker );
			PrintLn( "iDamage: ", iDamage );
			PrintLn( "sMeansOfDeath: ", sMeansOfDeath );
			
			if ( isDefined( sWeaponOriginal ) )
				PrintLn( "sWeaponOriginal: ", sWeaponOriginal );
				
			PrintLn( "sWeapon: ", sWeapon );
			PrintLn( "sPrimaryWeapon: ", sPrimaryWeapon );
			PrintLn( "--------------------------------" );
			PrintLn( "sWeaponType: ", sWeaponType );
			PrintLn( "sWeaponClass: ", sWeaponClass );
			PrintLn( "--------------------------------" );
			PrintLn( "weaponTokens.size: ", weaponTokens.size );

			tokenCount = 0;
			foreach ( token in weaponTokens )
			{
				PrintLn( "weaponTokens[", tokenCount, "]: ", weaponTokens[tokenCount] );
				tokenCount++;
			}
		}
		#/
		assert( weaponTokens.size > 1 && weaponTokens.size <= 4 );

		assertEx( weaponTokens[weaponTokens.size - 1] == "mp", "weaponTokens[weaponTokens.size - 1]: " + weaponTokens[weaponTokens.size - 1] );
		weaponTokens[weaponTokens.size - 1] = undefined; // remove the trailing "mp"
				
		setMatchData( "lives", lifeId, "weapon", weaponTokens[0] );

		if ( isDefined( weaponTokens[1] ) )
			setMatchData( "lives", lifeId, "attachments", 0, weaponTokens[1] );

		if ( isDefined( weaponTokens[2] ) )
			setMatchData( "lives", lifeId, "attachments", 1, weaponTokens[2] );
	}
	else if ( sWeaponType == "item" || sWeaponType == "offhand" )
	{
		weaponName = strip_suffix( sWeapon, "_mp" );
		setMatchData( "lives", lifeId, "weapon", weaponName );		
	}
	else
	{
		setMatchData( "lives", lifeId, "weapon", sWeapon );
	}
	
	if ( isKillstreakWeapon( sWeapon ) )
		setMatchData( "lives", lifeId, "modifiers", "killstreak", true );
		
	setMatchData( "lives", lifeId, "mod", sMeansOfDeath );
	if ( isPlayer( attacker ) )
	{
		setMatchData( "lives", lifeId, "attacker", attacker.clientid );
		setMatchData( "lives", lifeId, "attackerPos", 0, int( attacker.origin[0] ) );
		setMatchData( "lives", lifeId, "attackerPos", 1, int( attacker.origin[1] ) );
		setMatchData( "lives", lifeId, "attackerPos", 2, int( attacker.origin[2] ) );

		victimForward = anglesToForward( (0,self.angles[1],0) );
		attackDirection = (self.origin - attacker.origin);
		attackDirection = VectorNormalize( (attackDirection[0], attackDirection[1], 0) );
		setMatchData( "lives", lifeId, "dotOfDeath", VectorDot( victimForward, attackDirection ) );
	}
	else
	{
		// 255 is world
		setMatchData( "lives", lifeId, "attacker", 255 );
		setMatchData( "lives", lifeId, "attackerPos", 0, int( self.origin[0] ) );
		setMatchData( "lives", lifeId, "attackerPos", 1, int( self.origin[1] ) );
		setMatchData( "lives", lifeId, "attackerPos", 2, int( self.origin[2] ) );
	}
	
	setMatchData( "lives", lifeId, "player", self.clientid );
	setMatchData( "lives", lifeId, "deathPos", 0, int( self.origin[0] ) );
	setMatchData( "lives", lifeId, "deathPos", 1, int( self.origin[1] ) );
	setMatchData( "lives", lifeId, "deathPos", 2, int( self.origin[2] ) );

	setMatchData( "lives", lifeId, "deathAngles", 0, int( self.angles[0] ) );
	setMatchData( "lives", lifeId, "deathAngles", 1, int( self.angles[1] ) );
	setMatchData( "lives", lifeId, "deathAngles", 2, int( self.angles[2] ) );	
}


logPlayerData()
{
	if ( !matchMakingGame() || !canLogClient( self ) )
		return;
		
	setMatchData( "players", self.clientid, "score", self getPersStat( "score" ) );
	setMatchData( "players", self.clientid, "assists", self getPersStat( "assists" ) );
	setMatchData( "players", self.clientid, "longestStreak", self getPersStat( "longestStreak" ) );
}


// log the lives of players who are still alive at match end.
gameEndListener()
{
	if ( !matchMakingGame() )
		return;

	level waittill ( "game_ended" );
	
	setMatchData( "gameLength", int( getTimePassed() ) );
	
	foreach ( player in level.players )
	{		
		if ( player.team != "allies" && player.team != "axis" )
			continue;

		player logPlayerData();
			
		if ( !isAlive( player ) )
			continue;
			
		lifeId = getNextLifeId();
		player logPlayerLife( lifeId );
	}
}



canLogClient( client )
{
	assertEx( isPlayer( client ) , "Client is not a player: " + client.code_classname );
	return ( client.clientid < level.MaxLogClients );
}

canLogEvent()
{
	return ( getMatchData( "eventCount" ) < level.MaxEvents );
}

canLogKillstreak()
{
	return ( getMatchData( "killstreakCount" ) < level.MaxKillstreaks );
}

canLogLife( lifeId )
{
	return ( getMatchData( "lifeCount" ) < level.MaxLives );
}
