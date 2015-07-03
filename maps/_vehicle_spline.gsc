#include common_scripts\utility;
#include maps\_utility;
#include maps\_debug;
#include maps\_vehicle;
#include maps\_anim;

ANG_LOOKAHEAD_DIST = 800;
AHEAD_DISTANCE = 500;
WHITE = ( 1, 1, 1 );
RED = ( 1, 0, 0 );
GREEN = ( 0, 1, 0 );
BLUE = ( 0, 0, 1 );


init_vehicle_splines()
{
	create_dvar( "vehicle_spline_debug", 0 );
	
	level.SPLINE_MIN_PROGRESS = -2000;
	level.enemy_snowmobiles_max = 6;
	level.player_ent = spawn( "script_origin", level.player.origin + ( 0, 0, 88 ) );
	level.player_ent linkto( level.player );
	level.snowmobile_path = make_road_path();
	flag_init( "ai_snowmobiles_ram_player" );
	flag_set( "ai_snowmobiles_ram_player" );
	
	enable_spline_paths = getentarray( "enable_spline_path", "targetname" );
	array_thread( enable_spline_paths, ::enable_spline_path_think );
}

enable_spline_path_think()
{
	for ( ;; )
	{
		self waittill( "trigger", other );
		other notify( "enable_spline_path" );
	}
}

make_road_path()
{

	level.drive_spline_path_fun = ::bike_drives_path;

	path = process_path();
	flag_init( "race_complete" );
	level.player_view_org = spawn( "script_model", ( 0, 0, 0 ) );
	level.player_view_org setmodel( "tag_origin" );

	level.enemy_snowmobiles = [];
	level.bike_score = 0;
	level.player thread bike_death_score();
	return path;
}

bike_death_score()
{
	self waittill( "death" );
}


get_guy_from_spawner()
{
	spawner = getent( "spawner", "targetname" );
	spawner.count = 1;
	spawner.origin = self.origin;
	spawner.angles = ( 0, self.angles[ 1 ], 0 );
	return spawner stalingradspawn();
}

#using_animtree( "generic_human" );
orient_dir( yaw )
{
	for ( ;; )
	{
		if ( !isdefined( self ) )
			return;
		self OrientMode( "face angle", yaw );
		wait( 0.05 );
	}
}

process_path()
{
	path = create_path();
	level.snowmobile_path = path;
	//drop_path_to_ground( path );
	add_collision_to_path( path );
	/#
	if ( getdebugdvarint( "vehicle_spline_debug" ) )
		thread draw_path( path );
	#/
	return path;
}

droppedLine( start, end, color, depth, cull, timer )
{
	start = drop_to_ground( start );
	end = drop_to_ground( end );
	thread linedraw( start, end, color, depth, cull, timer );
}

droppedLineZ( z, start, end, color, depth, cull, timer )
{
	start = ( start[ 0 ], start[ 1 ], z );
	start = drop_to_ground( start );

	end = ( end[ 0 ], end[ 1 ], z );
	end = drop_to_ground( end );
	thread linedraw( start, end, color, depth, cull, timer );
}

draw_path( path )
{
	old_left_node = undefined;
	old_right_node = undefined;

	for ( i = 0; i < path.size; i++ )
	{
		node = path[ i ];
		angles = vectortoangles( node.next_node.midpoint - node.midpoint );
		forward = anglestoforward( angles ) * node.dist_to_next_targ;

		width = node.road_width * 0.5;
		start1 = get_position_from_spline( node, 0, width );
		end1 = get_position_from_spline( node, node.dist_to_next_targ, width );
		droppedLineZ( node.z, start1, end1, ( 0, 0.5, 1 ), 1, 1, 50000 );

		start2 = get_position_from_spline( node, 0, width * -1 );
		end2 = get_position_from_spline( node, node.dist_to_next_targ, width * -1 );
		droppedLineZ( node.z, start2, end2, ( 0, 0.5, 1 ), 1, 1, 50000 );

		droppedLineZ( node.z, start1, start2, ( 0, 0.5, 1 ), 1, 1, 50000 );
		droppedLineZ( node.z, end1, end2, ( 0, 0.5, 1 ), 1, 1, 50000 );
		


		/*		
		start = node.origins[ "left" ];
		end = start + forward;
		droppedLineZ( node.z, start, end, ( 1, 0.3, 0 ), 1, 1, 50000 );

		start = node.origins[ "right" ];
		end = start + forward;
		droppedLineZ( node.z, start, end, ( 1, 0.3, 0 ), 1, 1, 50000 );

		droppedLineZ( node.z, node.origins[ "left" ] + (1,1,1), node.origins[ "right" ] + (1,1,1), ( 1, 0.3, 0 ), 1, 1, 50000 );

		droppedLineZ( node.z, node.origins[ "left" ] + (1,1,1), node.origins[ "left" ] + (1,1,1) + forward, ( 1, 0.3, 0 ), 1, 1, 50000 );
		droppedLineZ( node.z, node.origins[ "right" ] + (1,1,1), node.origins[ "right" ] + (1,1,1) + forward, ( 1, 0.3, 0 ), 1, 1, 50000 );

		droppedLineZ( node.z, node.origins[ "left" ] + (1,1,1) + forward, node.origins[ "right" ] + (1,1,1) + forward, ( 1, 0.3, 0 ), 1, 1, 50000 );
		*/
		/*		
		midpoint1 = node.midpoint;
		midpoint2 = node.next_node.midpoint;
		
		angles = vectortoangles( midpoint1 - midpoint2 );
		right = anglestoright( angles );
		road_half_width = node.road_width * 0.5;
		left_node = node.midpoint + right * road_half_width;
		right_node = node.midpoint + right * road_half_width * -1;

		droppedLineZ( node.z, left_node, right_node, ( 1, 0.3, 0 ), 1, 0, 50000 );
		if ( isdefined( old_left_node ) )
		{
			droppedLineZ( node.z, left_node, old_left_node, ( 1, 0.3, 0 ), 1, 0, 50000 );
			droppedLineZ( node.z, right_node, old_right_node, ( 1, 0.3, 0 ), 1, 0, 50000 );
		}
		old_left_node = left_node;
		old_right_node = right_node;
		*/

		//Print3d( node.midpoint, "*", ( 0, 1, 1 ), 1, 3, 50000 );
		foreach ( col_volume in node.col_volumes )
		{
			node draw_col_vol( node.z, col_volume );
		}

		foreach ( col_line in node.col_lines )
		{
			//Line( col_line.origin, node.origin );
			//Print3d( col_line.origin, col_line.progress, (0.5,1,1), 1, 2, 50000 );
			start = col_line.origin;
			end = col_line.other_col_point.origin;
			droppedlineZ( node.z, start, end, ( 1, 0, 0 ), 1, 1, 50000 );

			//print3d( col_line.origin + (0,0,-30 ), col_line.offset, ( 1,1,1), 1, 1, 50000 );
			//print3d( col_line.other_col_point.origin + (0,0,-30 ), col_line.other_col_point.offset, ( 1,1,1), 1, 1, 50000 );
		}
	}
}

draw_col_vol( z, vol )
{
	start = get_position_from_spline( self, vol[ "min" ], vol[ "left_offset" ] );
	end = get_position_from_spline( self, vol[ "max" ], vol[ "left_offset" ] );
	droppedLineZ( z, start, end, ( 0.5, 0, 1 ), 1, 1, 50000 );

	start = get_position_from_spline( self, vol[ "min" ], vol[ "right_offset" ] );
	end = get_position_from_spline( self, vol[ "max" ], vol[ "right_offset" ] );
	droppedLineZ( z, start, end, ( 0.5, 0, 1 ), 1, 1, 50000 );

	start = get_position_from_spline( self, vol[ "min" ], vol[ "right_offset" ] );
	end = get_position_from_spline( self, vol[ "min" ], vol[ "left_offset" ] );
	droppedLineZ( z, start, end, ( 0.5, 0, 1 ), 1, 1, 50000 );

	start = get_position_from_spline( self, vol[ "max" ], vol[ "right_offset" ] );
	end = get_position_from_spline( self, vol[ "max" ], vol[ "left_offset" ] );
	droppedLineZ( z, start, end, ( 0.5, 0, 1 ), 1, 1, 50000 );
}

