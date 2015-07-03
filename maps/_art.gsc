// This function should take care of grain and glow settings for each map, plus anything else that artists 
// need to be able to tweak without bothering level designers.
#include maps\_utility;
#include common_scripts\utility;
#include common_scripts\_artCommon;

main()
{

	/#
	if ( GetDvar( "scr_art_tweak" ) == "" || GetDvar( "scr_art_tweak" ) == "0" )
		SetDvar( "scr_art_tweak", 0 );
	#/

	if ( GetDvar( "scr_cmd_plr_sun" ) == "" )
		SetDevDvar( "scr_cmd_plr_sun", "0" );

	if ( GetDvar( "scr_dof_enable" ) == "" )
		SetSavedDvar( "scr_dof_enable", "1" );

	if ( GetDvar( "scr_cinematic_autofocus" ) == "" )
		SetDvar( "scr_cinematic_autofocus", "1" );

	if ( GetDvar( "scr_art_visionfile" ) == "" )
		SetDvar( "scr_art_visionfile", level.script );

	level.dofDefault[ "nearStart" ] = 1;
	level.dofDefault[ "nearEnd" ] = 1;
	level.dofDefault[ "farStart" ] = 500;
	level.dofDefault[ "farEnd" ] = 500;
	level.dofDefault[ "nearBlur" ] = 4.5;
	level.dofDefault[ "farBlur" ] = .05;

	useDof = GetDvarInt( "scr_dof_enable" );
	
	level.special_weapon_dof_funcs = [];

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];

		player.curDoF = ( level.dofDefault[ "farStart" ] - level.dofDefault[ "nearEnd" ] ) / 2;

		if ( useDof )
			player thread adsDoF();
	}

	thread tweakart();

	if ( !isdefined( level.script ) )
		level.script = ToLower( GetDvar( "mapname" ) );

}

tweakart()
{
	/#
	if ( !isdefined( level.tweakfile ) )
		level.tweakfile = false;

	// not in DEVGUI
	SetDvar( "scr_fog_fraction", "1.0" );
	SetDvar( "scr_art_dump", "0" );

	// update the devgui variables to current settings
	SetDvar( "scr_dof_nearStart", level.dofDefault[ "nearStart" ] );
	SetDvar( "scr_dof_nearEnd", level.dofDefault[ "nearEnd" ] );
	SetDvar( "scr_dof_farStart", level.dofDefault[ "farStart" ] );
	SetDvar( "scr_dof_farEnd", level.dofDefault[ "farEnd" ] );
	SetDvar( "scr_dof_nearBlur", level.dofDefault[ "nearBlur" ] );
	SetDvar( "scr_dof_farBlur", level.dofDefault[ "farBlur" ] );

	// not in DEVGUI
	level.fogfraction = 1.0;

	file = undefined;
	filename = undefined;

	// set dofvars from < levelname > _art.gsc
	dofvarupdate();

	printed = false;

	for ( ;; )
	{
		while ( GetDvarInt( "scr_art_tweak" ) == 0 )
		{
			//	AssertEx( GetDvar( "scr_art_dump" ) == "0", "Must Enable Art Tweaks to export _art file." );
			wait .05;
			if ( ! GetDvarInt( "scr_art_tweak" ) == 0 )
				common_scripts\_artCommon::setfogsliders();// sets the sliders to whatever the current fog value is
		}


		if ( !printed )
		{
			printed = true;
			IPrintLnBold( "ART TWEAK ENABLED" );
		}

		//translate the slider values to script variables
		common_scripts\_artCommon::translateFogSlidersToScript();

		dofvarupdate();

		// catch all those cases where a slider can be pushed to a place of conflict
		fovslidercheck();

		dump = dumpsettings();// dumps and returns true if the dump dvar is set

		common_scripts\_artCommon::updateFogFromScript();

		level.player setDefaultDepthOfField();

		if ( dump )
		{
			PrintLn( "Art settings dumped success!" );
			addstring = "maps\\createart\\" + level.script + "_art::main();";
			AssertEx( level.tweakfile, "remove all art setting in " + level.script + ".gsc and add the following line before _load: " + addstring );
			SetDvar( "scr_art_dump", "0" );
 		}
		wait .05;
	}
	#/
}

