#include common_scripts\utility;
#include animscripts\utility;
#include animscripts\combat_utility;
#include maps\_utility;

#using_animtree( "generic_human" );


//
//		 Damage Yaw
//
//           front
//        /----|----\
//       /    180    \
//      /\     |     /\
//     / -135  |  135  \
//     |     \ | /     |
// left|-90----+----90-|right
//     |     / | \     |
//     \  -45  |  45   /
//      \/     |     \/
//       \     0     / 
//        \----|----/
//           back

main()
{
	self endon( "killanimscript" );

	// make sure the guy doesn't talk after death
	self stopsoundchannel( "voice" );
	changeTime = 0.3;
	self clearanim( %scripted_talking, 				changeTime );
	
	// don't abort at this point unless you're going to play another animation!
	// just playing ragdoll isn't sufficient because sometimes ragdoll fails, and then
	// you'll just have a corpse standing around in limbo.
	
	if ( self.a.nodeath == true )
		return;

	if ( isdefined( self.deathFunction ) )
	{
		result = self [[ self.deathFunction ]]();
		if ( !isdefined( result ) )
			result = true;
		if ( result )
			return;
	}

	animscripts\utility::initialize( "death" );

	// should move this to squad manager somewhere...
	removeSelfFrom_SquadLastSeenEnemyPos( self.origin );

	anim.numDeathsUntilCrawlingPain -- ;
	anim.numDeathsUntilCornerGrenadeDeath -- ;

	if ( isDefined( self.ragdoll_immediate ) || self.forceRagdollImmediate )
	{
		self doImmediateRagdollDeath();
		// ragdoll can fail so don't assume that we can quit the function
	}

	if ( isDefined( self.deathanim ) )
	{
		playDeathAnim( self.deathAnim );

		// Added so that I can do special stuff in Level scripts on an ai
		if ( isdefined( self.deathanimscript ) )
			self [[ self.deathanimscript ]]();
		return;
	}

	explosiveDamage = self animscripts\pain::wasDamagedByExplosive();

	if ( self.damageLocation == "helmet" || self.damageLocation == "head" )
		self helmetPop();
	else if ( explosiveDamage && randomint( 3 ) == 0 )
		self helmetPop();

	self clearanim( %root, 0.3 );

	if ( !damageLocationIsAny( "head", "helmet" ) )
	{
		if ( self.dieQuietly )
		{
			// replace with actual die quietly gurglesque sound
//			if ( randomint(3) < 2 )
//				self animscripts\face::SayGenericDialogue("pain");
		}
		else
		{
			PlayDeathSound();
		}
	}

	if ( explosiveDamage && playExplodeDeathAnim() )
		return;
		
	// different from deathFunction above, doesn't skip explosion deaths, immediate ragdoll, sounds, etc
	if ( isdefined( self.specialDeathFunc ) )
	{
		if ( [[ self.specialDeathFunc ]]() )
			return;
	}

	// TODO: replace these with the above specialDeathFunc
	if ( specialDeath() )
		return;

	deathAnim = getDeathAnim();

	 /#
	if ( getdvarint( "scr_paindebug" ) == 1 )
		println( "^2Playing pain: ", deathAnim, " ; pose is ", self.a.pose );
	#/

	playDeathAnim( deathAnim );
}

doImmediateRagdollDeath()
{
	self animscripts\shared::DropAllAIWeapons();
	self.skipDeathAnim = true;  // this helps playDeathAnim() do failsafes for ragdoll failures later
	
	initialImpulse = 10;
	
	damageType = common_scripts\_destructible::getDamageType( self.damageMod );
	if( IsDefined( self.attacker ) && self.attacker == level.player && damageType == "melee" )
	{
		initialImpulse = 5;
	}
	
	damageTaken = self.damagetaken;
	if ( damageType == "bullet" )
		damageTaken = max( damageTaken, 300 );
	
	directionScale = initialImpulse * damageTaken;
	directionUp = max( 0.3, self.damagedir[ 2 ] );
	direction = ( self.damagedir[ 0 ], self.damagedir[ 1 ], directionUp );
	direction *= directionScale;
	
	if ( self.forceRagdollImmediate )
		direction += self.prevAnimDelta * 20 * 10;	// 20 frames/sec
	
	self startragdollfromimpact( self.damagelocation, direction );
	
	// wait a bit so that the ragdoll can start before the death script tries to play a regular
	//  death animation as a failsafe - if ragdolling, the regular death anim won't do anything when called
	wait( 0.05 );
}

