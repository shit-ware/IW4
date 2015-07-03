#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	/*
	level.lootColors = [];
	level.lootColors["epic"] = (0.63, 0.2, 0.7) * 1.2;
	level.lootColors["rare"] = (0, 0.43, 0.76) * 1.2;
	level.lootColors["common"] = (0.11, 1, 0) * 1.0;
	level.lootColors["none"] = (1, 1, 0.5);
	*/
	/*
	level.lootColors["epic"] = (0.75, 1, 0.73) * 1.0;
	level.lootColors["rare"] = (0.75, 1, 0.73) * 1.0;
	level.lootColors["common"] = (0.75, 1, 0.73) * 1.0;
	level.lootColors["none"] = (1, 1, 0.5);
	*/
	
	precacheString( &"MP_DOLLAR" );

	level._effect["money"] = loadfx ("props/cash_player_drop");

	maps\mp\gametypes\_rank::registerScoreInfo( "gear", 1000 );
	maps\mp\gametypes\_rank::registerScoreInfo( "money", 1000 );

	maps\mp\gametypes\_rank::registerScoreInfo( "common", 500 );
	maps\mp\gametypes\_rank::registerScoreInfo( "rare", 1000 );
	maps\mp\gametypes\_rank::registerScoreInfo( "epic", 2000 );
	
	level.lootMins["epic"] = 90;
	level.lootMins["rare"] = 70;
	//level.lootMins["common"] = 95;
	
	level.lootIndices["epic"] = 2;
	level.lootIndices["rare"] = 1;
	level.lootIndices["common"] = 0;
	
	level.lootBaseChance = 0.05;
	level.lootIdealTime = (15*60);

	/#
	thread updateLootDvars();
	#/
	
	thread onPlayerConnect();
}


onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		player.pers["money"] = player maps\mp\gametypes\_persistence::statGet( "money" );
		player.displayMoney = player.pers["money"];
		player.moneyUpdateTotal = 0;

		player.timeSinceLastLoot = player maps\mp\gametypes\_persistence::statGet( "timeSinceLastLoot" );
		
		player thread initLootDisplay();
		player thread onPlayerSpawned();
		player thread onGameEnded();
	}
}


onPlayerSpawned()
{
	for ( ;; )
	{
		self waittill( "spawned_player" );
		
		self thread trackLastLootTime();
	}
}


onGameEnded()
{
	self endon ( "disconnect" );

	level waittill ( "game_ended" );
	
	self maps\mp\gametypes\_persistence::statSet( "timeSinceLastLoot", self.timeSinceLastLoot );
}


trackLastLootTime()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		wait ( 1.0 );

		self.timeSinceLastLoot += 1;
	}
}


initLootDisplay()
{
	self.totalMoney = createFontString( "bigfixed", 0.8 );
	self.totalMoney setPoint( "TOPRIGHT" );
	self.totalMoney setValue( self.pers["money"] );
	self.totalMoney.label = &"MP_DOLLAR";
	self.totalMoney.glowColor = (0.3, 0.8, 0.3);
	self.totalMoney.glowAlpha = 1;
	self.totalMoney.alpha = 0;
	
	self.earnedMoney = createFontString( "bigfixed", 0.7 );
	self.earnedMoney setParent( self.totalMoney );
	self.earnedMoney setPoint( "TOPRIGHT", "BOTTOMRIGHT", 0, 10 );
	self.earnedMoney setValue( 0 );
	self.earnedMoney.label = &"MP_PLUS";
	self.earnedMoney.glowColor = (0.3, 0.8, 0.3);
	self.earnedMoney.glowAlpha = 0.1;
	self.earnedMoney.alpha = 0;
}


moMoney()
{
	self endon ( "disconnect" );
	
	for ( ;; )
	{
		wait ( randomFloatRange( 8.0, 10.0 ) );
		
		self thread giveMoney( "asdf", randomIntRange( 100, 5000 ) );
	}
}


