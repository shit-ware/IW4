#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "generic_human" );

DRONE_RUN_SPEED = 170;
TRACE_HEIGHT = 100;
MAX_DRONES_ALLIES = 99999;
MAX_DRONES_AXIS = 99999;
MAX_DRONES_TEAM3 = 99999;
MAX_DRONES_CIVILIAN = 99999;
DEATH_DELETE_FOV = 0.5; // cos(60)

initGlobals()
{
	//############################################################################
	//############################################################################
	// NEVER CALL THIS FUNCTION MANUALLY, THIS IS MEANT TO BE CALLED INTERNALLY!!!
	// NEVER CALL THIS FUNCTION MANUALLY, THIS IS MEANT TO BE CALLED INTERNALLY!!!
	// NEVER CALL THIS FUNCTION MANUALLY, THIS IS MEANT TO BE CALLED INTERNALLY!!!
	//############################################################################
	//############################################################################
	
	if ( getdvar( "debug_drones" ) == "" )
		setdvar( "debug_drones", "0" );
	
	assert( isdefined( level.drone_anims ) );
	
	// lookahead value - how far the character will lookahead for movement direction
	// larger number makes smother, more linear travel. small value makes character go almost exactly point to point
	if ( !isdefined( level.lookAhead_value ) )
		level.drone_lookAhead_value = 200;
	
	if ( !isdefined( level.max_drones ) )
		level.max_drones = [];
	if ( !isdefined( level.max_drones[ "allies" ] ) )
		level.max_drones[ "allies" ] = MAX_DRONES_ALLIES;
	if ( !isdefined( level.max_drones[ "axis" ] ) )
		level.max_drones[ "axis" ] = MAX_DRONES_AXIS;
	if ( !isdefined( level.max_drones[ "team3" ] ) )
		level.max_drones[ "team3" ] = MAX_DRONES_TEAM3;
	if ( !isdefined( level.max_drones[ "neutral" ] ) )
		level.max_drones[ "neutral" ] = MAX_DRONES_CIVILIAN;

	if ( !isdefined( level.drones ) )
		level.drones = [];
	if ( !isdefined( level.drones[ "allies" ] ) )
		level.drones[ "allies" ] = struct_arrayspawn();
	if ( !isdefined( level.drones[ "axis" ] ) )
		level.drones[ "axis" ] = struct_arrayspawn();
	if ( !isdefined( level.drones[ "team3" ] ) )
		level.drones[ "team3" ] = struct_arrayspawn();
	if ( !isdefined( level.drones[ "neutral" ] ) )
		level.drones[ "neutral" ] = struct_arrayspawn();
	
	level.drone_spawn_func = ::drone_init;
}