playDeathAnim( deathAnim )
{
	if ( !animHasNoteTrack( deathAnim, "dropgun" ) && !animHasNoteTrack( deathAnim, "fire_spray" ) )// && !animHasNotetrack( deathAnim, "gun keep" )
		self animscripts\shared::DropAllAIWeapons();

	//if ( isdefined( self.faceDamageDir ) )
	//	self orientmode( "face angle", self.damageYaw );

	self setFlaggedAnimKnobAllRestart( "deathanim", deathAnim, %body, 1, .1 );

	if ( IsDefined( self.skipDeathAnim ) )
	{
		ASSERTEX( self.skipDeathAnim, "self.skipDeathAnim must be either true or undefined." );
		
		if( !isdefined( self.noragdoll ) )
			self startRagDoll();
		
		wait( 0.05 );
		// failsafe in case ragdoll fails: he'll still be playing a deathanim,
		//  but at least he'll fall to the ground
		self AnimMode( "gravity" );
	}
	else if ( !animHasNotetrack( deathanim, "start_ragdoll" ) )
	{
		self thread waitForRagdoll( getanimlength( deathanim ) * 0.35 );
	}

	// do we really need this anymore?
	 /#
	if ( getdebugdvar( "debug_grenadehand" ) == "on" )
	{
		if ( animhasnotetrack( deathAnim, "bodyfall large" ) )
			return;
		if ( animhasnotetrack( deathAnim, "bodyfall small" ) )
			return;

		println( "Death animation ", deathAnim, " does not have a bodyfall notetrack" );
		iprintlnbold( "Death animation needs fixing (check console and report bug in the animation to Boon)" );
	}
	#/
	
	// SRS 11/20/08: blood pools don't always line up with ragdoll corpses, so skip them if
	//  we did ragdoll without a death anim (which usually sends the body farther away from the death spot)
	if ( !IsDefined( self.skipDeathAnim ) )
	{
		self thread playDeathFX();
	}
	
	self animscripts\shared::DoNoteTracks( "deathanim" );
	self animscripts\shared::DropAllAIWeapons();
}

waitForRagdoll( time )
{
	wait( time );
	if ( isdefined( self ) )
		self animscripts\shared::DropAllAIWeapons();
	if ( isdefined( self ) && !isdefined( self.noragdoll ) )
		self startragdoll();
}

playDeathFX()
{
	self endon( "killanimscript" );
	//iprintlnbold("bleed'n");

	if ( self.stairsState != "none" )
		return;

	wait 2;
	
	play_blood_pool();
}

play_blood_pool( note, flagName )
{
	if ( !isdefined( self ) )
		return;
	
	if ( isdefined( self.skipBloodPool ) )
	{
		assertex( self.skipBloodPool, "Setting must be either true or undefined" );
		return;
	}
	
	tagPos = self gettagorigin( "j_SpineUpper" );	// rough tag to play fx on
	tagAngles = self gettagangles( "j_SpineUpper" );
	forward = anglestoforward( tagAngles );
	up = anglestoup( tagAngles );
	right = anglestoright( tagAngles );

	tagPos = tagPos + vector_multiply( forward, -8.5 ) + vector_multiply( up, 5 ) + vector_multiply( right, 0 );

	trace = bulletTrace( tagPos + ( 0, 0, 30 ), tagPos - ( 0, 0, 100 ), false, undefined );
	
	if ( trace[ "normal" ][2] > 0.9 )
		playfx( level._effect[ "deathfx_bloodpool_generic" ], tagPos );
}


