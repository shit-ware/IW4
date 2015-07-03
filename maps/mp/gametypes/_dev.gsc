#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	/#
	setDevDvarIfUninitialized("scr_showspawns", "0");

	precacheItem("defaultweapon_mp");
	precacheModel("test_sphere_silver");

	thread addTestClients();

	setDevDvarIfUninitialized( "scr_testclients", "0" );
	
	setDevDvar( "scr_list_weapons", "" );
	setDevDvar( "scr_givekillstreak", "" );
	setDevDvar( "scr_giveradar", "0" );
	setDevDvar( "scr_useGambit", "" );
	setDevDvar( "scr_useAirDrop", "");
	setDevDvar( "scr_giveairstrike", "0" );
	setDevDvar( "scr_givehelicopter", "0" );
	setDevDvar( "scr_giveac130", "0" );
	setDevDvar( "scr_giveairdrop", "0" );
	setDevDvar( "scr_giveremotemissile", "0" );

	setDevDvar( "scr_predatorme", "" );
	setDevDvar( "scr_setdefcon", "" );
	setDevDvar( "scr_showcard", "" );
	setDevDvar( "scr_showoutcome", "" );

	setDevDvar( "scr_enemykillhost", "" );

	setDevDvar( "scr_giveperk", "" );
	setDevDvar( "scr_takeperk", "" );
	
	setDevDvar( "scr_sre", "" );
	setDevDvar( "scr_testmigration", "" );
	
	setDevDvar( "scr_show_splash", "" );
	setDevDvar( "scr_spam_splashes", "" );
	
	setDevDvar( "scr_show_endgameupdate", "" );

	level.baseWeaponList = maps\mp\gametypes\_weapons::buildWeaponData( true );	

	setDevDvarIfUninitialized( "debug_reflection", "0" );

	level thread onPlayerConnect();	
	
	for(;;)
	{
		updateDevSettings();
		wait .05;
	}
	#/
}


