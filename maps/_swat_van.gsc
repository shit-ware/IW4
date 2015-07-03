#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );
main( model, type )
{
    build_template( "swat_van", model, type );
    build_localinit( ::init_local );
    build_deathmodel( "vehicle_russian_swat_van" );
	
	build_deathfx( "explosions/large_vehicle_explosion", 	undefined, 				"car_explode", 						undefined, 			undefined, 		undefined, 		0 );      
    
    build_radiusdamage( ( 0, 0, 32 ), 300, 200, 100, false );
    build_drive( %uaz_driving_idle_forward, %uaz_driving_idle_backward, 10 );
   
    build_deathquake( 1, 1.6, 500 );
    build_treadfx();
    build_life( 999, 500, 1500 );
    build_team( "axis" );
    
    build_aianims( ::setanims, ::set_vehicle_anims );
    
    build_compassicon( "automobile", false );
}


init_local()
{
}


set_vehicle_anims( positions )
{
	positions[ 0 ].vehicle_getoutanim = %russian_swat_van_driver_getout_door;
	positions[ 0 ].vehicle_getoutsoundtag = "front_door_left_jnt";
    positions[ 0 ].vehicle_getoutanim_clear = true;
    
    return positions;
}


#using_animtree( "generic_human" );


setanims()
{
        positions = [];
        for ( i = 0;i < 1;i++ )
                positions[ i ] = spawnstruct();


        positions[ 0 ].sittag 			= "tag_driver";
		positions[ 0 ].idle 			= %russian_swat_van_driver_idle;
		positions[ 0 ].getout 			= %russian_swat_van_driver_getout;
        
        return positions;
}


/*QUAKED script_vehicle_russian_swat_van (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


put this in your GSC:
maps\_swat_van::main( "vehicle_russian_swat_van" );


and these lines in your CSV:
include,vehicle_russian_swat_van
sound,vehicle_swat_van,vehicle_standard,all_sp


defaultmdl="vehicle_russian_swat_van"
default:"vehicletype" "swat_van"
*/ 