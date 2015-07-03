#include maps\_vehicle;
#include maps\_vehicle_aianim;


main( model, type )
{
	build_template( "zodiac_player", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_zodiac_viewmodel" );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );

	//build_treadfx();  //currently disabled because vehicle type "boat" isn't supported. http://bugzilla.infinityward.net/show_bug.cgi?id=85644
}


init_local()
{
}

set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_body";
	positions[ 1 ].sittag = "tag_body";
	positions[ 2 ].sittag = "tag_body";
	positions[ 3 ].sittag = "tag_body";
	positions[ 4 ].sittag = "tag_body";
	positions[ 5 ].sittag = "tag_body";

	positions[ 0 ].idle = %oilrig_civ_escape_1_seal_A;
	positions[ 1 ].idle = %oilrig_civ_escape_2_seal_A;
	positions[ 2 ].idle = %oilrig_civ_escape_3_A;
	positions[ 3 ].idle = %oilrig_civ_escape_4_A;
	positions[ 4 ].idle = %oilrig_civ_escape_5_A;
	positions[ 5 ].idle = %oilrig_civ_escape_6_A;

	positions[ 0 ].getout = %pickup_driver_climb_out;
	positions[ 1 ].getout = %pickup_driver_climb_out;
	positions[ 2 ].getout = %pickup_driver_climb_out;
	positions[ 3 ].getout = %pickup_driver_climb_out;
	positions[ 4 ].getout = %pickup_driver_climb_out;
	positions[ 5 ].getout = %pickup_driver_climb_out;

	return positions;
}
/*QUAKED script_vehicle_zodiac_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_zodiac_player::main( "vehicle_zodiac_viewmodel" );

and these lines in your CSV:
include,vehicle_zodiac_player
sound,vehicle_zodiac,vehicle_standard,all_sp


defaultmdl="vehicle_zodiac_viewmodel"
default:"vehicletype" "zodiac_player"
default:"script_team" "allies"
*/
