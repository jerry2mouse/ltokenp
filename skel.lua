-- token filter: sample skeleton

local function BEGIN(file)
	print("BEGIN",file:sub(2))
end

local function END(line)
	print("END",line)
end

local function DO(line,token,text,value)
	print("DO",line,token,text,value)
end

function FILTER(line,token,text,value)
	local t=text
	if t=="<file>" then
		BEGIN(value)
	elseif t=="<eof>" then
		END(line)
	else
		DO(line,token,text,value)
	end
end
