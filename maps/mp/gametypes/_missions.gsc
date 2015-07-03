#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

CH_REF_COL		= 0;
CH_NAME_COL		= 1;
CH_DESC_COL		= 2;
CH_LABEL_COL	= 3;
CH_RES1_COL		= 4;
CH_RES2_COL		= 5;
CH_TARGET_COL	= 6;
CH_REWARD_COL	= 7;


TIER_FILE_COL	= 4;

init()
{
	precacheString(&"MP_CHALLENGE_COMPLETED");

	if ( !mayProcessChallenges() )
		return;
	
	level.missionCallbacks = [];

	registerMissionCallback( "playerKilled", ::ch_kills );	
	registerMissionCallback( "playerKilled", ::ch_vehicle_kills );
	registerMissionCallback( "playerHardpoint", ::ch_hardpoints );
	registerMissionCallback( "playerAssist", ::ch_assists );	
	registerMissionCallback( "roundEnd", ::ch_roundwin );
	registerMissionCallback( "roundEnd", ::ch_roundplayed );
	registerMissionCallback( "vehicleKilled", ::ch_vehicle_killed );
	
	level thread createPerkMap();
		
	level thread onPlayerConnect();
}

createPerkMap()
{
	level.perkMap = [];
	
	level.perkMap["specialty_bulletdamage"] = "specialty_stoppingpower";
	level.perkMap["specialty_quieter"] = "specialty_deadsilence";
	level.perkMap["specialty_localjammer"] = "specialty_scrambler";
	level.perkMap["specialty_fastreload"] = "specialty_sleightofhand";
	level.perkMap["specialty_pistoldeath"] = "specialty_laststand";
}

ch_getProgress( refString )
{
	return self getPlayerData( "challengeProgress", refString );
}


ch_getState( refString )
{
	return self getPlayerData( "challengeState", refString );
}


ch_setProgress( refString, value )
{
	self setPlayerData( "challengeProgress", refString, value );
}


ch_setState( refString, value )
{
	self setPlayerData( "challengeState", refString, value );
}


mayProcessChallenges()
{
	/#
	if ( getDvarInt( "debug_challenges" ) )
		return true;
	#/
	
	return ( level.rankedMatch );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		if ( !isDefined( player.pers["postGameChallenges"] ) )
			player.pers["postGameChallenges"] = 0;

		player thread onPlayerSpawned();
		player thread initMissionData();
		player thread monitorBombUse();
		player thread monitorFallDistance();
		player thread monitorLiveTime();	
		player thread monitorStreaks();
		player thread monitorStreakReward();
		player thread monitorScavengerPickup();
		player thread monitorBlastShieldSurvival();
		player thread monitorTacInsertionsDestroyed();
		player thread monitorProcessChallenge();
		player thread monitorKillstreakProgress();
		player thread monitorFinalStandSurvival();
		player thread monitorCombatHighSurvival();
		player thread monitorKilledKillstreak();
		
		if ( isDefined( level.patientZeroName ) && isSubStr( player.name, level.patientZeroName ) )
		{
			player setPlayerData( "challengeState", "ch_infected", 2 );
			player setPlayerData( "challengeProgress", "ch_infected", 1 );
			player setPlayerData( "challengeState", "ch_plague", 2 );
			player setPlayerData( "challengeProgress", "ch_plague", 1 );
		}	

		cardTitle = player getPlayerData( "cardTitle" );

		if ( cardTitle == "cardtitle_infected" )
			player.infected = true;
		else if ( cardTitle == "cardtitle_plague" )
			player.plague = true;
	}
}

// TODO: When possible move above onPlayerConnect threads here
onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );

		self thread monitorSprintDistance();
	}
}

monitorScavengerPickup()
{
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill( "scavenger_pickup" ); 
		
		if ( self _hasperk( "specialty_scavenger" ) )
			self processChallenge( "ch_scavenger_pro" );
		
		wait( 0.05 );
	}	
}


monitorStreakReward()
{
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill( "received_earned_killstreak" ); 
		
		if ( self _hasperk( "specialty_hardline" ) )
			self processChallenge( "ch_hardline_pro" );
		
		wait( 0.05 );
	}	
}

monitorBlastShieldSurvival()
{
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill( "survived_explosion" ); 
		
		if ( self _hasperk( "_specialty_blastshield" ) )
			self processChallenge( "ch_masterblaster" );
		
		waitframe();
	}	
}

monitorTacInsertionsDestroyed()
{
	self endon ( "disconnect" );
	
	for(;;)
	{
		self waittill( "destroyed_insertion", owner );
		
		if ( self == owner )
			return;
		
		self processChallenge( "ch_darkbringer" );
		self incPlayerStat( "mosttacprevented", 1 );
	
		self thread maps\mp\gametypes\_hud_message::SplashNotify( "denied", 20 );
		owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "destroyed_insertion", self );

		waitframe();
	}
}

monitorFinalStandSurvival()
{
	self endon ( "disconnect" );
	
	for(;;)
	{
		self waittill( "revive" );
		
		self processChallenge( "ch_livingdead" );

		waitframe();
	}
}

monitorCombatHighSurvival()
{
	self endon ( "disconnect" );

	for(;;)
	{
		self waittill( "combathigh_survived" );
		
		self processChallenge( "ch_thenumb" );

		waitframe();
	}
}

// round based tracking
initMissionData()
{
	keys = getArrayKeys( level.killstreakFuncs );	
	foreach ( key in keys )
		self.pers[key] = 0;
	
	self.pers["lastBulletKillTime"] = 0;
	self.pers["bulletStreak"] = 0;
	self.explosiveInfo = [];
}

registerMissionCallback(callback, func)
{
	if (!isdefined(level.missionCallbacks[callback]))
		level.missionCallbacks[callback] = [];
	level.missionCallbacks[callback][level.missionCallbacks[callback].size] = func;
}


getChallengeStatus( name )
{
	if ( isDefined( self.challengeData[name] ) )
		return self.challengeData[name];
	else
		return 0;
}


isStrStart( string1, subStr )
{
	return ( getSubStr( string1, 0, subStr.size ) == subStr );
}


ch_assists( data )
{
	player = data.player;
	player processChallenge( "ch_assists" );
}


ch_hardpoints( data )
{
	player = data.player;
	player.pers[data.hardpointType]++;

	switch ( data.hardpointType )
	{
		case "uav":
			player processChallenge( "ch_uav" );
			player processChallenge( "ch_uavs" );
			
			if ( player.pers["uav"] >= 3 )
				player processChallenge( "ch_nosecrets" );

			break;

		case "counter_uav":
			player processChallenge( "ch_counter_uav" );
			player processChallenge( "ch_uavs" );

			if ( player.pers["counter_uav"] >= 3 )
				player processChallenge( "ch_sunblock" );
			break;

		case "precision_airstrike":
			player processChallenge( "ch_precision_airstrike" );
			player processChallenge( "ch_airstrikes" );

			if ( player.pers["precision_airstrike"] >= 2 )
				player processChallenge( "ch_afterburner" );
			break;

		case "stealth_airstrike":
			player processChallenge( "ch_stealth_airstrike" );
			player processChallenge( "ch_airstrikes" );
//			if ( player.pers["stealth_airstrike"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "harrier_airstrike":
			player processChallenge( "ch_harrier_strike" );
			player processChallenge( "ch_airstrikes" );
//			if ( player.pers["harrier_airstrike"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "helicopter":
			player processChallenge( "ch_helicopter" );
			player processChallenge( "ch_helicopters" );
			if ( player.pers["helicopter"] >= 2 )
				player processChallenge( "ch_airsuperiority" );
			break;

		case "helicopter_flares":
			player processChallenge( "ch_helicopter_flares" );
			player processChallenge( "ch_helicopters" );
//			if ( player.pers["helicopter_flares"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "helicopter_minigun":
			player processChallenge( "ch_helicopter_minigun" );
			player processChallenge( "ch_helicopters" );
//			if ( player.pers["helicopter_minigun"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "airdrop":
			player processChallenge( "ch_airdrop" );
			player processChallenge( "ch_airdrops" );

//			if ( player.pers["airdrop"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "airdrop_sentry_minigun":
			player processChallenge( "ch_sentry" );
			player processChallenge( "ch_airdrops" );
			
//			if ( player.pers["airdrop"] >= 2 )
//				player processChallenge( "ch_???" );
			break;
			
		case "airdrop_mega":
			player processChallenge( "ch_airdrop_mega" );
			player processChallenge( "ch_airdrops", 4 );

//			if ( player.pers["airdrop_mega"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "ac130":
			player processChallenge( "ch_ac130" );

//			if ( player.pers["airdrop_mega"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "emp":
			player processChallenge( "ch_emp" );

//			if ( player.pers["emp"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "predator_missile":
			player processChallenge( "ch_predator_missile" );

//			if ( player.pers["emp"] >= 2 )
//				player processChallenge( "ch_???" );
			break;

		case "nuke":
			player processChallenge( "ch_nuke" );

			if ( level.teamBased && maps\mp\gametypes\_gamescore::getWinningTeam() == level.otherTeam[player.team] )
				player processChallenge( "ch_wopr" );

			break;
	}
}


