#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
	maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
	maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );

	registerAdrenalineInfo( "damage", 10 );
	registerAdrenalineInfo( "damaged", 20 );
	registerAdrenalineInfo( "kill", 50 );
	registerAdrenalineInfo( "killed", 20 );
	
	registerAdrenalineInfo( "headshot", 20 );
	registerAdrenalineInfo( "melee", 10 );
	registerAdrenalineInfo( "backstab", 20 );
	registerAdrenalineInfo( "longshot", 10 );
	registerAdrenalineInfo( "assistedsuicide", 10);
	registerAdrenalineInfo( "defender", 10 );
	registerAdrenalineInfo( "avenger", 10 );
	registerAdrenalineInfo( "execution", 10 );
	registerAdrenalineInfo( "comeback", 50 );
	registerAdrenalineInfo( "revenge", 20 );
	registerAdrenalineInfo( "buzzkill", 20 );	
	registerAdrenalineInfo( "double", 10 );	
	registerAdrenalineInfo( "triple", 20 );	
	registerAdrenalineInfo( "multi", 30 );
	registerAdrenalineInfo( "assist", 20 );

	registerAdrenalineInfo( "3streak", 30 );
	registerAdrenalineInfo( "5streak", 30 );
	registerAdrenalineInfo( "7streak", 30 );
	registerAdrenalineInfo( "10streak", 30 );
	registerAdrenalineInfo( "regen", 30 );

	precacheShader( "crosshair_red" );

	level._effect["money"] = loadfx ("props/cash_player_drop");
	
	level.numKills = 0;

	level thread onPlayerConnect();	
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player.killedPlayers = [];
		player.killedPlayersCurrent = [];
		player.killedBy = [];
		player.lastKilledBy = undefined;
		player.greatestUniquePlayerKills = 0;
		
		player.recentKillCount = 0;
		player.lastKillTime = 0;
		player.damagedPlayers = [];	
		
		player.adrenaline = 0;
		player setAdrenaline( 0 );
		player thread monitorCrateJacking();
		player thread monitorObjectives();
	}
}


damagedPlayer( victim, damage, weapon )
{
//	self giveAdrenaline( "damage" );
//	victim giveAdrenaline( "damaged" );
}


