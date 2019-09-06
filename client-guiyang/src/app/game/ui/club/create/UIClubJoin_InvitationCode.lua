local csbPath = "ui/csb/Club/UIClubJoin_InvitationCode.csb"
local super = require("app.game.ui.UIBase")

--[[
    输入亲友圈邀请码申请加入亲友圈
]]

local UIClubJoin_InvitationCode = class("UIClubJoin_InvitationCode", super, function() return cc.CSLoader:createNode(csbPath) end)

function UIClubJoin_InvitationCode:ctor()
    self._animAction = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._animAction)
    
    self._btnFind = seekNodeByName(self, "Button_sqjl_Clublist_0", "ccui.Button") -- 查找
    self._btnApply = seekNodeByName(self, "Button_sqjl_Clublist", "ccui.Button") -- 申请列表
    self._imgApplyRed = seekNodeByName(self, "Image_red_sqjl_Clubnew", "ccui.ImageView") -- 申请列表红点
    -- self._panelPlacard  = seekNodeByName(self, "Panel_1", "ccui.Layout") -- 公告

    self._imtFind = seekNodeByName(self, "Image_22_0", "ccui.ImageView")

    self:_registerCallBack()
end
-- 点击事件注册
function UIClubJoin_InvitationCode:_registerCallBack()
    bindEventCallBack(self._imtFind, handler(self, self._onBtnFindClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFind, handler(self, self._onBtnFindClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnApply, handler(self, self._onBtnApplyClick), ccui.TouchEventType.ended)
    -- bindEventCallBack(self._panelPlacard, handler(self, self._onPlacardClick), ccui.TouchEventType.ended)
end

function UIClubJoin_InvitationCode:show()
    self:setVisible(true)
    self:setPosition(0, 0)
    self:_showTabBadge()
    self._animAction:play("animation0", true)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)
end

function UIClubJoin_InvitationCode:_showTabBadge()
    local service = game.service.club.ClubService.getInstance()
    self._imgApplyRed:setVisible(service:getUserData():hasInvitationBadges())
end

function UIClubJoin_InvitationCode:_onPlacardClick()
    game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBJOIN_INVITATIONCODE_STRING_100, {"我同意"})
end

-- 查找亲友圈
function UIClubJoin_InvitationCode:_onBtnFindClick()
    UIManager:getInstance():show("UIKeyboard", "输入邀请码", 6, "邀请码输入有误，请重新输入", "提交申请", function (code)
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLAccedeToClubInfoREQ(code)
    end)
end

-- 我的申请列表
function UIClubJoin_InvitationCode:_onBtnApplyClick()
    -- 统计点击我的申请按钮的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_My_Apply);

    UIManager:getInstance():show("UIClubInvitation")
end

function UIClubJoin_InvitationCode:hide()
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIClubJoin_InvitationCode
