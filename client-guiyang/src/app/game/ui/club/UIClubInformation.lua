local csbPath = "ui/csb/Club/UIClubInformation.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubInformation = class("UIClubInformation", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    亲友圈邀请信息内容
]]

function UIClubInformation:ctor()
    self._btnClose = nil
    self._btnAccept = nil -- 接受
    self._btnCancel = nil -- 取消
    self._btnCopy = nil -- 拷贝
    self._textContent = nil -- 信息内容

    self._data = nil -- 记录内容
end

function UIClubInformation:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnAccept = seekNodeByName(self, "Button_Accept", "ccui.Button")
    self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
    self._btnCopy = seekNodeByName(self, "Button_Copy", "ccui.Button")
    self._textContent = seekNodeByName(self, "Text_Content", "ccui.Text")

    self:_registerCallBack()
end

function UIClubInformation:_registerCallBack()
    bindEventCallBack(self._btnClose, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnAccept, handler(self, self._onAcceptClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCopy, handler(self, self._onCopyClick), ccui.TouchEventType.ended)
end

function UIClubInformation:onShow(data)
    self._data = data

    -- 信息有没有处理所显示的按钮不一样
    self._btnAccept:setVisible(data.status == ClubConstant:getClubInvitationStatus().NORMAL)
    self._btnCancel:setVisible(data.status == ClubConstant:getClubInvitationStatus().NORMAL)
    self._textContent:setString(data.invitedMsg)
end

-- 接受邀请
function UIClubInformation:_onAcceptClick()
   game.service.club.ClubService.getInstance():getClubMemberService():sendCCLClubInvitationResultREQ(self._data, true, self._data.sourceType)
   self:_onCloseClick()
end

-- 拷贝信息内容
function UIClubInformation:_onCopyClick()
    -- 统计亲友圈复制按钮的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_club_recommend_copy);

    if self._textContent:getString() ~= "" and game.plugin.Runtime.setClipboard(self._textContent:getString()) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end
end

function UIClubInformation:_onCloseClick()
    UIManager:getInstance():destroy("UIClubInformation")
end

function UIClubInformation:onHide()
end


function UIClubInformation:needBlackMask()
	return true
end

function UIClubInformation:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubInformation:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubInformation