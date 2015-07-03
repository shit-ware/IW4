main()
{
	animated_model_setup();
}

#using_animtree( "animated_props" );
animated_model_setup()
{
	level.anim_prop_models[ "foliage_tree_palm_bushy_3" ][ "still" ] = %palmtree_bushy3_still;
	level.anim_prop_models[ "foliage_tree_palm_bushy_3" ][ "strong" ] = %palmtree_bushy3_sway;
	level.anim_prop_models[ "foliage_tree_palm_bushy_1" ][ "still" ] = %palmtree_bushy1_still;
	level.anim_prop_models[ "foliage_tree_palm_bushy_1" ][ "strong" ] = %palmtree_bushy1_sway;
}