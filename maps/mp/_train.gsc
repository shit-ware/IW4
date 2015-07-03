#include maps\mp\_utility;
#include common_scripts\utility;

SOUND_DELAY_MIN = 0.1;
SOUND_DELAY_MAX = 1;

init()
{
	train = getEnt( "the_l_train", "targetname" );
	assertex( isdefined( train ), "Calling to setup train in map without having the train in map! [targetname: the_l_train]" );
	train thread train_setup();
}

train_setup()
{
	precacheItem( "train_mp" );	
	
	delay_until_first_train = 2;
	Units_per_second = 1200;// train speed
	train_cars = 24;
	distance_between_cars = 368;
	eq_radius = 900;// 	radius of earthquakes broadcast from the train tracks

	min_time_between_trains = 100;
	max_time_between_trains = 200;

	lead_in_dist = 8000;
	lead_out_dist = 4000;

	train_car_sound_interval = 3;
	
	flag_init( "train_running" );

	yaw = self.angles[ 1 ];
	while ( yaw >= 90 )
	{
		yaw -= 90;
	}
	assertEx( yaw == 0, "Trains must have a yaw of 0, 90, 180, or 270 currently( for collision purposes )" );

	wheels = getentarray( "wheel", "targetname" );
	wheel_model = wheels[ 0 ].model;
	wheel_offset = [];
	foreach ( wheel in wheels )
	{
		wheel linkto( self );
		wheel.offset = self.origin - wheel.origin;
	}

	// ****************
	// Set up the other cars
	// ****************	
	forward = anglestoforward( self.angles );
	forward *= distance_between_cars;
	car_separation_vec = forward;
	cars = [];
	for ( i = 0; i < train_cars - 1; i++ )// - 1 car self is the lead car
	{
		car = spawn( "script_model", self.origin - car_separation_vec );
		car.angles = self.angles;
		car setmodel( self.model );
		car linkto( self );
		car_separation_vec += forward;
		cars[ cars.size ] = car;
		car.wheels = [];

		foreach ( owner_wheel in wheels )
		{
			wheel = spawn( "script_model", car.origin + owner_wheel.offset );
			wheel setmodel( wheel_model );
			wheel.angles = owner_wheel.angles;
			wheel linkto( car );
			car.wheels[ car.wheels.size ] = wheel;
		}
	}

	// ****************
	// The start and end points for the train, set from script origins
	// ****************	
	start = getent( self.target, "targetname" );
	start.origin = ( start.origin[ 0 ], start.origin[ 1 ], self.origin[ 2 ] );
	
	end = getent( start.target, "targetname" );
	end.origin = ( end.origin[ 0 ], end.origin[ 1 ], self.origin[ 2 ] );
	forward = anglestoforward( self.angles );
	start.origin = start.origin - forward * lead_in_dist;
	end.origin = end.origin + forward * lead_out_dist;

	track_dist = distance( start.origin, end.origin );
	travel_dist = track_dist + train_cars * distance_between_cars;
	travel_time = travel_dist / Units_per_second;
	track_time = track_dist / Units_per_second;
	full_train_time = train_cars * distance_between_cars / Units_per_second;



	// ****************
	// set up the earthquakes that play to make the train tracks rattle
	// ****************	
	distance_between_eq_orgs = eq_radius * 0.5;
	eq_count = track_dist / distance_between_eq_orgs;

	// the amount of time it takes for all the EQs to start before the train moves in
	delay_between_eqs = track_time / eq_count;
	travel_time_segment = track_time / eq_count;
	min_time_between_trains -= track_time;
	if ( min_time_between_trains < 0.1 )
		min_time_between_trains = 0.1;
	max_time_between_trains -= track_time;
	if ( max_time_between_trains < min_time_between_trains )
		max_time_between_trains = min_time_between_trains + 0.1;

	eq_points = [];
	for ( i = 0; i < eq_count; i++ )
	{
		progress = i / eq_count;
		eq_points[ i ] = start.origin * ( 1 - progress ) + end.origin * progress;
	}

	self.cars = cars;
	self.wheels = wheels;

	self.origin = start.origin;
	wait( delay_until_first_train );
	
	for ( ;; )
	{
		hide_trains();
		wait( 0.05 );
		self.origin = start.origin;


		// First there is a lead in of small EQs to shake the platform
		timer = gettime();
		for ( i = 0; i < eq_count; i++ )
		{
			thread train_eq( eq_points[ i ], eq_radius, track_time, full_train_time );
			wait( delay_between_eqs );
		}

		show_trains();
		thread train_kills_players( train_cars, distance_between_cars );
		thread train_spawns_dust();

		// Now the train goes by
		self moveto( end.origin + car_separation_vec, travel_time );
		train_play_sounds( train_car_sound_interval );
		
		wait( travel_time );
		hide_trains();

		train_stop_sounds( train_car_sound_interval );

		flag_set( "train_running" );
		self notify( "train_stops_killing_players" );
		// Wait until the next train
		wait( randomfloatrange( min_time_between_trains, max_time_between_trains ) );
	}
}