draw_col_vol_offset( Z, vol, offset, forward, right )
{
	targ = self;

	start = get_position_from_spline( targ, vol[ "min" ], vol[ offset ] );
	end = get_position_from_spline( targ, vol[ "max" ], vol[ offset ] );
	droppedLineZ( z, start, end, ( 0.5, 0, 1 ), 1, 1, 50000 );
	


	/*
	angles = vectortoangles( self.next_node.origin - self.origin );
	forward = anglestoforward( angles );
	right = anglestoright( angles );

	start = self.midpoint - right * vol[ "right_offset" ] + forward * vol[ "min" ];
	end = self.midpoint - right * vol[ "right_offset" ] + forward * vol[ "max" ];
	start = drop_to_ground( start );
	end = drop_to_ground( end );
	Line( start, end, ( 1, 1, 1 ), 1, 0, 50000 );

	start = self.midpoint - right * vol[ "left_offset" ] + forward * vol[ "min" ];
	end = self.midpoint - right * vol[ "left_offset" ] + forward * vol[ "max" ];
	start = drop_to_ground( start );
	end = drop_to_ground( end );
	Line( start, end, ( 1, 1, 1 ), 1, 0, 50000 );
	*/
}

create_path()
{
	targ = getstruct( "road_path_left", "targetname" );
	assert( isdefined( targ ) );

	path = [];

	/#
	targ.z = targ.origin[ 2 ];
	#/
	targ.origin = ( targ.origin[ 0 ], targ.origin[ 1 ], 0 );

	count = 0;
	prev_targ = targ;
	for ( ;; )
	{
		next_targ = targ;
		if ( isdefined( targ.target ) )
			next_targ = getstruct( targ.target, "targetname" );

		 /#
		if ( !isdefined( next_targ.z ) )
			next_targ.z = next_targ.origin[ 2 ];
		#/
		next_targ.origin = ( next_targ.origin[ 0 ], next_targ.origin[ 1 ], 0 );

		path[ path.size ] = targ;
		targ.next_node = next_targ;
		targ.prev_node = prev_targ;
		next_targ.previous_node = targ;
		targ.col_lines = [];
		targ.col_volumes = [];
		targ.col_radiuses = [];
		targ.origins = [];
		targ.dist_to_next_targs = [];
		targ.origins[ "left" ] = targ.origin;

		targ.index = count;
		count++ ;

		if ( targ == next_targ )
			break;
		prev_targ = targ;
		targ = next_targ;
	}

	targ = getstruct( "road_path_right", "targetname" );
	/#
	targ.z = targ.origin[ 2 ];
	#/
	targ.origin = ( targ.origin[ 0 ], targ.origin[ 1 ], 0 );

	new_count = 0;
	for ( ;; )
	{
		next_targ = targ;
		if ( isdefined( targ.target ) )
			next_targ = getstruct( targ.target, "targetname" );

/*			
		vehicle_node = undefined;
		if ( isdefined( targ.script_linkto ) )
		{
			vehicle_node = getVehicleNode( targ.script_linkto, "script_linkname" );
		}
*/

		 /#
		if ( !isdefined( next_targ.z ) )
			next_targ.z = next_targ.origin[ 2 ];
		#/
		next_targ.origin = ( next_targ.origin[ 0 ], next_targ.origin[ 1 ], 0 );

		assertex( count >= new_count, "Had more right road nodes than left road nodes." );

		parent = path[ new_count ];
		assertex( isdefined( parent ), "Had more left road nodes than right road nodes." );
		parent.origins[ "right" ] = targ.origin;
		parent.road_width = distance( parent.origins[ "right" ], parent.origins[ "left" ] );
		
/*
		if ( isdefined( vehicle_node ) )
		{
			parent.vehicle_node = vehicle_node;
		}
*/		

		new_count++ ;

		if ( targ == next_targ )
			break;

		targ = next_targ;
	}


	assertex( count == new_count, "Had more left road nodes than right road nodes." );

	foreach ( node in path )
	{
		node.midpoint = ( node.origins[ "left" ] + node.origins[ "right" ] ) * 0.5;
	}

	foreach ( node in path )
	{
		// calc the new left/right based on road width		
		midpoint1 = node.midpoint;
		midpoint2 = node.next_node.midpoint;

		angles = vectortoangles( midpoint1 - midpoint2 );
		right = anglestoright( angles );
		road_half_width = node.road_width * 0.5;
		node.origins[ "left" ] = node.midpoint + right * road_half_width;
		node.origins[ "right" ] = node.midpoint + right * road_half_width * - 1;
	}

	// this node doesn't get a mid point because it has no .target
	node = path[ path.size - 1 ].next_node;
	node.midpoint = ( node.origins[ "left" ] + node.origins[ "right" ] ) * 0.5;

	foreach ( node in path )
	{
		node.dist_to_next_targ = distance( node.midpoint, node.next_node.midpoint );
		node.dist_to_next_targs[ "left" ] = distance( node.origins[ "left" ], node.next_node.origins[ "left" ] );
		node.dist_to_next_targs[ "right" ] = distance( node.origins[ "right" ], node.next_node.origins[ "right" ] );
	}

	return path;
}

drop_path_to_ground( path )
{
	targ = self;
	foreach ( node in path )
	{
		node.origin += ( 0, 0, 20 );
		endpos = PhysicsTrace( node.origin, node.origin + ( 0, 0, -100 ) );
		node.origin = endpos;
	}
}

add_collision_to_path( path )
{
	collision_lines = getstructarray( "moto_line", "targetname" );
	foreach ( collision_line in collision_lines )
	{
		collision_line.origin = ( collision_line.origin[ 0 ], collision_line.origin[ 1 ], 0 );
		next_line = getstruct( collision_line.target, "targetname" );
		// each collision line is made up of two points and each have a refence
		// to the other
		collision_line.other_col_point = next_line;
		next_line.other_col_point = collision_line;
	}

	foreach ( collision_line in collision_lines )
	{
		//droppedLine( collision_line.origin, collision_line.other_col_point.origin, GREEN, 1, 0, 50000 );
	}

	targ = self;
	foreach ( node in path )
	{
		foreach ( collision_line in collision_lines )
		{
			add_collision_to_path_ent( node, collision_line );
		}
	}

	// add the hard collision radiuses to the nearest path points
	moto_collision = getentarray( "moto_collision", "targetname" );
	foreach ( col_radius in moto_collision )
	{
		closest_nodes = get_array_of_closest( col_radius.origin, path, undefined, 2 );
		foreach ( node in closest_nodes )
		{
			node.col_radiuses[ node.col_radiuses.size ] = col_radius;
		}
	}
}

get_offset_percent( targ, next_targ, progress, offset )
{
	// translates an offset distance to a percentage
	dist = distance( targ.midpoint, next_targ.midpoint );
	//assertex( progress <= dist, "Too much progress" );

	progress_percent = 1 - ( progress / dist );

	offset_side = "left";
	if ( offset > 0 )
	{
		offset_side = "right";
	}

	// bumper meaning the outer edge of the current targ area
	bumper_start = targ.origins[ offset_side ];
	bumper_end = next_targ.origins[ offset_side ];

	// the origin equivalent to our progress, on the bumper
	bumper_org = bumper_start * progress_percent + bumper_end * ( 1 - progress_percent );

	center_start = targ.midpoint;
	center_end = next_targ.midpoint;

	// our progress on the center divider
	center_org = center_start * progress_percent + center_end * ( 1 - progress_percent );

	// the track width at our current progress
	track_width = distance( center_org, bumper_org );

	// our offset proportion based on that width
	return offset / track_width;
}

