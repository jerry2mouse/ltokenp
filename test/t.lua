--test

require("dbg_out")
local line_feed = "\r\n"
function read_file(filename)
    local file = io.open(filename, "rb")
    if file ~= nil then
        local s = file:read("a")
        file:close()
        return s
    end
    return nil;
end
function output_buf(m)
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
        ::nnnn::  
    end

    return table.concat(ret, line_feed)
end
function conv(a,
b,c)
    local fn = [[D:\work\a\t - ¸±±¾.lua]]
    local s = read_file(fn)
    print(output_buf(s))
::nnnn::
end
local a=-5
local B =     -5.0
local B1 = {a=2,b=3,}
if a == 1 then
elseif a == nil and(a == 1) 
then -- test comment at tail
elseif a == 1 then
elseif a == 1 then
else
end
local s = 



[=[
aa

cc



dd--]=]
local t= 
{
	a = 10,
--[=[
aa

cc



   dd--]=]
}

print("ff1")
local a = 590
::nnnn::a= 5
print("zz",a)

local s = "abc//def"
if a and b then
print("zz")
end
print("ff")
local c = ~a
local a = c<<-3
a = a -3
print(string.format("%x",a))
a = 1
local c = a- - 9
print("c=",c)
print(string.format("c=%x,%d",c,a))
local a = 2^-5
print(a)
print(string.format("c=%x,%f",c,a))

--conv()

