local csbPath = "ui/csb/UIAccountBindCode.csb"
local super = require("app.game.ui.UIBase")

--[[        关联老帐号
]]
local UIAccountBindCode = class("UIAccountBindCode", super, function() return kod.LoadCSBNode(csbPath) end)

function UIAccountBindCode:needBlackMask()
	return true
end

function UIAccountBindCode:ctor()
	self._code = ""
end

function UIAccountBindCode:init()
	
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	-- --绑定流程
	-- self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	--一键复制
	self._btnCopy = seekNodeByName(self, "btnCopy", "ccui.Button")
	--去新版本
	self._btnJump = seekNodeByName(self, "btnJump", "ccui.Button")
	--验证码框
	self._textCode = seekNodeByName(self, "textCode", "ccui.TextField")
	self._textCode:setTextColor(cc.c4b(151, 86, 31, 255))
	
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
	-- bindEventCallBack(self._btnHelp, handler(self, self._showHelp), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnCopy, handler(self, self._onCopy), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnJump, handler(self, self._jumpToUrl), ccui.TouchEventType.ended)
	
end


function UIAccountBindCode:onShow()
	game.service.LocalPlayerService.getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._queryCode), self)
    game.service.CertificationService:getInstance():addEventListener("EVENT_INTERFLOW_CODE_RECEIVE", handler(self, self._refreshCode), self)
    
    self:_refreshCode()
	self:_queryCode()
end


function UIAccountBindCode:onHide()
	game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
	game.service.CertificationService:getInstance():removeEventListenersByTag(self)
	
end


function UIAccountBindCode:_onClose()
	UIManager:getInstance():destroy("UIAccountBindCode")
end
--显示绑定流程
function UIAccountBindCode:_showHelp()
	UIManager:getInstance():show("UIAccountBindHelp")
end
--复制验证码
function UIAccountBindCode:_onCopy()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.account_verification_code_copy)
	if game.plugin.Runtime.setClipboard(self._code) == true then
		game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
	end
end
--跳转下载页(ios和安卓必须顺序不一样)
function UIAccountBindCode:_jumpToUrl()
	
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.jump_to_new_app)
	local areaId = game.service.LocalPlayerService:getInstance():getArea()
	if areaId == 10006 then 
		-- 铜仁相关
		local downloadUrl = config.GlobalConfig.getDownloadUrl()
		if device.platform == "android" then
			cc.Application:getInstance():openURL(config.GlobalConfig.getConfig().SHARE_HOSTNAME .. downloadUrl)
			cc.Application:getInstance():openURL("myqtrmjgzb://")
		elseif device.platform == "ios" then
			cc.Application:getInstance():openURL("wx7f1dd3655b171be8://")
			cc.Application:getInstance():openURL(config.GlobalConfig.getConfig().SHARE_HOSTNAME .. downloadUrl)
		end
	else 
		local downloadUrl = config.GlobalConfig.getNewDownUrl()
		-- 贵阳相关
		if device.platform == "android" then
			cc.Application:getInstance():openURL(downloadUrl)
			cc.Application:getInstance():openURL("gymjzhht://")
		elseif device.platform == "ios" then
			cc.Application:getInstance():openURL("wx7c6c29fe20b11316://")
			cc.Application:getInstance():openURL(downloadUrl)
		end
	end 
end
--请求验证码
function UIAccountBindCode:_queryCode()
	game.service.CertificationService:getInstance():CIAccountHuTongCodeREQ()
end
--显示验证码
function UIAccountBindCode:_refreshCode(event)
	self._code = game.service.CertificationService:getInstance():getCode()
	self._textCode:setString(self._code)
end


return UIAccountBindCode
