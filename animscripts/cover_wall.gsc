#include animscripts\Combat_utility;
#include animscripts\Utility;
#include common_scripts\Utility;
#using_animtree( "generic_human" );

cover_wall_think( coverType )
{
	self endon( "killanimscript" );

    self.coverNode = self.node;
    self.coverType = coverType;

	if ( !isDefined( self.node.turret ) )
		animscripts\cover_behavior::turnToMatchNodeDirection( 0 );
	
    if ( coverType == "crouch" )
    {
		self setup_cover_crouch( "unknown" );
		self.coverNode initCoverCrouchNode();
	}
	else
	{
		self setup_cover_stand( "unknown" );
	}
	
	self.a.aimIdleThread = undefined;

	// face the direction of our covernode
	self OrientMode( "face angle", self.coverNode.angles[ 1 ] );

	if ( isDefined( self.weapon ) && usingMG() && isDefined( self.node ) && isDefined( self.node.turretInfo ) && canspawnturret() )
	{
		if ( coverType == "crouch" )
		{
			if ( isRPD( self.weapon ) )
				weaponInfo = "rpd_bipod_crouch";
			else
				weaponInfo = "saw_bipod_crouch";
		}
		else
		{
			if ( isRPD( self.weapon ) )
				weaponInfo = "rpd_bipod_stand";
			else
				weaponInfo = "saw_bipod_stand";
		}

		if ( isRPD( self.weapon ) )
			weaponModel = "weapon_rpd_MG_Setup";
		else
			weaponModel = "weapon_saw_MG_Setup";

		self useSelfPlacedTurret( weaponInfo, weaponModel );
	}
	else if ( isDefined( self.node ) && isDefined( self.node.turret ) )
	{
		self useStationaryTurret();
	}

	self animmode( "normal" );

	//start in hide position
	if ( coverType == "crouch" && self.a.pose == "stand" )
	{
		transAnim = animArray( "stand_2_hide" );
		time = getAnimLength( transAnim );
		self setAnimKnobAllRestart( transAnim, %body, 1, 0.2, fasterAnimSpeed() );
		self thread animscripts\shared::moveToOriginOverTime( self.coverNode.origin, time );
		wait time;
		self.a.coverMode = "hide";
	}
	else
	{
		loopHide( .4 );// need to transition to hide here in case we didn't do an approach

		if ( distanceSquared( self.origin, self.coverNode.origin ) > 1 )
		{
			self thread animscripts\shared::moveToOriginOverTime( self.coverNode.origin, .4 );
			wait( .2 );
			if ( coverType == "crouch" )
				self.a.pose = "crouch";
			wait( .2 );
		}
		else
		{
			wait 0.1;
		}
	}

	self animmode( "zonly_physics" );

	if ( coverType == "crouch" )
	{
		if ( self.a.pose == "prone" )
			self ExitProneWrapper( 1 );
		self.a.pose = "crouch";// in case we only lerped into the pose
	}

	if ( self.coverType == "stand" )
		self.a.special = "cover_stand";
	else
		self.a.special = "cover_crouch";

	behaviorCallbacks = spawnstruct();
	if ( !self.fixedNode )
		behaviorCallbacks.moveToNearByCover	 = animscripts\cover_behavior::moveToNearbyCover;

	behaviorCallbacks.reload				 = ::coverReload;
	behaviorCallbacks.leaveCoverAndShoot	 = ::popUpAndShoot;
	behaviorCallbacks.look					 = ::look;
	behaviorCallbacks.fastlook				 = ::fastLook;
	behaviorCallbacks.idle					 = ::idle;
	behaviorCallbacks.flinch				 = ::flinch;
	behaviorCallbacks.grenade				 = ::tryThrowingGrenade;
	behaviorCallbacks.grenadehidden			 = ::tryThrowingGrenadeStayHidden;
	behaviorCallbacks.blindfire				 = ::blindfire;

	animscripts\cover_behavior::main( behaviorCallbacks );
}

isRPD( weapon )
{
	return getSubStr( weapon, 0, 3 ) == "rpd" && (weapon.size == 3 || weapon[3] == "_");
}

initCoverCrouchNode()
{
	if ( isdefined( self.crouchingIsOK ) )
		return;

	// it's only ok to crouch at this node if we can see out from a crouched position.
	crouchHeightOffset = ( 0, 0, 42 );
	forward = anglesToForward( self.angles );
	self.crouchingIsOK = sightTracePassed( self.origin + crouchHeightOffset, self.origin + crouchHeightOffset + vector_multiply( forward, 64 ), false, undefined );
}


