#include maps\mp\_utility;
#include common_scripts\utility;

/******************************************************************* 
//						_littleBird.gsc  
//	
//	Holds all the littlebird specific functions
//	
//	Jordan Hirsh	Jan. 6th 	2009
********************************************************************/


init()
{
	precacheString( &"MP_CIVILIAN_AIR_TRAFFIC" );
	precacheString( &"MP_AIR_SPACE_TOO_CROWDED" );
	
	return;
	//precacheString( &"MP_WAR_AIRSTRIKE_INBOUND_NEAR_YOUR_POSITION" );
	//precacheString( &"MP_WAR_AIRSTRIKE_INBOUND" );
	
	//precacheTurret( "minigun_littlebird_mp" );
	//precacheModel( "vehicle_little_bird_minigun_left" );
	//precacheModel( "vehicle_little_bird_minigun_right" );
	
	//level.attackLB = [];
	//level.lbStrike = 0;
	
	//level.killStreakFuncs["littlebird_support"] = ::tryUseLbStrike;
}


tryUseLbStrike( lifeId )
{
	if ( isDefined( level.civilianJetFlyBy ) )
	{
		self iPrintLnBold( &"MP_CIVILIAN_AIR_TRAFFIC" );
		return false;
	}

	if ( self isUsingRemote() )
	{
		return false;
	}
	
	if ( level.lbStrike >= 1 )
	{
		self iPrintLnBold( &"MP_AIR_SPACE_TOO_CROWDED" );
		return false;	
	}
	
	result = self selectLbStrikeLocation( lifeId );

	if ( !isDefined( result ) || !result )
		return false;
	
	level.lbStrike++;
	return true;
}


startLBStrike( lifeId, origin, owner, team, yawDir )
{	
	while ( isDefined( level.airstrikeInProgress ) )
	{
		level waittill ( "begin_airstrike" );
	}
	
	level.airstrikeInProgress = true;

	num = 17 + randomint(3);
	trace = bullettrace(origin, origin + (0,0,-1000000), false, undefined);
	targetpos = trace["position"];
	
	//yaw = getBestLbDirection( targetpos );
	
	//yaw = 90;
	yaw = yawDir;
	
	if ( level.teambased )
	{
		players = level.players;
		
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			playerteam = player.pers["team"];
			if ( isdefined( playerteam ) )
			{
				if ( playerteam == team )
					player iprintln( &"MP_WAR_AIRSTRIKE_INBOUND", owner );
			}
		}
	}
	
	// buffer between airstrikes
	level.airstrikeInProgress = undefined;

	owner notify ( "begin_airstrike" );
	level notify ( "begin_airstrike" );
	
	if ( !isDefined( owner ) )
		return;
	
	callStrike( lifeId, owner, targetpos, yaw );
}


clearProgress( delay )
{
	if( !isDefined( delay ) )
		delay = 0;
		
	wait ( delay );
	level.lbStrike = 0;	
}


doLbStrike( lifeId, owner, requiredDeathCount, coord, startPoint, endPoint, direction )
{
	self endon( "death" );

	if ( !isDefined( owner ) ) 
		return;

	lb = spawnAttackLittleBird( owner, startPoint, endPoint, coord );
	lb.lifeId = lifeId;
	
	lb thread watchDeath();
	lb thread waitTillGone();
	
	lb endon( "death" );
	
	totalDist = Distance2d( startPoint, coord );
	midTime = ( totalDist / lb.speed ) / 2 * .1 + 2.5;
	
	assert ( isDefined( lb ) );
	
	lb SetMaxPitchRoll( 45, 45 );			
	//moving to end point
	lb setVehGoalPos( endPoint, 1 );
	wait( midTime - 1 );
	
	//slowing down and firing 
	lb Vehicle_SetSpeed( 45, 60 );
	wait( 1 );
	lb SetMaxPitchRoll( 200, 200 );	
	wait ( 5 );	
	lb thread startLbFiring();
	wait ( 7 );
	
	//stops firing and turns around
	lb notify ( "stopFiring" );
	lb Vehicle_SetSpeed( 75, 60 );
	lb SetMaxPitchRoll( 65, 65 );
	wait(2.5);
	lb setVehGoalPos( startPoint, 1 );	
	wait ( 4 );
	lb SetMaxPitchRoll( 180, 180 );
	wait ( .75 );
	
	//slows down firing opposite direction
	lb Vehicle_SetSpeed( 45, 60 );
	lb thread startLbFiring();
	wait ( 6 );
	
	//off into the sunset
	lb Vehicle_SetSpeed( lb.speed, 60 );
	lb notify ( "stopFiring" ); 
	lb SetMaxPitchRoll( 75, 180 );
	
	lb waittill ( "goal" );
	lb notify( "gone" );
	lb delete();

}

