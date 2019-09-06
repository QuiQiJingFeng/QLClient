local csbPath = "ui/csb/UIAccountAssociation.csb"
local super = require("app.game.ui.UIBase")

--[[
        关联老帐号
]]

local UIAccountAssociation = class("UIAccountAssociation", super, function() return kod.LoadCSBNode(csbPath) end )

function UIAccountAssociation:ctor()
    self._panelPhone = nil -- 手机绑定的panel
    self._panelPlayInfo = nil -- 玩家信息的panel

    self._textIntroduce = nil -- 新老帐号关联说明
    self._textPhone = nil -- 手机号
    self._textCode = nil -- 验证码
    self._btnCode = nil -- 获取验证码按钮
    self._textBtnCodeName = nil -- 获取验证码按钮名称
    self._btnNext = nil -- 下一步

    self._textOldId = nil -- 老帐号Id
    self._textId = nil -- 现在玩家id
    self._textOldName = nil -- 老帐号昵称
    self._textName = nil -- 现在玩家昵称
    self._textOldRoomCard = nil -- 老帐号房卡
    self._textRoomCard = nil -- 现在玩家房卡
    self._btnAssociate = nil -- 关联
    self._btnNotAssociate = nil -- 取消关联

    self._playInfo = nil -- 保存一下玩家数据
    self._updateTime = nil
    self._time = 0
end

function UIAccountAssociation:init()
    self._panelPhone = seekNodeByName(self, "Panel_Phone", "ccui.Layout")
    self._panelPlayInfo = seekNodeByName(self, "Panel_Playinfo", "ccui.Layout")
    self._panelPhone:setVisible(true)
    self._panelPlayInfo:setVisible(false)

    self._textIntroduce = seekNodeByName(self, "Text_Introduce", "ccui.Text")
    self._textPhone = seekNodeByName(self, "Text_Phone", "ccui.TextField")
    self._textCode = seekNodeByName(self, "Text_Code", "ccui.TextField")
    self._btnCode = seekNodeByName(self, "Button_Code", "ccui.Button")
    self._textBtnCodeName = seekNodeByName(self, "BitmapFontLabel_CodeName", "ccui.TextBMFont")
    self._btnNext = seekNodeByName(self, "Button_Next", "ccui.Button")

    self._textOldId = seekNodeByName(self, "Text_OldId", "ccui.Text")
    self._textId = seekNodeByName(self, "Text_Id", "ccui.Text")
    self._textOldName = seekNodeByName(self, "Text_OldName", "ccui.Text")
    self._textName = seekNodeByName(self, "Text_Name", "ccui.Text")
    self._textOldRoomCard = seekNodeByName(self, "Text_OldRoomCard", "ccui.Text")
    self._textRoomCard = seekNodeByName(self, "Text_RoomCard", "ccui.Text")
    self._btnAssociate = seekNodeByName(self, "Button_Associate", "ccui.Button")
    self._btnNotAssociate = seekNodeByName(self, "Button_NotAssociate", "ccui.Button")
    self._btnClose = seekNodeByName(self._panelPhone, "btnClose", "ccui.Button")
    self._btnClose_ = seekNodeByName(self._panelPlayInfo, "btnClose", "ccui.Button")

    bindEventCallBack(self._btnCode, handler(self, self._onBtnCode), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNext, handler(self, self._onBtnNext), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose_, handler(self, self._onBtnClose), ccui.TouchEventType.ended)

    bindEventCallBack(self._btnAssociate, handler(self, self._onBtnAssociate), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNotAssociate, handler(self, self._onBtnNotAssociate), ccui.TouchEventType.ended)

    self._textPhone:addEventListener(handler(self, self._onTextFieldChanged))
    self._textCode:addEventListener(handler(self, self._onTextFieldChanged))
    self._textPhone:setTextColor(cc.c4b(151, 86, 31, 255))
    self._textCode:setTextColor(cc.c4b(151, 86, 31, 255))
end

function UIAccountAssociation:_onTextFieldChanged(sender, eventType)
	-- 当是插入文字的时候
	if eventType == ccui.TextFiledEventType.attach_with_ime  then
		if device.platform == "ios" then
			self._panelPhone:setPositionPercent(cc.p(0.5,0.7))
		end
	end
	if eventType == ccui.TextFiledEventType.detach_with_ime then
		if device.platform == "ios" then 
			self._panelPhone:setPositionPercent(cc.p(0.5,0.5))
		end
	end
end

-- 获取手机验证码
function UIAccountAssociation:_onBtnCode()
    -- 客户端先判断一下手机号是否正确
    local aa = self._textPhone:getString()
    if self._loginPhoneService:isVerificationPhone(self._textPhone:getString()) then
        self._loginService:phoneCodeReq(self._textPhone:getString(), self._loginPhoneService:getCodeType().TYPE_BIND_OLD_ROLEID)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的手机号")
    end