// TODO: replace these with specialDeathFunc
// Special death is for corners, rambo behavior, mg42's, anything out of the ordinary stand, crouch and prone.  
// It returns true if it handles the death for the special animation state, or false if it wants the regular 
// death function to handle it.
specialDeath()
{
	if ( self.a.special == "none" )
		return false;

	switch( self.a.special )
	{
	case "cover_right":
		if ( self.a.pose == "stand" )
		{
			deathArray = [];
			deathArray[ 0 ] = %corner_standr_deathA;
			deathArray[ 1 ] = %corner_standr_deathB;
			DoDeathFromArray( deathArray );
		}
		else
		{
			deathArray = [];

			if ( damageLocationIsAny( "head", "neck" ) )
			{
				deathArray[ 0 ] = %CornerCrR_alert_death_slideout;
			}
			else
			{
				deathArray[ 0 ] = %CornerCrR_alert_death_slideout;
				deathArray[ 1 ] = %CornerCrR_alert_death_back;
			}
			DoDeathFromArray( deathArray );
		}
		return true;

	case "cover_left":
		if ( self.a.pose == "stand" )
		{
			deathArray = [];
			deathArray[ 0 ] = %corner_standl_deathA;
			deathArray[ 1 ] = %corner_standl_deathB;
			DoDeathFromArray( deathArray );
		}
		else
		{
			deathArray = [];
			deathArray[ 0 ] = %CornerCrL_death_side;
			deathArray[ 1 ] = %CornerCrL_death_back;
			DoDeathFromArray( deathArray );
		}
		return true;

	case "cover_stand":
		deathArray = [];
		deathArray[ 0 ] = %coverstand_death_left;
		deathArray[ 1 ] = %coverstand_death_right;
		DoDeathFromArray( deathArray );
		return true;

	case "cover_crouch":
		deathArray = [];
		if ( damageLocationIsAny( "head", "neck" ) && ( self.damageyaw > 135 || self.damageyaw <= -45 ) )	// Front / Left quadrant
			deathArray[ deathArray.size ] = %covercrouch_death_1;

		if ( ( self.damageyaw > - 45 ) && ( self.damageyaw <= 45 ) )	// Back quadrant
			deathArray[ deathArray.size ] = %covercrouch_death_3;

		deathArray[ deathArray.size ] = %covercrouch_death_2;

		DoDeathFromArray( deathArray );
		return true;

	case "saw":
		if ( self.a.pose == "stand" )
			DoDeathFromArray( array( %saw_gunner_death ) );
		else if ( self.a.pose == "crouch" )
			DoDeathFromArray( array( %saw_gunner_lowwall_death ) );
		else
			DoDeathFromArray( array( %saw_gunner_prone_death ) );
		return true;

	case "dying_crawl":
		if ( isdefined( self.a.onback ) && self.a.pose == "crouch" )
		{
			deathArray = array( %dying_back_death_v2, %dying_back_death_v3, %dying_back_death_v4 );
			DoDeathFromArray( deathArray );
		}
		else
		{
			assertex( self.a.pose == "prone", self.a.pose );
			deathArray = array( %dying_crawl_death_v1, %dying_crawl_death_v2 );
			DoDeathFromArray( deathArray );
		}
		return true;
	}
	return false;
}


DoDeathFromArray( deathArray )
{
	deathAnim = deathArray[ randomint( deathArray.size ) ];

	playDeathAnim( deathAnim );
	//nate - adding my own special death flag on top of special death. 
	if ( isdefined( self.deathanimscript ) )
		self [[ self.deathanimscript ]]();
}


PlayDeathSound()
{
//	if (self.team == "allies")
//		self playsound("allied_death"); 
//	else
//		self playsound("german_death"); 
	self animscripts\face::SayGenericDialogue( "death" );
}

print3dfortime( place, text, time )
{
	numframes = time * 20;
	for ( i = 0; i < numframes; i++ )
	{
		print3d( place, text );
		wait .05;
	}
}

