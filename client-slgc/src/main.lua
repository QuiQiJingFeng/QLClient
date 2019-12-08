local fileUtils = cc.FileUtils:getInstance()
fileUtils:setPopupNotify(false)
local searchPaths = {
    "src",
    "res",
    "res/ui",
    "res/ui/art",
    "res/ui/csb",
    "src/test"
}
local downloadPath = fileUtils:getWritablePath() .. "package/"
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
    return msg
end

require "config"
require "cocos.init"
require "app.init"

local function main()
    math.randomseed(os.time())
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
    cc.Director:getInstance():setAnimationInterval(1/60)
    
    -- require("app.GameMain").create()
    --TEST
    local testCase = require("test.init")
    require("app.GameMain").create()
    game.Util:scheduleUpdate(function() 
        testCase:run()
        return true
    end,1)
end

xpcall(main, __G__TRACKBACK__)
