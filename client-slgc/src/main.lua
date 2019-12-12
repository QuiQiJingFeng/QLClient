local fileUtils = cc.FileUtils:getInstance()
fileUtils:setPopupNotify(false)
-- local searchPaths = {
--     "src/test",
--     "src",
--     "res",
--     "res/ui",
--     "res/ui/art",
--     "res/ui/csb",
-- }
-- local downloadPath = fileUtils:getWritablePath() .. "package/"
-- for i = 1, #searchPaths do
-- 	table.insert(searchPaths, searchPaths[i])
-- 	searchPaths[i] = downloadPath .. searchPaths[i]
-- end
-- searchPaths[#searchPaths] = downloadPath
-- fileUtils:setSearchPaths(searchPaths)


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

local function main()
    math.randomseed(os.time())
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
    cc.Director:getInstance():setAnimationInterval(1/60)
    
    --"package/package_src.zip"
    --"package/package_res_ui_uncompress.zip"
    
    local scene = cc.Scene:create()
    display.runScene(scene)
    local uncompressLayer = require("uncompress.UncompressLayer").new()
    scene:addChild(uncompressLayer)
    
end

xpcall(main, __G__TRACKBACK__)