helmetPop()
{
	if ( !isdefined( self ) )
		return;
	if ( !isdefined( self.hatModel ) )
		return;
	// used to check self removableHat() in cod2... probably not necessary though

	partName = GetPartName( self.hatModel, 0 );
	model = spawn( "script_model", self.origin + ( 0, 0, 64 ) );
	model setmodel( self.hatModel );
	model.origin = self GetTagOrigin( partName );// self . origin + ( 0, 0, 64 );
	model.angles = self GetTagAngles( partName );// ( -90, 0 + randomint( 90 ), 0 + randomint( 90 ) );
	model thread helmetLaunch( self.damageDir );

	hatModel = self.hatModel;
	self.hatModel = undefined;

	wait 0.05;

	if ( !isdefined( self ) )
		return;
	self detach( hatModel, "" );
}

helmetLaunch( damageDir )
{
    launchForce = damageDir;
	launchForce = launchForce * randomFloatRange( 2000, 4000 );

	forcex = launchForce[ 0 ];
	forcey = launchForce[ 1 ];
	forcez = randomFloatRange( 1500, 3000 );

	contactPoint = self.origin + ( randomfloatrange( -1, 1 ), randomfloatrange( -1, 1 ), randomfloatrange( -1, 1 ) ) * 5;

	self PhysicsLaunchClient( contactPoint, ( forcex, forcey, forcez ) );

	wait 60;

	while ( 1 )
	{
		if ( !isdefined( self ) )
			return;

		if ( distanceSquared( self.origin, level.player.origin ) > 512 * 512 )
			break;

		wait 30;
	}

	self delete();
}


removeSelfFrom_SquadLastSeenEnemyPos( org )
{
	for ( i = 0;i < anim.squadIndex.size;i++ )
		anim.squadIndex[ i ] clearSightPosNear( org );
}


clearSightPosNear( org )
{
	if ( !isdefined( self.sightPos ) )
		return;

	if ( distance( org, self.sightPos ) < 80 )
	{
		self.sightPos = undefined;
		self.sightTime = gettime();
	}
}


shouldDoRunningForwardDeath()
{
	if ( self.a.movement != "run" )
		return false;

	if ( self getMotionAngle() > 60 || self getMotionAngle() < - 60 )
		return false;

/*
	if ( ( self.damageyaw >= 120 ) || ( self.damageyaw <= -120 ) )// Front quadrant
		return true;

	if ( ( self.damageyaw >= -45 ) && ( self.damageyaw <= 45 ) )// Back quadrant
		return true;

	return false;
*/
	return true;
}

shouldDoStrongBulletDamage( damageWeapon, damageMod, damagetaken, attacker )
{
	ASSERT( IsDefined( damageWeapon ) );

	if ( isdefined( self.a.doingLongDeath ) )
	{
		return false;
	}

	if ( self.a.pose == "prone" || isdefined( self.a.onback ) )
	{
		return false;
	}
	
	if( damageWeapon == "none" )
	{
		return false;
	}
	
	if ( damagetaken > 500 )
	{
		return true;
	}
	
	if( damageMod == "MOD_MELEE" )
	{
		return false;	
	}
	
	// if I'm running, and the attacker is far enough away, sometimes let me do
	//  a running death instead.  this helps minimize repetition of strong damage animations
	//  when a line of dudes is running towards you and you're mowing them down, etc.
	if( self.a.movement == "run" && !isAttackerWithinDist( attacker, 275 ) )
	{
		if( RandomInt( 100 ) < 65 )
		{
			return false;
		}
	}
	
	if ( isSniperRifle( damageWeapon ) && self.maxHealth < damageTaken )
	{
		return true;
	}
	
	if( isShotgun( damageWeapon ) && isAttackerWithinDist( attacker, 512 ) )
	{
		return true;
	}
	
	if( isDesertEagle( damageWeapon ) && isAttackerWithinDist( attacker, 425 ) )
	{
		return true;
	}
	
	return false;
}

isDesertEagle( damageWeapon )
{
	if( damageWeapon == "deserteagle" )
	{
		return true;
	}
	
	return false;
}

isAttackerWithinDist( attacker, maxDist )
{
	if( !IsDefined( attacker ) )
	{
		return false;
	}
	
	if( Distance( self.origin, attacker.origin ) > maxDist )
	{
		return false;
	}
	
	return true;
}