fovslidercheck()
{
	// catch all those cases where a slider can be pushed to a place of conflict
	if ( level.dofDefault[ "nearStart" ] >= level.dofDefault[ "nearEnd" ] )
	{
		level.dofDefault[ "nearStart" ] = level.dofDefault[ "nearEnd" ] - 1;
		SetDvar( "scr_dof_nearStart", level.dofDefault[ "nearStart" ] );
	}
	if ( level.dofDefault[ "nearEnd" ] <= level.dofDefault[ "nearStart" ] )
	{
		level.dofDefault[ "nearEnd" ] = level.dofDefault[ "nearStart" ] + 1;
		SetDvar( "scr_dof_nearEnd", level.dofDefault[ "nearEnd" ] );
	}
	if ( level.dofDefault[ "farStart" ] >= level.dofDefault[ "farEnd" ] )
	{
		level.dofDefault[ "farStart" ] = level.dofDefault[ "farEnd" ] - 1;
		SetDvar( "scr_dof_farStart", level.dofDefault[ "farStart" ] );
	}
	if ( level.dofDefault[ "farEnd" ] <= level.dofDefault[ "farStart" ] )
	{
		level.dofDefault[ "farEnd" ] = level.dofDefault[ "farStart" ] + 1;
		SetDvar( "scr_dof_farEnd", level.dofDefault[ "farEnd" ] );
	}
	if ( level.dofDefault[ "farBlur" ] >= level.dofDefault[ "nearBlur" ] )
	{
		level.dofDefault[ "farBlur" ] = level.dofDefault[ "nearBlur" ] - .1;
		SetDvar( "scr_dof_farBlur", level.dofDefault[ "farBlur" ] );
	}
	if ( level.dofDefault[ "farStart" ] <= level.dofDefault[ "nearEnd" ] )
	{
		level.dofDefault[ "farStart" ] = level.dofDefault[ "nearEnd" ] + 1;
		SetDvar( "scr_dof_farStart", level.dofDefault[ "farStart" ] );
	}
}

dumpsettings()
{
	/#
	if ( GetDvar( "scr_art_dump" ) == "0" )
		return false;

	filename = "createart/" + GetDvar( "scr_art_visionfile" ) + "_art.gsc";

	////////////////// 

	file = 1;

	fileprint_launcher_start_file();

	fileprint_launcher( "// _createart generated.  modify at your own risk. Changing values should be fine." );
	fileprint_launcher( "main()" );
	fileprint_launcher( "{" );

	fileprint_launcher( "" );
	fileprint_launcher( "\tlevel.tweakfile = true;" );

	artfxprintlnFog();

	fileprint_launcher( "\tmaps\\_utility::set_vision_set( \"" + level.script + "\", 0 );" );

	fileprint_launcher( "" );
	fileprint_launcher( "}" );

	if ( ! artEndFogFileExport() )
		return false;
	////////////////////////////// 

	visionFilename = "vision/" + GetDvar( "scr_art_visionfile" ) + ".vision";
//	file = OpenFile( visionFilename, "write" );

	file = 1;

//	AssertEx( ( file != -1 ), "File not writeable( may need checked out of P4 ): " + filename );
	artStartVisionFileExport();

	fileprint_launcher( "r_glow                    \"" + GetDvar( "r_glowTweakEnable" ) + "\"" );
	fileprint_launcher( "r_glowRadius0             \"" + GetDvar( "r_glowTweakRadius0" ) + "\"" );
	fileprint_launcher( "r_glowBloomCutoff         \"" + GetDvar( "r_glowTweakBloomCutoff" ) + "\"" );
	fileprint_launcher( "r_glowBloomDesaturation   \"" + GetDvar( "r_glowTweakBloomDesaturation" ) + "\"" );
	fileprint_launcher( "r_glowBloomIntensity0     \"" + GetDvar( "r_glowTweakBloomIntensity0" ) + "\"" );
	fileprint_launcher( " " );
	fileprint_launcher( "r_filmEnable              \"" + GetDvar( "r_filmTweakEnable" ) + "\"" );
	fileprint_launcher( "r_filmContrast            \"" + GetDvar( "r_filmTweakContrast" ) + "\"" );
	fileprint_launcher( "r_filmBrightness          \"" + GetDvar( "r_filmTweakBrightness" ) + "\"" );
	fileprint_launcher( "r_filmDesaturation        \"" + GetDvar( "r_filmTweakDesaturation" ) + "\"" );
	fileprint_launcher( "r_filmDesaturationDark    \"" + GetDvar( "r_filmTweakDesaturationDark" ) + "\"" );
	fileprint_launcher( "r_filmInvert              \"" + GetDvar( "r_filmTweakInvert" ) + "\"" );
	fileprint_launcher( "r_filmLightTint           \"" + GetDvar( "r_filmTweakLightTint" ) + "\"" );
	fileprint_launcher( "r_filmMediumTint          \"" + GetDvar( "r_filmTweakMediumTint" ) + "\"" );
	fileprint_launcher( "r_filmDarkTint            \"" + GetDvar( "r_filmTweakDarkTint" ) + "\"" );
	fileprint_launcher( " " );
	fileprint_launcher( "r_primaryLightUseTweaks              \"" + GetDvar( "r_primaryLightUseTweaks" ) + "\"" );
	fileprint_launcher( "r_primaryLightTweakDiffuseStrength   \"" + GetDvar( "r_primaryLightTweakDiffuseStrength" ) + "\"" );
	fileprint_launcher( "r_primaryLightTweakSpecularStrength  \"" + GetDvar( "r_primaryLightTweakSpecularStrength" ) + "\"" );

	if ( ! artEndVisionFileExport() )
		return false;

	PrintLn( "CREATE ART DUMP SUCCESS!" );

	return true;
	#/
}



