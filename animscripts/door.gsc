#include animscripts\combat_utility;
#include animscripts\utility;
#include animscripts\shared;
#include common_scripts\utility;
#include maps\_utility;

#using_animtree( "generic_human" );


doorGrenadeInterval = 5000;
maxDistDoorToEnemySq = 600 * 600;

doorEnterExitCheck()
{
	self endon( "killanimscript" );

	if ( isdefined( self.disableDoorBehavior ) )
		return;

	while ( 1 )
	{
		doorNode = self getDoorPathNode();
		if ( isdefined( doorNode ) )
			break;

		wait 0.2;
	}

	goingInDoor = ( doorNode.type == "Door Interior" ) || self compareNodeDirToPathDir( doorNode );

	if ( goingInDoor )
		self doorEnter( doorNode );
	else
		self doorExit( doorNode );

	// waittill doorNode changes
	while ( 1 )
	{
		newDoorNode = self getDoorPathNode();
		if ( !isdefined( newDoorNode ) || newDoorNode != doorNode )
			break;

		wait 0.2;
	}

	self thread doorEnterExitCheck();
}

teamFlashBangImmune()
{
	self endon( "killanimscript" );

	self.teamFlashbangImmunity = true;
	wait 5;
	self.teamFlashbangImmunity = undefined;
}


doDoorGrenadeThrow( node )
{
	self thread teamFlashBangImmune();

	if ( self.grenadeWeapon == "flash_grenade" )
		self notify( "flashbang_thrown" );

	self OrientMode( "face current" );
	node.nextDoorGrenadeTime = gettime() + doorGrenadeInterval;
	self.minInDoorTime = gettime() + 100000;	// hack to not forget going indoor

	self notify( "move_interrupt" );
	self.update_move_anim_type = undefined;

	self clearanim( %combatrun, 0.2 );
	self.a.movement = "stop";
	self waittill( "done_grenade_throw" );
	self OrientMode( "face default" );

	self.minInDoorTime = gettime() + 5000;

	self.grenadeWeapon = self.oldGrenadeWeapon;
	self.oldGrenadeWeapon = undefined;

	self animscripts\run::endFaceEnemyAimTracking();
	self thread animscripts\move::pathChangeCheck();
	self thread animscripts\move::restartMoveLoop( true );
}


// try throwing grenade before entering door
doorEnter_TryGrenade( node, grenadeType, ricochet, minDistSq, checkInterval )
{
	safeCheckDone = false;
	throwAttempts = 3;
	throwAnim = undefined;
	throwAnim = %CQB_stand_grenade_throw;

	doorForward = anglesToForward( node.angles );
	if ( node.type == "Door Interior" && !( self compareNodeDirToPathDir( node ) ) )
		doorForward = -1 * doorForward;

	doorPos = ( node.origin[ 0 ], node.origin[ 1 ], node.origin[ 2 ] + 64 );
	throwPos = doorPos;

	if ( ricochet )
	{
		doorPlane = AnglesToRight( node.angles );
		dirToDoor = node.origin - self.origin;

		// upto 20 units to left or right of door depending on direction to door to make it likely to bounce off door edge
		projLength = vectordot( doorPlane, dirToDoor );
		if ( projLength > 20 )
			projLength = 20;
		else if ( projLength < - 20 )
			projLength = -20;

		throwPos = doorPos + projLength * doorPlane;
	}

	while ( throwAttempts > 0 )
	{
		if ( isdefined( self.grenade ) || !isdefined( self.enemy ) )
			return;

		if ( onSameSideOfDoor( node, doorForward ) )
			return;

		if ( !self seeRecently( self.enemy, 0.2 ) && self.a.pose == "stand" && distance2DAndHeightCheck( self.enemy.origin - node.origin, maxDistDoorToEnemySq, 128 * 128 ) )
		{
			if ( isdefined( node.nextDoorGrenadeTime ) && node.nextDoorGrenadeTime > gettime() )
				return;

			if ( self canShootEnemy() )
				return;

			// too close to door
			dirToDoor = node.origin - self.origin;
			if ( lengthSquared( dirToDoor ) < minDistSq )
				return;

			// don't throw backwards
			if ( vectordot( dirToDoor, doorForward ) < 0 )
				return;

			self.oldGrenadeWeapon = self.grenadeWeapon;
			self.grenadeWeapon = grenadeType;

			self setActiveGrenadeTimer( self.enemy );

			if ( !safeCheckDone )
			{
				checkPos = doorPos + ( doorForward * 100 );
				if ( !( self isGrenadePosSafe( self.enemy, checkPos, 128 ) ) )
					return;
			}

			safeCheckDone = true;	// do this only once but do isGrenadePosSafe as late as possible

			if ( TryGrenadeThrow( self.enemy, throwPos, throwAnim, getGrenadeThrowOffset( throwAnim ), true, false, true ) )
			{
				self doDoorGrenadeThrow( node );
				return;
			}
		}

		throwAttempts -- ;
		wait checkInterval;

		// check if door node has past
		newNode = self getDoorPathNode();
		if ( !isdefined( newNode ) || newNode != node )
			return;
	}
}