getDeathAnim()
{
	if ( shouldDoStrongBulletDamage( self.damageWeapon, self.damageMod, self.damagetaken, self.attacker ) )
	{
		deathAnim = getStrongBulletDamageDeathAnim();
		
		if ( IsDefined( deathAnim ) )
		{
			return deathAnim;
		}
	}

	if ( isdefined( self.a.onback ) )
	{
		if ( self.a.pose == "crouch" )
			return getBackDeathAnim();
		else
			animscripts\shared::stopOnBack();
	}

	if ( self.a.pose == "stand" )
	{
		if ( shouldDoRunningForwardDeath() )
		{
			return getRunningForwardDeathAnim();
		}
		else
		{
			return getStandDeathAnim();
		}
	}
	else if ( self.a.pose == "crouch" )
	{
		return getCrouchDeathAnim();
	}
	else if ( self.a.pose == "prone" )
	{
		return getProneDeathAnim();
	}
}


// may return undefined
// large death animation for shotguns, snipers etc.
getStrongBulletDamageDeathAnim()
{
	damageYaw = abs( self.damageYaw );

	if ( damageYaw < 45 )
		return;

	if ( damageYaw > 150 )
	{
		if ( damageLocationIsAny( "left_leg_upper", "left_leg_lower", "right_leg_upper", "right_leg_lower", "left_foot", "right_foot" ) )
		{
			deathArray = array( %death_shotgun_legs, %death_stand_sniper_leg );
		}
		else
		{				
			deathArray = [];
			
			if ( self.damageLocation == "torso_lower" )
			{
				deathArray[ deathArray.size ] = %death_shotgun_legs;
				deathArray[ deathArray.size ] = %death_stand_sniper_leg;
			}
			
			deathArray[ deathArray.size ] = %death_shotgun_back_v1;
			deathArray[ deathArray.size ] = %exposed_death_blowback;
			deathArray[ deathArray.size ] = %death_stand_sniper_chest1; 
			deathArray[ deathArray.size ] = %death_stand_sniper_chest2;
			deathArray[ deathArray.size ] = %death_stand_sniper_spin1;
		}

		//self.faceDamageDir = true;	
	}
	else if ( self.damageYaw < 0 )
	{
		deathArray = array( %death_shotgun_spinL, %death_stand_sniper_spin1, %death_stand_sniper_chest1, %death_stand_sniper_chest2 );
	}
	else
	{
		deathArray = array( %death_shotgun_spinR, %death_stand_sniper_spin2, %death_stand_sniper_chest1, %death_stand_sniper_chest2 );
	}

	return deathArray[ randomint( deathArray.size ) ];
}

getRunningForwardDeathAnim()
{
	deathArray = [];
	deathArray[ deathArray.size ] = tryAddDeathAnim( %run_death_facedown );
	deathArray[ deathArray.size ] = tryAddDeathAnim( %run_death_roll );
	deathArray[ deathArray.size ] = tryAddDeathAnim( %run_death_fallonback );
	deathArray[ deathArray.size ] = tryAddDeathAnim( %run_death_flop );

	deathArray = animscripts\pain::removeBlockedAnims( deathArray );

	if ( !deathArray.size )
		return getStandDeathAnim();

	return deathArray[ randomint( deathArray.size ) ];
}

// remove undefined entries from array
removeUndefined( array )
{
	newArray = [];
	for ( index = 0; index < array.size; index++ )
	{
		if ( !isDefined( array[ index ] ) )
			continue;

		newArray[ newArray.size ] = array[ index ];
	}
	return newArray;
}