killedPlayer( killId, victim, weapon, meansOfDeath )
{
	victimGuid = victim.guid;
	myGuid = self.guid;
	curTime = getTime();
	
	self thread updateRecentKills( killId );
	self.lastKillTime = getTime();
	self.lastKilledPlayer = victim;

	self.modifiers = [];

	level.numKills++;

	// a player is either damaged, or killed; never both
	self.damagedPlayers[victimGuid] = undefined;
	
	self giveAdrenaline( "kill" );
	victim giveAdrenaline( "killed" );
	
	if ( !isKillstreakWeapon( weapon ) )
	{
		if ( weapon == "none" )
			return false;

		//if ( isSubStr( weapon, "ranger" ) && isDefined( self.bothBarrels ) )  This wont work because this is called before weapons self.bothbarrels would be set
		//	self.modifiers["bothbarrels"] = true;

		if ( isDefined( self.pers["copyCatLoadout"] ) && isDefined( self.pers["copyCatLoadout"]["owner"] ) )
		{
			if ( victim == self.pers["copyCatLoadout"]["owner"] )
				self.modifiers["clonekill"] = true;
		} 
		
		if ( victim.attackers.size == 1 )
		{
			/#
			if ( !isDefined( victim.attackers[self.guid] ) )
			{
				println("Weapon: "+ weapon );
				println("Attacker GUID:" + self.guid );
				
				foreach ( key,value in victim.attackers )
					println( "Victim Attacker list GUID: " + key );
			}
			#/
			assertEx( isDefined( victim.attackers[self.guid] ), "See console log for details" );
			
			weaponClass = getWeaponClass( weapon );
						
			if ( getTime() == victim.attackerData[self.guid].firstTimeDamaged && meansOfDeath != "MOD_MELEE" && ( /*weaponClass == "weapon_shotgun" ||*/ weaponClass == "weapon_sniper" ) )
			{
				self.modifiers["oneshotkill"] = true;
				self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "one_shot_kill" );	
			}
		}

		if ( isDefined( victim.throwingGrenade ) && victim.throwingGrenade == "frag_grenade_mp" )
			self.modifiers["cooking"] = true;
		
		if ( isDefined(self.assistedSuicide) && self.assistedSuicide )
			self assistedSuicide( killId );
		
		if ( level.numKills == 1 )
			self firstBlood( killId );
			
		if ( self.pers["cur_death_streak"] > 3 )
			self comeBack( killId );
			
		if ( meansOfDeath == "MOD_HEAD_SHOT" )
		{
			if ( isDefined( victim.lastStand ) )
				execution( killId );
			else
				headShot( killId );
		}
			
		if ( isDefined(self.wasti) && self.wasti && getTime() - self.spawnTime <= 5000 )
			self.modifiers["jackintheboxkill"] = true;
		
		if ( !isAlive( self ) && self.deathtime + 800 < getTime() )
			postDeathKill( killId );
		
		fakeAvenge = false;
		if ( level.teamBased && curTime - victim.lastKillTime < 500 )
		{
			if ( victim.lastkilledplayer != self )
				self avengedPlayer( killId );		
		}
	
		foreach ( guid, damageTime in victim.damagedPlayers )
		{
			if ( guid == self.guid )
				continue;
	
			if ( level.teamBased && curTime - damageTime < 500 )
				self defendedPlayer( killId );
		}
	
		if ( isDefined( victim.attackerPosition ) )
			attackerPosition = victim.attackerPosition;
		else
			attackerPosition = self.origin;
	
		if ( isAlive( self ) && !self isUsingRemote() && (meansOfDeath == "MOD_RIFLE_BULLET" || meansOfDeath == "MOD_PISTOL_BULLET" || meansOfDeath == "MOD_HEAD_SHOT") && distance( attackerPosition, victim.origin ) > 1536 && !isKillstreakWeapon( weapon ) && !isDefined( self.assistedSuicide ) )
			self thread longshot( killId );
	
		//if ( isAlive( self ) && self.health < 20 && isDefined( self.attackers ) && self.attackers.size == 1 && self.attackers[0] == victim )
		//	victim thread consolation( killId );
	
		if ( isDefined( victim.killstreaks[ victim.pers["cur_kill_streak"] + 1 ] ) )
		{
			// playercard splash for the killstreak stopped
			self buzzKill( killId, victim );
		}
			
		self thread checkMatchDataKills( killId, victim, weapon, meansOfDeath);
		
	}

	if ( !isDefined( self.killedPlayers[victimGuid] ) )
		self.killedPlayers[victimGuid] = 0;

	if ( !isDefined( self.killedPlayersCurrent[victimGuid] ) )
		self.killedPlayersCurrent[victimGuid] = 0;
		
	if ( !isDefined( victim.killedBy[myGuid] ) )
		victim.killedBy[myGuid] = 0;

	self.killedPlayers[victimGuid]++;
	
	//this sets player stat for routine customer award
	if ( self.killedPlayers[victimGuid] > self.greatestUniquePlayerKills )
		self setPlayerStat( "killedsameplayer", self.killedPlayers[victimGuid] );
	
	self.killedPlayersCurrent[victimGuid]++;		
	victim.killedBy[myGuid]++;	

	victim.lastKilledBy = self;		
}