/#
updateDevSettings()
{
	showspawns = getdvarInt("scr_showspawns");
	if(showspawns > 1)
		showspawns = 1;
	else if(showspawns < 0)
		showspawns = 0;
	
	if(!isdefined(level.showspawns) || level.showspawns != showspawns)
	{
		level.showspawns = showspawns;
		setDevDvar("scr_showspawns", level.showspawns);

		if(level.showspawns)
			showSpawnpoints();
		else
			hideSpawnpoints();
	}
	
	updateMinimapSetting();
	
	if ( getDvar( "scr_test_weapon" ) != "" )
	{
		foreach ( player in level.players )
		{
			player thread initForWeaponTests();
			player setTestWeapon( getDvar( "scr_test_weapon" ) );
		}

		setDevDvar( "scr_test_weapon", "" );
	}

	if ( getDvar( "scr_dump_ranks" ) != "" )
	{

		setDevDvar( "scr_dump_ranks", "" );

		for ( rId = 0; rId <= level.maxRank; rId++ )
		{
			rankName = tableLookupIString( "mp/rankTable.csv", 0, rId, 5 );
			iprintln( "REFERENCE           UNLOCKED_AT_LV" + (rId+1) );
			iprintln( "LANG_ENGLISH        Unlocked at ", rankName, " (Lv" + (rId+1) + ")" );
			
			wait ( 0.05 );
		}		
	}
	
	if ( getDvar( "scr_list_weapons" ) != "" )
	{
		foreach ( baseWeapon, _ in level.baseWeaponList )
			iPrintLn( baseWeapon );

		setDevDvar( "scr_list_weapons", "" );
	}

	if ( getdvarint("scr_predatorme") == 1 )
	{
		foreach ( player in level.players )
			level thread maps\mp\killstreaks\_remotemissile::_fire_noplayer( 0, player );

		setDevDvar( "scr_predatorme", "" );
	}

	if ( getdvarfloat("scr_complete_all_challenges") != 0 )
	{
		foreach ( player in level.players )
		{
			player thread maps\mp\gametypes\_missions::completeAllChallenges( getdvarfloat("scr_complete_all_challenges") );
		}

		setDevDvar( "scr_complete_all_challenges", "" );
	}

	if ( getdvarint("scr_giveradar") == 1 )
	{
		foreach ( player in level.players )
			player maps\mp\killstreaks\_killstreaks::giveKillstreak( "uav" );

		setDevDvar( "scr_giveradar", "0" );
	}
	if ( getdvarint("scr_giveairstrike") == 1 )
	{
		foreach ( player in level.players )
			player maps\mp\killstreaks\_killstreaks::giveKillstreak( "airstrike" );

		setDevDvar( "scr_giveairstrike", "0" );
	}
	if ( getdvarint("scr_giveairdrop") == 1 )
	{
		foreach ( player in level.players )
			player maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop" );

		setDevDvar( "scr_giveairdrop", "0" );
	}
	if ( getdvarint("scr_givehelicopter") == 1 )
	{
		foreach ( player in level.players )
			player maps\mp\killstreaks\_killstreaks::giveKillstreak( "helicopter" );

		setDevDvar( "scr_givehelicopter", "0" );
	}
	if ( getdvarint("scr_giveac130") == 1 )
	{
		foreach ( player in level.players )
			player maps\mp\killstreaks\_killstreaks::giveKillstreak( "ac130" );

		setDevDvar( "scr_giveac130", "0" );
	}
	if ( getdvarint("scr_giveremotemissile") == 1 )
	{
		foreach ( player in level.players )
			player maps\mp\killstreaks\_killstreaks::giveKillstreak( "predator_missile" );

		setDevDvar( "scr_giveremotemissile", "0" );
	}
	if ( getDvarInt("scr_setdefcon") != 0 )
	{
		maps\mp\_defcon::updateDefcon( getDvarInt("scr_setdefcon") ); 
		setDevDvar( "scr_setdefcon", "" );
	}

	if ( getDvar("scr_givekillstreak") != "" )
	{
		streakName = getDvar( "scr_givekillstreak" );
		
		if ( isDefined( level.killstreakFuncs[streakName] ) )
		{
			foreach ( player in level.players )
				player maps\mp\killstreaks\_killstreaks::giveKillstreak( streakName );
		}
		else
		{
			println( "\"" + getDvar("scr_givekillstreak") + "\" is not a valid value for scr_givekillstreak. Try:" );
			foreach ( killstreak, value in level.killstreakFuncs )
			{
				println( "    " + killstreak );
			}
			println( "" );
		}
			
		setDevDvar( "scr_givekillstreak", "" );
	}

	if ( getDvar("scr_showcard") != "" )
	{
		tokens = strTok( getDvar( "scr_showcard" ), " " );

		if ( tokens.size )
		{
			playerName = tokens[0];
	
			if ( isDefined( tokens[1] ) )
				slotId = int(tokens[1]);
			else
				slotId = 0;
	
			owner = undefined;
			foreach ( player in level.players )
			{
				if ( player.name == playerName )
				{
					owner = player;	
					player SetCardDisplaySlot( player, slotId );					
					break;
				}
			}
			
			if ( !isDefined( owner ) )
				printLn( "Player " + playerName + "not found!" );				
		}

		setDevDvar( "scr_showcard", "" );
	}

	if ( getDvar("scr_usekillstreak") != "" )
	{
		tokens = strTok( getDvar( "scr_usekillstreak" ), " " );

		if ( tokens.size > 1 )
		{
			playerName = tokens[0];
			streakName = tokens[1];

			if ( !isDefined( level.killstreakFuncs[streakName] ) )
				printLn( "Killstreak " + streakName + "not found!" );
			
			owner = undefined;
			foreach ( player in level.players )
			{
				if ( player.name == playerName )
				{
					owner = player;
					
					player maps\mp\killstreaks\_killstreaks::giveKillstreak( streakName );
					
					if ( isDefined( tokens[2] ) )
						player thread maps\mp\killstreaks\_killstreaks::killstreakUsePressed();
					else
						player thread [[ level.killstreakFuncs[ streakName ] ]]();
					
					if ( isSubStr( streakName, "airstrike" ) )
					{
						wait .05;
						player notify( "confirm_location", level.mapCenter, 0 );
					}
					
					if ( isSubStr( streakName, "airdrop" ) )
					{
						wait .05;
						
						if ( streakName == "airdrop_mega" )
							level thread maps\mp\killstreaks\_airdrop::doC130FlyBy( player, level.mapCenter, randomFloat( 360 ), "airdrop_mega" );
						else
							level thread maps\mp\killstreaks\_airdrop::doFlyBy( player, level.mapCenter, randomFloat( 360 ), "airdrop" );
					}
					break;
				}
			}
			
			if ( !isDefined( owner ) )
				printLn( "Player " + playerName + "not found!" );				
		}
		setDevDvar( "scr_usekillstreak", "" );
	}

	if ( getDvar("scr_playertoorigin") != "" )
	{
		tokens = strTok( getDvar( "scr_playertoorigin" ), " " );

		newOrigin = (int(tokens[0]), int(tokens[1]), int(tokens[2]));

		playerName = tokens[3];
		foreach ( player in level.players )
		{
			if ( player.name == playerName )
			{
				player setOrigin( newOrigin );
				break;
			}
		}

		setDevDvar( "scr_playertoorigin", "" );
	}
	
	if ( getDvar("scr_useGambit") != "" )
	{
		tokens = strTok( getDvar( "scr_useGambit" ), " " );

		if ( tokens.size > 1 )
		{
			playerName = tokens[0];
			gambitName = tokens[1];

			if ( !isDefined( level.scriptPerks[gambitName] ) )
				printLn( "Gambit " + gambitName + "not found!" );
			
			owner = undefined;
			foreach ( player in level.players )
			{
				if ( player.name == playerName )
				{
					owner = player;
					player notify("gambit_on");
					break;
				}
			}
			
			if ( !isDefined( owner ) )
				printLn( "Player " + playerName + "not found!" );				
		}
		setDevDvar( "scr_useGambit", "" );
	}
	
	if ( getDvar("scr_levelnotify" ) != "" )
	{
		level notify ( getDvar( "scr_levelnotify" ) );
		setDevDvar( "scr_levelnotify", "" );
	}

	if ( getdvar("scr_giveperk") != "" )
	{
		perk = getdvar("scr_giveperk");

		for ( i = 0; i < level.players.size; i++ )
			level.players[i] thread maps\mp\perks\_perks::givePerk( perk );

		setDevDvar( "scr_giveperk", "" );
	}
	if ( getdvar("scr_takeperk") != "" )
	{
		perk = getdvar("scr_takeperk");
		for ( i = 0; i < level.players.size; i++ )
		{
			level.players[i] unsetPerk( perk, true );
			level.players[i].extraPerks[ perk ] = undefined;
		}
		setDevDvar( "scr_takeperk", "" );
	}
	
	if ( getDvar( "scr_x_kills_y" ) != "" )
	{
		nameTokens = strTok( getDvar( "scr_x_kills_y" ), " " );
		if ( nameTokens.size > 1 )
			thread xKillsY( nameTokens[0], nameTokens[1] );

		setDevDvar( "scr_x_kills_y", "" );
	}

	if ( getDvar( "scr_enemykillhost" ) != "" )
	{
		hostPlayer = undefined;
		enemyPlayer = undefined;
		foreach ( player in level.players )
		{
			if ( !player isHost() )
				continue;
				
			hostPlayer = player;
			break;
		}
		
		
		foreach ( player in level.players )
		{
			if ( level.teamBased )
			{
				if ( player.team == hostPlayer.team )
					continue;
					
				enemyPlayer = player;
				break;
			}
			else
			{
				if ( player isHost() )
					continue;
					
				enemyPlayer = player;
				break;
			}
		}
		
		if ( isDefined( enemyPlayer ) )
			thread xKillsY( enemyPlayer.name, hostPlayer.name );

		setDevDvar( "scr_enemykillhost", "" );
	}

	if ( getDvar( "scr_drop_weapon" ) != "" )
	{
		weapon = spawn( "weapon_" + getDvar( "scr_drop_weapon" ), level.players[0].origin );
		setDevDvar( "scr_drop_weapon", "" );
	}

	if ( getDvar( "scr_set_rank" ) != "" )
	{
		level.players[0].pers["rank"] = 0;
		level.players[0].pers["rankxp"] = 0;
		
		newRank = min( getDvarInt( "scr_set_rank" ), 54 );
		newRank = max( newRank, 1 );

		setDevDvar( "scr_set_rank", "" );

		if ( level.teamBased && (!level.teamCount["allies"] || !level.teamCount["axis"]) )
			println( "scr_set_rank may not work because there are not players on both teams" );
		else if ( !level.teamBased && (level.teamCount["allies"] + level.teamCount["axis"] < 2) )
			println( "scr_set_rank may not work because there are not at least two players" );
		
		level.players[0] setPlayerData( "restXPGoal", 0 );
		
		lastXp = 0;
		for ( index = 0; index <= newRank; index++ )		
		{
			newXp = maps\mp\gametypes\_rank::getRankInfoMinXP( index );
			level.players[0] thread maps\mp\gametypes\_rank::giveRankXP( "kill", newXp - lastXp );
			lastXp = newXp;
			wait ( 0.25 );
			self notify ( "cancel_notify" );
		}
	}

	if ( getDvar( "scr_givexp" ) != "" )
	{
		level.players[0] thread maps\mp\gametypes\_rank::giveRankXP( "challenge", getDvarInt( "scr_givexp" ) );
		
		setDevDvar( "scr_givexp", "" );
	}

	if ( getDvar( "scr_do_notify" ) != "" )
	{
		for ( i = 0; i < level.players.size; i++ )
			level.players[i] maps\mp\gametypes\_hud_message::oldNotifyMessage( getDvar( "scr_do_notify" ), getDvar( "scr_do_notify" ), game["icons"]["allies"] );
		
		announcement( getDvar( "scr_do_notify" ) );
		setDevDvar( "scr_do_notify", "" );
	}	

	if ( getDvar( "scr_spam_splashes" ) != "" )
	{
		foreach( player in level.players )
		{
			player thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "longshot" );
			player thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "headshot" );
			player thread maps\mp\gametypes\_rank::updateRankAnnounceHUD();
			player thread maps\mp\gametypes\_hud_message::challengeSplashNotify( "ch_marksman_m16" );
			player thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "execution" );
			player thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "uav", 3 );
			player thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "ac130", 11 );
			player thread maps\mp\gametypes\_rank::updateRankAnnounceHUD();
		}
		
		setDevDvar( "scr_spam_splashes", "" );	
	}

	if ( getDvar( "scr_show_splash" ) != "" )
	{
		splashName = getDvar( "scr_show_splash" );
		splashValue = 1;
		splashType = tableLookup( "mp/splashTable.csv", 0, splashName, 11 );
		
		if ( splashType == "" || splashType == "none" )
		{
			println( "splash not found in splash table" );
		}
		else
		{
			switch( splashType )
			{
				case "splash":
					foreach( player in level.players )
						player thread maps\mp\gametypes\_hud_message::splashNotify( splashName, splashValue );
					break;
				case "killstreak":
					foreach( player in level.players )
						player thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( splashName, splashValue );
					break;
				case "challenge":
				case "perk_challenge":
					foreach( player in level.players )
						player thread maps\mp\gametypes\_hud_message::challengeSplashNotify( splashName );
					break;
				case "splooge":
					foreach( player in level.players )
					{
						player thread maps\mp\gametypes\_hud_message::challengeSplashNotify( "ch_marksman_m16" );
						player thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "uav", 3 );
						player thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "ac130", 11 );
					}
					break;
				default:
					break;
			}
		}
		setDevDvar( "scr_show_splash", "" );
	}	

	if ( getDvar( "scr_addlower" ) != "" )
	{
		foreach ( player in level.players )
			player thread testLowerMessage();
		
		setDevDvar( "scr_addlower", "" );
	}	

	if ( getDvar( "scr_entdebug" ) != "" )
	{
		ents = getEntArray();
		level.entArray = [];
		level.entCounts = [];
		level.entGroups = [];
		for ( index = 0; index < ents.size; index++ )
		{
			classname = ents[index].classname;
			if ( !isSubStr( classname, "_spawn" ) )
			{
				curEnt = ents[index];

				level.entArray[level.entArray.size] = curEnt;
				
				if ( !isDefined( level.entCounts[classname] ) )
					level.entCounts[classname] = 0;
			
				level.entCounts[classname]++;

				if ( !isDefined( level.entGroups[classname] ) )
					level.entGroups[classname] = [];
			
				level.entGroups[classname][level.entGroups[classname].size] = curEnt;
			}
		}
	}
	
	if ( getDvar( "scr_sre" ) != "" )
	{
		assertmsg( "Testing script runtime error" );
		setDevDvar( "scr_sre", "" );
	}
	
	if ( getDvar( "scr_testmigration" ) != "" )
	{
		setDevDvar( "scr_testmigration", "" );
		thread maps\mp\gametypes\_hostmigration::Callback_HostMigration();
		thread hostMigrationEndTimer_dev();
	}
	
	if ( getDvar( "scr_show_endgameupdate" ) != "" )
	{
		promotion = ( getDvar( "scr_show_endgameupdate" ) == "2" );
		
		foreach( player in level.players )
			player thread testEndGameUpdate( promotion );
		
		setDevDvar( "scr_show_endgameupdate", "" );	
	}
}