waitTillGone()
{
	self waittill( "gone" );
	clearProgress( 0 );
}


// spawn helicopter at a start node and monitors it
spawnAttackLittleBird( owner, pathStart, pathGoal, coord )
{
	
	forward = vectorToAngles( pathGoal - pathStart );
	lb = spawnHelicopter( owner, pathStart, forward, "littlebird_mp" , "vehicle_little_bird_armed" );

	if ( !isDefined( lb ) )
		return;
	lb.speed = 400;
	lb.health = 350; 
	lb setCanDamage( true );
	lb.owner = owner;
	lb.team = owner.team;
	lb SetMaxPitchRoll( 45, 45 );	
	lb Vehicle_SetSpeed( lb.speed, 60 );
	
	lb.damageCallback = ::Callback_VehicleDamage;
	
	mgTurret1 = spawnTurret( "misc_turret", lb.origin, "minigun_littlebird_mp" );
	mgTurret1 linkTo( lb, "tag_minigun_attach_right", (0,0,0), (0,0,0) );
	mgTurret1 setModel( "vehicle_little_bird_minigun_right" );
	mgTurret1.angles = lb.angles; 
	mgTurret1.owner = lb.owner;
	mgTurret1.team = mgTurret1.owner.team;
	
	mgTurret1 SetPlayerSpread( .65 );
	mgTurret1 makeTurretInoperable();
	lb.mgTurret1 = mgTurret1; 
	lb.mgTurret1 SetDefaultDropPitch( 0 );
	
	mgTurret2 = spawnTurret( "misc_turret", lb.origin, "minigun_littlebird_mp" );
	mgTurret2 linkTo( lb, "tag_minigun_attach_left", (0,0,0), (0,0,0) );
	mgTurret2 setModel( "vehicle_little_bird_minigun_right" );
	mgTurret2 SetPlayerSpread( .65 );
	mgTurret2.angles = lb.angles; 
	mgTurret2.owner = lb.owner;
	mgTurret2.team = mgTurret2.owner.team;
	
	mgTurret2 makeTurretInoperable();
	lb.mgTurret2 = mgTurret2; 
	lb.mgTurret2 SetDefaultDropPitch( 0 );
	
	level.littlebird[level.littlebird.size] = lb;
	
	return lb;
}

startLbFiring( )
{
	self endon( "gone" );
	self endon( "death" );
	self endon( "stopFiring" );
	
	i = 0;
	
	for( ;; )
	{
		self.mgTurret1 ShootTurret();
		self.mgTurret2 ShootTurret();
		wait ( 0.05 );	
	}	
}

getBestLbDirection( hitpos )
{
	//if ( !self.precisionAirstrike )
	//	return randomFloat( 360 );
	
	checkPitch = -25;
	
	numChecks = 15;
	
	startpos = hitpos + (0,0,64);
	
	bestangle = randomfloat( 360 );
	bestanglefrac = 0;
	
	fullTraceResults = [];
	
	for ( i = 0; i < numChecks; i++ )
	{
		yaw = ((i * 1.0 + randomfloat(1)) / numChecks) * 360.0;
		angle = (checkPitch, yaw + 180, 0);
		dir = anglesToForward( angle );
		
		endpos = startpos + dir * 1500;
		
		trace = bullettrace( startpos, endpos, false, undefined );
		
		if ( trace["fraction"] > bestanglefrac )
		{
			bestanglefrac = trace["fraction"];
			bestangle = yaw;
			
			if ( trace["fraction"] >= 1 )
				fullTraceResults[ fullTraceResults.size ] = yaw;
		}
		
		if ( i % 3 == 0 )
			wait .05;
	}
	
	if ( fullTraceResults.size > 0 )
		return fullTraceResults[ randomint( fullTraceResults.size ) ];
	
	return bestangle;
}


callStrike( lifeId, owner, coord, yaw )
{	
	// Get starting and ending point for the plane
	direction = ( 0, yaw, 0 );
	planeHalfDistance = 24000;
	planeFlyHeight = 850;
	planeFlySpeed = 7000;
	
	if ( isdefined( level.airstrikeHeightScale ) )
		planeFlyHeight *= level.airstrikeHeightScale;
	
	startPoint = coord + vector_multiply( anglestoforward( direction ), -1 * planeHalfDistance );
	startPoint += ( 0, 0, planeFlyHeight );

	endPoint = coord + vector_multiply( anglestoforward( direction ), planeHalfDistance );
	endPoint += ( 0, 0, planeFlyHeight );
	
	owner endon("disconnect");
	
	requiredDeathCount = owner.lifeId;

	level thread doLbStrike( lifeId, owner, requiredDeathCount, coord, startPoint, endPoint, direction );
	            
}


