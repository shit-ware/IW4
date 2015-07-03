setupMiniMap( material )
{
	level.minimap_image = material;
	if ( !isdefined( level._loadStarted ) )
	{
		println( "^1Warning: shouldn't call setupMiniMap until after _load::main()" );
	}

	// use 0 for no required map aspect ratio.
	requiredMapAspectRatio = getdvarfloat( "scr_requiredMapAspectRatio", 1 );

	corners = getentarray( "minimap_corner", "targetname" );
	if ( corners.size != 2 )
	{
		println( "^1Error: There are not exactly two \"minimap_corner\" entities in the map. Could not set up minimap." );
		return;
	}

	corner0 = ( corners[ 0 ].origin[ 0 ], corners[ 0 ].origin[ 1 ], 0 );
	corner1 = ( corners[ 1 ].origin[ 0 ], corners[ 1 ].origin[ 1 ], 0 );

	cornerdiff = corner1 - corner0;

	north = ( cos( getnorthyaw() ), sin( getnorthyaw() ), 0 );
	west = ( 0 - north[ 1 ], north[ 0 ], 0 );

	// we need the northwest and southeast corners. all we know is that corner0 is opposite of corner1.
	if ( vectordot( cornerdiff, west ) > 0 ) {
		// corner1 is further west than corner0
		if ( vectordot( cornerdiff, north ) > 0 ) {
			// corner1 is northwest, corner0 is southeast
			northwest = corner1;
			southeast = corner0;
		}
		else {
			// corner1 is southwest, corner0 is northeast
			side = vecscale( north, vectordot( cornerdiff, north ) );
			northwest = corner1 - side;
			southeast = corner0 + side;
		}
	}
	else {
		// corner1 is further east than corner0
		if ( vectordot( cornerdiff, north ) > 0 ) {
			// corner1 is northeast, corner0 is southwest
			side = vecscale( north, vectordot( cornerdiff, north ) );
			northwest = corner0 + side;
			southeast = corner1 - side;
		}
		else {
			// corner1 is southeast, corner0 is northwest
			northwest = corner0;
			southeast = corner1;
		}
	}

	// expand map area to fit required aspect ratio
	if ( requiredMapAspectRatio > 0 )
	{
		northportion = vectordot( northwest - southeast, north );
		westportion = vectordot( northwest - southeast, west );
		mapAspectRatio = westportion / northportion;
		if ( mapAspectRatio < requiredMapAspectRatio )
		{
			incr = requiredMapAspectRatio / mapAspectRatio;
			addvec = vecscale( west, westportion * ( incr - 1 ) * 0.5 );
		}
		else
		{
			incr = mapAspectRatio / requiredMapAspectRatio;
			addvec = vecscale( north, northportion * ( incr - 1 ) * 0.5 );
		}
		northwest += addvec;
		southeast -= addvec;
	}
	
	// This level.map_extents stuff seems to rely on northyaw being in a specific direction. It is not correct in the general case. I would not recommend using it.
	level.map_extents = [];
	level.map_extents[ "top" ] = northwest[ 1 ];
	level.map_extents[ "left" ] = southeast[ 0 ];
	level.map_extents[ "bottom" ] = southeast[ 1 ];
	level.map_extents[ "right" ] = northwest[ 0 ];
	level.map_width = level.map_extents[ "right" ] - level.map_extents[ "left" ];
	level.map_height = level.map_extents[ "top" ] - level.map_extents[ "bottom" ];

	setMiniMap( material, northwest[ 0 ], northwest[ 1 ], southeast[ 0 ], southeast[ 1 ] );
}

vecscale( vec, scalar )
{
	return( vec[ 0 ] * scalar, vec[ 1 ] * scalar, vec[ 2 ] * scalar );
}
