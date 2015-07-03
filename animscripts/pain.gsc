#include animscripts\Utility;
#include animscripts\weaponList;
#include common_scripts\utility;
#include animscripts\Combat_Utility;
#using_animtree( "generic_human" );

main()
{
	if ( isdefined( self.longDeathStarting ) )
	{
		// important that we don't run any other animscripts.
		self waittill( "killanimscript" );
		return;
	}

	if ( [[ anim.pain_test ]]() )
		return;
	if ( self.a.disablePain )
		return;

	self notify( "kill_long_death" );

	if ( isdefined( self.a.painTime ) )
		self.a.lastPainTime = self.a.painTime;
	else
		self.a.lastPainTime = 0;
		
	self.a.painTime = gettime();
	if ( self.stairsState != "none" )
		self.a.painOnStairs = true;
	else
		self.a.painOnStairs = undefined;

	if ( self.a.nextStandingHitDying )
		self.health = 1;

	dead = false;
	stumble = false;

	ratio = self.health / self.maxHealth;

//	println ("hit at " + self.damagelocation);

    self notify( "anim entered pain" );
	self endon( "killanimscript" );

	// Two pain animations are played.  One is a longer, detailed animation with little to do with the actual 
	// location and direction of the shot, but depends on what pose the character starts in.  The other is a 
	// "hit" animation that is very location-specific, but is just a single pose for the affected bones so it 
	// can be played easily whichever position the character is in.
    animscripts\utility::initialize( "pain" );

    self animmode( "gravity" );

	//thread [[anim.println]] ("Shot in "+self.damageLocation+" from "+self.damageYaw+" for "+self.damageTaken+" hit points");#/

	if ( !isdefined( self.no_pain_sound ) )
		self animscripts\face::SayGenericDialogue( "pain" );

	if ( self.damageLocation == "helmet" )
		self animscripts\death::helmetPop();
	else if ( self wasDamagedByExplosive() && randomint( 2 ) == 0 )
		self animscripts\death::helmetPop();

	if ( isdefined( self.painFunction ) )
	{
		self [[ self.painFunction ]]();
		return;
	}

	// corner grenade death takes priority over crawling pain
	/#
	if ( getDvarInt( "scr_forceCornerGrenadeDeath" ) == 1 )
	{
		if ( self TryCornerRightGrenadeDeath() )
			return;
	}
	#/
	if ( crawlingPain() )
		return;

	if ( specialPain( self.a.special ) )
		return;
		
	// if we didn't handle self.a.special, we can't rely on it being accurate after the pain animation we're about to play.
	//self.a.special = "none";
	//self.specialDeathFunc = undefined;

	painAnim = getPainAnim();

	 /#
	if ( getdvarint( "scr_paindebug" ) == 1 )
		println( "^2Playing pain: ", painAnim, " ; pose is ", self.a.pose );
	#/

	playPainAnim( painAnim );
}

initPainFx()
{
	level._effect[ "crawling_death_blood_smear" ] = LoadFX( "impacts/blood_smear_decal" );
}

end_script()
{
	if ( isdefined( self.damageShieldPain ) )
	{
		self.damageShieldCounter = undefined;
		self.damageShieldPain = undefined;
		self.allowpain = true;
		
		// still somewhat risky
		if ( !isdefined( self.preDamageShieldIgnoreMe ) )
			self.ignoreme = false;
			
		self.preDamageShieldIgnoreMe = undefined;
	}
	
	if ( isdefined( self.blockingPain ) )
	{
		self.blockingPain = undefined;
		self.allowPain = true;
	}
}

wasDamagedByExplosive()
{
	if ( isExplosiveDamageMOD( self.damageMod ) )
		return true;

	if ( gettime() - anim.lastCarExplosionTime <= 50 )
	{
		rangesq = anim.lastCarExplosionRange * anim.lastCarExplosionRange * 1.2 * 1.2;
		if ( distanceSquared( self.origin, anim.lastCarExplosionDamageLocation ) < rangesq )
		{
			// assume this exploding car damaged us.
			upwardsDeathRangeSq = rangesq * 0.5 * 0.5;
			self.mayDoUpwardsDeath = ( distanceSquared( self.origin, anim.lastCarExplosionLocation ) < upwardsDeathRangeSq );
			return true;
		}
	}

	return false;
}


maxDamageShieldPainInterval = 1500;

getDamageShieldPainAnim()
{
	if ( self.a.pose == "prone" )
		return;
		
	if ( isdefined( self.lastAttacker ) && isdefined( self.lastAttacker.team ) && self.lastAttacker.team == self.team )
		return;
	
	if ( !isdefined( self.damageShieldCounter ) || ( gettime() - self.a.lastPainTime ) > maxDamageShieldPainInterval )
		self.damageShieldCounter = randomintrange( 2, 3 );

	if ( isdefined( self.lastAttacker ) && distanceSquared( self.origin, self.lastAttacker.origin ) < squared( 512 ) )
		self.damageShieldCounter = 0;
		
	if ( self.damageShieldCounter > 0 )
	{
		self.damageShieldCounter--;
		return;
	}
		
	self.damageShieldPain = true;
	self.allowpain = false;

	if ( self.ignoreme )
		self.preDamageShieldIgnoreMe = true;
	else
		self.ignoreme = true;

	if ( usingSidearm() )
		animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );

	if ( self.a.pose == "crouch" )
		return %exposed_crouch_extendedpainA;

	painArray = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	return painArray[ randomint( painArray.size ) ];
}

MAX_RUNNING_PAIN_DIST_SQ = ( 64 * 64 );

