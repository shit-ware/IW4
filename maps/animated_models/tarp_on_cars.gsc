#include common_scripts\utility;

main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "tarp_on_cars_animated";
	level.anim_prop_models[ model ][ "wind" ] = "tarp_cars_anim";
}

// SP not currently supported because this requires updating "animated_props" animtree