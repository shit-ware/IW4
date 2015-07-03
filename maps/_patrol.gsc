#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;

#using_animtree( "generic_human" );
patrol( start_target )
{
	if ( isdefined( self.enemy ) )
		return;
	self endon( "enemy" );

	self endon( "death" );
	self endon( "damage" );
	self endon( "end_patrol" );
	if ( isdefined( self.script_stealthgroup ) )
		[[ level.global_callbacks[ "_patrol_endon_spotted_flag" ] ]]();
		
	self thread waittill_combat();
	self thread waittill_death();

	self.goalradius = 32;
	self allowedStances( "stand" );
	self.disableArrivals = true;
	self.disableExits = true;
	self.allowdeath = true;
	self.script_patroller = 1;
	self disable_cqbwalk();

	self linkPet();

	self set_patrol_run_anim_array();
	
	// 1st boolean, true is for origins, false is for nodes
	// 2nd boolean, true is for targetname linking, false is for linkto
	get_goal_func[ "ent" ][ true ] 		 = ::get_target_ents;
	get_goal_func[ "ent" ][ false ] 	 = ::get_linked_ents;
	get_goal_func[ "node" ][ true ] 	 = ::get_target_nodes;
	get_goal_func[ "node" ][ false ] 	 = ::get_linked_nodes;
	get_goal_func[ "struct" ][ true ] 	 = ::get_target_structs;
	get_goal_func[ "struct" ][ false ] 	 = ::get_linked_structs;
	set_goal_func[ "ent" ] 		 = ::set_goal_ent;
	set_goal_func[ "node" ] 	 = ::set_goal_node;
	set_goal_func[ "struct" ] 	 = ::set_goal_ent;

	if ( isdefined( start_target ) )
		self.target = start_target;

	assertEx( isdefined( self.target ) || isdefined( self.script_linkto ), "Patroller with no target or script_linkto defined." );

	if ( isdefined( self.target ) )
	{
		link_type = true;
		ents 	 = self get_target_ents();
		nodes 	 = self get_target_nodes();
		structs = self get_target_structs();

		if ( ents.size )
		{
			currentgoal = random( ents );
			goal_type = "ent";
		}
		else if ( nodes.size )
		{
			currentgoal = random( nodes );
			goal_type = "node";
		}
		else
		{
			currentgoal = random( structs );
			goal_type = "struct";
		}
	}
	else
	{
		link_type = false;
		ents 	 = self get_linked_ents();
		nodes 	 = self get_linked_nodes();
		structs = self get_linked_structs();

		if ( ents.size )
		{
			currentgoal = random( ents );
			goal_type = "ent";
		}
		else if ( nodes.size )
		{
			currentgoal = random( nodes );
			goal_type = "node";
		}
		else
		{
			currentgoal = random( structs );
			goal_type = "struct";
		}
	}

	assertex( isdefined( currentgoal ), "Initial goal for patroller is undefined" );

	patrol_idle_anim_table = [];
	patrol_idle_anim_table["pause"] = "patrol_idle_";
	patrol_idle_anim_table["turn180"] = "patrol_turn180";
	patrol_idle_anim_table["smoke"] = "patrol_idle_smoke";
	patrol_idle_anim_table["stretch"] = "patrol_idle_stretch";
	patrol_idle_anim_table["checkphone"] = "patrol_idle_checkphone";
	patrol_idle_anim_table["phone"] = "patrol_idle_phone";

	nextgoal = currentgoal;
	for ( ;; )
	{
		while ( isdefined( nextgoal.patrol_claimed ) )
		{
			// self animscripted( "scripted_animdone", self.origin, self.angles, getGenericAnim( "pause" ) );
			// self waittill( "scripted_animdone" );
			wait 0.05;
		}

		currentgoal.patrol_claimed = undefined;
		currentgoal = nextgoal;
		self notify( "release_node" );

		assertex( !isdefined( currentgoal.patrol_claimed ), "Goal was already claimed" );
		currentgoal.patrol_claimed = true;
		// self thread showclaimed( currentgoal );

		//this is for stealth code...so we can send him back to his patrol node if need be
		self.last_patrol_goal = currentgoal;

		[[ set_goal_func[ goal_type ] ]]( currentgoal );
		//check for both defined and size - because ents dont have radius defined by 
		//default - but nodes do - and that radius is 0 by default.
		if ( isdefined( currentgoal.radius ) && currentgoal.radius > 0 )
			self.goalradius = currentgoal.radius;
		else
			self.goalradius = 32;

		self waittill( "goal" );
		
		currentgoal notify( "trigger", self );
		
		//HANDLE SCRIPT_FLAG_SET and friends - z
		if ( isdefined( currentgoal.script_flag_set ) )
		{
			flag_set( currentgoal.script_flag_set );
		}
		
		if ( isdefined( currentgoal.script_ent_flag_set ) )
		{
			self ent_flag_set( currentgoal.script_ent_flag_set );
		}
		
		if ( isdefined( currentgoal.script_flag_clear ) )
		{
			flag_clear( currentgoal.script_flag_clear );
		}
		

		currentgoals = currentgoal [[ get_goal_func[ goal_type ][ link_type ] ]]();

		if ( !currentgoals.size )
		{
			self notify( "reached_path_end" );
			self notify( "_patrol_reached_path_end" );
			if( isalive( self.patrol_pet ) )
				self.patrol_pet notify( "master_reached_patrol_end" );
		}
		
		if( isdefined( currentgoal.script_delay ) )
			wait currentgoal.script_delay;
			
		if( IsDefined( currentgoal.script_flag_wait ) )
		{
			flag_wait( currentgoal.script_flag_wait );
		}
		
		reactionAnimThread = animscripts\reactions::reactionsCheckLoop;
		animType = currentgoal.script_animation;
		
		if ( isdefined( animType ) )
		{
			// come to a stop
			self patrol_do_stop_transition_anim( animType, reactionAnimThread );
			
			//for pets
			self.patrol_script_animation = 1;
			
			// now pick the anim to use and do it
			anime = patrol_idle_anim_table[ animType ];
			if ( isdefined( anime ) )
			{
				if ( animType == "pause" )
				{
					if( IsDefined( self.patrol_scriptedanim ) && IsDefined( self.patrol_scriptedanim[ animType ] ) )
					{
						anime = self.patrol_scriptedanim[ animType ][ RandomInt( self.patrol_scriptedanim[ animType ].size ) ];
					}
					else
					{
						anime = anime + randomintrange( 1, 6 );
					}
				}
				
				self anim_generic_custom_animmode( self, "gravity", anime, undefined, reactionAnimThread );
				
				// if we should keep moving, and we're not going to spin around, start walking forward again
				if ( currentgoals.size && animType != "turn180" )
				{
					self patrol_do_start_transition_anim( animType, reactionAnimThread );
				}
			}

			self.patrol_script_animation = undefined;
		}

		if ( !currentgoals.size )
		{			
			// see if we have a custom end idle to do, but don't do it if we already did an idle on this node (can't guarantee a good-looking blend)
			if( IsDefined( self.patrol_end_idle ) && !IsDefined( animType ) )
			{
				self patrol_do_stop_transition_anim( "path_end_idle", reactionAnimThread );
				
				while( 1 )
				{
					idleAnim = self.patrol_end_idle[ RandomInt( self.patrol_end_idle.size ) ];
					self anim_generic_custom_animmode( self, "gravity", idleAnim, undefined, reactionAnimThread );
				}
			}
			
			break;
		}

		nextgoal = random( currentgoals );
	}
}

