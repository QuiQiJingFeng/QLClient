local csbPath = "ui/csb/Club/UIClubActivityKoi.csb"
local super = require("app.game.ui.UIBase")
local UIItem = require("app.game.ui.element.UIItem")
---@class UIClubActivityKoi:UIBase
local UIClubActivityKoi = class("UIClubActivityKoi", super, function() return kod.LoadCSBNode(csbPath) end)

local STATUS =
{
    "art/activity/Fish/img_wdc_jlhd.png", -- 未达成
    "art/activity/Fish/img_ylc_jlhd.png", -- 已领取
    "art/activity/Fish/img_wks_jlhd.png", -- 未开始
}

function UIClubActivityKoi:ctor()
end

function UIClubActivityKoi:init()
    ---@type Button
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnRule = seekNodeByName(self, "Button_Rule", "ccui.Button")
    ---@type ListView
    self._listViewReward = seekNodeByName(self, "ListView_Reward", "ccui.ListView")
    self._listViewReward:setScrollBarEnabled(false)
    --self._listViewReward:setTouchEnabled(false)
    self._listViewItemBig = ccui.Helper:seekNodeByName(self._listViewReward, "Panel_RewardItem")
    self._listViewItemBig:removeFromParent(false)
    self:addChild(self._listViewItemBig)
    self._listViewItemBig:setVisible(false)

    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRule, handler(self, self._onBtnRuleClick), ccui.TouchEventType.ended)
end

function UIClubActivityKoi:_onBtnCloseClick()
    UIManager:getInstance():destroy("UIClubActivityKoi")
end

function UIClubActivityKoi:_onBtnRuleClick()
    local str = [[活动规则

1.只有被系统选中的锦鲤才能参与这个活动；

2.连续5天，每一天比前一天多打20局，均可以领取奖励；

3.完成任务后，后续可能触发奖励更加丰厚的活动。
    ]]
    UIManager:getInstance():show("UIClubActivityDescription", str)
end

function UIClubActivityKoi:onShow(awards)
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CLUB_KOI)
    self._time = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    self:_initAwardRecord(awards)
end

function UIClubActivityKoi:_initAwardRecord(awards)
    self._listViewReward:removeAllChildren()
    for _, award in ipairs(awards.awardRecords) do
        local node = self._listViewItemBig:clone()
        self._listViewReward:addChild(node)
        node:setVisible(true)

        local panelNode = ccui.Helper:seekNodeByName(node, "Panel_Node")
        local textName = ccui.Helper:seekNodeByName(node, "Text_Name")
        ---@type ImageView
        local imgStatus = ccui.Helper:seekNodeByName(node, "Image_Status")
        local btnReceive = ccui.Helper:seekNodeByName(node, "Button_Receive")
        local testConut = ccui.Helper:seekNodeByName(node, "Text_Conut")
        local testTime = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_Time")
        testTime:setString(tostring(award.index + 1))
        if award.hasPicked then
            btnReceive:setVisible(false)
            imgStatus:setVisible(true)
            imgStatus:loadTexture(STATUS[2])
        else
            if award.curRoundCount >= award.needRoundCount and self._time >= award.canPickTime then
                btnReceive:setVisible(true)
                imgStatus:setVisible(false)
            else
                btnReceive:setVisible(false)
                imgStatus:setVisible(true)
                imgStatus:loadTexture(STATUS[1])
            end
        end
        testConut:setString(string.format("%s/%s", award.curRoundCount, award.needRoundCount))
        UIItem.extend(panelNode, textName, award.awardItemId, award.awardItemCount, award.awardItemTime)
        bindEventCallBack(btnReceive, function ()
            self._service:sendCACPickKoiFishActivityAwardREQ(
                {
                    area = self._service:getAreaId(),
                    index = award.index
                }
            )
        end, ccui.TouchEventType.ended)
    end
end

function UIClubActivityKoi:onHide()
end

function UIClubActivityKoi:onDestroy()
end

function UIClubActivityKoi:needBlackMask()
    return true
end

function UIClubActivityKoi:closeWhenClickMask()
    return false
end

function UIClubActivityKoi:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIClubActivityKoi