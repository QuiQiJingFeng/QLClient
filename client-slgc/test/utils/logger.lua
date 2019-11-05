----------------------------
-- 日志输出模块, 为了方便使用, 封装日志管理器
-- 每一位代码一个level的开关，灵活改变，看想看的log
----------------------------

local tlog = {}

-- 每一位代表一个等级
local _level = 0

local DebugLevel = {
	ERROR = 0,
	WARN = 1,
	INFO = 2,
	DEBUG = 3,
}

local function _print(level, format, ...)
    local levelStr = ""
    if level == DebugLevel.DEBUG then
        levelStr = "Debug"
    elseif level == DebugLevel.INFO then
        levelStr = "Info"
    elseif level == DebugLevel.WARN then
        levelStr = "Warn"
    elseif level == DebugLevel.ERROR then
        levelStr = "Error"
	end
	
	local args = {...}
	format = #args == 0 and format or string.format(format, ...)

    local s, ms = math.modf(tutils.now() / 1);
    local _msg = string.format("[LUA UNIT TEST]==[%s.%03d-%d-%s] %s", os.date("%X", tutils.now()),
        math.modf(ms * 1000 / 1), cc.Director:getInstance():getTotalFrames(), levelStr, format)
    print(_msg);
end

function tlog.debug(format, ...)
	local l = bit.lshift(1, DebugLevel.DEBUG)
	if bit.band(_level, l) == 0 then
		return
	end
	_print(DebugLevel.DEBUG, format, ...);
end

function tlog.info(format, ...)
	local l = bit.lshift(1, DebugLevel.INFO)
	if bit.band(_level, l) == 0 then
		return
	end
	_print(DebugLevel.INFO, format, ...);
end

function tlog.warn(format, ...)
	local l = bit.lshift(1, DebugLevel.WARN)
	if bit.band(_level, l) == 0 then
		return
	end
	_print(DebugLevel.WARN, format, ...);
end

function tlog.error(format, ...)
	local l = bit.lshift(1, DebugLevel.ERROR)
	if bit.band(_level, l) == 0 then
		return
	end
	_print(DebugLevel.ERROR, format, ...);
end

--[[
	@desc: 设置日志等级，按位来设置 
	1 1 1 1
	^ ^ ^ ^
	| | | |
	| | | +-- error 是否打开
	| | +-- warn 是否打开
	| +-- info 是否打开
	+-- debug 是否打开
    author:{author}
    time:2018-04-25 20:37:09
    --@level: 具体如下 15：全开 0：全关
    return
]]
function tlog.setLevel( level )
	_level = level
end

_G.tlog = tlog

return tlog