testEndGameUpdate( promotion )
{
	self setClientDvars( "ui_challenge_1_ref", "ch_marksman_ak47",
						 "ui_challenge_2_ref", "ch_ak47_gl",
						 "ui_challenge_3_ref", "ch_ak47_reflex",
						 "ui_challenge_4_ref", "ch_ak47_silencer",
						 "ui_challenge_5_ref", "ch_ak47_acog",
						 "ui_challenge_6_ref", "ch_ak47_fmj",
						 "ui_challenge_7_ref", "ch_ak47_mastery" );

	if ( isDefined( promotion ) && promotion )
		self setClientDvar( "ui_promotion", 1 );
	else
		self setClientDvar( "ui_promotion", 0 );
	
	self closepopupMenu();
	self closeInGameMenu();
	
	self openMenu( game["menu_endgameupdate"] );

	waitTime = 4.0 + min( 7, 3 );
	while ( waitTime )
	{
		wait ( 0.25 );
		waitTime -= 0.25;

		self openMenu( game["menu_endgameupdate"] );
	}
	
	self closeMenu( game["menu_endgameupdate"] );
}

hostMigrationEndTimer_dev()
{
	level endon( "host_migration_begin" );
	wait randomfloat( 20 );
	level notify( "hostmigration_enoughplayers" );
}


