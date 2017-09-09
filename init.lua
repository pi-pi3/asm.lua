
local boilerplate = [[
_R={a=0,b=0,c=0,d=0,ss='\0',ds='\0',f={gt=false,lt=false,ge=false,le=false,eq=false,ne=false,err=false,syserr=false},sp=1}
_X={}
_D={}]]

local ex = {
    {type = 'do', pattern = 'do', out = {}},
    {type = 'end', pattern = 'end', out = {}},
    {type = 'loop', pattern = 'loop', out = {}},
    {type = 'label', pattern = '(%a+)%s*:', out = {'name'}},
    {type = 'section', pattern = 'section %.(%a+)', out = {'name'}},
    {type = 'if', pattern = 'if (%a+) then', out = {'cond'}}, -- TODO: cond validation
    {type = 'while', pattern = 'while (%a+) do', out = {'cond'}},
    {type = 'until', pattern = 'until (%a+)', out = {'cond'}},
    {type = 'op', pattern = '(%a+) ([%a%d%[%]_%-]+), ([%a%d%[%]_%-]+)', out = {'op', 'a', 'b'}},
    {type = 'op', pattern = '(%a+) ([%a%d%[%]_%-]+)', out = {'op', 'a'}},
    {type = 'op', pattern = '(%a+)', out = {'op'}},
    {type = 'extern', pattern = 'extern ([%a%d_]+)', out = {'name'}},
    {type = 'def', pattern = 'def ([%a%d_]+) (".*")', out = {'name', 'val'}}, -- TODO: string validation
    {type = 'def', pattern = 'def ([%a%d_]+) (0?[xb]?[%da-fA-F]?%.?[%da-fA-F]+)', out = {'name', 'val'}}
}

for _, v in pairs(ex) do
    local b = '^%s*' -- begin
    local e = '%s*$' -- end
    local s = '%s+'  -- space one or more
    v.pattern = b .. string.gsub(v.pattern, ' ', '%%s+') .. e
end

local match = function(expr, ex, result, verbose, line)
    local out = {string.match(expr, ex.pattern)}
    if #out == 0 then
        return false
    end

    result.type = ex.type

    for i = 1, #ex.out do
        local name = ex.out[i]
        result[name] = out[i]
    end

    if verbose then
        result.linen = line
        result.text = expr
    end

    return true
end

local genast = function(src, verbose)
    local line = 1
    local ast = {}
    local iter
    if type(src) == 'string' then
        iter = string.gmatch(src, '.')
    elseif type(src) == 'function' then
        iter = src
    end

    for expr in iter do
        expr = string.gsub(expr, '%s*%-%-.*$', '')
        -- TODO check for invalid characters 
        if not string.match(expr, '^%s*$') then
            local found = false
            for _, v in ipairs(ex) do
                local result = {}
                if match(expr, v, result, verbose, line) then
                    ast[#ast+1] = result
                    found = true
                    break
                end
            end
            if not found then
                error(string.format('invalid expression: %s\n' ..
                                    '           at line: %d', expr, line))
            end
        end
        line = line + 1
    end

    return ast
end

comp = {}
comp['do'] = {pattern = 'do', arg = {}}
comp['end'] = {pattern = 'end', arg = {}}
comp['loop'] = {pattern = '_R.c=_R.c+1;while _R.c>1 do _R.c=_R.c-1', arg = {}}
comp['label'] = {pattern = 'function %s()', arg = {'name'}}
comp['if'] = {pattern = 'if _R.f.%s then', arg = {'cond'}}
comp['while'] = {pattern = 'while _R.f.%s do', arg = {'cond'}}
comp['until'] = {pattern = 'until _R.f.%s', arg = {'cond'}}
comp['extern'] = {pattern = '_X["%s"] = %s', arg = {'name'}}

local section = 'text'
local expr_to_lua = function(expr, verbose)
    local type = expr.type

    if type == 'section' then
        section = expr.name
        return ''
    elseif type == 'op' then -- TODO
        return '\n'
    elseif type == 'def' then -- TODO
        return '\n'
    else
        local args = {}
        for _, v in pairs(comp[type].arg) do
            args[#args+1] = expr[v]
        end

        local lua = string.format(comp[type].pattern, table.unpack(args))
        if verbose and verbose >= 2 then
            lua = string.format(' -- line %d\n -- %s\n%s\n', expr.linen, expr.text, lua)
        elseif verbose then
            lua = string.format('%s -- %s', lua, expr.text)
        end
        return lua
    end
end

local ast_to_lua = function(ast, verbose)
    local dst = ''
    for _, v in ipairs(ast) do
        dst = dst .. expr_to_lua(v, verbose) .. '\n'
    end
    return dst
end

local compile = function(src, verbose)
    local dst = boilerplate

    local ast
    local status, result = pcall(genast, src, verbose)
    if status then
        ast = result
    else
        print(result)
        os.exit(1)
    end

    dst = dst .. ast_to_lua(ast, verbose)
    return dst
end

return {compile = compile}
