// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("body_seal_udt_smg");
	codescripts\character::attachHead( "alias_seal_udt_heads", xmodelalias\alias_seal_udt_heads::main() );
	self.voice = "seal";
}

precache()
{
	precacheModel("body_seal_udt_smg");
	codescripts\character::precacheModelArray(xmodelalias\alias_seal_udt_heads::main());
}