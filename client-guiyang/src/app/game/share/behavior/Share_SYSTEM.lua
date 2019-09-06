--[[    系统分享的封装
    详细注释说明见 Share_FRIENDS.lua
]]
local forms = require("app.game.share.behavior.base.Share_Forms")

local shareFunc = require("app.game.share.behavior.base.ShareSDK_System")
local Version = require "app.kod.util.Version"

local channel = share.constants.CHANNEL.SYSTEM;
local channelidx = share.constants.CHANNELIDX.SYSTEM;

-- 安全分享版本验证
local checkSystemVer = function()
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if currentVersion:compare(Version.new("4.4.0.0")) <= 0 then
		game.ui.UIMessageBoxMgr.getInstance():show("安全分享将信息以更安全的形式分享至聊天工具，目前仅在新版本中可以使用，赶快下载吧！",
		{"立即下载", "取消"}, function()
			-- 跳下载页
			local downloadUrl = config.GlobalConfig.getDownloadUrl();
			cc.Application:getInstance():openURL(config.GlobalConfig.SHARE_HOSTNAME .. downloadUrl)
		end)
		return false
	end	
	return true
end



local shareUrlFunc = function(url, shareInfo, shareContent, shareIcon)
	if checkSystemVer() then
		local showHelp = cc.UserDefault:getInstance():getBoolForKey(share.constants.HELP_KEY, true)
		if showHelp then
			UIManager:getInstance():show("UIShareFindWx", function() shareFunc.shareUrlFunc(url, shareInfo, shareIcon) end)
		else
			shareFunc.shareUrlFunc(url, shareInfo, shareIcon)
		end
	end
end

local sharePicFunc = function(filePath, shareInfo, data)
	if checkSystemVer() then
		local showHelp = cc.UserDefault:getInstance():getBoolForKey(share.constants.HELP_KEY, true)
		if showHelp then
			UIManager:getInstance():show("UIShareFindWx", function() shareFunc.sharePicFunc(filePath) end)
		else
			shareFunc.sharePicFunc(filePath, data)
		end
	end
end

return forms(shareUrlFunc, sharePicFunc, channel, channelidx) 