getPainAnim()
{
	if ( self.damageShield && !isdefined( self.disableDamageShieldPain ) )
	{
		painAnim = getDamageShieldPainAnim();
		if ( isdefined( painAnim ) )
			return painAnim;
	}
	
	if ( isdefined( self.a.onback ) )
	{
		if ( self.a.pose == "crouch" )
			return %back_pain;	
		else
			animscripts\shared::stopOnBack();
	}
	
	if ( self.a.pose == "stand" )
	{
		closeToNode = isdefined( self.node ) && ( distanceSquared( self.origin, self.node.origin ) < MAX_RUNNING_PAIN_DIST_SQ );

		if ( !closeToNode && self.a.movement == "run" && ( abs( self getMotionAngle() ) < 60 ) )
			return getRunningForwardPainAnim();

		self.a.movement = "stop";
		return getStandPainAnim();
	}
	else if ( self.a.pose == "crouch" )
	{
		self.a.movement = "stop";
		return getCrouchPainAnim();
	}
	else if ( self.a.pose == "prone" )
	{
		self.a.movement = "stop";
		return getPronePainAnim();
	}
}

RUN_PAIN_SHORT = 120; // actual animations are 150 but let it run against the wall a bit.
RUN_PAIN_MED = 200;
RUN_PAIN_LONG = 300;

getRunningForwardPainAnim()
{
	// 200 units
	runPains = [];
	
	allowMedPain = false;
	allowLongPain = false;
	allowShortPain = false;
	
	if ( self mayMoveToPoint( self localToWorldCoords( ( RUN_PAIN_LONG, 0, 0 ) ) ) )
	{
		allowLongPain = true;
		allowMedPain = true;
	}
	else if ( self mayMoveToPoint( self localToWorldCoords( ( RUN_PAIN_MED, 0, 0 ) ) ) )
	{
		allowMedPain = true;
	}

	if ( allowLongPain )
	{
		runPains[ runPains.size ] = %run_pain_leg;
		runPains[ runPains.size ] = %run_pain_shoulder;
		runPains[ runPains.size ] = %run_pain_stomach_stumble;
		runPains[ runPains.size ] = %run_pain_head;
	}
	
	// randomize medium with long pains
	if ( allowMedPain )
	{
		runPains[ runPains.size ] = %run_pain_fallonknee_02;
		runPains[ runPains.size ] = %run_pain_stomach;
		runPains[ runPains.size ] = %run_pain_stumble;
		runPains[ runPains.size ] = %run_pain_stomach_fast;
		runPains[ runPains.size ] = %run_pain_leg_fast;
		runPains[ runPains.size ] = %run_pain_fall;
	}
	// short pains are a back up only
	else if ( self mayMoveToPoint( self localToWorldCoords( ( RUN_PAIN_SHORT, 0, 0 ) ) ) )
	{
		// drop check
		runPains[ runPains.size ] = %run_pain_fallonknee;
		runPains[ runPains.size ] = %run_pain_fallonknee_03;
	}
	
	if ( !runPains.size )
	{
		self.a.movement = "stop";
		return getStandPainAnim();
	}

	return runPains[ randomint( runPains.size ) ];
}

getStandPistolPainAnim()
{
	painArray = [];

	if ( self damageLocationIsAny( "torso_upper", "torso_lower", "left_arm_upper", "right_arm_upper", "neck" ) )
		painArray[ painArray.size ] = %pistol_stand_pain_chest;
	if ( self damageLocationIsAny( "torso_lower", "left_leg_upper", "right_leg_upper" ) )
		painArray[ painArray.size ] = %pistol_stand_pain_groin;
	if ( self damageLocationIsAny( "head", "neck" ) )
		painArray[ painArray.size ] = %pistol_stand_pain_head;
	if ( self damageLocationIsAny( "left_arm_lower", "left_arm_upper", "torso_upper" ) )
		painArray[ painArray.size ] = %pistol_stand_pain_leftshoulder;
	if ( self damageLocationIsAny( "right_arm_lower", "right_arm_upper", "torso_upper" ) )
		painArray[ painArray.size ] = %pistol_stand_pain_rightshoulder;

	if ( painArray.size < 2 )
		painArray[ painArray.size ] = %pistol_stand_pain_chest;
	if ( painArray.size < 2 )
		painArray[ painArray.size ] = %pistol_stand_pain_groin;

	assertex( painArray.size > 0, painArray.size );
	return painArray[ randomint( painArray.size ) ];
}
		
		
getStandPainAnim()
{
	if ( usingSideArm() )
		return getStandPistolPainAnim();

	painArray = [];
	extendedPainArray = [];

	if ( self damageLocationIsAny( "torso_upper", "torso_lower" ) )
	{
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_gut;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_stomach;
	}

	if ( self damageLocationIsAny( "torso_upper", "head", "helmet", "neck" ) )
	{
		painArray[ painArray.size ] = %exposed_pain_face;
		painArray[ painArray.size ] = %stand_exposed_extendedpain_neck;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_head_2_crouch;
	}
	
	if ( self damageLocationIsAny( "right_arm_upper", "right_arm_lower" ) )
		painArray[ painArray.size ] = %exposed_pain_right_arm;
	
	if ( self damageLocationIsAny( "left_arm_lower", "left_arm_upper" ) )
	{
		painArray[ painArray.size ] = %stand_exposed_extendedpain_shoulderswing;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_shoulder_2_crouch;
	}

	if ( self damageLocationIsAny( "torso_lower", "left_leg_upper", "right_leg_upper" ) )
	{
		painArray[ painArray.size ] = %exposed_pain_groin;
		painArray[ painArray.size ] = %stand_exposed_extendedpain_hip;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_hip_2_crouch;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_feet_2_crouch;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_stomach;
	}
	
	if ( self damageLocationIsAny( "left_foot", "right_foot", "left_leg_lower", "right_leg_lower" ) )
	{
		painArray[ painArray.size ] = %stand_exposed_extendedpain_thigh;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_feet_2_crouch;
	}
	
	// default, only exposed pain that takes the AI to ground. Other ones look a bit awkward for getting hit by a bullet
	if ( painArray.size < 2 )
	{
		if ( !self.a.disableLongDeath )
		{
			painArray[ painArray.size ] = %exposed_pain_2_crouch;
			painArray[ painArray.size ] = %stand_extendedpainB;
		}
		else
		{
			painArray[ painArray.size ] = %exposed_pain_right_arm;
			painArray[ painArray.size ] = %exposed_pain_face;
			painArray[ painArray.size ] = %exposed_pain_groin;
		}
	}
	
	if ( extendedPainArray.size < 2 )
	{
		extendedPainArray[ extendedPainArray.size ] = %stand_extendedpainC;
		extendedPainArray[ extendedPainArray.size ] = %stand_exposed_extendedpain_chest;
	}	

	if ( !self.damageShield && !self.a.disableLongDeath )
	{
		index = randomint( painArray.size + extendedPainArray.size );
		if ( index < painArray.size )
			return painArray[index];
		else
			return extendedPainArray[ index - painArray.size ];
	}

	assertex( painArray.size > 0, painArray.size );
	return painArray[ randomint( painArray.size ) ];
}


