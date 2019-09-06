local fileUtils = cc.FileUtils:getInstance()
fileUtils:setPopupNotify(false)
local searchPaths = {
	"src",
	"res",
	"res/ui",
	"res/ui/art",
	"res/ui/csb",
}
local downloadDir = "download"
if loho.getDownloadDir then downloadDir = loho.getDownloadDir() end -- 获取app的下载目录, 并兼容旧包默认下载目录'download'

local downloadPath = fileUtils:getAppDataPath() .. downloadDir .. "/"
for i = 1, #searchPaths do
	table.insert(searchPaths, searchPaths[i])
	searchPaths[i] = downloadPath .. searchPaths[i]
end
fileUtils:setSearchPaths(searchPaths)

-- 全局异常处理, 捕获的异常传递bugly
__G__TRACKBACK__ = function(msg)
    -- record the message
    local message = msg
    -- auto genretated
    local msg = debug.traceback(msg, 3)
    release_print(msg)
	-- show message in debug mode
	if DEBUG > 0 then loho.messageBox(msg) end
    -- report lua exception
    buglyReportLuaException(tostring(message), debug.traceback())
    return msg
end


local function main()
    require "socket"
    require "config"
    require "app.utils"
    require "cocos.init"
    require "app.GlobalRequire"

    math.randomseed(os.time())

	-- 模拟器检测
    -- if device.platform == "android" then
    -- 	local ok1, isEmulator = luaj.callStaticMethod("com/lohogames/mahjong/EnvironmentDetector", "isEmulator", {}, "()Z")
	--     local ok2, isEmulatorStrict = luaj.callStaticMethod("com/lohogames/mahjong/EnvironmentDetector", "isEmulatorStrict", {}, "()Z")
    --     if (ok1 and isEmulator) or (ok2 and isEmulatorStrict) then
    --         Logger.info("Emulator detected! %s, %s", isEmulator, isEmulatorStrict)
	-- 		cc.Director:getInstance():endToLua()
	-- 		return
    --     end
	-- end
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
	cc.Director:getInstance():setAnimationInterval(1/60)
	
	-- 清老贵阳遗留下载
	if fileUtils:isFileExist(downloadPath .. "scripts/app/global/globalval.lua") then		
		local succ = fileUtils:removeDirectory(fileUtils:getAppDataPath() .. "download/")
	end

	require("app.GameMain").create()	
end

xpcall(main, __G__TRACKBACK__)
