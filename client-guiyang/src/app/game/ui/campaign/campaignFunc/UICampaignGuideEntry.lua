-- 第一次进比赛场的引导界面
local csbPath = "ui/csb/Campaign/campaignUtils/UIBattlemessage.csb"
local super = require("app.game.ui.UIBase")
local CampaignAnimPlayer = require("app.game.campaign.utils.CampaignAnimPlayer");

local UICampaignGuideEntry = class("UICampaignGuideEntry", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignGuideEntry:ctor()
	self._btnClose = nil
    self._btnSee = nil
    self._data = nil
end

function UICampaignGuideEntry:init()
    self._btnClose  = seekNodeByName(self, "Button_Close",  "ccui.Button");
    self._btnSee  = seekNodeByName(self, "Button_Charge",  "ccui.Button");

    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSee, handler(self, self._onSee), ccui.TouchEventType.ended)
end

function UICampaignGuideEntry:onShow(...)
    local args = {...};
    self._btnClose:setVisible(false)
    self._data = args[1]

    self._animNode = CampaignAnimPlayer:getInstance():play(self, config.CampaignConfig.CampaignAnim["FingerTouch"], 1, true)
    local x,y = self._btnSee:getPosition()
    local width = self._btnSee:getContentSize().width
    local height = self._btnSee:getContentSize().height
    self._animNode:setPosition(cc.p(x + width * 0.90, y + height * 0.4))
end

function UICampaignGuideEntry:_onSee()
    scheduleOnce(function()
        UIManager:getInstance():show("UICampaignGuide", self._data)
        UIManager:getInstance():destroy("UICampaignGuideEntry")
    end,0)
end

function UICampaignGuideEntry:onClose()
    UIManager:getInstance():destroy("UICampaignGuideEntry")
end

function UICampaignGuideEntry:_onClose()
    UIManager:getInstance():destroy("UICampaignGuideEntry")
end

function UICampaignGuideEntry:needBlackMask()
	return true;
end

function UICampaignGuideEntry:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignGuideEntry:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignGuideEntry;