testLowerMessage()
{
	self setLowerMessage( "spawn_info", game["strings"]["waiting_to_spawn"], 10 );
	wait ( 3.0 );

	self setLowerMessage( "last_stand", &"PLATFORM_COWARDS_WAY_OUT", undefined, 50 );
	wait ( 3.0 );

	self clearLowerMessage( "last_stand" );
	wait ( 10.0 );

	self clearLowerMessage( "spawn_info" );
}


giveExtraPerks()
{
	if ( !isdefined( self.extraPerks ) )
		return;
	
	perks = getArrayKeys( self.extraPerks );
	
	for ( i = 0; i < perks.size; i++ )
		self setPerk( perks[i], true );
}

xKillsY( attackerName, victimName )
{
	attacker = undefined;
	victim = undefined;
	
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( level.players[index].name == attackerName )
			attacker = level.players[index];
		else if ( level.players[index].name == victimName )
			victim = level.players[index];
	}
	
	if ( !isAlive( attacker ) || !isAlive( victim ) )
		return;
		
	victim thread [[level.callbackPlayerDamage]](
		attacker, // eInflictor The entity that causes the damage.(e.g. a turret)
		attacker, // eAttacker The entity that is attacking.
		500, // iDamage Integer specifying the amount of damage done
		0, // iDFlags Integer specifying flags that are to be applied to the damage
		"MOD_RIFLE_BULLET", // sMeansOfDeath Integer specifying the method of death
		"scar_mp", // sWeapon The weapon number of the weapon used to inflict the damage
		(0,0,0), // vPoint The point the damage is from?
		(0,0,0), // vDir The direction of the damage
		"none", // sHitLoc The location of the hit
		0 // psOffsetTime The time offset for the damage
	);
}


