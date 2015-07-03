#include common_scripts\utility;

main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "foliage_tree_green_pine_lg_b_animated";
	level.anim_prop_models[ model ][ "sway" ] = "foliage_tree_green_pine_lg_b_sway";
}

// SP not currently supported because this requires updating "animated_props" animtree