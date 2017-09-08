
local boilerplate = [[
_R={a=0,b=0,c=0,d=0,ss='\0',ds='\0',f={gt=false,lt=false,ge=false,le=false,eq=false,ne=false,err=false,syserr=false},_R.sp=1}
_X={}
_D={}
]]

local ex = {}
-- TODO: improve readability
ex.doloop = {pattern = 'do', type = 'do', out = {}}
ex.endb = {pattern = 'end', type = 'end', out = {}}
ex.loop = {pattern = 'loop', type = 'loop', out = {}}
ex.label = {pattern = '(%a+)%s*:', type = 'label', out = {'name'}}
ex.section = {pattern = 'section .(%a+)', type = 'section', out = {'name'}}
ex.ifthen = {pattern = 'if (%a+) then', type = 'if', out = {'cond'}} -- TODO: cond validation
ex.whiledo = {pattern = 'while (%a+) do', type = 'while', out = {'cond'}}
ex.untilloop = {pattern = 'until (%a+)', type = 'until', out = {'cond'}}
ex.op2 = {pattern = '(%a+) ([%a%d%[%]]+), ([%a%d%[%]]+)', type = 'op', out = {'op', 'a', 'b'}}
ex.op1 = {pattern = '(%a+) ([%a%d%[%]]+)', type = 'op', out = {'op', 'a'}}
ex.op0 = {pattern = '(%a+)', type = 'op', out = {'op'}}
ex.extern = {pattern = 'extern ([%a%d_]+)', type = 'extern', out = {'name'}}
ex.defstr = {pattern = 'def ([%a%d_]+) (".*")', type = 'def', out = {'name', 'val'}} -- TODO: string validation
ex.defnum = {pattern = 'def ([%a%d_]+) (0?[xb]?[%da-fA-F]?%.?[%da-fA-F]+)', type = 'def', out = {'name', 'val'}}

for _, v in pairs(ex) do
    local b = '^%s*' -- begin
    local e = '%s*$' -- end
    local s = '%s+'  -- space one or more
    v.pattern = b .. string.gsub(v.pattern, ' ', '\\s+') .. e
end

local match = function(expr, ex, result)
    local out = {string.match(expr, ex.pattern)}
    if #out == 0 then
        return false
    end

    result.type = ex.type

    for i = 1, #out do
        local name = ex.out[i]
        result[name] = out[i]
    end

    return true
end

local genast = function(src)
    local line = 1
    local ast = {}
    local iter
    if type(src) == 'string' then
        iter = string.gmatch(src, '.')
    elseif type(src) == 'function' then
        iter = iter
    end

    for expr in iter do
        expr = string.gsub(expr, '%s*%-%-.*$', '')
        -- TODO check for invalid characters 
        if not string.match(expr, '^%s*$') then
            for _, v in pairs(ex) do
                local result = {}
                if match(expr, v, result) then
                    ast[#ast+1] = result
                else
                    error(string.format('invalid expression: %s\n' ..
                                        '           at line: %d', expr, line))
                end
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
local expr_to_lua = function(expr)
    local type = expr.type

    if type == 'section' then
        section = expr.name
        return ''
    elseif type == 'op' then -- TODO
        return ''
    elseif type == 'def' then -- TODO
        return ''
    else
        local args = {}
        for k, _ in pairs(comp[type].arg) do
            comp[type].arg[k] = expr[k]
        end

        local lua
        lua = string.format(comp[type].pattern, table.unpack(args))
        return lua
    end
end

local ast_to_lua = function(ast)
    local dst = ''
    for _, v in ipairs(ast) do
        dst = dst .. expr_to_lua(v)
    end
    return dst
end

local compile = function(src)
    local dst = boilerplate

    local ast
    local status, result = genast(src)
    if status then
        ast = result
    else
        print(result)
        os.exit(1)
    end

    dst = dst .. ast_to_lua(ast)
    return dst
end

return compile
