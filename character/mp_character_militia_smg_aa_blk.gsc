// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("mp_body_militia_smg_aa_blk");
	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );
	self setViewmodel("viewhands_militia");
	self.voice = "portuguese";
}

precache()
{
	precacheModel("mp_body_militia_smg_aa_blk");
	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());
	precacheModel("viewhands_militia");
}