setup_cover_crouch( exposedAnimSet )
{
	self setDefaultAimLimits( self.coverNode );
	self setup_crouching_anim_array( exposedAnimSet );
}


setup_cover_stand( exposedAnimSet )
{
	self setDefaultAimLimits( self.coverNode );
	self setup_standing_anim_array( exposedAnimSet );
}


coverReload()
{
	Reload( 2.0, animArray( "reload" ) );// ( reload no matter what )
	return true;
}


popUpAndShoot()
{
	self.keepClaimedNodeIfValid = true;
	
	if ( isdefined( self.ramboChance ) && randomFloat( 1 ) < self.ramboChance )
	{
		if ( rambo() )
			return true;
	}
	
	if ( !pop_up() )
		return false;

	shootAsTold();

	self endFireAndAnimIdleThread();

	if ( isDefined( self.shootPos ) )
	{
		distSqToShootPos = lengthsquared( self.origin - self.shootPos );
		// too close for RPG or out of ammo
		if ( usingRocketLauncher() && ( distSqToShootPos < squared( 512 ) || self.a.rockets < 1 ) )
		{
			if ( self.a.pose == "stand" )
				animscripts\shared::throwDownWeapon( %RPG_stand_throw );
			else
				animscripts\shared::throwDownWeapon( %RPG_crouch_throw );
		}
	}

	go_to_hide();

	self.coverCrouchLean_aimmode = undefined;
	self.keepClaimedNodeIfValid = false;

	return true;
}


shootAsTold()
{
	self endon( "return_to_cover" );

	self maps\_gameskill::didSomethingOtherThanShooting();

	while ( 1 )
	{
		if ( isdefined( self.shouldReturnToCover ) )
			break;

		if ( !isdefined( self.shootPos ) ) {
			assert( !isdefined( self.shootEnt ) );
			// give shoot_behavior a chance to iterate
			self waittill( "do_slow_things" );
			waittillframeend;
			if ( isdefined( self.shootPos ) )
				continue;
			break;
		}

		if ( !self.bulletsInClip )
			break;

		// crouch only
		if ( self.coverType == "crouch" && needToChangeCoverMode() )
		{
			break;

			// TODO: if changing between stances without returning to cover is implemented, 
			// we can't just endon("return_to_cover") because it will cause problems when it
			// happens while changing stance.
			// see corner's implementation of this idea for a better implementation.

			// NYI
			/*changeCoverMode();
			
			// if they're moving too fast for us to respond intelligently to them,
			// give up on firing at them for the moment
			if ( needToChangeCoverMode() )
				break;
			
			continue;*/
		}

		shootUntilShootBehaviorChange_coverWall();
		self clearAnim( %add_fire, .2 );
	}
}

shootUntilShootBehaviorChange_coverWall()
{
	if ( self.coverType == "crouch" )
		self thread angleRangeThread();// gives stopShooting notify when shootPosOutsideLegalYawRange returns true
	self thread aimIdleThread();

	shootUntilShootBehaviorChange();
}


rambo()
{
	if ( !hasEnemySightPos() )
		return false;
	
	animType = "rambo";
	if ( randomint( 10 ) < 2 )
		animType = "rambo_fail";
	
	if ( !animArrayAnyExist( animType ) )
		return false;
	
	if ( self.coverType == "crouch" && !self.coverNode.crouchingIsOK )
		return false;
	
	pitch = getShootPosPitch( self.coverNode.origin + getNodeOffset( self.coverNode ) );
	if ( pitch > 15 )
		return false;
	
	forward = anglesToForward( self.angles );
	stepto = self.origin + vector_multiply( forward, -16 );
	
	if ( !self mayMoveToPoint( stepto ) )
		return false;
	
	self.coverPosEstablishedTime = gettime();
	
	self animMode( "zonly_physics" );
	self.keepClaimedNodeIfValid = true;
	self.isRambo = true;
	self.a.prevAttack = "rambo";
	
	self.changingCoverPos = true;
	
	self thread animscripts\shared::ramboAim( 0 );
	
	ramboAnim = animArrayPickRandom( animType );
	self setFlaggedAnimKnobAllRestart( "rambo", ramboAnim, %body, 1, .2, 1 );
	self animscripts\shared::DoNoteTracks( "rambo" );
	
	self notify( "rambo_aim_end" );
	
	self.changingCoverPos = false;
	
	self.keepClaimedNodeIfValid = false;
	self.lastRamboTime = getTime();
	
	self.changingCoverPos = false;
	self.isRambo = undefined;
	
	return true;
}


