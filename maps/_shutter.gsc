#include maps\_utility;
#include common_scripts\utility;

main()
{
	if ( !isdefined( level.windStrength ) )
		level.windStrength = 0.2;


	//WIND SETTINGS
	//-------------
	level.animRate[ "awning" ] = 1.0;
	level.animRate[ "palm" ] = 1.0;
	level.animWeightMin = ( level.windStrength - 0.5 );
	level.animWeightMax = ( level.windStrength + 0.2 );
	//clamp values
	if ( level.animWeightMin < 0.1 )
		level.animWeightMin = 0.1;
	if ( level.animWeightMax > 1.0 )
		level.animWeightMax = 1.0;
	//-------------
	//-------------


	level.inc = 0;
	awningAnims();
	palmTree_anims();

	thread new_style_shutters();

	array_levelthread( GetEntArray( "wire", "targetname" ), ::wireWander );
	array_levelthread( GetEntArray( "awning", "targetname" ), ::awningWander );
	array_levelthread( GetEntArray( "palm", "targetname" ), ::palmTrees );

	leftShutters = [];
	array = GetEntArray( "shutter_left", "targetname" );
	leftShutters = array_combine( leftShutters, array );

	array = GetEntArray( "shutter_right_open", "targetname" );
	leftShutters = array_combine( leftShutters, array );

	array = GetEntArray( "shutter_left_closed", "targetname" );
	leftShutters = array_combine( leftShutters, array );

	foreach ( shutter in leftShutters )
		shutter AddYaw( 180 );

	rightShutters = [];
	array = GetEntArray( "shutter_right", "targetname" );
	rightShutters = array_combine( rightShutters, array );

	array = GetEntArray( "shutter_left_open", "targetname" );
	rightShutters = array_combine( rightShutters, array );

	array = GetEntArray( "shutter_right_closed", "targetname" );
	rightShutters = array_combine( rightShutters, array );

	wait( 0.05 );

	array = array_combine( leftShutters, rightShutters );
	foreach ( shutter in array )
	{
		shutter thread shutterSound();
		shutter.startYaw = shutter.angles[ 1 ];
	}
	array = undefined;

	windDirection = "left";
	for ( ;; )
	{
		array_levelthread( leftShutters, ::shutterWanderLeft, windDirection );
		array_levelthread( rightShutters, ::shutterWanderRight, windDirection );
		level waittill( "wind blows", windDirection );
	}
}

windController()
{
	for ( ;; )
	{
		windDirection = "left";
		if ( RandomInt( 100 ) > 50 )
			windDirection = "right";
		level notify( "wind blows", windDirection );
		wait( 2 + RandomFloat( 10 ) );
	}
}

new_style_shutters()
{
	shutters = getentarray( "shutter", "targetname" );
	
	foreach ( shutter in shutters )
	{
		// all shutters target an ent that tells them what direction they're facing
		target_ent = getent( shutter.target, "targetname" );
		
		// spawn a pivot that will do the actual rotating, cause a brush model has no actual angles.
		pivot = spawn( "script_origin", shutter.origin );
		pivot.angles = target_ent.angles;
		pivot.startYaw = pivot.angles[ 1 ];
		
		shutter.pivot = pivot;
		shutter linkto( pivot );
		pivot addyaw( randomfloatrange( -90, 90 ) );
	
		shutter thread shutterSound();
	}
	
	windDirection = "left";
	for ( ;; )
	{
		array_levelthread( shutters, ::shutterWander, windDirection );
		level waittill( "wind blows", windDirection );
	}
}

shutterWander( shutter, windDirection )
{
	level endon( "wind blows" );

	pivot = shutter.pivot;
//	newYaw = pivot.startYaw - 89.9;
//	if ( windDirection == "left" )
//		newYaw += 179.9;

//	newTime = 0.2;
//	pivot RotateTo( ( 0, newYaw, 0 ), newTime );
//	wait( newTime + 0.1 );

	next_swap = randomint( 3 ) + 1;
	modifier = 1;
	if ( coinToss() )
		modifier *= -1;
	
	max_right_angle = 80;
	max_left_angle = 80;
	
	if ( isdefined( shutter.script_max_left_angle ) )
		max_left_angle = shutter.script_max_left_angle;
	
	if ( isdefined( shutter.script_max_right_angle ) )
		max_right_angle = shutter.script_max_right_angle;

	for ( ;; )
	{
		shutter notify( "shutterSound" );
		rot = RandomIntRange( 50, 80 );
		
		next_swap--;
		if ( !next_swap )
		{
			next_swap = randomint( 3 ) + 1;
			modifier *= -1;
		}
		
		rot *= modifier;
		
		if ( modifier > 0 )
		{
			if ( rot > max_right_angle )
				rot = max_right_angle;
		}
		else
		{
			if ( rot > max_left_angle )
				rot = max_left_angle;
		}		
		
		dest_yaw = pivot.startYaw + rot;

		dif = abs( pivot.angles[ 1 ] - dest_yaw );

		newTime = dif * 0.05 + RandomFloat( 1 ) + 0.25;
		if ( newTime < 0.25 )
			newTime = 0.25;

		
		pivot RotateTo( ( 0, dest_yaw, 0 ), newTime, newTime * 0.5, newTime * 0.5 );
		//Print3d( pivot.origin, newtime, (1,1,1), 1, 1, int( newTime * 20 ) );
		wait( newTime );
	}
}

