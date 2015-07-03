
/*QUAKED script_vehicle_littlebird_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

valid ai groups are:
"first_guys" - left and right side guys that need to be on first
"left" - all left guys
"right" - all right guys
"passengers" - everybody that can unload
"default"

put this in your GSC:
maps\_littlebird_player::main( "vehicle_little_bird_bench" );

and these lines in your CSV:
include,vehicle_littlebird_bench
sound,vehicle_littlebird,vehicle_standard,all_sp

defaultmdl="vehicle_little_bird_bench"
default:"vehicletype" "littlebird_player"
default:"script_team" "allies"
*/

main( model, type )
{
	maps\_littlebird::main( model, "littlebird_player" );
}