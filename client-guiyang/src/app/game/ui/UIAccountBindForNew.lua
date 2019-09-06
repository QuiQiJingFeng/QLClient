local csbPath = "ui/csb/UIAccountBindForNew.csb"
local super = require("app.game.ui.UIBase")

--[[        关联老帐号
]]
local UIAccountBindForNew = class("UIAccountBindForNew", super, function() return kod.LoadCSBNode(csbPath) end)
local oldUrl = "https://lnk0.com/easylink/ELFpMZNd"

function UIAccountBindForNew:needBlackMask()
	return true 
end

function UIAccountBindForNew:ctor()
	
end

function UIAccountBindForNew:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	-- --绑定流程
	-- self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	--绑定账号
	self._btnBind = seekNodeByName(self, "btnBind", "ccui.Button")
	--验证码框
	self._textCode = seekNodeByName(self, "textCode", "ccui.TextField")
	--去旧版本
	self._btnJump = seekNodeByName(self, "btnJump", "ccui.Button")
	
	self._panel = seekNodeByName(self, "Panel_BG", "ccui.Layout")

	self._btnPaste = seekNodeByName(self, "btnPaste", "ccui.Button")
	
	self._beginPosY_panel = self._panel:getPositionY()
	
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
	-- bindEventCallBack(self._btnHelp, handler(self, self._showHelp), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnBind, handler(self, self._bindAccount), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnJump, handler(self, self._jumpToUrl), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnPaste, handler(self, self._pasteCode), ccui.TouchEventType.ended)
	self._textCode:addEventListener(handler(self, self._changePos))
	self._textCode:setTextColor(cc.c4b(151, 86, 31, 255))
end


function UIAccountBindForNew:onShow()
	game.service.CertificationService:getInstance():addEventListener("EVENT_INTERFLOW_BIND_SUCCESS", handler(self, self._onClose), self)
	self._textCode:setString("")
	
end


function UIAccountBindForNew:onHide()
	game.service.CertificationService:getInstance():removeEventListenersByTag(self)
end

function UIAccountBindForNew:_onClose()
	UIManager:getInstance():destroy("UIAccountBindForNew")
end

function UIAccountBindForNew:_showHelp()
	UIManager:getInstance():show("UIAccountBindHelp")
end

function UIAccountBindForNew:_bindAccount()
	local code = self._textCode:getString()
	if not code or code == "" then
		game.ui.UIMessageTipsMgr.getInstance():showTips("请输入验证码")
	else
		game.service.CertificationService:getInstance():CIAccountHuTongByCodeREQ(code, false)
	end

	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.bind_old_account)
	
end

--跳转下载页(ios和安卓必须顺序不一样)
function UIAccountBindForNew:_jumpToUrl()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.jump_to_old_app)
	
	local areaId = game.service.LocalPlayerService:getInstance():getArea()
	if areaId == 10006 then 
		-- 铜仁相关
		if device.platform == "android" then
			cc.Application:getInstance():openURL(oldUrl)
			cc.Application:getInstance():openURL("myqtrmj://")
		elseif device.platform == "ios" then
			cc.Application:getInstance():openURL("wxd82a674598535715://")
			cc.Application:getInstance():openURL(oldUrl)
		end
	else 
		-- 贵阳相关
		if device.platform == "android" then
			cc.Application:getInstance():openURL(oldUrl)
			cc.Application:getInstance():openURL("qyhgymj://")
			cc.Application:getInstance():openURL("gyyybtestschema://")
			
		elseif device.platform == "ios" then
			cc.Application:getInstance():openURL("wx009e2922f786b230://")
			cc.Application:getInstance():openURL("wxc431ee8bb37d8013://")
			cc.Application:getInstance():openURL("wxc5613106044a7e8f://")
			cc.Application:getInstance():openURL(oldUrl)
		end
	end 
end

function UIAccountBindForNew:_changePos(sender, event)
	if event == ccui.TextFiledEventType.attach_with_ime then
		self._panel:setPositionY(self._beginPosY_panel + display.height * 0.15)
	elseif event == ccui.TextFiledEventType.detach_with_ime then
		self._panel:setPositionY(self._beginPosY_panel)
	end	
end

function UIAccountBindForNew:_pasteCode(...)
	game.plugin.Runtime.getClipboard(function(msg)
		if not msg then
			msg = ""
		end
		self._textCode:setString(msg)
	end)

	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.paste_account_verification_code)
end

return UIAccountBindForNew
