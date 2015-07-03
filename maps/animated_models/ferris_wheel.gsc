#include common_scripts\utility;

main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "ferris_wheel_animated";
	level.anim_prop_models[ model ][ "rotate" ] = "ferris_wheel_anim";
}

// SP not currently supported because this requires updating "animated_props" animtree