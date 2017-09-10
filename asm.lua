#!/bin/lua

local asm = require('init')

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
            optname = nil
        end
    elseif optname then
        opts[optname] = arg
        optname = nil
    else
        free[#free+1] = arg
    end
end

local printf = function(...)
    print(string.format(...))
end

local usage = function()
    print('Usage: asm.lua [options] FILE\n\n' ..
          'Options:\n' ..
          ' -o --out FILE   Output to FILE\n' ..
          ' -h --help       Show this message and quit')
    os.exit(1)
end

if opts.h or opts.help then
    usage()
end

local verbose = opts.v or opts.verbose or false
local vlevel = tonumber(verbose) or 1
if verbose then
    if vlevel >= 2 then
        printf('verbose level: %d', vlevel)
    end
    verbose = vlevel
end

local input = free[1]
if not input then
    print('error: no input file')
    usage()
end

if verbose and verbose >= 2 then
    printf('input: %s', input)
end

local output = opts.o or opts.out or 'a.lua'
if verbose and verbose >= 2 then
    printf('output: %s', output)
end

local code
local status, result = pcall(asm.compile, io.lines(input), verbose)
if status then
    code = result
else
    print(result)
    os.exit(1)
end

local outfile = io.open(output, 'w+')
outfile:write(code)

io.close(outfile)

if verbose and verbose then
    printf('compiled %s', input)
    printf('written %d characters to %s', string.len(code), output)
end
