local csbPath = "ui/csb/UIJingCaiHuoDong.csb"
local super = require("app.game.ui.UIBase")
local ShareNode = require("app.game.ui.element.UIElemShareNode")
local UIFreeCard = class("UIFreeCard", super, function() return kod.LoadCSBNode(csbPath) end)
local Version = require "app.kod.util.Version"


local sharURLToSystem = function(url, shareInfo, shareIcon, shareApp)
	if Macro.assertTrue(type(url) ~= "string") then
		return
	end
	if game.plugin.Runtime.shareUrl(
	shareInfo or config.GlobalConfig.getShareInfo() [1],
	shareIcon or config.GlobalConfig.getDefaultIcon(),
	url,
	shareApp or "com.tencent.mm") then
	end
end

function UIFreeCard:ctor()
	self._shareFlag = false
end

function UIFreeCard:needBlackMask()
	return true
end

function UIFreeCard:init()
	self._btnShare = seekNodeByName(self, "Button_1", "ccui.Button")
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button");
	
	bindEventCallBack(self._btnShare, handler(self, self._onShare), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
end

function UIFreeCard:onShow()
	self._shareFlag = false
	-- 微信分享事件监听
	game.service.WeChatService.getInstance():addEventListener("EVENT_SEND_RESP", handler(self, self._sendMsgToServerIOS), self);
	self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._sendMsgToServer))
	game.service.DataEyeService.getInstance():onEvent("UIFreeCard")
end

function UIFreeCard:onHide()
	game.service.WeChatService.getInstance():removeEventListenersByTag(self)
	
	if self._listenerEnterForeground ~= nil then
		unlistenGlobalEvent(self._listenerEnterForeground)
		self._listenerEnterForeground = nil;
	end
end

--分享成功后向服务器请求获取免费房卡
function UIFreeCard:_sendMsgToServer()
	if not self._shareFlag then
		return
	end
	-- if(event.errCode == game.service.WeChatService.WXErrorCode.WXSuccess) then
	game.service.ActivityService.getInstance():sendCACMainSceneSharePickREQ()
	self:_onClose()
	-- end
end

--分享成功后向服务器请求获取免费房卡
function UIFreeCard:_sendMsgToServerIOS(event)
	
	if(event.errCode == game.service.WeChatService.WXErrorCode.WXSuccess) then
		game.service.ActivityService.getInstance():sendCACMainSceneSharePickREQ()
		self:_onClose()
	end
end

-- 获取分享链接
local getShareUrl = function()
	local encodeURL = function(s)
		s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
		return string.gsub(s, " ", "+")
	end
	
	-- 下载链接
	local url = encodeURL(config.GlobalConfig.getShareUrl())
	-- 地区id
	local area = game.service.LocalPlayerService:getInstance():getArea()
	-- 玩家显示id
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	-- 下载链接*地区ID*用户ID*按钮事件ID
	local state = string.format("%s*%d*%d*%d", url, area, roleId, 2)
	
	-- 测试参数
	-- local wx_appid = "wx92cca06b0a446257"
	-- local redirect_uri = "http://test.agtzf.gzgy.gymjnxa.com/wechattools/ordinary_share.do"
	-- 正式参数
	local wx_appid = "wx4330c6dd6db846dc"
	local redirect_uri = "http://agtzf.gzgy.gymjnxa.com/wechattools/ordinary_share.do"
	
	local shareUrl = string.format("https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%s#wechat_redirect",
	wx_appid,
	encodeURL(redirect_uri),
	state)
	return shareUrl
end

--[[	系统分享URL
	@param url 分享的url地地址
	@param shareInfo 分享到内容
	@param shareIcon 分享的图标
	@param shareApp 要分享到的app，现在默认是微信
]]
local sharURLToSystem = function(url, shareInfo, shareIcon, shareApp)
	if Macro.assertTrue(type(url) ~= "string") then
		return
	end
	if game.plugin.Runtime.shareUrl(
	shareInfo or config.GlobalConfig.getShareInfo() [1],
	shareIcon or config.GlobalConfig.getDefaultIcon(),
	url,
	shareApp or "com.tencent.mm") then
		
		-- 记录分享渠道
		-- game.service.ActivityService.getInstance():setShareChannels(false)
	end