cloudlight( sunlight_bright, sunlight_dark, diffuse_high, diffuse_low )
{
	level.sunlight_bright = sunlight_bright;
	level.sunlight_dark = sunlight_dark;
	level.diffuse_high = diffuse_high;
	level.diffuse_low = diffuse_low;

	SetDvar( "r_lighttweaksunlight", level.sunlight_dark );
	SetDvar( "r_lighttweakdiffusefraction", level.diffuse_low );
	direction = "up";

	for ( ;; )
	{
		sunlight = GetDvarFloat( "r_lighttweaksunlight" );
		jitter = scale( 1 + RandomInt( 21 ) );

		flip = RandomInt( 2 );
		if ( flip )
			jitter = jitter * -1;

		if ( direction == "up" )
			next_target = sunlight + scale( 30 ) + jitter;
		else
			next_target = sunlight - scale( 30 ) + jitter;

		// IPrintLn( "jitter = ", jitter );
		if ( next_target >= level.sunlight_bright )
		{
			next_target = level.sunlight_bright;
			direction = "down";
		}

		if ( next_target <= level.sunlight_dark )
		{
			next_target = level.sunlight_dark;
			direction = "up";
		}

		if ( next_target > sunlight )
			brighten( next_target, ( 3 + RandomInt( 3 ) ), .05 );
		else
			darken( next_target, ( 3 + RandomInt( 3 ) ), .05 );
	}
}

brighten( target_sunlight, time, freq )
{
	// IPrintLn( "Brightening sunlight to ", target_sunlight );
	sunlight = GetDvarFloat( "r_lighttweaksunlight" );
	// diffuse = GetDvarFloat( "r_lighttweakdiffusefraction" );
	// IPrintLn( "sunlight = ", sunlight );
	// IPrintLn( "diffuse = ", diffuse );

	totalchange = target_sunlight - sunlight;
	changeamount = totalchange / ( time / freq );
	// IPrintLn( "totalchange = ", totalchange );
	// IPrintLn( "changeamount = ", changeamount );

	while ( time > 0 )
	{
		time = time - freq;

		sunlight = sunlight + changeamount;
		SetDvar( "r_lighttweaksunlight", sunlight );
		// IPrintLn( "^6sunlight = ", sunlight );

		frac = ( sunlight - level.sunlight_dark ) / ( level.sunlight_bright - level.sunlight_dark );
		diffuse = level.diffuse_high + ( level.diffuse_low - level.diffuse_high ) * frac;
		SetDvar( "r_lighttweakdiffusefraction", diffuse );
		// IPrintLn( "^6diffuse = ", diffuse );

		wait freq;
	}
}

