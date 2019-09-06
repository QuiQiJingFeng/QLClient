--[[
    微信好友分享的封装
    详细注释说明见
]]

-- 分享形式，是一个闭包，把这个渠道必要的参数传入后获取到真正的分享形式
local forms = require("app.game.share.behavior.base.Share_Forms")

-- 分享sdk的封装，提供url和pic的分享接口
local shareFunc = require("app.game.share.behavior.base.ShareSDK_WeChat")

-- 渠道，要往哪里分享
local channel = share.constants.CHANNEL.FRIENDS;
-- 渠道index
local channelidx = share.constants.CHANNELIDX.FRIENDS;
-- 微信sdk需要的参数，指明往朋友圈还是好友分享
local wxType = game.service.WeChatService.WXScene.WXSceneSession;

-- 封装一下分享url的方法
-- 因为微信的sdk需要指定wxType，所以包一层
local shareUrlFunc = function (url, shareInfo, shareContent, shareIcon)
    shareFunc.shareUrlFunc(url, wxType, nil, shareInfo, shareContent, shareIcon)
end

-- 封装一下分享图片的方法
-- 因为微信的sdk需要指定wxType，所以包一层
local sharePicFunc = function (filePath, shareInfo)
    shareFunc.sharePicFunc(filePath, wxType, nil, shareInfo)
end

-- 执行闭包方法，获取到分享形式的各种接口方法 
return forms(shareUrlFunc, sharePicFunc, channel, channelidx)