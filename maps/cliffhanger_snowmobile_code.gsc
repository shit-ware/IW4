#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_blizzard;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_vehicle_spline;
#include maps\cliffhanger_code;
#include maps\cliffhanger;
#include maps\cliffhanger_snowmobile;

RED = ( 1, 0, 0 );

/************************************************************************************************************/
/*													SNOWMOBILE												*/
/************************************************************************************************************/


enemy_snowmobile_chase_spawner_think()
{
	self endon( "death" );
	self thread chase_player();

	for ( ;; )
	{
		self.baseAccuracy = 0;
		flag_wait( "price_ditches_player" );
		self.baseAccuracy = 1000;

		flag_waitopen( "price_ditches_player" );
		self.baseAccuracy = 0;
	}
}

chase_player()
{
	self.goalradius = 250;
	target_ent = spawn( "script_origin", ( 0, 0, 0 ) );
 	// shoot near the player if he is with price

	for ( ;; )
	{
		if ( !isalive( self ) )
			return;

		if ( flag( "player_slides_down_hill" ) )
		{
			self delete();
			return;
		}

		if ( flag( "price_ditches_player" ) )
		{
			self clearEntityTarget();
		}
		else
		{
			self setentitytarget( target_ent );
			angles = vectortoangles( level.player.origin - self.origin );
			angles = ( 0, angles[ 1 ], 0 );

			forward = anglestoforward( angles );
			target_ent.origin = level.player.origin + forward * 250;
			random_vec = randomvector( 200 );
			random_vec = ( random_vec[ 0 ], random_vec[ 1 ], 0 );
			target_ent.origin += random_vec;

			target_ent.origin = drop_to_ground( target_ent.origin ) + ( 0, 0, 1 );
		}
		//Line( self.origin, target_ent.origin );
		self setgoalpos( level.player.origin );
		wait( randomfloatrange( 0.4, 0.7 ) );
	}
}

price_ditches_player_detection()
{
	level endon( "player_slides_down_hill" );
	for ( ;; )
	{
		player_near_price = distance( level.price.origin, level.player.origin ) < 256;

		if ( flag( "price_ditches_player" ) )
		{
			if ( player_near_price )
			{
				flag_clear( "price_ditches_player" );
				level.price.ignoreme = false;
			}
		}
		else
		{
			if ( !player_near_price )
			{
				flag_set( "price_ditches_player" );
				level.price.ignoreme = true;
			}
		}

		wait( 0.05 );
	}
}

    

modulate_speed_based_on_distance()
{
	// modulate speed based on distance until player gets on his bike
	if ( flag( "player_gets_on_snowmobile" ) )
		return;
	level endon( "player_gets_on_snowmobile" );
	
	for ( ;; )
	{
		dist = distance( self.origin, level.player.origin );
		maxspeed = 60; // the speed the bike goes when it is near the player
		maxrange = 1000; // the distance at which to stop
		
		dist = maxrange - dist;
		if ( dist < 0 )
			dist = 0;
			
		speed = 60 * dist / 1000;
		self Vehicle_SetSpeed( speed, 1, 1 );
		wait( 0.05 );
	}
}

stop_modulation_at_big_hill()
{
	//flag_wait( "player_reaches_hilltop" );
	
	price_goes_down_hill = getent( "price_goes_down_hill", "targetname" );
	for ( ;; )
	{
		price_goes_down_hill waittill( "trigger", other );
		if ( !isalive( other ) )
			continue;
		if ( other == level.price )
			break;
	}
//	level.price.vehicle.veh_pathtype = "follow";
	
	//level.price.vehicle notify( "stop_modulating_speed" );
	//level.price.vehicle vehicle_setspeed( 75, 30, 30 );	
	/*
	for ( ;; )
	{
		if ( !isdefined( level.player.vehicle ) )
			return;
			
		if ( flag( "price_takes_jump" ) )
			break;
		
		min_speed = level.price.vehicle.veh_speed;
		if ( min_speed > 169 )
			break;
			
		level.price.vehicle.min_speed = min_speed;
		wait( 0.05 );
	}
	*/
	
	level.price.vehicle notify( "stop_modulating_speed" );
//	level.price.vehicle vehicle_setspeed( 0, 20, 20 );
	
//	flag_wait( "price_gets_to_other_side" );
	level.price.vehicle resumespeed( 100 );
	//level.price.vehicle vehicle_setspeed( 50, 35, 35 );
//	level.price.vehicle.veh_pathtype = "constrained";
//	wait( 6 );
//	speed = 60;
//	level.price.vehicle Vehicle_SetSpeed( speed, speed * 0.25, speed * 0.25 );
}

price_leads_player_to_heli()
{
	level.price.vehicle = self;	
	
	flag_wait( "price_ready_for_auto_speed" );
	level.price forceUseWeapon( "kriss", "primary" );
	
	modulate_speed_based_on_distance();
	thread modulate_speed_based_on_progress();
	thread stop_modulation_at_big_hill();

	self waittill( "reached_end_node" );
	
	thread unload_failsafe();
	wait( 1 );
//	self notify( "unload" );
	
	level.price waittill( "jumpedout" );
	
	flag_wait( "ending_heli_flies_in" );
	level.ending_heli ent_flag_wait( "landed" );
	
	level.ending_heli anim_reach_solo( level.price, "evac", "tag_detach" );
	level.price linkto( level.ending_heli, "tag_detach" );
	delaythread( 6, ::flag_set, "price_enters_heli" );
	level.ending_heli anim_single_solo( level.price, "evac", "tag_detach" );
}

