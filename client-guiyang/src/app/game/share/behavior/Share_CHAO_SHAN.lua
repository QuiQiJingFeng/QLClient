
local shareFunc = require("app.game.share.behavior.base.ShareSDK_System")
local Version = require "app.kod.util.Version"

local channel = share.constants.CHANNEL.SYSTEM;
local channelidx = share.constants.CHANNELIDX.SYSTEM;

local shareUrlFunc = function (url, shareInfo, shareContent, shareIcon)
    shareFunc.shareUrlFunc(url, shareInfo, shareIcon)
end

local sharePicFunc = function (filePath, shareInfo)
    shareFunc.sharePicFunc(filePath)
end

return {
    USE_SYSTEM_FIRST = function (enter, data, finalCallback, uiname)
        return function ()
            local currentVersion = Version.new("4.4.1.0") --game.plugin.Runtime.getBuildVersion())
            if currentVersion:compare(Version.new("4.4.0.0")) >= 0 then
                UIManager:getInstance():show("UIShareWTF_chaoshan", enter, data, finalCallback)
                return
            end

            share.ShareWTF.getInstance():shareDefault(enter, data, finalCallback, uiname)
        end
    end
}