updateMinimapSetting()
{	
	// use 0 for no required map aspect ratio.
	requiredMapAspectRatio = getdvarfloat("scr_requiredMapAspectRatio", 1);
	
	if (!isdefined(level.minimapheight)) {
		setDevDvar("scr_minimap_height", "0");
		level.minimapheight = 0;
	}
	minimapheight = getdvarfloat("scr_minimap_height");
	if (minimapheight != level.minimapheight)
	{
		if (isdefined(level.minimaporigin)) {
			level.minimapplayer unlink();
			level.minimaporigin delete();
			level notify("end_draw_map_bounds");
		}
		
		if (minimapheight > 0)
		{
			level.minimapheight = minimapheight;
			
			players = getentarray("player", "classname");
			if (players.size > 0)
			{
				player = players[0];
				
				corners = getentarray("minimap_corner", "targetname");
				if (corners.size == 2)
				{
					viewpos = (corners[0].origin + corners[1].origin);
					viewpos = (viewpos[0]*.5, viewpos[1]*.5, viewpos[2]*.5);

					maxcorner = (corners[0].origin[0], corners[0].origin[1], viewpos[2]);
					mincorner = (corners[0].origin[0], corners[0].origin[1], viewpos[2]);
					if (corners[1].origin[0] > corners[0].origin[0])
						maxcorner = (corners[1].origin[0], maxcorner[1], maxcorner[2]);
					else
						mincorner = (corners[1].origin[0], mincorner[1], mincorner[2]);
					if (corners[1].origin[1] > corners[0].origin[1])
						maxcorner = (maxcorner[0], corners[1].origin[1], maxcorner[2]);
					else
						mincorner = (mincorner[0], corners[1].origin[1], mincorner[2]);
					
					viewpostocorner = maxcorner - viewpos;
					viewpos = (viewpos[0], viewpos[1], viewpos[2] + minimapheight);
					
					origin = spawn("script_origin", player.origin);
					
					northvector = (cos(getnorthyaw()), sin(getnorthyaw()), 0);
					eastvector = (northvector[1], 0 - northvector[0], 0);
					disttotop = vectordot(northvector, viewpostocorner);
					if (disttotop < 0)
						disttotop = 0 - disttotop;
					disttoside = vectordot(eastvector, viewpostocorner);
					if (disttoside < 0)
						disttoside = 0 - disttoside;
					
					// extend map bounds to meet the required aspect ratio
					if ( requiredMapAspectRatio > 0 )
					{
						mapAspectRatio = disttoside / disttotop;
						if ( mapAspectRatio < requiredMapAspectRatio )
						{
							incr = requiredMapAspectRatio / mapAspectRatio;
							disttoside *= incr;
							addvec = vecscale( eastvector, vectordot( eastvector, maxcorner - viewpos ) * (incr - 1) );
							mincorner -= addvec;
							maxcorner += addvec;
						}
						else
						{
							incr = mapAspectRatio / requiredMapAspectRatio;
							disttotop *= incr;
							addvec = vecscale( northvector, vectordot( northvector, maxcorner - viewpos ) * (incr - 1) );
							mincorner -= addvec;
							maxcorner += addvec;
						}
					}
					
					if ( level.console )
					{
						aspectratioguess = 16.0/9.0;
						// .8 would be .75 but it needs to be bigger because of safe area
						angleside = 2 * atan(disttoside * .8 / minimapheight);
						angletop = 2 * atan(disttotop * aspectratioguess * .8 / minimapheight);
					}
					else
					{
						aspectratioguess = 4.0/3.0;
						angleside = 2 * atan(disttoside / minimapheight);
						angletop = 2 * atan(disttotop * aspectratioguess / minimapheight);
					}
					if (angleside > angletop)
						angle = angleside;
					else
						angle = angletop;
					
					znear = minimapheight - 1000;
					if (znear < 16) znear = 16;
					if (znear > 10000) znear = 10000;
					
					player playerlinkto(origin);
					origin.origin = viewpos + (0,0,-62);
					origin.angles = (90, getnorthyaw(), 0);
					

					player TakeAllWeapons();
					player _giveWeapon( "defaultweapon_mp" );
					player setclientdvar("cg_drawgun", "0");
					player setclientdvar("cg_draw2d", "0");
					player setclientdvar("cg_drawfps", "0");
					player setclientdvar("fx_enable", "0");
					player setclientdvar("r_fog", "0");
					player setclientdvar("r_highLodDist", "0"); // (turns of lods)
					player setclientdvar("r_znear", znear); // (reduces z-fighting)
					player setclientdvar("r_lodscale", "0");
					player setclientdvar("cg_drawversion", "0");
					player setclientdvar("sm_enable", "1");
					setDevDvar("player_view_pitch_down", "90");
					setDevDvar("player_view_pitch_up", "0");
					player setclientdvar("cg_fov", angle);
					player setclientdvar("cg_fovmin", "1");
					
					// hide 3D icons
					if ( isdefined( level.objPoints ) )
					{
						for ( i = 0; i < level.objPointNames.size; i++ )
						{
							if ( isdefined( level.objPoints[level.objPointNames[i]] ) )
								level.objPoints[level.objPointNames[i]] destroy();
						}
						level.objPoints = [];
						level.objPointNames = [];
					}
					
					level.minimapplayer = player;
					level.minimaporigin = origin;
					
					thread drawMiniMapBounds(viewpos, mincorner, maxcorner);
					
					wait .05;
					
					player setplayerangles(origin.angles);
				}
				else
					println("^1Error: There are not exactly 2 \"minimap_corner\" entities in the level.");
			}
			else
				setDevDvar("scr_minimap_height", "0");
		}
	}
}