unload_failsafe()
{
	self endon( "unload" );
	level.price endon( "jumpedout" );
	wait( 4 );
	self vehicle_unload();
}

banister_spawner_think()
{
	self add_spawn_function( ::banister_spawn_func );
	flag_wait( "snowmobile_in_house" );
	self spawn_ai();
}

banister_spawn_func()
{
	self.ignoreall = true;
	self endon( "death" );
	
	for ( ;; )
	{
		if ( !isdefined( level.player.vehicle ) )
			break;
		dist = distance( level.player.vehicle.origin, self.origin );
		if ( dist < 300 )
		{
			self.ignoreall = false;
		}
		
		if ( dist < 210 )
		{
			self set_generic_deathanim( "balcony_death" );
			/*
			org = self.origin;
			org = ( org[0], org[1] - 15, org[2] );
			RadiusDamage( org, 20, 1500, 1500, self );
			wait( 0.2 );
			*/
			self kill();
			return;
			/*
			self kill();
			angles = level.player.vehicle.angles;
			forward = anglestoforward( angles );
			forward *= 50;
			self StartRagdollFromImpact( level.player.vehicle.origin, forward );
			*/
		}
		wait( 0.05 );
	}
}


player_jolts_house()
{
	pulsetime = 0.05;
	timer = 2;
	timer /= pulsetime;
	for ( i = 0; i < timer; i++ )
	{
		if ( !isdefined( level.player.vehicle ) )
			return;
		forward = anglestoforward( level.player.vehicle.angles );
		org = level.player.vehicle.origin + forward * 55;
		org = ( org[ 0 ], org[ 1 ], level.player.vehicle.origin[ 2 ] );
		PhysicsExplosionSphere( org, 165, 125, 50 );
		wait( pulsetime );
	}
}


friends_drive()
{
	self.hero = true;
	price_bike_path = getent( "price_bike_path", "targetname" );
	for ( ;; )
	{
		self vehicleDriveTo( price_bike_path.origin, 20 );
		if ( distance( self.origin, price_bike_path.origin ) < price_bike_path.radius )
			break;
		wait( 0.2 );
	}

	flag_wait( "player_gets_on_snowmobile" );
	self.health = 5000;// need to use vehicle bullet shield
	//level.snowmobile_path[ 0 ] thread bike_drives_path( self );
	
}

speed_print()
{
	self.printspeed = 0;
	self.printprogress = 0;
	self endon( "death" );
	for ( ;; )
	{
		Print3d( self.origin + (0,0,36), self.printspeed + " " + self.printprogress, (1,0.2,0.2), 1, 1, int( 0.2 * 20 ) );
		wait( 0.2 );
	}
}

track_player_ride_progress()
{
	avalanche_progress_org = getent( "avalanche_progress_org", "targetname" );
	targ = getent( avalanche_progress_org.target, "targetname" );
	dist = distance( avalanche_progress_org.origin, targ.origin );
	for ( ;; )
	{
		array = get_progression_between_points( self.origin, avalanche_progress_org.origin, targ.origin );
		progress = array[ "progress" ];
		level.player_ride_progress = progress;
		level.player_ride_progress_percent = progress / dist;
		wait( 0.2 );
	}
}

remove_from_chase_vehicles()
{
	self waittill_either( "death", "veh_collision" );
	level.chase_vehicles = array_remove_nokeys( level.chase_vehicles, self );
}

avalache_chase_vehicle_spawner_think()
{
	self waittill( "spawned", vehicle );
	vehicle endon( "death" );
	//vehicle thread speed_print();
	vehicle thread vehicle_becomes_crashable();
	vehicle thread vehicle_tumble_in_avalanche();

	// we would do this if drivers shooting looked good
	/*if ( vehicle.riders.size == 1 )
	{
		// no passenger, make the driver shoot
		vehicle.driver_shooting = true;
		vehicle.passenger_shooting = false;
	}*/
	
	level.chase_vehicles[ level.chase_vehicles.size ] = vehicle;
	vehicle.personal_offset = 0;
	vehicle thread remove_from_chase_vehicles();

	vehicle snowmobile_maintains_distance_behind_player();
}

snowmobile_maintains_distance_behind_player()
{
	avalanche_progress_org = getent( "avalanche_progress_org", "targetname" );
	targ = getent( avalanche_progress_org.target, "targetname" );
	start_time = gettime();

	self Vehicle_SetSpeed( 35, 25, 25 );
	for ( ;; )
	{
		array = get_progression_between_points( self.origin, avalanche_progress_org.origin, targ.origin );
		progress = array[ "progress" ];
		progress_dif = progress - level.player_ride_progress;
		self.progress_dif = progress_dif;
		progress_dif += self.personal_offset;
				
		if ( progress_dif > 250 )
		{
			speed = 0.25;
		}
		else
		if ( progress_dif > 50 )
		{
			// we're ahead so slow down
			speed = 0.75;
		}
		else
		if ( progress_dif < -400 )
		{
			speed = 2;
		}
		else
		if ( progress_dif < -200 )
		{
			speed = 1.2;
		}
		else
		if ( progress_dif < -100 )
		{
			speed = 1.05;
		}
		else
		{
			speed = 1;
		}
		
		if ( gettime() > start_time + 3000 )
		{
			player_speed = level.player_ride vehicle_getSpeed();
			self Vehicle_SetSpeed( player_speed * speed, 25, 25 );
		}
		
		wait( 0.2 );
	}
}

