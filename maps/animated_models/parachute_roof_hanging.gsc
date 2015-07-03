#include common_scripts\utility;

main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "parachute_roof_hanging_animated";
	level.anim_prop_models[ model ][ "operate" ] = "parachute_roof_hanging_anim";
}

// SP not currently supported because this requires updating "animated_props" animtree