patrol_do_stop_transition_anim( animType, reactionAnimThread )
{
	if( IsDefined( self.patrol_stop ) && IsDefined( self.patrol_stop[ animType ] ) )
	{
		self anim_generic_custom_animmode( self, "gravity", self.patrol_stop[ animType ], undefined, reactionAnimThread );
	}
	else
	{
		self anim_generic_custom_animmode( self, "gravity", "patrol_stop", undefined, reactionAnimThread );
	}
}

patrol_do_start_transition_anim( animType, reactionAnimThread )
{
	if( IsDefined( self.patrol_start ) && IsDefined( self.patrol_start[ animType ] ) )
	{
		self anim_generic_custom_animmode( self, "gravity", self.patrol_start[ animType ], undefined, reactionAnimThread );
	}
	else
	{
		self anim_generic_custom_animmode( self, "gravity", "patrol_start", undefined, reactionAnimThread );
	}
}

stand_up_if_necessary()
{
	if ( self.a.pose == "crouch" && isdefined( self.a.array ) )
	{
		standUpAnim = self.a.array[ "stance_change" ];
		if ( isdefined( standUpAnim ) )
		{
			self SetFlaggedAnimKnobAllRestart( "stand_up", standUpAnim, %root, 1 );
			self animscripts\shared::DoNoteTracks( "stand_up" );
		}
	}
}