giveMoney( type, amount )
{
	if ( !self rankingEnabled() )
		return;
	
	self endon ( "disconnect" );
	self notify( "giveMoney" );
	self endon( "giveMoney" );

	self.displayMoney = self.pers["money"];
	self.pers["money"] += amount;
	self maps\mp\gametypes\_persistence::statSet( "money", self.pers["money"] );

	self.moneyUpdateTotal += amount;
	
	self.totalMoney fadeOverTime( 0.5 );
	self.totalMoney.alpha = 1;

	self.earnedMoney fadeOverTime( 0.5 );
	self.earnedMoney.alpha = 1;
	
	self.earnedMoney setValue( self.moneyUpdateTotal );
	
	wait ( 1.0 );
	
	increment = max( int( self.moneyUpdateTotal / 30 ), 1 );
		
	while ( self.moneyUpdateTotal > 0 )
	{
		addMoney = min( self.moneyUpdateTotal, increment );
		self.moneyUpdateTotal -= addMoney;
		
		self.displayMoney += addMoney;
		self.totalMoney setValue( self.displayMoney );
		self.earnedMoney setValue( self.moneyUpdateTotal );		

		wait ( 0.05 );
	}
	
	self.earnedMoney fadeOverTime( 1.0 );
	self.earnedMoney.alpha = 0;

	wait ( 2.0 );

	self.totalMoney fadeOverTime( 1.0 );
	self.totalMoney.alpha = 0;
}


updateLootDvars()
{
	if ( getDvar( "scr_loot_epicMin" ) == "" )
		setDvar( "scr_loot_epicMin", level.lootMins["epic"] );

	if ( getDvar( "scr_loot_rareMin" ) == "" )
		setDvar( "scr_loot_rareMin", level.lootMins["rare"] );

	//if ( getDvar( "scr_loot_commonMin" ) == "" )
	//	setDvar( "scr_loot_commonMin", level.lootMins["common"] );

	if ( getDvar( "scr_loot_baseChance" ) == "" )
		setDvar( "scr_loot_baseChance", level.lootBaseChance );

	if ( getDvar( "scr_loot_idealTime" ) == "" )
		setDvar( "scr_loot_idealTime", level.lootIdealTime );
	
	/#
	if ( getDvar( "scr_forceloot" ) == "" )
		setDvar( "scr_forceloot", "0" );
	#/
	
	for ( ;; )
	{
		/#
		if ( getDvar( "scr_forceloot" ) != "" && getDvar( "scr_forceloot" ) != "0" )
		{
			setDvar( "scr_loot_baseChance", 1 );
		}
		#/
		
		level.lootMins["epic"] = getDvarFloat( "scr_loot_epicMin" );
		level.lootMins["rare"] = getDvarFloat( "scr_loot_rareMin" );
		//level.lootMins["common"] = getDvarFloat( "scr_loot_commonMin" );
		
		level.lootBaseChance = getDvarFloat( "scr_loot_baseChance" );
		level.lootIdealTime = getDvarFloat( "scr_loot_idealTime" );
		
		wait ( 1.0 );
	}
}


unlockedCaC()
{
	return self isItemUnlocked( "cac" );
}

gotLoot()
{
	if ( !self rankingEnabled() )
		return false;
	
	if ( !self unlockedCaC() )
	{
		returnfalse = true;
		/#
		if ( getDvar( "scr_forceloot" ) != "" && getDvar( "scr_forceloot" ) != "0" )
			returnfalse = false;
		#/
		if ( returnfalse )
			return false;
	}
	
	baseChance = level.lootBaseChance;
	idealLootTime = level.lootIdealTime;
	maxLootChance = 0.50; // 50%
	
	chanceMod = min( self.timeSinceLastLoot / idealLootTime, 1 );
	chanceMod = chanceMod * chanceMod;
	
	lootChance = baseChance + (maxLootChance - baseChance) * chanceMod;
	
	return randomFloat( 1 ) < lootChance;
}


getLootTier( lootRoll )
{
	if ( lootRoll >= level.lootMins["epic"] )
		return "epic";
	else if ( lootRoll >= level.lootMins["rare"] )
		return "rare";
	else
		return "common";
}

