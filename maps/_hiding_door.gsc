#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

hiding_door_spawner()
{
	// place a hiding_door_guy prefab and then place a spawner next to it with script_noteworthy "hiding_door_spawner". 
	// Spawn the guy however you like (trigger or script)
	// Target the spawner to a trigger, this trigger will make the guy open the door.
	// Alternatively put a script_flag_wait on the spawner. The guy will wait for the flag to be set before opening the door.
	// If you put neither, a trigger_radius will be spawned, using the radius of the spawner if a radius is set
	
	door_orgs = getentarray( "hiding_door_guy_org", "targetname" );
	assertex( door_orgs.size, "Hiding door guy with export " + self.export + " couldn't find a hiding_door_org!" );
	
	door_org = getclosest( self.origin, door_orgs );
	assertex( distance( door_org.origin, self.origin ) < 256, "Hiding door guy with export " + self.export + " was not placed within 256 units of a hiding_door_org" );
	
	door_org.targetname = undefined;// so future searches won't grab this one
	
	//get door models (and script_brushmodel doors, if applicable)
	door_models = getentarray( door_org.target, "targetname" );
	door_model = undefined;
	brushmodel_door = undefined;
	
	badplaceBrush = undefined;
	if( IsDefined( door_org.script_linkto ) )
	{
		badplaceBrush = door_org get_linked_ent();
	}
	
	//if there is only one ent, it must be the script_model door
	if ( door_models.size == 1 )
	{
		door_model = door_models[ 0 ];
	}
	
	//if targeting more than one ent, the LD wants to substitute a custom script_brushmodel door
	else
	{
		foreach( ent in door_models )
		{
			if ( ent.code_classname == "script_brushmodel" )
			{
				brushmodel_door = ent;
			}
			else if ( ent.code_classname == "script_model" )
			{
				door_model = ent;
			}
		}
		assertex( isdefined( brushmodel_door ), "Hiding door org at " + door_org.origin + " targets multiple entities, but not a script_brushmodel door" );
		assertex( isdefined( door_model ), "Hiding door org at " + door_org.origin + " targets multiple entities, but not a script_model door" );
	}
	
	door_clip = getent( door_model.target, "targetname" );
	assert( isdefined( door_model.target ) );
	
	pushPlayerClip = undefined;
	if ( isdefined( door_clip.target ) )
		pushPlayerClip = getent( door_clip.target, "targetname" );
	if ( isdefined( pushPlayerClip ) )
	{
		door_org thread hiding_door_guy_pushplayer( pushPlayerClip );
		
		if( !IsDefined( level._hiding_door_pushplayer_clips ) )
		{
			level._hiding_door_pushplayer_clips = [];
		}
		level._hiding_door_pushplayer_clips[ level._hiding_door_pushplayer_clips.size ] = pushPlayerClip;
	}
	
	door_model delete();// we spawn our own door, the one in the prefab is just to aid placement
	
	door = spawn_anim_model( "hiding_door" );
	door_org thread anim_first_frame_solo( door, "fire_3" );
	if ( isdefined( brushmodel_door ) )
	{
		brushmodel_door linkTo( door, "door_hinge_jnt" );
		door hide();
	}
	
	if ( isdefined( door_clip ) )
	{
		door_clip linkto( door, "door_hinge_jnt" );
		door_clip disconnectPaths();
	}
	
	trigger = undefined;
	if ( isdefined( self.target ) )
	{
		trigger = getent( self.target, "targetname" );
		if ( !issubstr( trigger.classname, "trigger" ) )
			trigger = undefined;
	}
	
	if ( !isdefined( self.script_flag_wait ) && !isdefined( trigger ) )
	{
		radius = 200;
		if ( isdefined( self.radius ) )
			radius = self.radius;

		// no trigger mechanism specified, so add a radius trigger
		trigger = spawn( "trigger_radius", door_org.origin, 0, radius, 48 );
	}
	
	if ( isdefined( badplaceBrush ) )
		badPlace_Brush( badplaceBrush getentitynumber(), 0, badplaceBrush, "allies" );
	
	self add_spawn_function( ::hiding_door_guy, door_org, trigger, door, door_clip, badplaceBrush );
}

