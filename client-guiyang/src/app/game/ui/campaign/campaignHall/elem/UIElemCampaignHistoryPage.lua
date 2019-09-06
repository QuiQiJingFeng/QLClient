--[[
比赛历史记录子页面
--]]
local csbPath = "ui/csb/Campaign/campaignHall/elem/UIBattlehistory.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UIRichTextEx = require("app.game.util.UIRichTextEx")
local super = require("app.game.ui.UIBase")

local CAMPAIGN_RECEIVE = 
{
    RECEIVED = 0,
    NOTRECEIVED = 1
}

-- 单条比赛战绩显示
----------------------------------------------------------------------
local UICampaignRecordItem = class("UICampaignRecordItem")

function UICampaignRecordItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UICampaignRecordItem)
    self:_initialize()
    return self
end

function UICampaignRecordItem:_initialize()
    -- body
    self._timeText =  seekNodeByName(self, "Text_jl_link_Battlehistory", "ccui.Text")                  -- 获奖时间
    self._gameName = seekNodeByName(self, "BitmapFontLabel_gameName", "ccui.TextBMFont")               -- 比赛名称
    self._ranking = seekNodeByName(self, "BitmapFontLabel_ranking", "ccui.TextBMFont")                 -- 比赛名次
    self._reward = seekNodeByName(self, "BitmapFontLabel_reward", "ccui.TextBMFont")                  -- 比赛奖励
    self._shareBtn =  seekNodeByName(self, "Button_bm_link_Battlehistory", "ccui.Button")              -- 分享按钮
    self._shareToReceive = seekNodeByName(self, "Button_bm_link_Battlehistory_0", "ccui.Button")       -- 分享领取按钮
end

function UICampaignRecordItem:getData()
    return self._data
end

-- 整体设置数据
function UICampaignRecordItem:setData (applicationInfo)
    self._data = applicationInfo
    self._gameName:setVisible(true)
    self._ranking:setVisible(true)
    self._reward:setVisible(true)
    if applicationInfo.isGiveUp == true then
        self._timeText:setString(self:_convertToData(applicationInfo.createTimestamp).. " ".. self:_convertToTime(applicationInfo.createTimestamp))
        self._gameName:setString(applicationInfo.name)
        self._reward:setVisible(false)
        self._shareBtn:setVisible(false)
        self._ranking:setString("退赛")
    elseif #applicationInfo.item == 0 then
        self._timeText:setString(self:_convertToData(applicationInfo.createTimestamp).. " ".. self:_convertToTime(applicationInfo.createTimestamp))
        self._gameName:setString(applicationInfo.name)
        self._ranking:setString(string.format("第%s名", applicationInfo.rank))
        self._reward:setString("没有奖励，再接再厉！")
        self._shareBtn:setVisible(true)
    else
        local rewardTxt = ""
        rewardTxt = self:generateReward(applicationInfo.item)
        self._timeText:setString(self:_convertToData(applicationInfo.createTimestamp).. " ".. self:_convertToTime(applicationInfo.createTimestamp))
        self._gameName:setString(applicationInfo.name)
        self._ranking:setString(string.format("第%s名", applicationInfo.rank))
        self._reward:setString(string.format("奖励：%s", rewardTxt))
        self._shareBtn:setVisible(true)
    end
    self._shareToReceive:setVisible(applicationInfo.status == CAMPAIGN_RECEIVE.NOTRECEIVED)


    bindEventCallBack(self._shareBtn, handler(self, self.showRewards), ccui.TouchEventType.ended)
    bindEventCallBack(self._shareToReceive, handler(self, self.shareToReceive), ccui.TouchEventType.ended)
end

function UICampaignRecordItem:generateReward(param)
    local rewardTxt = ""

    if param.item ~= "" then
        rewardTxt = rewardTxt .. PropReader.generatePropTxt(param)
    end

    return rewardTxt
end

function UICampaignRecordItem:_convertToTime(stamp)
    -- body
    return os.date("%H:%M",stamp/1000)
end

function UICampaignRecordItem:_convertToData(stamp)
    -- body
    return os.date("%m",stamp/1000).."月"..os.date("%d",stamp/1000).."日"
end

function UICampaignRecordItem:showRewards()
    -- service完成后改为发事件弹出detail
    local data = {result= self._data}
    local ui = UIManager:getInstance():show("UICampaignResults",data,"history")

    -- 统计点击比赛场按钮点击炫耀的次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Flaunt);
end

function UICampaignRecordItem:shareToReceive()
    -- service完成后改为发事件弹出detail
    local data = {result= self._data}
    local ui = UIManager:getInstance():show("UICampaignResults",data,"history")

    -- 统计点击比赛场按钮点击炫耀的次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_ShareReward);
end
----------------------------------------------------------------------
--比赛场历史记录list
local UIElemCampaignHistoryPage = class("UIElemCampaignHistoryPage", super, function () return cc.CSLoader:createNode(csbPath) end)

function UIElemCampaignHistoryPage:ctor(parent)
    self._parent = parent;
    self._reusedCampaignHistoryList = nil;

    self._reusedCampaignHistoryList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_Battlehistory", "ccui.ListView"), UICampaignRecordItem)
    self._reusedCampaignHistoryList:setScrollBarEnabled(false)
    self._noneText = seekNodeByName(self, "noneTxt", "ccui.Text")
end

function UIElemCampaignHistoryPage:show(data)
    if self._parent.class.__cname ~= "UICampaignHistory_Club" then
        self._parent._btnRewards:setVisible(false)
        self._parent._addCard:setVisible(false)
        self._parent._addTicket:setVisible(false)
        self._parent._addBean:setVisible(false)
        self._parent._title:setString("参赛记录")
        self._parent._ticketBackpack:setVisible(false)
    end         

    self:setVisible(true)
    self:_onCampaignHistoryReceived(data)
end

function UIElemCampaignHistoryPage:hide()
    -- body    
    if self._parent.class.__cname ~= "UICampaignHistory_Club" then
        self._parent._title:setString("比赛场")
        self._parent._btnRewards:setVisible(true)   
        self._parent._addCard:setVisible(true)
        self._parent._addTicket:setVisible(true)
        self._parent._ticketBackpack:setVisible(true)
        self._parent._addBean:setVisible(true)
    end
    self:setVisible(false)
    game.service.CampaignService.getInstance():removeEventListenersByTag(self);
end

function UIElemCampaignHistoryPage:_onCampaignHistoryReceived( data )
    --更新List中的数据
    self._reusedCampaignHistoryList:deleteAllItems()

    self._noneText:getParent():setVisible(#data == 0)
    -- 排序
    table.sort(data, function (a,b)
        if a.status == CAMPAIGN_RECEIVE.RECEIVED and b.status == CAMPAIGN_RECEIVE.RECEIVED then
            return a.createTimestamp > b.createTimestamp
        end

        if a.status == CAMPAIGN_RECEIVE.RECEIVED then
            return false
        elseif b.status == CAMPAIGN_RECEIVE.RECEIVED then
            return true
        end
        return a.createTimestamp > b.createTimestamp
    end)

    --添加数据
    for idx,member in ipairs(data) do
        self._reusedCampaignHistoryList:pushBackItem(member)
    end
end

return UIElemCampaignHistoryPage;
