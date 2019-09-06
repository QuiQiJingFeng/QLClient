
local ns = namespace("kod.util")

ns.String = {}

-- 字符串保存到table
function ns.String.stringToTable(s)
	local tb = {}
	
	--[[    UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字)
    ]]
	for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(tb, utfChar)
	end
	
	return tb
end

-- 获取字符串长度,英文字符为一个单位长, 中文字符为2个单位长
function ns.String.getUTFLen(s)
	local sTable = ns.String.stringToTable(s)
	local len = 0
	local charLen = 0
	
	for i = 1, #sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then -- 长度大于1的就认为是中文
			charLen = 2
		else
			charLen = 1
		end
		
		len = len + charLen
	end
	
	return len
end

-- 获取指定个数字符串长度
function ns.String.getUTFLenWithCount(s, count)
	local sTable = ns.String.stringToTable(s)
	local len = 0
	local charLen = 0
	local isLimited =(count >= 0)
	
	for i = 1, #sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then -- 长度大于1的就认为是中文
			charLen = 2
		else
			charLen = 1
		end
		-- 当超过截取的字符时舍去这个字符
		if isLimited then
			count = count - charLen
			if count < 0 then
				break
			end
		end
		
		len = len + utfCharLen
	end
	
	return len
end

-- 获取指定长度字符串, 超过最大长度则截断
function ns.String.getMaxLenString(s, maxLen)
	local len = ns.String.getUTFLen(s)
	local dstString = s
	if len > maxLen then
		dstString = string.sub(s, 1, ns.String.getUTFLenWithCount(s, maxLen))
	end
	
	return dstString
end

-- lua base64简单处理
-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2
-- character table string
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function ns.String.base64(data)
	return((data:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, - 1 do r = r ..(b % 2 ^ i - b % 2 ^(i - 1) > 0 and '1' or '0') end
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if(#x < 6) then return '' end
		local c = 0
		for i = 1, 6 do c = c +(x:sub(i, i) == '1' and 2 ^(6 - i) or 0) end
		return b:sub(c + 1, c + 1)
	end) ..({'', '==', '='}) [#data % 3 + 1])
end

-- decoding
function ns.String.unbase64(data)
	data = string.gsub(data, '[^' .. b .. '=]', '')
	return(data:gsub('.', function(x)
		if(x == '=') then return '' end
		local r, f = '',(b:find(x) - 1)
		for i = 6, 1, - 1 do r = r ..(f % 2 ^ i - f % 2 ^(i - 1) > 0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if(#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do c = c +(x:sub(i, i) == '1' and 2 ^(8 - i) or 0) end
		return string.char(c)
	end))
end

-- 用来处理HTTP请求的时候还有中文或者符号的处理
-- 现在因为网页处理方面有问题，没有使用，直接取消传名字
-- URL ENCODE
-- URL中的特殊字符，转义
function ns.String.encodeURI(str)
	if(str) then
		str = string.gsub(str, "\n", "\r\n")
		str = string.gsub(str, "([^%w ])",
		function(c) return string.format("%%%02X", string.byte(c)) end
		)
		str = string.gsub(str, " ", "+")
	end
	return str
end

-- URL DECODE
-- URL中的特殊字符，反转义
function ns.String.decodeURI(s)
	if(s) then
		s = string.gsub(s, '%%(%x%x)',
		function(hex) return string.char(tonumber(hex, 16)) end
		)
	end
	return s
end

-- 格式化显示货币,数量过大时保留N位小数
-- decimalCount 小数位数
-- 最小显示到的单位(请填写"万"或者"亿")
function ns.String.formatMoney(money, decimalCount, unit)
	--不是数字类型则不转换
	if type(money) ~= 'number' then
		return money
	end
	if money < 10000 then
		return money
	elseif money < 100000000 or unit == "万" then
		local first = 10000 /(10 ^ decimalCount)
		local temp = math.floor(money / first)
		return(temp /(10 ^ decimalCount)) .. "万"
	else
		local first = 100000000 /(10 ^ decimalCount)
		local temp = math.floor(money / first)
		return(temp /(10 ^ decimalCount)) .. "亿"
	end
end 