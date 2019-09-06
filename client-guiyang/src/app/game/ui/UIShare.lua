local csbPath = "ui/csb/UIShare.csb"
local super = require("app.game.ui.UIBase")
local MultiArea = require("app.gameMode.config.MultiArea")

local UIShare = class("UIShare", super, function () return kod.LoadCSBNode(csbPath) end)

function UIShare:ctor()
	self._shareType = false;
	self._btnClose = nil
	self._shareUrl = nil
end

function UIShare:init()
	self._btnClose   = seekNodeByName(self,"Button_Close",   "ccui.Button")
	self._btnCircle  = seekNodeByName(self,"Button_Circle",  "ccui.Button")
	self._btnFriends = seekNodeByName(self,"Button_Friends", "ccui.Button")

	self:_registerCallBack()
end

function UIShare:_registerCallBack()
	bindEventCallBack(self._btnClose,   handler(self, self._onClose),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnCircle,  handler(self, self._onShareToCircle),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnFriends, handler(self, self._onShareToFriends),ccui.TouchEventType.ended);
end

function UIShare:onShow(...)
	local args = {...};
	self._shareType = args[1]

	if #args > 1 then
		self._shareUrl = args[2]
	end

	-- 防止在微信分享赠房卡活动中点击分享有礼进入微信却没有分享，在点击分享进入微信分享加房卡的bug
	game.service.ActivityService.getInstance():setHasGroup(false)
end

function UIShare:needBlackMask()
	return true;
end

function UIShare:closeWhenClickMask()
	return true
end

function UIShare:_onClose(sender)
	UIManager:getInstance():destroy("UIShare")
end

-- 分享到好友群
function UIShare:_onShareToFriends(sender)
	local url = config.GlobalConfig.getShareUrl()
	if self._shareUrl ~= nil then
		url = string.format("%s*1", self._shareUrl)
	end

	if self._shareType == config.SHARE_TYPE.URL or self._shareType == config.SHARE_TYPE.MAIN_URL then
		-- bi统计分享(大厅分享类型)
		if self._shareType == config.SHARE_TYPE.MAIN_URL then
			game.globalConst.getBIStatistics(game.globalConst.shareType.Friend_Share)
		end

		-- 分享链接
		if game.service.WeChatService.getInstance():sendLinkURL(
			url,
			"tagName", 
			config.GlobalConfig.getShareInfo()[1], 
			config.GlobalConfig.getShareInfo()[2],
			config.GlobalConfig.getDefaultIcon(),
			game.service.WeChatService.WXScene.WXSceneSession) then

			-- 记录分享渠道
			game.service.ActivityService.getInstance():setShareChannels(true)
		end
	elseif self._shareType == config.SHARE_TYPE.SCREEN_SHOT then
		-- 分享截图
		cc.utils:captureScreen(function(succeed, outputFile)
			if succeed == false then return end
			game.service.WeChatService.getInstance():sendImageData(
				outputFile, 
				"tagName", 
				config.GlobalConfig.getShareInfo()[1],  
				config.GlobalConfig.getShareInfo()[2], 
				outputFile, 
				game.service.WeChatService.WXScene.WXSceneSession)
		end, "ScreenShot.jpg")
	elseif self._shareType == config.SHARE_TYPE.SCREEN_SHOT_WITH_LOGO then
		captureScreenWithLogo(function(succeed, outputFile)
			if succeed == false then return end
			game.service.WeChatService.getInstance():sendImageData(
				outputFile, 
				"tagName", 
				config.GlobalConfig.getShareInfo()[1],  
				config.GlobalConfig.getShareInfo()[2], 
				outputFile, 
				game.service.WeChatService.WXScene.WXSceneSession)
		end)
	end

	UIManager:getInstance():destroy("UIShare")
end

-- 分享到朋友圈
function UIShare:_onShareToCircle(sender)
	local url = config.GlobalConfig.getShareUrl()
	if self._shareUrl ~= nil then
		url = string.format("%s*2", self._shareUrl)
	end

	if self._shareType == config.SHARE_TYPE.URL or self._shareType == config.SHARE_TYPE.MAIN_URL then
		--- bi统计分享(大厅分享类型)
		if self._shareType == config.SHARE_TYPE.MAIN_URL then
			game.globalConst.getBIStatistics(game.globalConst.shareType.Group_Share)
		end

		-- 分享链接
		if game.service.WeChatService.getInstance():sendLinkURL(
			url,
			"tagName", 
			config.GlobalConfig.getShareInfo()[1], 
			"", 
			config.GlobalConfig.getDefaultIcon(),
			game.service.WeChatService.WXScene.WXSceneTimeline) then

			-- 记录分享渠道
			game.service.ActivityService.getInstance():setShareChannels(false)
		end
	elseif self._shareType == config.SHARE_TYPE.SCREEN_SHOT then
		-- 分享截图
		cc.utils:captureScreen(function(succeed, outputFile)
			if succeed == false then return end
			game.service.WeChatService.getInstance():sendImageData(
				outputFile, 
				"tagName", 
				config.GlobalConfig.getShareInfo()[1], 
				"", 
				outputFile, 
				game.service.WeChatService.WXScene.WXSceneTimeline)
		end, "ScreenShot.jpg")
	elseif self._shareType == config.SHARE_TYPE.SCREEN_SHOT_WITH_LOGO then
		captureScreenWithLogo(function(succeed, outputFile)
			if succeed == false then return end
			game.service.WeChatService.getInstance():sendImageData(
				outputFile, 
				"tagName", 
				config.GlobalConfig.getShareInfo()[1], 
				"", 
				outputFile, 
				game.service.WeChatService.WXScene.WXSceneTimeline)
		end)
	end

	UIManager:getInstance():destroy("UIShare")
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIShare:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIShare;
