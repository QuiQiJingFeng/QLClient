local csbPath = "ui/csb/UICertification.csb"
local super = require("app.game.ui.UIBase")
local UICertification = class("UICertification", super, function () return kod.LoadCSBNode(csbPath) end)

function UICertification:cotr()
	self._btnEnsure	= nil
	self._btnClose	= nil
	self._textName = nil
	self._textCertification = nil
end

function UICertification:init()
	self._btnEnsure	= seekNodeByName(self, "Button_rz_certification", "ccui.Button");
	self._btnClose	= seekNodeByName(self, "Button_x_certification", "ccui.Button");
	self._pannel = seekNodeByName(self, "Panel_certification", "ccui.Layout");
	self._textName = seekNodeByName(self, "TextField__srk1_shuzi_certification", "ccui.TextField")
	self._textCertification = seekNodeByName(self, "TextField__srk2_shuzi_certification", "ccui.TextField")
	self._clearInputBtn = seekNodeByName(self, "Button_1", "ccui.Button")

	self:_registerCallBack()
end

function UICertification:_registerCallBack()
	bindEventCallBack(self._btnEnsure, handler(self, self._onBtnEnsure), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose, handler(self, self._onBtnBack), ccui.TouchEventType.ended);
	bindEventCallBack(self._clearInputBtn, handler(self, self._onBtnClear), ccui.TouchEventType.ended);
	self._textName:addEventListener(handler(self, self._onTextFieldChanged))
	self._textCertification:addEventListener(handler(self, self._onTextFieldChanged))
end

function UICertification:_onBtnClear()
	self._textCertification:setString("")
	self._clearInputBtn:setVisible(false)
end

-- 界面显示
function UICertification:onShow()

	self._textName:setMaxLengthEnabled(true)
	self._textName:setMaxLength(16)
	self._textName:setTextColor(cc.c4b(151, 86, 31, 255))
	self._textCertification:setTextColor(cc.c4b(151, 86, 31, 255))
	-- self._textCertification:setMaxLengthEnabled(true)
	-- self._textCertification:setMaxLength(18)
	-- self._btnEnsure:setColor(cc.c3b(128,128,128))
	self:_updateButtonStatus()
end

-- 界面隐藏
function UICertification:onHide()
	self._textName:setString("")
	self._textCertification:setString("")
end

function UICertification:needBlackMask()
	return true;
end

function UICertification:closeWhenClickMask()
	return false
end

function UICertification:_onBtnEnsure()
	local name = string.trim(self._textName:getString())
	local certification = string.trim(self._textCertification:getString())
	if string.len(name) == 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("请输入姓名")
		return
	end
	if string.len(certification) ~= 18 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("请输入18位身份证号")
		return
	end

	game.service.CertificationService:getInstance():queryIdentityVerify(game.service.LocalPlayerService.getInstance():getRoleId(), name, certification)
end

function UICertification:_onBtnBack()
	UIManager:getInstance():hide("UICertification")
end

function UICertification:_onTextFieldChanged(sender, eventType)
	-- 当是插入文字的时候
	if eventType == ccui.TextFiledEventType.attach_with_ime  then
		if device.platform == "ios" then
			self._pannel:setPositionPercent(cc.p(0.5,0.7))
		end
		if sender:getString() == "" then
			sender:setString(" ")
		end
	end
	if eventType == ccui.TextFiledEventType.detach_with_ime then
		if device.platform == "ios" then 
			self._pannel:setPositionPercent(cc.p(0.5,0.5))
		end
		if sender:getString() == " " then		
			sender:setString("")
			self._clearInputBtn:setVisible(false)
		end
	end
	if eventType == ccui.TextFiledEventType.insert_text or eventType == ccui.TextFiledEventType.delete_backward then
		self:_updateButtonStatus()
	end
end

-- 更新当前按钮状态
function UICertification:_updateButtonStatus()
	local certification = self._textCertification:getString()
	if string.len(string.trim(certification)) > 0 then
		self._clearInputBtn:setVisible(true)
	else
		self._clearInputBtn:setVisible(false)
	end
end

return UICertification