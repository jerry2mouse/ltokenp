-- format lua code
local line_feed = "\n"
local keep_line_count = 2    -- 保留空白行个数

local prt_buf =
{
    ["<name>"] = 1,
    ["<string>"] = 1,
    ["<p>"] = 1,
    ["<spaces>"] = 1,
    ["<lcomment>"] = 1,
    ["<scomment>"] = 1,
}

local function read_file(filename)
    local content = ""
    file = io.open(filename, "rb")
    if file ~= nil then
        content = file:read("*a")
        file:close()
    end
    return content;
end

local function output_buf(m)
    if m == nil then
        return ""
    end
    local ret = {}
    local tt = {}
    local line_count = 1
    local msg = ""
    for i = 1, #m do
        msg = string.format("%02X", string.byte(m, i))
        tt[#tt + 1] = msg
        if i % 16 == 0 then
            msg = string.format("%3d - %3d\t", line_count, line_count + 15)
            msg = msg .. table.concat(tt, " ")
            --print(msg)
            ret[#ret + 1] = msg
            tt = {}
            line_count = line_count + 16
        end
    end

    if #tt > 0 then
        msg = string.format("%3d - %3d\t", line_count, #m)
        msg = msg .. table.concat(tt, " ")
        --print(msg)
        ret[#ret + 1] = msg
    end

    return table.concat(ret, line_feed)
end

local CLASH = {}

local function setclash(a, b)
    if CLASH[a] == nil then CLASH[a] = {}end
    CLASH[a][b] = true
end

local function clash(a, b)
    return CLASH[a] ~= nil and CLASH[a][b] ~= nil
end
local function init_clash()
    -- <integer> 按<number> 处理
    setclash('not', '(')
    setclash('do', '(')
    setclash('else', '(')
    setclash('elseif', '(')
    setclash('for', '(')
    setclash('if', '(')
    setclash('return', '(')
    setclash('until', '(')
    setclash('while', '(')
    --setclash('function', '(') -- function(a,b),function后不加空格

    setclash('<name>', '#')
    setclash('<name>', '<name>')
    setclash('<name>', '<number>')
    setclash('<name>', '<string>')
    setclash('<name>', '..')
    setclash('<name>', '}')
    --setclash('<name>', '(')  -- string.format("%s"),format is <name>，函数调用后不加空格
    setclash('<name>', '+')
    setclash('<name>', '-')
    setclash('<number>', '..')
    setclash('<number>', '...')
    setclash('<number>', '<name>')
    setclash('<number>', '<number>')
    setclash('<number>', '+')
    setclash('<number>', '-')
    setclash('<number>', '}')
    setclash('<string>', '<string>')
    setclash('<string>', '<name>')
    setclash('<string>', '..')
    setclash('<string>', '}')
    setclash('return', '<string>')
    setclash('return', '{')
    setclash(')', '<name>')
    setclash(')', '..')
    setclash(')', '+')
    setclash(')', '-')
    setclash(']', '+')
    setclash(']', '-')
    setclash(']', '}')
    setclash(']', '<name>')
    setclash(']', '..')
    setclash('{', '#')
    setclash('{', '[')
    setclash('{', '+')
    setclash('{', '-')
    setclash('{', '{')
    setclash('{', '<name>')
    setclash('{', '<string>')
    setclash('{', '<number>')
    setclash('{', '[')
    setclash('}', ')')
    setclash('}', '}')
end


-- 以下操作符的前后都要加空格
local blank_2 = {
    ["+"] = 1,
    --["-"] = 1, -- 特殊处理
    ["*"] = 1,
    ["/"] = 1,
    ["//"] = 1,
    ["^"] = 1,
    ["%"] = 1,
    ["&"] = 1,
    --["~"] = 1,  -- 取反，右结合，最高优先级 a=~1 --> a = ~1
    ["|"] = 1,
    [">>"] = 1,
    ["<<"] = 1,
    [".."] = 1,
    ["<"] = 1,
    ["<="] = 1,
    [">"] = 1,
    [">="] = 1,
    ["=="] = 1,
    ["~="] = 1,

    ["="] = 1,
    ["or"] = 1,
    ["and"] = 1,

}

-- 以下操作符后面的减号和数值，应该是组合为一个负数
-- 如: a >= - 5  --> a >= -5
local op_minus = {
    ["+"] = 1,
    ["-"] = 1,
    ["*"] = 1,
    ["/"] = 1,
    ["//"] = 1,
    ["^"] = 1,
    ["%"] = 1,
    ["&"] = 1,
    ["~"] = 1,
    ["|"] = 1,
    [">>"] = 1,
    ["<<"] = 1,
    [".."] = 1,
    ["<"] = 1,
    ["<="] = 1,
    [">"] = 1,
    [">="] = 1,
    ["=="] = 1,
    ["~="] = 1,
    ["="] = 1,
    [","] = 1,
    [";"] = 1,
    ["and"] = 1,
    ["or"] = 1,
}
local tk_before_left_brackets = {
    ["and"] = 1,
    ["do"] = 1,
    ["else"] = 1,
    ["elseif"] = 1,
    ["for"] = 1,
    ["if"] = 1,
    ["not"] = 1,
    ["or"] = 1,
    ["return"] = 1,
    ["true"] = 1,
    ["until"] = 1,
    ["while"] = 1,
}

function save_new_file(filename, s)
    local f = io.open(filename, "w+b")
    if f ~= nil then
        f:write(s)
        f:close()
    end
end


local all_token = {}

function get_string_linefeed_count(s)
    local n = #s
    if n <= 0 then
        return 0
    elseif n == 1 then
        local a = string.byte(s, 1)
        if a == 0x0d or a == 0x0a then
            return 1
        end
    else
        local i = 1
        local lines = 0
        while i < n do
            local a = string.byte(s, i)
            local b = string.byte(s, i + 1)
            local x1 = false
            local x2 = false
            if a == 0x0d or a == 0x0a then
                x1 = true
            end
            if b == 0x0d or b == 0x0a then
                x2 = true
            end

            if x1 == true and x2 == true then
                lines = lines + 1
                i = i + 2
            elseif x1 == true then
                lines = lines + 1
                i = i + 1
            elseif x2 == true then
                i = i + 1
            else
                i = i + 2
            end
        end

        return lines
    end
    return 0
end

local tk_list =
{
    "and", "break", "do", "else", "elseif",
    "end", "false", "for", "function", "goto", "if",
    "in", "local", "nil", "not", "or", "repeat",
    "return", "then", "true", "until", "while",
    "//", "..", "...", "==", ">=", "<=", "~=",
    "<<", ">>", "::", "<eof>",
    "<number>", "<integer>", "<name>", "<string>",
    "<p>", "<spaces>", "<lcomment>", "<scomment>",
}

function fmt_calc_allline_indent()
    local ins_stack = {}
    for i = 1, #all_token do
        -- line -- 整数
        -- text -- in tk_list
        -- line, token, text, value, ct
        local x = all_token[i]
        x.incount = #ins_stack
        local text = x.text
        if text == "<lcomment>" or text == "<scomment>" then
            goto continue
        end
        if text == "<p>" or text == "<spaces>" then
            goto continue
        end
        if text:match("^%l") or text == "{" or text == "}" then
            -- check indent
        else
            goto continue
        end

        x.incount = #ins_stack
        if text == "if" or text == "while" or text == "do" or text == "function" or text == "for" then
            if #ins_stack > 0 and text == "do" then
                if ins_stack[#ins_stack] == "while" then    -- while xxx do block end
                elseif ins_stack[#ins_stack] == "for" then    -- for xxx do block end
                else
                    -- do block end
                    table.insert(ins_stack, text)
                end
            else
                table.insert(ins_stack, text)
            end
        elseif text == "end" then
            table.remove(ins_stack)
        elseif text == "repeat" then
            table.insert(ins_stack, text)
        elseif text == "until" then
            table.remove(ins_stack)
        elseif text == "{" then
            table.insert(ins_stack, text)
        elseif text == "}" then
            table.remove(ins_stack)
        end

        if text == "else" then
            x.incount = x.incount - 1
        elseif text == "elseif" then
            x.incount = x.incount - 1
        elseif text == "}" then
            x.incount = x.incount - 1
        elseif text == "until" then
            x.incount = x.incount - 1
        elseif text == "end" then
            x.incount = x.incount - 1
        end
        ::continue::
    end
end
function fmt_calc_indent(t1)
    if t1 == nil then
        return ""
    end
    local s = ""
    for i = 1, t1.incount * 4 do
        s = s .. " "
    end
    return s
end

function fmt_emit_val(t1)
    if t1 == nil then
        return ""
    end

    if t1.text == "<string>" or t1.text == "<lcomment>" or t1.text == "<scomment>" then
        return t1.ct
    else
        return t1.value
    end
end
function fmt_emit_linefeed(t0, t1)
    if t0 == nil then
        return ""
    end
    if t1 == nil then
        return ""
    end
    if t0.line == t1.line then
        return ""
    end

    -- 以下是：t0.line ~= t1.line的情况
    -- "<string>"需要特殊处理
    local ret = {}
    local n = 0
    if t1.text == "<string>" or t1.text == "<scomment>" or t1.text == "<lcomment>" then
        local a = t1.line - get_string_linefeed_count(t1.ct)    -- 字符串开始的行号
        for i = t0.line, a - 1 do
            table.insert(ret, line_feed)
            n = n + 1
            if n > keep_line_count then
                break
            end
        end
    else
        for i = t0.line, t1.line - 1 do
            table.insert(ret, line_feed)
            n = n + 1
            if n > keep_line_count then
                break
            end
        end
    end
    if #ret > 0 then
        return table.concat(ret, "")
    end
    return ""
end

-- a 是已经输出的token
-- b 是下一个将要输出的token
function fmt_emit_space(a1, a0, a, b)
    if a == nil then
        return ""
    end
    if b == nil then
        return ""
    end
    local atext = a.text
    local btext = b.text
    if btext == "<scomment>" or btext == "<lcomment>" then
        return ""
    end

    if btext == "(" and tk_before_left_brackets[atext] == 1 then
        return " "
    end

    if btext:match("^%l") then
        -- string is keyword
        btext = "<name>"
    end
    if clash(atext, btext) then
        return " "
    end
    if atext:match("^%l") then
        -- string is keyword
        atext = "<name>"
    end

    if clash(atext, btext) then
        return " "
    end
    if atext == "-" then
        if btext == "<number>" then
            -- ab,构成一个负号后面跟一个数值，可以是一个负数，也可能是一个减操作
            -- 如果ab是负数，则ab之间不加空格，否则加空格
            -- x = a-2 这是减操作,x = a+-2，这是负号  --> x = a - 2 这是减操作,x = a + -2，这是负号
            -- 是否需要在负号和数值之间输出一个空格，由负号之前的token决定,如果负号之前的token是操作，则需要符号之前加入空格
            if a0 ~= nil and op_minus[a0.text] ~= 1 then
                return " "
            end
        else
            return " "
        end
    elseif atext == "," then
        -- 前一个token是逗号，如 f(x,y)
        return " "
    elseif atext == "::" and (a0 ~= nil and a0.text == "<name>") and (a1 ~= nil and a1.text == "::") then
        -- ::xx:: yy = 5, label结束，后面如果有token，则加一个空格
        return " "
    end

    -- 将要输出的是一个操作符 
    -- x>y,a是x，b是>
    -- x > y
    if blank_2[btext] ~= nil then
        return " "
    end
    -- 前一个token是一个操作符
    -- x>y,a是>，b是y
    -- x > y
    if blank_2[atext] ~= nil then
        return " "
    end

    return ""
end

function format_code()
    local ret = {}
    local token3
    local token2
    local token1
    local token0
    local line_break = {}
    fmt_calc_allline_indent()
    for i = 1, #all_token do
        -- line -- integer
        -- text -- in tk_list
        -- line, token, text, value, ct
        local x = all_token[i]
        local text = x.text

        if text == "<spaces>" then
            goto continue
        end
        if text == "<p>" then
            line_feed = x.value
            table.insert(line_break, line_feed)
            goto continue
        end

        -- 
        line_break = {}
        token3 = token2
        token2 = token1
        token1 = token0
        token0 = x
        local ll = fmt_emit_linefeed(token1, token0)
        if ll == "" then
            if text == "<lcomment>" or text == "<scomment>" then
                if #ret > 0 then
                    table.insert(ret, "    ")
                end
            end
            local a = fmt_emit_space(token3, token2, token1, token0)
            if a ~= "" then
                table.insert(ret, a)
            end
        else
            table.insert(ret, ll)
            local a = fmt_calc_indent(token0)
            if a ~= "" then
                table.insert(ret, a)
            end
        end
        local a = fmt_emit_val(token0)
        if a ~= "" then
            table.insert(ret, a)
        end

        ::continue::
    end

    -- 保留文件末尾的空行
    -- 至少要保留一个空行，因为在格式化选择的代码时，后面可能会有一个空行，这个空行不能删除
    if keep_line_count == 0 then
        for i = 1, #line_break do
            table.insert(ret, line_break[i])
            break
        end
    else
        for i = 1, #line_break do
            table.insert(ret, line_break[i])
            if i > keep_line_count then
                break
            end
        end
    end


    local s = table.concat(ret)
    return s
end

-- 选项：如果是重新格式化reformat，美化文档，需自动添加换行
-- 如果是一般的格式化，只是修改缩进和空格,只删除多余的空白行，不增加新空白行

-- ct 字符串的原始格式
-- 输出字符串时，使用原始格式，不使用value，value是经过转义的
function FILTER_COMMENT(line, token, text, value, ct)
    if prt_buf[text] == 1 then
        --print(string.format("FILTERCMT\tline:%3d\t%s\t'%s'\t%s", line, text, value, output_buf(ct)))
    else
        --print(string.format("FILTERCMT\tline:%3d\t%s\t'%s'", line, text, value))
    end
    table.insert(all_token, { line = line, token = token, text = text, value = value, ct = ct } )
end

function FILTER(line, token, text, value, ct)
    if prt_buf[text] == 1 then
        --print(string.format("FILTER-->\tline:%3d\t%s\t'%s'\t%s", line, text, value, output_buf(ct)))
    else
        --print(string.format("FILTER-->\tline:%3d\t%s\t'%s'", line, text, value))
    end

    if text == "<file>" then
        all_token = {}
    elseif text == "<eof>" then
        init_clash()
        local s = format_code()
        --save_new_file("t_fmtok.lua", s)
        io.write(s)
    else
        if text == "<integer>" then
            text = "<number>"
        end
        table.insert(all_token, { line = line, token = token, text = text, value = value, ct = ct } )
    end
end