shutterWanderLeft( shutter, windDirection )
{
//	println ("shutter angles ", shutter.angles[1]);
//	assert (shutter.angles[1] >= shutter.startYaw);
//	assert (shutter.angles[1] < shutter.startYaw + 180);

//	println ("Wind + ", level.inc);
	level.inc++;
	level endon( "wind blows" );

	newYaw = shutter.startYaw;
	if ( windDirection == "left" )
		newYaw += 179.9;

	newTime = 0.2;
	shutter RotateTo( ( shutter.angles[ 0 ], newYaw, shutter.angles[ 2 ] ), newTime );
	wait( newTime + 0.1 );


	for ( ;; )
	{
		shutter notify( "shutterSound" );
		rot = RandomInt( 80 );
		if ( coinToss() )
			rot *= -1;

		newYaw = shutter.angles[ 1 ] + rot;
		altYaw = shutter.angles[ 1 ] + ( rot * -1 );
		if ( ( newYaw < shutter.startYaw ) || ( newYaw > shutter.startYaw + 179 ) )
		{
			newYaw = altYaw;
		}

		dif = abs( shutter.angles[ 1 ] - newYaw );

		newTime = dif * 0.02 + RandomFloat( 2 );
		if ( newTime < 0.3 )
			newTime = 0.3;
//		println ("startyaw " + shutter.startyaw + " newyaw " + newYaw);

//		assert (newYaw >= shutter.startYaw);
//		assert (newYaw < shutter.startYaw + 179);

		shutter RotateTo( ( shutter.angles[ 0 ], newYaw, shutter.angles[ 2 ] ), newTime, newTime * 0.5, newTime * 0.5 );
		wait( newTime );
	}
}


shutterWanderRight( shutter, windDirection )
{
//	println ("shutter angles ", shutter.angles[1]);
//	assert (shutter.angles[1] >= shutter.startYaw);
//	assert (shutter.angles[1] < shutter.startYaw + 180);

//	println ("Wind + ", level.inc);
	level.inc++;
	level endon( "wind blows" );

	newYaw = shutter.startYaw;
	if ( windDirection == "left" )
		newYaw += 179.9;

	newTime = 0.2;
	shutter RotateTo( ( shutter.angles[ 0 ], newYaw, shutter.angles[ 2 ] ), newTime );
	wait( newTime + 0.1 );

	for ( ;; )
	{
		shutter notify( "shutterSound" );
		rot = RandomInt( 80 );
		if ( RandomInt( 100 ) > 50 )
			rot *= -1;

		newYaw = shutter.angles[ 1 ] + rot;
		altYaw = shutter.angles[ 1 ] + ( rot * -1 );
		if ( ( newYaw < shutter.startYaw ) || ( newYaw > shutter.startYaw + 179 ) )
		{
			newYaw = altYaw;
		}

		dif = abs( shutter.angles[ 1 ] - newYaw );

		newTime = dif * 0.02 + RandomFloat( 2 );
		if ( newTime < 0.3 )
			newTime = 0.3;
//		println ("startyaw " + shutter.startyaw + " newyaw " + newYaw);

//		assert (newYaw >= shutter.startYaw);
//		assert (newYaw < shutter.startYaw + 179);

		shutter RotateTo( ( shutter.angles[ 0 ], newYaw, shutter.angles[ 2 ] ), newTime, newTime * 0.5, newTime * 0.5 );
		wait( newTime );
	}
}

shutterSound()
{
	for ( ;; )
	{
		self waittill( "shutterSound" );
		//self PlaySound( "shutter_move", "sounddone" );
		self waittill( "sounddone" );
		wait( RandomFloat( 2 ) );
	}
}

wireWander( wire )
{
	origins = GetEntArray( wire.target, "targetname" );
	org1 = origins[ 0 ].origin;
	org2 = origins[ 1 ].origin;

	angles = VectorToAngles( org1 - org2 );
	ent = Spawn( "script_model", ( 0, 0, 0 ) );
	ent.origin = vector_multiply( org1, 0.5 ) + vector_multiply( org2, 0.5 );
//	ent setmodel ("temp");
	ent.angles = angles;
	wire LinkTo( ent );
	rottimer = 2;
	rotrange = 0.9;
	dist = 4 + RandomFloat( 2 );
	ent RotateRoll( dist * 0.5, 0.2 );
	wait( 0.2 );
	for ( ;; )
	{
		rottime = rottimer + RandomFloat( rotRange ) - ( rotRange * 0.5 );
		ent RotateRoll( dist, rottime, rottime * 0.5, rottime * 0.5 );
		wait( rottime );
		ent RotateRoll( dist * -1, rottime, rottime * 0.5, rottime * 0.5 );
		wait( rottime );
	}
}