removeBlockedAnims( array )
{
	newArray = [];
	for ( index = 0; index < array.size; index++ )
	{
		painAnim = array[ index ];
		time = 1;
		if ( animHasNoteTrack( painAnim, "code_move" ) )
			time = getNotetrackTimes( painAnim, "code_move" )[0];
	
		localDeltaVector = getMoveDelta( painAnim, 0, time );
		endPoint = self localToWorldCoords( localDeltaVector );

		if ( self mayMoveToPoint( endPoint, true, true ) )
			newArray[ newArray.size ] = painAnim;
	}
	return newArray;
}

getCrouchPainAnim()
{
	painArray = [];

	if ( !self.damageShield && !self.a.disableLongDeath )
		painArray[ painArray.size ] = %exposed_crouch_extendedpainA;
		
	painArray[ painArray.size ] = %exposed_crouch_pain_chest;
	painArray[ painArray.size ] = %exposed_crouch_pain_headsnap;
	painArray[ painArray.size ] = %exposed_crouch_pain_flinch;

	if ( damageLocationIsAny( "left_hand", "left_arm_lower", "left_arm_upper" ) )
		painArray[ painArray.size ] = %exposed_crouch_pain_left_arm;
	if ( damageLocationIsAny( "right_hand", "right_arm_lower", "right_arm_upper" ) )
		painArray[ painArray.size ] = %exposed_crouch_pain_right_arm;

	assertex( painArray.size > 0, painArray.size );
	return painArray[ randomint( painArray.size ) ];
}

getPronePainAnim()
{
	if ( randomint( 2 ) == 0 )
		return %prone_reaction_A;
	else
		return %prone_reaction_B;
}


playPainAnim( painAnim )
{
	// TEMP make all pain faster
	// rate = 1.5;
	rate = 1;

	self setFlaggedAnimKnobAllRestart( "painanim", painAnim, %body, 1, .1, rate );

	if ( self.a.pose == "prone" )
		self UpdateProne( %prone_legs_up, %prone_legs_down, 1, 0.1, 1 );

	if ( animHasNotetrack( painAnim, "start_aim" ) )
	{
		self thread notifyStartAim( "painanim" );
		self endon( "start_aim" );
	}

	if ( animHasNotetrack( painAnim, "code_move" ) )
		self animscripts\shared::DoNoteTracks( "painanim" );

	self animscripts\shared::DoNoteTracks( "painanim" );
}

notifyStartAim( animFlag )
{
	self endon( "killanimscript" );
	self waittillmatch( animFlag, "start_aim" );
	self notify( "start_aim" );
}


specialPainBlocker()
{
	self endon( "killanimscript" );
	
	assert( self.allowPain );
	
	self.blockingPain = true;
	self.allowPain = false;

	wait 0.5;

	self.blockingPain = undefined;
	self.allowPain = true;
}

// Special pain is for corners, rambo behavior, mg42's, anything out of the ordinary stand, crouch and prone.  
// It returns true if it handles the pain for the special animation state, or false if it wants the regular 
// pain function to handle it.
specialPain( anim_special )
{
	if ( anim_special == "none" )
		return false;
		
	self.a.special = "none";
	
	self thread specialPainBlocker();

	switch( anim_special )
	{
	case "cover_left":
		if ( self.a.pose == "stand" )
		{
			painArray = [];
			painArray[ painArray.size ] = %corner_standl_painB;// groin hit
			painArray[ painArray.size ] = %corner_standl_painC;// chest hit
			painArray[ painArray.size ] = %corner_standl_painD;// left leg hit
			painArray[ painArray.size ] = %corner_standl_painE;// right leg hit
			DoPainFromArray( painArray );
			handled = true;
		}
		else if ( self.a.pose == "crouch" )
		{
			painArray = [];
			painArray[ painArray.size ] = %CornerCrL_painB;
			DoPainFromArray( painArray );
			handled = true;
		}
		else
		{
			handled = false;
		}
		break;
	case "cover_right":
		if ( self.a.pose == "stand" )
		{
			painArray = [];
			painArray[ 0 ] = %corner_standr_pain;
			painArray[ 1 ] = %corner_standr_painB;
			painArray[ 2 ] = %corner_standr_painC;
			DoPainFromArray( painArray );
			handled = true;
		}
		else if ( self.a.pose == "crouch" )
		{
			painArray = [];
			painArray[ painArray.size ] = %CornerCrR_alert_painA;
			painArray[ painArray.size ] = %CornerCrR_alert_painC;
			DoPainFromArray( painArray );
			handled = true;
		}		
		else
		{
			handled = false;
		}
		break;
		
	case "cover_right_stand_A":
		//DoPain( %corner_standR_pain_A_2_alert );
		handled = false;
		break;
		
	case "cover_right_stand_B":
		DoPain( %corner_standR_pain_B_2_alert );
		handled = true;
		break;

	case "cover_left_stand_A":
		DoPain( %corner_standL_pain_A_2_alert );
		handled = true;
		break;

	case "cover_left_stand_B":
		DoPain( %corner_standL_pain_B_2_alert );
		handled = true;
		break;

	/*
	// these are just exposed crouch poses
	case "cover_right_crouch_A":
	case "cover_right_crouch_B":
	case "cover_left_crouch_A":
	case "cover_left_crouch_B":
		handled = false;
		break;
	*/

	case "cover_crouch":
		painArray = [];
		painArray[painArray.size] = %covercrouch_pain_right;
		painArray[painArray.size] = %covercrouch_pain_front;
		painArray[painArray.size] = %covercrouch_pain_left_3;
		DoPainFromArray(painArray);
		handled = true;
		break;
		
	case "cover_stand":
		painArray = [];
		painArray[ painArray.size ] = %coverstand_pain_groin;
		painArray[ painArray.size ] = %coverstand_pain_leg;
		DoPainFromArray( painArray );
		handled = true;
		break;
		
	case "cover_stand_aim":
		painArray = [];
		painArray[ painArray.size ] = %coverstand_pain_aim_2_hide_01;
		painArray[ painArray.size ] = %coverstand_pain_aim_2_hide_02;
		DoPainFromArray( painArray );
		handled = true;
		break;
		
	case "cover_crouch_aim":
		DoPain( %covercrouch_pain_aim_2_hide_01 );
		handled = true;
		break;		
		
	case "saw":
		if ( self.a.pose == "stand" )
			painAnim = %saw_gunner_pain;
		else if ( self.a.pose == "crouch" )
			painAnim = %saw_gunner_lowwall_pain_02;
		else
			painAnim = %saw_gunner_prone_pain;

		self setflaggedanimknob( "painanim", painAnim, 1, .3, 1 );
		self animscripts\shared::DoNoteTracks( "painanim" );
		handled = true;
		break;
	case "mg42":
		mg42pain( self.a.pose );
		handled = true;
		break;
	case "minigun":
		handled = false;
		break;
	case "corner_right_martyrdom":
		handled = ( self TryCornerRightGrenadeDeath() );
		break;
	case "rambo_left":
	case "rambo_right":
	case "rambo":
	case "dying_crawl":
		handled = false;
		break;
	default:
		println( "Unexpected anim_special value : " + anim_special + " in specialPain." );
		handled = false;
	}
	return handled;
}