patrol_resume_move_start_func()
{
	self endon( "enemy" );
	
	self animmode( "zonly_physics", false );
	self orientmode( "face current" );

	stand_up_if_necessary();
	
	radioAnim = level.scr_anim[ "generic" ][ "patrol_radio_in_clear" ];

	self SetFlaggedAnimKnobAllRestart( "radio", radioAnim, %root, 1 );
	self animscripts\shared::DoNoteTracks( "radio" );
	
	turn_180_move_start_func();
}

turn_180_move_start_func()
{
	if ( !isdefined( self.pathgoalpos ) )
		return;

	pos = self.pathgoalpos;

	vec2 = pos - self.origin;
	vec2 = ( vec2[0], vec2[1], 0 );
	vec2LengthSq = lengthSquared( vec2 );
	
	if ( vec2LengthSq < 1 )
		return;
		
	vec2 = vec2 / sqrt( vec2LengthSq );	

	vec1 = anglestoforward( self.angles );

	// if the goal is behind him - do a 180 anim
	if ( vectordot( vec1, vec2 ) < -0.5 )
	{
		self animmode( "zonly_physics", false );
		self orientmode( "face current" );
		
		stand_up_if_necessary();
		
		turnAnim = level.scr_anim[ "generic" ][ "patrol_turn180" ];
		
		self SetFlaggedAnimKnobAllRestart( "move", turnAnim, %root, 1 );

		if ( animHasNotetrack( turnAnim, "code_move" ) )
		{
			self animscripts\shared::DoNoteTracks( "move" );	// return on code_move
			self OrientMode( "face motion" );
			self animmode( "none", false );
		}

		self animscripts\shared::DoNoteTracks( "move" );
	}
}


set_patrol_run_anim_array()
{
	walkanim = "patrol_walk";
	if ( IsDefined( self.patrol_walk_anim ) )
	{
		walkanim = self.patrol_walk_anim;
	}
		
	twitch_weights = undefined;
	if ( IsDefined( self.patrol_walk_twitch ) )
	{
		twitch_weights = self.patrol_walk_twitch;
	}
		
	self set_generic_run_anim_array( walkanim, twitch_weights );
}

waittill_combat_wait()
{
	self endon( "end_patrol" );
	
	if ( isdefined( self.patrol_master ) )
		self.patrol_master endon( "death" );

	self waittill( "enemy" );
}

waittill_death()
{
	self waittill( "death" );

	if ( !isdefined( self ) )
		return;

	self notify( "release_node" );

	if ( !isdefined( self.last_patrol_goal ) )
		return;

	self.last_patrol_goal.patrol_claimed = undefined;
}