vecscale(vec, scalar)
{
	return (vec[0]*scalar, vec[1]*scalar, vec[2]*scalar);
}

drawMiniMapBounds(viewpos, mincorner, maxcorner)
{
	level notify("end_draw_map_bounds");
	level endon("end_draw_map_bounds");
	
	viewheight = (viewpos[2] - maxcorner[2]);
	
	north = (cos(getnorthyaw()), sin(getnorthyaw()), 0);
	
	diaglen = length(mincorner - maxcorner);

	/*diagonal = maxcorner - mincorner;
	side = vecscale(north, vectordot(diagonal, north));
	
	origcorner0 = mincorner;
	origcorner1 = mincorner + side;
	origcorner2 = maxcorner;
	origcorner3 = maxcorner - side;*/
	
	mincorneroffset = (mincorner - viewpos);
	mincorneroffset = vectornormalize((mincorneroffset[0], mincorneroffset[1], 0));
	mincorner = mincorner + vecscale(mincorneroffset, diaglen * 1/800);
	maxcorneroffset = (maxcorner - viewpos);
	maxcorneroffset = vectornormalize((maxcorneroffset[0], maxcorneroffset[1], 0));
	maxcorner = maxcorner + vecscale(maxcorneroffset, diaglen * 1/800);
	
	diagonal = maxcorner - mincorner;
	side = vecscale(north, vectordot(diagonal, north));
	sidenorth = vecscale(north, abs(vectordot(diagonal, north)));
	
	corner0 = mincorner;
	corner1 = mincorner + side;
	corner2 = maxcorner;
	corner3 = maxcorner - side;
	
	toppos = vecscale(mincorner + maxcorner, .5) + vecscale(sidenorth, .51);
	textscale = diaglen * .003;
	
	while(1)
	{
		line(corner0, corner1, (0,1,0));
		line(corner1, corner2, (0,1,0));
		line(corner2, corner3, (0,1,0));
		line(corner3, corner0, (0,1,0));

		/*line(origcorner0, origcorner1, (1,0,0));
		line(origcorner1, origcorner2, (1,0,0));
		line(origcorner2, origcorner3, (1,0,0));
		line(origcorner3, origcorner0, (1,0,0));*/
		
		print3d(toppos, "This Side Up", (1,1,1), 1, textscale);
		
		wait .05;
	}
}

addTestClients()
{
	wait 5;

	for(;;)
	{
		if(getdvarInt("scr_testclients") > 0)
			break;
		wait 1;
	}

//	for ( index = 1; index < 24; index++ )
//		kick( index );

	testclients = getdvarInt("scr_testclients");
	setDevDvar( "scr_testclients", 0 );
	for(i = 0; i < testclients; i++)
	{
		ent[i] = addtestclient();

		if (!isdefined(ent[i])) {
			println("Could not add test client");
			wait 1;
			continue;
		}
			
		ent[i].pers["isBot"] = true;
		ent[i] thread TestClient("autoassign");
	}
	
	if ( matchMakingGame() )
		setMatchData( "hasBots", true );
	
	thread addTestClients();
}


