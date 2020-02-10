#include common_scripts\utility;
#include common_scripts\_destructible;
#include common_scripts\_destructible_types;
#using_animtree( "destructibles_dlc2" );

makeType_dlc2( destructibleType ) 
{
	//println( destructibleType );

	// if it's already been created dont create it again
	infoIndex = getInfoIndex( destructibleType );
	if ( infoIndex >= 0 )
		return infoIndex;

	found_dlc2_destructible = true;
	switch ( destructibleType )
	{
		// add new destructibles here, you can write new functions for them or call the old ones
		case "toy_fortune_machine":
			toy_fortune_machine( destructibleType );
			break;
		case "toy_trashcan_clown":
			toy_trashcan_clown( destructibleType );
			break;
		case "toy_popcorn_cart":
			toy_popcorn_cart( destructibleType );
			break;
		case "vehicle_theme_park_truck":
			vehicle_theme_park_truck( destructibleType );
			break;
		case "vehicle_delivery_truck_white":
			vehicle_delivery_truck_white( destructibleType );
			break;
		case "toy_keg":
			toy_keg( destructibleType );
			break;
		case "toy_propane_tank03":
			toy_propane_tank03( destructibleType );
			break;
		case "toy_propane_tank03b":
			toy_propane_tank03b( destructibleType );
			break;

		default:
			found_dlc2_destructible = false;
			break;
	}
	
	if ( !found_dlc2_destructible )
	{
		return undefined;
	}

	infoIndex = getInfoIndex( destructibleType );
	assert( infoIndex >= 0 );
	return infoIndex;
}