waittill_combat()
{
	self endon( "death" );

	assert( !isdefined( self.enemy ) );

	waittill_combat_wait();
	
	stealth = ( self ent_flag_exist( "_stealth_enabled" ) && self ent_flag( "_stealth_enabled" ) );
	if ( !stealth )
	{
		self clear_run_anim();
		self allowedStances( "stand", "crouch", "prone" );
		self.disableArrivals = false;
		self.disableExits = false;
		self stopanimscripted();
		self notify( "stop_animmode" );

		self.script_nobark = undefined;
		self.goalradius = level.default_goalradius;
	}
	
	if ( isdefined( self.old_interval ) )
		self.interval = self.old_interval;
	self.moveplaybackrate = 1;

	if ( !isdefined( self ) )
		return;

	self notify( "release_node" );

	if ( !isdefined( self.last_patrol_goal ) )
		return;

	self.last_patrol_goal.patrol_claimed = undefined;
}

get_target_ents()
{
	array = [];

	if ( isdefined( self.target ) )
		array = getentarray( self.target, "targetname" );

	return array;
}

get_target_nodes()
{
	array = [];

	if ( isdefined( self.target ) )
		array = getnodearray( self.target, "targetname" );

	return array;
}

get_target_structs()
{
	array = [];

	if ( isdefined( self.target ) )
		array = getstructarray( self.target, "targetname" );

	return array;
}

get_linked_nodes()
{
	array = [];

	if ( isdefined( self.script_linkto ) )
	{
		linknames = strtok( self.script_linkto, " " );
		for ( i = 0; i < linknames.size; i++ )
		{
			ent = getnode( linknames[ i ], "script_linkname" );
			if ( isdefined( ent ) )
				array[ array.size ] = ent;
		}
	}

	return array;
}

showclaimed( goal )
{
	self endon( "release_node" );

	 /#
	for ( ;; )
	{
		entnum = self getentnum();
		print3d( goal.origin, entnum, ( 1.0, 1.0, 0.0 ), 1 );
		wait 0.05;
	}
	#/
}



//////////////////////////////////////////////////////////??//////////////////
/*									PETS									*/
//////////////////////////////////////////////////////////??//////////////////

linkPet()
{
	if ( isdefined( self.patrol_pet ) )
	{
		self.patrol_pet thread pet_patrol();
		return;
	}

	if ( !isdefined( self.script_pet ) )
		return;

	waittillframeend;// make sure everyone is spawned;

	pets = getaispeciesarray( self.team, "dog" );
	pet = undefined;

	for ( i = 0; i < pets.size; i++ )
	{
		if ( !isdefined( pets[ i ].script_pet ) )
			continue;
		if ( pets[ i ].script_pet != self.script_pet )
			continue;

		pet = pets[ i ];
		self.patrol_pet = pet;
		pet.patrol_master = self;
		break;
	}

	if ( !isdefined( pet ) )
		return;

	pet thread pet_patrol();
}

pet_patrol()
{
	spawn_failed( self );

	if ( isdefined( self.enemy ) )
		return;
	self endon( "enemy" );

	self endon( "death" );
	self endon( "end_patrol" );
	if ( isdefined( self.script_stealthgroup ) )
		[[ level.global_callbacks[ "_patrol_endon_spotted_flag" ] ]]();
	
	self.patrol_master endon( "death" );

	self thread waittill_combat();

	self.goalradius = 4;
	self.allowdeath = true;
//	self.script_patroller = 1;		

	positions = pet_patrol_create_positions();

	//find out where the dog is spawned...left or right
	forward = vectornormalize( self.origin - self.patrol_master.origin );
	right = anglestoright( self.patrol_master.angles );

	curr_pos = "left";
	if ( vectordot( forward, right ) > 0 )
		curr_pos = "right";

	wait 1;// wait for everyone to actually start moving

	self thread pet_patrol_handle_move_state();
	self thread pet_patrol_handle_movespeed();
	self.old_interval = self.interval;
	self.interval = 70;

	while ( 1 )
	{
		if ( isdefined( self.patrol_master ) && !isdefined( self.patrol_master.patrol_script_animation ) )
		{
			positions = pet_patrol_init_positions( positions );

			//pet_debug_positions( positions );

			if ( curr_pos == "null" )
			{
				curr_pos = "back";
			}

			curr_pos = pet_patrol_get_available_origin( positions, curr_pos );
			self.patrol_goal_pos = positions[ curr_pos ].origin;
		}
		else
		{
			self.patrol_goal_pos = self.origin;
		}

		self setgoalpos( self.patrol_goal_pos );
		wait .05;
	}
}