checkMatchDataKills( killId, victim, weapon, meansOfDeath )
{
	weaponClass = getWeaponClass( weapon );
	alreadyUsed = false;
	
	self thread camperCheck();
	
	if ( isDefined( self.lastKilledBy ) && self.lastKilledBy == victim )
	{
		self.lastKilledBy = undefined;
		self revenge( killId );

		playFx( level._effect["money"], victim getTagOrigin( "j_spine4" ) );
	}

	if ( victim.iDFlags & level.iDFLAGS_PENETRATION )
		self incPlayerStat( "bulletpenkills", 1 );
	
	if ( self.pers["rank"] < victim.pers["rank"] )
		self incPlayerStat( "higherrankkills", 1 );
	
	if ( self.pers["rank"] > victim.pers["rank"] )
		self incPlayerStat( "lowerrankkills", 1 );
	
	if ( isDefined( self.laststand ) && self.laststand )
		self incPlayerStat( "laststandkills", 1 );
	
	if ( isDefined( victim.laststand ) && victim.laststand )
		self incPlayerStat( "laststanderkills", 1 );
	
	if ( self getCurrentWeapon() != self.loadoutPrimary + "_mp" && self getCurrentWeapon() != self.loadoutSecondary + "_mp" )
		self incPlayerStat( "otherweaponkills", 1 );

	if ( getBaseWeaponName( weapon ) == "m79" )
		self incPlayerStat( "thumperkills", 1 );
	
	timeAlive = getTime() - victim.spawnTime ;
	
	if( !matchMakingGame() )
		victim setPlayerStatIfLower( "shortestlife", timeAlive );
		
	victim setPlayerStatIfGreater( "longestlife", timeAlive );
	
	switch( weaponClass )
	{
		case "weapon_pistol":
		case "weapon_smg":
		case "weapon_assault":
		case "weapon_projectile":
		case "weapon_sniper":
		case "weapon_shotgun":
		case "weapon_lmg":
			self checkMatchDataWeaponKills( victim, weapon, meansOfDeath, weaponClass );
			break;
		case "weapon_grenade":
		case "weapon_explosive":
			self checkMatchDataEquipmentKills( victim, weapon, meansOfDeath );
			break;
		default:
			break;
	}
}

// Need to make sure these only apply to kills of an enemy, not friendlies or yourself
checkMatchDataWeaponKills( victim, weapon, meansOfDeath, weaponType )
{
	attacker = self;
	kill_ref = undefined;
	headshot_ref = undefined;
	death_ref = undefined;
	
	switch( weaponType )
	{
		case "weapon_pistol":
			kill_ref = "pistolkills";
			headshot_ref = "pistolheadshots";
			break;	
		case "weapon_smg":
			kill_ref = "smgkills";
			headshot_ref = "smgheadshots";
			break;
		case "weapon_assault":
			kill_ref = "arkills";
			headshot_ref = "arheadshots";
			break;
		case "weapon_projectile":
			if ( weaponClass( weapon ) == "rocketlauncher" )
				kill_ref = "rocketkills";
			break;
		case "weapon_sniper":
			kill_ref = "sniperkills";
			headshot_ref = "sniperheadshots";
			break;
		case "weapon_shotgun":
			kill_ref = "shotgunkills";
			headshot_ref = "shotgunheadshots";
			death_ref = "shotgundeaths";
			break;
		case "weapon_lmg":
			kill_ref = "lmgkills";
			headshot_ref = "lmgheadshots";
			break;
		default:
			break;
	}

	if ( isDefined ( kill_ref ) )
		attacker incPlayerStat( kill_ref, 1 );

	if ( isDefined ( headshot_ref ) && meansOfDeath == "MOD_HEAD_SHOT" )
		attacker incPlayerStat( headshot_ref, 1 );

	if ( isDefined ( death_ref ) && !matchMakingGame() )
		victim incPlayerStat( death_ref, 1 );
		
	if ( attacker PlayerAds() > 0.5 ) 
	{
		attacker incPlayerStat( "adskills", 1 );

		if ( weaponType == "weapon_sniper" || isSubStr( weapon, "acog" ) )
			attacker incPlayerStat( "scopedkills", 1 );
		
		if ( isSubStr( weapon, "thermal" ) )
			attacker incPlayerStat( "thermalkills", 1 );
	}
	else
	{
		attacker incPlayerStat( "hipfirekills", 1 );
	}
}