train_play_sound_delayed( alias )
{
	wait( randomfloatrange( SOUND_DELAY_MIN, SOUND_DELAY_MAX ) );	
	self playLoopSound( alias );
}

train_play_sounds( max )
{	
	self thread train_play_sound_delayed( "veh_train_eng_dist1_loop" );
	self thread train_play_sound_delayed( "veh_train_eng_dist2_loop" );
	self thread train_play_sound_delayed( "veh_train_eng_mid_loop" );
	self thread train_play_sound_delayed( "veh_train_eng_close1_loop" );
	self thread train_play_sound_delayed( "veh_train_eng_close2_loop" );
	
	// dont play sounds on every car
	count = 0;
	for ( i = 0; i < self.cars.size; i++ )
	{
		count++;
		if ( count < max )
			continue;
		count = 0;
	
		self.cars[ i ] thread train_play_sound_delayed( "veh_train_car_dist_loop" );
		self.cars[ i ] thread train_play_sound_delayed( "veh_train_car_mid_loop" );
		self.cars[ i ] thread train_play_sound_delayed( "veh_train_car_close_loop" );
	}
}

train_stop_sounds( max )
{
	self stopLoopSound( "veh_train_eng_dist1_loop" );   
	self stopLoopSound( "veh_train_eng_dist2_loop" );   
	self stopLoopSound( "veh_train_eng_mid_loop" );     
	self stopLoopSound( "veh_train_eng_close1_loop" );  
	self stopLoopSound( "veh_train_eng_close2_loop" );  

	count = 0;
	for ( i = 0; i < self.cars.size; i++ )
	{
		count++;
		if ( count < max )
			continue;
		count = 0;
	
		self.cars[ i ] stopLoopSound( "veh_train_car_dist_loop" );
		self.cars[ i ] stopLoopSound( "veh_train_car_mid_loop" );
		self.cars[ i ] stopLoopSound( "veh_train_car_close_loop" );
	}
}

hide_trains()
{
	// Hide the train while it warps to position
	self hide();
	foreach ( wheel in self.wheels )
	{
		wheel hide();
	}
	foreach ( car in self.cars )
	{
		car hide();
		foreach ( wheel in car.wheels )
		{
			wheel hide();
		}
	}
}

show_trains()
{
	// show the train while it warps to position
	self show();
	foreach ( wheel in self.wheels )
	{
		wheel show();
	}
	foreach ( car in self.cars )
	{
		car show();
		foreach ( wheel in car.wheels )
		{
			wheel show();
		}
	}
}

train_spawns_dust()
{
	if ( !isdefined( level._effect[ "train_dust" ] ) )
		return;
		
	range = 40;
	self endon( "train_stops_killing_players" );
	
	for ( ;; )
	{
		/*
		for ( i = 0; i < 10; i ++ )
		{
			x = randomfloatrange( self.min_x, self.max_x );
			y = randomfloatrange( self.min_y, self.max_y );
			PlayFX( level._effect[ "train_dust" ], ( x, y, self.origin[ 2 ] - 30 ) );
		}
		*/

		count = randomintrange( 1, 3 ); // which means 1 to 2 fx per frame
		for ( i = 0; i < count; i ++ )
		{
			x = randomfloatrange( self.min_x - range, self.max_x + range );
			y = randomfloatrange( self.min_y - range, self.max_y + range );
			PlayFX( level._effect[ "train_dust_linger" ], ( x, y, self.origin[ 2 ] - 10 ) );
		}
		wait( 0.05 );
	}
}