getLootName( tier )
{
	if ( !isDefined( self.droppedLootNames ) )
		self.droppedLootNames = [];
	
	for ( try = 0; try < 10; try++ )
	{
		lootName = self GetRandomLoot( tier );
		if ( !isDefined( lootName ) )
			return undefined;
		
		for ( i = 0; i < self.droppedLootNames.size; i++ )
		{
			if ( lootName == self.droppedLootNames[i] )
				break;
		}
		if ( i < self.droppedLootNames.size )
			continue;
		
		return lootName;
	}
	
	return undefined;
}


giveLoot( victim )
{
	if ( !gotLoot() )
		return false;
	
	lootTier = getLootTier( randomFloat( 100.0 ) );
	
	tierInt = level.lootIndices[lootTier];
	lootName = self getLootName( tierInt );
	
	if ( !isDefined( lootName ) )
		return false;
	
	self maps\mp\gametypes\_persistence::statSet( "timeSinceLastLoot", 0 );
	self.timeSinceLastLoot = 0;

	thread maps\mp\_loot::playMoneyFx( victim, self );
	
	if ( lootTier == "epic" )
	{
		self CreateLootMail( lootName );
		self thread showLootNotify( lootTier );
	}
	else
	{
		self thread dropLoot( lootTier, lootName, victim );
	}

	return true;
}


showLootNotify( lootTier )
{
	/*
	notifyData = spawnStruct();

	if ( lootTier == "epic" )
	{
		notifyData.titleText = "Target of Opportunity!";
		notifyData.iconName = "skull_black_plain";
		notifyData.iconOverlay = "skull_crosshair_white";
	}
	else
	{
		notifyData.titleText = "You've got mail!";
	}
	//notifyData.sound = "loot_drop_" + lootTier;
	notifyData.sound = "mp_last_stand";
	notifyData.glowColor = (1, 0, 0);
	notifyData.duration = 3.0;

	thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	*/
}


playMoneyFx( victim, attacker, sMeansOfDeath )
{
	/*
	victim endon ( "disconnect" );
	
	origin = victim getTagOrigin( "j_spine4" );
	victim.fxModel.origin = origin;
	wait ( 0.05 );
	*/
	//playFxOnTag( level._effect["money"], victim.fxModel, "tag_origin" );
	//playFxOnTagForClients	( level._effect["money"], victim.fxModel, "tag_origin", attacker );
}


dropLoot( lootTier, lootName, dropEnt )
{
	trace = playerPhysicsTrace( dropEnt.origin + (0,0,20), dropEnt.origin - (0,0,2000), false, dropEnt);
	angleTrace = bulletTrace( dropEnt.origin + (0,0,20), dropEnt.origin - (0,0,2000), false, dropEnt );
	
	if ( !isDefined( trace ) )
		return;

	println( "dropping loot" );

	tempAngle = randomfloat( 360 );
	
	dropOrigin = trace;
	
	assert( isdefined( self.droppedLootNames ) );
	/#
	foreach ( droppedLootName in self.droppedLootNames )
	{
		assert( droppedLootName != lootName );
	}
	#/
	if ( lootName[0] != "$" )
		self.droppedLootNames[ self.droppedLootNames.size ] = lootName;
	
	fxEnt = spawn( "script_model", dropOrigin );
	//fxEnt.angles = (-90,0,0);

	lootIcon = newClientHudElem( self );
	lootIcon.x = dropOrigin[0];
	lootIcon.y = dropOrigin[1];
	lootIcon.z = dropOrigin[2];
	lootIcon.alpha = 1;

	lootTrigger = spawn( "trigger_radius", dropOrigin, 0, 32, 128 );
	//lootTrigger.angles = (-90,0,0);
	lootTrigger.fxEnt = fxEnt;
	lootTrigger.icon = lootIcon;
	lootTrigger.owner = self;

	lootTrigger thread lootPickupWaiter( lootTier, lootName );
	lootTrigger thread lootDeleteOnDisconnect();
	/#
	if ( getdvarint( "scr_lootdebug" ) )
		lootTrigger thread lootDebugPrint( lootTier, lootName );
	#/
	
	lootTrigger endon ( "death" );
	
	wait ( 0.05 );

	self playLocalSound( "loot_drop_" + lootTier );
	
	switch ( lootTier )
	{
		case "epic":
		case "rare":
		default:
			fxEnt setModel( "gamestation_box" );
			lootIcon setShader( "hud_overlay_random", 10, 10 );		
			lootIcon setWaypoint( true, false );
			lootIcon.alpha = 0.81;
			//playFxOnTagForClients( level._effect["gears"], fxEnt, "tag_origin", self );
			break;
	}
}