add_collision_to_path_ent( targ, col_org )
{
	if ( targ == targ.next_node )
		return;

	max_dist = targ.road_width;
	if ( targ.dist_to_next_targ > max_dist )
		max_dist = targ.dist_to_next_targ;
	
	if ( distance( col_org.origin, targ.next_node.midpoint ) > max_dist * 1.5 )
		return;

	next_org = getstruct( col_org.target, "targetname" );

	prog1 = get_progression_between_points( col_org.origin, targ.midpoint, targ.next_node.midpoint );
	progress1 = prog1[ "progress" ];

	prog2 = get_progression_between_points( next_org.origin, targ.midpoint, targ.next_node.midpoint );
	progress2 = prog2[ "progress" ];

	if ( progress1 < 0 || progress2 < 0 )
		return;
	if ( progress1 > targ.dist_to_next_targ && progress2 > targ.dist_to_next_targ )
		return;

	assertex( progress1 >= 0, "Negative progress" );
	assertex( progress2 >= 0, "Negative progress" );
	
	col_org.claimed = true;
	next_org.claimed = true;

	//start = get_position_from_spline( targ, prog1["progress"], prog1["offset"] );
	//end = get_position_from_spline( targ, prog2["progress"], prog2["offset"] );
	//droppedLineZ( targ.z, start, end, RED, 1, 0, 50000 );

	col_org.progress = progress1;
	col_org.offset = prog1[ "offset" ];
	col_org.offset_percent = get_offset_percent( targ, targ.next_node, progress1, prog1[ "offset" ] );

	next_org.progress = progress2;
	next_org.offset = prog2[ "offset" ];
	next_org.offset_percent = get_offset_percent( targ, targ.next_node, progress2, prog2[ "offset" ] );

	col_org.origin = ( col_org.origin[ 0 ], col_org.origin[ 1 ], targ.midpoint[ 2 ] + 40 );
	next_org.origin = ( next_org.origin[ 0 ], next_org.origin[ 1 ], targ.midpoint[ 2 ] + 40 );

	// add the collision ents in order of earliest progress then later progress
	if ( progress1 < progress2 )
	{
		add_collision_offsets_to_path_ent( targ, col_org, next_org );
		targ.col_lines[ targ.col_lines.size ] = col_org;
	}
	else
	{
		add_collision_offsets_to_path_ent( targ, next_org, col_org );
		targ.col_lines[ targ.col_lines.size ] = next_org;
	}
}

add_collision_offsets_to_path_ent( targ, close_org, far_org )
{
	// go through the path ents and apply the collision info to each node
	max_progress = far_org.progress + AHEAD_DISTANCE;
	min_progress = close_org.progress - level.DODGE_DISTANCE;

	right_offset = undefined;
	left_offset = undefined;
	right_offset_percent = undefined;
	left_offset_percent = undefined;
	
	if ( far_org.offset > close_org.offset )
	{
		right_offset = far_org.offset;
		left_offset = close_org.offset;
		right_offset_percent = far_org.offset_percent;
		left_offset_percent = close_org.offset_percent;
	}
	else
	{
		right_offset = close_org.offset;
		left_offset = far_org.offset;
		right_offset_percent = close_org.offset_percent;
		left_offset_percent = far_org.offset_percent;
	}

	start_targ = targ;
	start_max_progress = max_progress;
	start_min_progress = min_progress;

	// travel down the path and set collision	
	for ( ;; )
	{
		add_vol_to_node( targ, max_progress, min_progress, right_offset, left_offset, right_offset_percent, left_offset_percent );
		if ( !isdefined( targ.next_node ) )
			break;
		if ( targ.dist_to_next_targ >= max_progress )
			break;

		max_progress -= targ.dist_to_next_targ;
		targ = targ.next_node;
		min_progress = 0;
	}

	targ = start_targ;
	max_progress = start_max_progress;
	min_progress = start_min_progress;

	// travel up the path and set collision	
	for ( ;; )
	{
		if ( !isdefined( targ.previous_node ) )
			break;
		if ( min_progress > 0 )
			break;

		targ = targ.previous_node;
		max_progress = targ.dist_to_next_targ;
		min_progress = targ.dist_to_next_targ + min_progress;
		add_vol_to_node( targ, max_progress, min_progress, right_offset, left_offset, right_offset_percent, left_offset_percent );
	}
}

add_vol_to_node( targ, max_col_progress, min_col_progress, right_offset, left_offset, right_offset_percent, left_offset_percent )
{
	colvol = [];
	colvol[ "max" ] = max_col_progress;
	if ( colvol[ "max" ] > targ.dist_to_next_targ )
		colvol[ "max" ] = targ.dist_to_next_targ;

	colvol[ "min" ] = min_col_progress;
	if ( colvol[ "min" ] < 0 )
		colvol[ "min" ] = 0;

	assert( colvol[ "min" ] < colvol[ "max" ] );

	colvol[ "left_offset" ] = left_offset;
	colvol[ "right_offset" ] = right_offset;
	
	colvol[ "left_offset_percent" ] = left_offset_percent;
	colvol[ "right_offset_percent" ] = right_offset_percent;
	
	colvol[ "mid_offset" ] = ( right_offset + left_offset ) * 0.5;
	colvol[ "mid_offset_percent" ] = ( right_offset_percent + left_offset_percent ) * 0.5;

	targ.col_volumes[ targ.col_volumes.size ] = colvol;
}


