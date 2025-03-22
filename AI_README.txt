This repo is not run in Lua. Rather, it is run in a Steam game called Simulo as Luau.
That means there are a lot of API calls that have no references.
It also means that running the code with lua is impossible, outside of highly abstract libraries.
So don't do that.
Thanks.

Keep in mind:
There is no Console.log, but there was in previous versions of the game, so it might be lurking in the code in places. Replace it with print().