chase_vehicles_get_personal_progress_offset()
{
	// makes vehicles spread out behind player
	for ( ;; )
	{
		offset = 100;
		waittillframeend;// for chase_vehicles to be up to date
		if ( level.chase_vehicles.size )
		{
			array = get_array_of_closest( level.player_ride.origin, level.chase_vehicles );
			for ( i = 0; i < array.size; i++ )
			{
				array[ i ].personal_offset = offset;
				offset += randomintrange( 100, 200 );
			}
		}
		wait( 0.21 );
	}
}


avalanche_section()
{
	node = getvehiclenode( self.target, "targetname" );
	self hide();

	level.avalanche_vehicles[ level.avalanche_vehicles.size ] = self;
	fxmodel = spawn_tag_origin();
	fxmodel linkto( self, "tag_origin", ( 0, 0, 256 ), ( 0, 0, -90 ) );
	playfxontag( level._effect[ "avalanche_loop_large" ], fxmodel, "tag_origin" );
	thread gopath( self );
	self.personal_offset = 2000;
	self thread avalanche_maintains_distance_behind_player();

//	self thread avlanche_node_think( node );
}

avalanche_maintains_distance_behind_player()
{
	if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "main_avalanche" )
	{
		// this trigger follows the avalanche and kills vehicles that get in it
		level.main_avalanche = self;
		avalanche_trigger = getent( "avalanche_trigger", "targetname" );
		avalanche_trigger playsound( "avalanche_ambiance_main" );
		self.progress = 0;
		avalanche_trigger thread trigger_follows_avalanche();
		avalanche_trigger thread trigger_kills_vehicles();
	}
	
	avalanche_progress_org = getent( "avalanche_progress_org", "targetname" );
	targ = getent( avalanche_progress_org.target, "targetname" );
	for ( ;; )
	{
		array = get_progression_between_points( self.origin, avalanche_progress_org.origin, targ.origin );
		progress = array[ "progress" ];
		self.progress = progress;
		progress_dif = progress - level.player_ride_progress;
		self.progress_dif = progress_dif;
		progress_dif += self.personal_offset;
			
		speed = 1;
		if ( progress_dif > -100 && progress_dif < 100 )
		{
			speed = 1;
		}
		else
		{
			if ( progress_dif < -200 )
			{
				speed = 1.5;
			}
			else
			if ( progress_dif < -400 )
			{
				speed = 2;
			}
			else
			if ( progress_dif > 120 )
			{
				speed = 0.25;
			}
		}

		player_speed = level.player_ride vehicle_getSpeed();
		self Vehicle_SetSpeed( player_speed * speed, 150, 150 );
		wait( 0.2 );
	}
}

trigger_follows_avalanche()
{
	avalanche_progress_org = getent( "avalanche_progress_org", "targetname" );
	targ = getent( avalanche_progress_org.target, "targetname" );
	angles = vectortoangles( avalanche_progress_org.origin - targ.origin );
	self.angles = angles + (0,90,0);

	dist = distance( avalanche_progress_org.origin, targ.origin );
	for ( ;; )
	{
		progress = level.main_avalanche.progress - 100;
		progress_percent = progress / dist;

		self.origin = avalanche_progress_org.origin * ( 1 - progress_percent ) + targ.origin * progress_percent;
		//Line( self.origin, level.player.origin, (0,0.6,0.4), 1, 0, int(0.2*20));
		wait( 0.2 );
	}
}


avlanche_node_think( node )
{
	wait 1;

	gopath( self );

	while ( 1 )
	{
		wait 12.5;

		self.attachedpath = undefined;
		self notify( "newpath" );
		self attachpath( node );
		gopath( self );
	}
}

trigger_kills_vehicles()
{
	for ( ;; )
	{
		self waittill( "trigger", other );
		other notify( "driver_died" );
	}
}

set_avalanche_offset( offset )
{
	foreach( vehicle in level.avalanche_vehicles )
	{
		vehicle.personal_offset = offset;
	}	
}

enemy_snowmobiles_spawn_and_attack()
{
	level endon( "snowmobile_jump" );
	level endon( "enemy_snowmobiles_wipe_out" );
	wait_time = 3;
	flag_wait( "player_starts_snowmobile_trip" );

	for ( ;; )
	{
		thread spawn_enemy_bike();
		wait( wait_time );
		wait_time -= 0.5;
		if ( wait_time < 0.5 )
			wait_time = 0.5;
		//wait( randomfloatrange( 2, 3 ) );		
	}
}

rider_gains_accuracy()
{
	self endon( "death" );
	wait 20;
	self.baseAccuracy = 1;
}

become_price_snowmobile()
{
	self VehPhys_DisableCrashing();
}

price_snowmobile_riders_are_invulnerable_for_awhile()
{
	self magic_bullet_shield();
	wait( 7.5 );
	self stop_magic_bullet_shield();
}

die_on_snowmobile_mount()
{
	self endon( "death" );
	flag_wait( "player_rides_snowmobile" );
	wait( randomfloat( 0.35 ) );
	self kill();
}

