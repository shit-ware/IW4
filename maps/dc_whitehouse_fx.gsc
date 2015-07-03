#include common_scripts\utility;
#include maps\_utility;
#include maps\_weather;

main()
{
		
	if ( getdvarint( "sm_enable" ) )
	{
		// Hunted Spotlight
		level._effect[ "_attack_heli_spotlight" ]	 			= loadfx( "misc/hunted_spotlight_model" );
	}
	else
	{
		// MinSpec Spotlight
		level._effect[ "_attack_heli_spotlight" ]				= loadfx( "misc/spotlight_large_dcburning" );
	}	
	
	//CRASH SCENE FX 
	level._effect[ "firelp_large_pm" ]							= loadfx( "fire/firelp_large_pm" );
	level._effect[ "firelp_med_pm" ]							= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm" ]							= loadfx( "fire/firelp_small_pm" );
	level._effect[ "firelp_small_pm_a" ]						= loadfx( "fire/firelp_small_pm_a" );
	
	level._effect[ "firelp_large_pm_nolight" ]					= loadfx( "fire/firelp_large_pm_nolight" );
	level._effect[ "firelp_med_pm_nolight" ]					= loadfx( "fire/firelp_med_pm_nolight" );
	level._effect[ "firelp_small_pm_nolight" ]					= loadfx( "fire/firelp_small_pm_nolight" );
	level._effect[ "firelp_small_pm_a_nolight" ]				= loadfx( "fire/firelp_small_pm_a_nolight" );
		
	//Tunnel	
	level._effect[ "waterfall_drainage_short" ] 				= loadfx( "water/waterfall_drainage_short_dcemp" );
	level._effect[ "waterfall_drainage_splash" ] 				= loadfx( "water/waterfall_drainage_splash_dcemp" );
	level._effect[ "falling_water_trickle" ]	 				= loadfx( "water/falling_water_trickle" );
	level._effect[ "rain_noise_splashes" ]						= loadfx( "weather/rain_noise_splashes" );
	level._effect[ "cgo_ship_puddle_large" ]		 			= loadfx( "distortion/cgo_ship_puddle_large" );

	//WHITEHOUSE
	level._effect[ "transformer_spark_runner" ]					= loadfx( "explosions/transformer_spark_runner" );

	level._effect[ "hallway_smoke_light" ]						= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "room_smoke_200" ]							= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_200_dcwhite" ]					= loadfx( "smoke/room_smoke_200_dcwhite" );
	level._effect[ "room_smoke_400" ]							= loadfx( "smoke/room_smoke_400" );

	level._effect[ "rock_falling_small_runner" ]	 			= loadfx( "misc/rock_falling_small_runner" );
	level._effect[ "powerline_runner_cheap" ] 					= loadfx( "explosions/powerline_runner_cheap" );

	level._effect[ "fire_tree_slow_longrange" ] 				= loadfx( "fire/fire_tree_slow_longrange" );
	level._effect[ "field_fire_distant" ] 						= loadfx( "fire/field_fire_distant" );
	level._effect[ "embers_whitehouse" ] 						= loadfx( "fire/embers_whitehouse" );

	level._effect[ "green_flare" ] 								= loadfx( "misc/handflare_green" );
	level._effect[ "green_flare_ignite" ] 						= loadfx( "misc/handflare_green_ignite" );
	level._effect[ "player_flare" ]								= loadfx( "impacts/small_metalhit" );
	level._effect[ "carpetbomb" ]								= loadfx( "explosions/tanker_explosion" );

	level._effect[ "green_flare_smoke_distant" ]				= loadfx( "smoke/green_flare_smoke_distant" );
	level._effect[ "thin_black_smoke_dcwhite" ]					= loadfx( "smoke/thin_black_smoke_dcwhite" );

	level._effect[ "breach_room_concrete_whitehouse" ]			= loadfx( "explosions/breach_room_concrete_whitehouse" );
	level._effect[ "breach_room_residual_whitehouse" ]			= loadfx( "explosions/breach_room_residual_whitehouse" );
	level._effect[ "breach_wall_concrete_whitehouse" ]			= loadfx( "explosions/breach_wall_concrete_whitehouse" );
	level._effect[ "falling_brick_runner_whitehouse" ]			= loadfx( "misc/falling_brick_runner_whitehouse" );

	//CHANDELIER
	level._effect[ "wire_spark" ]								= loadfx( "explosions/transformer_spark_runner" );

	//SPOTLIGHT
	level._effect[ "spotlight_spark" ]							= loadfx( "explosions/transformer_spark_runner" );

	//LIGHTING
	level._effect[ "lightning" ]				 				= loadfx( "weather/lightning" );
	level._effect[ "lightning_bolt" ]			 				= loadfx( "weather/lightning_bolt" );
	level._effect[ "lightning_bolt_lrg" ]						= loadfx( "weather/lightning_bolt_lrg" );
	addLightningExploder( 10 );// these exploders make lightning flashes in the sky
	addLightningExploder( 11 );
	addLightningExploder( 12 );
	level.nextLightning = gettime() + 1;// 10000 + randomfloat( 4000 );// sets when the first lightning of the level will go off
	
	//footstep fx