inDoorCqbToggleCheck()
{
	self endon( "killanimscript" );

	if ( isdefined( self.disableDoorBehavior ) )
		return;

	self.isInDoor = false;

	while ( 1 )
	{
		if ( self isInDoor() && !self.doingAmbush )
		{
			doorEnter_enable_cqbwalk();
		}
		else if ( !isdefined( self.minInDoorTime ) || self.minInDoorTime < gettime() )
		{
			self.minInDoorTime = undefined;
			doorExit_disable_cqbwalk();
		}

		wait 0.2;
	}
}


// substitute for enable_cqbwalk so LD can always disable cqb
doorEnter_enable_cqbwalk()
{
	if ( !isdefined( self.neverEnableCQB ) && !self.doingAmbush )
	{
		self.isInDoor = true;
		if ( !isdefined( self.cqbWalking ) || !self.cqbWalking )
			enable_cqbwalk( true );
	}
}


// substitute for disable_cqbwalk so LD can force CQB even after exiting to outdoor
doorExit_disable_cqbwalk()
{
	if ( !isdefined( self.cqbEnabled ) )
	{
		self.isInDoor = false;
		if ( isdefined( self.cqbWalking ) && self.cqbWalking )
			disable_cqbwalk();
	}
}


maxFragDistSq = 750 * 750;
minFragDistSq = 550 * 550;
maxFlashDistSq = 192 * 192;
minFlashDistSq = 64 * 64;
maxFragHeightDiffSq = 160 * 160;
maxFlashHeightDiffSq = 80 * 80;

distance2DAndHeightCheck( vec, dist2DSq, heightSq )
{
	return( ( vec[ 0 ] * vec[ 0 ] + vec[ 1 ] * vec[ 1 ] ) < dist2DSq ) && ( ( vec[ 2 ] * vec[ 2 ] ) < heightSq );
}


onSameSideOfDoor( node, doorForward )
{
	assert( isdefined( self.enemy ) );

	selfToDoor = node.origin - self.origin;
	enemyToDoor = node.origin - self.enemy.origin;

	return( vectordot( selfToDoor, doorForward ) * vectordot( enemyToDoor, doorForward ) > 0 );
}


doorEnter( node )
{
	// try frag
	while ( 1 )
	{
		if ( isdefined( self.doorFragChance ) && ( self.doorFragChance == 0 || self.doorFragChance < randomfloat( 1 ) ) )
			break;

		if ( distance2DAndHeightCheck( self.origin - node.origin, maxFragDistSq, maxFragHeightDiffSq ) )
		{
			self doorEnter_TryGrenade( node, "fraggrenade", false, minFragDistSq, 0.3 );

			node = self getDoorPathNode();
			if ( !isdefined( node ) )
				return;

			break;
		}
		wait 0.1;
	}

	// try flashbang
	while ( 1 )
	{
		if ( distance2DAndHeightCheck( self.origin - node.origin, maxFlashDistSq, maxFlashHeightDiffSq ) )
		{
			self doorEnter_enable_cqbwalk();
			self.minInDoorTime = gettime() + 6000;

			if ( isdefined( self.doorFlashChance ) && ( self.doorFlashChance == 0 || self.doorFlashChance < randomfloat( 1 ) ) )
				return;

			self doorEnter_TryGrenade( node, "flash_grenade", true, minFlashDistSq, 0.2 );
			return;
		}

		wait 0.1;
	}
}

doorExit( node )
{
	while ( 1 )
	{
		if ( !self.isInDoor || distanceSquared( self.origin, node.origin ) < 32 * 32 )
		{
			//self doorExit_disable_cqbwalk();
			return;
		}

		wait 0.1;
	}
}