hiding_door_guy( door_org, trigger, door, door_clip, badplaceBrush )
{
	starts_open = hiding_door_starts_open( door_org );

	self.animname = "hiding_door_guy";
	self endon( "death" );
	self endon( "damage" );
	
	self.grenadeammo = 2;

	self set_deathanim( "death_2" );
	self.allowdeath = true;
	self.health = 50000;// buffer health, he "dies" in one hit

	guy_and_door = [];
	guy_and_door[ guy_and_door.size ] = door;
	guy_and_door[ guy_and_door.size ] = self;

	thread hiding_door_guy_cleanup( door_org, self, door, door_clip, badplaceBrush );
	thread hiding_door_death( door, door_org, self, door_clip, badplaceBrush );

	if ( starts_open )
	{
		// wait for trigger before closing the door
		door_org thread anim_loop( guy_and_door, "idle" );
	}
	else
	{
		door_org thread anim_first_frame( guy_and_door, "fire_3" );
	}

	if ( isdefined( trigger	 ) )
	{
		wait 0.05;
		trigger waittill( "trigger" );
	}
	else
	{
		flag_wait( self.script_flag_wait );
	}

	if ( starts_open )
	{
		door_org notify( "stop_loop" );
		door_org anim_single( guy_and_door, "close" );
	}
	
	counter = 0;
	timesFired = 0;
	for ( ;; )
	{
		//-----------------
		// GET ENEMY AND ENEMY DIRECTION
		//-----------------
		
		enemy = level.player;
		if ( isdefined( self.enemy ) )
			enemy = self.enemy;
		assert( isdefined( enemy ) );
		direction = hiding_door_get_enemy_direction( door.angles, self.origin, enemy.origin );
		
		//-----------------
		// ABORT CONDITIONS
		//-----------------
		
		// Abort door behavior if the player comes up behind the AI
		if ( self player_entered_backdoor( direction ) )
		{
			if ( self quit_door_behavior() )
				return;
		}
		
		// Abort door behavior after peeking a couple times if the player can see him from behind
		if ( counter >= 2 )
		{
			if ( self quit_door_behavior( true ) )
				return;
		}
		
		//-----------------
		// DETERMINE SCENE BASED ON ENEMY DIRECTION
		//-----------------
		
		scene = undefined;
		if ( direction == "left" || direction == "front" )
		{
			scene = "fire_3";
		}
		else if ( direction == "right" )
		{
			scene = "fire_1";
			if ( cointoss() )
				scene = "fire_2";
		}
		else
		{
			// player or enemy is behind him so just open and close the door and peek
			door_org anim_single( guy_and_door, "open" );
			door_org anim_single( guy_and_door, "close" );
			counter++;
			continue;
		}
		assert( isdefined( scene ) );
		
		//-----------------
		// CHARGE CONDITION + CHANCE
		//-----------------
		
		if ( self hiding_door_guy_should_charge( direction, enemy, timesFired ) )
		{
			scene = "jump";
			if ( coinToss() )
			{
				if ( self mayMoveToPoint( animscripts\utility::getAnimEndPos( level.scr_anim[ self.animname ][ "kick" ] ) ) )
					scene = "kick";
			}
			
			// connect paths on the door and handle player clip
			thread hiding_door_death_door_connections( door_clip, badplaceBrush );
			door_org notify( "push_player" );
			
			// stop the thread that waits for him to break out of door behavior to open the door since this anim opens it for us
			self notify( "charge" );
			
			// guy charges out
			self.allowdeath = true;
			self.health = 100;
			self clear_deathanim();
			door_org anim_single( guy_and_door, scene );
			
			// now he goes to exposed combat
			self quit_door_behavior();
			return;
				
		}
		
		//-----------------
		// THROW A GRENADE?
		//-----------------
		
		// randomly do grenade throw if the AI has grenade ammo. More likely if hte AI has more grenades
		if ( self hiding_door_guy_should_throw_grenade( direction, timesFired ) )
		{
			self.grenadeammo--;
			scene = "grenade";
		}
		
		counter = 0;
		timesFired++;
		
		//-----------------
		// DO ANIM
		//-----------------
		
		door_org thread anim_single( guy_and_door, scene );
		
		// delay the settime by a frame or it wont work
		// this is so we can skip the slow creep part of the animation
		delaythread( 0.05, ::anim_set_time, guy_and_door, scene, 0.3 );
		door_org waittill( scene );
		
		//-----------------
		// IDLE FOR A MOMENT
		//-----------------
		
		door_org thread anim_first_frame( guy_and_door, "open" );
		wait( randomfloatrange( 0.2, 1.0 ) );
		door_org notify( "stop_loop" );
	}
}

quit_door_behavior( sightTraceRequired, door_org )
{
	if ( !isdefined( sightTraceRequired ) )
		sightTraceRequired = false;
	
	if ( sightTraceRequired )
	{
		if ( !sightTracePassed( level.player getEye(), self getEye(), false, self ) )
			return false;
	}
	
	self.health = 100;
	self clear_deathanim();
	self.goalradius = 512;
	self setGoalPos( self.origin );
	self notify( "quit_door_behavior" );
	self stopanimscripted();
	self notify( "killanimscript" );
	return true;
}