#using_animtree( "desert_props" );
awningAnims()
{
/*
	level.scr_anim["2x4 awning"]["wind"][0]			= (%awning_2x4_wind_medium);
	level.scr_anim["2x4 awning"]["wind"][1]			= (%awning_2x4_wind_still);
	
	level.scr_anim["2x5 awning"]["wind"][0]			= (%awning_2x4_wind_medium);
	level.scr_anim["2x5 awning"]["wind"][1]			= (%awning_2x4_wind_still);
	
	level.scr_anim["5x11 awning"]["wind"][0]		= (%awning_5x11_wind_medium);
	level.scr_anim["5x11 awning"]["wind"][1]		= (%awning_5x11_wind_still);
	
	level.scr_anim["desert awning"]["wind"][0]		= (%awning_desert_market_medium);
	level.scr_anim["desert awning"]["wind"][1]		= (%awning_desert_market_still);
*/
}

awningWander( ent )
{
/*
	ent UseAnimTree( #animtree );
	
	switch (ent.model)
	{
		case "awning_2x4_1":
		case "awning_2x4_2":
		case "awning_2x4_3":
		case "awning_2x4_4":
		case "awning_2x4_5":
			ent.animname = "2x4 awning";
			break;
		case "awning_2x5_1":
		case "awning_2x5_2":
			ent.animname = "2x5 awning";
			break;
		case "awning_2-5x11":
			ent.animname = "5x11 awning";
			break;
		case "awning_desert_market_small":
		case "awning_desert_market_medium1":
		case "awning_desert_market_medium2":
		case "awning_desert_market_large":
		case "awning_desert_market_large2":
			ent.animname = "desert awning";
			break;
	}
	
	if (!isdefined (ent.animname))
		return;
	
	wait RandomFloat(2);
	
	for (;;)
	{
		fWeight = (level.animWeightMin + RandomFloat((level.animWeightMax - level.animWeightMin)) );
		fLength = 4;
		
		//setanim(anim, goalWeight, goalTime, rate)
		ent SetAnim(level.scr_anim[ent.animname]["wind"][0], fWeight, fLength, level.animRate["awning"]);
		ent SetAnim(level.scr_anim[ent.animname]["wind"][1], 1 - fWeight, fLength, level.animRate["awning"]);
		wait (1 + RandomFloat(3));
	}
*/
}

#using_animtree( "animated_props" );
palmTree_anims()
{
	return;

/*	
	level.scr_anim["tree_desertpalm01"]["wind"][0]			= (%tree_desertpalm01_strongwind);
	level.scr_anim["tree_desertpalm01"]["wind"][1]			= (%tree_desertpalm01_still);
	
	level.scr_anim["tree_desertpalm02"]["wind"][0]			= (%tree_desertpalm02_strongwind);
	level.scr_anim["tree_desertpalm02"]["wind"][1]			= (%tree_desertpalm02_still);
	
	level.scr_anim["tree_desertpalm03"]["wind"][0]			= (%tree_desertpalm03_strongwind);
	level.scr_anim["tree_desertpalm03"]["wind"][1]			= (%tree_desertpalm03_still);
*/
}

palmTrees( ent )
{
	ent UseAnimTree( #animtree );

	switch( ent.model )
	{
		case "tree_desertpalm01":
			ent.animname = "tree_desertpalm01";
			break;
		case "tree_desertpalm02":
			ent.animname = "tree_desertpalm02";
			break;
		case "tree_desertpalm03":
			ent.animname = "tree_desertpalm03";
			break;
	}




	if ( !isdefined( ent.animname ) )
		return;

	wait RandomFloat( 2 );

	for ( ;; )
	{
		fWeight = ( level.animWeightMin + RandomFloat( ( level.animWeightMax - level.animWeightMin ) ) );
		fLength = 4;

		//setanim(anim, goalWeight, goalTime, rate)
		ent SetAnim( level.scr_anim[ ent.animname ][ "wind" ][ 0 ], fWeight, fLength, level.animRate[ "palm" ] );
		ent SetAnim( level.scr_anim[ ent.animname ][ "wind" ][ 1 ], 1 - fWeight, fLength, level.animRate[ "palm" ] );
		wait( 1 + RandomFloat( 3 ) );
	}


	//palm[0] thread maps\_anim::anim_loop(palm, "wind", undefined, "stop palm anim");
}