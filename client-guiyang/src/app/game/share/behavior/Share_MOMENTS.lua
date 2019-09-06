--[[
    朋友圈分享的封装
    详细注释说明见 Share_FRIENDS.lua
]]
local forms = require("app.game.share.behavior.base.Share_Forms")

local shareFunc = require("app.game.share.behavior.base.ShareSDK_WeChat")

local channel = share.constants.CHANNEL.MOMENTS;
local channelidx = share.constants.CHANNELIDX.MOMENTS;
local wxType = game.service.WeChatService.WXScene.WXSceneTimeline;

local shareUrlFunc = function (url, shareInfo, shareContent, shareIcon)
    shareFunc.shareUrlFunc(url, wxType, shareInfo, shareContent, shareIcon)
end

local sharePicFunc = function (filePath, shareInfo)
    shareFunc.sharePicFunc(filePath, wxType, nil, shareInfo)
end

return forms(shareUrlFunc, sharePicFunc, channel, channelidx)