#include common_scripts\utility;

main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "foliage_pacific_palms06_animated";
	level.anim_prop_models[ model ][ "sway" ] = "foliage_pacific_palms06_sway";
}

// SP not currently supported because this requires updating "animated_props" animtree