drone_give_soul()
{

	// Tell drone which animtree to use
	self useAnimTree( #animtree );

	// Tell drone to use hero-only lighting so they look like AI
	self startUsingHeroOnlyLighting();

	if ( isdefined( self.script_moveplaybackrate ) )
		self.moveplaybackrate = self.script_moveplaybackrate;
	else
		self.moveplaybackrate = 1;

	// Put a friendly name on the drone so they look like AI
	if ( self.team == "allies" )
	{
		// asign name
		self maps\_names::get_name();
		// string not found for 
		self setlookattext( self.name, &"" );
	}

	if ( isdefined( level.droneCallbackThread ) )
		self thread [[ level.droneCallbackThread ]]();

	// Run the friendly fire thread on this drone so the mission can be failed for killing friendly drones
	// Runs on all teams since friendly fire script also keeps track of enemies killed, etc.
	level thread maps\_friendlyfire::friendly_fire_think( self );
}

drone_init()
{
	// Dont keep this drone if we've reached the max population for that team of drones
	assertEx( isdefined( level.max_drones ), "You need to put maps\_drone::init(); in your level script!" );
	if ( level.drones[ self.team ].array.size >= level.max_drones[ self.team ] )
	{
		self delete();
		return;
	}
	
	thread drone_array_handling( self );
	
	// Give the drone default health and make it take damage like an AI does
	self setCanDamage( true );

	drone_give_soul();
	
	if ( isdefined( self.script_drone_override ) )
		return;

	// Wait until this drone loses it's health so it can die
	thread drone_death_thread();
		

	// If the drone targets something then make it move, otherwise just idle in place
	if ( isdefined( self.target ) ) 
	{
		if( !isdefined( self.script_moveoverride ) )
			self thread drone_move();
		else
			self thread drone_wait_move();
	}
	if ( ( isdefined( self.script_looping ) ) && ( self.script_looping == 0 ) )
	{
		return;
	}
	
	self thread drone_idle();
}

drone_array_handling( drone )
{
	structarray_add( level.drones[ drone.team ], drone );
	
	team = drone.team;
	
	drone waittill( "death" );
	
	if ( isdefined( drone ) && isdefined( drone.struct_array_index ) )
		structarray_remove_index( level.drones[ team ], drone.struct_array_index );
	else
		structarray_remove_undefined( level.drones[ team ] );
}

drone_death_thread()
{
	// Wait until the drone reaches 0 health
	while ( isdefined( self ) )
	{
		self waittill( "damage" );
		
		if ( isdefined( self.damageShield ) && self.damageShield )
		{
			self.health = 100000;
			continue;
		}
		
		if ( self.health <= 0 )
			break;
	}

	deathanim = level.drone_anims[ self.team ][ "stand" ][ "death" ];
	if( isdefined( self.deathanim ) )
		deathanim = self.deathanim;
	
	// Make drone die
	self notify( "death" );
	
	if ( !( isdefined( self.noragdoll ) && isdefined( self.skipDeathAnim ) ) )
	{
		if ( isdefined( self.noragdoll ) )
		{
			self drone_play_scripted_anim( deathanim, "deathplant" );
		}
		else
		if ( isdefined( self.skipDeathAnim ) )
		{
			self startragdoll();
			self drone_play_scripted_anim( deathanim, "deathplant" );
		}
		else
		{
			self drone_play_scripted_anim( deathanim, "deathplant" );
			self startragdoll();
		}
	}
	
	self notsolid();
	
	if( isdefined( self ) && isdefined( self.nocorpsedelete ) )
		return;

	wait 10;
	while( isdefined( self ) )
	{
		if ( !within_fov( level.player.origin, level.player.angles, self.origin, DEATH_DELETE_FOV ) )
			self delete();
		wait( 5 );
	}
}

// non-blocking loop animation used for idle/movement
drone_play_looping_anim( droneAnim, rate )
{
	self ClearAnim( %body, 0.2 );
	self StopAnimScripted();

	self SetFlaggedAnimKnobAllRestart( "drone_anim", droneAnim, %body, 1, 0.2, rate );
}

//blocking/scripted animation (when we're not moving)
drone_play_scripted_anim( droneAnim, deathplant )
{
	self clearAnim( %body, 0.2 );
	self stopAnimScripted();

	mode = "normal";
	if ( isdefined( deathplant ) )
		mode = "deathplant";

	flag = "drone_anim";
	self animscripted( flag, self.origin, self.angles, droneAnim, mode );

	//self animRelative( "drone_anim", self.origin, self.angles, droneAnim );
	self waittillmatch( "drone_anim", "end" );
}


/*
=============
///ScriptDocBegin
"Name: drone_drop_real_weapon_on_death()"
"Summary: Call this on a drone to have him drop a real weapon that can be picked up by the player"
"Module: Utility"
"CallOn: A spawned drone"
"Example: myDrone thread drone_drop_real_weapon_on_death()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
drone_drop_real_weapon_on_death()
{
	if ( !isdefined( self ) )
		return;
	
	self waittill( "death" );
	if( !isdefined( self ) )	//abort if deleted manually
		return;
		
	weapon_model = getWeaponModel( self.weapon );
	weapon = self.weapon;
	if ( isdefined( weapon_model ) )
	{
		//self waittill_match_or_timeout( "deathanim", "end", 4 );
		self detach( weapon_model, "tag_weapon_right" );
		org = self gettagorigin( "tag_weapon_right" );
		ang = self gettagangles( "tag_weapon_right" );
		gun = Spawn( "weapon_" + weapon, ( 0, 0, 0 ) );
		gun.angles = ang;
		gun.origin = org;
	}
	
}

drone_idle( lastNode, moveToDest )
{
	
	if ( ( isdefined( lastNode ) ) && ( isdefined( lastNode[ "script_noteworthy" ] ) ) && ( isdefined( level.drone_anims[ self.team ][ lastNode[ "script_noteworthy" ] ] ) ) )
	{
		//if the last node has a valid fight behavior in its script_noteworthy, fight from that node
		self thread drone_fight( lastNode[ "script_noteworthy" ], lastNode, moveToDest );
	}
	else
	{
		// Otherwise, just loop standard idle animation
		self drone_play_looping_anim( level.drone_anims[ self.team ][ "stand" ][ "idle" ], 1 );
	}

}

drone_get_goal_loc_with_arrival( dist, node )
{
	animset = node[ "script_noteworthy" ];
	if ( !isdefined( level.drone_anims[ self.team ][ animset ][ "arrival" ] ) )
		return dist;
	animDelta = GetMoveDelta( level.drone_anims[ self.team ][ animset ][ "arrival" ], 0, 1 );
	animDelta = length( animDelta );
	assertex( animDelta < dist, "Drone with export " + self.export + " does not have enough room to play an arrival anim. Space nodes out more and ensure he has a straight path into the last node"  );
	dist = ( dist - animDelta );
	return dist;
}
/*
ent_cleanup( drone )
{
	//cleanup the script_origin used to make arrivals work on uneven terrain
	self endon( "death" );
	drone waittill( "death" );
	if ( isdefined( self ) )
		self delete();
}
*/
drone_fight( animset, struct, moveToDest )
{

	self endon( "death" );
	self endon( "stop_drone_fighting" );
	self.animset = animset;
	self.weaponsound = undefined;
	iRand = randomintrange( 1, 4 );
	
	//assign drone a random weapon for sound variety
	if( self.team == "axis" )
	{
		if( iRand == 1 )
			self.weaponsound = "drone_ak47_fire_npc";
		else if( iRand == 2 )
			self.weaponsound = "drone_g36c_fire_npc";
		if( iRand == 3 )
			self.weaponsound = "drone_fnp90_fire_npc";
	}
	else
	{
		if( iRand == 1 )
			self.weaponsound = "drone_m4carbine_fire_npc";
		else if( iRand == 2 )
			self.weaponsound = "drone_m16_fire_npc";
		if( iRand == 3 )
			self.weaponsound = "drone_m249saw_fire_npc";
	}
	
	
	//commenting out arrival stuff for now....causes floating and other unpredictible behavior
	//attach drone to dummy node for arrival so he can arrive on uneven terrain
//	dummy = spawn( "script_origin", moveToDest );
//	dummy thread ent_cleanup( self );
//	dummy thread debug_message( "ORG", undefined, 9999, dummy );
//	dummy.origin = ( dummy.origin[ 0 ], dummy.origin[ 1 ], self.origin[ 2 ] );
//	self linkTo( dummy );
//	dummyTime = getanimlength( level.drone_anims[ self.team ][ animset ][ "arrival" ] );
//	dummyTime = dummyTime - 1;
//	dummy moveto( moveToDest + ( 0, 0, 2 ), dummyTime );
//	self drone_play_scripted_anim( level.drone_anims[ self.team ][ animset ][ "arrival" ] );
//	self unlink();
//	dummy delete();
	
	//make sure drone has no UP angle...should just play anim flat on the ground and not be tilted
	self.angles = ( 0, self.angles[ 1 ], self.angles[ 2 ] ); 	
	
	//move up a few units if prone...keeps getting buried in ground
	if ( animset == "coverprone" )
		self moveto( self.origin + ( 0, 0, 8 ), .05 );
	
	//set deathanim to one that will work with cover behavior
	self.noragdoll = true;
	self.deathanim = level.drone_anims[ self.team ][ animset ][ "death" ];
	bPopUpToFire = 1;
	while( isdefined( self ) )
	{
		//play random cover loop/twitch
		self drone_play_scripted_anim( level.drone_anims[ self.team ][ animset ][ "idle" ][ randomint( level.drone_anims[ self.team ][ animset ][ "idle" ].size ) ] );
		
	
		//pop up and fire
		if ( ( cointoss() ) && ( !isdefined( self.ignoreall ) ) )
		{
			//dont always pop up if prone
			if ( animset == "coverprone" )
			{
				if( cointoss() )
					bPopUpToFire = 0;
				else
					bPopUpToFire = 1;
			}
			//never pop up if coverguard
			else if (  animset == "coverguard" )
				bPopUpToFire = 0;
			
			if ( bPopUpToFire == 1 )
			{
				self drone_play_scripted_anim( level.drone_anims[ self.team ][ animset ][ "hide_2_aim" ] );
				wait( getanimlength( level.drone_anims[ self.team ][ animset ][ "hide_2_aim" ] ) - .5 );
			}
			
			//fire some blank bullets
			if ( isdefined( level.drone_anims[ self.team ][ animset ][ "fire" ] ) )
			{
				if ( ( animset == "coverprone" ) && ( bPopUpToFire == 1 ) )
					self thread drone_play_looping_anim( level.drone_anims[ self.team ][ animset ][ "fire_exposed" ], 1  );
				else
					self thread drone_play_looping_anim( level.drone_anims[ self.team ][ animset ][ "fire" ], 1  );
				
				self drone_fire_randomly();
			}
			else
			{
				//if no fire idle anim...just put out a quick burst
				self drone_shoot();
				wait(.15);
				self drone_shoot();
				wait(.15);
				self drone_shoot();
				wait(.15);
				self drone_shoot();
			}

			
			
			//dont always pop up if prone..never pop up if coverguard
			if ( bPopUpToFire == 1 )
				self drone_play_scripted_anim( level.drone_anims[ self.team ][ animset ][ "aim_2_hide" ] );
			
			//reload weapon
			self drone_play_scripted_anim( level.drone_anims[ self.team ][ animset ][ "reload" ] );
		}
	}
}

drone_fire_randomly()
{
	self endon( "death" );
	
	//randomly do bursts or single shots
	if( cointoss() )
	{
		self drone_shoot();
		wait( .1 );
		self drone_shoot();
		wait( .1 );
		self drone_shoot();
		
		if( cointoss() )
		{
			wait( .1 );
			self drone_shoot();
		}

		if( cointoss() )
		{
			wait( .1 );
			self drone_shoot();
			wait( .1 );
			self drone_shoot();
			wait( .1 );
		}
		if( cointoss() )
			wait( randomfloatrange( 1, 2 ) );
	}
	else
	{
		self drone_shoot();
		wait( randomfloatrange( .25, .75 ) );
		self drone_shoot();
		wait( randomfloatrange( .15, .75 ) );
		self drone_shoot();
		wait( randomfloatrange( .15, .75 ) );
		self drone_shoot();
		wait( randomfloatrange( .15, .75 ) );
	}

}

drone_shoot()
{
	self endon( "death" );
	self notify( "firing" );
	self endon( "firing" );
	drone_shoot_fx();
	fireAnim = %exposed_crouch_shoot_auto_v2;
	//SetAnimKnobRestart( <animation>, <weight>, <time>, <rate> )
	self setAnimKnobRestart( fireAnim, 1, .2, 1.0 );
	self delaycall( .25, ::clearAnim, fireAnim, 0 );
}

drone_shoot_fx()
{
	shoot_fx = getfx( "ak47_muzzleflash" );
	if ( self.team == "allies" )
	{
		shoot_fx = getfx( "m16_muzzleflash" );
	}
	
	self thread drone_play_weapon_sound( self.weaponsound );
	PlayFXOnTag( shoot_fx, self, "tag_flash" );
}

drone_play_weapon_sound( weaponsound )
{
	self playsound( weaponsound );
}

drone_wait_move()
{
	self endon( "death" );
	self waittill( "move" );
	self thread drone_move();	
}

drone_init_path()
{
	if ( !isdefined( self.target ) )
		return;
	if ( isdefined( level.drone_paths[ self.target ] ) )
		return;
	
	// don't process a path more than once
	level.drone_paths[ self.target ] = true;

	target = self.target;
	node = getstruct( target, "targetname" );
	if ( !isdefined( node ) )
		return;

	vectors = [];
	
	completed_nodes = [];
	original_node = node;

	for ( ;; )
	{
		node = original_node;
		found_new_node = false;
		
		for ( ;; )
		{
			if ( !isdefined( node.target ) )
				break;
			
			nextNodes = getstructarray( node.target, "targetname" );
			if ( nextNodes.size )
				break;
			
			nextNode = undefined;
			foreach ( newNode in nextNodes )
			{
				// origin should be unique per node
				if ( isdefined( completed_nodes[ newNode.origin + "" ] ) )
					continue;
				
				nextNode = newNode;
				break;
			}
			if ( !isdefined( nextNode ) )
				break;
			
			completed_nodes[ nextNode.origin + "" ] = true;
			
			//Line( node.origin, nextNode.origin, (1,1,1), 1, 0, 5000 );
			vectors[ node.targetname ] = nextNode.origin - node.origin;
			node.angles = vectortoangles( vectors[ node.targetname ] );
				
			node = nextNode;
			found_new_node = true;
		}
		
		if ( !found_new_node )
			break;
	}

	// now average the angles so they take corners properly
	target = self.target;
	node = getstruct( target, "targetname" );
	prevNode = node;
	completed_nodes = [];

	for ( ;; )
	{
		node = original_node;
		found_new_node = false;

		for ( ;; )
		{
			if ( !isdefined( node.target ) )
				return;
			
			if ( !isdefined( vectors[ node.targetname ] ) )
				return;

			nextNodes = getstructarray( node.target, "targetname" );
			if ( nextNodes.size )
				break;
			
			nextNode = undefined;
			foreach ( newNode in nextNodes )
			{
				// origin should be unique per node
				if ( isdefined( completed_nodes[ newNode.origin + "" ] ) )
					continue;
				
				nextNode = newNode;
				break;
			}
			if ( !isdefined( nextNode ) )
				break;
	
			
			if ( isdefined( node.radius ) )
			{
				vec1 = vectors[ prevNode.targetname ];
				vec2 = vectors[ node.targetname ];
				vec = ( vec1 + vec2 ) * 0.5;
				node.angles = vectorToAngles( vec );
				
				/*
				Line( node.origin, node.origin + vec1, (1,0,0), 1, 1, 1000 );
				Line( node.origin, node.origin + vec2, (0,0,1), 1, 1, 1000 );
				Line( node.origin, node.origin + vec, (0,1,0), 1, 1, 1000 );
				
				/#
				thread maps\_debug::drawArrowForever( node.origin, node.angles );
				#/
				*/
			}
				
			found_new_node = true;
			prevNode = node;
			node = nextNode;
		}

		if ( !found_new_node )
			break;
	}
}

drone_move()
{
	self endon( "death" );

	// Loop run animation
	wait randomfloat( 0.5 );
	
	runAnim = level.drone_anims[ self.team ][ "stand" ][ "run" ];
	if ( isdefined( self.runanim ) )
		runAnim = self.runanim;
		
	self drone_play_looping_anim( runAnim, self.moveplaybackrate );
	
	nodes = self getPathArray( self.target, self.origin );
	assert( isdefined( nodes ) );
	assert( isdefined( nodes[ 0 ] ) );

	prof_begin( "drone_math" );

	loopTime = 0.5;
	currentNode_LookAhead = 0;
	for ( ;; )
	{
		if ( !isdefined( nodes[ currentNode_LookAhead ] ) )
			break;

		// Calculate how far and what direction the lookahead path point should move
		//--------------------------------------------------------------------------

		// find point on real path where character is
		vec1 = nodes[ currentNode_LookAhead ][ "vec" ];
		vec2 = ( self.origin - nodes[ currentNode_LookAhead ][ "origin" ] );
		distanceFromPoint1 = vectorDot( vectorNormalize( vec1 ), vec2 );

		// check if this is the last node (wont have a distance value)
		if ( !isdefined( nodes[ currentNode_LookAhead ][ "dist" ] ) )
			break;

		lookaheadDistanceFromNode = ( distanceFromPoint1 + level.drone_lookAhead_value );
		assert( isdefined( lookaheadDistanceFromNode ) );

		assert( isdefined( currentNode_LookAhead ) );
		assert( isdefined( nodes[ currentNode_LookAhead ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "dist" ] ) );

		while ( lookaheadDistanceFromNode > nodes[ currentNode_LookAhead ][ "dist" ] )
		{
			// moving the lookahead would pass the node, so move it the remaining distance on the vector of the next node
			lookaheadDistanceFromNode = lookaheadDistanceFromNode - nodes[ currentNode_LookAhead ][ "dist" ];
			currentNode_LookAhead++ ;

			if ( !isdefined( nodes[ currentNode_LookAhead ][ "dist" ] ) )
			{
				//last node on the chain
				self rotateTo( vectorToAngles( nodes[ nodes.size - 1 ][ "vec" ] ), loopTime );
				d = distance( self.origin, nodes[ nodes.size - 1 ][ "origin" ] );
				timeOfMove = ( d / ( DRONE_RUN_SPEED * self.moveplaybackrate ) );
				
				//compensate for arrivals, if any
//				timeOfMoveWithArrival = undefined;
//				if ( isdefined( nodes[ nodes.size - 1 ][ "script_noteworthy" ] ) )
//				{
//					d = drone_get_goal_loc_with_arrival( d, nodes[ nodes.size - 1 ] );
//					timeOfMoveWithArrival = ( d / ( DRONE_RUN_SPEED * self.moveplaybackrate ) );
//				}

				traceOrg1 = nodes[ nodes.size - 1 ][ "origin" ] + ( 0, 0, TRACE_HEIGHT );
				traceOrg2 = nodes[ nodes.size - 1 ][ "origin" ] - ( 0, 0, TRACE_HEIGHT );
				moveToDest = physicstrace( traceOrg1, traceOrg2 );

				if ( getdvar( "debug_drones" ) == "1" )
				{
					thread draw_line_for_time( traceOrg1, traceOrg2, 1, 1, 1, loopTime );
					thread draw_line_for_time( self.origin, moveToDest, 0, 0, 1, loopTime );
				}
				self moveTo( moveToDest, timeOfMove );
				
//				if ( isdefined( timeOfMoveWithArrival ) )
//					wait timeOfMoveWithArrival;
//				else
//					wait timeOfMove;
				wait timeOfMove;
				prof_end( "drone_math" );
				self notify( "goal" );
				self thread check_delete();
				self thread drone_idle( nodes[ nodes.size - 1 ], moveToDest );
				return;
			}

			if ( !isdefined( nodes[ currentNode_LookAhead ] ) )
			{
				prof_end( "drone_math" );
				self notify( "goal" );
				self thread drone_idle();
				return;
			}

			assert( isdefined( nodes[ currentNode_LookAhead ] ) );
		}
		//-------------------------------------------------------------------------


		// Move the lookahead point down along it's path
		//----------------------------------------------
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ][ 0 ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ][ 1 ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ][ 2 ] ) );
		desiredPosition = vector_multiply( nodes[ currentNode_LookAhead ][ "vec" ], lookaheadDistanceFromNode );
		desiredPosition = desiredPosition + nodes[ currentNode_LookAhead ][ "origin" ];
		lookaheadPoint = desiredPosition;
		// trace the lookahead point to the ground
		traceOrg1 = lookaheadPoint + ( 0, 0, TRACE_HEIGHT );
		traceOrg2 = lookaheadPoint - ( 0, 0, TRACE_HEIGHT );
		lookaheadPoint = physicstrace( traceOrg1, traceOrg2 );
		
		if ( getdvar( "debug_drones" ) == "1" )
		{
			thread draw_line_for_time( traceOrg1, traceOrg2, 1, 1, 1, loopTime );
			thread draw_point( lookaheadPoint, 1, 0, 0, 16, loopTime );
			println( lookaheadDistanceFromNode + "/" + nodes[ currentNode_LookAhead ][ "dist" ] + " units forward from node[" + currentNode_LookAhead + "]" );
		}
		//---------------------------------------------


		//Rotate character to face the lookahead point
		//--------------------------------------------
		assert( isdefined( lookaheadPoint ) );
		characterFaceDirection = VectorToAngles( lookaheadPoint - self.origin );
		assert( isdefined( characterFaceDirection ) );
		assert( isdefined( characterFaceDirection[ 0 ] ) );
		assert( isdefined( characterFaceDirection[ 1 ] ) );
		assert( isdefined( characterFaceDirection[ 2 ] ) );
		self rotateTo( ( 0, characterFaceDirection[ 1 ], 0 ), loopTime );
		//--------------------------------------------


		//Move the character in the direction of the lookahead point
		//----------------------------------------------------------
		characterDistanceToMove = ( DRONE_RUN_SPEED * loopTime * self.moveplaybackrate );
		moveVec = vectorNormalize( lookaheadPoint - self.origin );
		desiredPosition = vector_multiply( moveVec, characterDistanceToMove );
		desiredPosition = desiredPosition + self.origin;
		if ( getdvar( "debug_drones" ) == "1" )
			thread draw_line_for_time( self.origin, desiredPosition, 0, 0, 1, loopTime );
		self moveTo( desiredPosition, loopTime );
		//----------------------------------------------------------

		wait loopTime;
	}
	
	
	self thread drone_idle();
	
	prof_end( "drone_math" );
}

