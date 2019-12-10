----------------------------
-- 日志输出模块, 为了方便使用, 封装日志管理器
----------------------------
cc.exports.Logger = class("Logger")

local DebugLevel = {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
}

local _logLevel = DebugLevel.DEBUG

local function _print(level, format, ...)
    local levelStr = ""
    local levelValue = 0
    if level == DebugLevel.DEBUG then
        levelStr = "Debug"
        levelValue = 4
    elseif level == DebugLevel.INFO then
        levelStr = "Info"
        levelValue = 3
    elseif level == DebugLevel.WARN then
        levelStr = "Warn"
        levelValue = 2
    elseif level == DebugLevel.ERROR then
        levelStr = "Error"
        levelValue = 1
    end

	local args = {...}
	format = #args == 0 and format or string.format(format, ...)

    local s, ms = math.modf(os.time() / 1);
    local _msg = string.format("[%s.%03d-%d-%s] %s", os.date("%X", os.time()),
        math.modf(ms * 1000 / 1), cc.Director:getInstance():getTotalFrames(), levelStr, format)
    -- buglyLog(levelValue,levelStr, string.gsub(_msg, "%%", "_"))
    release_print(_msg);
end

function Logger.debug(format, ...)
	if _logLevel < DebugLevel.DEBUG then
		return
	end

	_print(DebugLevel.DEBUG, format, ...);
end

function Logger.warn(format, ...)
	if _logLevel < DebugLevel.WARN then
		return
	end

	_print(DebugLevel.WARN, format, ...);
end

function Logger.info(format, ...)
	if _logLevel < DebugLevel.INFO then
		return
	end

	_print(DebugLevel.INFO, format, ...);
end

function Logger.error(format, ...)
	if _logLevel < DebugLevel.ERROR then
		return
	end

	_print(DebugLevel.ERROR, format, ...);	
end

function Logger.dump(dumpTab, tips, level)
	if _logLevel < DebugLevel.DEBUG then
		return
    end
    local originPrint = print
    if device.platform == "windwos" then
        print = release_print
    end
    dump(dumpTab, tips, level)
    print = originPrint
end

function Logger.reportStackTrace(format, ...)
	-- buglyReportLuaException(format and string.format(format, ...) or "Internal Error", debug.traceback())
end

function Logger.assert(condition, ...)
	if DEBUG > 0 then
		assert(condition, ...)
	else
		if not condition then
			local msg = {...}
			Logger.error(debug.traceback())
			if msg[1] == nil then
				msg = "Internal Error";
				Logger.error("Asset failed:%s", msg)
				Logger.reportStackTrace("Asset failed:%s", msg)
			else
				Logger.error(...)
				Logger.reportStackTrace(...)
			end			
		end
	end
end