icepick_vehicle_think()
{
	self VehPhys_DisableCrashing();
	foreach ( rider in self.riders )
	{
		noteworthy = "";
		if ( isdefined( rider.script_noteworthy ) )
			noteworthy = rider.script_noteworthy;
		if ( noteworthy == "magic_bullet_spawner" )
		{
			rider thread die_on_snowmobile_mount();
		}
		else
		{
			rider.health = 20;
		}
			
		rider thread rider_gains_accuracy();
	}

	price_snowmobile = isdefined( self.script_noteworthy ) && self.script_noteworthy == "god_vehicle_spawner";
	
	if ( price_snowmobile )
	{
		self.riders[0] price_snowmobile_riders_are_invulnerable_for_awhile();

		level.price_snowmobile = self;
		level.price_snowmobile_riders = self.riders;
		self waittill( "reached_end_node" );
		wait( 3 );
		self become_price_snowmobile();
	}
	else
	{
		self thread vehicle_becomes_crashable();
		self icepick_ride_until_crash();
	}

	if ( isalive( self.riders[ 0 ] ) )
	{
		//wait( 1 );
		//self vehicle_unload();
		foreach ( rider in self.riders )
		{
			if ( isalive( rider ) )
				rider.baseAccuracy = 1;
		}
	}

	self Vehicle_SetSpeed( 0, 35, 35 );
		
	level.icepick_snowmobiles[ level.icepick_snowmobiles.size ] = self;
	level notify( "new_icepick_snowmobile" );
	
	
}

wait_for_end_node_or_player_rides()
{
	level endon( "player_rides_snowmobile" );
	self waittill( "reached_end_node" );
}

icepick_ride_until_crash()
{
	self.riders[ 0 ] endon( "death" );
	//self endon( "reached_path_end" );
	self endon( "death" );
	self endon( "veh_collision" );
	
	wait_for_end_node_or_player_rides();
	flag_wait( "player_starts_snowmobile_trip" );
		
	node = self get_my_spline_node( self.origin );
	//Line( vehicle.origin, node.midpoint, (1, 0, 0 ), 1, 0, 5000 );
	node thread [[ level.drive_spline_path_fun ]]( self );
	
	/*
	for ( ;; )
	{
		if ( self vehicle_getspeed() > 15 )
		{
			break;
		}
		wait( 0.05 );
	}

	for ( ;; )
	{
		if ( self vehicle_getspeed() < 4 )
		{
			break;
		}
		wait( 0.05 );
	}
	*/
}



/*
		HUNTER KILLER HELI chases player during snowmobile ride
*/
hk_heli()
{
/#
	if ( getdebugdvarint( "chasecam" ) )
		return;
#/

	if ( level.start_point != "snowspawn" )
	{
		flag_wait( "enemies_persue_on_bike" );
	}
		
	hk_spawner = getent( "hunter_killer", "targetname" );
	/#
	if ( level.start_point == "snowspawn" )
	{
		hk_spawner = getent( "hunter_killer_start", "targetname" );
		wait( 1 );
	}
	#/
	
	hk = hk_spawner spawn_vehicle();
	level.hk = hk;
	flag_set( "hk_gives_chase" );
	hk.attack_progress = 4000;
	hk.warnings = 0;
	hk.hover_warnings = 3; // warnings at which heli goes after you
	hk ent_flag_init( "firing" );

	hk thread hk_moves();
	hk thread hk_wait_until_player_stops_progressing();
	/*
	for ( ;; )
	{
//		hk SetVehGoalPos( level.player.origin + (0,0,1200), false );	
		angles = vectortoangles( level.player.origin - hk.origin );
		yaw = angles[ 1 ];
		if ( hk.warnings >= 8 )
		{
			hk SetGoalYaw( yaw );
		}
		else
		{
			hk ClearGoalYaw();
		}
		
		wait( 0.05 );
	}
	*/
}


hk_fires_on_player()
{
	self endon( "death" );
	if ( !isdefined( level.player.vehicle ) )
		return;
		
//	if ( flag( "bad_heli_goes_to_death_position" ) )
//		return;
		
	self endon( "stop_tracking" );
	self setVehWeapon( "hind_turret" );
	//self setVehWeapon( "hunted_crash_missile" );
	
	forward = anglesToForward( level.player.angles );
	level.hk_lookat_ent.origin = level.player.origin;
	target_guide = spawn( "script_origin", level.player.origin );

	self setturrettargetent( level.hk_lookat_ent, ( 0, 0, 0 ) );
	//self setlookatent( level.hk_lookat_ent );
	self setlookatent( level.player );
	

	forward_dist = level.player.vehicle vehicle_getSpeed() * 80;
	if ( forward_dist < 2000 && self.warnings < 9 )
		forward_dist = 2000;
	else
	if ( forward_dist > 4000 )
		forward_dist = 4000;
		
	forward_org = forward * forward_dist;
	level.hk_lookat_ent.origin = level.player.origin + forward_org;	
	
	// target_guide lets us plant the target and still keep it linked to the player
	target_guide.origin = level.hk_lookat_ent.origin;
	target_guide linkto( level.player );
	
	printTime = 5;
	//Line( self.origin, target.origin, (0.8,1,0), 1, 1, int(printTime*20) );

	for ( ;; )
	{
		level.hk_lookat_ent.origin = get_trace_pos( target_guide.origin, 0 );
		if ( within_fov_2d( self.origin, self.angles, level.hk_lookat_ent.origin, 0.9 ) )
			break;
		wait( 0.05 );
	}
	
	burst = randomintrange( 6, 9 );
	start_pos = level.hk_lookat_ent.origin;

	burst_break = burst;
	if ( self.warnings < 5 )
	{
		burst_break = burst - 2;
	}
	
	for ( i = 0; i < burst_break; i++ )
	{
		/*
		dif = i / burst;
		dif = 1 - dif;
		forward_speed = 1000;
		forward_org = forward * forward_speed * ( dif + 1 );
		target.origin = level.player.origin + forward_org;	
		*/

		dif = i / burst;
		
		pos = start_pos * ( 1 - dif ) + level.player.origin * dif;
		//target.origin = pos;
		
		// once we start firing, the target homes in on the player
		//angles = vectortoangles( level.player.origin - target.origin );
	//	forward = anglestoforward( angles );
		//target.origin += forward * 300;
		level.hk_lookat_ent.origin = get_trace_pos( pos, 0 );
		
		
		delay = randomfloatrange( 0.1, 0.3 );
		//Line( level.player.origin, target.origin, RED, 1, 1, int(delay*20) );
		//Line( self.origin, target.origin, RED, 1, 1, int(printTime*20) );
		maps\_helicopter_globals::fire_missile( "hind_zippy", 1, level.hk_lookat_ent, delay );
	}
	
	target_guide delete();
}