getStandPistolDeathAnim()
{
	deathArray = [];
	
	if ( abs( self.damageYaw ) < 50 )
	{
		deathArray[ deathArray.size ] = %pistol_death_2;// falls forwards
	}
	else
	{
		if ( abs( self.damageYaw ) < 110 )
			deathArray[ deathArray.size ] = %pistol_death_2;// falls forwards

		if ( damageLocationIsAny( "torso_lower", "torso_upper", "left_leg_upper", "left_leg_lower", "right_leg_upper", "right_leg_lower" ) )
		{
			deathArray[ deathArray.size ] = %pistol_death_3;// hit in groin from front
			if ( !damageLocationIsAny( "torso_upper" ) )
				deathArray[ deathArray.size ] = %pistol_death_3;// ( twice as likely )
		}

		if ( !damageLocationIsAny( "head", "neck", "helmet", "left_foot", "right_foot", "left_hand", "right_hand", "gun" ) && randomint( 2 ) == 0 )
			deathArray[ deathArray.size ] = %pistol_death_4;// hit at top and falls backwards, but more dragged out

		if ( deathArray.size == 0 || damageLocationIsAny( "torso_lower", "torso_upper", "neck", "head", "helmet", "right_arm_upper", "left_arm_upper" ) )
			deathArray[ deathArray.size ] = %pistol_death_1;// falls backwards
	}
	
	return deathArray;
}

getStandDeathAnim()
{
	deathArray = [];
	extendedDeathArray = [];

	if ( usingSidearm() )
	{
		deathArray = getStandPistolDeathAnim();
	}
	else
	{
		// torso or legs
		if ( damageLocationIsAny( "torso_lower", "left_leg_upper", "left_leg_lower", "right_leg_lower", "right_leg_lower" ) )
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_groin );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_leg );
			extendedDeathArray[ extendedDeathArray.size ] = tryAddDeathAnim( %stand_death_crotch );
			extendedDeathArray[ extendedDeathArray.size ] = tryAddDeathAnim( %stand_death_guts );
		}
		
		if ( damageLocationIsAny( "head", "helmet" ) )
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_headshot );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_flop );
		}

		if ( damageLocationIsAny( "neck" ) )
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_neckgrab );
		}
		
		if ( damageLocationIsAny( "torso_upper", "left_arm_upper" ) )
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_twist );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_shoulder_spin );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_shoulderback );
		}	
		
		if ( damageLocationIsAny( "torso_upper" ) )
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_tumbleforward );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_stumbleforward );
			extendedDeathArray[ extendedDeathArray.size ] = tryAddDeathAnim( %stand_death_fallside ); 
		}			
		
		// quadrants
		if ( ( self.damageyaw > 135 ) || ( self.damageyaw <= -135 ) )// Front quadrant
		{
			if ( damageLocationIsAny( "neck", "head", "helmet" ) )
			{
				deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_face );
				deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_headshot_slowfall );
				extendedDeathArray[ extendedDeathArray.size ] = tryAddDeathAnim( %stand_death_head_straight_back );
			}

			if ( damageLocationIsAny( "torso_upper" ) )
			{
				deathArray[ deathArray.size ] = tryAddDeathAnim( %stand_death_tumbleback );   
				extendedDeathArray[ extendedDeathArray.size ] = tryAddDeathAnim( %stand_death_chest_stunned );
			}
		}
		//else if ( ( self.damageyaw > 45 ) && ( self.damageyaw <= 135 ) )// Right quadrant
		//{
		//}
		else if ( ( self.damageyaw > -45 ) && ( self.damageyaw <= 45 ) )// Back quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_falltoknees );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_falltoknees_02 );
		}
		//else// Left quadrant
		//{
		//}
		
		foundLocDamageDeath = ( deathArray.size > 0 );
		
		if ( !foundLocDamageDeath || RandomInt( 100 ) < 15 )
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_02 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_death_nerve );
		}
		
		if ( RandomInt( 100 ) < 10 && firingDeathAllowed() )
		{
			deathArray[ deathArray.size ] = tryAddFiringDeathAnim( %exposed_death_firing_02 );
			deathArray[ deathArray.size ] = tryAddFiringDeathAnim( %exposed_death_firing );
			deathArray = removeUndefined( deathArray );
		}

	}

	assertex( deathArray.size > 0, deathArray.size );
	if ( deathArray.size == 0 )
		deathArray[ deathArray.size ] = %exposed_death;

	if ( !self.a.disableLongDeath && self.stairsState == "none" && !isdefined( self.a.painOnStairs ) )
	{
		index = randomint( deathArray.size + extendedDeathArray.size );
		if ( index < deathArray.size )
			return deathArray[ index ];
		else
			return extendedDeathArray[ index - deathArray.size ];
	}

	assertex( deathArray.size > 0, deathArray.size );
	return deathArray[ randomint( deathArray.size ) ];
}