TestClient(team)
{
	self endon( "disconnect" );

	while(!isdefined(self.pers["team"]))
		wait .05;

	self notify("menuresponse", game["menu_team"], team);
	wait 0.5;
	
	while( 1 )
	{
		//class = level.classMap[randomInt( level.classMap.size )];
		class = "class" + randomInt( 5 );
		
		self notify("menuresponse", "changeclass", class);
			
		self waittill( "spawned_player" );
		wait ( 0.10 );
	}
}

showSpawnpoint( spawnpoint, classname, color )
{
	center = spawnpoint.origin;
	forward = anglestoforward(spawnpoint.angles);
	right = anglestoright(spawnpoint.angles);

	forward = common_scripts\utility::vector_multiply(forward, 16);
	right = common_scripts\utility::vector_multiply(right, 16);

	a = center + forward - right;
	b = center + forward + right;
	c = center - forward + right;
	d = center - forward - right;
	
	thread lineUntilNotified(a, b, color, 0);
	thread lineUntilNotified(b, c, color, 0);
	thread lineUntilNotified(c, d, color, 0);
	thread lineUntilNotified(d, a, color, 0);

	thread lineUntilNotified(a, a + (0, 0, 72), color, 0);
	thread lineUntilNotified(b, b + (0, 0, 72), color, 0);
	thread lineUntilNotified(c, c + (0, 0, 72), color, 0);
	thread lineUntilNotified(d, d + (0, 0, 72), color, 0);

	a = a + (0, 0, 72);
	b = b + (0, 0, 72);
	c = c + (0, 0, 72);
	d = d + (0, 0, 72);
	
	thread lineUntilNotified(a, b, color, 0);
	thread lineUntilNotified(b, c, color, 0);
	thread lineUntilNotified(c, d, color, 0);
	thread lineUntilNotified(d, a, color, 0);

	center = center + (0, 0, 36);
	arrow_forward = anglestoforward(spawnpoint.angles);
	arrowhead_forward = anglestoforward(spawnpoint.angles);
	arrowhead_right = anglestoright(spawnpoint.angles);

	arrow_forward = common_scripts\utility::vector_multiply(arrow_forward, 32);
	arrowhead_forward = common_scripts\utility::vector_multiply(arrowhead_forward, 24);
	arrowhead_right = common_scripts\utility::vector_multiply(arrowhead_right, 8);
	
	a = center + arrow_forward;
	b = center + arrowhead_forward - arrowhead_right;
	c = center + arrowhead_forward + arrowhead_right;
	
	thread lineUntilNotified(center, a, (1, 1, 1), 0);
	thread lineUntilNotified(a, b, (1, 1, 1), 0);
	thread lineUntilNotified(a, c, (1, 1, 1), 0);
	
	foreach ( alternate in spawnpoint.alternates )
	{
		thread lineUntilNotified( spawnpoint.origin, alternate, color, 0);
	}
	
	thread print3DUntilNotified(spawnpoint.origin + (0, 0, 72), classname, color, 1, 1);
}

showSpawnpoints()
{
	if ( isdefined( level.spawnpoints ) )
	{
		foreach ( spawnpoint in level.spawnpoints )
		{
			showSpawnpoint( spawnpoint, spawnpoint.classname, (1,1,1) );
		}
	}
	if ( isdefined( level.extraspawnpointsused ) )
	{
		foreach ( spawnpoint in level.extraspawnpointsused )
		{
			showSpawnpoint( spawnpoint, spawnpoint.fakeclassname, (.5,.5,.5) );
		}
	}
}

print3DUntilNotified(origin, text, color, alpha, scale)
{
	level endon("hide_spawnpoints");
	
	for(;;)
	{
		print3d(origin, text, color, alpha, scale);
		wait .05;
	}
}

lineUntilNotified(start, end, color, depthTest)
{
	level endon("hide_spawnpoints");
	
	for(;;)
	{
		line(start, end, color, depthTest);
		wait .05;
	}
}

hideSpawnpoints()
{
	level notify("hide_spawnpoints");
}


initForWeaponTests()
{
	if ( isDefined( self.initForWeaponTests ) )
		return;
		
	self.initForWeaponTests = true;
	
	self thread changeCamoListener();
	self thread thirdPersonToggle();
	
	self waittill ( "death" );
	self.initForWeaponTests = undefined;
}


setTestWeapon( weaponName )
{
	if ( !isDefined( level.baseWeaponList[weaponName] ) )
	{
		self iPrintLnBold( "Unknown weapon: " + weaponName );
		return;
	}

	self notify ( "new_test_weapon" );	
	self.baseWeapon = weaponName;
	self thread weaponChangeListener();
	
	self updateTestWeapon();
}