weighted_results( weights )
{
	total = 0;
	foreach ( _, weight in weights )
	{
		total += weight;
	}
	
	assertex( total > 0, "Did weighted results with no weight!" );

	roll = randomfloat( total );
	total = 0;
	
	foreach( type, weight in weights )
	{
		total += weight;
		if ( roll <= total )
			return type;
	}
	
	assertEx( 0, "Impossible!" );
}

hk_modulates_track_offset()
{
	self endon( "death" );
	level endon( "avalanche_begins" );
	if ( flag( "avalanche_begins" ) )
		return;
	for ( ;; )
	{
		self.track_offset = randomfloatrange( -4, 4 );
		if ( self.warnings < self.hover_warnings )
			self.attack_progress = randomfloatrange( 1000, 5000 );
		wait( randomfloatrange( 4, 8 ) );
	}
}



hk_moves()
{
	self endon( "death" );
	//level endon( "bad_heli_goes_to_death_position" );
	/# flag_assert( "bad_heli_goes_to_death_position" ); #/
	
	self Vehicle_SetSpeed( 120, 50, 50 );
	self.track_offset = 0;
	thread hk_modulates_track_offset();

	flag_wait( "player_gets_on_snowmobile" );


	for ( ;; )
	{
		// bit hacky way to wait for the player to link to the vehicle, only needed cause of start points
		if ( get_player_targ().index > 0 )
			break;
		wait( 0.05 );
	}
	
	self SetYawSpeed( 300, 160, 160 );
	self Vehicle_SetSpeed( 350, 75, 275 );
	level.hk_lookat_ent = spawn( "script_origin", level.player.origin );
	self setlookatent( level.hk_lookat_ent );	
	
	for ( ;; )
	{
		dest_dist = randomfloatrange( 7500, 9500 );
		dest_offset = randomfloatrange( 550, 750 );
		if ( coinToss() )
			dest_offset *= -1;
		pos = get_position_from_spline_unlimited( get_player_targ(), get_player_progress() + dest_dist, dest_offset );
		pos = get_trace_pos( pos, 1200 );

		//self clearlookatent();
		self setNearGoalNotifyDist( 1000 );
	
		//self ent_flag_waitopen( "firing" );	
		if ( !flag( "bad_heli_goes_to_death_position" ) )
		{
			hk_flies_to_pos_until_goal( pos );
			self SetVehGoalPos( pos, true );
		}
		
		timer = gettime();
		hk_fires_on_player();
		delay = randomfloatrange( 2, 3 );
		wait_for_buffer_time_to_pass( timer, delay );
		//self thread hk_tracks_player();
		
		/*
		add_wait( ::hk_waits_until_player_passes );
		add_wait( ::_wait, 4 );
		add_endon( "stop_tracking" );
		do_wait_any();
		*/
		self notify( "stop_tracking" );
		
		//Line( self.origin, pos, (1,0,1), 1, 0, int( 0.5 * 20 ) );
	}
}

hk_waits_until_player_passes()
{
	targ = get_my_spline_node( self.origin );
	array = get_progression_between_points( self.origin, targ.midpoint, targ.next_node.midpoint );	
	
	for ( ;; )
	{
		progress = array[ "progress" ];
		dif = progress_dif( targ, progress, get_player_targ(), get_player_progress() );
		if ( dif < 1200 )
			return;
		wait( 0.5 );
	}
}

hk_flies_to_pos_until_goal( target_pos )
{
	level endon( "bad_heli_goes_to_death_position" );
	self endon( "death" );
	timer = 0.2;
	
	for ( ;; )
	{
		if ( distance( self.origin, target_pos ) < 2500 )
			return;
		
		my_pos = set_z( self.origin, 0 );
		
		heading = vectortoangles( target_pos - my_pos );
		forward = anglestoforward( heading );
		pos = my_pos + forward * 600;
		pos = ( pos[0], pos[1], self.origin[2] );
		pos = get_trace_pos( pos, 1200 );
		self SetVehGoalPos( pos, false );
		//Line( self.origin, target_pos, (0.5,1,0), 1, 1, int(timer*20) );
		wait( timer );
	}
}


hk_tracks_player()
{
	self notify( "stop_tracking" );
	self endon( "stop_tracking" );
	self endon( "death" );
	for ( ;; )
	{
		yaw = get_yaw( self.origin, level.player.origin );
		self SetGoalYaw( yaw );
		level.goalyaw = yaw;
		wait ( 0.05 );
	}
}

get_yaw( org1, org2 )
{
	angles = vectortoangles( org2 - org1 );
	return angles[1];
}


get_trace_pos( pos, height )
{
	trace = BulletTrace( pos + (0,0,2000), pos + (0,0,-15000), false, self );
	return trace["position"] + (0,0,height);
}