idle()
{
	self endon( "end_idle" );

	while ( 1 )
	{
		useTwitch = ( randomint( 2 ) == 0 && animArrayAnyExist( "hide_idle_twitch" ) );
		if ( useTwitch )
			idleanim = animArrayPickRandom( "hide_idle_twitch" );
		else
			idleanim = animarray( "hide_idle" );

		playIdleAnimation( idleAnim, useTwitch );
	}
}

flinch()
{
	if ( !animArrayAnyExist( "hide_idle_flinch" ) )
		return false;

	forward = anglesToForward( self.angles );
	stepto = self.origin + vector_multiply( forward, -16 );

	if ( !self mayMoveToPoint( stepto ) )
		return false;

	self animmode( "zonly_physics" );
	self.keepClaimedNodeIfValid = true;

	flinchanim = animArrayPickRandom( "hide_idle_flinch" );
	playIdleAnimation( flinchanim, true );

	self.keepClaimedNodeIfValid = false;

	return true;
}

playIdleAnimation( idleAnim, needsRestart )
{
	if ( needsRestart )
		self setFlaggedAnimKnobAllRestart( "idle", idleAnim, %body, 1, 0.25, 1 );
	else
		self setFlaggedAnimKnobAll( "idle", idleAnim, %body, 1, 0.25, 1 );

	self.a.coverMode = "hide";

	self animscripts\shared::DoNoteTracks( "idle" );
}

look( lookTime )
{
	if ( !isdefined( self.a.array[ "hide_to_look" ] ) )
		return false;

	if ( !peekOut() )
		return false;

	animscripts\shared::playLookAnimation( animArray( "look_idle" ), lookTime );// TODO: replace

	lookanim = undefined;
	if ( self isSuppressedWrapper() )
		lookanim = animArray( "look_to_hide_fast" );
	else
		lookanim = animArray( "look_to_hide" );

	self setflaggedanimknoballrestart( "looking_end", lookanim, %body, 1, .1 );
	animscripts\shared::DoNoteTracks( "looking_end" );

	return true;
}

peekOut()
{
	if ( isdefined( self.coverNode.script_dontpeek ) )
		return false;	

	// assuming no delta, so no maymovetopoint check

	self setFlaggedAnimKnobAll( "looking_start", animArray( "hide_to_look" ), %body, 1, .2 );
	animscripts\shared::DoNoteTracks( "looking_start" );

	return true;
}

fastLook()
{
	self setFlaggedAnimKnobAllRestart( "look", animArrayPickRandom( "look" ), %body, 1, .1 );
	self animscripts\shared::DoNoteTracks( "look" );

	return true;
}


// These should be adjusted in animation data
pop_up_and_hide_speed()
{
	if ( self.a.coverMode == "left" || self.a.coverMode == "right" || self.a.coverMode == "over" )
		return 1;

	return randomfasterAnimSpeed();
}


pop_up()
{
	assert( !isdefined( self.a.coverMode ) || self.a.coverMode == "hide" );

	newCoverMode = getBestCoverMode();

	timeleft = .1;
	
	popupAnim = animArray( "hide_2_" + newCoverMode );

	if ( !self mayMoveToPoint( getAnimEndPos( popupAnim ) ) )
		return false;

	if ( self.script == "cover_crouch" && newCoverMode == "lean" )
		self.coverCrouchLean_aimmode = true;

	if ( self.coverType == "crouch" )
		self setup_cover_crouch( newCoverMode );
	else
		self setup_cover_stand( newCoverMode );

	self.a.special = "none";
	self.specialDeathFunc = undefined;
	
	if ( self.coverType == "stand" )
		self.a.special = "cover_stand_aim";
	else
		self.a.special = "cover_crouch_aim";		
		
	self.changingCoverPos = true; 
	self notify( "done_changing_cover_pos" );

	self animmode( "zonly_physics" );

	animRate = pop_up_and_hide_speed();

	self setFlaggedAnimKnobAllRestart( "pop_up", popUpAnim, %body, 1, .1, animRate );
	self thread DoNoteTracksForPopup( "pop_up" );

	if ( animHasNoteTrack( popupAnim, "start_aim" ) )
	{
		self waittillmatch( "pop_up", "start_aim" );
		timeleft = getAnimLength( popupAnim ) / animRate * ( 1 - self getAnimTime( popupAnim ) );
	}
	else
	{
		self waittillmatch( "pop_up", "end" );
		timeleft = .1;
	}

	self clearAnim( popUpAnim, timeleft + 0.05 );

	self.a.coverMode = newCoverMode;
	self.a.prevAttack = newCoverMode;
	self setup_additive_aim( timeleft );
	self thread animscripts\shared::trackShootEntOrPos();

	wait( timeleft );
	
	if ( self isSniper() )
	{
		thread animscripts\shoot_behavior::sniper_glint_behavior();
	}

	self.changingCoverPos = false;
	self.coverPosEstablishedTime = gettime();

	self notify( "stop_popup_donotetracks" );

	return true;
}