/*
=============
///ScriptDocBegin
"Name: get_progression_between_points( <start> , <first_point> , <second_point> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_progression_between_points( start, first_point, second_point )
{
	first_point = ( first_point[ 0 ], first_point[ 1 ], 0 );
	second_point = ( second_point[ 0 ], second_point[ 1 ], 0 );
	start = ( start[ 0 ], start[ 1 ], 0 );

	prog = [];

	angles = vectortoangles( second_point - first_point );
	forward = anglestoforward( angles );

	end = first_point;
	difference = vectornormalize( end - start );
	dot = vectordot( forward, difference );

	normal = vectorNormalize( second_point - first_point );
	vec = start - first_point;
	progress = vectorDot( vec, normal );


	offset_org = first_point + forward * progress;

	prog[ "progress" ] = progress;
	prog[ "offset" ] = distance( offset_org, start );

	right = anglestoright( angles );
	difference = vectornormalize( offset_org - start );
	dot = vectordot( right, difference );
	prog[ "dot" ] = dot;
	if ( dot > 0 )
		prog[ "offset" ] *= -1;

	return prog;

}

wipe_out( bike )
{
	foreach ( col_radius in self.targ.col_radiuses )
	{
		crashPoint = ( self.origin[ 0 ], self.origin[ 1 ], 0 );

		if ( distance( ( col_radius.origin[ 0 ], col_radius.origin[ 1 ], 0 ), crashPoint ) < col_radius.radius )
			return true;
	}

	if ( bike.health >= 100 )// 0 && bike.rider.health >= 100 )
		return false;

	level.bike_score++ ;

	return true;
}

vehicle_line( bike )
{
	self endon( "death" );
	bike endon( "death" );
	for ( ;; )
	{
		line( self.origin, bike.origin, ( 0.2, 0.8, 0.3 ), 1, 0 );
		wait( 0.05 );
	}
}

spawner_random_team()
{
	waittillframeend;
	if ( !isdefined( self.riders ) )
		return;
	team = "axis";
	if ( cointoss() )
		team = "allies";
	foreach ( guy in self.riders )
	{
		guy.team = team;
	}
}

get_spawn_position( player_targ, my_progress )
{
	// convert the progress/targ to the actual targ/progress
	ent = move_to_correct_segment( player_targ, my_progress );
	progress = ent.progress;
	targ = ent.targ;

	// pick a random track offset then adjust it for obstacles
	half_road_width = targ.road_width * 0.5;
	offset = undefined;
	if ( isdefined( level.player.offset ) )
	{
		random_offset = 500;
		if ( cointoss() )
			random_offset *= -1;
		offset = level.player.offset + random_offset;
	}
	else
	{
		offset = randomfloatrange( half_road_width * -1, half_road_width );
	}
	
	obstacle_array = get_obstacle_dodge_amount( targ, progress, offset );
	if ( isdefined( obstacle_array["dodge"] ) )
		offset = obstacle_array["dodge"];
		
		
	
	// get the point on the spline
	spawn_pos = get_position_from_spline_unlimited( targ, progress, offset );
	array = [];
	array["spawn_pos"] = spawn_pos;
	array["progress"] = progress;
	array["targ"] = targ;
	array["offset"] = offset;
	return array;
}

debug_enemy_vehicles()
{
	/#
	if ( !getdebugdvarint( "vehicle_spline_debug" ) )
		return;
		
	level notify( "stop_debugging_enemy_vehicles" );
	array_thread( level.enemy_snowmobiles, ::debug_enemy_vehicles_line );
	#/
}

debug_enemy_vehicles_line()
{
	self endon( "death" );
	level endon( "stop_debugging_enemy_vehicles" );
	for ( ;; )
	{
		line( self.origin, level.player.origin, ( 1, 0.5, 0 ) );
		wait( 0.05 );
	}	
}

spawn_enemy_bike()
{
	assertex( isdefined( level.enemy_snowmobiles ), "Please add maps\_vehicle_spline::init_vehicle_splines(); to the beginning of your script" );
	
	/#
	debug_enemy_vehicles();
	#/
	
	if ( level.enemy_snowmobiles.size >= level.enemy_snowmobiles_max )
		return;

	player_targ = get_player_targ();
	player_progress = get_player_progress();
	my_direction = "forward";
	
	spawn_array = get_spawn_position( player_targ, player_progress - 1000 - level.POS_LOOKAHEAD_DIST );
	spawn_pos = spawn_array["spawn_pos"];
	player_sees_me_spawn = within_fov( level.player.origin, level.player.angles, spawn_pos, 0 );
	
	if ( player_sees_me_spawn )
	{ 
		// player could see us so try spawning in front of the player and drive backwards
		spawn_array = get_spawn_position( player_targ, player_progress + 1000 );
		spawn_pos = spawn_array["spawn_pos"];
		my_direction = "backward";
		player_sees_me_spawn = within_fov( level.player.origin, level.player.angles, spawn_pos, 0 );
		if ( player_sees_me_spawn )
		{
			return;
		}
	}
	
	// found a safe spawn pos
	spawn_pos = drop_to_ground( spawn_pos );
	
	
	snowmobile_spawner = getent( "snowmobile_spawner", "targetname" );
	assertEx( isdefined( snowmobile_spawner ), "Need a snowmobile spawner with targetname snowmobile_spawner in the level" );
	targ = spawn_array["targ"];

	snowmobile_spawner.origin = spawn_pos;
	
	//snowmobile_spawner.angles = vectortoangles( snowmobile_path_node.next_node.midpoint - snowmobile_path_node.midpoint );
	snowmobile_spawner.angles = vectortoangles( targ.next_node.midpoint - targ.midpoint );
	/*
	if ( isalive( level.player ) && isdefined( level.player.vehicle ) )
		snowmobile_spawner.angles = level.player.vehicle.angles;
	*/
	
	ai_spawners = snowmobile_spawner get_vehicle_ai_spawners();
	foreach ( spawner in ai_spawners )
	{
		spawner.origin = snowmobile_spawner.origin;
	}

	bike = vehicle_spawn( snowmobile_spawner );
	bike.offset_percent = spawn_array["offset"];
	bike VehPhys_SetSpeed( 90 );
	
	bike thread crash_detection();
	bike.left_spline_path_time = gettime() - 3000;
	waittillframeend; // for bike.riders to get defined
	if ( !isalive( bike ) )
		return;
		
	targ bike_drives_path( bike );
}

crash_detection()
{
	self waittill( "veh_collision", velocity, collisionNormal );
	
	self wipeout( "collision!" );	
}

rider_death_detection( bike )
{
	self waittill( "death" );
	if ( isdefined( bike ) )
	{
		bike wipeout( "driver died!" );
	}
}

wipeout( msg )
{
	/#
	if ( !self.wipeout )
	{
		if ( getdebugdvarint( "vehicle_spline_debug" ) )
			Print3d( self.origin, msg, (1,0.25,0), 1, 1.5, 400 );
	}
	#/
	self.wipeout = true;
}

update_bike_player_avoidance( my_bike )
{
	bikes = [];
	foreach ( bike in level.enemy_snowmobiles )
	{
		if ( !isalive( bike ) )
			continue;
			
		if ( bike.wipeout )
			continue;

		bikes[ bikes.size ] = bike;		
	}
	level.enemy_snowmobiles = bikes;

	if ( isalive( my_bike ) && !my_bike.wipeout )
	{
		found_bike = false;
		foreach ( bike in level.enemy_snowmobiles )
		{
			if ( bike == my_bike )
			{
				found_bike = true;
				continue;
			}
		}
		
		if ( !found_bike )
		{
			level.enemy_snowmobiles[ level.enemy_snowmobiles.size ] = my_bike;
		}
	}

	offset = 0;
	foreach ( bike in level.enemy_snowmobiles )
	{
		bike.bike_avoidance_offset = offset;
		offset += 75;
	}
}

bike_drives_path( bike )
{
	if ( !isdefined( bike.left_spline_path_time ) )
		bike.left_spline_path_time = gettime();
		
	bike.wipeout = false;
	update_bike_player_avoidance( bike );

	// speed = randomfloatrange( 50, 70 );

	if ( !isdefined( bike.player_offset ) )
		bike.player_offset = 250;
		
	bike.steering = 0;
	offset = randomfloatrange( 0, 1 );
	if ( !isdefined( bike.offset_percent ) )
		bike.offset_percent = offset * 2 - 1;

	targ = self;
	ent = spawnstruct();
	ent.origin = self.midpoint;
	ent.progress = 0;
	ent.tilt_vel = 0;
	ent.speed = 100;
	ent ent_flag_init( "biker_reaches_path_end" );
	
	// let other scripts know that track behavior has taken over
	bike notify( "enable_spline_path" );

	/*
	foreach ( rider in bike.riders )
	{
		if ( !isdefined( rider.magic_bullet_shield ) )
			rider thread magic_bullet_shield();
	}
	*/
	
	if ( !bike.riders.size )
	{
		bike VehPhys_Crash();
		return;
	}
	
	array_thread( bike.riders, ::rider_death_detection, bike );

	ent.bike = bike;
	//bike EnableAimAssist();
	//bike playloopsound( "veh_motorcycle_dist_loop" );

	bike.health = 100;

	wipeout = false;
	ent thread bike_ent_wipe_out_check( bike );

	// track the bike's progress along the path so we can do proper angles
	bike.progress_targ = targ;
	bike.offset_modifier = 0;
	bike.fails = 0;
	bike.direction = "forward";
	
	bike.old_pos = bike.origin;

	for ( ;; )
	{
		/#
		if ( getdebugdvarint( "vehicle_spline_debug" ) )
			bike debug_bike_line();
		#/
		
		if ( !isalive( bike ) )
			break;

		set_bike_position( ent );

		if ( !isalive( bike ) )
			break;
		if ( abs( bike.progress_dif ) > 6000 && gettime() > bike.left_spline_path_time + 4000 )
		{
			bike wipeout( "left behind!" );
		}

		waittillframeend;// for bike_ent wipeout to occur
		if ( bike.wipeout )
		{
			
			if ( isdefined( bike.hero ) )
				continue;

			bike VehPhys_Crash();
			foreach ( rider in bike.riders )
			{
				if ( isalive( rider ) )
				{
					//rider stop_magic_bullet_shield();
					rider kill();
				}
			}
			wait( 5 );
			if ( isdefined( bike ) )
			{
				bike delete();
			}

			update_bike_player_avoidance();
			return;
//			bike thread bike_wipes_out( ent );
//			bike hide();
		}

		if ( ent ent_flag( "biker_reaches_path_end" ) || flag( "race_complete" ) )
			break;
	}

	update_bike_player_avoidance();
	
	ent notify( "stop_bike" );
	level notify( "biker_dies" );
	if ( bike.wipeout && !flag( "race_complete" ) )
		wait( 5 );

	ent ent_flag_clear( "biker_reaches_path_end" );

}