getPathArray( firstTargetName, initialPoint )
{
	//#########################################################################################################
	//	make an array of all the points along the spline starting with the characters current position,
	//	then starting with the point with the passed in targetname
	//
	//	information stored in array:
	//
	//	origin - origin of the node
	//	dist - distance to the next node ( will be undefined if there is not a next node )
	//	vec	- vector to the next node ( if there is not a next node, the vector will be the same as the previous node )
	//	script_noteworthy - script_noteworthy of the node if defined
	//
	//#########################################################################################################

	usingNodes = true;
	assert( isdefined( firstTargetName ) );

	prof_begin( "drone_math" );

	assert( isdefined( initialPoint ) );
	
	nodes = [];
	nodes[ 0 ][ "origin" ] = initialPoint;
	nodes[ 0 ][ "dist" ] = 0;
	

	nextNodeName = undefined;
	nextNodeName = firstTargetName;

	get_target_func[ "entity" ] 	= maps\_spawner::get_target_ents;
	get_target_func[ "node" ] 		= maps\_spawner::get_target_nodes;
	get_target_func[ "struct" ] 	= maps\_spawner::get_target_structs;
	
	goal_type = undefined;
	test_ent = [[ get_target_func[ "entity" ] ]]( nextNodeName );
	test_nod = [[ get_target_func[ "node" ] ]]( nextNodeName );
	test_str = [[ get_target_func[ "struct" ] ]]( nextNodeName );
	
	if( test_ent.size )
		goal_type = "entity";
	else
	if( test_nod.size )
		goal_type = "node";
	else
	if( test_str.size )
		goal_type = "struct";
			
	for ( ;; )
	{
		index = nodes.size;

		// get the next node in the chain
		nextNodes = [[ get_target_func[ goal_type ] ]]( nextNodeName );
		node = random( nextNodes );
/*
		// no script_struct was found
		if ( !isdefined( node ) )
		{
			if ( index == 0 )
				assertMsg( "Drone was told to walk to a node with a targetname that doesnt match a script_struct targetname" );
			break;
		}
*/
		// add this node information to the chain data array
		org = node.origin;

		//check for radius on node, since you can make them run to a radius rather than an exact point
		if ( isdefined( node.radius ) )
		{
			assert( node.radius > 0 );

			// offset for this drone (-1 to 1)
			if ( !isdefined( self.droneRunOffset ) )
				self.droneRunOffset = ( 0 - 1 + ( randomfloat( 2 ) ) );

			if ( !isdefined( node.angles ) )
				node.angles = ( 0, 0, 0 );

			prof_begin( "drone_math" );
				forwardVec = anglestoforward( node.angles );
				rightVec = anglestoright( node.angles );
				upVec = anglestoup( node.angles );
				relativeOffset = ( 0, ( self.droneRunOffset * node.radius ), 0 );
				org += vector_multiply( forwardVec, relativeOffset[ 0 ] );
				org += vector_multiply( rightVec, relativeOffset[ 1 ] );
				org += vector_multiply( upVec, relativeOffset[ 2 ] );
			prof_end( "drone_math" );
		}
		nodes[ index ][ "origin" ] = org;
		if ( isdefined( node.script_noteworthy ) )
			nodes[ index ][ "script_noteworthy" ] = node.script_noteworthy;
			
		// find the distance from the previous node to this node, and the vector of of the previous node to this node
		// then add the info to the previous nodes data
		nodes[ index - 1 ][ "dist" ] = distance( nodes[ index ][ "origin" ], nodes[ index - 1 ][ "origin" ] );
		nodes[ index - 1 ][ "vec" ] = vectorNormalize( nodes[ index ][ "origin" ] - nodes[ index - 1 ][ "origin" ] );
			
		//if the node doesn't target another node then it's the last of the chain
		if ( !isdefined( node.target ) )
			break;
		//it targets something
		nextNodeName = node.target;
	}

	nodes[ index ][ "vec" ] = nodes[ index - 1 ][ "vec" ];

	node = undefined;

	prof_end( "drone_math" );

	return nodes;
}

draw_point( org, r, g, b, size, time )
{
	point1 = org + ( size, 0, 0 );
	point2 = org - ( size, 0, 0 );
	thread draw_line_for_time( point1, point2, r, g, b, time );
	
	point1 = org + ( 0, size, 0 );
	point2 = org - ( 0, size, 0 );
	thread draw_line_for_time( point1, point2, r, g, b, time );
	
	point1 = org + ( 0, 0, size );
	point2 = org - ( 0, 0, size );
	thread draw_line_for_time( point1, point2, r, g, b, time );
}

check_delete()
{
	if ( !isdefined( self ) )
		return;
	
	if ( !isdefined( self.script_noteworthy ) )
		return;
	
	if ( self.script_noteworthy != "delete_on_goal" )
		return;
	
	self delete();
}