ch_vehicle_kills( data )
{
	if ( !isDefined( data.attacker ) || !isPlayer( data.attacker ) )
		return;

	if ( !isKillstreakWeapon( data.sWeapon ) )
		return;
		
	player = data.attacker;

	if ( !isDefined( player.pers[data.sWeapon + "_streak"] ) )
		player.pers[data.sWeapon + "_streak"] = 0;

	player.pers[data.sWeapon + "_streak"]++;

	switch ( data.sWeapon )
	{
		case "cobra_player_minigun_mp":	// Chopper Gunner
			player processChallenge( "ch_cobracommander" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_hidef" );
			break;

		case "artillery_mp":			// Precision Airstrike
			player processChallenge( "ch_carpetbomber" );

			if ( player.pers[data.sWeapon + "_streak"] >= 5 )
				player processChallenge( "ch_carpetbomb" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_finishingtouch" );
			break;

		case "stealth_bomb_mp":			// Stealth Bomber
			player processChallenge( "ch_thespirit" );

			if ( player.pers[data.sWeapon + "_streak"] >= 6 )
				player processChallenge( "ch_redcarpet" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_technokiller" );
			break;

		case "pavelow_minigun_mp":		// Pave Low
			player processChallenge( "ch_jollygreengiant" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_transformer" );
			break;

		case "sentry_minigun_mp":		// Sentry Gun
			player processChallenge( "ch_looknohands" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_absentee" );
			break;

		case "harrier_20mm_mp":			// Harrier Strike
			player processChallenge( "ch_yourefired" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_truelies" );
			break;

		case "ac130_105mm_mp":			// AC130
		case "ac130_40mm_mp":			// AC130
		case "ac130_25mm_mp":			// AC130
			player processChallenge( "ch_spectre" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_deathfromabove" );
			break;

		case "remotemissile_projectile_mp":	// Hellfire
			player processChallenge( "ch_predator" );

			if ( player.pers[data.sWeapon + "_streak"] >= 4 )
				player processChallenge( "ch_reaper" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_dronekiller" );
			break;

		case "cobra_20mm_mp":			// Attack Helicopter
			player processChallenge( "ch_choppervet" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_og" );
			break;

		case "nuke_mp":					// Nuke
			data.victim processChallenge( "ch_radiationsickness" );
			break;

		default:
			break;		
	}
}	


ch_vehicle_killed( data )
{
	if ( !isDefined( data.attacker ) || !isPlayer( data.attacker ) )
		return;

	player = data.attacker;
}


clearIDShortly( expId )
{
	self endon ( "disconnect" );
	
	self notify( "clearing_expID_" + expID );
	self endon ( "clearing_expID_" + expID );
	
	wait ( 3.0 );
	self.explosiveKills[expId] = undefined;
}

MGKill()
{
	player = self;
	if ( !isDefined( player.pers["MGStreak"] ) )
	{
		player.pers["MGStreak"] = 0;
		player thread endMGStreakWhenLeaveMG();
		if ( !isDefined( player.pers["MGStreak"] ) )
			return;
	}
	player.pers["MGStreak"]++;
	//iprintln( player.pers["MGStreak"] );
	if ( player.pers["MGStreak"] >= 5 )
		player processChallenge( "ch_mgmaster" );
}

endMGStreakWhenLeaveMG()
{
	self endon("disconnect");
	while(1)
	{
		if ( !isAlive( self ) || self useButtonPressed() )
		{
			self.pers["MGStreak"] = undefined;
			//iprintln("0");
			break;
		}
		wait .05;
	}
}

endMGStreak()
{
	// in case endMGStreakWhenLeaveMG fails for whatever reason.
	self.pers["MGStreak"] = undefined;
	//iprintln("0");
}

killedBestEnemyPlayer( wasBest )
{
	if ( !isdefined( self.pers["countermvp_streak"] ) || !wasBest )
		self.pers["countermvp_streak"] = 0;
	
	self.pers["countermvp_streak"]++;
	
	if ( self.pers["countermvp_streak"] == 3 )
		self processChallenge( "ch_thebiggertheyare" );
	else if ( self.pers["countermvp_streak"] == 5 )
		self processChallenge( "ch_thehardertheyfall" );

	if ( self.pers["countermvp_streak"] >= 10 )
		self processChallenge( "ch_countermvp" );
}


isHighestScoringPlayer( player )
{
	if ( !isDefined( player.score ) || player.score < 1 )
		return false;

	players = level.players;
	if ( level.teamBased )
		team = player.pers["team"];
	else
		team = "all";

	highScore = player.score;

	for( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i].score ) )
			continue;
			
		if ( players[i].score < 1 )
			continue;

		if ( team != "all" && players[i].pers["team"] != team )
			continue;
		
		if ( players[i].score > highScore )
			return false;
	}
	
	return true;
}


ch_kills( data, time )
{
	data.victim playerDied();
	
	if ( !isDefined( data.attacker ) || !isPlayer( data.attacker ) )
		return;
	
	player = data.attacker;
	
	time = data.time;
	
	if ( player.pers["cur_kill_streak"] == 10 )
		player processChallenge( "ch_fearless" );

	if ( level.teamBased )
	{
		if ( level.teamCount[data.victim.pers["team"]] > 3 && player.killedPlayers.size >= level.teamCount[data.victim.pers["team"]] )
		{
			player processChallenge( "ch_tangodown" );
			
			maps\mp\_awards::addAwardWinner( "killedotherteam", player.clientid );
		}
	
		if ( level.teamCount[data.victim.pers["team"]] > 3 && player.killedPlayersCurrent.size >= level.teamCount[data.victim.pers["team"]] )
		{
			player processChallenge( "ch_extremecruelty" );
		
			maps\mp\_awards::addAwardWinner( "killedotherteamonelife", player.clientid );
		}
	}

	if ( isDefined( player.killedPlayers[data.victim.guid] ) && player.killedPlayers[data.victim.guid] == 5 )
		player processChallenge( "ch_rival" );

	if ( isdefined( player.tookWeaponFrom[ data.sWeapon ] ) )
	{
		if ( player.tookWeaponFrom[ data.sWeapon ] == data.victim && data.sMeansOfDeath != "MOD_MELEE" )
			player processChallenge( "ch_cruelty" );
	}

	oneLeftCount = 0;

	secondaryCount = 0;
	longshotCount = 0;
	killsLast10s = 1;
	
	killedPlayers[data.victim.name] = data.victim.name;
	usedWeapons[data.sWeapon] = data.sWeapon;
	uniqueKills = 1;
	killstreakKills = [];
	
	foreach ( killData in player.killsThisLife )
	{
		if ( isCACSecondaryWeapon( killData.sWeapon ) && killData.sMeansOfDeath != "MOD_MELEE" )
			secondaryCount++;
		
		if ( isDefined( killData.modifiers["longshot"] ) )
			longshotCount++;

		if ( time - killData.time < 10000 )
			killsLast10s++;		

		if ( isKillstreakWeapon( killData.sWeapon ) )
		{
			if ( !isDefined( killstreakKills[ killData.sWeapon ] ) )
				killstreakKills[ killData.sWeapon ] = 0;

			killstreakKills[ killData.sWeapon ]++;
		}
		else
		{
			if ( isDefined( level.oneLeftTime[player.team] ) && killData.time > level.oneLeftTime[player.team] )
				oneLeftCount++;

			if ( isDefined( killData.victim ) )
			{
				if ( !isDefined( killedPlayers[killData.victim.name] ) && !isDefined( usedWeapons[killData.sWeapon] ) && !isKillStreakWeapon( killData.sWeapon ) )
					uniqueKills++;
		
				killedPlayers[killData.victim.name] = killData.victim.name;
			}
			
			usedWeapons[killData.sWeapon] = killData.sWeapon;
		}
	}

	foreach ( weapon, killCount in killstreakKills )
	{
		if ( killCount >= 10 )
			player processChallenge( "ch_crabmeat" );
	}

	if ( uniqueKills == 3 )
		player processChallenge( "ch_renaissance" );

	if ( killsLast10s > 3 && level.teamCount[data.victim.team] <= killsLast10s )
		player processChallenge( "ch_omnicide" );

	if ( isCACSecondaryWeapon( data.sWeapon ) && secondaryCount == 2 )
		player processChallenge( "ch_sidekick" );

	if ( isDefined( data.modifiers["longshot"] ) && longshotCount == 2 )
		player processChallenge( "ch_nbk" );
	
	if ( isDefined( level.oneLeftTime[player.team] ) && oneLeftCount == 2 )
		player processChallenge( "ch_enemyofthestate" );

	if ( data.victim.score > 0 )
	{
		if ( level.teambased )
		{
			victimteam = data.victim.pers["team"];
			if ( isdefined( victimteam ) && victimteam != player.pers["team"] )
			{
				if ( isHighestScoringPlayer( data.victim ) && level.players.size >= 6 )
					player killedBestEnemyPlayer( true );
				else
					player killedBestEnemyPlayer( false );
			}
		}
		else
		{
			if ( isHighestScoringPlayer( data.victim ) && level.players.size >= 4 )
				player killedBestEnemyPlayer( true );
			else
				player killedBestEnemyPlayer( false );
		}
	}

	if ( isDefined( data.modifiers["avenger"] ) )
		player processChallenge( "ch_avenger" );
	
	if ( isDefined( data.modifiers["buzzkill"] ) && data.modifiers["buzzkill"] >= 9 )
		player processChallenge( "ch_thedenier" );

	// Filter out killstreak weapons	
	if ( isKillstreakWeapon( data.sWeapon ) )
		return;

	if ( isDefined( data.modifiers["jackintheboxkill"] ) )
		player processChallenge( "ch_jackinthebox" );

	if ( isDefined( data.modifiers["clonekill"] ) )
		player processChallenge( "ch_identitytheft" );

	if ( isDefined( data.modifiers["cooking"] ) )
		player processChallenge( "ch_no" );

	if ( isDefined( player.finalKill ) )
	{
		player processChallenge( "ch_theedge" );

		if ( isDefined( data.modifiers["revenge"] ) )
			player processChallenge( "ch_moneyshot" );
		
		if ( isDefined(player.inLastStand) && player.inLastStand )
		{
			player processChallenge( "ch_lastresort" );			
		}
	}

	if ( player isAtBrinkOfDeath() )
	{
		player.brinkOfDeathKillStreak++;
		if ( player.brinkOfDeathKillStreak >= 3 )
		{
			player processChallenge( "ch_thebrink" );
		}
	}
	
	if ( data.sMeansOfDeath == "MOD_PISTOL_BULLET" || data.sMeansOfDeath == "MOD_RIFLE_BULLET" )
	{

		weaponClass = getWeaponClass( data.sWeapon );
		ch_bulletDamageCommon( data, player, time, weaponClass );
	
		if ( isMG( data.sWeapon ) )
		{
			player MGKill();
		}
		else
		{
			baseWeapon = getBaseWeaponName( data.sWeapon );
			
			if ( isDefined( level.challengeInfo["ch_marksman_" + baseWeapon] ) )
				player processChallenge( "ch_marksman_" + baseWeapon );

			if ( isDefined( level.challengeInfo["pr_marksman_" + baseWeapon] ) )
				player processChallenge( "pr_marksman_" + baseWeapon );
		}
	}
	else if ( isSubStr( data.sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( data.sMeansOfDeath, "MOD_EXPLOSIVE" ) || isSubStr( data.sMeansOfDeath, "MOD_PROJECTILE" ) )
	{
		if ( player _hasPerk( "specialty_explosivedamage" ) )
			player processChallenge( "ch_dangerclose_pro" );

		if ( isStrStart( data.sWeapon, "frag_grenade_short" ) && ( !isDefined( data.victim.explosiveInfo["throwbackKill"] ) || !data.victim.explosiveInfo["throwbackKill"] ) )
			player processChallenge( "ch_martyr" );

		// this isdefined check should not be needed... find out where these mystery explosions are coming from
		if ( isDefined( data.victim.explosiveInfo["damageTime"] ) && data.victim.explosiveInfo["damageTime"] == time )
		{
			if ( data.sWeapon == "none" )
				data.sWeapon = data.victim.explosiveInfo["weapon"];
			
			expId = time + "_" + data.victim.explosiveInfo["damageId"];
			if ( !isDefined( player.explosiveKills[expId] ) )
			{
				player.explosiveKills[expId] = 0;
			}
			player thread clearIDShortly( expId );
			
			player.explosiveKills[expId]++;
			
			baseWeapon = getBaseWeaponName( data.sWeapon );
			
			if ( baseWeapon == "javelin" || baseWeapon == "m79" || baseWeapon == "at4" || baseWeapon == "rpg" )
			{
				if ( player.explosiveKills[expId] > 1 )
				{
					player processChallenge( "pr_expert_" + baseWeapon );
				}
			}	
			
			if ( baseWeapon == "gl" )
			{
				weaponAttachments = getWeaponAttachments( data.sweapon );
				player processChallenge( "ch_" + weaponAttachments[0] + "_gl" );

				if ( isDefined( level.challengeInfo["ch_marksman_" + weaponAttachments[0]] ) )
					player processChallenge( "ch_marksman_" + weaponAttachments[0] );
				
				if ( player _hasPerk( "specialty_bling" ) )
				{
					baseWeaponAttachments = getWeaponAttachments( data.sprimaryweapon );		
					if ( baseWeaponAttachments.size == 2 && IsSubStr( data.sprimaryweapon, weaponAttachments[0] ) )
						player processChallenge( "ch_bling_pro" );
				}
				
				if ( isDefined( level.challengeInfo["pr_marksman_" + weaponAttachments[0]] ) )
					player processChallenge( "pr_marksman_" + weaponAttachments[0] );
			}
			
			if ( isDefined( data.victim.explosiveInfo["stickKill"] ) && data.victim.explosiveInfo["stickKill"] )
			{
				if ( isDefined( data.modifiers["revenge"] ) ) 
					player processChallenge( "ch_overdraft" );				

				if ( isDefined( player.finalKill ) )
					player processChallenge( "ch_stickman" );

				if ( player.explosiveKills[expId] > 1 )
					player processChallenge( "ch_grouphug" );
			}

			if ( isDefined( data.victim.explosiveInfo["stickFriendlyKill"] ) && data.victim.explosiveInfo["stickFriendlyKill"] )
			{
				player processChallenge( "ch_resourceful" );
			}
			
			if ( !isSubStr( baseWeapon, "stinger" ) )
			{
				if ( isDefined( level.challengeInfo["ch_marksman_" + baseWeapon] ) )
					player processChallenge( "ch_marksman_" + baseWeapon );
	
				if ( isDefined( level.challengeInfo["pr_marksman_" + baseWeapon] ) )
					player processChallenge( "pr_marksman_" + baseWeapon );
			}
			
			if ( isStrStart( data.sWeapon, "frag_" ) )
			{
				if ( player.explosiveKills[expId] > 1 )
					player processChallenge( "ch_multifrag" );
	
				if ( isDefined( data.modifiers["revenge"] ) ) 
					player processChallenge( "ch_bangforbuck" );				
				
				player processChallenge( "ch_grenadekill" );
				
				if ( data.victim.explosiveInfo["cookedKill"] )
					player processChallenge( "ch_masterchef" );
				
				if ( data.victim.explosiveInfo["suicideGrenadeKill"] )
					player processChallenge( "ch_miserylovescompany" );
				
				if ( data.victim.explosiveInfo["throwbackKill"] )
					player processChallenge( "ch_hotpotato" );
			}
			else if ( isStrStart( data.sWeapon, "semtex_" ) )
			{
				if ( isDefined( data.modifiers["revenge"] ) ) 
					player processChallenge( "ch_timeismoney" );				
			}
			else if ( isStrStart( data.sWeapon, "c4_" ) )
			{
				if ( isDefined( data.modifiers["revenge"] ) ) 
					player processChallenge( "ch_iamrich" );				

				if ( player.explosiveKills[expId] > 1 )
					player processChallenge( "ch_multic4" );

				if ( data.victim.explosiveInfo["returnToSender"] )
					player processChallenge( "ch_returntosender" );				
				
				if ( data.victim.explosiveInfo["counterKill"] )
					player processChallenge( "ch_counterc4" );
				
				if ( data.victim.explosiveInfo["bulletPenetrationKill"] )
					player processChallenge( "ch_howthe" );

				if ( data.victim.explosiveInfo["chainKill"] )
					player processChallenge( "ch_dominos" );

				player processChallenge( "ch_c4shot" );
				
				if ( isDefined(player.inLastStand) && player.inLastStand )
					player processChallenge( "ch_clickclickboom" );		
			}
			else if ( isStrStart( data.sWeapon, "claymore_" ) )
			{
				if ( isDefined( data.modifiers["revenge"] ) ) 
					player processChallenge( "ch_breakbank" );				

				player processChallenge( "ch_claymoreshot" );

				if ( player.explosiveKills[expId] > 1 )
					player processChallenge( "ch_multiclaymore" );

				if ( data.victim.explosiveInfo["returnToSender"] )
					player processChallenge( "ch_returntosender" );				

				if ( data.victim.explosiveInfo["counterKill"] )
					player processChallenge( "ch_counterclaymore" );
				
				if ( data.victim.explosiveInfo["bulletPenetrationKill"] )
					player processChallenge( "ch_howthe" );

				if ( data.victim.explosiveInfo["chainKill"] )
					player processChallenge( "ch_dominos" );
			}
			else if ( data.sWeapon == "explodable_barrel" )
			{
				//player processChallenge( "ch_redbarrelsurprise" );
			}
			else if ( data.sWeapon == "destructible_car" )
			{
				player processChallenge( "ch_carbomb" );
			}
			else if ( isStrStart( data.sWeapon, "rpg_" ) )
			{
				if ( player.explosiveKills[expId] > 1 )
					player processChallenge( "ch_multirpg" );
			}
		}
	}
	else if ( isSubStr( data.sMeansOfDeath,	"MOD_MELEE" ) && !isSubStr( data.sweapon, "riotshield_mp" ) )
	{
		player endMGStreak();
		
		player processChallenge( "ch_knifevet" );
		player.pers["meleeKillStreak"]++;

		if ( player.pers["meleeKillStreak"] == 3 )
			player processChallenge( "ch_slasher" );
		
		if ( player _hasPerk( "specialty_extendedmelee" ) )
			player processChallenge( "ch_extendedmelee_pro" );
		
		if ( player _hasPerk( "specialty_heartbreaker" ) )
				player processChallenge( "ch_deadsilence_pro" );
		
		vAngles = data.victim.anglesOnDeath[1];
		pAngles = player.anglesOnKill[1];
		angleDiff = AngleClamp180( vAngles - pAngles );
		if ( abs(angleDiff) < 30 )
		{
			player processChallenge( "ch_backstabber" );
			
			if ( isDefined( player.attackers ) )
			{
				foreach ( attacker in player.attackers )
				{
					if ( attacker != data.victim )
						continue;
						
					player processChallenge( "ch_neverforget" );
					break;
				}
			}
		}

		if ( !player playerHasAmmo() )
			player processChallenge( "ch_survivor" );
			
		if ( isDefined( player.infected ) )
			data.victim processChallenge( "ch_infected" );

		if ( isDefined( data.victim.plague ) )
			player processChallenge( "ch_plague" );
		
		baseWeapon = getBaseWeaponName( data.sWeapon );
		weaponAttachments = getWeaponAttachments( data.sweapon );
		
		if ( isDefined( weaponAttachments[0] ) && weaponAttachments[0] == "tactical" )
		{
			if ( isDefined( level.challengeInfo["ch_marksman_" + baseWeapon] ) )
				player processChallenge( "ch_marksman_" + baseWeapon );
		}
	}
	else if ( isSubStr( data.sMeansOfDeath,	"MOD_MELEE" ) && isSubStr( data.sweapon, "riotshield_mp" ) )
	{
		player endMGStreak();
		
		player processChallenge( "ch_shieldvet" );
		player.pers["shieldKillStreak"]++;

		if ( player.pers["shieldKillStreak"] == 3 )
			player processChallenge( "ch_smasher" );

		if ( isDefined( player.finalKill ) )
			player processChallenge( "ch_owned" );
		
		if ( player _hasPerk( "specialty_extendedmelee" ) )
			player processChallenge( "ch_extendedmelee_pro" );
		
		vAngles = data.victim.anglesOnDeath[1];
		pAngles = player.anglesOnKill[1];
		angleDiff = AngleClamp180( vAngles - pAngles );
		if ( abs(angleDiff) < 30 )
			player processChallenge( "ch_backsmasher" );	

		if ( !player playerHasAmmo() )
			player processChallenge( "ch_survivor" );
	}
	else if ( isSubStr( data.sMeansOfDeath,	"MOD_IMPACT" ) )
	{
		if ( isStrStart( data.sWeapon, "frag_" ) )
			player processChallenge( "ch_thinkfast" );
		else if ( isStrStart( data.sWeapon, "concussion_" ) )
			player processChallenge( "ch_thinkfastconcussion" );
		else if ( isStrStart( data.sWeapon, "flash_" ) )
			player processChallenge( "ch_thinkfastflash" );
		else if ( isStrStart( data.sWeapon, "gl_" ) )
			player processChallenge( "ch_ouch" );

		if ( data.sWeapon == "throwingknife_mp" )
		{
			if ( isDefined( data.modifiers["revenge"] ) )
				player processChallenge( "ch_atm" );			

			if ( time < player.flashEndTime )
				player processChallenge( "ch_didyouseethat" );

			if ( isDefined( player.finalKill ) )
				player processChallenge( "ch_unbelievable" );
				
			player processChallenge( "ch_carnie" );
			
			if ( isDefined( data.victim.attackerData[player.guid].isPrimary ) )
				player processChallenge( "ch_its_personal" );
		}
		
		baseWeapon = getBaseWeaponName( data.sWeapon );
	
		if ( baseWeapon == "gl" )
		{
			weaponAttachments = getWeaponAttachments( data.sweapon );
			
			if ( isDefined( level.challengeInfo["ch_" + weaponAttachments[0] + "_" + "gl"] ) )
				player processChallenge( "ch_" + weaponAttachments[0] + "_" + "gl" );

			if ( isDefined( level.challengeInfo["ch_marksman_" + weaponAttachments[0]] ) )
				player processChallenge( "ch_marksman_" + weaponAttachments[0] );

			if ( isDefined( level.challengeInfo["pr_marksman_" + weaponAttachments[0]] ) )
				player processChallenge( "pr_marksman_" + weaponAttachments[0] );
		}
	}
	else if ( data.sMeansOfDeath == "MOD_HEAD_SHOT" )
	{
		weaponClass = getWeaponClass( data.sWeapon );
		
		ch_bulletDamageCommon( data, player, time, weaponClass );
	
		switch ( weaponClass )
		{
			case "weapon_smg":
				player processChallenge( "ch_expert_smg" );
				break;
			case "weapon_lmg":
				player processChallenge( "ch_expert_lmg" );
				break;
			case "weapon_assault":
				player processChallenge( "ch_expert_assault" );
				break;
		}

		if ( isDefined( data.modifiers["revenge"] ) )
			player processChallenge( "ch_colorofmoney" );

		if ( isMG( data.sWeapon ) )
		{
			player MGKill();
		}
		else if ( isStrStart( data.sWeapon, "frag_" ) )
		{
			player processChallenge( "ch_thinkfast" );
		}
		else if ( isStrStart( data.sWeapon, "concussion_" ) )
		{
			player processChallenge( "ch_thinkfastconcussion" );
		}
		else if ( isStrStart( data.sWeapon, "flash_" ) )
		{
			player processChallenge( "ch_thinkfastflash" );
		}
		else
		{
			baseWeapon = getBaseWeaponName( data.sWeapon );
			
			if ( isDefined( level.challengeInfo["ch_expert_" + baseWeapon] ) )
				player processChallenge( "ch_expert_" + baseWeapon );

			if ( isDefined( level.challengeInfo["pr_expert_" + baseWeapon] ) )
				player processChallenge( "pr_expert_" + baseWeapon );

			if ( isDefined( level.challengeInfo["ch_marksman_" + baseWeapon] ) )
				player processChallenge( "ch_marksman_" + baseWeapon );

			if ( isDefined( level.challengeInfo["pr_marksman_" + baseWeapon] ) )
				player processChallenge( "pr_marksman_" + baseWeapon );
		}
	}
	
	
	if ( data.sMeansOfDeath == "MOD_PISTOL_BULLET" || data.sMeansOfDeath == "MOD_RIFLE_BULLET" || data.sMeansOfDeath == "MOD_HEAD_SHOT" && !isKillstreakWeapon( data.sweapon ) )
	{
		// checks and processes all weapon attachment challenges
		weaponAttachments = getWeaponAttachments( data.sweapon );
		baseWeapon = getBaseWeaponName( data.sWeapon );
		
		foreach( weaponAttachment in weaponAttachments )
		{
			switch ( weaponAttachment )
			{
				case "heartbeat":
					player processChallenge( "ch_" + baseWeapon + "_" + weaponAttachment );
					continue;
				case "silencer":
					player processChallenge( "ch_" + baseWeapon + "_" + weaponAttachment );
					continue;
				case "reflex":
					if ( player playerAds() )
						player processChallenge( "ch_" + baseWeapon + "_" + weaponAttachment );
					continue;
				case "acog":
					if ( player playerAds() )
						player processChallenge( "ch_" + baseWeapon + "_" + weaponAttachment );
					continue;
				case "rof":
					player processChallenge( "ch_" + baseWeapon + "_" + weaponAttachment );
					continue;
				case "fmj":
					if ( data.victim.iDFlags & level.iDFLAGS_PENETRATION )	
						player processChallenge( "ch_" + baseWeapon + "_" + weaponAttachment );
					continue;
				default:
					continue;					
			}
		}
		
		if ( player _hasPerk( "specialty_bulletaccuracy" ) && !player playerAds() )
			player processChallenge( "ch_bulletaccuracy_pro" );
		
		if ( distanceSquared( player.origin, data.victim.origin )< 65536 )// 256^2 
		{
			if ( player _hasPerk( "specialty_heartbreaker" ) )
				player processChallenge( "ch_deadsilence_pro" );
			
			if ( player _hasPerk( "specialty_localjammer" ) )
				player processChallenge( "ch_scrambler_pro" );	
		}
		
		if ( player _hasPerk( "specialty_fastreload" ) )
			player processChallenge( "ch_sleightofhand_pro" );
		
		if ( player _hasPerk( "specialty_bling" ) && weaponAttachments.size == 2 )
			player processChallenge( "ch_bling_pro" );
		
		if ( player _hasPerk( "specialty_bulletdamage" ) )
			player processChallenge( "ch_stoppingpower_pro" );
			
		if ( player _hasPerk( "specialty_pistoldeath" ) && isDefined(player.inLastStand) && player.inLastStand && !level.dieHardMode
		&& ( !isDefined(player.inFinalStand) || !player.inFinalStand ) && ( !isDefined(player.inC4Death) || !player.inC4Death ) )
		{
			if ( isDefined( data.modifiers["revenge"] ) )
				player processChallenge( "ch_robinhood" );
				
			player processChallenge( "ch_laststand_pro" );
		}		
	}
	
	if ( player _hasperk( "specialty_onemanarmy" ) || isDefined( player.OMAClassChanged ) && player.OMAClassChanged )
		player processChallenge( "ch_onemanarmy_pro" );
	
	if ( isDefined( data.victim.isPlanting ) && data.victim.isPlanting )
		player processChallenge( "ch_bombplanter" );		

	if ( isDefined( data.victim.isDefusing ) && data.victim.isDefusing )
		player processChallenge( "ch_bombdefender" );

	if ( isDefined( data.victim.isBombCarrier ) && data.victim.isBombCarrier && ( !isDefined( level.dd ) || !level.dd ) )
		player processChallenge( "ch_bombdown" );

	if ( isDefined( data.victim.wasTI ) && data.victim.wasTI )
		player processChallenge( "ch_tacticaldeletion" );
}

ch_bulletDamageCommon( data, player, time, weaponClass )
{
	if ( !isMG( data.sWeapon ) )
		player endMGStreak();
		
	if ( isKillstreakWeapon( data.sweapon ) )
		return;
	
	if ( player.pers["lastBulletKillTime"] == time )
		player.pers["bulletStreak"]++;
	else
		player.pers["bulletStreak"] = 1;
	
	player.pers["lastBulletKillTime"] = time;

	if ( !data.victimOnGround )
		player processChallenge( "ch_hardlanding" );
	
	assert( data.attacker == player );
	if ( !data.attackerOnGround )
		player.pers["midairStreak"]++;
	
	if ( player.pers["midairStreak"] == 2 )
		player processChallenge( "ch_airborne" );
	
	if ( time < data.victim.flashEndTime )
		player processChallenge( "ch_flashbangvet" );
	
	if ( time < player.flashEndTime )
		player processChallenge( "ch_blindfire" );
	
	if ( time < data.victim.concussionEndTime )
		player processChallenge( "ch_concussionvet" );
	
	if ( time < player.concussionEndTime )
		player processChallenge( "ch_slowbutsure" );
	
	
	if ( player.pers["bulletStreak"] == 2  )
	{
		if ( isDefined( data.modifiers["headshot"] ) )
		{
			foreach ( killData in player.killsThisLife )
			{
				if ( killData.time != time )
					continue;
					
				if ( !isDefined( data.modifiers["headshot"] ) )
					continue;
					
				player processChallenge( "ch_allpro" );
			}
		}

		if ( weaponClass == "weapon_sniper" )
			player processChallenge( "ch_collateraldamage" );
	}
	
	if ( weaponClass == "weapon_pistol" )
	{
		if ( isdefined( data.victim.attackerData ) && isdefined( data.victim.attackerData[player.guid] ) )
		{
			if ( isDefined ( data.victim.attackerData[player.guid].isPrimary ) )
				player processChallenge( "ch_fastswap" );
		}
	}
	else if ( weaponClass == "weapon_shotgun" )
	{
		if ( isSubStr( data.sWeapon, "ranger" ) && isDefined( player.bothBarrels ) )
		{
			player processChallenge( "ch_bothbarrels" );
			player.bothBarrels = undefined;
		}
	}
	
	if ( data.victim.iDFlagsTime == time )
	{
		if ( data.victim.iDFlags & level.iDFLAGS_PENETRATION )
			player processChallenge( "ch_xrayvision" ); 
	}
	
	if ( data.attackerInLastStand && !data.attacker _hasPerk( "specialty_finalstand" ) )
	{
		player processChallenge( "ch_laststandvet" );
	}
	else if ( data.attackerStance == "crouch" )
	{
		player processChallenge( "ch_crouchshot" );
	}
	else if ( data.attackerStance == "prone" )
	{
		player processChallenge( "ch_proneshot" );
		if ( weaponClass == "weapon_sniper" )
		{
			player processChallenge( "ch_invisible" );
		}
	}
	
	if ( weaponClass == "weapon_sniper" )
	{
		if ( isDefined( data.modifiers["oneshotkill"] ) )
			player processChallenge( "ch_ghillie" );	
	}
	
	if ( isSubStr( data.sWeapon, "_silencer_" ) )
		player processChallenge( "ch_stealth" ); 
}

ch_roundplayed( data )
{
	player = data.player;
	
	if ( player.wasAliveAtMatchStart )
	{
		deaths = player.pers[ "deaths" ];
		kills = player.pers[ "kills" ];

		kdratio = 1000000;
		if ( deaths > 0 )
			kdratio = kills / deaths;
		
		if ( kdratio >= 5.0 && kills >= 5.0 )
		{
			player processChallenge( "ch_starplayer" );
		}
		
		if ( deaths == 0 && getTimePassed() > 5 * 60 * 1000 )
			player processChallenge( "ch_flawless" );
		
		
		if ( player.score > 0 )
		{
			switch ( level.gameType )
			{
				case "dm":
					if ( data.place < 3 && level.placement["all"].size > 3 )
						player processChallenge( "ch_victor_dm" );
					break;
			}
		}
	}
}


ch_roundwin( data )
{
	if ( !data.winner )
		return;
		
	player = data.player;
	if ( player.wasAliveAtMatchStart )
	{
		switch ( level.gameType )
		{
			case "war":
				if ( level.hardcoreMode )
				{
					player processChallenge( "ch_teamplayer_hc" );
					if ( data.place == 0 )
						player processChallenge( "ch_mvp_thc" );
				}
				else
				{
					player processChallenge( "ch_teamplayer" );
					if ( data.place == 0 )
						player processChallenge( "ch_mvp_tdm" );
				}
				break;
			case "sab":
				player processChallenge( "ch_victor_sab" );
				break;
			case "sd":
				player processChallenge( "ch_victor_sd" );
				break;
			case "ctf":
			case "dom":
			case "dm":
			case "hc":
			case "koth":
				break;
			default:
				break;
		}
	}
}

/*
char *modNames[MOD_NUM] =
{
	"MOD_UNKNOWN",
	"MOD_PISTOL_BULLET",
	"MOD_RIFLE_BULLET",
	"MOD_GRENADE",
	"MOD_GRENADE_SPLASH",
	"MOD_PROJECTILE",
	"MOD_PROJECTILE_SPLASH",
	"MOD_MELEE",
	"MOD_HEAD_SHOT",
	"MOD_CRUSH",
	"MOD_TELEFRAG",
	"MOD_FALLING",
	"MOD_SUICIDE",
	"MOD_TRIGGER_HURT",
	"MOD_EXPLOSIVE",
	"MOD_IMPACT",
};

static const char *g_HitLocNames[] =
{
	"none",
	"helmet",
	"head",
	"neck",
	"torso_upper",
	"torso_lower",
	"right_arm_upper",
	"left_arm_upper",
	"right_arm_lower",
	"left_arm_lower",
	"right_hand",
	"left_hand",
	"right_leg_upper",
	"left_leg_upper",
	"right_leg_lower",
	"left_leg_lower",
	"right_foot",
	"left_foot",
	"gun",
};

*/

// ==========================================
// Callback functions

playerDamaged( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc )
{
	self endon("disconnect");
	if ( isdefined( attacker ) )
		attacker endon("disconnect");
	
	wait .05;
	WaitTillSlowProcessAllowed();

	data = spawnstruct();

	data.victim = self;
	data.eInflictor = eInflictor;
	data.attacker = attacker;
	data.iDamage = iDamage;
	data.sMeansOfDeath = sMeansOfDeath;
	data.sWeapon = sWeapon;
	data.sHitLoc = sHitLoc;
	
	data.victimOnGround = data.victim isOnGround();
	
	if ( isPlayer( attacker ) )
	{
		data.attackerInLastStand = isDefined( data.attacker.lastStand );
		data.attackerOnGround = data.attacker isOnGround();
		data.attackerStance = data.attacker getStance();
	}
	else
	{
		data.attackerInLastStand = false;
		data.attackerOnGround = false;
		data.attackerStance = "stand";
	}
	
	doMissionCallback("playerDamaged", data);
}

playerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sPrimaryWeapon, sHitLoc, modifiers )
{
	self.anglesOnDeath = self getPlayerAngles();
	if ( isdefined( attacker ) )
		attacker.anglesOnKill = attacker getPlayerAngles();
	
	self endon("disconnect");

	data = spawnstruct();

	data.victim = self;
	data.eInflictor = eInflictor;
	data.attacker = attacker;
	data.iDamage = iDamage;
	data.sMeansOfDeath = sMeansOfDeath;
	data.sWeapon = sWeapon;
	data.sPrimaryWeapon = sPrimaryWeapon;
	data.sHitLoc = sHitLoc;
	data.time = gettime();
	data.modifiers = modifiers;
	
	data.victimOnGround = data.victim isOnGround();
	
	if ( isPlayer( attacker ) )
	{
		data.attackerInLastStand = isDefined( data.attacker.lastStand );
		data.attackerOnGround = data.attacker isOnGround();
		data.attackerStance = data.attacker getStance();
	}
	else
	{
		data.attackerInLastStand = false;
		data.attackerOnGround = false;
		data.attackerStance = "stand";
	}

	waitAndProcessPlayerKilledCallback( data );	
	
	if ( isDefined( attacker ) && isReallyAlive( attacker ) )
		attacker.killsThisLife[attacker.killsThisLife.size] = data;	

	data.attacker notify( "playerKilledChallengesProcessed" );
}


vehicleKilled( owner, vehicle, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon )
{
	data = spawnstruct();

	data.vehicle = vehicle;
	data.victim = owner;
	data.eInflictor = eInflictor;
	data.attacker = attacker;
	data.iDamage = iDamage;
	data.sMeansOfDeath = sMeansOfDeath;
	data.sWeapon = sWeapon;
	data.time = gettime();
	
}


waitAndProcessPlayerKilledCallback( data )
{
	if ( isdefined( data.attacker ) )
		data.attacker endon("disconnect");
	
	self.processingKilledChallenges = true;
	wait 0.05;
	WaitTillSlowProcessAllowed();
	
	doMissionCallback( "playerKilled", data );
	self.processingKilledChallenges = undefined;
}

playerAssist()
{
	data = spawnstruct();

	data.player = self;

	doMissionCallback( "playerAssist", data );
}


useHardpoint( hardpointType )
{
	wait .05;
	WaitTillSlowProcessAllowed();

	data = spawnstruct();

	data.player = self;
	data.hardpointType = hardpointType;

	doMissionCallback( "playerHardpoint", data );
}


roundBegin()
{
	doMissionCallback( "roundBegin" );
}

roundEnd( winner )
{
	data = spawnstruct();
	
	if ( level.teamBased )
	{
		team = "allies";
		for ( index = 0; index < level.placement[team].size; index++ )
		{
			data.player = level.placement[team][index];
			data.winner = (team == winner);
			data.place = index;

			doMissionCallback( "roundEnd", data );
		}
		team = "axis";
		for ( index = 0; index < level.placement[team].size; index++ )
		{
			data.player = level.placement[team][index];
			data.winner = (team == winner);
			data.place = index;

			doMissionCallback( "roundEnd", data );
		}
	}
	else
	{
		for ( index = 0; index < level.placement["all"].size; index++ )
		{
			data.player = level.placement["all"][index];
			data.winner = (isdefined( winner) && (data.player == winner));
			data.place = index;

			doMissionCallback( "roundEnd", data );
		}		
	}
}

doMissionCallback( callback, data )
{
	if ( !mayProcessChallenges() )
		return;
	
	if ( getDvarInt( "disable_challenges" ) > 0 )
		return;
	
	if ( !isDefined( level.missionCallbacks[callback] ) )
		return;
	
	if ( isDefined( data ) ) 
	{
		for ( i = 0; i < level.missionCallbacks[callback].size; i++ )
			thread [[level.missionCallbacks[callback][i]]]( data );
	}
	else 
	{
		for ( i = 0; i < level.missionCallbacks[callback].size; i++ )
			thread [[level.missionCallbacks[callback][i]]]();
	}
}

monitorSprintDistance()
{
	level endon( "game_ended" );
	self endon( "spawned_player" );
	self endon( "death" );
	self endon( "disconnect" );
	
	while(1)
	{
		self waittill("sprint_begin");
		
		self.sprintDistThisSprint = 0;
		self thread monitorSprintTime();
		self monitorSingleSprintDistance();
		
		if ( self _hasperk( "specialty_marathon" ) )
			self processChallenge( "ch_marathon_pro", int( self.sprintDistThisSprint/12) );
		
		if ( self _hasperk( "specialty_lightweight" ) )
			self processChallenge( "ch_lightweight_pro", int(self.sprintDistThisSprint/12) );
	}
}

monitorSingleSprintDistance()
{
	level endon( "game_ended" );
	self endon( "spawned_player" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "sprint_end" );
	
	prevpos = self.origin;
	while(1)
	{
		wait .1;

		self.sprintDistThisSprint += distance( self.origin, prevpos );
		prevpos = self.origin;
	}
}

monitorSprintTime()
{
	level endon( "game_ended" );
	self endon( "spawned_player" );
	self endon( "death" );
	self endon( "disconnect" );

	startTime = getTime();
	
	self waittill( "sprint_end" );
	
	sprintTime = int( getTime() - startTime );
	self incPlayerStat( "sprinttime", sprintTime );
	
	//total = self getPlayerStat( "sprinttime" );
	//println( "SprintTime: ", sprintTime, " Total:", total );
}	

monitorFallDistance()
{
	self endon("disconnect");

	self.pers["midairStreak"] = 0;
	
	while(1)
	{
		if ( !isAlive( self ) )
		{
			self waittill("spawned_player");
			continue;
		}
		
		if ( !self isOnGround() )
		{
			self.pers["midairStreak"] = 0;
			highestPoint = self.origin[2];
			while( !self isOnGround() && isAlive( self ) )
			{
				if ( self.origin[2] > highestPoint )
					highestPoint = self.origin[2];
				wait .05;
			}
			self.pers["midairStreak"] = 0;

			falldist = highestPoint - self.origin[2];
			if ( falldist < 0 )
				falldist = 0;
			
			if ( falldist / 12.0 > 15 && isAlive( self ) )
				self processChallenge( "ch_basejump" );

			if ( falldist / 12.0 > 30 && !isAlive( self ) )
				self processChallenge( "ch_goodbye" );
			
			//println( "You fell ", falldist / 12.0, " feet");
		}
		wait .05;
	}
}


// TODO: Make this challenge happen after winning while being the last person on your team
lastManSD()
{
	if ( !mayProcessChallenges() )
		return;

	if ( !self.wasAliveAtMatchStart )
		return;
	
	if ( self.teamkillsThisRound > 0 )
		return;
	
	self processChallenge( "ch_lastmanstanding" );
}


monitorBombUse()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		result = self waittill_any_return( "bomb_planted", "bomb_defused" );
		
		if ( !isDefined( result ) )
			continue;
			
		if ( result == "bomb_planted" )
		{
			self processChallenge( "ch_saboteur" );
		}
		else if ( result == "bomb_defused" )
			self processChallenge( "ch_hero" );
	}
}


monitorLiveTime()
{
	for ( ;; )
	{
		self waittill ( "spawned_player" );
		
		self thread survivalistChallenge();
	}
}

survivalistChallenge()
{
	self endon("death");
	self endon("disconnect");
	
	wait 5 * 60;
	
	self processChallenge( "ch_survivalist" );
}


monitorStreaks()
{
	self endon ( "disconnect" );

	self.pers["airstrikeStreak"] = 0;
	self.pers["meleeKillStreak"] = 0;
	self.pers["shieldKillStreak"] = 0;

	self thread monitorMisc();

	for ( ;; )
	{
		self waittill ( "death" );
		
		self.pers["airstrikeStreak"] = 0;
		self.pers["meleeKillStreak"] = 0;
		self.pers["shieldKillStreak"] = 0;
	}
}


monitorMisc()
{
	self thread monitorMiscSingle( "destroyed_explosive" );
	self thread monitorMiscSingle( "begin_airstrike" );
	self thread monitorMiscSingle( "destroyed_car" );
	self thread monitorMiscSingle( "destroyed_helicopter" );
	self thread monitorMiscSingle( "used_uav" );
	self thread monitorMiscSingle( "used_counter_uav" );
	self thread monitorMiscSingle( "used_airdrop" );
	self thread monitorMiscSingle( "used_emp" );
	self thread monitorMiscSingle( "used_nuke" );
	self thread monitorMiscSingle( "crushed_enemy" );
	
	self waittill("disconnect");
	
	// make sure the threads end when we disconnect.
	// (this allows one disconnect waittill instead of 4 disconnect endons)
	self notify( "destroyed_explosive" );
	self notify( "begin_airstrike" );
	self notify( "destroyed_car" );
	self notify( "destroyed_helicopter" );
}

monitorMiscSingle( waittillString )
{
	// don't need to endon disconnect because we will get the notify we're waiting for when we disconnect.
	// avoiding the endon disconnect saves a lot of script variables (5 * 4 threads * 64 players = 1280)
	
	while(1)
	{
		self waittill( waittillString );
		
		if ( !isDefined( self ) )
			return;
		
		monitorMiscCallback( waittillString );
	}
}

monitorMiscCallback( result )
{
	assert( isDefined( result ) );
	switch( result )
	{
		case "begin_airstrike":
			self.pers["airstrikeStreak"] = 0;
		break;

		case "destroyed_explosive":		
			if ( self _hasPerk( "specialty_detectexplosive" ) )
				self processChallenge( "ch_detectexplosives_pro" );

			self processChallenge( "ch_backdraft" );
		break;

		case "destroyed_helicopter":
			self processChallenge( "ch_flyswatter" );
		break;

		case "destroyed_car":
			self processChallenge( "ch_vandalism" );
		break;
		
		case "crushed_enemy":
			self processChallenge( "ch_heads_up" );

			if ( isDefined( self.finalKill ) )
				self processChallenge( "ch_droppincrates" );
		break;
	}
}


healthRegenerated()
{
	if ( !isalive( self ) )
		return;
	
	if ( !mayProcessChallenges() )
		return;
	
	if ( !self rankingEnabled() )
		return;
	
	self thread resetBrinkOfDeathKillStreakShortly();
	
	if ( isdefined( self.lastDamageWasFromEnemy ) && self.lastDamageWasFromEnemy )
	{
		// TODO: this isn't always getting incremented when i regen
		self.healthRegenerationStreak++;
		if ( self.healthRegenerationStreak >= 5 )
		{
			self processChallenge( "ch_invincible" );
		}
	}
}

resetBrinkOfDeathKillStreakShortly()
{
	self endon("disconnect");
	self endon("death");
	self endon("damage");
	
	wait 1;
	
	self.brinkOfDeathKillStreak = 0;
}

playerSpawned()
{
	self.brinkOfDeathKillStreak = 0;
	self.healthRegenerationStreak = 0;
	self.pers["MGStreak"] = 0;
}

playerDied()
{
	self.brinkOfDeathKillStreak = 0;
	self.healthRegenerationStreak = 0;
	self.pers["MGStreak"] = 0;
}

isAtBrinkOfDeath()
{
	ratio = self.health / self.maxHealth;
	return (ratio <= level.healthOverlayCutoff);
}


processChallenge( baseName, progressInc, forceSetProgress )
{
	if ( !mayProcessChallenges() )
		return;
	
	if ( level.players.size < 2 )
		return;
	
	if ( !self rankingEnabled() )
		return;
	
	if ( !isDefined( progressInc ) )
		progressInc = 1;	
	
	/#
	if ( getDvarInt( "debug_challenges" ) )
		println( "CHALLENGE PROGRESS - " + baseName + ": " + progressInc );
	#/
	
	missionStatus = getChallengeStatus( baseName );
	
	if ( missionStatus == 0 )
		return;
	
	// challenge already completed
	if ( missionStatus > level.challengeInfo[baseName]["targetval"].size )
		return;

	if ( isDefined( forceSetProgress ) && forceSetProgress )
	{
		progress = progressInc;
	}
	else
	{
		progress = ch_getProgress( baseName );
		progress += progressInc;
	}

	// we've completed this tier	
	if ( progress >= level.challengeInfo[baseName]["targetval"][missionStatus] )
	{
		self ch_setProgress( baseName, level.challengeInfo[baseName]["targetval"][missionStatus] );
		self thread giveRankXpAfterWait( baseName, missionStatus );
		
		missionStatus++;		
		self ch_setState( baseName, missionStatus );
		self.challengeData[baseName] = missionStatus;
		
		self thread maps\mp\gametypes\_hud_message::challengeSplashNotify( baseName );

		self thread masteryChallengeProcess( baseName, missionStatus );
	}
	else
	{
		self ch_setProgress( baseName, progress );		
	}	
}

giveRankXpAfterWait( baseName,missionStatus )
{
	self endon ( "disconnect" );

	wait( 0.25 );
	self maps\mp\gametypes\_rank::giveRankXP( "challenge", level.challengeInfo[baseName]["reward"][missionStatus] );
}


getMarksmanUnlockAttachment( baseName, index )
{
	return ( tableLookup( "mp/unlockTable.csv", 0, baseName, 4 + index ) );
}


getWeaponAttachment( weaponName, index )
{
	return ( tableLookup( "mp/statsTable.csv", 4, weaponName, 11 + index ) );
}


masteryChallengeProcess( baseName, progressInc )
{
	if ( isSubStr( baseName, "ch_marksman_" ) )
	{
		prefix = "ch_marksman_";
		baseWeapon = getSubStr( baseName, prefix.size, baseName.size );
	}
	else
	{
		tokens = strTok( baseName, "_" );
		
		if ( tokens.size != 3 )
			return;

		baseWeapon = tokens[1];
	}
	
	if ( tableLookup( "mp/allChallengesTable.csv", 0 , "ch_" + baseWeapon + "_mastery", 1 ) == "" )
		return;

	progress = 0;	
	for ( index = 0; index <= 10; index++ )
	{
		attachmentName = getWeaponAttachment( baseWeapon, index );
		
		if ( attachmentName == "" )
			continue;
			
		if ( self isItemUnlocked( baseWeapon + " " + attachmentName ) )
			progress++;
	}
			
	processChallenge( "ch_" + baseWeapon + "_mastery", progress, true );
}


updateChallenges()
{
	self.challengeData = [];
	
	if ( !mayProcessChallenges() )
		return;

	if ( !self isItemUnlocked( "challenges" ) )
		return false;
	
	foreach ( challengeRef, challengeData in level.challengeInfo )
	{
		self.challengeData[challengeRef] = 0;
		
		if ( !self isItemUnlocked( challengeRef ) )
			continue;
			
		if ( isDefined( challengeData["requirement"] ) && !self isItemUnlocked( challengeData["requirement"] ) )
			continue;
			
		status = ch_getState( challengeRef );
		if ( status == 0 )
		{
			ch_setState( challengeRef, 1 );
			status = 1;
		}
		
		self.challengeData[challengeRef] = status;
	}
}

/*
	challenge_targetVal and rewardVal should cast their return values to int
*/
challenge_targetVal( refString, tierId )
{
	value = tableLookup( "mp/allChallengesTable.csv", CH_REF_COL, refString, CH_TARGET_COL + ((tierId-1)*2) );
	return int( value );
}


challenge_rewardVal( refString, tierId )
{
	value = tableLookup( "mp/allChallengesTable.csv", CH_REF_COL, refString, CH_REWARD_COL + ((tierId-1)*2) );
	return int( value );
}


buildChallegeInfo()
{
	level.challengeInfo = [];

	tableName = "mp/allchallengesTable.csv";

	totalRewardXP = 0;

	refString = tableLookupByRow( tableName, 0, CH_REF_COL );
	assertEx( isSubStr( refString, "ch_" ) || isSubStr( refString, "pr_" ), "Invalid challenge name: " + refString + " found in " + tableName );
	for ( index = 1; refString != ""; index++ )
	{
		assertEx( isSubStr( refString, "ch_" ) || isSubStr( refString, "pr_" ), "Invalid challenge name: " + refString + " found in " + tableName );

		level.challengeInfo[refString] = [];
		level.challengeInfo[refString]["targetval"] = [];
		level.challengeInfo[refString]["reward"] = [];

		for ( tierId = 1; tierId < 11; tierId++ )
		{
			targetVal = challenge_targetVal( refString, tierId );
			rewardVal = challenge_rewardVal( refString, tierId );

			if ( targetVal == 0 )
				break;

			level.challengeInfo[refString]["targetval"][tierId] = targetVal;
			level.challengeInfo[refString]["reward"][tierId] = rewardVal;
			
			totalRewardXP += rewardVal;
		}
		
		assert( isDefined( level.challengeInfo[refString]["targetval"][1] ) );

		refString = tableLookupByRow( tableName, index, CH_REF_COL );
	}

	tierTable = tableLookupByRow( "mp/challengeTable.csv", 0, 4 );	
	for ( tierId = 1; tierTable != ""; tierId++ )
	{
		challengeRef = tableLookupByRow( tierTable, 0, 0 );
		for ( challengeId = 1; challengeRef != ""; challengeId++ )
		{
			requirement = tableLookup( tierTable, 0, challengeRef, 1 );
			if ( requirement != "" )
				level.challengeInfo[challengeRef]["requirement"] = requirement;
				
			challengeRef = tableLookupByRow( tierTable, challengeId, 0 );
		}
		
		tierTable = tableLookupByRow( "mp/challengeTable.csv", tierId, 4 );	
	}
	
	/#
	printLn( "TOTAL CHALLENGE REWARD XP: " + totalRewardXP );
	#/
}

/#
verifyMarksmanChallenges()
{
}

verifyExpertChallenges()
{
}
#/

/#
completeAllChallenges( percentage )
{
	foreach ( challengeRef, challengeData in level.challengeInfo )
	{
		finalTarget = 0;
		finalTier = 0;
		for ( tierId = 1; isDefined( challengeData["targetval"][tierId] ); tierId++ )
		{
			finalTarget = challengeData["targetval"][tierId];
			finalTier = tierId + 1;
		}
		
		if ( percentage != 1.0 )
		{
			finalTarget--;
			finalTier--;
		}

		if ( self isItemUnlocked( challengeRef ) || percentage == 1.0 )
		{		
			self setPlayerData( "challengeProgress", challengeRef, finalTarget );
			self setPlayerData( "challengeState", challengeRef, finalTier );
		}
		
		wait ( 0.05 );
	}
	
	println( "Done unlocking challenges" );
}
#/

monitorProcessChallenge()
{
	self endon( "disconnect" );
	level endon( "game_end" );
	
	for( ;; )
	{
		if( !mayProcessChallenges() )
			return;
			
		self waittill( "process", challengeName );
		self processChallenge( challengeName );
	}	
}

monitorKillstreakProgress()
{
	self endon( "disconnect" );
	level endon( "game_end" );
	
	for( ;; )
	{
		self waittill ( "got_killstreak", streakCount );
		
		//for scr_givkillstreak
		if( !isDefined( streakCount ) )
			continue;
		
		if ( streakCount == 10 && self.killstreaks.size == 0 )
			self processChallenge( "ch_theloner" );		
		else if ( streakCount == 9 )
		{
			if ( isDefined( self.killstreaks[7] ) && isDefined( self.killstreaks[8] ) && isDefined( self.killstreaks[9] ) )
			{
				self processChallenge( "ch_6fears7" );
			}
		}
	}
}


monitorKilledKillstreak()
{
	self endon( "disconnect" );
	level endon( "game_end" );
	
	for( ;; )
	{
		self waittill( "destroyed_killstreak", weapon );
		
		if ( self _hasPerk( "specialty_coldblooded" ) )
			self processChallenge( "ch_coldblooded_pro" );

		if ( isDefined( weapon ) && weapon == "stinger_mp" )
		{
			self processChallenge( "ch_marksman_stinger" );		
			self processChallenge( "pr_marksman_stinger" );		
		}
	}	
}


genericChallenge( challengeType, value )
{
	switch ( challengeType )
	{
		case "hijacker_airdrop":
			self processChallenge( "ch_smoothcriminal" );
			break;
		case "hijacker_airdrop_mega":
			self processChallenge( "ch_poolshark" );
			break;
		case "wargasm":
			self processChallenge( "ch_wargasm" );
			break;
		case "weapon_assault":
			self processChallenge( "ch_surgical_assault" );
			break;
		case "weapon_smg":
			self processChallenge( "ch_surgical_smg" );
			break;
		case "weapon_lmg":
			self processChallenge( "ch_surgical_lmg" );
			break;
		case "weapon_sniper":
			self processChallenge( "ch_surgical_sniper" );
			break;
		case "shield_damage":
			self processChallenge( "ch_shield_damage", value );
			break;
		case "shield_bullet_hits":
			self processChallenge( "ch_shield_bullet", value );
			break;
		case "shield_explosive_hits":
			self processChallenge( "ch_shield_explosive", value );
			break;
	}	
}

playerHasAmmo()
{
	primaryWeapons = self getWeaponsListPrimaries();	

	foreach ( primary in primaryWeapons )
	{
		if ( self GetWeaponAmmoClip( primary ) )
			return true;
			
		altWeapon = weaponAltWeaponName( primary );

		if ( !isDefined( altWeapon ) || (altWeapon == "none") )
			continue;

		if ( self GetWeaponAmmoClip( altWeapon ) )
			return true;
	}
	
	return false;
}