DoNoteTracksForPopup( animname )
{
	self endon( "killanimscript" );
	self endon( "stop_popup_donotetracks" );
	self animscripts\shared::DoNoteTracks( animname );
}


setup_additive_aim( transTime )
{
	if ( self.a.coverMode == "left" || self.a.coverMode == "right" )
		aimCoverMode = "crouch";
	else
		aimCoverMode = self.a.coverMode;

	self setAnimKnobAll( animArray( aimCoverMode + "_aim" ), %body, 1, transTime );
	if ( aimCoverMode == "crouch" )
	{
		self setanimlimited( %covercrouch_aim2_add, 1, 0 );
		self setanimlimited( %covercrouch_aim4_add, 1, 0 );
		self setanimlimited( %covercrouch_aim6_add, 1, 0 );
		self setanimlimited( %covercrouch_aim8_add, 1, 0 );
	}
	else if ( aimCoverMode == "stand" )
	{
		self setanimlimited( %exposed_aim_2, 1, 0 );
		self setanimlimited( %exposed_aim_4, 1, 0 );
		self setanimlimited( %exposed_aim_6, 1, 0 );
		self setanimlimited( %exposed_aim_8, 1, 0 );
	}
	else if ( aimCoverMode == "lean" )
	{
		self setanimlimited( %exposed_aim_2, 1, 0 );
		self setanimlimited( %exposed_aim_4, 1, 0 );
		self setanimlimited( %exposed_aim_6, 1, 0 );
		self setanimlimited( %exposed_aim_8, 1, 0 );
		// these don't seem to have 45 degree aiming limits,
		// so i'm using the exposed ones instead
		/*self setanimlimited(%covercrouch_lean_aim2_add,1,0);
		self setanimlimited(%covercrouch_lean_aim4_add,1,0);
		self setanimlimited(%covercrouch_lean_aim6_add,1,0);
		self setanimlimited(%covercrouch_lean_aim8_add,1,0);*/
	}
	else if ( aimCoverMode == "over" )
	{
		self setanimlimited( %coverstandaim_aim2_add, 1, 0 );
		self setanimlimited( %coverstandaim_aim4_add, 1, 0 );
		self setanimlimited( %coverstandaim_aim6_add, 1, 0 );
		self setanimlimited( %coverstandaim_aim8_add, 1, 0 );
	}
}


go_to_hide()
{
	self notify( "return_to_cover" );

	self.changingCoverPos = true; self notify( "done_changing_cover_pos" );

	self endAimIdleThread();

	animRate = pop_up_and_hide_speed();

	self setFlaggedAnimKnobAll( "go_to_hide", animArray( self.a.coverMode + "_2_hide" ), %body, 1, 0.2, animRate );
	self clearAnim( %exposed_modern, 0.2 );

	self animscripts\shared::DoNoteTracks( "go_to_hide" );

	self.a.coverMode = "hide";

	if ( self.coverType == "stand" )
		self.a.special = "cover_stand";
	else
		self.a.special = "cover_crouch";

	self.changingCoverPos = false;
}


tryThrowingGrenadeStayHidden( throwAt )
{
	// TODO: check suppression and add rambo grenade support
	return tryThrowingGrenade( throwAt, true );
}


