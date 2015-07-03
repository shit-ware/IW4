main( model, type )
{
	maps\_snowmobile::main( model, "snowmobile_friendly" );
}


/*QUAKED script_vehicle_snowmobile_friendly (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile_friendly::main( "vehicle_snowmobile_alt" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile_alt"
default:"vehicletype" "snowmobile_friendly"
default:"script_team" "allies"
*/