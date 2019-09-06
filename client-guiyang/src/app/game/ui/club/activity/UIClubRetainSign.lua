local csbPath = "ui/csb/Club/UIClubRetainSign.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIItem = require("app.game.ui.element.UIItem")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubRetainSign = class("UIClubRetainSign", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRetainSign:ctor()
    
end

function UIClubRetainSign:init()
    self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button")

    self._listRetain = ListFactory.get(
        seekNodeByName(self, "ListView_Retain", "ccui.ListView"),
        handler(self, self._onListRetainInit),
        handler(self, self._onListRetainSetData)
    )

    self._listRetain:setScrollBarEnabled(false)
    self._listRetain:setTouchEnabled(false)

    self._panelReceived = seekNodeByName(self, "Panel_ylq_Retain", "ccui.Layout") -- 已领取状态
    self._imgReceived_NextDay = seekNodeByName(self, "Image_Tomorrow1", "ccui.ImageView") -- 次日领取状态
    self._imgSelected = seekNodeByName(self, "Image_selected", "ccui.ImageView") -- 选中状态
    self._imgNotSelected = seekNodeByName(self, "Image_notSelected", "ccui.ImageView") -- 未选中状态
    self._day = seekNodeByName(self, "Text_seven", "ccui.Text")
    self._btnReceive = seekNodeByName(self, "Button_receive", "ccui.Button") -- 领取
    self._imgNotReceive = seekNodeByName(self, "Image_ylq1", "ccui.ImageView") -- 未领取

    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")
    
    bindEventCallBack(self._btnQuit, handler(self, self._onClickQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnReceive, function()
        self:_sendCACPickClubWeekSignRewardREQ(self._info[7].day)
    end, ccui.TouchEventType.ended)
end

function UIClubRetainSign:_onClickQuit()
    UIManager:getInstance():hide("UIClubRetainSign")
end

function UIClubRetainSign:_onListRetainInit(listItem)
    listItem._panelNode = ccui.Helper:seekNodeByName(listItem, "Panel_node")
    listItem._textName = ccui.Helper:seekNodeByName(listItem, "Text_Name")
end

function UIClubRetainSign:_onListRetainSetData(listItem, data)
    UIItem.extend(listItem._panelNode, listItem._textName, data.itemId, data.count, data.time)
end

function UIClubRetainSign:onShow(protocol)
    self._textTips:setString(string.format("每日进入%s均可领取奖励，第七天即可领取专属礼包！", config.STRING.COMMON))
    self._info = clone(protocol.signInfos)
    self._startTime = game.service.TimeService:getInstance():getStartTime() * 1000
    self._endTime = game.service.TimeService:getInstance():getEndTime() * 1000
    self._nextDayTime = self._endTime + 24 * 60 *60 * 1000
    
    self:_workingDayInit()
    self:_initListViewItem()
end

function UIClubRetainSign:_workingDayInit(listItem)
    for i = 1, 6 do
        local node = seekNodeByName(self, string.format("Panel_panel%d", i), "ccui.Layout")
        local imgSelected = ccui.Helper:seekNodeByName(node, "Image_bg2") -- 选中状态
        local imgNotSelected = ccui.Helper:seekNodeByName(node, "Image_bg1") -- 未选中状态
        local textDay = ccui.Helper:seekNodeByName(node, "Text_day") -- 第几天
        local panelNode = ccui.Helper:seekNodeByName(node, "Panel_node") -- 商品
        local textName = ccui.Helper:seekNodeByName(node, "Text_name") -- 商品名称
        local panelReceived = ccui.Helper:seekNodeByName(node, "Panel_received") -- 已领取状态
        local imgReceived_NextDay = ccui.Helper:seekNodeByName(node, "Image_received_nextDay") -- 次日领取状态
        local btnReceive = ccui.Helper:seekNodeByName(node, "Button_receive") -- 领取
        local imgNotReceive = ccui.Helper:seekNodeByName(node, "Image_ylq1") -- 标识

        local isVisible = self._info[i].vaildDate >= self._startTime and  self._info[i].vaildDate <= self._endTime and self._info[i].status == 0
        imgSelected:setVisible(isVisible)
        btnReceive:setVisible(isVisible)
        panelReceived:setVisible(self._info[i].vaildDate <= self._endTime and not isVisible)
        imgNotReceive:loadTexture(self._info[i].status == 1 and "art/club4/img_retainylq.png" or "art/club4/img_retainwlq.png")
        bindEventCallBack(btnReceive, function()
            self:_sendCACPickClubWeekSignRewardREQ(self._info[i].day)
        end, ccui.TouchEventType.ended)
        imgReceived_NextDay:setVisible(self._info[i].vaildDate > self._endTime and self._info[i].vaildDate <= self._nextDayTime)
        textDay:setString(string.format("第%d天", self._info[i].day))
        UIItem.extend(panelNode, textName, self._info[i].rewardItems[1].itemId, self._info[i].rewardItems[1].count, self._info[i].rewardItems[1].time) 
    end
end

function UIClubRetainSign:_initListViewItem()
    self._listRetain:deleteAllItems()
    self._day:setString(string.format("第%d天", self._info[7].day))
    local isVisible = self._info[7].vaildDate >= self._startTime and  self._info[7].vaildDate <= self._endTime and self._info[7].status == 0
    self._imgSelected:setVisible(isVisible)
    self._btnReceive:setVisible(isVisible)
    self._panelReceived:setVisible(self._info[7].vaildDate <= self._endTime and not isVisible)
    self._imgNotReceive:loadTexture(self._info[7].status == 1 and "art/club4/img_retainylq.png" or "art/club4/img_retainwlq.png")

    self._imgReceived_NextDay:setVisible(self._info[7].vaildDate > self._endTime and self._info[7].vaildDate <= self._nextDayTime)

    for i = 1, #self._info[7].rewardItems do
        self._listRetain:pushBackItem(self._info[7].rewardItems[i])
    end

    self._listRetain:requestDoLayout()
    self._listRetain:doLayout()
end

function UIClubRetainSign:_sendCACPickClubWeekSignRewardREQ(day)
    local weekSignActivity = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CLUB_WEEK_SIGN)
    weekSignActivity:sendCACPickClubWeekSignRewardREQ(day)
end

function UIClubRetainSign:onHide()
end

function UIClubRetainSign:needBlackMask()
    return true
end

function UIClubRetainSign:closeWhenClickMask()
    return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRetainSign:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

return UIClubRetainSign