getCrouchDeathAnim()
{
	deathArray = [];

	if ( damageLocationIsAny( "head", "neck" ) )	// Front / Left quadrant
		deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_crouch_death_fetal );

	if ( damageLocationIsAny( "torso_upper", "torso_lower", "left_arm_upper", "right_arm_upper", "neck" ) )
		deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_crouch_death_flip );

	if ( deathArray.size < 2 )
		deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_crouch_death_twist );
	if ( deathArray.size < 2 )
		deathArray[ deathArray.size ] = tryAddDeathAnim( %exposed_crouch_death_flip );

	assertex( deathArray.size > 0, deathArray.size );
	return deathArray[ randomint( deathArray.size ) ];
}


getProneDeathAnim()
{
	if ( isdefined( self.a.proneAiming ) )
		return %prone_death_quickdeath;
	else
		return %dying_crawl_death_v1;
}

getBackDeathAnim()
{
	deathArray = array( %dying_back_death_v1, %dying_back_death_v2, %dying_back_death_v3, %dying_back_death_v4 );
	return deathArray[ randomint( deathArray.size ) ];
}

firingDeathAllowed()
{
	if ( !isdefined( self.weapon ) || !usingRifleLikeWeapon() || !weaponIsAuto( self.weapon ) || self.dieQuietly )
		return false;
	
	if ( self.a.weaponPos[ "right" ] == "none" )
		return false;
		
	return true;
}

tryAddDeathAnim( animName )
{
	assert( !animHasNoteTrack( animName, "fire" ) && !animHasNoteTrack( animName, "fire_spray" ) );
	return animName;
}

tryAddFiringDeathAnim( animName )
{
	assert( animHasNoteTrack( animName, "fire" ) || animHasNoteTrack( animName, "fire_spray" ) );
	return animName;
}

playExplodeDeathAnim()
{
	if ( isdefined( self.juggernaut ) )
		return false;
		
	if ( self.damageLocation != "none" )
		return false;

	deathArray = [];

	if ( self.a.movement != "run" )
	{
		if ( ( self.damageyaw > 135 ) || ( self.damageyaw <= -135 ) )	// Front quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_B_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_B_v2 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_B_v3 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_B_v4 );
		}
		else if ( ( self.damageyaw > 45 ) && ( self.damageyaw <= 135 ) )		// Right quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_L_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_L_v2 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_L_v3 );
		}
		else if ( ( self.damageyaw > - 45 ) && ( self.damageyaw <= 45 ) )		// Back quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_F_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_F_v2 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_F_v3 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_F_v4 );
		}
		else
		{															// Left quadrant
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_R_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_stand_R_v2 );
		}
	}
	else
	{
		if ( ( self.damageyaw > 135 ) || ( self.damageyaw <= -135 ) )	// Front quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_B_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_B_v2 );
		}
		else if ( ( self.damageyaw > 45 ) && ( self.damageyaw <= 135 ) )		// Right quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_L_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_L_v2 );
		}
		else if ( ( self.damageyaw > - 45 ) && ( self.damageyaw <= 45 ) )		// Back quadrant
		{
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_F_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_F_v2 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_F_v3 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_F_v4 );
		}
		else
		{															// Left quadrant
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_R_v1 );
			deathArray[ deathArray.size ] = tryAddDeathAnim( %death_explosion_run_R_v2 );
		}
	}

	deathAnim = deathArray[ randomint( deathArray.size ) ];

	if ( getdvar( "scr_expDeathMayMoveCheck", "on" ) == "on" )
	{
		localDeltaVector = getMoveDelta( deathAnim, 0, 1 );
		endPoint = self localToWorldCoords( localDeltaVector );

		if ( !self mayMoveToPoint( endPoint, false ) )
			return false;
	}

	// this should really be in the notetracks
	self animMode( "nogravity" );

	playDeathAnim( deathAnim );
	return true;
}