// Need to make sure these only apply to kills of an enemy, not friendlies or yourself
checkMatchDataEquipmentKills( victim, weapon, meansOfDeath )
{	
	attacker = self;
	
	// equipment kills
	switch( weapon )
	{
		case "frag_grenade_mp":
			attacker incPlayerStat( "fragkills", 1 );
			attacker incPlayerStat( "grenadekills", 1 );
			isEquipment = true;
			break;	
		case "c4_mp":
			attacker incPlayerStat( "c4kills", 1 );
			isEquipment = true;
			break;
		case "semtex_mp":
			attacker incPlayerStat( "semtexkills", 1 );
			attacker incPlayerStat( "grenadekills", 1 );
			isEquipment = true;
			break;
		case "claymore_mp":
			attacker incPlayerStat( "claymorekills", 1 );
			isEquipment = true;
			break;
		case "throwingknife_mp":
			attacker incPlayerStat( "throwingknifekills", 1 );
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "knifethrow", maps\mp\gametypes\_rank::getScoreInfoValue( "knifethrow" ) );
			isEquipment = true;
			break;
		default:
			isEquipment = false;
			break;
	}
	
	if ( isEquipment )
		attacker incPlayerStat( "equipmentkills", 1 );
}

camperCheck()
{
	if ( !isDefined ( self.lastKillLocation ) )
	{
		self.lastKillLocation = self.origin;	
		self.lastCampKillTime = getTime();
		return;
	}
	
	if ( Distance( self.lastKillLocation, self.origin ) < 512 && getTime() - self.lastCampKillTime > 5000 )
	{
		self incPlayerStat( "mostcamperkills", 1 );
	}
	
	self.lastKillLocation = self.origin;
	self.lastCampKillTime = getTime();
}

consolation( killId )
{
	/*
	value = int( maps\mp\gametypes\_rank::getScoreInfoValue( "kill" ) * 0.25 );

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "consolation", value );
	self thread maps\mp\gametypes\_rank::giveRankXP( "consolation", value );
	*/
}


longshot( killId )
{
	self.modifiers["longshot"] = true;
	
	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "longshot", maps\mp\gametypes\_rank::getScoreInfoValue( "longshot" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "longshot" );
	self thread giveAdrenaline( "longshot" );
	self incPlayerStat( "longshots", 1 );
	self thread maps\mp\_matchdata::logKillEvent( killId, "longshot" );
}


