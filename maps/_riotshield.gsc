#include maps\_utility;
#include animscripts\utility;
#include common_scripts\utility;

DEFAULT_GROUP_SPACING = 50;
DEFAULT_GOAL_RADIUS = 25;
RIOTSHIELD_PATH_ENEMY_DIST = 400;

// must be called before maps::\_load::main()
init_riotshield()
{
	if ( isdefined( level.riotshield_initialized ) )
		return;
		
	level.riotshield_initialized = true;
	
	if ( is_specialop() )
	{
		quotes = [];
		quotes[ quotes.size ] = "@DEADQUOTE_RIOTSHIELD_USE_EXPLOSIVE";
		quotes[ quotes.size ] = "@DEADQUOTE_RIOTSHIELD_OUT_FLANK";
		quotes[ quotes.size ] = "@DEADQUOTE_RIOTSHIELD_DONT_CHARGE";
		maps\_specialops::so_include_deadquote_array( quotes );
	}
		
	if ( !isdefined( level.subclass_spawn_functions ) )
		level.subclass_spawn_functions = [];

	level.subclass_spawn_functions[ "riotshield" ] = ::subclass_riotshield;
	
	animscripts\riotshield\riotshield::init_riotshield_AI_anims();
}


subclass_riotshield()
{
	animscripts\riotshield\riotshield::init_riotshield_AI();
}


