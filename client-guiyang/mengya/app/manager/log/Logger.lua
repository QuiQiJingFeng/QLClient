----------------------------
-- 日志输出模块, 为了方便使用, 封装日志管理器
----------------------------
local Logger = {}

local LEVEL = {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
}
local LEVELNAME = {
	"ERROR",
	"WARN",
	"INFO",
	"DEBUG",
}

local _logLevel = LEVEL.DEBUG

local function _print(level,...)
    local levelStr = LEVELNAME[level]
    local strArgs = table.concat({...}," ")
    local dateStr = app.Util:getFormatDate()
    local totalFrames = app.Util:getTotalFramesSinceStart()

    local content = string.format("[%s][%s][%d] %s",levelStr,dateStr,totalFrames,strArgs)
    release_print(content)
end

function Logger:setLevel(level)
    _logLevel = level
end

function Logger:debug(...)
	if _logLevel < LEVEL.DEBUG then
		return
	end

	_print(LEVEL.DEBUG, ...)
end

function Logger:warn(...)
	if _logLevel < LEVEL.WARN then
		return
	end

	_print(LEVEL.WARN, ...)
end

function Logger:info(...)
	if _logLevel < LEVEL.INFO then
		return
	end

	_print(LEVEL.INFO, ...)
end

function Logger:error(...)
	if _logLevel < LEVEL.ERROR then
		return
	end

	_print(LEVEL.ERROR, ...)	
end

function Logger:dump(dumpTab, tips, level)
	if _logLevel < LEVEL.INFO then
		return
    end
    local strs = {}
    local originPrint = print
    print = function(...)
        table.insert(strs,table.concat({...},""))
    end
    dump(dumpTab, tips, level)
    print = originPrint
    local content = table.concat( strs, "" )
    _print(LEVEL.INFO, content)
end

--TODO
function Logger:reportStackTrace()

end

function Logger:assert(condition, ...)
	if DEBUG > 0 then
		assert(condition, ...)
	else
		if not condition then
			local content = table.concat({...},"")
            self:error(debug.traceback())
            self:error("Asset failed:%s", content)				
            self:reportStackTrace("Asset failed:%s", content)		
		end
	end
end