hk_wait_until_player_stops_progressing()
{
	self endon( "death" );
	old_index = get_player_targ().index;
	old_targ = get_player_targ();
	old_progress = get_player_progress();
	req_dist = 350;
	
	for ( ;; )
	{
		new_index = get_player_targ().index;
		new_progress = get_player_progress();;
		
		if ( new_index == old_index )
		{
			if ( new_progress < old_progress + req_dist )
				self.warnings++;
			else
				self.warnings = 0;
		}
		else
		if ( new_index < old_index )
		{
			self.warnings++;
		}
		else
		if ( new_index > old_index + 1 )
		{
			self.warnings = 0;
		}
		else
		{
			assert( new_index == old_index + 1 );
			if ( new_progress + old_targ.dist_to_next_targ > old_index + req_dist )
				self.warnings = 0;
		}

		if ( self.warnings == 0 )
		{
			old_index = get_player_targ().index;
			old_targ = get_player_targ();
			old_progress = get_player_progress();
		}
		
		self.attack_player = self.warnings > 10;
		self.kill_player = self.warnings > 50;

		if ( self.warnings > 3 )
		{
			flag_clear( "can_save" );
		}
		else
		{
			if ( !flag( "can_save" ) )
				flag_set( "can_save" );
		}
		
		if ( self.warnings >= self.hover_warnings )
			self.attack_progress = 1000;
			
//		else
//			self.attack_progress = 4000;
		wait( 0.5 );
	}
}

objective_ent_leads_player()
{
	level.player_snowmobile endon( "death" );

	for ( ;; )
	{
		targ = maps\_vehicle_spline::get_player_targ();
		progress = maps\_vehicle_spline::get_player_progress();
		progress += 7500;
		
		pos = get_position_from_spline( targ, progress, 0 );
		pos = set_z( pos, level.player_snowmobile.origin[ 2 ] );
		pos = PhysicsTrace( pos + ( 0, 0, 5000 ), pos + ( 0, 0, -5000 ) );
		//bike_lookahead_pos = set_z( bike_lookahead_pos, z );
		//return PhysicsTrace( bike_lookahead_pos + ( 0, 0, 200 ), bike_lookahead_pos + ( 0, 0, -200 ) );
		//pos = get_bike_pos_from_spline( targ, progress, 0, level.player.origin[2] );
		
		self.origin = pos;
		wait( 5 );
	}	
}

set_obj_point_from_flag( index, flagname )
{
	if ( !isdefined( level.player_snowmobile ) )
		return;

	objective_end_org = getent( "objective_end_org", "targetname" );
	dist = distance( objective_end_org.origin, level.player_snowmobile.origin );
		

	trigger = getentwithflag( flagname );
	ent = getent( trigger.target, "targetname" );
	angles = vectortoangles( ent.origin - trigger.origin );
	forward = anglestoforward( angles );
	ent.origin = trigger.origin + forward * 500000;
	
	angles = vectortoangles( ent.origin - level.player_snowmobile.origin );
	forward = anglestoforward( angles );
	end = level.player_snowmobile.origin + forward * dist;
		
	objective_position( index, end );
}

snowmobile_dialogue()
{
	flag_wait( "enemies_persue_on_bike" );

	// “More tangos to the rear! Just outrun them! Go! Go!”	
	radio_dialogue( "outrunthem" );

	wait( 4 );	
	// “Don’t slow down! Keep moving or you’re dead!”	
	radio_dialogue( "keepmoving" );

	wait( 3 );
	// “Go! Go! Go!”	
	radio_dialogue( "gogogo" );

	flag_wait( "snowmobile_price_full_speed" );

	// “Come on! Come on!” 	
	radio_dialogue( "comeoncomeon" );
		
}

price_progress_dialogue()
{	
	for ( ;; )
	{
		if ( level.player_ride_progress_percent > 0.6 )
			break;
		wait( 0.1 );
	}
	
	// “We’re gonna make it! Just hang on!”	
	thread radio_dialogue_queue( "gonnamakeit" );

	for ( ;; )
	{
		if ( level.player_ride_progress_percent > 0.7 )
			break;
		wait( 0.1 );
	}
	
	// “Come on! Come on!” 	
	thread radio_dialogue_queue( "comeoncomeon" );

	for ( ;; )
	{
		if ( level.player_ride_progress_percent > 0.9 )
			break;
		wait( 0.1 );
	}
	
	// “Hang ooonnn!!!” 	
	thread radio_dialogue_queue( "hangon2" );
}

missile_repulser()
{
	repulse = Missile_CreateRepulsorEnt( level.player, 10000, 2000 );
}

track_player_position()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		level.player.position = self.script_noteworthy;
		level notify( "new_player_position", self.script_noteworthy );
		wait( 2 );
	}
}

cliff_attacker_think()
{
	startPos = self.origin;
	targ = getent( self.target, "targetname" );
	angles = targ.angles;
	deathanim = level.cliffdeath_anims[ level.cliffdeath_anims_index ];
	level.cliffdeath_anims_index++;
	if ( level.cliffdeath_anims_index >= level.cliffdeath_anims.size )
		level.cliffdeath_anims_index = 0;
	
	self set_generic_deathanim( deathanim );
	
	cliff_attackers_wait_for_death_or_flag();
	
	if ( !isalive( self ) )
	{
		level.cliffdeaths++;
		level notify( "cliff_death" );
		return;
	}

	wait randomfloatrange( 0.2, 0.7 );
	if ( isalive( self ) )
	{
		self setgoalpos( startPos );
		self.goalradius = distance( self.origin, startPos ) / 2;
		self waittill_either( "goal", "death" );
	}
	level.cliffdeaths++;
	level notify( "cliff_death" );
	
	if ( !isalive( self ) )
		return;

	self endon( "death" );
	self.goalradius = 8;
	self waittill( "goal" );
	self delete();
}

