#!/bin/lua


local root = string.gsub(arg[0], 'asm.lua$', '')
local asm = require(root .. 'init')

local argv = {...}
local opts = {}
local free = {}

local optname = nil
for _, arg in ipairs(argv) do
    if string.sub(arg, 1, 2) == '--' then
        if optname then
            opts[optname] = true
        end
        optname = string.sub(arg, 3)
    elseif string.sub(arg, 1, 1) == '-' then
        if optname then
            opts[optname] = true
        end
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

if optname then
    opts[optname] = true
end

local printf = function(...)
    print(string.format(...))
end

local usage = function()
    print('Usage: asm.lua [options] FILE\n\n' ..
          'Options:\n' ..
          ' -o --out FILE   Output to FILE\n' ..
          ' -n --nostd      No std library, std ports and standard mmap\n' ..
          ' -r --run        Run the output instead of writing go FILE\n' ..
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

local nostd = opts.n or opts.nostd

local code
local status, result = pcall(asm.compile, io.lines(input), verbose, not nostd)
if status then
    code = result
else
    print(result)
    os.exit(1)
end

local run = opts.r or opts.run
if run then
    local f = loadstring(code)
    local status, result = pcall(f)
    if not status then
        printf('a runtime error occured in %s:\n%s', input, result)
        os.exit(1)
    end
else
    local outfile = io.open(output, 'w+')
    outfile:write(code)
    
    io.close(outfile)
end

if verbose and verbose then
    printf('compiled %s', input)
    if not run then
        printf('written %d characters to %s', string.len(code), output)
    end
end