/*
=============
///ScriptDocBegin
"Name: riotshield_sprint_on()"
"Summary: Turn on sprint for riotshield AI"
"Module: AI"
"CallOn: An AI"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
riotshield_sprint_on()
{
	animscripts\riotshield\riotshield::riotshield_sprint_on();
}

/*
=============
///ScriptDocBegin
"Name: riotshield_fastwalk_on()"
"Summary: Turn on fast walking ( while still facing a givin direction ) for riotshield AI"
"Module: AI"
"CallOn: An AI"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
riotshield_fastwalk_on()
{
	animscripts\riotshield\riotshield::riotshield_fastwalk_on();
}


/*
=============
///ScriptDocBegin
"Name: riotshield_sprint_off()"
"Summary: Turn off sprint for riotshield AI"
"Module: AI"
"CallOn: An AI"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
riotshield_sprint_off()
{
	animscripts\riotshield\riotshield::riotshield_sprint_off();
}

/*
=============
///ScriptDocBegin
"Name: riotshield_fastwalk_off()"
"Summary: Turn off fast walking for riotshield AI"
"Module: AI"
"CallOn: An AI"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
riotshield_fastwalk_off()
{
	animscripts\riotshield\riotshield::riotshield_fastwalk_off();
}

/*
=============
///ScriptDocBegin
"Name: riotshield_flee()"
"Summary: Drop shield and run away to cover"
"Module: AI"
"CallOn: An AI"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
riotshield_flee()
{
	assert( self.subclass == "riotshield" );

	if ( self.subclass != "riotshield" )
		return;
		
	self.combatMode = "cover";
	self.goalradius = 2048;

	animscripts\riotshield\riotshield::riotshield_init_flee();

	node = self FindBestCoverNode();
	
	if ( isdefined( node ) )
		self UseCoverNode( node );
}

//////////////////////////////////////////////////////////////////
// riotshield group

/*
=============
///ScriptDocBegin
"Name: group_create( <ai_array> )"
"Summary: Create an AI group from an array of AI"
"Module: AI"
"CallOn: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_create( ai_array, forward, spacing )
{
	newarray = [];
	foreach( member in ai_array )
	{
		if( member.combatMode != "no_cover"	)
			continue;//means they lost their shield or were never a riotshield guy
		newarray[ newarray.size ] = member;
	}
	group = spawnstruct();
	
	//remove guys out of a previous group and set their group to this one
	foreach( member in newarray )
	{
		if( isdefined( member.group ) && isdefined( member.group.ai_array ) )
			member.group.ai_array = array_remove( member.group.ai_array, member );
		member.group = group;
	}
	
	group.ai_array = newarray;
	group.fleeThreshold = 1;
	group.spacing = DEFAULT_GROUP_SPACING;
	
	group thread group_check_deaths();
	return group;
}


/*
=============
///ScriptDocBegin
"Name: group_initialize_formation( <forward>, <spacing> )"
"Summary: Create an AI group from an array of AI"
"Module: AI"
"CallOn: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_initialize_formation( forward, spacing )
{
	assert( isdefined( self.ai_array ) );
	
	self.ai_array = array_removedead( self.ai_array );	
	
	self.forward = forward;
	
	if ( isdefined( spacing ) )
		self.spacing = spacing;
	
	foreach ( ai in self.ai_array )
	{		
		ai.goalradius = DEFAULT_GOAL_RADIUS;
		ai.pathEnemyFightDist = 128;
		ai.pathEnemyLookahead = 128;
	}
	
	self group_sort_by_closest_match();
	//self thread group_resort_on_deaths();
	
	self thread check_group_facing_forward();
}

group_resort_on_deaths()
{
	assert( isdefined( self.ai_array ) );
	
	self endon( "break_group" );
	
	if ( self.ai_array.size == 0 )
		return;
		
	while( self.ai_array.size )
	{
		waittill_dead( self.ai_array, 1 );
				
		if( self.group_move_mode != "stopped" )
			self waittill( "goal" );
		
		self.ai_array = array_removedead( self.ai_array );				
		self group_sort_by_closest_match();
	}
}

/*
=============
///ScriptDocBegin
"Name: group_sort_by_closest_match( <forward> )"
"Summary: "
"Module: AI"
"CallOn: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_sort_by_closest_match( dir )
{
	assert( isdefined( self.ai_array ) );
	
	if ( self.ai_array.size == 0 )
		return;
		
	if ( isdefined( dir ) )
		self.forward = dir;
	else
		dir = self.forward;
	
	center = group_center();
	right = ( self.forward[1], -1 * self.forward[0], 0 );
	offset = right * self.spacing;
	pos = self group_left_corner( center, offset );

	// array of projected distance to phalanx line
	dist_array = [];
	for ( i = 0; i < self.ai_array.size; i++ )
	{
		if ( isdefined( self.ai_array[i] ) )
			dist_array[i] = vectordot( pos - self.ai_array[i].origin, right );
		else
			dist_array[i] = 0;
	}

	// sort	
	for ( i = 1; i < dist_array.size; i++ )
	{
		curDist = dist_array[i];
		curAI   = self.ai_array[i];
		
		for ( j = i - 1; j >= 0; j-- )
		{
			if ( curDist < dist_array[j] )
				break;
				
			dist_array[j + 1] = dist_array[j];
			self.ai_array[j + 1] = self.ai_array[j];
		}
		
		dist_array[j + 1] = curDist;
		self.ai_array[j + 1] = curAI;
	}
}


// poll for now, should get group notify from code
group_check_deaths()
{
	while (1)
	{
		if ( self.fleeThreshold > 0 )
		{
			self.ai_array = array_removedead( self.ai_array );
					
			if ( self.ai_array.size <= self.fleeThreshold )
			{
				foreach( ai in self.ai_array )
					ai riotshield_flee();
				
				self notify( "break_group" );
				break;									
			}
		}
		
		wait 1;
	}
}


group_left_corner( center, offset )
{
	return center - ((self.ai_array.size - 1) / 2 * offset);
}


/*
=============
///ScriptDocBegin
"Name: group_move( <group_center>, <forward> )"
"Summary: Move an AI group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_move( group_center, dir )
{
	assert( isdefined( self.ai_array ) );
	assert( isdefined( self.forward ) );
	assert( isdefined( group_center ) );
	
	self notify( "new_goal_set" );
	self.group_move_mode = "moving";
	
	if ( isdefined( dir ) )
		self.forward = dir;
	else
		dir = self.forward;
	
	right = ( dir[1], -1 * dir[0], 0 );
	offset = right * self.spacing;
	pos = self group_left_corner( group_center, offset );
	
	for ( i = 0; i < self.ai_array.size; i++ )
	{
		ai = self.ai_array[i];
		
		if ( isdefined( ai ) )
			ai setgoalpos( pos );
			
		pos = pos + offset;
	}
	
	self thread check_group_at_goal();
}

MIN_AT_GOAL_RADIUS = 45;

// do this in code
check_group_at_goal()
{
	self endon( "new_goal_set" );
	
	while (1)
	{
		//self waittill( "ai_at_goal" );
		wait 0.5;
	
		alive_count = 0;
		foreach ( ai in self.ai_array )
		{
			if ( isdefined( ai ) && isalive( ai ) )
				alive_count++;
		}
		
		at_goal_count = 0;
		for ( i = 0; i < self.ai_array.size; i++ )	
		{
			ai = self.ai_array[i];
			
			if ( isdefined( ai ) )
			{
				check_radius = max( MIN_AT_GOAL_RADIUS, ai.goalradius );
				if ( distanceSquared( ai.origin, ai.goalpos ) < squared( check_radius ) )
					at_goal_count++;
			}
		}
		
		if ( at_goal_count == alive_count )
		{
			self notify( "goal" );
			self.group_move_mode = "stopped";
		}
	}
}


check_group_facing_forward()
{
	self endon( "break_group" );
	
	while (1)
	{
		wait 0.5;
	
		alive_count = 0;
		foreach ( ai in self.ai_array )
		{
			if ( isdefined( ai ) && isalive( ai ) )
				alive_count++;
		}
		
		at_goal_count = 0;
		group_yaw = vectorToYaw( self.forward );
		
		for ( i = 0; i < self.ai_array.size; i++ )	
		{
			ai = self.ai_array[i];
			
			if ( isdefined( ai ) )
			{
				if ( abs( ai.angles[1] - group_yaw ) < 45 )
					at_goal_count++;
			}
		}
		
		if ( at_goal_count == alive_count )
			self notify( "goal_yaw" );
	}
}


/*
=============
///ScriptDocBegin
"Name: group_sprint_on()"
"Summary: Turn sprint on for a riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_sprint_on()
{
	foreach ( ai in self.ai_array )
		if ( isalive( ai ) )
			ai riotshield_sprint_on();
}

/*
=============
///ScriptDocBegin
"Name: group_fastwalk_on()"
"Summary: Turn fast walk on for a riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_fastwalk_on()
{
	foreach ( ai in self.ai_array )
		if ( isalive( ai ) )
			ai riotshield_fastwalk_on();
}


/*
=============
///ScriptDocBegin
"Name: group_sprint_off()"
"Summary: Turn sprint off for a riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_sprint_off()
{
	foreach ( ai in self.ai_array )
		if ( isalive( ai ) )
			ai riotshield_sprint_off();
}

/*
=============
///ScriptDocBegin
"Name: group_fastwalk_off()"
"Summary: Turn fast walk off for a riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_fastwalk_off()
{
	foreach ( ai in self.ai_array )
		if ( isalive( ai ) )
			ai riotshield_fastwalk_off();
}


/*
=============
///ScriptDocBegin
"Name: group_lock_angles( <dir> )"
"Summary: Lock angles for a riotshield group. This function waits for the AI to turntable small angle changes"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_lock_angles( dir )
{
	self.forward = dir;
	yaw = vectorToYaw( dir );
	
	foreach ( ai in self.ai_array )
	{
		if ( !isdefined( ai ) )
			continue;

		if ( isdefined( ai.enemy ) && distanceSquared( ai.origin, ai.enemy.origin ) < squared( ai.pathEnemyFightDist ) )
			continue;

		ai orientmode( "face angle", yaw );
		ai.lockOrientation = true;
	}
	
	wait 0.1;
}


/*
=============
///ScriptDocBegin
"Name: group_unlock_angles()"
"Summary: Unlock angles for a riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_unlock_angles()
{
	foreach ( ai in self.ai_array )
	{
		if ( !isdefined( ai ) )
			continue;
			
		ai orientmode( "face default" );
		ai.lockOrientation = false;
	}
}


/*
=============
///ScriptDocBegin
"Name: group_free_combat()"
"Summary: Turn on free combat mode for a riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_free_combat()
{
	self group_unlock_angles();
	
	foreach ( ai in self.ai_array )
	{
		if ( !isdefined( ai ) )
			continue;
				
		ai.goalradius = 2048;
		ai.pathEnemyFightDist = RIOTSHIELD_PATH_ENEMY_DIST;
		ai.pathEnemyLookahead = RIOTSHIELD_PATH_ENEMY_DIST;
	}
}

/*
=============
///ScriptDocBegin
"Name: group_center()"
"Summary: Calculate the center position of the riotshield group"
"Module: AI"
"CallOn: AI group"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
group_center()
{
	center = ( 0, 0, 0 );
	alive_count = 0;
	foreach( ai in self.ai_array )
	{
		if ( isdefined( ai ) )
		{
			center = center + ai.origin;
			alive_count++;
		}
	}
		
	if ( alive_count )
		center = ( 1 / alive_count ) * center;
	
	return center;
}