get_obstacle_dodge_amount( targ, progress, offset )
{
	array[ "near_obstacle" ] = false;
	foreach ( vol in targ.col_volumes )
	{
		if ( progress < vol[ "min" ] )
			continue;
		if ( progress > vol[ "max" ] )
			continue;
		array[ "near_obstacle" ] = true;
		if ( offset < vol[ "left_offset" ] )
			continue;
		if ( offset > vol[ "right_offset" ] )
			continue;

		org = ( targ.midpoint + targ.next_node.midpoint ) * 0.5;
		//droppedLineZ( targ.z, org, origin, RED, 1, 0, 1 );
		if ( offset > vol[ "mid_offset" ] )
			array[ "dodge" ] = vol[ "right_offset" ];
		else
			array[ "dodge" ] = vol[ "left_offset" ];
		break;
	}
	return array;
}

sweep_tells_vehicles_to_get_off_path()
{
	for ( ;; )
	{
		self waittill( "trigger", other );
		if ( !isdefined( other.script_noteworthy ) )
			continue;
		if ( other.script_noteworthy != "sweepable" )
			continue;
		timer = randomfloatrange( 0, 1 );
		other thread notify_delay( "enable_spline_path", timer );
	}
}

drawmyoff()
{
	for ( ;; )
	{
		if ( isdefined( level.player.vehicle ) )
		{
			my_speed = self vehicle_getSpeed();
			p_speed = level.player.vehicle vehicle_getSpeed();
			Print3d( self.origin + (0,0,64), my_speed - p_speed, (1,0,0.2), 1, 1.2 );
			level.difference = my_speed - p_speed;
			
			Line( self.origin, level.player.origin, (1,0,0.2) );
		}
		wait( 0.05 );
	}
}

priceliner()
{
	/#
	create_dvar( "price_line", 0 );
	for ( ;; )
	{
		if ( !isdefined( level.player.vehicle ) )
			return;
		
		forward = anglestoforward( level.player.vehicle.angles );
		forward *= -150;
		if ( getdebugdvarint( "price_line" ) )
			Line( level.player.origin + forward, self.origin, (1,0,0) );
		wait( 0.05 );
	}
	#/
}

modulate_speed_based_on_progress()
{
	/*
	if ( flag( "price_leaves_player_throttling" ) )
		return;
	level endon( "price_leaves_player_throttling" );
	*/
	
	// thread drawmyoff();
	thread priceliner();
	self.targ = get_my_spline_node( self.origin );
	self.min_speed = 1;
	
	self endon( "stop_modulating_speed" );

	hud = undefined;
	/#
	hud = maps\_hud_util::createFontString( "default", 1.5 );
	hud maps\_hud_util::setPoint( "MIDDLE", "MIDDLE", 0, 30 );
	hud.color = ( 1, 1, 1 );
	hud.alpha = 1;
	#/
	
	
	for ( ;; )
	{
//		wait( randomfloatrange( 0.4, 1.2 ) );
		wait( 0.05 );

		targ = self.targ;
		if ( targ == targ.next_node )
		{
			// reached end
			return;
		}

		array = get_progression_between_points( self.origin, self.targ.midpoint, self.targ.next_node.midpoint );
		progress = array["progress"];
		progress += level.POS_LOOKAHEAD_DIST;

		ent = move_to_correct_segment( self.targ, progress );
		progress = ent.progress;
		self.targ = ent.targ;
		self.progress = progress;

		player_targ = get_player_targ();
		player_progress = get_player_progress();
		dif = progress_dif( self.targ, self.progress, player_targ, player_progress );
		level.progress_dif = dif;
	
		
		
		/*
		if ( dif < -1000 )
		{
			// catch up
			if ( isdefined( player_targ.next_node ) && isdefined( player_targ.next_node.vehicle_node ) )
			{
				path = player_targ.next_node.vehicle_node;
				endpos = self get_bike_pos_from_spline( player_targ, player_progress - 500, 0, path.origin[ 2 ] );
				self Vehicle_Teleport( endpos, self.angles );
				self startPath( path );
				Line( level.player.origin, endpos, (1,0,1), 1, 0, 500 );
			}
		}
		*/

		if ( !isdefined( level.player.vehicle ) )
		{
			self Vehicle_SetSpeed( 65, 1, 1 );
			continue;
		}
			
		if ( abs( dif > 3500 ) )
		{
			speed = 65;
	
			// if we're between these two speeds, then 
			//normal_max = 600; 
			//normal_min = 300;
			//dif_min = 300;
			
			dif *= -1;
			dif += 750; // go this far ahead of the player
			speed = level.player.vehicle.veh_speed + dif * 0.05;
			max_speed = level.player.vehicle.veh_speed;
			if ( max_speed < 100 )
				max_speed = 100;
				
			if ( speed > max_speed )
				speed = max_speed;
			else
			if ( speed < self.min_speed )
				speed = self.min_speed;
			level.desired_speed = speed;
			
			//my_speed = self vehicle_getSpeed();
			//if ( abs( player_speed - my_speed ) > 50 )
			//	self Vehicle_SetSpeedImmediate( speed, 90, 20 );
			//else
			self Vehicle_SetSpeed( speed, 90, 20 );
		}
		else
		{
			price_match_player_speed( 10, 10 );
			/#
				//hud setText( int( array["progress"] ) + " mult:" + multiplier + " dspeed:" + int( my_speed ) + " aspeed:" + int( self.veh_speed ) );
			#/
		}
							
	}
}

price_match_player_speed( maxaccell, maxdecel )
{
	
	angles = self.angles;
	angles = ( 0, angles[1], 0 );
	forward = anglestoforward( angles );
	
	array = get_progression_between_points( level.player.vehicle.origin, self.origin + forward * 1, self.origin - forward * 1 );
	progress = array["progress"];
	
	
	if ( progress > 4000 )
		self Vehicle_SetSpeed( 0, 90, 20 );
	else
	{
		dot = get_dot( self.origin, self.angles, level.player.origin );
		multiplier = 1;
		
		if ( progress > 0 )
		{
			// we're ahead of the player
			
			/*
			if ( progress > 3000 )
				multiplier = 0.1;
			else
			if ( progress > 1000 )
				multiplier = 0.2;
			else
			if ( progress > 500 )
				multiplier = 0.6;
			else
			if ( progress > 300 )
				multiplier = 0.9;
			else
			if ( progress > 150 )
				multiplier = 0.98;
			else
			if ( progress > 100 )
				multiplier = 0.99;
			else
			if ( progress > 50 )
				multiplier = 1.0;
				
			multiplier += randomfloatrange( -0.5, 0.5 );

			if ( multiplier < 1.2 && dot < -0.97 )
			{
				// player is behind us so we need to stay in front of him
				multiplier = 1.2;
			}
			*/
			
			multiplier = 1;
		}
		else
		{
			if ( progress > -500 )
				multiplier = 1.25;
				
			if ( multiplier > 0.95 && dot > 0.97 )
			{
				// player is ahead of us, don't run him over
				multiplier = 0.95;
			}
		}
			
		my_speed = 70 * multiplier;
		if ( my_speed < self.min_speed )
			my_speed = self.min_speed;
		if ( my_speed < 25 )
			my_speed = 25;
	
		/*
		if ( my_speed + 8 < self.veh_speed )
		{
			self Vehicle_SetSpeedImmediate( my_speed, 90, 90 );
		}
		else
		{
			if ( my_speed > self.veh_speed + 50 )
				self Vehicle_SetSpeedImmediate( my_speed, 90, 90 );
			else
				self Vehicle_SetSpeed( my_speed, 90, 90 );
		}
		*/
		
		level.price_desired_speed = my_speed;
		self Vehicle_SetSpeed( my_speed, maxaccell, maxdecel );
	}
}

