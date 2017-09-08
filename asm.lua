#!/bin/lua

local asm = require('init.lua')

local argv = {...}
local opts = {}
local free = {}

local optname = nil
for _, arg in ipairs(argv) do
    if string.sub(arg, 1, 2) == '--' then
        optname = string.sub(arg, 3)
    elseif string.sub(arg, 1, 1) == '-' then
        optname = string.sub(arg, 2, 2)
        local val = string.sub(arg, 3)
        if string.len(val) > 0 then
            opts[optname] = val
        end
    elseif optname then
        opts[optname] = arg
    else
        free[#free+1] = arg
    end
end

function usage()
    print('Usage: asm.lua [options] FILE\n\n' ..
          'Options:\n' ..
          ' -o --out FILE   Output to FILE\n' ..
          ' -h --help       Show this message and quit')
    os.exit(1)
end

if opts.h or opts.help then
    usage()
end

local input = free[1]
if not input then
    print('error: no input file')
    usage()
end

local output = opts.o or opts.out or 'a.lua'

input = io.open(input, 'r')
output = io.open(output, 'w+')

code = asm(io.lines(input))
io.write(outpute, code)

io.close(input)
io.close(output)