end

-- 请求老帐号信息
function UIAccountAssociation:_onBtnNext()
    if self._textPhone:getString() ~= "" and self._textCode:getString() ~= "" then
        local areaId = game.service.LocalPlayerService:getInstance():getArea()
        local phone = self._textPhone:getString()
        local code = self._textCode:getString()
        self._loginPhoneService:sendCIQueryPlayerInfoREQ(self._textPhone:getString(), self._textCode:getString(), areaId)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的手机号或验证码")
    end
end

-- 请求服务器关联帐号
function UIAccountAssociation:_onBtnAssociate()
    game.ui.UIMessageBoxMgr.getInstance():show("是否确认关联该账号信息,关联成功后当前账号信息将无法恢复!" , {"确定","取消"}, function()
        local areaId = game.service.LocalPlayerService:getInstance():getArea()
        self._loginPhoneService:sendCIBindOldPlayerREQ(self._playInfo.sign, self._playInfo.phone)
    end)
end

-- 取消关联
function UIAccountAssociation:_onBtnNotAssociate()
    UIManager:getInstance():hide("UIAccountAssociation")
end

function UIAccountAssociation:onShow()
    self._loginService = game.service.LoginService:getInstance()
    self._loginPhoneService = self._loginService:getLoginPhoneService()

    
    self._textIntroduce:setString("1.关联账号就是将另一个已存在的账号信息关联至当前的登录方式上;\n2.关联成功后，当前账号的所有信息将被要关联的账号覆盖;\n3.关联成功后,如有任何疑问,可联系官方客服进行咨询;")

    -- 默认显示获取手机验证码界面
    self:_setVisible(true)

    self:_setUpdataTime()

    self._loginPhoneService:addEventListener("EVENT_OLDPLAYERINFO", handler(self, self._updataOldPlayerInfo), self)
    self._loginService:addEventListener("EVENT_VERIFYCODE", function()
        self._time = 60
        self:_setUpdataTime()
    end, self)
end

-- 区分显示panel
function UIAccountAssociation:_setVisible(isVisible)
    self._panelPhone:setVisible(isVisible)
    self._panelPlayInfo:setVisible(not isVisible)
end

-- 做一个验证码倒计时的处理
function UIAccountAssociation:_setUpdataTime()
    self._time = self._time - 1
    if self._time <= 0 then
        self._time = 0
        if self._updataTime ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updataTime)
		    self._updataTime = nil
        end
    else
        if self._updataTime == nil then
            self._updataTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._setUpdataTime), 1, false)
        end
    end

    if self._time == 0 then
        self._textBtnCodeName:setString("获取验证码")
        self._btnCode:setEnabled(true)
    else
        self._textBtnCodeName:setString(string.format("%ds", self._time))
        self._btnCode:setEnabled(false)
    end
end

function UIAccountAssociation:_updataOldPlayerInfo(event)
    self:_setVisible(false)

    self._playInfo = event.oldPlayerInfo

    -- 初始化玩家新老帐号数据
    self._textOldId:setString(string.format("ID:%s", self._playInfo.oldRoleId))
    self._textId:setString(string.format("ID:%s", game.service.LocalPlayerService:getInstance():getRoleId()))
    self._textOldName:setString(string.format("昵称:%s", self:_getInterceptString(self._playInfo.oldName)))
    self._textName:setString(string.format("昵称:%s", self:_getInterceptString(game.service.LocalPlayerService:getInstance():getName())))
    self._textOldRoomCard:setString(string.format(config.STRING.UIACCOUNTASSOCIATION_STRING_101, self._playInfo.cardNum))
    self._textRoomCard:setString(string.format(config.STRING.UIACCOUNTASSOCIATION_STRING_101, game.service.LocalPlayerService:getInstance():getCardCount()))
end

function UIAccountAssociation:_getInterceptString(string)
	if string == nil then
		return ""
	end

    local len = 8
	
	if kod.util.String.getUTFLen(string) > len then
		return kod.util.String.getMaxLenString(string, len)
	end
	
	return string
end

function UIAccountAssociation:onHide()
    self._loginPhoneService:removeEventListenersByTag(self)
    self._loginService:removeEventListenersByTag(self)

    if self._updataTime ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updataTime)
        self._updataTime = nil
    end
end

function UIAccountAssociation:_onBtnClose()
    UIManager:getInstance():destroy("UIAccountAssociation")
end

function UIAccountAssociation:needBlackMask()
	return true
end

function UIAccountAssociation:closeWhenClickMask()
	return false
end

return UIAccountAssociation