tryThrowingGrenade( throwAt, safe )
{
	if ( isdefined( self.dontEverShoot ) || isdefined( throwAt.dontAttackMe ) )
		return false;

	theanim = undefined;
	if ( isdefined( self.ramboChance ) && randomfloat( 1.0 ) < self.ramboChance )
	{
		theanim = animArrayPickRandom( "grenade_rambo" );
	}
	else
	{
		if ( isdefined( safe ) && safe )
			theanim = animArrayPickRandom( "grenade_safe" );
		else
			theanim = animArrayPickRandom( "grenade_exposed" );
	}

	self animMode( "zonly_physics" );// Unlatch the feet
	self.keepClaimedNodeIfValid = true;
	
	threwGrenade = TryGrenade( throwAt, theanim );
	
	self.keepClaimedNodeIfValid = false;
	return threwGrenade;
}


blindfire()
{
	if ( !animArrayAnyExist( "blind_fire" ) )
		return false;

	self animMode( "zonly_physics" );
	self.keepClaimedNodeIfValid = true;

	self setFlaggedAnimKnobAllRestart( "blindfire", animArrayPickRandom( "blind_fire" ), %body, 1, 0.2, 1 );
	self animscripts\shared::DoNoteTracks( "blindfire" );

	self.keepClaimedNodeIfValid = false;

	return true;
}


createTurret( posEnt, weaponInfo, weaponModel )
{
	turret = spawnTurret( "misc_turret", posEnt.origin, weaponInfo );
	turret.angles = posEnt.angles;
	turret.aiOwner = self;
	turret setModel( weaponModel );
	turret makeUsable();
	turret setDefaultDropPitch( 0 );

	if ( isDefined( posEnt.leftArc ) )
		turret.leftArc = posEnt.leftArc;
	if ( isDefined( posEnt.rightArc ) )
		turret.rightArc = posEnt.rightArc;
	if ( isDefined( posEnt.topArc ) )
		turret.topArc = posEnt.topArc;
	if ( isDefined( posEnt.bottomArc ) )
		turret.bottomArc = posEnt.bottomArc;

	return turret;
}

deleteIfNotUsed( owner )
{
	self endon( "death" );
	self endon( "being_used" );

	wait .1;

	if ( isdefined( owner ) )
	{
		assert( !isdefined( owner.a.usingTurret ) || owner.a.usingTurret != self );
		owner notify( "turret_use_failed" );
	}
	self delete();
}

useSelfPlacedTurret( weaponInfo, weaponModel )
{
	turret = self createTurret( self.node.turretInfo, weaponInfo, weaponModel );

	if ( self useTurret( turret ) )
	{
		turret thread deleteIfNotUsed( self );
		if ( isdefined( self.turret_function ) )
			thread [[ self.turret_function ]]( turret );
//		self setAnimKnob( %cover, 0, 0 );
		self waittill( "turret_use_failed" );// generally this won't notify, and we'll just not do any more cover_wall for now
	}
	else
	{
		turret delete();
	}
}


useStationaryTurret()
{
	assert( isdefined( self.node ) );
	assert( isdefined( self.node.turret ) );

	turret = self.node.turret;
	if ( !turret.isSetup )
		return;

//	turret setmode( "auto_ai" ); // auto, auto_ai, manual, manual_ai
//	turret startFiring(); // seems to be a bug with the turret being in manual mode to start with
//	wait( 1 );
	thread maps\_mg_penetration::gunner_think( turret );
	self waittill( "continue_cover_script" );

//	turret thread maps\_spawner::restorePitch();
//	self useturret( turret ); // dude should be near the mg42
}


