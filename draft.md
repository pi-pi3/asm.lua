
# Registers

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

# Memory

Memory is divided into cells indexed by integers. Every cell holds a Lua
variable.

### 0
reserved for nil  
cannot be changed

### 1 .. 4ki
program's .data section

### 4ki .. 64ki
general purpose memory

### 64ki .. 80ki
stack

### 24ki video memory?

# Syntax

### operations
```
operation [dst], [src] -- comment
```

##### reference
// TODO

### conditional
```
cmp <dst>, <src> OR test <dst>
if <cond> then
... code
end
```

`cond` can be `gt`, `lt`, `ge`, `le`, `eq` or `ne`

### loops
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

### functions
```
<name>:
... code
 ret
end
```

can only be defined in the .text section

### Lua ffi
```
extern <name>
movx <extern-dst>, <any-src>
callx <extern-func>, <n>
```

# Examples
```
section .text

mov a, 1            -- set register a to 1
mov [0x4000], a     -- move the value in register a to memory at 0x4000
```

### Function
```
section .text

foo:            -- define a function called foo
 mov a, 0       -- move 1 to the a register
 ret            -- return from function
end             -- end function
```

### Print a string backwards, one character at a time
```
section .data

hello_world:
    db "Hello, world!" -- "Hello, world!" is put into the first available spot in
                       -- memory, i.e. 0x1

section .text

mov ss, [hello_world]   -- move the value of hello_world to ss
call strlen             -- set a to length of hello_world

mov c, a -- set c to a

loop
 mov ss, [hello_world]   -- move the value at hello_world to ss
 mov a, c   -- set a to c
 mov b, c   -- set b to c
 inc b      -- increment b
 call strsub    -- get the substring ranging from c to c + 1,
                -- where c is the first character of the string
                -- and c + 1 is the first character after the string
 mov ss, ds     -- move the result of the last string operation to ss
 call print     -- print the string in ss
end
call endl       -- print a newline
```

### Lua ffi
```
extern foo -- declare an extern variable called foo
extern bar -- declare an extern variable called bar

movx bar, 0 -- set extern bar to 0
push bar    -- push the value of bar to stack
push 1      -- push 1 to stack
push a      -- push the value in register a to stack
push [0x1]  -- push the value at [0x1] to stack

callx foo, 4 -- call extern foo with 4 arguments
```

# How the examples compile to Lua

### Boilerplate
```
_R = {}
_R.a = 0
_R.b = 0
_R.c = 0
_R.d = 0

_R.ss = '\0'
_R.ds = '\0'

_R.f = {
    gt = false,
    lt = false,
    ge = false,
    le = false,
    eq = false,
    ne = false,
    err = false,
    syserr = false,
}

_R.sp = 1

_X = {}
_D = {}
```

### First example
```
# mov a, 1
_R.a = 1

# mov [0x4000], a
_D[0x4000] = _R.a
```

### Function
```
# foo:
function foo()

#  mov a, 0
_R.a = 0

#  ret
return

# end
end
```

### Print a string backwards, one character at a time
```
function strlen()
    _R.a = string.len(_R.ss)
end

function strsub()
    _R.ds = string.sub(_R.ss, _R.a, _R.b - 1)
end

_print = print
function endl()
    _print(_R.ss)
end

function endl()
    _print("\n")
end

# hello_world:
#     db "Hello, world!"
_D[0x1] = "Hello, world!"

# mov ss, [hello_world]
_R.ss = _D[0x1]

# call strlen
_R.f.syserr = not select(1, pcall(strlen))
 
# mov c, a
_R.c = _R.a
 
# loop
while _R.c > 0 do

#  mov ss, [hello_world]
_R.ss = _D[0x1]

#  mov a, c
_R.a = _R.c

#  mov b, c
_R.b = _R.c

#  inc b
_R.b = _R.b + 1

#  call strsub
_R.f.syserr = not select(1, pcall(strsub))

#  mov ss, ds
_R.ss = _R.ds

#  call print
_R.f.syserr = not select(1, pcall(print))

# end
end

# call endl
_R.f.syserr = not select(1, pcall(endl))
```

### Lua ffi
```
# extern foo
_X.foo = foo

# extern bar
_X.bar = bar
 
# movx bar, 0
_X.bar = 0

# push bar
_D[_R.sp] = _X.bar; _R.sp = _R.sp + 1

# push 1
_D[_R.sp] = 1; _R.sp = _R.sp + 1

# push a
_D[_R.sp] = _R.a; _R.sp = _R.sp + 1

# push [0x1]
_D[_R.sp] = _D[0x1]; _R.sp = _R.sp + 1
 
# callx foo, 4
_Xargs = {}
for i = 1, 4 do
    _Xargs[i] = _D[_R.sp + 1]
end
_R.f.syserr = not select(1, pcall(_X.foo, unpack(_Xargs)))
_Xargs = nil
```