toy_fortune_machine( destructibleType )
{
	//---------------------------------------------------------------------
	// Exploding Fortune Telling Maching
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_origin", 0, undefined, 32 );
			destructible_loopsound( "fortune_machine_idle" );
			destructible_loopfx( "J_Eye_RI", "props/fortune_machine_glow_eyes", 2.9 );
			destructible_loopfx( "J_Eye_LE", "props/fortune_machine_glow_eyes", 2.9 );
			destructible_loopfx( "tag_fx3", "props/fortune_machine_glow_ball", 4.0 );
			destructible_anim( get_precached_anim( "fortune_machine_anim" ), #animtree, "setanimknob", undefined, undefined, "fortune_machine_anim" );
		destructible_state( "tag_origin", "fortune_machine", 75 );
			destructible_fx( "tag_fx", "props/fortune_machine_exp", undefined, undefined, undefined, 1 );
			destructible_fx( "tag_fx2", "props/fortune_machine_tickets" );
			destructible_sound( "fortune_machine_destroy" );
			destructible_anim( get_precached_anim( "fortune_machine_des" ), #animtree, "setanimknob", undefined, 0, "fortune_machine_des" );
			destructible_explode( 20, 2000, 20, 20, 40, 40, undefined, 64 ); 	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage, continueDamage, originOffset
		destructible_state( undefined, "fortune_machine_des", undefined, undefined, "no_melee" );
}

toy_trashcan_clown( destructibleType )
{
	//---------------------------------------------------------------------
	// Clown Trashcan toy
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_origin", 120, undefined, 32 );
				destructible_fx( "tag_fx", "props/garbage_spew_des", true, "splash" );
				destructible_fx( "tag_fx", "props/garbage_spew", true, damage_not( "splash" ) );
				destructible_sound( "exp_trashcan_sweet" ); 															
				destructible_explode( 600, 651, 1, 1, 10, 20 ); 	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage

		destructible_state( "tag_origin", "trashcan_clown_base", undefined, undefined, undefined, undefined, undefined, false );


		destructible_part( "tag_fx", "trashcan_clown_lid", undefined, undefined, undefined, undefined, 1.0, 1.0 );

}


toy_popcorn_cart( destructibleType )
{
	//---------------------------------------------------------------------
	// Exploding Fortune Telling Maching
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_glass", 5 );
			destructible_fx( "tag_fx", "props/popcorn_cart_glass_dmg" );
			destructible_sound( "popcorn_cart_glass_dmg" );
		destructible_state( undefined, "popcorn_cart_glass_dmg", 100, undefined, undefined, "splash" );
			destructible_fx( "tag_fx", "props/popcorn_cart_exp" );
			destructible_sound( "popcorn_cart_destroy" );
		destructible_state( undefined, "popcorn_cart_damaged", undefined, undefined, undefined, undefined, undefined, false );
		
		destructible_part( "tag_glass", "popcorn_cart_damaged", 4, undefined, undefined, undefined, 1.0, 1.0 );
}


vehicle_theme_park_truck( destructibleType )
{
	//---------------------------------------------------------------------
	// White Moving Truck
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_body", 300, undefined, 32, "no_melee" );
		//destructible_splash_damage_scaler( 18 );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 15, 0.25, 210, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/vehicle_explosion_medium", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 210, 250, 50, 300, undefined, undefined, 0.3, 500 );
				destructible_anim( %vehicle_80s_sedan1_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_80s_sedan1_destroy" );
			destructible_state( undefined, "vehicle_theme_park_truck_destroyed", undefined, 32, "no_melee" );
		// Tires
		destructible_part( "left_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "left_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		// Glass ( Front )
		tag = "tag_glass_front";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		tag = "tag_glass_front2";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// glass left
		tag = "tag_glass_side_left";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		tag = "tag_glass_left_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// glass right
		tag = "tag_glass_side_right";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		tag = "tag_glass_right_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );

}

vehicle_delivery_truck_white( destructibleType )
{
	//---------------------------------------------------------------------
	// White Moving Truck
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_body", 300, undefined, 32, "no_melee" );
		//destructible_splash_damage_scaler( 18 );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 15, 0.25, 210, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/vehicle_explosion_medium", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 210, 250, 50, 300, undefined, undefined, 0.3, 500 );
				destructible_anim( %vehicle_80s_sedan1_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_80s_sedan1_destroy" );
			destructible_state( undefined, "vehicle_delivery_truck_white_destroyed", undefined, 32, "no_melee" );
		// Tires
		destructible_part( "left_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "left_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		// Glass ( Front )
		tag = "tag_glass_front";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		tag = "tag_glass_front2";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// glass left
		tag = "tag_glass_side_left";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		tag = "tag_glass_left_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// glass right
		tag = "tag_glass_side_right";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		tag = "tag_glass_right_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );

}

toy_keg( destructibleType )
{
	//---------------------------------------------------------------------
	// beer keg toy
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_origin", 250, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 11 );
			destructible_state( undefined, undefined, 500, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_fx", "props/keg_leak", 0.1 );
				destructible_loopsound( "keg_spray_loop" );
				destructible_healthdrain( 12, 0.2 );
			destructible_state( undefined, undefined, 800, undefined, 5, "no_melee" );
				destructible_fx( "tag_fx", "props/keg_exp", false );
				destructible_fx( "tag_fx", "props/keg_spray_10sec", false );
				destructible_sound( "keg_burst" );
				destructible_explode( 17000, 18000, 96, 96, 32, 48 ); 	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
			destructible_state( undefined, "prop_trailerpark_beer_keg_dest", undefined, undefined, "no_melee" );

		// destroyed hydrant
//		destructible_part( "tag_fx", "com_keg_dam", undefined, undefined, undefined, undefined, 1.0, 1.0 );
		// side cap
//		destructible_part( "tag_cap", "com_keg_cap", undefined, undefined, undefined, undefined, 1.0, 1.0 );
}

toy_propane_tank03( destructibleType )
{
	//---------------------------------------------------------------------
	// Smaller Propane tank goes KaBooM
	//---------------------------------------------------------------------
	
	destructible_create( destructibleType, "tag_origin", 50, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 10 );
			destructible_state( undefined, undefined, 350, undefined, 32, "no_melee" );
				destructible_loopsound( "propanetank03_gas_leak_loop" );
				destructible_loopfx( "tag_cap", "distortion/propane_cap_distortion_small", 0.1 );
			destructible_state( undefined, undefined, 350, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_cap", "fire/propane_capfire_leak", 0.1 );
				destructible_sound( "propanetank03_flareup_med" );
				destructible_loopsound( "propanetank03_fire_med" );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_physics( "tag_cap", ( 50, 0, 0 ) );
				//destructible_loopfx( "tag_cap", "fire/propane_capfire", 0.6 );
				destructible_fx( "tag_cap", "fire/propane_valvefire_flareup" );
				//destructible_fx( "tag_cap", "fire/propane_capfire_flareup" );
				destructible_loopfx( "tag_cap", "fire/propane_valvefire", 0.1 );
				destructible_sound( "propanetank03_flareup_med" );
				destructible_loopsound( "propanetank03_fire_med" );
			destructible_state( undefined, undefined, 200, undefined, 5, "no_melee" );
				destructible_fx( "tag_fx", "fire/firelp_med_pm" );
				//destructible_fx( "tag_fx", "explosions/propane_large_exp_fireball" );
				destructible_fx( "tag_fx", "explosions/propane_small_exp", false );
				destructible_sound( "propanetank03_explode" );
				destructible_explode( 3500, 4000, 300, 300, 32, 200, undefined, 32 ); 	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
			destructible_state( undefined, "com_propane_tank03_d", undefined, undefined, "no_melee" );
		// Top Cap
		destructible_part( "tag_cap", "com_propane_tank_lid_03" );

}

toy_propane_tank03b( destructibleType )
{
	//---------------------------------------------------------------------
	// Smaller Propane tank goes KaBooM
	//---------------------------------------------------------------------
	
	destructible_create( destructibleType, "tag_origin", 50, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 10 );
			destructible_state( undefined, undefined, 350, undefined, 32, "no_melee" );
				destructible_loopsound( "propanetank03_gas_leak_loop" );
				destructible_loopfx( "tag_cap", "distortion/propane_cap_distortion_small", 0.1 );
			destructible_state( undefined, undefined, 350, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_cap", "fire/propane_capfire_leak", 0.1 );
				destructible_sound( "propanetank03_flareup_med" );
				destructible_loopsound( "propanetank03_fire_med" );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_physics( "tag_cap", ( 50, 0, 0 ) );
				//destructible_loopfx( "tag_cap", "fire/propane_capfire", 0.6 );
				destructible_fx( "tag_cap", "fire/propane_valvefire_flareup" );
				//destructible_fx( "tag_cap", "fire/propane_capfire_flareup" );
				destructible_loopfx( "tag_cap", "fire/propane_valvefire", 0.1 );
				destructible_sound( "propanetank03_flareup_med" );
				destructible_loopsound( "propanetank03_fire_med" );
			destructible_state( undefined, undefined, 200, undefined, 5, "no_melee" );
				destructible_fx( "tag_fx", "fire/firelp_med_pm" );
				//destructible_fx( "tag_fx", "explosions/propane_large_exp_fireball" );
				destructible_fx( "tag_fx", "explosions/propane_small_exp", false );
				destructible_sound( "propanetank03_explode" );
				destructible_explode( 3500, 4000, 300, 300, 32, 200, undefined, 32 ); 	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
			destructible_state( undefined, "com_propane_tank03_d", undefined, undefined, "no_melee" );
		// Top Cap
		destructible_part( "tag_cap", "com_propane_tank_lid_03b" );

}