player_entered_backdoor( direction )
{
	if ( direction != "behind" )
		return false;
	
	d = distance( self.origin, level.player.origin );
	if ( d > 250 )
		return false;
	
	if ( !sightTracePassed( level.player getEye(), self getEye(), false, self ) )
		return false;
	
	return true;
}

hiding_door_guy_should_charge( direction, enemy, timesFired )
{
	TIMES_FIRED_MIN = 3;
	MIN_DIST = 100;
	MAX_DIST = 600;
	
	if ( timesFired < TIMES_FIRED_MIN )
		return false;
	
	if ( enemy != level.player )
		return false;
	
	if ( direction != "front" )
		return false;
	
	d = distance( self.origin, level.player.origin );
	if ( d < MIN_DIST )
		return false;
	if ( d > MAX_DIST )
		return false;
	
	return coinToss();
}

hiding_door_guy_should_throw_grenade( direction, timesFired )
{
	if ( timesFired < 1 )
		return false;
	if ( direction == "behind" )
		return false;
	if ( randomint( 100 ) < 25 * self.grenadeammo )
		return true;
	return false;
}

hiding_door_get_enemy_direction( viewerAngles, viewerOrigin, targetOrigin )
{
	forward = anglesToForward( viewerAngles );
	vFacing = vectorNormalize( forward );
	anglesToFacing = vectorToAngles( vFacing );
	anglesToPoint = vectorToAngles( targetOrigin - viewerOrigin );

	angle = anglesToFacing[ 1 ] - anglesToPoint[ 1 ];
	angle += 360;
	angle = int( angle ) % 360;
	
	direction = undefined;
	
	if ( angle >= 90 && angle <= 270 )
		direction = "behind";
	else if ( angle >= 300 || angle <= 45 )
		direction = "front";
	else if ( angle < 90 )
		direction = "right";
	else if ( angle > 270 )
		direction = "left";
	
	assert( isdefined( direction ) );
	return direction;
}

hiding_door_guy_cleanup( door_org, guy, door, door_clip, badplaceBrush )
{
	guy endon( "charge" );
	
	// if the guy gets deleted before the sequence happens this thread will catch that and clean up any problems that could arise
	guy waittill_either( "death", "quit_door_behavior" );
	
	// stop the looping animations because the guy is removed now
	door_org notify( "stop_loop" );

	thread hiding_door_death_door_connections( door_clip, badplaceBrush );
	door_org notify( "push_player" );
	if ( !isdefined( door.played_death_anim ) )
	{
		door.played_death_anim = true;
		door_org thread anim_single_solo( door, "death_2" );
	}
}

hiding_door_guy_pushplayer( pushPlayerClip )
{
	self waittill( "push_player" );
	pushPlayerClip moveto( self.origin, 1.5 );
	wait 1.5;
	pushPlayerClip delete();
}

hiding_door_guy_grenade_throw( guy )
{
	// called from a notetrack
	startOrigin = guy getTagOrigin( "J_Wrist_RI" );
	strength = ( distance( level.player.origin, guy.origin ) * 2.0 );
	if ( strength < 300 )
		strength = 300;
	if ( strength > 1000 )
		strength = 1000;
	vector = vectorNormalize( level.player.origin - guy.origin );
	velocity = vector_multiply( vector, strength );
	guy magicGrenadeManual( startOrigin, velocity, randomfloatrange( 3.0, 5.0 ) );
}

hiding_door_death( door, door_org, guy, door_clip, badplaceBrush )
{
	guy endon( "charge" );
	guy endon( "quit_door_behavior" );
	
	guy waittill( "damage", dmg, attacker );
	if ( !isalive( guy ) )
		return;
	thread hiding_door_death_door_connections( door_clip, badplaceBrush );
	door_org notify( "push_player" );
	door_org thread anim_single_solo( guy, "death_2" );
	if ( !isdefined( door.played_death_anim ) )
	{
		door.played_death_anim = true;
		door_org thread anim_single_solo( door, "death_2" );
	}
	wait( 0.5 );
	if ( isalive( guy ) )
	{
		if ( IsDefined( attacker ) )
		{
			guy Kill( ( 0, 0, 0 ), attacker );
		}
		else
		{
			//guy.a.nodeath = true;
			guy kill( ( 0, 0, 0 ) );
		}
	}
}

hiding_door_death_door_connections( door_clip, badplaceBrush )
{
	wait 2;
	
	if ( isdefined( door_clip ) )
		door_clip disconnectpaths();
	
	if ( isdefined( badplaceBrush ) )
		badPlace_Delete( badplaceBrush getentitynumber() );
}

hiding_door_starts_open( door_org )
{
	return ( isdefined( door_org.script_noteworthy ) && ( door_org.script_noteworthy == "starts_open" ) );
}