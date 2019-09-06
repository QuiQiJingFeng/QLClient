--[[
比赛详情子界面
--]]
local csbPath = "ui/csb/Campaign/campaignUtils/UIBattlehelp.csb"
local super = require("app.game.ui.UIBase")


local UIElemCampaignRewards = require("app.game.ui.campaign.elem.UIElemCampaignRewards")
local UIElemCampaignRule = require("app.game.ui.campaign.elem.UIElemCampaignRule")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
----------------------------------------------------------------------
--比赛场比赛详情界面
local UICampaignDetailPage = class("UICampaignDetailPage", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignDetailPage:ctor(parent)
    self._parent = parent;

    -- 比赛奖励pannel
    self._campaignRewardPannel = nil
    -- 比赛规则pannel
    self._campaignRulePannel = nil

    self._anchorNode = nil

    -- checkbox
    self._campaignRewardCheckbox = nil
    self._campaignRuleCheckbox = nil

    self._checkboxGroup = {}

    self.datas = {}
end

function UICampaignDetailPage:init()
    -- 只有一个奖品时的UI       
    self._btnClose = seekNodeByName(self, "btnClose_Battlehelp", "ccui.Button")
    self._campaignRewardCheckbox = seekNodeByName(self, "CheckBox1_Battlehelp", "ccui.CheckBox")
    self._campaignRuleCheckbox = seekNodeByName(self, "CheckBox2_Battlehelp", "ccui.CheckBox")
    self._anchorNode = seekNodeByName(self, "Node_1", "cc.Node")

    -- 绑定按钮事件
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)

    -- checkbox事件
    self._checkboxGroup = CheckBoxGroup.new({
        self._campaignRewardCheckbox,
        self._campaignRuleCheckbox
    }, handler(self, self._onCheckBoxGroupClick))
end

function UICampaignDetailPage:onShow(info)
    self.datas = info

    self:onRewardCheckbox(self.datas)
end

function UICampaignDetailPage:_onCheckBoxGroupClick(group, index)
    if group[index] == self._campaignRewardCheckbox then
        self:onRewardCheckbox(self.datas)
    elseif group[index] == self._campaignRuleCheckbox then
        self:onRuleCheckbox(self.datas)
    end
end

function UICampaignDetailPage:onRewardCheckbox(data)
    self._campaignRuleCheckbox:setSelected(false)
    self._campaignRewardCheckbox:setSelected(true)

    if self._campaignRewardPannel == nil then
        self._campaignRewardPannel = UIElemCampaignRewards.new(self)
        self._anchorNode:addChild(self._campaignRewardPannel)
    end

    self:hideAllPages()
    if data.rewardList ~= nil then
        self._campaignRewardPannel:show(data.rewardList)
    end
end

function UICampaignDetailPage:onRuleCheckbox(data)
    self._campaignRewardCheckbox:setSelected(false)
    self._campaignRuleCheckbox:setSelected(true)

    if self._campaignRulePannel == nil then
        self._campaignRulePannel = UIElemCampaignRule.new(self)
        self._anchorNode:addChild(self._campaignRulePannel)
    end

    self:hideAllPages()
    if data ~= nil then
        self._campaignRulePannel:show(data)
    end
end

function UICampaignDetailPage:hideAllPages()
    if self._campaignRulePannel ~= nil then 
        self._campaignRulePannel:hide() 
    end
    if self._campaignRewardPannel ~= nil then 
        self._campaignRewardPannel:hide()
    end
end

function UICampaignDetailPage:onHide()
end

function UICampaignDetailPage:dispose()
end

function UICampaignDetailPage:_onClose()
    UIManager:getInstance():destroy("UICampaignDetailPage")
end

function UICampaignDetailPage:needBlackMask()
	return true;
end

function UICampaignDetailPage:closeWhenClickMask()
	return false
end

return UICampaignDetailPage;