darken( target_sunlight, time, freq )
{
	// IPrintLn( "Darkening sunlight to ", target_sunlight );
	sunlight = GetDvarFloat( "r_lighttweaksunlight" );
	// diffuse = GetDvarFloat( "r_lighttweakdiffusefraction" );
	// IPrintLn( "sunlight = ", sunlight );
	// IPrintLn( "diffuse = ", diffuse );

	totalchange = sunlight - target_sunlight;
	changeamount = totalchange / ( time / freq );
	// IPrintLn( "totalchange = ", totalchange );
	// IPrintLn( "changeamount = ", changeamount );

	while ( time > 0 )
	{
		time = time - freq;

		sunlight = sunlight - changeamount;
		SetDvar( "r_lighttweaksunlight", sunlight );
		// IPrintLn( "^6sunlight = ", sunlight );

		frac = ( sunlight - level.sunlight_dark ) / ( level.sunlight_bright - level.sunlight_dark );
		diffuse = level.diffuse_high + ( level.diffuse_low - level.diffuse_high ) * frac;
		SetDvar( "r_lighttweakdiffusefraction", diffuse );
		// IPrintLn( "^6diffuse = ", diffuse );

		wait freq;
	}
}

scale( percent )
{
		frac = percent / 100;
		return( level.sunlight_dark + frac * ( level.sunlight_bright - level.sunlight_dark ) ) - level.sunlight_dark;
}


adsDoF()
{
	Assert( IsPlayer( self ) );

	self.dof = level.dofDefault;
	art_tweak = false;

	for ( ;; )
	{
		wait( 0.05 );

		if ( level.level_specific_dof )
		{
			continue;
		}
		if ( GetDvarInt( "scr_cinematic" ) )
		{
			updateCinematicDoF();
			continue;
		}

		/# art_tweak = GetDvarInt( "scr_art_tweak" ); #/

		if ( GetDvarInt( "scr_dof_enable" ) && !art_tweak )
		{
			updateDoF();
			continue;
		}

		self setDefaultDepthOfField();
	}
}


updateCinematicDoF()
{
	Assert( IsPlayer( self ) );

	adsFrac = self PlayerAds();

	if ( adsFrac == 1 && GetDvarInt( "scr_cinematic_autofocus" ) )
	{
		traceDir = VectorNormalize( AnglesToForward( self GetPlayerAngles() ) );
		trace = BulletTrace( self GetEye(), self GetEye() + vector_multiply( traceDir, 100000 ), true, self );

		enemies = GetAIArray();
		nearEnd = 10000;
		farStart = -1;
		start_origin = self GetEye();
		start_angles = self GetPlayerAngles();
		bestDot = 0;
		bestFocalPoint = undefined;
		for ( index = 0; index < enemies.size; index++ )
		{
			end_origin = enemies[ index ].origin;
			normal = VectorNormalize( end_origin - start_origin );
			forward = AnglesToForward( start_angles );
			dot = VectorDot( forward, normal );

			if ( dot > bestDot )
			{
				bestDot = dot;
				bestFocalPoint = enemies[ index ].origin;
			}
		}

		if ( bestDot < 0.923 )
		{
			scrDoF = Distance( start_origin, trace[ "position" ] );
// 			scrDoF = GetDvarInt( "scr_cinematic_doffocus" ) * 39;
		}
		else
		{
			scrDoF = Distance( start_origin, bestFocalPoint );
		}

		changeDoFValue( "nearStart", 1, 200 );
		changeDoFValue( "nearEnd", scrDoF, 200 );
		changeDoFValue( "farStart", scrDoF + 196, 200 );
		changeDoFValue( "farEnd", ( scrDoF + 196 ) * 2, 200 );
		changeDoFValue( "nearBlur", 6, 0.1 );
		changeDoFValue( "farBlur", 3.6, 0.1 );
	}
	else
	{
		scrDoF = GetDvarInt( "scr_cinematic_doffocus" ) * 39;

		if ( self.curDoF != scrDoF )
		{
			changeDoFValue( "nearStart", 1, 100 );
			changeDoFValue( "nearEnd", scrDoF, 100 );
			changeDoFValue( "farStart", scrDoF + 196, 100 );
			changeDoFValue( "farEnd", ( scrDoF + 196 ) * 2, 100 );
			changeDoFValue( "nearBlur", 6, 0.1 );
			changeDoFValue( "farBlur", 3.6, 0.1 );
		}
	}

	self.curDoF = ( self.dof[ "farStart" ] - self.dof[ "nearEnd" ] ) / 2;

	self SetDepthOfField(
							self.dof[ "nearStart" ],
							self.dof[ "nearEnd" ],
							self.dof[ "farStart" ],
							self.dof[ "farEnd" ],
							self.dof[ "nearBlur" ],
							self.dof[ "farBlur" ]
							 );
}


