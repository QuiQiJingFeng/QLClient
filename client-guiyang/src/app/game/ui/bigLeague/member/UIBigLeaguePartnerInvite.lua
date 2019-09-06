local csbPath = "ui/csb/BigLeague/UIBigLeaguePartnerInvite.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeaguePartnerInvite:UIBase
local UIBigLeaguePartnerInvite = super.buildUIClass("UIBigLeaguePartnerInvite", csbPath)

function UIBigLeaguePartnerInvite:ctor()

end

function UIBigLeaguePartnerInvite:init()
    self._btnPlayerId = seekNodeByName(self, "Button_PlayerId", "ccui.Button")
    self._btnImport = seekNodeByName(self, "Button_Import", "ccui.Button")
    self._btnClosed = seekNodeByName(self, "Button_Closed", "ccui.Button")

    bindEventCallBack(self._btnPlayerId, handler(self, self._onClickPlayerId), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnImport, handler(self, self._onClickImport), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClosed, function () self:destroySelf() end, ccui.TouchEventType.ended)
end

function UIBigLeaguePartnerInvite:_onClickPlayerId()
    local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    UIManager:getInstance():show("UIKeyboard", "邀请成员", 9, "请输入正确的玩家ID", "邀请", function (inviterId)
        bigLeagueService:sendCCLInvitePartnerMemberREQ(bigLeagueService:getLeagueData():getLeagueId(), bigLeagueService:getLeagueData():getClubId(), tonumber(inviterId))
        self:hideSelf()
    end)
end

function UIBigLeaguePartnerInvite:_onClickImport()
    -- 亲友圈导入
    local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    UIManager:getInstance():show("UIClubGroupImportList", bigLeagueService:getLeagueData():getClubId(), bigLeagueService:getLeagueData():getLeagueId())
    self:hideSelf()
end

function UIBigLeaguePartnerInvite:onShow()

end

function UIBigLeaguePartnerInvite:onHide()

end

function UIBigLeaguePartnerInvite:needBlackMask()
    return true
end

function UIBigLeaguePartnerInvite:closeWhenClickMask()
    return false
end

function UIBigLeaguePartnerInvite:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeaguePartnerInvite