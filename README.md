# asm.lua

A Lua-based assembly-like language designed for learning and teaching assembly.


asm.lua based on the x86 architecture. To Lua, it's what asm.js is it to
JavaScript, except that it's not actually faster. It compiles to pure Lua and is
implemented in pure Lua.

It is currently in very early development. asm.lua is not yet guaranteed to work and
many features are subject to change.

# Examples

To compile the examples, execute `./asm.lua examples/X.lua`, where X is any of
the examples included in the examples directory. This will create a file called
`a.lua` that can be ran using the Lua interpreter, like so: `lua a.lua`.

# Short reference

## Registers

 - general purpose registers (can be used for any operation (mostly)) (only numbers allowed here)
    - **A** the accumulator
    - **B** base index 
    - **C** counter
    - **D** arithmetic
 - string registers (only strings are allowed here)
    - **SS** source string
    - **DS** destination string
 - **F** flag register
    - `f.gt` greater than
    - `f.lt` less than
    - `f.ge` greater or equal to
    - `f.le` less or equal to
    - `f.eq` equal to
    - `f.ne` not equal to
    - `f.err` general purpose error flag
    - `f.syserr` system error flag
 - **SP**  stack pointer

## Memory

Memory is divided into cells indexed by integers. Every cell holds a Lua
variable (either a string or a number).

#### 0
reserved for nil  
cannot be changed

#### 1ki .. 64ki
general purpose memory

#### 64ki .. 80ki
stack

#### 24ki video memory?
// TODO

## Syntax & semantics

#### Operations
```
<op> [dst], [src] -- comment
```

###### Reference
 - data moving
    - `mov DST, SRC` moves SRC to DST
 - functions
    - `call F` calls F
    - `callx F` calls an extern F
    - `ret` returns from function
 - stack
    - `push SRC` pushes SRC to stack
    - `pop DST` pops from stack to DST
 - testing
    - `cmp A, B` compares A and B
    - `test A` tests if A is zero
    - `not` negates last comparison
 - boolean
    - `cmpl DST` binary compliment
    - `and  DST, SRC` binary and
    - `or   DST, SRC` binary or
    - `xor  DST, SRC` binary xor
    - `nand DST, SRC` binary nand
    - `nor  DST, SRC` binary nor
    - `xnor DST, SRC` binary xnor
 - arithmetic
    - `inc DST` increments DST
    - `dec DST` decrements DST
    - `add DST, SRC` adds SRC to DST
    - `sub DST, SRC` subtracts SRC from DST
    - `mul DST, SRC` multipies DST by src
    - `div DST, SRC` divides DST by SRC

###### Note

The bitwise operators require the Lua bitops library. It is currently not
included by default, but is available by default when using LuaJIT.

#### Conditional
```
cmp <dst>, <src> OR test <dst>
if <cond> then
... code
end
```

`cond` can be `gt`, `lt`, `ge`, `le`, `eq`, `ne`, `err` or `syserr`

#### Loops
```
repeat
... code
 cmp <dst>, <src> OR test <dst>
until <cond>
```

```
cmp <dst>, <src> OR test <dst>
while <cond> do
... code
 cmp <dst>, <src> OR test <dst>
end
```

```
loop
... code
end
```

The last one loops as long as register C is not 0.

#### Functions
```
<name>:
... code
 ret
end
```

#### Lua ffi
```
extern <name>
mov <extern-dst>, <any-src>
callx <extern-func>, <n>
```