setup_crouching_anim_array( exposedAnimSet )
{
	anim_array = [];

	anim_array[ "hide_idle" ] = %covercrouch_hide_idle;
	anim_array[ "hide_idle_twitch" ] = array(
		%covercrouch_twitch_1,
		%covercrouch_twitch_2,
		%covercrouch_twitch_3,
		%covercrouch_twitch_4
		//%covercrouch_twitch_5 // excluding #5 because it's a wave to someone behind him, and in idle twitches we don't know if that makes sense at the time
	 );

	anim_array[ "hide_idle_flinch" ] = array(
		/*%covercrouch_explosion_1,
		%covercrouch_explosion_2,
		%covercrouch_explosion_3*/ // these just don't look good for flinching
	 );

	anim_array[ "hide_2_crouch" ] = %covercrouch_hide_2_aim;
	anim_array[ "hide_2_stand" ] = %covercrouch_hide_2_stand;
	anim_array[ "hide_2_lean" ] = %covercrouch_hide_2_lean;
	anim_array[ "hide_2_right" ] = %covercrouch_hide_2_right;
	anim_array[ "hide_2_left" ] = %covercrouch_hide_2_left;

	anim_array[ "crouch_2_hide" ] = %covercrouch_aim_2_hide;
	anim_array[ "stand_2_hide" ] = %covercrouch_stand_2_hide;
	anim_array[ "lean_2_hide" ] = %covercrouch_lean_2_hide;
	anim_array[ "right_2_hide" ] = %covercrouch_right_2_hide;
	anim_array[ "left_2_hide" ] = %covercrouch_left_2_hide;


	anim_array[ "crouch_aim" ] = %covercrouch_aim5;
	anim_array[ "stand_aim" ] = %exposed_aim_5;
	anim_array[ "lean_aim" ] = %covercrouch_lean_aim5;

	anim_array[ "fire" ] = %exposed_shoot_auto_v2;
	anim_array[ "semi2" ] = %exposed_shoot_semi2;
	anim_array[ "semi3" ] = %exposed_shoot_semi3;
	anim_array[ "semi4" ] = %exposed_shoot_semi4;
	anim_array[ "semi5" ] = %exposed_shoot_semi5;

	if ( weapon_pump_action_shotgun() )
	{
		if ( exposedAnimSet == "lean" || exposedAnimSet == "stand" )
			anim_array[ "single" ] = array( %shotgun_stand_fire_1A );
		else
			anim_array[ "single" ] = array( %shotgun_crouch_fire );
	}
	else
	{
		anim_array[ "single" ] = array( %exposed_shoot_semi1 );
	}

	anim_array[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	anim_array[ "burst3" ] = %exposed_shoot_burst3;
	anim_array[ "burst4" ] = %exposed_shoot_burst4;
	anim_array[ "burst5" ] = %exposed_shoot_burst5;
	anim_array[ "burst6" ] = %exposed_shoot_burst6;

	anim_array[ "blind_fire" ] = array( %covercrouch_blindfire_1, %covercrouch_blindfire_2, %covercrouch_blindfire_3, %covercrouch_blindfire_4 );

	anim_array[ "reload" ] = %covercrouch_reload_hide;

	anim_array[ "grenade_safe" ] = array( %covercrouch_grenadeA, %covercrouch_grenadeB );
	anim_array[ "grenade_exposed" ] = array( %covercrouch_grenadeA, %covercrouch_grenadeB );

	anim_array[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	anim_array[ "look" ] = array( %covercrouch_hide_look );
	
	if ( isDefined( anim.ramboAnims ) )
	{
		anim_array[ "rambo" ] = anim.ramboAnims.covercrouch;
		anim_array[ "rambo_fail" ] = anim.ramboAnims.covercrouchfail;
		anim_array[ "grenade_rambo" ] = anim.ramboAnims.covercrouchgrenade;
	}
	
	self.a.array = anim_array;
}


setup_standing_anim_array( exposedAnimSet )
{
	anim_array = [];

	anim_array[ "hide_idle" ] = %coverstand_hide_idle;
	anim_array[ "hide_idle_twitch" ] = array(
		%coverstand_hide_idle_twitch01,
		%coverstand_hide_idle_twitch02,
		%coverstand_hide_idle_twitch03,
		%coverstand_hide_idle_twitch04,
		%coverstand_hide_idle_twitch05
	 );

	anim_array[ "hide_idle_flinch" ] = array(
		%coverstand_react01,
		%coverstand_react02,
		%coverstand_react03,
		%coverstand_react04
	 );

	anim_array[ "hide_2_stand" ] = %coverstand_hide_2_aim;
	anim_array[ "stand_2_hide" ] = %coverstand_aim_2_hide;

	anim_array[ "hide_2_over" ] = %coverstand_2_coverstandaim;
	anim_array[ "over_2_hide" ] = %coverstandaim_2_coverstand;

	if ( exposedAnimSet == "over" )
	{
		anim_array[ "over_aim" ] = %coverstandaim_aim5;

		anim_array[ "fire" ] = %coverstandaim_autofire;
		anim_array[ "semi2" ] = %coverstandaim_fire;
		anim_array[ "semi3" ] = %coverstandaim_fire;
		anim_array[ "semi4" ] = %coverstandaim_fire;
		anim_array[ "semi5" ] = %coverstandaim_fire;

		anim_array[ "single" ] = array( %coverstandaim_fire );

		anim_array[ "burst2" ] = %coverstandaim_autofire;// ( will be limited to 2 shots )
		anim_array[ "burst3" ] = %coverstandaim_autofire;
		anim_array[ "burst4" ] = %coverstandaim_autofire;
		anim_array[ "burst5" ] = %coverstandaim_autofire;
		anim_array[ "burst6" ] = %coverstandaim_autofire;
	}
	else
	{
		anim_array[ "stand_aim" ] = %exposed_aim_5;

		anim_array[ "fire" ] = %exposed_shoot_auto_v2;
		anim_array[ "semi2" ] = %exposed_shoot_semi2;
		anim_array[ "semi3" ] = %exposed_shoot_semi3;
		anim_array[ "semi4" ] = %exposed_shoot_semi4;
		anim_array[ "semi5" ] = %exposed_shoot_semi5;

		if ( weapon_pump_action_shotgun() )
			anim_array[ "single" ] = array( %shotgun_stand_fire_1A );
		else
			anim_array[ "single" ] = array( %exposed_shoot_semi1 );

		anim_array[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
		anim_array[ "burst3" ] = %exposed_shoot_burst3;
		anim_array[ "burst4" ] = %exposed_shoot_burst4;
		anim_array[ "burst5" ] = %exposed_shoot_burst5;
		anim_array[ "burst6" ] = %exposed_shoot_burst6;
	}

	anim_array["blind_fire"] = array( %coverstand_blindfire_1, %coverstand_blindfire_2 /*, %coverstand_blindfire_3*/ ); // #3 looks silly

	anim_array[ "reload" ] = %coverstand_reloadA;

	anim_array[ "look" ] = array( %coverstand_look_quick, %coverstand_look_quick_v2 );

	anim_array[ "grenade_safe" ] = array( %coverstand_grenadeA, %coverstand_grenadeB );
	anim_array[ "grenade_exposed" ] = array( %coverstand_grenadeA, %coverstand_grenadeB );

	anim_array[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	anim_array[ "hide_to_look" ] = %coverstand_look_moveup;
	anim_array[ "look_idle" ] = %coverstand_look_idle;
	anim_array[ "look_to_hide" ] = %coverstand_look_movedown;
	anim_array[ "look_to_hide_fast" ] = %coverstand_look_movedown_fast;
	
	if ( isDefined( anim.ramboAnims ) )
	{
		anim_array[ "rambo" ] = anim.ramboAnims.coverstand;
		anim_array[ "rambo_fail" ] = anim.ramboAnims.coverstandfail;
		anim_array[ "grenade_rambo" ] = anim.ramboAnims.coverstandgrenade;
	}
	
	self.a.array = anim_array;
}


loopHide( transTime )
{
	if ( !isdefined( transTime ) )
		transTime = .1;

	self setanimknoballrestart( animArray( "hide_idle" ), %body, 1, transTime );
	self.a.coverMode = "hide";
}


angleRangeThread()
{
	self endon( "killanimscript" );
	self notify( "newAngleRangeCheck" );
	self endon( "newAngleRangeCheck" );
	self endon( "return_to_cover" );

	while ( 1 )
	{
		if ( needToChangeCoverMode() )
			break;
		wait( 0.1 );
	}

	self notify( "stopShooting" );// For changing shooting pose to compensate for player moving
}


needToChangeCoverMode()
{
	if ( self.coverType != "crouch" )
		return false;

	pitch = getShootPosPitch( self getEye() );

	if ( self.a.coverMode == "lean" )
	{
		return pitch < 10;
	}
	else
	{
		return pitch > 45;
	}
}


getBestCoverMode()
{
	modes = [];
	assert( isdefined( self.coverNode ) );
	
	if ( self.coverType == "stand" )
	{
		modes = self.coverNode GetValidCoverPeekOuts();
		modes[ modes.size ] = "stand";
	}
	else
	{
		pitch = getShootPosPitch( self.coverNode.origin + getNodeOffset( self.coverNode ) );

		if ( pitch > 30 )
			return "lean";
		if ( pitch > 15 || !self.coverNode.crouchingIsOK )
			return "stand";
			
		modes = self.coverNode GetValidCoverPeekOuts();
		modes[ modes.size ] = "crouch";
	}

	return getRandomCoverMode( modes );
}


getShootPosPitch( fromPos )
{
	shootPos = getEnemyEyePos();

	return AngleClamp180( vectorToAngles( shootPos - fromPos )[ 0 ] );
}
