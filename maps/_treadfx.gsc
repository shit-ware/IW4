#include maps\_utility;
main( vehicletype )
{
	//this sets default tread and tire fx for vehicles - they can be overwritten in level scripts
	if ( !isdefined( vehicletype ) )
		return;
	level.vehicle_treads[ vehicletype ] = true;
	switch( vehicletype )
	{
		case "apache":
		case "cobra":
		case "cobra_player":
		case "littlebird":
		case "littlebird_player":
		case "blackhawk":
		case "blackhawk_minigun":
		case "blackhawk_minigun_so":
		case "hind":
		case "harrier":
		case "mi17":
		case "mi17_noai":
		case "seaknight":
		case "seaknight_airlift":
		case "mi28":
		case "pavelow":
		case "mig29":
		case "b2":
			setallvehiclefx( vehicletype, "treadfx/heli_dust_default" );
			setvehiclefx( vehicletype, "water", "treadfx/heli_water" );
			setvehiclefx( vehicletype, "snow", "treadfx/heli_snow_default" );
			setvehiclefx( vehicletype, "slush", "treadfx/heli_snow_default" );
			setvehiclefx( vehicletype, "ice", "treadfx/heli_snow_default" );
			break;
		default:// if the vehicle isn't in this list it will use these effects
			setallvehiclefx( vehicletype, "treadfx/tread_dust_default" );
			setvehiclefx( vehicletype, "water" );
			setvehiclefx( vehicletype, "concrete" );
			setvehiclefx( vehicletype, "rock" );
			setvehiclefx( vehicletype, "metal" );
			setvehiclefx( vehicletype, "brick" );
			setvehiclefx( vehicletype, "plaster" );
			setvehiclefx( vehicletype, "asphalt" );
			setvehiclefx( vehicletype, "paintedmetal" );
			setvehiclefx( vehicletype, "riotshield" );
			setvehiclefx( vehicletype, "snow", "treadfx/tread_snow_default" );
			setvehiclefx( vehicletype, "slush", "treadfx/tread_snow_default" );
			setvehiclefx( vehicletype, "ice", "treadfx/tread_ice_default" );
			break;
	}
}

setvehiclefx( vehicletype, material, fx )
{
	if ( !isdefined( level._vehicle_effect ) )
		level._vehicle_effect = [];
	if ( !isdefined( fx ) )
		level._vehicle_effect[ vehicletype ][ material ] = -1;
	else
		level._vehicle_effect[ vehicletype ][ material ] = loadfx( fx );
}

setallvehiclefx( vehicletype, fx )
{
	setvehiclefx( vehicletype, "brick", fx );
 	setvehiclefx( vehicletype, "bark", fx );
 	setvehiclefx( vehicletype, "carpet", fx );
 	setvehiclefx( vehicletype, "cloth", fx );
 	setvehiclefx( vehicletype, "concrete", fx );
 	setvehiclefx( vehicletype, "dirt", fx );
 	setvehiclefx( vehicletype, "flesh", fx );
 	setvehiclefx( vehicletype, "foliage", fx );
 	setvehiclefx( vehicletype, "glass", fx );
 	setvehiclefx( vehicletype, "grass", fx );
 	setvehiclefx( vehicletype, "gravel", fx );
 	setvehiclefx( vehicletype, "ice", fx );
 	setvehiclefx( vehicletype, "metal", fx );
 	setvehiclefx( vehicletype, "mud", fx );
 	setvehiclefx( vehicletype, "paper", fx );
 	setvehiclefx( vehicletype, "plaster", fx );
 	setvehiclefx( vehicletype, "rock", fx );
 	setvehiclefx( vehicletype, "sand", fx );
 	setvehiclefx( vehicletype, "snow", fx );
 	setvehiclefx( vehicletype, "water", fx );
 	setvehiclefx( vehicletype, "wood", fx );
 	setvehiclefx( vehicletype, "asphalt", fx );
 	setvehiclefx( vehicletype, "ceramic", fx );
 	setvehiclefx( vehicletype, "plastic", fx );
 	setvehiclefx( vehicletype, "rubber", fx );
 	setvehiclefx( vehicletype, "cushion", fx );
 	setvehiclefx( vehicletype, "fruit", fx );
 	setvehiclefx( vehicletype, "paintedmetal", fx );
 	setvehiclefx( vehicletype, "riotshield", fx );
 	setvehiclefx( vehicletype, "slush", fx );
 	setvehiclefx( vehicletype, "default", fx );
	setvehiclefx( vehicletype, "none" );
}