painDeathNotify()
{
	self endon( "death" );

	// it isn't safe to notify "pain_death" from the start of an animscript.
	// this can cause level script to run, which might cause things with this AI to change while the animscript is starting
	// and this can screw things up in unexpected ways.
	// take my word for it.
	wait .05;
	self notify( "pain_death" );
}

DoPainFromArray( painArray )
{
	painAnim = painArray[ randomint( painArray.size ) ];

	self setflaggedanimknob( "painanim", painAnim, 1, .3, 1 );
	self animscripts\shared::DoNoteTracks( "painanim" );
}

DoPain( painAnim )
{
	self setflaggedanimknob( "painanim", painAnim, 1, .3, 1 );
	self animscripts\shared::DoNoteTracks( "painanim" );
}

mg42pain( pose )
{
//		assertmsg("mg42 pain anims not implemented yet");//scripted_mg42gunner_pain

	 /#
	assertEx( isdefined( level.mg_animmg ), "You're missing maps\\_mganim::main();  Add it to your level." );
	{
		println( "	maps\\_mganim::main();" );
		return;
	}
	#/

	self setflaggedanimknob( "painanim", level.mg_animmg[ "pain_" + pose ], 1, .1, 1 );
	self animscripts\shared::DoNoteTracks( "painanim" );
}


// This is to stop guys from taking off running if they're interrupted during pain.  This used to happen when 
// guys were running when they entered pain, but didn't play a special running pain (eg because they were 
// running sideways).  It resulted in a running pain or death being played when they were shot again.
waitSetStop( timetowait, killmestring )
{
	self endon( "killanimscript" );
	self endon( "death" );
	if ( isDefined( killmestring ) )
		self endon( killmestring );
	wait timetowait;

	self.a.movement = "stop";
}

maxCrawlPainHealth = 100;

crawlingPain()
{
	if ( self.a.disableLongDeath || self.dieQuietly || self.damageShield )
		return false;
		
	if ( self.stairsState != "none" )
		return false;

	if ( isdefined( self.a.onback ) )
		return false;

	/# 
	if ( getDvarInt( "scr_forceCrawl" ) == 1 )
		self.forceLongDeath = 1;
	#/

	if ( isdefined( self.forceLongDeath ) )
	{
		self.health = 10;
		self thread crawlingPistol();

		self waittill( "killanimscript" );
		return true;
	}
	
	transAnims[ "prone" ] = array( %dying_crawl_2_back );
	transAnims[ "stand" ] = array( %dying_stand_2_back_v1, %dying_stand_2_back_v2 );
	transAnims[ "crouch" ] = array( %dying_crouch_2_back );
	self.a.crawlingPainTransAnim = transAnims[self.a.pose][ randomint( transAnims[self.a.pose].size ) ];
	
	if ( !isCrawlDeltaAllowed( self.a.crawlingPainTransAnim ) )
		return false;
	
	if ( self.health > maxCrawlPainHealth )
		return false;

	legHit = self damageLocationIsAny( "left_leg_upper", "left_leg_lower", "right_leg_upper", "right_leg_lower", "left_foot", "right_foot" );
	
	if ( legHit && self.health < self.maxhealth * .4 )
	{
		if ( gettime() < anim.nextCrawlingPainTimeFromLegDamage )
			return false;
	}
	else
	{
		if ( anim.numDeathsUntilCrawlingPain > 0 )
			return false;
		if ( gettime() < anim.nextCrawlingPainTime )
			return false;
	}

	/*if ( self.a.movement != "stop" )
		return false;*/

	if ( isDefined( self.deathFunction ) )
		return false;

	foreach ( player in level.players )
	{
		if ( distance( self.origin, player.origin ) < 175 )
			return false;
	}

	if ( self damageLocationIsAny( "head", "helmet", "gun", "right_hand", "left_hand" ) )
		return false;

	if ( usingSidearm() )
		return false;
	
	// we'll wait a bit to see if this crawling pain will really succeed.
	// in the meantime, don't start any other ones.
	anim.nextCrawlingPainTime = gettime() + 3000;
	anim.nextCrawlingPainTimeFromLegDamage = gettime() + 3000;

	// needs to be threaded
	self thread crawlingPistol();

	self waittill( "killanimscript" );
	return true;
}

