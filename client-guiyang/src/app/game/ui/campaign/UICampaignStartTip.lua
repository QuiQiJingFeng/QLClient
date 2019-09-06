local csbPath = "ui/csb/Campaign/UIBattleStartTips.csb"
local super = require("app.game.ui.UIBase")

local UICampaignStartTip = class("UICampaignStartTip", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignStartTip:ctor()
    self._btnCancle = nil
    self._btnJoin = nil

    self._campaignName = ""
    self._campaignId = ""
end

function UICampaignStartTip:init()
    self._btnCancle  = seekNodeByName(self, "Button_cancel",  "ccui.Button");
    self._btnJoin  = seekNodeByName(self, "Button_join",  "ccui.Button");
    self.infoText =  seekNodeByName(self, "Text_z_Battleready",  "ccui.Text");

    bindEventCallBack(self._btnCancle,    handler(self, self.onClose),    ccui.TouchEventType.ended);
    bindEventCallBack(self._btnJoin,    handler(self, self.onJoin),    ccui.TouchEventType.ended);
end

function UICampaignStartTip:onShow(...)
    local args = {...}
    local data = args[1]
    self._campaignId = data.campaignId
    self._campaignName = data.campaignName
    self._configId = data.configId
    self.infoText:setString("您报名的" .. self._campaignName .. "已经开始，您可以点击以下按钮或到比赛场参加比赛。")
end

function UICampaignStartTip:onJoin()
    game.service.CampaignService.getInstance():sendCCASignUpREQ(self._campaignId,self._configId,1) 
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Join_Campaign_Tip);
end

function UICampaignStartTip:onClose()
    UIManager:getInstance():destroy("UICampaignStartTip")
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Join_Campaign_Tip_Cancle);
end

function UICampaignStartTip:needBlackMask()
	return true;
end

function UICampaignStartTip:closeWhenClickMask()
	return false
end

return UICampaignStartTip;