updateDoF()
{
	Assert( IsPlayer( self ) );
	adsFrac = self PlayerAds();

	if ( adsFrac == 0.0 )
	{
		self setDefaultDepthOfField();
		return;
	}

	playerEye = self GetEye();
	playerAngles = self GetPlayerAngles();
	playerForward = VectorNormalize( AnglesToForward( playerAngles ) );

	trace = BulletTrace( playerEye, playerEye + vector_multiply( playerForward, 8192 ), true, self, true );
	enemies = GetAIArray( "axis" );

	weapon = self getcurrentweapon();
	if ( isdefined( level.special_weapon_dof_funcs[ weapon ] ) )
	{
		[[ level.special_weapon_dof_funcs[ weapon ] ]]( trace, enemies, playerEye, playerForward, adsFrac );
		return;
	}

	nearEnd = 10000;
	farStart = -1;

	for ( index = 0; index < enemies.size; index++ )
	{
		enemyDir = VectorNormalize( enemies[ index ].origin - playerEye );

		dot = VectorDot( playerForward, enemyDir );
		if ( dot < 0.923 )// 45 degrees
			continue;

		distFrom = Distance( playerEye, enemies[ index ].origin );

		if ( distFrom - 30 < nearEnd )
			nearEnd = distFrom - 30;

		if ( distFrom + 30 > farStart )
			farStart = distFrom + 30;
	}
	
	if ( nearEnd > farStart )
	{
		nearEnd = 256;
		farStart = 2500;
	}
	else
	{
		if ( nearEnd < 50 )
			nearEnd = 50;
		else 
		if ( nearEnd > 512 )
			nearEnd = 512;

		if ( farStart > 2500 )
			farStart = 2500;
		else 
		if ( farStart < 1000 )
			farStart = 1000;
	}

	traceDist = Distance( playerEye, trace[ "position" ] );

	if ( nearEnd > traceDist )
		nearEnd = traceDist - 30;

	if ( nearEnd < 1 )
		nearEnd = 1;

	if ( farStart < traceDist )
		farSTart = traceDist;
		
	self setDoFTarget( adsFrac, 1, nearEnd, farStart, farStart * 4, 6, 1.8 );
}

javelin_dof( trace, enemies, playerEye, playerForward, adsFrac )
{
	if ( adsFrac < 0.88 )
	{
		self setDefaultDepthOfField();
		return;
	}

	nearEnd = 10000;
	farStart = -1;
	nearEnd = 2400;
	nearStart = 2400;

	for ( index = 0; index < enemies.size; index++ )
	{
		enemyDir = VectorNormalize( enemies[ index ].origin - playerEye );

		dot = VectorDot( playerForward, enemyDir );
		if ( dot < 0.923 )// 45 degrees
			continue;

		distFrom = Distance( playerEye, enemies[ index ].origin );
		if ( distFrom < 2500 )
			distFrom = 2500;

		if ( distFrom - 30 < nearEnd )
			nearEnd = distFrom - 30;

		if ( distFrom + 30 > farStart )
			farStart = distFrom + 30;
	}
	
	
	if ( nearEnd > farStart )
	{
		nearEnd = 2400;
		farStart = 3000;
	}
	else
	{
		if ( nearEnd < 50 )
			nearEnd = 50;

		if ( farStart > 2500 )
			farStart = 2500;
		else 
		if ( farStart < 1000 )
			farStart = 1000;
	}

	traceDist = Distance( playerEye, trace[ "position" ] );
	if ( traceDist < 2500 )
		traceDist = 2500;

	if ( nearEnd > traceDist )
		nearEnd = traceDist - 30;

	if ( nearEnd < 1 )
		nearEnd = 1;

	if ( farStart < traceDist )
		farSTart = traceDist;
		
	if ( nearStart >= nearEnd )
		nearStart = nearEnd - 1;

	self setDoFTarget( adsFrac, nearStart, nearEnd, farStart, farStart * 4, 4, 1.8 );
}