isCrawlDeltaAllowed( theanim )
{
	if ( isdefined( self.a.force_num_crawls ) )
		return true;
		
	delta = getMoveDelta( theanim, 0, 1 );
	endPoint = self localToWorldCoords( delta );

	return self mayMoveToPoint( endPoint );
}

initCrawlingPistolAnims()
{
	self.a.array = [];
	self.a.array[ "stand_2_crawl" ] = array( %dying_stand_2_crawl_v1, %dying_stand_2_crawl_v2, %dying_stand_2_crawl_v3 );
	self.a.array[ "crouch_2_crawl" ] = array( %dying_crouch_2_crawl );

	self.a.array[ "crawl" ] = %dying_crawl;

	self.a.array[ "death" ] = array( %dying_crawl_death_v1, %dying_crawl_death_v2 );

	self.a.array[ "back_idle" ] = %dying_back_idle;
	self.a.array[ "back_idle_twitch" ] = array( %dying_back_twitch_A, %dying_back_twitch_B );
	self.a.array[ "back_crawl" ] = %dying_crawl_back;
	self.a.array[ "back_fire" ] = %dying_back_fire;

	self.a.array[ "back_death" ] = array( %dying_back_death_v1, %dying_back_death_v2, %dying_back_death_v3 );
	
	if ( isdefined( self.crawlingPainAnimOverrideFunc ) )
		[[ self.crawlingPainAnimOverrideFunc ]]();
}

crawlingPistol()
{
	// don't end on killanimscript. pain.gsc will abort if self.crawlingPistolStarting is true.
	self endon( "kill_long_death" );
	self endon( "death" );

	initCrawlingPistolAnims();

	self thread preventPainForAShortTime( "crawling" );

	self.a.special = "none";
	self.specialDeathFunc = undefined;

	self thread painDeathNotify();
	//notify ac130 missions that a guy is crawling so context sensative dialog can be played
	level notify( "ai_crawling", self );

	self thread crawling_stab_achievement();

	self setAnimKnobAll( %dying, %body, 1, 0.1, 1 );

	// dyingCrawl() returns false if we die without turning around
	if ( !self dyingCrawl() )
		return;
	
	self setFlaggedAnimKnob( "transition", self.a.crawlingPainTransAnim, 1, 0.5, 1 );
	self animscripts\shared::DoNoteTracksIntercept( "transition", ::handleBackCrawlNotetracks );
	assert( isdefined( self.a.onback ) );
	
	self.a.special = "dying_crawl";

	self thread dyingCrawlBackAim();
	
	if ( isdefined( self.enemy ) )
		self setLookAtEntity( self.enemy );

	decideNumCrawls();
	while ( shouldKeepCrawling() )
	{
		crawlAnim = animArray( "back_crawl" );
		if ( !self isCrawlDeltaAllowed( crawlAnim ) )
			break;
		
		self setFlaggedAnimKnobRestart( "back_crawl", crawlAnim, 1, 0.1, 1.0 );
		self animscripts\shared::DoNoteTracksIntercept( "back_crawl", ::handleBackCrawlNotetracks );
	}

	self.desiredTimeOfDeath = gettime() + randomintrange( 4000, 20000 );
	while ( shouldStayAlive() )
	{
		if ( self canSeeEnemy() && self aimedSomewhatAtEnemy() )
		{
			backAnim = animArray( "back_fire" );

			self setFlaggedAnimKnobRestart( "back_idle_or_fire", backAnim, 1, 0.2, 1.0 );
			self animscripts\shared::DoNoteTracks( "back_idle_or_fire" );
		}
		else
		{
			backAnim = animArray( "back_idle" );
			if ( randomfloat( 1 ) < .4 )
				backAnim = animArrayPickRandom( "back_idle_twitch" );

			self setFlaggedAnimKnobRestart( "back_idle_or_fire", backAnim, 1, 0.1, 1.0 );

			timeRemaining = getAnimLength( backAnim );
			while ( timeRemaining > 0 )
			{
				if ( self canSeeEnemy() && self aimedSomewhatAtEnemy() )
					break;

				interval = 0.5;
				if ( interval > timeRemaining )
				{
					interval = timeRemaining;
					timeRemaining = 0;
				}
				else
				{
					timeRemaining -= interval;
				}
				self animscripts\shared::DoNoteTracksForTime( interval, "back_idle_or_fire" );
			}
		}
	}

	self notify( "end_dying_crawl_back_aim" );
	self clearAnim( %dying_back_aim_4_wrapper, .3 );
	self clearAnim( %dying_back_aim_6_wrapper, .3 );

	self.deathanim = animArrayPickRandom( "back_death" );
	self killWrapper();

	self.a.special = "none";
	self.specialDeathFunc = undefined;
}

crawling_stab_achievement()
{
	if ( self.team == "allies" )
		return;
	self endon( "end_dying_crawl_back_aim" );
	self waittill( "death", attacker, type );
	if ( !isdefined( self ) || !isdefined( attacker ) || !isplayer( attacker ) )
		return;
//	if ( type == "MOD_MELEE" )
//		maps\_utility::giveachievement_wrapper( "NO_REST_FOR_THE_WEARY" );
}

shouldStayAlive()
{
	if ( !enemyIsInGeneralDirection( anglesToForward( self.angles ) ) )
		return false;

	return gettime() < self.desiredTimeOfDeath;
}

