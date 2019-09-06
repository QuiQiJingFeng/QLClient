local csbPath = "ui/csb/UIShareQRCode.csb"
local super = require("app.game.ui.UIBase")
local UIMainSceneShare = class("UIMainSceneShare", super, function() return kod.LoadCSBNode(csbPath) end)

function UIMainSceneShare:ctor()
	self._callback = nil
end

function UIMainSceneShare:init()
	self._ImageShare = seekNodeByName(self, "ImageShare", "ccui.ImageView")
	self._ImageQRCode = seekNodeByName(self, "ImageQRCode", "ccui.ImageView")
	
	
	
end

function UIMainSceneShare:onShow(callback)
	-- game.service.ActivityService.getInstance():addEventListener("EVENT_WECHAT_SHAREURL_CHANGED", handler(self, self._setQRCodeIcon), self)
	-- game.service.ActivityService.getInstance():changeLongUrl2Short(self:createUrl())
	self._ImageShare:setVisible(false)	
	
	self._callback = callback

	local shareImgPath = saveNodeToPng(self._ImageShare, function(filePath)
		UIManager.getInstance():hide("UIMainSceneShare")
		self._callback(filePath)
	end, "shareQRCode.png")
end

function UIMainSceneShare:createUrl()
	-- 下载链
	local url = config.GlobalConfig.getShareUrl()
	-- 地区id
	local area = game.service.LocalPlayerService:getInstance():getArea()
	-- 玩家显示id
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	-- 下载链接*地区ID*用户ID*按钮事件ID
	local state = string.format("%s*%d*%d*%d", url, area, roleId, 3)
	
	-- 测试参数
	-- local wx_appid = "wx92cca06b0a446257"
	-- local redirect_uri = "http://test.agtzf.gzgy.gymjnxa.com/wechattools/ordinary_share.do"
	-- 正式参数
	local wx_appid = "wx4330c6dd6db846dc"
	local redirect_uri = "http://agtzf.gzgy.gymjnxa.com/wechattools/ordinary_share.do"
	
	local shareUrl = string.format("https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%s#wechat_redirect",
	wx_appid,
	(redirect_uri),
	state)
	return shareUrl
end
-- 二维码
function UIMainSceneShare:_setQRCodeIcon(event)
	-- 设置图片
	if not tolua.isnull(self._ImageQRCode) then
		if self._ImageQRCode.loadTexture then
			self._ImageQRCode:loadTexture(event.imgPath)
		elseif self._ImageQRCode.setTexture then
			self._ImageQRCode:setTexture(event.imgPath)
		end
	end
	
	local shareImg = self._ImageShare
	
	
	local shareImgPath = saveNodeToPng(shareImg, function(filePath)
		UIManager.getInstance():hide("UIMainSceneShare")
		self._callback(filePath)
	end, "shareQRCode.png")
end

function UIMainSceneShare:onHide()
	game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end


-- function UIMainSceneShare:needBlackMask()
-- 	return true
-- end
-- function UIMainSceneShare:closeWhenClickMask()
-- 	return true
-- end
return UIMainSceneShare 