pet_patrol_create_positions()
{
	positions = [];

	right = spawnstruct();
	right.options = [];
	right.options[ right.options.size ] = "right";
	right.options[ right.options.size ] = "back_right";

	backright = spawnstruct();
	backright.options = [];
	backright.options[ backright.options.size ] = "right";
	backright.options[ backright.options.size ] = "back_right";
	backright.options[ backright.options.size ] = "back";

	back = spawnstruct();
	back.options = [];
	back.options[ back.options.size ] = "back_right";
	back.options[ back.options.size ] = "back_left";
	back.options[ back.options.size ] = "back";

	backleft = spawnstruct();
	backleft.options = [];
	backleft.options[ backleft.options.size ] = "left";
	backleft.options[ backleft.options.size ] = "back_left";
	backleft.options[ backleft.options.size ] = "back";

	left = spawnstruct();
	left.options = [];
	left.options[ left.options.size ] = "left";
	left.options[ left.options.size ] = "back_left";

	null = spawnstruct();

	positions[ "right" ]		 = right;
	positions[ "left" ] 		 = left;
	positions[ "back_right" ] 	 = backright;
	positions[ "back_left" ] 	 = backleft;
	positions[ "back" ] 		 = back;
	positions[ "null" ] 		 = null;

	return positions;
}

pet_patrol_init_positions( positions )
{
	//dont want to use angles because of animations when in idle
	angles = vectortoangles( self.patrol_master.last_patrol_goal.origin - self.patrol_master.origin );

	//calculate the goal pos
	origin = self.patrol_master.origin;
	right = anglestoright( angles );
	forward = anglestoforward( angles );

	//don't do positions.size because the array will constantly grow.
	positions[ "right" ].origin			 = origin + vector_multiply( right, 40 ) + vector_multiply( forward, 30 );	// right
	positions[ "left" ].origin 			 = origin + vector_multiply( right, -40 ) + vector_multiply( forward, 30 );	// left
	positions[ "back_right" ].origin 	 = origin + vector_multiply( right, 32 ) + vector_multiply( forward, -16 );	// back right
	positions[ "back_left" ].origin 	 = origin + vector_multiply( right, -32 ) + vector_multiply( forward, -16 );	// back left
	positions[ "back" ].origin 			 = origin + vector_multiply( forward, -48 );									// back
	positions[ "null" ].origin			 = self.origin;

	keys = getarraykeys( positions );
	for ( i = 0; i < keys.size; i++ )
	{
		key = keys[ i ];
		positions[ key ].checked = false;
		positions[ key ].recursed = false;
	}

	return positions;
}

pet_debug_positions( positions )
{
	keys = getarraykeys( positions );
	for ( i = 0; i < keys.size; i++ )
	{
		key = keys[ i ];
		if ( key == "null" )
			continue;
		print3d( positions[ key ].origin, "o", ( 0, 1, 0 ), 1, .5 );
	}
}