dyingCrawl()
{
	if( !isdefined( self.forceLongDeath ) )
	{
		if ( self.a.pose == "prone" )
			return true;
	
		if ( self.a.movement == "stop" )
		{
			if ( randomfloat( 1 ) < .4 ) // chance of randomness
			{
				if ( randomfloat( 1 ) < .5 )
					return true;
			}
			else
			{
				// if hit from front, return true
				if ( abs( self.damageYaw ) > 90 )
					return true;
			}
		}
		else
		{
			// if we're not stopped, we want to fall in the direction of movement
			// so return true if moving backwards
			if ( abs( self getMotionAngle() ) > 90 )
				return true;
		}
	}
	
	if ( self.a.pose != "prone" )
	{
		fallAnim = animArrayPickRandom( self.a.pose + "_2_crawl" );
		
		if ( !self isCrawlDeltaAllowed( fallAnim ) )
			return true;
		
		self thread dyingCrawlBloodSmear();

		self setFlaggedAnimKnob( "falling", fallAnim, 1, 0.5, 1 );
		self animscripts\shared::DoNoteTracks( "falling" );
		assert( self.a.pose == "prone" );
	}
	else
	{
		self thread dyingCrawlBloodSmear();
	}

	self.a.crawlingPainTransAnim = %dying_crawl_2_back;
	
	self.a.special = "dying_crawl";

	decideNumCrawls();
	while ( shouldKeepCrawling() )
	{
		crawlAnim = animArray( "crawl" );
		
		if ( !self isCrawlDeltaAllowed( crawlAnim ) )
			return true;
		
		if ( isdefined( self.custom_crawl_sound ) )
		{
			self playsound( self.custom_crawl_sound );
		}
		
		self setFlaggedAnimKnobRestart( "crawling", crawlAnim, 1, 0.1, 1.0 );
		self animscripts\shared::DoNoteTracks( "crawling" );
	}
	
	self notify( "done_crawling" );

	// check if target is in cone to shoot
	if ( !isdefined( self.forceLongDeath ) && enemyIsInGeneralDirection( anglesToForward( self.angles ) * - 1 ) )
		return true;
			
	deathanim = animArrayPickRandom( "death" );

	// this particular death animation is long enough that we want it to be interruptible
	if( deathanim != %dying_crawl_death_v2 )
	{
		// all the others are short so we don't want them to be interruptible
		self.a.nodeath = true;
	}

	animscripts\death::playDeathAnim( deathanim );
	self killWrapper();

	self.a.special = "none";
	self.specialDeathFunc = undefined;

	return false;
}

dyingCrawlBloodSmear()
{
	self endon( "death" );

	if ( self.a.pose != "prone" )
	{
		while( 1 )
		{
			self waittill( "falling", note );
			
			if ( IsSubStr( note, "bodyfall" ) )
				break;
		}
	}
	
	origintag = "J_SpineLower";
	angletag = "tag_origin";
	
	fx_rate = .25;
	fx = level._effect[ "crawling_death_blood_smear" ];
	
	if ( isdefined( self.a.crawl_fx_rate ) )
		fx_rate = self.a.crawl_fx_rate;
	if( isdefined( self.a.crawl_fx ) )
		fx = level._effect[ self.a.crawl_fx ];
	
	while( fx_rate )
	{
		org = self gettagorigin( origintag );
		angles = self GetTagAngles( angletag );
		forward = anglestoright( angles );
		up = anglestoforward( ( 270, 0, 0 ) );
		
		playfx( fx, org, up, forward );
		
		wait( fx_rate );
	}
}

dyingCrawlBackAim()
{
	self endon( "kill_long_death" );
	self endon( "death" );
	self endon( "end_dying_crawl_back_aim" );

	if ( isdefined( self.dyingCrawlAiming ) )
		return;
	self.dyingCrawlAiming = true;

	self setAnimLimited( %dying_back_aim_4, 1, 0 );
	self setAnimLimited( %dying_back_aim_6, 1, 0 );

	prevyaw = 0;

	while ( 1 )
	{
		aimyaw = self getYawToEnemy();

		diff = AngleClamp180( aimyaw - prevyaw );
		if ( abs( diff ) > 3 )
			diff = sign( diff ) * 3;

		aimyaw = AngleClamp180( prevyaw + diff );

		if ( aimyaw < 0 )
		{
			if ( aimyaw < - 45.0 )
				aimyaw = -45.0;
			weight = aimyaw / - 45.0;
			self setAnim( %dying_back_aim_4_wrapper, weight, .05 );
			self setAnim( %dying_back_aim_6_wrapper, 0, .05 );
		}
		else
		{
			if ( aimyaw > 45.0 )
				aimyaw = 45.0;
			weight = aimyaw / 45.0;
			self setAnim( %dying_back_aim_6_wrapper, weight, .05 );
			self setAnim( %dying_back_aim_4_wrapper, 0, .05 );
		}

		prevyaw = aimyaw;

		wait .05;
	}
}

startDyingCrawlBackAimSoon()
{
	self endon( "kill_long_death" );
	self endon( "death" );

	wait 0.5;
	self thread dyingCrawlBackAim();
}

handleBackCrawlNotetracks( note )
{
	if ( note == "fire_spray" )
	{
		if ( !self canSeeEnemy() )
			return true;

		if ( !self aimedSomewhatAtEnemy() )
			return true;

		self shootEnemyWrapper();

		return true;
	}
	else if ( note == "pistol_pickup" )
	{
		self thread startDyingCrawlBackAimSoon();
		return false;
	}
	return false;
}

aimedSomewhatAtEnemy()
{
	assert( isdefined( self.enemy ) );

	enemyShootAtPos = self.enemy getShootAtPos();

	weaponAngles = self getMuzzleAngle();
	anglesToEnemy = vectorToAngles( enemyShootAtPos - self getMuzzlePos() );

	absyawdiff = AbsAngleClamp180( weaponAngles[ 1 ] - anglesToEnemy[ 1 ] );
	if ( absyawdiff > anim.painYawDiffFarTolerance )
	{
		if ( distanceSquared( self getEye(), enemyShootAtPos ) > anim.painYawDiffCloseDistSQ || absyawdiff > anim.painYawDiffCloseTolerance )
			return false;
	}

	return AbsAngleClamp180( weaponAngles[ 0 ] - anglesToEnemy[ 0 ] ) <= anim.painPitchDiffTolerance;
}

enemyIsInGeneralDirection( dir )
{
	if ( !isdefined( self.enemy ) )
		return false;

	toenemy = vectorNormalize( self.enemy getShootAtPos() - self getEye() );

	return( vectorDot( toenemy, dir ) > 0.5 );// cos( 60 ) = 0.5
}


