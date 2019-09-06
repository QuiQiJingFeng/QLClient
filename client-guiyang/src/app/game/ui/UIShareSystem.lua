local csbPath = "ui/csb/UIShare1.csb"
local super = require("app.game.ui.UIBase")
local MultiArea = require("app.gameMode.config.MultiArea")
local Version = require "app.kod.util.Version"
-- local ShareNode = require("app.game.ui.element.UIElemShareNode")

local BUTTON_TYPE = {
	-- 朋友等会话
	WXSceneSession = 1,
	-- 朋友圈
	WXSceneTimeline = 2,
	-- 系统分享
	System = 3,
}

local BUTTON_TYPE_STRING = {
	-- 朋友等会话
	"friend",
	-- 朋友圈
	"group",
	-- 系统分享
	"system"
}

local UIShareSystem = class("UIShareSystem", super, function () return kod.LoadCSBNode(csbPath) end)

function UIShareSystem:ctor()
	self._shareType = false;
	self._btnClose = nil
	self._shareUrl = nil
	self._extend = nil
end

function UIShareSystem:init()
	self._btnClose   = seekNodeByName(self,"Button_System_help_close",   "ccui.Button")
	self._btnCircle  = seekNodeByName(self,"Button_Circle",  "ccui.Button")
	self._btnFriends = seekNodeByName(self,"Button_Friends", "ccui.Button")
    self._btnSystem  = seekNodeByName(self,"Button_Sys", 	 "ccui.Button")
    self._btnSystemClose = seekNodeByName(self,"Button_Close", 	 "ccui.Button")
	self:_registerCallBack()
end

function UIShareSystem:_registerCallBack()
	bindEventCallBack(self._btnClose,   handler(self, self._onClose),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnCircle,  handler(self, self._onShareToCircle),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnFriends, handler(self, self._onShareToFriends),ccui.TouchEventType.ended);
    bindEventCallBack(self._btnSystem,  handler(self, self._onShareToSystem),ccui.TouchEventType.ended);
    bindEventCallBack(self._btnSystemClose,   handler(self, self._onClose),ccui.TouchEventType.ended);
end

function UIShareSystem:hideUIHelp()
    local help1 = seekNodeByName(self,"Panel_System_help", "ccui.Layout")
    help1:setVisible(false)
    local help2 = seekNodeByName(self,"Button_System_help", "ccui.Layout")
    help2:setVisible(false)
end

function UIShareSystem:recordUIHelp()
    local help1 = seekNodeByName(self,"Panel_System_help", "ccui.Layout")
    help1:setVisible(true)
    local help2 = seekNodeByName(self,"Button_System_help", "ccui.Layout")
    help2:setVisible(true)
end

--[[
	参数类型:
	1.分享类型:截图 链接...
	2.从哪里点击进来的:大厅 活动...
	3.分享的内容
]]
function UIShareSystem:onShow(...)
    local args = {...};
    self:recordUIHelp()
	self._shareType = args[1]

    self._localShare = args[2]
    
    if self._localShare == config.LOCALSHARE.SingleRound then
        self:hideUIHelp()
    end

	if #args > 2 then
		self._shareUrl = args[3]
	end

	-- 有就赋值，没有就是nil
	self._extend = args[4]

	-- 回调,在使用安全分享时使用，因为安全分享没有EVENT_SEND_RESP
    self._callback = args[5]
    
    -- 指定node截图分享
    self._specialNode = args[6]

	-- 防止在微信分享赠房卡活动中点击分享有礼进入微信却没有分享，在点击分享进入微信分享加房卡的bug
	game.service.ActivityService.getInstance():setHasGroup(false)
end

function UIShareSystem:needBlackMask()
	return true;
end

function UIShareSystem:closeWhenClickMask()
	return true
end

function UIShareSystem:_onClose(...)
	UIManager:getInstance():destroy("UIShareSystem")
end

-- 分享到好友群
function UIShareSystem:_onShareToFriends(...)
	-- 统计好友分享
	game.service.DataEyeService.getInstance():onEvent(self._localShare .. "_to_Wfriend");

	-- bi统计分享(大厅分享类型)
	if self._localShare == config.LOCALSHARE.main then
		game.globalConst.getBIStatistics(game.globalConst.shareType.Friend_Share)
	end

	self:_toShare(BUTTON_TYPE.WXSceneSession)
	UIManager:getInstance():destroy("UIShareSystem")
end