match_player_speed( maxaccell, maxdecel )
{
	
	angles = self.angles;
	angles = ( 0, angles[1], 0 );
	forward = anglestoforward( angles );
	
	array = get_progression_between_points( level.player.vehicle.origin, self.origin + forward * 1, self.origin - forward * 1 );
	progress = array["progress"];
	
	if ( progress > 4000 )
		self Vehicle_SetSpeed( 0, 90, 20 );
	else
	{
		if ( progress < level.SPLINE_MIN_PROGRESS && gettime() > self.left_spline_path_time + 4000 )
		{
			self wipeout( "low progress!" );
		}
	
		progress -= 750;
		progress += self.bike_avoidance_offset;
		
		multiplier = 1;
	
		if ( progress > 150 )
			multiplier = 0.6;
		else
		if ( progress > 100 )
			multiplier = 1.0;
		else
		if ( progress < -100 )
			multiplier = 1.5;

		if ( isdefined( level.player.offset ) )
		{
			if ( progress > 250 )
			{
				// we're speeding up from behind so stay to the side
//				range = 200;
//				if ( array[ "offset" ] > level.player.offset + range )
//					self.preferred_offset = level.player.offset + range;
//				else
//				if ( array[ "offset" ] < level.player.offset - range )
//					self.preferred_offset = level.player.offset - range;
////				self.preferred_offset = undefined;
			}
			/*
			else
			{
				self.preferred_offset = level.player.offset + randomfloatrange( -150, 150 );
			}
			*/
		}
			
			
		my_speed = level.player.vehicle.veh_speed * multiplier;
		if ( my_speed < 25 )
			my_speed = 25;
	
		/*
		if ( my_speed + 8 < self.veh_speed )
		{
			self Vehicle_SetSpeedImmediate( my_speed, 90, 90 );
		}
		else
		{
			if ( my_speed > self.veh_speed + 50 )
				self Vehicle_SetSpeedImmediate( my_speed, 90, 90 );
			else
				self Vehicle_SetSpeed( my_speed, 90, 90 );
		}
		*/
		
		self Vehicle_SetSpeed( my_speed, maxaccell, maxdecel );
	}
}

track_player_progress( org )
{
	self notify( "track_player_progress" );
	self endon( "track_player_progress" );
	
	self.targ = get_my_spline_node( org );
	self.progress = 0;
	player_sweep_trigger = getent( "player_sweep_trigger", "targetname" );
	sweep_trigger = isdefined( player_sweep_trigger );
	if ( sweep_trigger )
		player_sweep_trigger thread sweep_tells_vehicles_to_get_off_path();
	 
	for ( ;; )
	{
		if ( self.targ == self.targ.next_node )
		{
			// reached end
			return;
		}

		array = get_progression_between_points( self.origin, self.targ.midpoint, self.targ.next_node.midpoint );
		
		progress  = array["progress"];
		progress += level.POS_LOOKAHEAD_DIST;

		ent = move_to_correct_segment( self.targ, progress );
		progress = ent.progress;
		self.targ = ent.targ;
		self.progress = progress;
		self.offset = array[ "offset" ];

		if ( sweep_trigger )
		{
			trigger_pos = get_position_from_spline_unlimited( self.targ, progress + 2000, 0 );
			trigger_pos = ( trigger_pos[ 0 ], trigger_pos[ 1 ], self.origin[ 2 ] - 500 );
			player_sweep_trigger.origin = trigger_pos;
			lookahead_pos = get_position_from_spline_unlimited( self.targ, progress + 3000, 0 );
			angles = vectortoangles( player_sweep_trigger.origin - lookahead_pos );
			player_sweep_trigger.angles = ( 0, angles[ 1 ], 0 );
		}
		
		if ( flag( "ai_snowmobiles_ram_player" ) )
		{
			// now find which enemy is closest to the player
			level.closest_enemy_snowmobile_to_player = getClosest( self.origin, level.enemy_snowmobiles );
		}
		else
		{
			// dont chase the player during crzy downhill part
			level.closest_enemy_snowmobile_to_player = undefined;
		}
				
		
		/*
		sweep_targ = self.targ;
		progress += 2000;
		for ( ;; )
		{
			if ( progress > sweep_targ.dist_to_next_targ )
			{
				progress -= sweep_targ.dist_to_next_targ;
				sweep_targ = sweep_targ.next_node;
				continue;
			}
			break;
		}
		player_sweep_trigger.origin = get_position_from_spline( sweep_targ, progress, 0 );
		player_sweep_trigger.origin = ( player_sweep_trigger.origin[ 0 ], player_sweep_trigger.origin[ 1 ], self.origin[ 2 ] - 500 );

				
		
		sweep_yaw = vectortoangles( sweep_targ.origin - sweep_targ.next_node.origin )[ 1 ];
		sweep_yaw_next = vectortoangles( sweep_targ.next_node.origin - sweep_targ.next_node.next_node.origin )[ 1 ];
		
		yaw = sweep_yaw * progress_percent + sweep_yaw_next * ( 1 - progress_percent );
		player_sweep_trigger.angles = ( 0, yaw, 0 );
		*/
		
		wait( 0.05 );
	}
}

progress_dif( targ, progress, targ2, progress2 )
{
	while ( targ.index > targ2.index )
	{
		targ = targ.prev_node;
		progress += targ.dist_to_next_targ;
	}
	while ( targ2.index > targ.index )
	{
		targ2 = targ2.prev_node;
		progress2 += targ2.dist_to_next_targ;
	}
	
	return progress - progress2;
}


