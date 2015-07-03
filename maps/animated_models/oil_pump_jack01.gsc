#include common_scripts\utility;

main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	// Uses .animation
	model = "oil_pump_jack";
	level.anim_prop_models[ model ][ "operate" ] = "oil_pump";
}

// SP not currently supported because this requires updating "animated_props" animtree