-- 分享到朋友圈
function UIShareSystem:_onShareToCircle(...)
	-- 统计朋友圈分享
	game.service.DataEyeService.getInstance():onEvent(self._localShare .. "_to_Group");

	-- bi统计分享(大厅分享类型)
	if self._localShare == config.LOCALSHARE.main then
		game.globalConst.getBIStatistics(game.globalConst.shareType.Group_Share)
	end

	self:_toShare(BUTTON_TYPE.WXSceneTimeline)
	UIManager:getInstance():destroy("UIShareSystem")
end

-- 拉起系统分享
function UIShareSystem:_onShareToSystem(...)
	-- 统计系统分享
	game.service.DataEyeService.getInstance():onEvent(self._localShare .. "_to_System");

	-- bi统计分享(大厅分享类型)
	if self._localShare == config.LOCALSHARE.main then
		game.globalConst.getBIStatistics(game.globalConst.shareType.System_Share)
	end

    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if currentVersion:compare(Version.new("4.4.0.0")) < 0 then
		game.ui.UIMessageBoxMgr.getInstance():show("安全分享将信息以更安全的形式分享至聊天工具，目前仅在新版本中可以使用，赶快下载吧！", 
			{"立即下载", "取消"},function()
				-- 跳下载页
				cc.Application:getInstance():openURL(config.GlobalConfig.getShareUrl())
			end)
		-- game.ui.UIMessageTipsMgr.getInstance():showTips("本版本暂不支持此功能，请下载新版!")
		return
	end
	
	self:_toShare(BUTTON_TYPE.System)
	if self._callback ~= nil and self._callback ~= false then
		self._callback(sender)
	end
	UIManager:getInstance():destroy("UIShareSystem")
end

--[[
	分享到微信，带图片功能的，统一接口，简化参数调用
	@param fileName 分享的文件名
	@param tagName tag
	@param shareInfo shareInfo
	@param wxType 分享的类型
]]
local shareToWX = function(fileName, wxType, tagName, shareInfo)
	game.service.WeChatService.getInstance():sendImageData(
		fileName, 
		tagName or "tagName", 
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		"", 
		fileName, 
		wxType
	)
end

--[[
	分享到系统，带图片功能的，统一接口，简化参数调用
	@param fileName 分享的文件名，这里可能是带完整路径的
]]
local shareToSystem = function(fileName)
	game.plugin.Runtime.shareImage(
		fileName, 
		""
	)
end

--[[
	分享URL到微信
	@param url 分享的url地地址
	@param wxType 分享的类型，是朋友圈还是会话
	@param tagName 
	@param shareInfo info
	@param shareIcon icon
]]
local shareURLToWX = function(url, wxType, tagName, shareInfo, shareContent, shareIcon)
	if game.service.WeChatService.getInstance():sendLinkURL(
		url,
		tagName or "tagName", 
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		shareContent or config.GlobalConfig.getShareInfo()[2], 
		shareIcon or config.GlobalConfig.getDefaultIcon(),
		wxType) then

		-- 记录分享渠道
		game.service.ActivityService.getInstance():setShareChannels(wxType == game.service.WeChatService.WXScene.WXSceneSession)
	end
end