waitForLbStrikeCancel()
{
	self waittill( "cancel_location" );
	self setblurforplayer( 0, 0.3 );
}


selectLbStrikeLocation( lifeId )
{
	self setClientDvar( "ui_selecting_location", "1");
	self beginLocationSelection( "map_artillery_selector", true, 500 );
	self.selectingLocation = true;

	self setblurforplayer( 10.3, 0.3 );
	self thread waitForLbStrikeCancel();

	self thread endSelectionOn( "cancel_location" );
	self thread endSelectionOn( "death" );
	self thread endSelectionOn( "disconnect" );
	self thread endSelectionOn( "used" );
	self thread endSelectionOnGameEnd();

	self endon( "stop_location_selection" );
	
	// wait for the selection. randomize the yaw if we ever stop doing a precision selection
	self waittill( "confirm_location", location, locationYaw);

	self setblurforplayer( 0, 0.3 );

	self thread finishLbStrikeUsage( lifeId, location, ::useLbStrike, locationYaw );
	return true;
}


finishLbStrikeUsage( lifeId, location, usedCallback, locationYaw )
{
	self notify( "used" );
	wait ( 0.05 );
	self thread stopLbStrikeLocationSelection( false );
	self thread [[usedCallback]]( lifeId, location, locationYaw );
	return true;
}


endSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	self waittill( waitfor );
	self thread stopLbStrikeLocationSelection( (waitfor == "disconnect") );
}


endSelectionOnGameEnd()
{
	self endon( "stop_location_selection" );
	level waittill( "game_ended" );
	self thread stopLbStrikeLocationSelection( false );
}


stopLbStrikeLocationSelection( disconnected )
{
	if ( !disconnected )
	{
		self setblurforplayer( 0, 0.3 );
		self endLocationSelection();
		self.selectingLocation = undefined;
	}
	self notify( "stop_location_selection" );
}

useLbStrike( lifeId, pos, yawDir )
{
	// find underside of top of skybox
	trace = bullettrace( level.mapCenter + (0,0,1000000), level.mapCenter, false, undefined );
	pos = (pos[0], pos[1], trace["position"][2] - 514);

	thread startLBStrike( lifeId, pos, self, self.pers["team"], yawDir );
}

Callback_VehicleDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName )
{
	if ( ( attacker == self || ( isDefined( attacker.pers ) && attacker.pers["team"] == self.team ) ) && ( attacker != self.owner || meansOfDeath == "MOD_MELEE" ) )
		return;
	

	self Vehicle_FinishDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
}

watchDeath()
{
	self endon( "gone" );
	
	self waittill( "death" );
	self thread heliDestroyed();
	
	level.littleBirds--;
	clearProgress( 0.05 );
	
	return;
}

heliDestroyed()
{
	self endon( "gone" );
	
	if (! isDefined(self) )
		return;
		
	//self trimActiveBirdList();
	self Vehicle_SetSpeed( 25, 5 );
	self thread lbSpin( RandomIntRange(180, 220) );
	
	wait( RandomFloatRange( .5, 1.5 ) );
	
	lbExplode();
}

lbExplode()
{
	forward = ( self.origin + ( 0, 0, 1 ) ) - self.origin;
	playfx ( level.chopper_fx["explode"]["air_death"], self.origin, forward );

	deathAngles = self getTagAngles( "tag_deathfx" );		
	playFx( level.chopper_fx["explode"]["air_death"]["littlebird"], self getTagOrigin( "tag_deathfx" ), anglesToForward( deathAngles ), anglesToUp( deathAngles ) );
	
	self playSound( "cobra_helicopter_crash" );
	self notify ( "explode" );
	
	if ( isDefined( self.mgTurret1 ) )
		self.mgTurret1 delete();
	
	if ( isDefined( self.mgTurret2 ) )
		self.mgTurret2 delete();
	
	self clearProgress( 0 );

	self delete();
}

lbSpin( speed )
{
	self endon( "explode" );
	
	// tail explosion that caused the spinning
	playfxontag( level.chopper_fx["explode"]["medium"], self, "tail_rotor_jnt" );
 	self thread trail_fx( level.chopper_fx["smoke"]["trail"], "tail_rotor_jnt", "stop tail smoke" );
	
	self setyawspeed( speed, speed, speed );
	while ( isdefined( self ) )
	{
		self settargetyaw( self.angles[1]+(speed*0.9) );
		wait ( 1 );
	}
}

trail_fx( trail_fx, trail_tag, stop_notify )
{
	// only one instance allowed
	self notify( stop_notify );
	self endon( stop_notify );
	self endon( "death" );
		
	for ( ;; )
	{
		playfxontag( trail_fx, self, trail_tag );
		wait( 0.05 );
	}
}