execution( killId )
{
	self.modifiers["execution"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "execution", maps\mp\gametypes\_rank::getScoreInfoValue( "execution" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "execution" );
	self thread giveAdrenaline( "execution" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "execution" );
}


headShot( killId )
{
	self.modifiers["headshot"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "headshot", maps\mp\gametypes\_rank::getScoreInfoValue( "headshot" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "headshot" );
	self thread giveAdrenaline( "headshot" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "headshot" );
}


avengedPlayer( killId )
{
	self.modifiers["avenger"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "avenger", maps\mp\gametypes\_rank::getScoreInfoValue( "avenger" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "avenger" );
	self thread giveAdrenaline( "avenger" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "avenger" );
	
	self incPlayerStat( "avengekills", 1 );
}

assistedSuicide( killId )
{
	self.modifiers["assistedsuicide"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "assistedsuicide", maps\mp\gametypes\_rank::getScoreInfoValue( "assistedsuicide" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "assistedsuicide" );
	self thread giveAdrenaline( "assistedsuicide" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "assistedsuicide" );
}

defendedPlayer( killId )
{
	self.modifiers["defender"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "defender", maps\mp\gametypes\_rank::getScoreInfoValue( "defender" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "defender" );
	self thread giveAdrenaline( "defender" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "defender" );
	
	self incPlayerStat( "rescues", 1 );
}


postDeathKill( killId )
{
	self.modifiers["posthumous"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "posthumous", maps\mp\gametypes\_rank::getScoreInfoValue( "posthumous" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "posthumous" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "posthumous" );
}


backStab( killId )
{
	self iPrintLnBold( "backstab" );
}


revenge( killId )
{
	self.modifiers["revenge"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "revenge", maps\mp\gametypes\_rank::getScoreInfoValue( "revenge" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "revenge" );
	self thread giveAdrenaline( "revenge" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "revenge" );
	
	self incPlayerStat( "revengekills", 1 );
}


multiKill( killId, killCount )
{
	assert( killCount > 1 );
	
	if ( killCount == 2 )
	{
		self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "doublekill", maps\mp\gametypes\_rank::getScoreInfoValue( "double" ) );
		self thread giveAdrenaline( "double" );
	}
	else if ( killCount == 3 )
	{
		self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "triplekill", maps\mp\gametypes\_rank::getScoreInfoValue( "triple" ) );
		self thread giveAdrenaline( "triple" );
		thread teamPlayerCardSplash( "callout_3xkill", self );
	}
	else
	{
		self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "multikill", maps\mp\gametypes\_rank::getScoreInfoValue( "multi" ) );
		self thread giveAdrenaline( "multi" );
		thread teamPlayerCardSplash( "callout_3xpluskill", self );
	}
	
	self thread maps\mp\_matchdata::logMultiKill( killId, killCount );
	
	// update player multikill record
	self setPlayerStatIfGreater( "multikill", killCount );
	
	// update player multikill count
	self incPlayerStat( "mostmultikills", 1 );
}


firstBlood( killId )
{
	self.modifiers["firstblood"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "firstblood", maps\mp\gametypes\_rank::getScoreInfoValue( "firstblood" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "firstblood" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "firstblood" );

	thread teamPlayerCardSplash( "callout_firstblood", self );
}


winningShot( killId )
{
}


buzzKill( killId, victim )
{
	self.modifiers["buzzkill"] =  victim.pers["cur_kill_streak"];

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "buzzkill", maps\mp\gametypes\_rank::getScoreInfoValue( "buzzkill" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "buzzkill" );
	self thread giveAdrenaline( "buzzkill" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "buzzkill" );
}


comeBack( killId )
{
	self.modifiers["comeback"] = true;

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "comeback", maps\mp\gametypes\_rank::getScoreInfoValue( "comeback" ) );
	self thread maps\mp\gametypes\_rank::giveRankXP( "comeback" );
	self thread giveAdrenaline( "comeback" );
	self thread maps\mp\_matchdata::logKillEvent( killId, "comeback" );

	self incPlayerStat( "comebacks", 1 );
}


disconnected()
{
	myGuid = self.guid;
	
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( isDefined( level.players[entry].killedPlayers[myGuid] ) )
			level.players[entry].killedPlayers[myGuid] = undefined;
	
		if ( isDefined( level.players[entry].killedPlayersCurrent[myGuid] ) )
			level.players[entry].killedPlayersCurrent[myGuid] = undefined;
	
		if ( isDefined( level.players[entry].killedBy[myGuid] ) )
			level.players[entry].killedBy[myGuid] = undefined;
	}
}


updateRecentKills( killId )
{
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self notify ( "updateRecentKills" );
	self endon ( "updateRecentKills" );
	
	self.recentKillCount++;
	
	wait ( 1.0 );
	
	if ( self.recentKillCount > 1 )
		self multiKill( killId, self.recentKillCount );
	
	self.recentKillCount = 0;
}

monitorCrateJacking()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "hijacker", crateType, owner );
		
		if( crateType == "sentry" )
		{
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "hijacker", 100 );
			self thread maps\mp\gametypes\_rank::giveRankXP( "hijacker", 100 );
			if ( isDefined( owner ) )
				owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "hijacked_sentry", self );
			self notify( "process", "ch_hijacker" );
		}
		else if( crateType == "mega" || crateType == "emergency_airdrop" )
		{
			if ( self.team == owner.team )
				continue;
			
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "hijacker", 100 );
			self thread maps\mp\gametypes\_rank::giveRankXP( "hijacker", 100 );
			if ( isDefined( owner ) )
				owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "hijacked_emergency_airdrop", self );
			self notify( "process", "ch_newjack" );
		}
		else
		{
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "hijacker", 100 );
			self thread maps\mp\gametypes\_rank::giveRankXP( "hijacker", 100 );
			if ( isDefined( owner ) )
				owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "hijacked_airdrop", self );
			self notify( "process", "ch_hijacker" );
		}		
	}
}

monitorObjectives()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	
	self waittill( "objective", objType );
	
	if ( objType == "captured" )
	{
		if ( isDefined( self.lastStand ) && self.lastStand )
		{
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "heroic", 100 );
			self thread maps\mp\gametypes\_rank::giveRankXP( "reviver", 100 );
		}
	}	
}