--[[
	系统分享URL
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
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		shareIcon or config.GlobalConfig.getDefaultIcon(),
		url, 
		shareApp or "com.tencent.mm") then

		-- 记录分享渠道
		-- game.service.ActivityService.getInstance():setShareChannels(false)
	end
end

-- 获取分享链接
function UIShareSystem:getShareUrl(buttonType)
	local encodeURL = function(s)
		s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
		return string.gsub(s, " ", "+")
	end

	-- 地区id
	local area = game.service.LocalPlayerService:getInstance():getArea()
	-- 下载链接
	local shortUrls = MultiArea.getShareShortUrl(area)
	local shortUrl = shortUrls[string.format("%s_%s", self._localShare, BUTTON_TYPE_STRING[buttonType])]
	-- 如果没有该分享类型就默认大厅
	if shortUrl == nil then
		shortUrl = shortUrls[string.format("%s_%s", config.LOCALSHARE.main, BUTTON_TYPE_STRING[buttonType])]
	end
	local url = string.format("%s%s",config.GlobalConfig.SHARE_SHORT_URL, shortUrl)

	-- 玩家显示id
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	-- 下载链接*地区ID*用户ID*按钮事件ID
	local state = string.format("%s*%d*%d*%d", url, area, roleId, buttonType)
	
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

--[[
	截图，完成后，再分享到对应的位置
	@param buttonType BUTTON_TYPE按钮类型
]]
function UIShareSystem:_captureScreen(buttonType)
	if buttonType == BUTTON_TYPE.System then
		-- 分享到系统的
		if self._shareType == config.SHARE_TYPE.SCREEN_SHOT then
			-- 分享截图
			cc.utils:captureScreen(function(succeed, outputFile)
					if succeed == false then return end
					shareToSystem(outputFile)
				end, "ScreenShot.jpg"
			)
		elseif self._shareType == config.SHARE_TYPE.SCREEN_SHOT_WITH_LOGO then
			-- 分享指定图片
			captureScreenWithLogo(function(succeed, outputFile)
					if succeed == false then return end
					shareToSystem(outputFile)
				end
			)
		end
	else
		-- 这些是分享到微信的
		local wxType = (buttonType == BUTTON_TYPE.WXSceneSession and game.service.WeChatService.WXScene.WXSceneSession or game.service.WeChatService.WXScene.WXSceneTimeline)
		if self._shareType == config.SHARE_TYPE.SCREEN_SHOT then
			-- 分享截图
			cc.utils:captureScreen(function(succeed, outputFile)
				if succeed == false then return end
				shareToWX(outputFile, wxType)
			end, "ScreenShot.jpg")
		elseif self._shareType == config.SHARE_TYPE.SCREEN_SHOT_WITH_LOGO then
			-- 分享指定图片
			captureScreenWithLogo(function(succeed, outputFile)
				if succeed == false then return end
				shareToWX(outputFile, wxType)
			end)
		end
	end
end

--[[
	统一的处理函数
	现在要处理一个特殊的需求，可以区分处理系统分享跟微信分享
	@param buttonType 按钮的点击类型，现在有三个按钮，分别分享到朋友，朋友圈，系统
]]
function UIShareSystem:_toShare(buttonType)
	if self._shareType == config.SHARE_TYPE.URL then
		-- 分享链接
		local url = config.GlobalConfig.getShareUrl()
		if self._shareUrl ~= nil and self._localShare == config.LOCALSHARE.activity then
			url = string.format("%s*%d", self._shareUrl, buttonType)
		end

		if buttonType == BUTTON_TYPE.System then
			sharURLToSystem(url)
		else
			local wxType = (buttonType == BUTTON_TYPE.WXSceneSession and game.service.WeChatService.WXScene.WXSceneSession or game.service.WeChatService.WXScene.WXSceneTimeline)
			shareURLToWX(url, wxType)
		end
	elseif self._shareType == config.SHARE_TYPE.URL_IS_PIC_PATH then
		local extend = self._extend
		local jpg = "shareImg.jpg"

		-- 分享指定图片
		if buttonType == BUTTON_TYPE.System then
            -- 获取截图的node，进行截图
            local node
            if self._specialNode then
                node = self._specialNode
            else
                node = ShareNode:getShareNode(BUTTON_TYPE_STRING[buttonType] ,self._shareUrl)
            end
			saveNodeToPng(node, function(filePath)
				-- 如果是分享到系统的话，正常处理
				if Macro.assertFalse(cc.FileUtils:getInstance():isFileExist(filePath), filePath) then
					shareToSystem(filePath)
				end
			end, jpg)
		else
			-- 如果是带图片路径的，可以重新指定，现在仅限在指定图片分享的情况下处理
			if not extend then
				local wxType = (buttonType == BUTTON_TYPE.WXSceneSession and game.service.WeChatService.WXScene.WXSceneSession or game.service.WeChatService.WXScene.WXSceneTimeline)
				-- 获取截图的node，进行截图
                local node
                if self._specialNode then
                    node = self._specialNode
                else
                    node = ShareNode:getShareNode(BUTTON_TYPE_STRING[buttonType] ,self._shareUrl)
                end
				saveNodeToPng(node, function(filePath)
					if Macro.assertFalse(cc.FileUtils:getInstance():isFileExist(filePath), filePath) then
						shareToWX(filePath, wxType)
					end
				end, jpg)
			else
				-- 这里可能需要特殊处理一下，因为有的图片是给系统专用的，如果是分享到微信，可能需要特殊处理一下
				if extend.shareType == config.SHARE_TYPE.URL then
					local url = extend.url or self:getShareUrl(buttonType)
					local wxType = (buttonType == BUTTON_TYPE.WXSceneSession and game.service.WeChatService.WXScene.WXSceneSession or game.service.WeChatService.WXScene.WXSceneTimeline)
					shareURLToWX(url, wxType)
				elseif Macro.assertTrue(extend.shareType == config.SHARE_TYPE.URL_IS_PIC_PATH) then
					-- 这个不处理，理论来说应该也不应该出现
				else
					-- 这里是截图功能相关的处理，这样发送截图的分享
					self:_captureScreen(buttonType)
				end
			end
		end
	else
		-- 带截图功能的，统一处理
		self:_captureScreen(buttonType)
	end
end

function UIShareSystem:needBlackMask()
	return true
end

function UIShareSystem:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIShareSystem:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIShareSystem;