lootDebugPrint( lootTier, lootName )
{
	self endon("death");
	while ( 1 )
	{
		print3d( self.origin, "(" + lootTier + ") " + lootName );
		wait .05;
	}
}

lootPickupWaiter( lootTier, lootName )
{
	self endon ( "death" );
	self.owner endon ( "disconnect" );
	
	for ( ;; )
	{
		self waittill ( "trigger", player );
		if ( player != self.owner )
			continue;
	
		//self.owner playLocalSound( "loot_pickup_" + lootTier ); // need better sound
		self.owner playLocalSound( "mp_last_stand" );

		/*
		switch ( lootTier )
		{
			case "epic":
				streakName = getRandomKillstreak( 7 );
				self.owner thread [[level.onXPEvent]]( "gear" );
				break;
			case "rare":
				streakName = getRandomKillstreak( 5 );
				self.owner thread [[level.onXPEvent]]( "gear" );
				break;
			default:
				streakName = getRandomKillstreak( 3 );
				self.owner thread [[level.onXPEvent]]( "money" );
				break;
		}

		self.owner thread randomKillstreakNotify( streakName );
		self.owner maps\mp\killstreaks\_killstreaks::giveKillstreak( streakName );
		*/
		self.owner pickupLoot( lootTier, lootName );
		
		self.fxEnt delete();
		self.icon destroy();
		self delete();
	}
}

pickupLoot( lootTier, lootName )
{
	self thread showLootNotify( lootTier );
	self thread [[level.onXPEvent]]( lootTier );
	self CreateLootMail( lootName );
	
	if ( lootName[0] != "$" )
	{
		for ( i = 0; i < self.droppedLootNames.size; i++ )
		{
			if ( self.droppedLootNames[i] == lootName )
			{
				break;
			}
		}
		assert( i < self.droppedLootNames.size );
		for ( ; i < self.droppedLootNames.size; i++ )
		{
			self.droppedLootNames[i] = self.droppedLootNames[i + 1];
		}
	}
}


lootDeleteOnDisconnect()
{
	self endon ( "death" );

	self.owner waittill ( "disconnect" );
	
	self.fxEnt delete();
	//self.icon destroy(); // code seems to take care of this automatically
	self delete();
}



getRandomKillstreak( minKillCount )
{
	killStreakNames = getArrayKeys( level.killstreakFuncs ); 
	killStreaks = [];
	foreach ( streakName in killStreakNames )
	{
		if ( maps\mp\killstreaks\_killstreaks::getStreakCost( streakName ) < minKillCount )
			continue;
			
		killStreaks[killStreaks.size] = streakName;
	}
	
	return killStreaks[randomInt( killStreaks.size )];
}



randomKillstreakNotify( streakName )
{
	self endon("disconnect");
	
	notifyData = spawnStruct();
	notifyData.titleText = "Killstreak In a Box!";
	notifyData.notifyText = maps\mp\killstreaks\_killstreaks::getKillstreakHint( streakName );
	notifyData.textIsString = true;
	notifyData.sound = maps\mp\killstreaks\_killstreaks::getKillstreakSound( streakName );
	notifyData.leaderSound = streakName;
	notifyData.glowColor = (1, 0.76, 0.35);
	notifyData.textGlowColor = (1, 1, 0.5);
	
	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}