cliff_attackers_wait_for_death_or_flag()
{
	self endon( "death" );
	flag_wait( "clifftop_snowmobile_guys_die" );
	wait( randomfloatrange( 0.1, 0.3 ) );
}


init_cliff_deaths()
{
	level.cliffdeaths = 0;
	level.cliffdeath_anims = [];
	level.cliffdeath_anims[ level.cliffdeath_anims.size ] = "cliffdeath_1";
	level.cliffdeath_anims[ level.cliffdeath_anims.size ] = "cliffdeath_2";
	level.cliffdeath_anims[ level.cliffdeath_anims.size ] = "cliffdeath_3";
	level.cliffdeath_anims[ level.cliffdeath_anims.size ] = "cliffdeath_4";
	level.cliffdeath_anims = array_randomize( level.cliffdeath_anims );
	level.cliffdeath_anims_index = 0;
}


slope_tree_think()
{
	//foliage_tree_pine_snow_lg_b
	yaw = randomint( 360 );
	self.angles = ( 0, yaw, 0 );
	range = 64;
	offset = randomint( range * 2 ) - range;

	//Line( self.origin, self.origin + ( offset, 0, 0 ), (1,0,0), 1, 0, 5000 );
	self.origin += ( offset, 0, 0 );
	trace = BulletTrace( self.origin + (0,0,64), self.origin + (0,0,-64), false, undefined );
	self.origin = trace[ "position" ] + (0,0,-8);
	// self hide();
	self.clip hide();
	self.clip.origin = self.origin;
	//Line( self.origin, self.clip.origin + ( offset, 0, 0 ), (0,1,0), 1, 0, 5000 );
	
	ent = common_scripts\_createfx::createLoopSound();
	ent.v[ "origin" ] = self.origin;
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "soundalias" ] = "velocity_whitenoise_loop";
}

end_camp_spawner_think()
{
	self endon( "death" );
	self.baseAccuracy = 0.2;
	for ( ;; )
	{
		vehicles = getentarray( "script_vehicle_littlebird_armed", "classname" );
		if ( vehicles.size )
		{
			closest_vehicle = getClosest( self.origin, vehicles, 8000 );
			self SetEntityTarget( closest_vehicle, 0.75 );
		}
		wait( randomfloatrange( 0.5, 1 ) );
	}
}

speedy_littlebird_spawner_think()
{
	wait( 2 );
	
	maps\_helicopter_globals::fire_missile( "hind_zippy", 1, level.hk );
	wait( 0.35 );
	maps\_helicopter_globals::fire_missile( "hind_zippy", 1, level.hk );
	wait( 0.35 );
	maps\_helicopter_globals::fire_missile( "hind_zippy", 1, level.hk );
	wait( 0.35 );
	flag_set( "bad_heli_missile_killed" );
	maps\_helicopter_globals::fire_missile( "hind_zippy", 1, level.hk );
	wait( 0.35 );
	maps\_helicopter_globals::fire_missile( "hind_zippy", 1, level.hk );
	
	
	flag_wait( "end_camp_player_leaves_camp" );
	waittillframeend; // wait until the littlebird starts moving cause its waiting on the same flag
	if ( player_looking_at( self.origin ) )
		return;
	
	// speed up this littlebird if the player isnt looking at it
	self vehicle_setspeedImmediate( 120, 50, 35 );
	self set_heli_move( "instant" );
	wait( 2 );
	self set_heli_move( "fast" );
}

ending_heli_think()
{
	level.ending_heli = self;
	self ent_flag_init( "landed" );
	self attach_vehicle_triggers();
	flag_set( "ending_heli_flies_in" );
	
	if ( isdefined( self.vehicle_triggers[ "trigger_multiple" ] ) )
		array_thread( self.vehicle_triggers[ "trigger_multiple" ], ::ending_heli_trigger_multiple );
	
	if ( isdefined( self.vehicle_triggers[ "trigger_use" ] ) )
		array_thread( self.vehicle_triggers[ "trigger_use" ], ::ending_heli_trigger_use );
	
//	thread dismount_player_when_he_gets_close();
	self waittill( "reached_dynamic_path_end" );
	self waittill( "near_goal" );
	self disconnectPaths();
	self ent_flag_set( "landed" );
	
	flag_wait( "player_boards" );

	if ( 1 ) return;
	
	model = spawn_anim_model( "player_rig" );
	model hide();
	
	model linkto( self, "tag_detach", (0,0,0), (0,0,0) );
	self thread anim_single_solo( model, "player_evac", "tag_detach" );
	level.player PlayerLinkToBlend( model, "tag_origin", 0.5, 0.2, 0.2 );
	delaythread( 0.5, ::reset_player_fov, model, "tag_origin" );
	//self waittill( "player_evac" );
	wait( 6 );
	flag_wait( "price_enters_heli" );
	path = getstruct( "ending_heli_escape_path", "targetname" );
	self thread vehicle_paths( path );
	flag_wait( "ending_heli_leaves" );
	
	nextmission();
}

ending_heli_trigger_multiple()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		if ( flag( "player_boards" ) )
			break;
		if ( level.player getvelocity()[ 2 ] > 8 )
			break;
	}
	self delete();
	flag_set( "player_boards" );
}

ending_heli_trigger_use()
{
	// "Press and hold ^3&&1^7 to board."
	self setHintString( &"CLIFFHANGER_BOARD" );
	add_wait( ::waittill_msg, "trigger" );
	level add_wait( ::waittill_msg, "player_boards" );
	do_wait_any();
	
	flag_set( "player_boards" );
	self delete();
}

