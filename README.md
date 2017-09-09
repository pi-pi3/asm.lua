# asm.lua

A Lua-based assembly-like language designed for learning and teaching assembly.
It's based on the x86 architecture. asm.lua is to Lua what asm.js it to
JavaScript, except that it's not actually faster. It compiles to pure Lua and is
implemented in pure Lua.

It is currently in very early development. It is not yet guaranteed to work and
many features are subject to change.

# Examples

To compile the examples, execute `./asm.lua examples/X.lua`, where X is any of
the examples included in the examples directory. This will create a file called
`a.lua` that can be ran using the Lua interpreter, like so: `lua a.lua`.

# Note

The bitwise operators require the Lua bitops library. It is currently not
included by default, but is available by default when using LuaJIT.
