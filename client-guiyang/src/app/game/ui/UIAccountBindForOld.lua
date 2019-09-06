local csbPath = "ui/csb/UIAccountBindForOld.csb"
local super = require("app.game.ui.UIBase")
local UIRichTextEx = require("app.game.util.UIRichTextEx")

--[[        关联老帐号
]]
local UIAccountBindForOld = class("UIAccountBindForOld", super, function() return kod.LoadCSBNode(csbPath) end)

function UIAccountBindForOld:needBlackMask()
	return true
end

function UIAccountBindForOld:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

function UIAccountBindForOld:ctor()
	self._code = ""
	self._copied = false
end

function UIAccountBindForOld:init()
	
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	-- 按钮我知道了(设定3S后可以点击)
	self._btnClose1 = seekNodeByName(self, "btnClose1", "ccui.Button")
	
	--去新版本
	self._btnJump = seekNodeByName(self, "btnJump", "ccui.Button")
	self._btnJump1 = seekNodeByName(self, "btnJump1", "ccui.Button")
	
	self._panelNormal = seekNodeByName(self, "panelNormal", "ccui.Layout")
	self._panelWarning = seekNodeByName(self, "panelWarning", "ccui.Layout")
	
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose1, handler(self, self._onClose), ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnJump, handler(self, self._jumpToUrl), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnJump1, handler(self, self._jumpToUrl), ccui.TouchEventType.ended)
	
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	
end


function UIAccountBindForOld:onShow(isWarn, isForce)
	game.service.LocalPlayerService.getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._queryCode), self)
	-- game.service.CertificationService:getInstance():addEventListener("EVENT_INTERFLOW_CODE_RECEIVE", handler(self, self._refreshCode), self)
	self:_queryCode()
	self._panelNormal:setVisible( isForce)
	self._panelWarning:setVisible(not isForce)
	self._btnClose:setVisible(not (isForce or isWarn))
	
	-- if isWarn then
		self:_setCloseBtnTimer()
	-- end
end


function UIAccountBindForOld:onHide()
	game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
	game.service.CertificationService:getInstance():removeEventListenersByTag(self)
	self._copied = false
end


function UIAccountBindForOld:_onClose()
	UIManager:getInstance():destroy("UIAccountBindForOld")
end
--显示绑定流程
function UIAccountBindForOld:_showHelp()
	UIManager:getInstance():show("UIAccountBindHelp")
end

--跳转下载页(ios和安卓必须顺序不一样)
function UIAccountBindForOld:_jumpToUrl()
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
		-- 贵阳相关
		local downloadUrl = config.GlobalConfig.getNewDownUrl()
		if device.platform == "android" then
			cc.Application:getInstance():openURL(downloadUrl)
			cc.Application:getInstance():openURL("gymjzhht://")
		elseif device.platform == "ios" then
			cc.Application:getInstance():openURL("wx7c6c29fe20b11316://")
			cc.Application:getInstance():openURL(downloadUrl)
		end
	end 
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.jump_to_new_app_at_once)

end
--请求验证码
function UIAccountBindForOld:_queryCode()
	game.service.CertificationService:getInstance():CIAccountHuTongCodeREQ()
end
--显示验证码
function UIAccountBindForOld:_refreshCode(event)
	self._code = event.code
	self._textCode:setString(self._code)
end

function UIAccountBindForOld:_setCloseBtnTimer()
	self._btnClose1:setEnabled(false)
	scheduleOnce(function() 
		if self._btnClose1 then
			self._btnClose1:setEnabled(true)
		end
	end, 3)
end


return UIAccountBindForOld
