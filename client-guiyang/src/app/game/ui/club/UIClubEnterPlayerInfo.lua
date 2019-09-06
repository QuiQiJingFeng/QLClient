local csbPath = "ui/csb/Club/UIClubEnterPlayerInfo.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubEnterPlayerInfo = class("UIClubEnterPlayerInfo", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    群主输入联系方式
]]

function UIClubEnterPlayerInfo:ctor()
    self._btnClose = nil
    self._btnOk = nil -- 已填写
    self._textInput = nil -- 输入框
    self._pannel = nil

    self._palyerInfo = nil
end

function UIClubEnterPlayerInfo:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnOk = seekNodeByName(self, "Button_ok", "ccui.Button")
    self._textInput = seekNodeByName(self, "TextField_Input", "ccui.TextField")
    self._pannel = seekNodeByName(self, "Panel_STP", "ccui.Layout")

    bindEventCallBack(self._btnClose, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onWriteClick), ccui.TouchEventType.ended)
    self._textInput:addEventListener(handler(self, self._onTextFieldChanged))
end

function UIClubEnterPlayerInfo:onShow(palyerInfo)
    self._palyerInfo = palyerInfo

end

function UIClubEnterPlayerInfo:_onTextFieldChanged(sender, eventType)
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
		end
	end
end

function UIClubEnterPlayerInfo:_onCloseClick()
    UIManager:getInstance():destroy("UIClubEnterPlayerInfo")
end

-- 邀请玩家(填写)
function UIClubEnterPlayerInfo:_onWriteClick()
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLSendClubInvitationREQ(self._palyerInfo.clubId,
        self._palyerInfo.roleId,
        ClubConstant:getClubInvitationSourceType().RECOMMAND,
        self._textInput:getString())

    self:_onCloseClick()
end

function UIClubEnterPlayerInfo:onHide()
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end


function UIClubEnterPlayerInfo:needBlackMask()
	return true
end

function UIClubEnterPlayerInfo:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubEnterPlayerInfo:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end


return UIClubEnterPlayerInfo