set_bike_position( ent )
{
	bike = ent.bike;
	timer = 0.1;

	// find the bike's progress and position on the path that runs down the middle of the road
	progress = 0;
	offset = 0;

	targ = bike.progress_targ;
	if ( targ == targ.next_node )
	{
		bike delete();
		return;
	}

	// don't consider targs we're a long way away from
	array = get_progression_between_points( bike.origin, targ.midpoint, targ.next_node.midpoint );
	array_next = get_progression_between_points( bike.origin, targ.next_node.midpoint, targ.next_node.next_node.midpoint );
	
	// if we could be in the next nodeset then put us there.
	if ( array_next["progress"] > 0 && array_next["progress"] < targ.next_node.dist_to_next_targ )
	{
		array = array_next;
		targ = targ.next_node;
	}
	offset = array["offset"];
	player_progress = 0;
	progress = array["progress"];
	bike.progress = progress;
	
	obstacle_array = get_obstacle_dodge_amount( targ, progress, offset );
	crashing = obstacle_array["near_obstacle"];
		
	dif = progress_dif( targ, progress, get_player_targ(), get_player_progress() );
	bike.progress_dif = dif;
	if ( bike.direction == "forward" )
	{
		progress += level.POS_LOOKAHEAD_DIST;
	}
	else
	{
		progress -= level.POS_LOOKAHEAD_DIST;
		if ( dif < 500 )
		{
			bike.direction = "forward";
		}
	}

	min_speed = 60; // slowest to go when too fast ahead
	max_speed = 90; // max speed to catch up
	min_dist = 100; // distance at which to go max speed
	max_dist = 200; // distance at which you go slowest speed
	
	if ( dif > max_dist )
	{
		speed = min_speed;
	}
	else
	if ( dif < min_dist )
	{
		speed = max_speed;
	}
	else
	{
		dist_dif = max_dist - min_dist;
		speed_dif = max_speed - min_speed;
		speed = dif - min_dist;
		speed = dist_dif - speed;
		
		speed *= speed_dif / dist_dif;
		speed += min_speed;
		assert( speed >= min_speed && speed <= max_speed );
	}

	if ( speed > 0 )
	{
		if ( bike vehicle_getspeed() < 2 )
		{
			bike.fails++ ;
			if ( bike.fails > 10 )
			{
				bike wipeout( "move fail!" );
				return;
			}
		}
		else
			bike.fails = 0;
	}
	else
		bike.fails = 0;

	
	offset_modifier = randomfloatrange( 0, 100 );
	offset_modifier *= 0.001;
	
	chaseCam = false;
	
	/#
	
	if ( getdvarint( "chasecam" ) )
	{
		chasecam = true;
	}
	#/
	
	current_road_width = targ.road_width;

	ent = move_to_correct_segment( targ, progress );
	progress = ent.progress;
	targ = ent.targ;	
	
	org = ( targ.midpoint + targ.next_node.midpoint ) * 0.5;
	//droppedLineZ( targ.z, org, bike.origin, GREEN, 1, 0, timer );

	// scale the offset by the ratio of the road width I'm going to	
	offset = offset * targ.road_width / current_road_width;
	
	obstacle_array = get_obstacle_dodge_amount( targ, progress, offset );

	if ( isdefined( obstacle_array["dodge"] ) )
	{
		// is there an obstacle? dodge it
		offset = obstacle_array["dodge"];
	}
	else
	{
		if ( isdefined( bike.preferred_offset ) )
		{
			offset = bike.preferred_offset;
		}
	}

	// cap the offset to the legit road
	offset_limit = 0.95;
	road_half_width = targ.road_width * 0.5;
	road_half_width -= 50; // bring the edge in a little
	if ( offset > road_half_width )
		offset = road_half_width;
	else
	if ( offset < - 1 * road_half_width )
		offset = -1 * road_half_width;

	//speed = 70;
	if ( targ != targ.next_node )
	{	
		endpos = bike get_bike_pos_from_spline( targ, progress, offset, bike.origin[ 2 ] );
		
		dot = get_dot( bike.origin, bike.angles, endpos );
		//Print3d( bike.origin, dot, (0,0.3,1), 1, 1, int( timer * 20 ) );
		
		if ( dot < 0.97 )
			speed = 50;
		else
		if ( dot < 0.96 )
			speed = 25;
		else
		if ( dot < 0.95 )
			speed = 15;
		
		bike vehicleDriveTo( endpos, speed );
		if ( !isdefined( level.player.vehicle ) )
		{
			bike Vehicle_SetSpeed( 65, 1, 1 );
		}
		else
		{
			bike.veh_topspeed = level.player.vehicle.veh_topspeed * 1.3;
			bike match_player_speed( 45, 30 );
		}
		
		/#
		if ( getdebugdvarint( "vehicle_spline_debug" ) && isdefined( level.player.vehicle ) )
		
			if ( bike.veh_speed > level.player.vehicle.veh_speed )
				thread Linedraw( bike.origin, endpos, ( 0.9, 0.1, 0.3 ), 1, 0, timer );
			else
				thread Linedraw( bike.origin, endpos, ( 0.3, 0.1, 0.9 ), 1, 0, timer );
		#/
	}
	

	bike.progress_targ = targ;
	bike.offset = offset;
	wait( timer );
}

get_bike_pos_from_spline( targ, progress, offset, z )
{
	bike_lookahead_pos = get_position_from_spline( targ, progress, offset );
	bike_lookahead_pos = set_z( bike_lookahead_pos, z );

	return PhysicsTrace( bike_lookahead_pos + ( 0, 0, 200 ), bike_lookahead_pos + ( 0, 0, -200 ) );
}


move_to_correct_segment( targ, progress )
{
	ent = spawnstruct();
	
	// convert progress to proper progress and targ	
	for ( ;; )
	{
		if ( targ == targ.next_node )
		{
			break;
		}

		if ( progress > targ.dist_to_next_targ )
		{
			progress -= targ.dist_to_next_targ;
			targ = targ.next_node;
			continue;
		}

		if ( progress < 0 )
		{
			progress += targ.dist_to_next_targ;
			targ = targ.prev_node;
			continue;
		}
		
		break;
	}
	
	ent.targ = targ;
	ent.progress = progress;
	return ent;
}


get_position_from_spline_unlimited( targ, progress, offset )
{
	// travels down the path first
	for ( ;; )
	{
		if ( targ == targ.next_node )
		{
			return targ.midpoint;
		}
		
		if ( progress > targ.dist_to_next_targ )
		{
			progress -= targ.dist_to_next_targ;
			targ = targ.next_node;
			continue;
		}
		break;
	}

	return get_position_from_spline( targ, progress, offset );
}



//get_position_from_spline( targ, progress, offset )
//{

	/*
	angles = vectortoangles( targ.midpoint - targ.next_node.midpoint );
	right = anglestoright( angles );
	*/
	//pos = get_position_from_progress( targ, progress );
	//pos = get_position_from_progress( targ, progress );
	
	/*
	new_pos = get_position_from_offset( targ, targ.next_node, progress, offset );

	ratio = 1 - ( progress / targ.dist_to_next_targ );
	droppedLine( targ.midpoint, targ.next_node.midpoint, ( 0.5, 0.5, 0.5 ), 1, 0, 0.2 );
	mid_origin = targ.midpoint * ratio + targ.next_node.midpoint * ( 1 - ratio );
	droppedLine( mid_origin, new_pos, ( 0.4, 0.4, 0.6 ), 1, 0, 0.2 );

	return new_pos;
	*/
//}

get_position_from_spline( targ, progress, offset )
{
	angles = vectortoangles( targ.next_node.midpoint - targ.midpoint );
	forward = anglesToForward( angles );
	right = anglesToRight( angles );
	return targ.midpoint + forward * progress + right * offset;
	
	/*
//	assertex( progress >= 0, "Negative progress" );
	// translates an offset distance to a percentage
	dist = distance( targ.midpoint, next_targ.midpoint );
	assertex( progress <= dist, "Too much progress" );

	progress_percent = 1 - ( progress / targ.dist_to_next_targ );

	offset_side = "left";
	if ( offset < 0 )
	{
		offset_side = "right";
	}

	// bumper meaning the outer edge of the current targ area
	bumper_start = targ.origins[ offset_side ];
	bumper_end = next_targ.origins[ offset_side ];

	// the origin equivalent to our progress, on the bumper
	bumper_org = bumper_start * progress_percent + bumper_end * ( 1 - progress_percent );

	center_start = targ.midpoint;
	center_end = next_targ.midpoint;

	// our progress on the center divider
	center_org = center_start * progress_percent + center_end * ( 1 - progress_percent );

	//droppedLine( center_org, bumper_org, GREEN, 1, 0, 5000 );
	offset_percent = 1 - abs( offset_percent );
	return center_org * offset_percent + bumper_org * ( 1 - offset_percent );
	*/
}


get_position_from_progress( targ, progress )
{
	progress_percent = 1 - ( progress / targ.dist_to_next_targ );
	return targ.midpoint * progress_percent + targ.next_node.midpoint * ( 1 - progress_percent );
}


bike_ent_wipe_out_check( bike )
{
	self endon( "stop_bike" );
	for ( ;; )
	{
		//self.wipeout = wipe_out( bike );
		self.wipeout = false;// need to find out from c0de

		if ( self.wipeout )
			break;
		wait( 0.05 );
	}
}

