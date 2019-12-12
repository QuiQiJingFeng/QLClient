local fileUtils = cc.FileUtils:getInstance()
fileUtils:setPopupNotify(false)

local breakInfoFun, xpcallFun = require("LuaDebugjit")("localhost", 7003)
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakInfoFun, 0.5, false)

__G__TRACKBACK__ = function(msg)
    xpcallFun()
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

    local callFunc = function()
        require("app.GameMain").create()
    end
    local a = string.format("%s","asdfads")
    --如果是第一次启动,解密资源
    if not cc.FileUtils:getInstance():isFileExist("test/init.lua") then
        local scene = cc.Scene:create()
        cc.Director:getInstance():runWithScene(scene)
        --src\umcompress\UncompressLayer.lua
        local uncompressLayer = require("umcompress.UncompressLayer")
        local layer = uncompressLayer.new(callFunc)
        scene:addChild(layer)
    else
        callFunc()
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