preventPainForAShortTime( type )
{
	self endon( "kill_long_death" );
	self endon( "death" );

	self.flashBangImmunity = true;

	self.longDeathStarting = true;
	self.a.doingLongDeath = true;
	self notify( "long_death" );
	self.health = 10000;// also prevent death
	self.threatbias = self.threatbias - 2000;

	// during this time, we won't be interrupted by more pain.
	// this increases the chances of the crawling pain succeeding.
	wait .75;

	// important that we die the next time we get hit,
	// instead of maybe going into pain and coming out and going into combat or something
	if ( self.health > 1 )
		self.health = 1;

	// important that we wait a bit in case we're about to start pain later in this frame
	wait .05;

	self.longDeathStarting = undefined;
	self.a.mayOnlyDie = true;// we've probably dropped our weapon and stuff; we must not do any other animscripts but death!

	if ( type == "crawling" )
	{
		wait 1.0;

		// we've essentially succeeded in doing a crawling pain.
		if ( isdefined( level.player ) && distanceSquared( self.origin, level.player.origin ) < 1024 * 1024 )
		{
			anim.numDeathsUntilCrawlingPain = randomintrange( 10, 30 );
			anim.nextCrawlingPainTime = gettime() + randomintrange( 15000, 60000 );
		}
		else
		{
			anim.numDeathsUntilCrawlingPain = randomintrange( 5, 12 );
			anim.nextCrawlingPainTime = gettime() + randomintrange( 5000, 25000 );
		}
		anim.nextCrawlingPainTimeFromLegDamage = gettime() + randomintrange( 7000, 13000 );
		 /#
		if ( getDebugDvarInt( "scr_crawldebug" ) == 1 )
		{
			thread printLongDeathDebugText( self.origin + ( 0, 0, 64 ), "crawl death" );
			return;
		}
		#/
	}
	else if ( type == "corner_grenade" )
	{
		wait 1.0;

		// we've essentially succeeded in doing a corner grenade death.
		if ( isdefined( level.player ) && distanceSquared( self.origin, level.player.origin ) < 700 * 700 )
		{
			anim.numDeathsUntilCornerGrenadeDeath = randomintrange( 10, 30 );
			anim.nextCornerGrenadeDeathTime = gettime() + randomintrange( 15000, 60000 );
		}
		else
		{
			anim.numDeathsUntilCornerGrenadeDeath = randomintrange( 5, 12 );
			anim.nextCornerGrenadeDeathTime = gettime() + randomintrange( 5000, 25000 );
		}
		 /#
		if ( getDebugDvarInt( "scr_cornergrenadedebug" ) == 1 )
		{
			thread printLongDeathDebugText( self.origin + ( 0, 0, 64 ), "grenade death" );
			return;
		}
		#/
	}
}

 /#
printLongDeathDebugText( loc, text )
{
	for ( i = 0; i < 100; i++ )
	{
		print3d( loc, text );
		wait .05;
	}
}
#/

decideNumCrawls()
{
	if( isdefined( self.a.force_num_crawls ) )
		self.a.numCrawls = self.a.force_num_crawls;
	else
		self.a.numCrawls = randomIntRange( 1, 5 );
}

shouldKeepCrawling()
{
	// TODO: player distance checks, etc...

	assert( isDefined( self.a.numCrawls ) );

	if ( !self.a.numCrawls )
	{
		self.a.numCrawls = undefined;
		return false;
	}

	self.a.numCrawls--;

	return true;
}


TryCornerRightGrenadeDeath()
{
	 /#
	if ( getDvarInt( "scr_forceCornerGrenadeDeath" ) == 1 )
	{
		self thread CornerRightGrenadeDeath();
		self waittill( "killanimscript" );
		return true;
	}
	#/

	if ( anim.numDeathsUntilCornerGrenadeDeath > 0 )
		return false;
	if ( gettime() < anim.nextCornerGrenadeDeathTime )
		return false;

	if ( self.a.disableLongDeath || self.dieQuietly || self.damageShield )
		return false;

	if ( isDefined( self.deathFunction ) )
		return false;

	if ( distance( self.origin, level.player.origin ) < 175 )
		return false;

	// we'll wait a bit to see if this crawling pain will really succeed.
	// in the meantime, don't start any other ones.
	anim.nextCornerGrenadeDeathTime = gettime() + 3000;

	self thread CornerRightGrenadeDeath();

	self waittill( "killanimscript" );
	return true;
}

CornerRightGrenadeDeath()
{
	self endon( "kill_long_death" );
	self endon( "death" );

	self thread painDeathNotify();

	self thread preventPainForAShortTime( "corner_grenade" );

	self thread maps\_utility::set_battlechatter( false );

	self.threatbias = -1000;// no need for AI to target me

	self setFlaggedAnimKnobAllRestart( "corner_grenade_pain", %corner_standR_death_grenade_hit, %body, 1, .1 );

	//wait getAnimLength( %corner_standR_death_grenade_hit ) * 0.2;
	self waittillmatch( "corner_grenade_pain", "dropgun" );
	self animscripts\shared::DropAllAIWeapons();

	self waittillmatch( "corner_grenade_pain", "anim_pose = \"back\"" );
	animscripts\shared::noteTrackPoseBack();

	self waittillmatch( "corner_grenade_pain", "grenade_left" );
	model = getWeaponModel( "fraggrenade" );
	self attach( model, "tag_inhand" );
	self.deathFunction = ::prematureCornerGrenadeDeath;

	self waittillmatch( "corner_grenade_pain", "end" );


	desiredDeathTime = gettime() + randomintrange( 25000, 60000 );

	self setFlaggedAnimKnobAllRestart( "corner_grenade_idle", %corner_standR_death_grenade_idle, %body, 1, .2 );

	self thread watchEnemyVelocity();
	while ( !enemyIsApproaching() )
	{
		if ( gettime() >= desiredDeathTime )
			break;

		self animscripts\shared::DoNoteTracksForTime( 0.1, "corner_grenade_idle" );
	}

	dropAnim = %corner_standR_death_grenade_slump;
	self setFlaggedAnimKnobAllRestart( "corner_grenade_release", dropAnim, %body, 1, .2 );

	dropTimeArray = getNotetrackTimes( dropAnim, "grenade_drop" );
	assert( dropTimeArray.size == 1 );
	dropTime = dropTimeArray[ 0 ] * getAnimLength( dropAnim );

	wait dropTime - 1.0;

	self animscripts\death::PlayDeathSound();

	wait 0.7;

	self.deathFunction = ::waitTillGrenadeDrops;

	velocity = ( 0, 0, 30 ) - anglesToRight( self.angles ) * 70;
	self CornerDeathReleaseGrenade( velocity, randomfloatrange( 2.0, 3.0 ) );

	wait .05;
	self detach( model, "tag_inhand" );

	self thread killSelf();
}

