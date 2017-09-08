
boilerplate = [[
_R={a=0,b=0,c=0,d=0,ss='\0',ds='\0',f={gt=false,lt=false,ge=false,le=false,eq=false,ne=false,err=false,syserr=false},_R.sp=1}
_X={}
_D={}
]]

-- section .NAME => {type = 'section', name = 'NAME'}
-- NAME: => {type = 'label', name = 'NAME'}
-- OP DST, SRC => {type = 'op', name = 'OP', dst = 'DST', src = 'SRC'}
-- end => {type = 'end'}
-- if COND then => {type = 'if', cond = 'COND'}
-- while COND do => {type = 'while', cond = 'COND'}
-- do => {type = 'do'}
-- until COND => {type = 'while', cond = 'COND'}
-- loop => {type = 'loop'}
function genast(src)
    -- TODO match string match
    return {}
end

function expr_to_lua(expr)
    return "\n"
end

function ast_to_lua(ast)
    local dst = ''
    for _, v in ipairs(ast) do
        dst = dst .. expr_to_lua(v)
    end
    return dst
end

function compile(src)
    local dst = boilerplate
    local ast = genast(src)
    dst = dst .. ast_to_lua(ast)
    return dst
end