setDoFTarget( adsFrac, nearStart, nearEnd, farStart, farEnd, nearBlur, farBlur )
{
	Assert( IsPlayer( self ) );

	
	if ( adsFrac == 1 )
	{
		changeDoFValue( "nearStart", nearStart, 50 );
		changeDoFValue( "nearEnd", nearEnd, 50 );
		changeDoFValue( "farStart", farStart, 400 );
		changeDoFValue( "farEnd", farEnd, 400 );
		changeDoFValue( "nearBlur", nearBlur, 0.1 );
		changeDoFValue( "farBlur", farBlur, 0.1 );
	}
	else
	{
		lerpDoFValue( "nearStart", nearStart, adsFrac );
		lerpDoFValue( "nearEnd", nearEnd, adsFrac );
		lerpDoFValue( "farStart", farStart, adsFrac );
		lerpDoFValue( "farEnd", farEnd, adsFrac );
		lerpDoFValue( "nearBlur", nearBlur, adsFrac );
		lerpDoFValue( "farBlur", farBlur, adsFrac );
	}

	self SetDepthOfField(
							self.dof[ "nearStart" ],
							self.dof[ "nearEnd" ],
							self.dof[ "farStart" ],
							self.dof[ "farEnd" ],
							self.dof[ "nearBlur" ],
							self.dof[ "farBlur" ]
							 );
}

changeDoFValue( valueName, targetValue, maxChange )
{
	Assert( IsPlayer( self ) );

	if ( self.dof[ valueName ] > targetValue )
	{
		changeVal = ( self.dof[ valueName ] - targetValue ) * 0.5;
		if ( changeVal > maxChange )
			changeVal = maxChange;
		else if ( changeVal < 1 )
			changeVal = 1;

		if ( self.dof[ valueName ] - changeVal < targetValue )
			self.dof[ valueName ] = targetValue;
		else
			self.dof[ valueName ] -= changeVal;
	}
	else if ( self.dof[ valueName ] < targetValue )
	{
		changeVal = ( targetValue - self.dof[ valueName ] ) * 0.5;
		if ( changeVal > maxChange )
			changeVal = maxChange;
		else if ( changeVal < 1 )
			changeVal = 1;

		if ( self.dof[ valueName ] + changeVal > targetValue )
			self.dof[ valueName ] = targetValue;
		else
			self.dof[ valueName ] += changeVal;
	}
}

lerpDoFValue( valueName, targetValue, lerpAmount )
{
	Assert( IsPlayer( self ) );

	self.dof[ valueName ] = level.dofDefault[ valueName ] + ( ( targetValue - level.dofDefault[ valueName ] ) * lerpAmount ) ;
}

dofvarupdate()
{
		level.dofDefault[ "nearStart" ] = GetDvarInt( "scr_dof_nearStart" );
		level.dofDefault[ "nearEnd" ] = GetDvarInt( "scr_dof_nearEnd" );
		level.dofDefault[ "farStart" ] = GetDvarInt( "scr_dof_farStart" );
		level.dofDefault[ "farEnd" ] = GetDvarInt( "scr_dof_farEnd" );
		level.dofDefault[ "nearBlur" ] = GetDvarFloat( "scr_dof_nearBlur" );
		level.dofDefault[ "farBlur" ] = GetDvarFloat( "scr_dof_farBlur" );
}

setdefaultdepthoffield()
{
	Assert( IsPlayer( self ) );

	if ( isdefined( self.dofDefault ) )
	{
		self SetDepthOfField(
								self.dofDefault[ "nearStart" ],
								self.dofDefault[ "nearEnd" ],
								self.dofDefault[ "farStart" ],
								self.dofDefault[ "farEnd" ],
								self.dofDefault[ "nearBlur" ],
								self.dofDefault[ "farBlur" ]
								 );
	}
	else
	{
		self SetDepthOfField(
								level.dofDefault[ "nearStart" ],
								level.dofDefault[ "nearEnd" ],
								level.dofDefault[ "farStart" ],
								level.dofDefault[ "farEnd" ],
								level.dofDefault[ "nearBlur" ],
								level.dofDefault[ "farBlur" ]
								 );
	}
}


isDoFDefault()
{
	if ( level.dofDefault[ "nearStart" ] != GetDvarInt( "scr_dof_nearStart" ) )
		return false;

	if ( level.dofDefault[ "nearEnd" ] != GetDvarInt( "scr_dof_nearEnd" ) )
		return false;

	if ( level.dofDefault[ "farStart" ] != GetDvarInt( "scr_dof_farStart" ) )
		return false;

	if ( level.dofDefault[ "farEnd" ] != GetDvarInt( "scr_dof_farEnd" ) )
		return false;

	if ( level.dofDefault[ "nearBlur" ] != GetDvarInt( "scr_dof_nearBlur" ) )
		return false;

	if ( level.dofDefault[ "farBlur" ] != GetDvarInt( "scr_dof_farBlur" ) )
		return false;

	return true;
}


