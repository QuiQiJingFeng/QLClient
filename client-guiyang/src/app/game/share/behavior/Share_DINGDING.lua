--[[    钉钉分享的封装
    详细注释说明见 Share_FRIENDS.lua
]]
local forms = require("app.game.share.behavior.base.Share_Forms")

local shareFunc = require("app.game.share.behavior.base.ShareSDK_DingTalk")

local channel = share.constants.CHANNEL.DINGDING;
local channelidx = share.constants.CHANNELIDX.DINGDING;

-- 钉钉分享版本验证
local checkSystemVer = function()
	if game.service.DingTalkService.getInstance():isSupported() == false then
		game.ui.UIMessageBoxMgr.getInstance():show("钉钉分享目前仅在新版本可用，赶快更新版本吧~",
		{"立即更新", "取消"},	
		function()			
			local downloadUrl = config.GlobalConfig.getDownloadUrl();
			cc.Application:getInstance():openURL(config.GlobalConfig.SHARE_HOSTNAME .. downloadUrl)
		end		
		)
		return false
	elseif game.service.DingTalkService.getInstance():isDTAppInstalled() == false then
		game.ui.UIMessageBoxMgr.getInstance():show("您的设备暂未安装钉钉软件，赶快下载安装吧~",
		{"下载钉钉", "取消"},
		function()
			if device.platform == "ios" then
				cc.Application:getInstance():openURL("https://itunes.apple.com/cn/app/%E9%92%89%E9%92%89/id930368978?mt=8");
			else
				cc.Application:getInstance():openURL("http://android.myapp.com/myapp/detail.htm?apkName=com.alibaba.android.rimet&ADTAG=mobile");
			end
		end
		)
		return false
	else
		return true
	end
end

local shareUrlFunc = function(url, shareInfo, shareContent, shareIcon)
	if checkSystemVer() then
		shareFunc.shareUrlFunc(url, shareInfo, shareContent, shareIcon)
	end
end

local sharePicFunc = function(filePath, shareInfo)
	if checkSystemVer() then
		shareFunc.sharePicFunc(filePath)
	end
end

return forms(shareUrlFunc, sharePicFunc, channel, channelidx) 