dismount_player_when_he_gets_close()
{
	for ( ;; )
	{
		if ( !isdefined( level.player.vehicle ) )
			return;
			
		if ( distance( level.player.origin, self.origin ) < 800 )
		{
			level.player.vehicle Vehicle_SetSpeed( 0, 5, 35 );
			if ( level.player.vehicle vehicle_getspeed() < 5 )
				break;
		}
		wait( 0.05 );
	}
	
	level.player player_dismount_vehicle();	
	level.player.vehicle Vehicle_SetSpeed( 0, 5, 25 );
}

reset_player_fov( ent, tag )
{
	level.player PlayerLinkToDelta( ent, tag, 1, 90, 90, 35, 45 );
}


magic_bullet_spawner_think()
{
}

god_vehicle_spawner_think()
{
//	self VehPhys_DisableCrashing();
//	self waittill( "reached_end_node" );
}

price_snowmobile_icon()
{
	if ( !isalive( level.price ) )
		return;
	level.price endon( "death" );

	icon = newHudElem();
	icon setShader( "overhead_obj_icon_world", 10, 10 );
	icon.alpha = 1.0;
	icon.color = ( 1, 1, 1 );
	icon setWayPoint( true, false );
	icon SetTargetEnt( level.price );

	flag_wait( "player_boards" );
	icon destroy();
}

ending_heli_fly_off_trigger_think()
{
	// ending heli hits a trigger then flies off and deletes
	flag_wait( "hk_gives_chase" );
	
	for ( ;; )
	{
		self waittill( "trigger", other );
		if ( level.hk != other )
			continue;
		break;
	}
	flag_set( "bad_heli_goes_to_death_position" );
	
	path = getstruct( self.target, "targetname" );
	level.hk SetVehGoalPos( path.origin, true );
	//level.hk thread vehicle_paths( path );
}

player_top_speed_limit_trigger_think()
{
	assertex( isdefined( self.script_speed ), "Trigger at " + self.origin + " has no .script_speed" );

	for ( ;; )
	{
		self waittill( "trigger", other );
		assert( isPlayer( other ) );
		//other.vehicle.veh_topspeed = self.script_speed;
	}
}

kill_enemy_snowmobile_think()
{
	for ( ;; )
	{
		self waittill( "trigger", other );
		if ( !isdefined( level.player.vehicle ) )
			continue;
		if ( !isdefined( level.price.vehicle ) )
			continue;
		if ( other == level.player.vehicle )
			continue;
		if ( other == level.price.vehicle )
			continue;
		if ( !isdefined( other.wipeout ) )
			continue;
		if ( other.wipeout )
			continue;
		
		other.wipeout = true;
	}
}

player_path_trigger_think()
{
	self waittill( "trigger" );
	node = getvehiclenode( self.target, "targetname" );
//	level.player.vehicle attachPath( node );
	level.player.vehicle.veh_pathType = "follow";
	level.player.vehicle startPath( node );
}

recover_vehicle_path_trigger()
{
	for ( ;; )
	{
		trigger = getent( "recover_vehicle_path_trigger", "targetname" );
		trigger waittill( "trigger", other );
		if ( other.vehicletype == "snowmobile_friendly" )
			break;
	}
		
	node = getvehiclenode( trigger.target, "targetname" );
	
	other thread vehicle_paths( node );
	other startpath( node );
}

player_is_protected_on_trip_to_objective( objective, org )
{
	level notify( "new_player_protection_trip" );
	
	self player_is_protected_on_trip_to_objective_think( objective, org );

	// clear existing changes
	level.player maps\_gameskill::resetSkill();
}


player_is_protected_on_trip_to_objective_think( objective, org )
{
	level endon( "new_player_protection_trip" );
	
	org = get_org_from_self( org );
	original_org = org;
	dist = distance( level.player.origin, org );
	
	run_delay = [];
	run_delay[ 0 ] = 1.25;
	run_delay[ 1 ] = 1.0;
	run_delay[ 2 ] = 0.75;
	run_delay[ 3 ] = 0.75;
	
	delay = run_delay[ level.gameskill ];
	
	old_protection_time = gettime() + 3000;
	start_org = level.player.origin;
	
	protection_dist = 150;
	
	for ( ;; )
	{
		org = get_org_from_self( org );
		if ( org != original_org )
		{
			original_org = org;
			dist = distance( level.player.origin, org );
			dist -= 55; // give the player a pseudo freeby for the update
		}
		
		//Line( level.player.origin, org, (1,0,0), 1, 0 );
		//Print3d( org, level.player.attackeraccuracy, (1,0,0), 1, 1 );
		
		current_dist = distance( level.player.origin, org );
		current_dist += 50; // must continue making progress
		
		if ( current_dist < dist || dist < 150 )
		{
			level.player set_player_attacker_accuracy( 0 );
			dist = current_dist;

			wait 0.5;
		}
		else
		{
			protected = gettime() < old_protection_time;
			nearby = distance( level.player.origin, start_org ) < protection_dist;
			
			if ( protected && nearby )
			{
				level.player set_player_attacker_accuracy( 0.1 );
			}
			else
			{
				level.player maps\_gameskill::resetSkill();
			}
		}
		
		wait 0.05;
	}
}

get_org_from_self( org )
{
	if ( !isalive( self ) )
		return org;
	if ( !isdefined( self.goalpos ) )
		return self.origin;
	return self.goalpos;
}