CornerDeathReleaseGrenade( velocity, fusetime )
{
	releasePoint = self getTagOrigin( "tag_inhand" );

	// avoid dropping under the floor.
	releasePointLifted = releasePoint + ( 0, 0, 20 );
	releasePointDropped = releasePoint - ( 0, 0, 20 );
	trace = bullettrace( releasePointLifted, releasePointDropped, false, undefined );

	if ( trace[ "fraction" ] < .5 )
		releasePoint = trace[ "position" ];

	surfaceType = "default";
	if ( trace[ "surfacetype" ] != "none" )
		surfaceType = trace[ "surfacetype" ];

	// play the grenade drop sound because we're probably not dropping it with enough velocity for it to play it normally
	thread playSoundAtPoint( "grenade_bounce_" + surfaceType, releasePoint );

	self.grenadeWeapon = "fraggrenade";
	self magicGrenadeManual( releasePoint, velocity, fusetime );
}

playSoundAtPoint( alias, origin )
{
	org = spawn( "script_origin", origin );
	org playsound( alias, "sounddone" );
	org waittill( "sounddone" );
	org delete();
}

killSelf()
{
	self.a.nodeath = true;
	self killWrapper();
	self startragdoll();
	wait .1;
	self notify( "grenade_drop_done" );
}

killWrapper()
{
	// Set in maps\_spawner.gsc, mainly for SpecOps
	// This helps ensure the kill is done by the player if a player is the one who put the Ai into the long-death
	if ( IsDefined( self.last_dmg_player ) )
	{
		self Kill( self.origin, self.last_dmg_player ); 
	}
	else
	{
		self Kill(); 
	}
}

enemyIsApproaching()
{
	if ( !isdefined( self.enemy ) )
		return false;
	if ( distanceSquared( self.origin, self.enemy.origin ) > 384 * 384 )
		return false;
	if ( distanceSquared( self.origin, self.enemy.origin ) < 128 * 128 )
		return true;

	predictedEnemyPos = self.enemy.origin + self.enemyVelocity * 3.0;

	nearestPos = self.enemy.origin;
	if ( self.enemy.origin != predictedEnemyPos )
		nearestPos = pointOnSegmentNearestToPoint( self.enemy.origin, predictedEnemyPos, self.origin );

	if ( distanceSquared( self.origin, nearestPos ) < 128 * 128 )
		return true;

	return false;
}

prematureCornerGrenadeDeath()
{
	deathArray = array( %dying_back_death_v1, %dying_back_death_v2, %dying_back_death_v3, %dying_back_death_v4 );
	deathAnim = deathArray[ randomint( deathArray.size ) ];

	self animscripts\death::PlayDeathSound();

	self setFlaggedAnimKnobAllRestart( "corner_grenade_die", deathAnim, %body, 1, .2 );

	velocity = getGrenadeDropVelocity();
	self CornerDeathReleaseGrenade( velocity, 3.0 );

	model = getWeaponModel( "fraggrenade" );
	self detach( model, "tag_inhand" );

	wait .05;

	self startragdoll();

	self waittillmatch( "corner_grenade_die", "end" );
}

waitTillGrenadeDrops()
{
	self waittill( "grenade_drop_done" );
}

watchEnemyVelocity()
{
	self endon( "kill_long_death" );
	self endon( "death" );

	self.enemyVelocity = ( 0, 0, 0 );

	prevenemy = undefined;
	prevpos = self.origin;

	interval = .15;

	while ( 1 )
	{
		if ( isdefined( self.enemy ) && isdefined( prevenemy ) && self.enemy == prevenemy )
		{
			curpos = self.enemy.origin;
			self.enemyVelocity = vector_multiply( curpos - prevpos, 1 / interval );
			prevpos = curpos;
		}
		else
		{
			if ( isdefined( self.enemy ) )
				prevpos = self.enemy.origin;
			else
				prevpos = self.origin;
			prevenemy = self.enemy;

			self.shootEntVelocity = ( 0, 0, 0 );
		}

		wait interval;
	}
}


additive_pain( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	self endon( "death" );
	
	if ( !isdefined( self ) )
		return;

	if ( isdefined( self.doingAdditivePain ) )
		return;

	if ( damage > self.minPainDamage )
		return;

	self.doingAdditivePain = true;
	painAnimArray = array( %pain_add_standing_belly, %pain_add_standing_left_arm, %pain_add_standing_right_arm );

	painAnim = %pain_add_standing_belly;

	if ( self damageLocationIsAny( "left_arm_lower", "left_arm_upper", "left_hand" ) )
		painAnim = %pain_add_standing_left_arm;
	if ( self damageLocationIsAny( "right_arm_lower", "right_arm_upper", "right_hand" ) )
		painAnim = %pain_add_standing_right_arm;
	else if ( self damageLocationIsAny( "left_leg_upper", "left_leg_lower", "left_foot" ) )
		painAnim = %pain_add_standing_left_leg;
	else if ( self damageLocationIsAny( "right_leg_upper", "right_leg_lower", "right_foot" ) )
		painAnim = %pain_add_standing_right_leg;
	else
		painAnim = painAnimArray[ randomint( painAnimArray.size ) ];


	self setanimlimited( %add_pain, 1, 0.1, 1 );
	self setanimlimited( painAnim, 1, 0, 1 );

	wait 0.4;

	self clearanim( painAnim, 0.2 );
	self clearanim( %add_pain, 0.2 );
	self.doingAdditivePain = undefined;
}