end

--分享按钮回调
function UIFreeCard:_onShare()
	local data =
	{
		_local = ShareNode:getShare_local().main
	}

	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if currentVersion:compare(Version.new("4.4.0.0")) >= 0 then	
	    if device.platform == "ios" then
			UIManager:getInstance():show("UIShareSystemNew",config.SHARE_TYPE.URL_IS_PIC_PATH, config.LOCALSHARE.main, data, {shareType = config.SHARE_TYPE.URL},"art/activity/mainScene_sharios.jpg")
		else
			UIManager:getInstance():show("UIShareSystemNew",config.SHARE_TYPE.URL_IS_PIC_PATH, config.LOCALSHARE.main, data, {shareType = config.SHARE_TYPE.URL},"art/activity/mainScene_shareand.jpg")
		end
		self:_onClose();
	else		
		--分享图片
		local shareImg = ""
		if device.platform == "ios" then
			shareImg = ccui.ImageView:create("art/activity/mainScene_sharios.jpg")
		else
			shareImg = ccui.ImageView:create("art/activity/mainScene_shareand.jpg")
		end
		shareImg:setVisible(false)    
		local shareImgPath = saveNodeToPng(shareImg, function(filePath)
			scheduleOnce(function()
				game.service.WeChatService.getInstance():sendImageData(
					filePath, 
					"tagName", 
					config.GlobalConfig.getShareInfo()[1], 
					"",
					filePath, 
					game.service.WeChatService.WXScene.WXSceneSession)
			end, 0.5)  
		end,"freeCardShareImg.png")
	end


	-- local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	-- if currentVersion:compare(Version.new("4.4.0.0")) < 0 then
	-- 	game.ui.UIMessageBoxMgr.getInstance():show("安全分享将信息以更安全的形式分享至聊天工具，目前仅在新版本中可以使用，赶快下载吧！",
	-- 	{"立即下载", "取消"}, function()
	-- 		-- 跳下载页
	-- 		cc.Application:getInstance():openURL(config.GlobalConfig.getShareUrl())
	-- 	end)
	-- 	-- game.ui.UIMessageTipsMgr.getInstance():showTips("本版本暂不支持此功能，请下载新版!")
	-- 	return
	-- end

	-- -- 分享链接
	-- game.globalConst.getBIStatistics(game.globalConst.shareType.MainScene_Share)
	
	
	-- if device.platform == "ios" then
	-- 	-- local url = getShareUrl()
	-- 	-- sharURLToSystem(url, "我在聚友贵州麻将赢了1000元红包，快来加入吧！")
	-- 	UIManager.getInstance():show("UIMainSceneShare", function(fileName)
	-- 		game.plugin.Runtime.shareImage(fileName, "")
	-- 	end)
	-- 	scheduleOnce(function() 
	-- 		game.service.ActivityService.getInstance():sendCACMainSceneSharePickREQ()
	-- 		UIManager:getInstance():hide("UIFreeCard")
	-- 	 end, 7)
	-- else
	-- 	local url = ""
	-- 	self._shareFlag = true
	-- 	UIManager.getInstance():show("UIMainSceneShare", function(fileName)
	-- 		game.plugin.Runtime.shareImage(fileName, "")
	-- 	end)
		
	-- end
end

--成功分享并获取房卡后的回调
function UIFreeCard:_onSharePickSuccess(event)
	game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UIFREECARD_STRING_100, {"确定"})
end

function UIFreeCard:_onClose()
	UIManager:getInstance():hide("UIFreeCard")
end


return UIFreeCard 
