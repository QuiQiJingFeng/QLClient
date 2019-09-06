--[[
    @desc: 新版比赛报名页面子页面 详情
    author:{贺逸}
    time:2018-06-15
    return
]]
local csbPath = "ui/csb/Campaign/campaignHall/UICampaignDetail.csb"
local super = require("app.game.ui.UIBase")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local PropTextConvertor = game.util.PropTextConvertor
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local ScrollText = require("app.game.util.ScrollText")

-- 单条比赛显示item
----------------------------------------------------------------------
local UICampaignRewardItem = class("UICampaignInfoItem")

function UICampaignRewardItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UICampaignRewardItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UICampaignRewardItem:_initialize()
    -- body
    self._rank = seekNodeByName(self, "Text_1", "ccui.Text")          -- 奖品Icon
    self._reward   = seekNodeByName(self, "Text_1_0", "ccui.Text")             -- 奖品Icon
end

function UICampaignRewardItem:getData()
    return self._data
end

-- 整体设置数据
function UICampaignRewardItem:setData (applicationInfo)
    self._data = applicationInfo
    self._rank:setString("第" .. applicationInfo.value .. "名")
    self._reward:setString(PropTextConvertor.genItemsNameWithOperator(applicationInfo.item," + "))
end

local UICampaignDetail = class("UICampaignDetail", super, function() return kod.LoadCSBNode(csbPath) end)

function UICampaignDetail:ctor()
    self._btnClose = nil
    self._ruleList = nil
    self._campaignName = nil

    self._rulePanel = nil
    self._rewardList = nil
    self._ruleText = nil

    self._ruleCB = nil
    self._rewardCB = nil

    self._pagesCbGroup = nil --切页
end

function UICampaignDetail:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._ruleList = seekNodeByName(self, "ListView_reward", "ccui.Button")
    self._campaignName = seekNodeByName(self, "BitmapFontLabel_campaignName", "ccui.TextBMFont")

    self._rulePanel = seekNodeByName(self, "Panel_rule", "ccui.Layout")
    self._rewardList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_reward", "ccui.ListView"), UICampaignRewardItem)
    self._rewardList:setScrollBarEnabled(false)

    self._ruleScroll = seekNodeByName(self, "ScrollView_1", "ccui.ScrollView")
    
    self._ruleCB = seekNodeByName(self, "CheckBox_rule", "ccui.CheckBox")
    self._rewardCB = seekNodeByName(self, "CheckBox_reward", "ccui.CheckBox")

    self._ruleText = seekNodeByName(self, "Text_rule", "ccui.Text")
    -- 解决如果比赛详情超过了一页，超过部分被剪裁的问题
    self._ruleText = ScrollText.new(self._ruleText, 24, true)

    self._pagesCbGroup = CheckBoxGroup.new({
        self._rewardCB,
        self._ruleCB
    },handler(self,self._onCheckBoxGroupClick))

    self:_registerCallback()
end

function UICampaignDetail:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
end

function UICampaignDetail:onShow( ... )
    local args = { ... }
    local data = args[1]
    local select = args[2]
    
    self._campaignName:setString(data.name)
    local text = string.gsub(data.instructions ,"\\n","\n")
    self._ruleText:setString(text)

    self:_initRewardList(data.rewardList)

    if select == "rewards" then
        self._rewardList:setVisible(true)
        self._ruleCB:setSelected(false)
        self._pagesCbGroup:setSelectedIndex(1)
    elseif select == "rules" then     
        self._rewardList:setVisible(false)
        self._ruleCB:setSelected(true)
        self._pagesCbGroup:setSelectedIndex(2)
    end
end

function UICampaignDetail:_initRewardList( rewardList)
    local list = PropTextConvertor.convertCampaignRewards(rewardList)

    self._rewardList:deleteAllItems()

    for idx,member in ipairs(list) do
        self._rewardList:pushBackItem(member)
    end  
end

function UICampaignDetail:_onCheckBoxGroupClick(group, index)
    if group[index] == self._rewardCB then
        self._rewardList:setVisible(true)
        self._rulePanel:setVisible(false)
    elseif group[index] == self._ruleCB then
        self._rewardList:setVisible(false)
        self._rulePanel:setVisible(true)
    end
end

function UICampaignDetail:_onClose()
    UIManager:getInstance():destroy("UICampaignDetail")
end

function UICampaignDetail:needBlackMask()
	return true;
end

function UICampaignDetail:closeWhenClickMask()
	return false
end

return UICampaignDetail