pet_patrol_get_available_origin( positions, curr )
{
	positions[ curr ].recursed = true;

	for ( i = 0; i < positions[ curr ].options.size; i++ )
	{
		name = positions[ curr ].options[ i ];

		if ( positions[ name ].checked )
			continue;

		if ( self maymovetopoint( positions[ name ].origin ) )
			return name;

		positions[ name ].checked = true;
	}

	for ( i = 0; i < positions[ curr ].options.size; i++ )
	{
		name = positions[ curr ].options[ i ];

		if ( positions[ name ].recursed )
			continue;

		name = pet_patrol_get_available_origin( positions, name );
		return name;
	}

	return "null";
}

pet_patrol_handle_move_state( walkdist )
{
	if ( isdefined( self.enemy ) )
		return;
	self endon( "enemy" );

	self endon( "death" );
	self endon( "end_patrol" );
		
	self.patrol_master endon( "death" );

	if( isdefined( self.patrol_master.script_noteworthy ) && ( self.patrol_master.script_noteworthy == "cqb_patrol" ) )
	{
		//always walk
		self set_dog_walk_anim();
		return;
	}



	if ( !isdefined( walkdist ) )
		walkdist = 200;//was 200
	
	//min_walkdist = 30;

	//move_state = "walk";
	self set_dog_walk_anim();
	
	while ( 1 )
	{
		//wait first so we have a self.patrol_goal_pos;
		wait .1;

		origin = self.patrol_goal_pos;

		dist = distancesquared( self.origin, self.patrol_goal_pos );

		if ( dist > squared( walkdist ) )
		{
			//we want to run
			if ( self.a.movement == "run" )
				continue;

			self anim_generic_custom_animmode( self, "gravity", "patrol_dog_start" );
			self clear_run_anim();
			self.script_nobark = 1;
		}
		else if ( self.a.movement != "walk" )
		{
			//we want to walk
			self notify( "stopped_while_patrolling" );
			self anim_generic_custom_animmode( self, "gravity", "patrol_dog_stop" );
			self set_dog_walk_anim();
		}
	}
}

pet_patrol_handle_movespeed( tooclose, toofar )
{
	if ( isdefined( self.enemy ) )
		return;
	self endon( "enemy" );

	self endon( "death" );
	self endon( "end_patrol" );
		
	self.patrol_master endon( "death" );

	if( isdefined( self.patrol_master.script_noteworthy ) && ( self.patrol_master.script_noteworthy == "cqb_patrol" ) )
	{
		while ( 1 )
		{
			wait .05;
			origin = self.patrol_goal_pos;
			dist = distancesquared( self.origin, self.patrol_goal_pos );
			
			//println( self.a.movement + " speed: " + self.moveplaybackrate );
			
			if ( dist < squared( 16 ) )
			{
				if ( self.moveplaybackrate > .4 )
					self.moveplaybackrate -= .05;
			}
			else if ( dist > squared( 48 ) )
			{
				if ( self.moveplaybackrate < 1.8 )
					self.moveplaybackrate += .05;
			}
			else
				self.moveplaybackrate = 1;
		}
	}

	if ( !isdefined( tooclose ) )
		tooclose = 16;
	if ( !isdefined( toofar ) )
		toofar = 48;

	tooclose2rd = tooclose * tooclose;
	toofar2rd = toofar * toofar;

	while ( 1 )
	{
		//wait first so we have a self.patrol_goal_pos;
		wait .05;

		origin = self.patrol_goal_pos;

		dist = distancesquared( self.origin, self.patrol_goal_pos );

		//println( self.a.movement + " speed: " + self.moveplaybackrate );
		//running?
		if ( self.a.movement != "walk" )
		{
			
			self.moveplaybackrate = 1;
			continue;
		}

		//too close?
		if ( dist < tooclose2rd )
		{
			if ( self.moveplaybackrate > .4 )
				self.moveplaybackrate -= .05;
		}
		else if ( dist > toofar2rd )
		{
			if ( self.moveplaybackrate < .75 )
				self.moveplaybackrate += .05;
		}
		else
			self.moveplaybackrate = .5;
	}
}