draw_bike_debug()
{
	for ( ;; )
	{
		waittillframeend;
		Print3d( self.origin, self.goal_dir, ( 1, 1, 1 ), 2 );
		wait( 0.05 );
	}
}

track_progress()
{
	self endon( "stop_bike" );
	for ( ;; )
	{
		start = ( self.origin[ 0 ], self.origin[ 1 ], 0 );
		end = ( self.targ.midpoint[ 0 ], self.targ.midpoint[ 1 ], 0 );
		next_targ = ( self.next_targ.midpoint[ 0 ], self.next_targ.midpoint[ 1 ], 0 );

		difference = vectornormalize( end - start );
		forward = anglestoforward( self.angles );
		dot = vectordot( forward, difference );

		normal = vectorNormalize( next_targ - end );
		vec = start - end;
		self.progress = vectorDot( vec, normal );
		//Print3d( self.origin +(0,0,60), progress );
		wait( 0.05 );
	}
}


set_road_offset( targ )
{
	self.right_offset = targ.road_width * 0.5;
	self.safe_offset = self.right_offset - 100;
}

bike_avoids_obstacles( bike )
{
	self endon( "stop_bike" );
	self endon( "end_path" );

	self.goal_dir = 0;
	//thread bike_assigns_dodge_dir_from_obstacles( bike );
	thread bike_randomly_changes_lanes();
	bike_turns();
}

bike_randomly_changes_lanes()
{
	self endon( "stop_bike" );
	self endon( "end_path" );
	for ( ;; )
	{
		if ( self.targ.col_volumes.size == 0 && self.dodge_dir == 0 )
		{
			if ( cointoss() )
				self.goal_dir++ ;
			else
				self.goal_dir -- ;

			if ( self.goal_dir > 1 )
				self.goal_dir -= 3;
			else
			if ( self.goal_dir < - 1 )
				self.goal_dir += 3;
		}
		wait( randomfloatrange( 1, 3 ) );
	}
}

should_stabilize()
{
	if ( self.goal_dir == 0 )
		return true;

	if ( self.goal_dir == 1 && self.offset > self.safe_offset )
		return true;

	if ( self.goal_dir == -1 && self.offset < self.safe_offset * - 1 )
		return true;

	return false;
}

bike_turns()
{
	self.tilt_vel = 0;
	tilt_vel_max = 12;
	tilt_rate = 3;
	max_turn_speed = 130;
	for ( ;; )
	{
		if ( should_stabilize() )
		{
			// stabilizing
			if ( self.tilt > 0 )
			{
				self.tilt_vel -= tilt_rate;
			}
			else
			if ( self.tilt < 0 )
			{
				self.tilt_vel += tilt_rate;
			}

		}
		else
		if ( self.goal_dir == 1 )
		{
			self.tilt_vel += tilt_rate;
		}
		else
		if ( self.goal_dir == -1 )
		{
			self.tilt_vel -= tilt_rate;
		}

		if ( self.tilt_vel > tilt_vel_max )
		{
			self.tilt_vel = tilt_vel_max;
		}
		else
		if ( self.tilt_vel < - 1 * tilt_vel_max )
		{
			self.tilt_vel = -1 * tilt_vel_max;
		}

		self.tilt += self.tilt_vel;
		if ( self.tilt > max_turn_speed )
		{
			self.tilt = max_turn_speed;
			self.tilt_vel = 1;// keep some tilt so we don't change the turn logic
		}
		else
		if ( self.tilt < max_turn_speed * - 1 )
		{
			self.tilt = max_turn_speed * - 1;
			self.tilt_vel = -1;// keep some tilt so we don't change the turn logic
		}

		wait( 0.05 );
	}
}

stabalize( max_turn_speed, tilt_rate )
{
	if ( self.tilt > 0 )
	{
		self.tilt -= tilt_rate;
	}
	else
	{
		self.tilt += tilt_rate;
	}

	if ( abs( self.tilt ) < tilt_rate )
		self.tilt = tilt_rate;
}

tilt_right( max_turn_speed, tilt_rate )
{
	if ( self.offset >= self.safe_offset )
	{
		self.goal_dir = 0;
		return;
	}

	self.tilt += tilt_rate;
	if ( self.tilt >= max_turn_speed )
		self.tilt = max_turn_speed;
}

tilt_left( max_turn_speed, tilt_rate )
{
	if ( self.offset < self.safe_offset * - 1 )
	{
		self.goal_dir = 0;
		return;
	}

	self.tilt -= tilt_rate;
	if ( self.tilt < max_turn_speed * - 1 )
		self.tilt = max_turn_speed * - 1;
}

/*

bike_ent_drives_path( ent, targ )
{
	bike = ent.bike;
	ent endon( "stop_bike" );
	set_road_offset( targ );
	ent.offset = randomfloatrange( ent.right_offset * - 1, ent.right_offset );
	ent.progress_percent = 1;
	ent.offset_percent = 0.5;
	ent.tilt = 0;
	ent.targ = targ;
	next_targ = targ;

	thread bike_avoids_obstacles( bike );

	next_turn = gettime() + randomfloatrange( 1000, 4000 );
	count = 0;
	sides = [];
	sides[ sides.size ] = "left";
	sides[ sides.size ] = "right";

	frame_time = 0.05;

	for ( ;; )
	{
		if ( ent.progress_percent >= 1.0 )
		{
			ent.progress_percent -= 1.0;
			targ = next_targ;
			if ( !isdefined( targ.target ) )
				break;

			next_targ = getent( targ.target, "targetname" );
			ent.targ = targ;

			count++ ;
			ent.next_targ = next_targ;

			set_road_offset( targ );
		}

		ent.offset += ent.tilt * 0.05;
		if ( ent.offset > ent.right_offset )
			ent.offset = ent.right_offset;
		else
		if ( ent.offset < ent.right_offset * - 1 )
			ent.offset = ent.right_offset * - 1;

		road_width = targ.road_width;

		column_position = [];
		foreach ( side in sides )
		{
			column_position[ side ] = targ.origins[ side ] * ( 1 - ent.progress_percent ) + next_targ.origins[ side ] * ent.progress_percent;
		}
		current_column_position = column_position[ "left" ] * ent.offset_percent + column_position[ "right" ] * ( 1 - ent.offset_percent );

		row_position = [];
		row_position[ "front" ] = targ.origins[ "left" ] * ent.offset_percent + targ.origins[ "right" ] * ( 1 - ent.offset_percent );
		row_position[ "back" ] = next_targ.origins[ "left" ] * ent.offset_percent + next_targ.origins[ "right" ] * ( 1 - ent.offset_percent );

		ent.origin = current_column_position;
		ent.angles = vectortoangles( row_position[ "front" ] - row_position[ "back" ] );

		dist = distance( row_position[ "front" ], row_position[ "back" ] );
		ent.progress = dist * ent.progress_percent;

		current_progress = ent.progress;
		next_progress = ent.progress + ent.speed * frame_time;

		ent.progress_percent = next_progress / dist;

		wait( frame_time );
	}

	flag_set( "biker_reaches_path_end", ent );
	ent notify( "end_path" );
}
*/

get_player_progress()
{
	if ( isdefined( level.player.progress ) )
	{
		return level.player.progress;
	}
	
	return 0;
}

get_player_targ()
{
	if ( isdefined( level.player.targ ) )
		return level.player.targ;
	return level.snowmobile_path[0];
}

debug_bike_line()
{
	color = ( 0.2, 0.2, 1.0 );
	if ( isdefined( level.player.vehicle ) && self.veh_speed > level.player.vehicle.veh_speed )
		color = ( 1.0, 0.2, 0.2 );
	
	Line( self.old_pos, self.origin, color, 1, 0, 50000 );
	self.old_pos = self.origin;
}