train_kills_players( train_cars, distance_between_cars )
{
	// find the extents of the train, presuming it is going straight n/s/e/w and then test vs player origins to see
	// if they should be run over
	train_width = 68;
	self endon( "train_stops_killing_players" );

	forward = anglestoforward( self.angles );
	right = anglestoright( self.angles );
	full_car_vec = forward * distance_between_cars;
	half_car_vec = full_car_vec * 0.5;
	train_width_vec = right * train_width;

	sides = [];
	sides[ "front" ] = self.origin + half_car_vec;
	sides[ "rear" ] = self.origin + train_cars * full_car_vec * - 1;
	sides[ "right" ] = self.origin + train_width_vec;
	sides[ "left" ] = self.origin - train_width_vec;
	start = self.origin;

	max_x = sides[ "front" ][ 0 ];
	min_x = sides[ "front" ][ 0 ];
	max_y = sides[ "front" ][ 1 ];
	min_y = sides[ "front" ][ 1 ];
	foreach ( side in sides )
	{
		if ( side[ 0 ] > max_x )
			max_x = side[ 0 ];
		if ( side[ 0 ] < min_x )
			min_x = side[ 0 ];
		if ( side[ 1 ] > max_y )
			max_y = side[ 1 ];
		if ( side[ 1 ] < min_y )
			min_y = side[ 1 ];
	}

	for ( ;; )
	{
		dif = start - self.origin;
		start = self.origin;
		max_x -= dif[ 0 ];
		min_x -= dif[ 0 ];
		max_y -= dif[ 1 ];
		min_y -= dif[ 1 ];
		
		// store it for the dust fx
		self.min_x = min_x;
		self.max_x = max_x;
		self.min_y = min_y;
		self.max_y = max_y;
		
		//print3d( ( max_x, max_y, self.origin[ 2 ] ), " * " );
		//print3d( ( min_x, max_y, self.origin[ 2 ] ), " * " );
		//print3d( ( max_x, min_y, self.origin[ 2 ] ), " * " );
		//print3d( ( min_x, min_y, self.origin[ 2 ] ), " * " );

		hit_ents = [];

		foreach ( player in level.players )
		{
			if ( !isalive( player ) )
				continue;
			if ( player.sessionstate != "playing" )
				continue;
			if ( !train_hits( player, min_x, min_y, max_x, max_y ) )
				continue;
				
			player playsound( "melee_knife_hit_watermelon" );

			pos = get_damageable_player_pos( player );
			hit_ents[ hit_ents.size ] = get_damageable_player( player, pos );
		}

		grenades = getentarray( "grenade", "classname" );
		foreach ( grenade in grenades )
		{
			if ( !train_hits( grenade, min_x, min_y, max_x, max_y ) )
				continue;

			pos = get_damageable_grenade_pos( grenade );
			hit_ents[ hit_ents.size ] = get_damageable_grenade( grenade, pos );
		}
	
		foreach ( ent in hit_ents )
		{				
			ent.damage = 5000;
			ent.pos = self.origin;
			ent.damageOwner = self;
			ent.eInflictor = self;

			ent maps\mp\gametypes\_weapons::damageEnt(
				ent.eInflictor, // eInflictor = the entity that causes the damage (e.g. a claymore)
				ent.damageOwner, // eAttacker = the player that is attacking
				ent.damage, // iDamage = the amount of damage to do
				"MOD_PROJECTILE_SPLASH", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
				"train_mp", // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
				ent.pos, // damagepos = the position damage is coming from
				vectornormalize(ent.damageCenter - ent.pos) // damagedir = the direction damage is moving in
			);			
		}
				
		wait( 0.05 );
	}
}

train_hits( entity, min_x, min_y, max_x, max_y )
{
	if ( entity.origin[ 2 ] < self.origin[ 2 ] - 5 )
		return false;

	if ( entity.origin[ 2 ] > self.origin[ 2 ] + 162 )
		return false;

	x = entity.origin[ 0 ];
	y = entity.origin[ 1 ];
	if ( x < min_x )
		return false;
	if ( y < min_y )
		return false;
	if ( x > max_x )
		return false;
	if ( y > max_y )
		return false;
	return true;
}


train_eq( origin, eq_radius, track_time, full_train_time )
{
	train_eq_lerp_for_time( origin, 0.0, 0.09, eq_radius, track_time, 0.5 );
	train_eq_for_time( origin, 0.17, eq_radius, full_train_time, 0.5 );
	train_eq_lerp_for_time( origin, 0.09, 0, eq_radius, track_time, 0.5 );
	//level notify( "stop_train_debug" + origin );
}

train_eq_for_time( origin, eq, eq_radius, eq_time, eq_time_slice )
{
	// earthquake makes the quake taper off over time so we
	// are going to do a lot of earthquakes to simulate a steady quake
	//thread print3d_eq( origin, eq );
	steps = int( eq_time / eq_time_slice );
	for ( i = 0; i < steps; i++ )
	{
		Earthquake( eq, eq_time_slice * 3, origin, eq_radius );
		wait( eq_time_slice );
	}
	remainder = eq_time - steps * eq_time_slice;
	if ( remainder > 0 )
	{
		wait( remainder );
	}
}

train_eq_lerp_for_time( origin, eq1, eq2, eq_radius, eq_time, eq_time_slice )
{
	// earthquake makes the quake taper off over time so we
	// are going to do a lot of earthquakes to simulate a steady quake
	//thread print3d_eq( origin, eq );
	steps = int( eq_time / eq_time_slice );
	for ( i = 0; i < steps; i++ )
	{
		progress = i / steps;
		eq = eq2 * progress + eq1 * ( 1 - progress );
		if ( eq > 0 )
			Earthquake( eq, eq_time_slice * 3, origin, eq_radius );
		wait( eq_time_slice );
	}
	remainder = eq_time - steps * eq_time_slice;
	if ( remainder > 0 )
	{
		wait( remainder );
	}
}

print3d_eq( origin, msg )
{
	level notify( "stop_train_debug" + origin );
	level endon( "stop_train_debug" + origin );
	for ( ;; )
	{
		Print3d( origin, msg );
		wait( 0.05 );
	}
}