/*	animscripts\utility::setFootstepEffect( "mud", 			loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "grass", 		loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "dirt", 		loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "concrete", 	loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "rock", 		loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "asphalt", 		loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "wood", 		loadfx( "impacts/footstep_water_dark" ) );
	animscripts\utility::setFootstepEffect( "metal", 		loadfx( "impacts/footstep_water_dark" ) );
*/
	// Rain
	level._effect[ "rain_10" ]	 							= loadfx( "weather/rain_heavy_mist" );
	level._effect[ "rain_9" ]		 						= loadfx( "weather/rain_9_lite" );
	level._effect[ "rain_8" ]		 						= loadfx( "weather/rain_8_lite" );
	level._effect[ "rain_7" ]		 						= loadfx( "weather/rain_7_lite" );
	level._effect[ "rain_6" ]		 						= loadfx( "weather/rain_6_lite" );
	level._effect[ "rain_5" ]		 						= loadfx( "weather/rain_5_lite" );
	level._effect[ "rain_4" ]		 						= loadfx( "weather/rain_4_lite" );
	level._effect[ "rain_3" ]		 						= loadfx( "weather/rain_3_lite" );
	level._effect[ "rain_2" ]		 						= loadfx( "weather/rain_2_lite" );
	level._effect[ "rain_1" ]		 						= loadfx( "weather/rain_1_lite" );
	level._effect[ "rain_0" ]		 						= loadfx( "misc/blank" );
	
	thread rainInit( "none" );// "none" "light" or "hard"	
	thread playerWeather();	// make the actual rain effect generate around the player
	
	//enable this line for correct vision in createfx BESURE TO DISABLE
	//thread maps\_utility::vision_set_fog_changes( "dc_whitehouse_roof", 0 );

}

lightning_flash( dir )
{
	level notify( "emp_lighting_flash" );
	level endon( "emp_lighting_flash" );

	if ( level.createFX_enabled )
		return;

   	num = randomintrange( 1, 4 );
	
	if( !isdefined( dir ) )
		dir = ( -20, 60, 0 );
	
    for ( i = 0; i < num; i++ )
    {
    	type = randomint( 3 );
	    switch( type )
	    {
	    	case 0:
	    		wait( 0.05 );
						   			    
			    setSunLight( 1, 1, 1.2 );	
				//parking_lightning( 1.2 );    
			    
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
			    //parking_lightning( 2.25 );

	    		break;

	    	case 1:{
	    		wait( 0.05 );
			   
			    setSunLight( 1, 1, 1.2 );	
			   	//parking_lightning( 1.2 );	    
			     
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
			    //parking_lightning( 2.25 );

			   	wait( 0.05 );

			    setSunLight( 3, 3, 3.7 );
			    //parking_lightning( 3 );

	    		}break;

	    	case 2:{
	    		wait( 0.05 );
			   
			    setSunLight( 1, 1, 1.2 );
			    //parking_lightning( 1.2 );	
			     
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
			    //parking_lightning( 2.25 );

			   	wait( 0.05 );

			    setSunLight( 3, 3, 3.7 );
			    //parking_lightning( 3 );
			    
			    wait( 0.05 );

			    setSunLight( 2, 2, 2.5 );
			    //parking_lightning( 2.25 );

	    		}break;
	    }
	    
	    wait randomfloatrange( 0.05, 0.1 );
   		lightning_normal();
    }
    lightning_normal();
}

lightning_normal()
{
    resetSunLight();
    resetSunDirection();	
}