thirdPersonToggle()
{
	self endon ( "death" );
	self notifyOnPlayerCommand( "dpad_down", "+actionslot 2" );
	
	thirdPersonElem = self createFontString( "default", 1.5 );
	thirdPersonElem setPoint( "TOPRIGHT", "TOPRIGHT", 0, 72 + 260 );
	thirdPersonElem setText( "3rd Person: " + getDvarInt( "camera_thirdPerson" ) + "  [{+actionslot 2}]" );
	self thread destroyOnDeath( thirdPersonElem );
	
	for ( ;; )
	{
		self waittill( "dpad_down" );

		setDvar( "camera_thirdPerson", !getDvarInt( "camera_thirdPerson" ) );
		
		thirdPersonElem setText( "3rd Person: " + getDvarInt( "camera_thirdPerson" ) + "  [{+actionslot 2}]" );
	}
}


changeCamoListener()
{
	self endon ( "death" );
	self notifyOnPlayerCommand( "dpad_up", "+actionslot 1" );
	
	camoList = [];
	
	for ( rowIndex = 0; tableLookupByRow( "mp/camoTable.csv", rowIndex, 1 ) != ""; rowIndex++ )
		camoList[camoList.size] = tableLookupByRow( "mp/camoTable.csv", rowIndex, 1 );

	self.camoIndex = 0;
	
	camoElem = self createFontString( "default", 1.5 );
	camoElem setPoint( "TOPRIGHT", "TOPRIGHT", 0, 52 + 260 );
	camoElem setText( "Camo: " + tableLookup( "mp/camoTable.csv", 0, self.camoIndex, 1 ) + "  [{+actionslot 1}]" );
	self thread destroyOnDeath( camoElem );
	
	for ( ;; )
	{
		self waittill( "dpad_up" );
		
		self.camoIndex++;
		if ( self.camoIndex > (camoList.size - 1) )
			self.camoIndex = 0;
		
		camoElem setText( "Camo: " + tableLookup( "mp/camoTable.csv", 0, self.camoIndex, 1 ) + "  [{+actionslot 1}]" );
		self updateTestWeapon();
	}
}


weaponChangeListener()
{
	self endon ( "death" );
	self endon ( "new_test_weapon" );
	
	self notifyOnPlayerCommand( "next_weapon", "weapnext" );

	if ( !isDefined( self.weaponElem ) )
	{
		self.weaponElem = self createFontString( "default", 1.5 );
		self.weaponElem setPoint( "TOPRIGHT", "TOPRIGHT", 0, 32 + 260 );
		self thread destroyOnDeath( self.weaponElem );
	}
	self.variantIndex = 0;

	self.weaponElem setText( "Weapon: " + level.baseWeaponList[self.baseWeapon].variants[self.variantIndex] + "  [{weapnext}]" );

	for ( ;; )
	{
		self waittill ( "next_weapon" );
		
		self.variantIndex++;
		if ( self.variantIndex > (level.baseWeaponList[self.baseWeapon].variants.size - 1) )
			self.variantIndex = 0;
		
		self.weaponElem setText( "Weapon: " + level.baseWeaponList[self.baseWeapon].variants[self.variantIndex] + "  [{weapnext}]" );
		self updateTestWeapon();
	}	
}


destroyOnDeath( hudElem )
{
	self waittill ( "death" );
	
	hudElem destroy();
}

updateTestWeapon()
{
	self takeAllWeapons();
	
	wait ( 0.05 );
	
	weaponName = level.baseWeaponList[self.baseWeapon].variants[self.variantIndex];
	
	self _giveWeapon( weaponName, int(self.camoIndex) );
	self switchToWeapon( weaponName );
	self giveMaxAmmo( weaponName );
}

#/

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player thread updateReflectionProbe();
	}
}

updateReflectionProbe()
{
	/#
	for(;;)
	{
		if ( getDvarInt( "debug_reflection" ) == 1 )
		{
			if ( !isDefined( self.debug_reflectionobject ) )
			{
				self.debug_reflectionobject = spawn( "script_model", self geteye() + ( vector_multiply( anglestoforward( self.angles ), 100 ) ) );
				self.debug_reflectionobject setmodel( "test_sphere_silver" );
				self.debug_reflectionobject.origin = self geteye() + ( vector_multiply( anglestoforward( self getplayerangles() ), 100 ) );
				self thread reflectionProbeButtons();
			}
		}
		else if ( getDvarInt( "debug_reflection" ) == 0 )
		{
			if ( isDefined( self.debug_reflectionobject ) )
				self.debug_reflectionobject delete();
		}

		wait( 0.05 );
	}
	#/
}

reflectionProbeButtons()
{
	/#
	offset = 100;
	offsetinc = 50;

	while ( getDvarInt( "debug_reflection" ) == 1 )
	{
		if ( self buttonpressed( "BUTTON_X" ) )
			offset += offsetinc;
		if ( self buttonpressed( "BUTTON_Y" ) )
			offset -= offsetinc;
		if ( offset > 1000 )
			offset = 1000;
		if ( offset < 64 )
			offset = 64;

		self.debug_reflectionobject.origin = self geteye() + ( vector_multiply( anglestoforward( self getplayerangles() ), offset ) );

		wait .05;
	}
	#/
}
