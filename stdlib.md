
# asm.lua standard library

## Prelude
`include` includes a Lua file located in the path specified by `ss`. Equivalent
to `require(_R.ss)`

`putc` writes a single character from `ss` without a newline to stdout.

`puts` writes a string from `ss` with a newline at the end to stdout.

`endl` writes a newline feed to stdout.

`sprintf` writes a formatted string to `ds`.

`printf` writes a formatted string to stdout.

`itoa` converts a number into a string.

`atoi` converts a string into a number.

`memset` sets `c` cells in memory, starting from `b` to `a`.

`memcpy` copies `c` cells from `a` to `b`.

`memcmp` compares `c` cells at `a` and `b`.

## Math
`abs`
`mod`
`floor`
`round`
`ceil`
`min`
`max`

`sqrt`
`pow`
`exp`
`log`
`log10`

`deg`
`rad`
`sin`
`cos`
`tan`
`asin`
`acos`
`atan`
`atan2`

## String library
`strlen`
`strsub`
`strrep`
`strup`
`strlow`
`strfind`
`strmatch`

`ord`
`chr`

## OS calls

`system`
`exit`
`env`
`time`
