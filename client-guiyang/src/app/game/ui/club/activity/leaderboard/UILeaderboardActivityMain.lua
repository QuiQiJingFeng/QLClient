local csbPath = "ui/csb/Club/UILeaderboardActivityMain.csb"
local super = require("app.game.ui.UIBase")

--[[
    俱乐部排行榜活动
]]

local ACTIVITY_TYPE =
{
    {name = "今\n日\n排\n行\n榜", ui = "UILeaderboardActivityToday", isVisible = true, id = 1},
    {name = "总\n排\n行\n榜", ui = "UILeaderboardActivityToday", isVisible = true, id = 2},
}

-- string.format("活动时间:%s - %s", os.date("%Y.%m.%d", startTime / 1000), os.date("%Y.%m.%d", endTime / 1000))

local M = class("UILeaderboardActivityMain", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    self._btnCheckList = {}
    self._textColor = {}
    self._uiElemList = {}
    self._showUiId = 0
    self._weChat = 0
end

function M:init()
    self._listMessage = seekNodeByName(self, "ListView_Activity_Type", "ccui.ListView")
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listMessage, "CheckBox_type")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)
    self._listMessage:setTouchEnabled(false)
    
    self._node = seekNodeByName(self, "Panel_node", "ccui.Layout")

    self._btnReward_Manager = seekNodeByName(self, "Button_Reward_Manager", "ccui.Button") -- 经理奖励
    self._btnReward_Member = seekNodeByName(self, "Button_Reward_Member", "ccui.Button") -- 成员奖励
    self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button") -- 退出
    self._btnHelp = seekNodeByName(self, "Button_help", "ccui.Button") -- 帮助
    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text") -- 提示
    self._btnCopy = seekNodeByName(self, "Button_copy", "ccui.Button") -- 复制

    self._btnRedDot_Member = seekNodeByName(self, "Image_RedDotMember", "ccui.ImageView")
    self._btnRedDot_Manager = seekNodeByName(self, "Image_RedDotManager", "ccui.ImageView")

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnReward_Manager, handler(self, self._onBtnRewardManagerClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnReward_Member, handler(self, self._onBtnRewardMemberClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onBtnHelpClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCopy, handler(self, self._onBtnCopyClick), ccui.TouchEventType.ended)

    -- 监听红点树的消息
    game.service.LocalPlayerService:getInstance():addEventListener("EVENT_RED_DOT_CHANGE", handler(self, self._changeRedDot), self)
    self:_changeRedDot()
end

function M:_changeRedDot()
    local redDotStateTreeManager = manager.RedDotStateTreeManager.getInstance()
    local redDotKey = redDotStateTreeManager:getRedDotKey()
    self._btnRedDot_Member:setVisible(redDotStateTreeManager:isVisible(redDotKey.CLUB_RANK_MEMBER_REWARD))
    self._btnRedDot_Manager:setVisible(redDotStateTreeManager:isVisible(redDotKey.CLUB_RANK_MANGER_REWARD))
end

-- 复制
function M:_onBtnCopyClick()
    if game.plugin.Runtime.setClipboard(self._weChat) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end	
end

-- 退出
function M:_onBtnQuitClick()
    UIManager:getInstance():hide("UILeaderboardActivityMain")
end

-- 领取经理奖励
function M:_onBtnRewardManagerClick()
    UIManager:getInstance():show("UIClubRewardCollection", 1)
end

-- 领取成员奖励
function M:_onBtnRewardMemberClick()
    UIManager:getInstance():show("UIClubRewardCollection", 2)
end

-- 帮助
function M:_onBtnHelpClick()
    local public = MultiArea.getNoPublic(game.service.LocalPlayerService:getInstance():getArea())
    local str = string.format([[1.活动时间：
    12.17-12.21
 2.排名：
    新老亲友圈成员均可通过完成完整牌局获得积分来参与该活动；
    提前解散的牌局不计入排行榜积分；
    若有亲友圈积分相同，则先达到该积分的俱乐部排名靠前；
 3.奖励：
    群主奖励与成员奖励、日排行榜奖励与总排行榜奖励。排名在每日0点进行结算；
    群主奖励仅创建亲友圈的群主可领取，成员需当天在对应亲友圈内打牌可领取奖励；
    日排行榜奖励统计当天24小时内的对局，总排行榜统计活动期间的所有完整对局；
 4.领奖：
    活动在12月21日结束，活动界面会保留至12月22日，请在12月22日领取总榜奖励；
    所有奖励请您在次日确认领取，隔日未领取的奖励将无法领取，还请及时领取活动奖励；
    红包奖励请在更新游戏后，前往公众号“%s”提现；
    如有疑问，请添加公众号“%s”，点击游戏中心，联系客服人员；]], public, public)
    UIManager:getInstance():show("UIClubActivityDescription", str)
end

function M:onShow()
    self._weChat = MultiArea.getNoPublic(game.service.LocalPlayerService:getInstance():getArea())
    self._textTips:setString(string.format("奖励请在次日领取,隔日奖励将无法领取;详情请添加公众号:%s,联系客服;", self._weChat))
    self:_initMessageList()
end

function M:_initMessageList()
    -- 清空列表
    self._listMessage:removeAllChildren()
    self._btnCheckList = {}
    self._textColor = {}

    for k, v in ipairs(ACTIVITY_TYPE) do
        if v.isVisible then
            self:_initMessageItem(v)
        end
    end

    -- 默认显示第一个为true的界面
    for k, v in ipairs(ACTIVITY_TYPE) do
        if v.isVisible then
            self:_onItemTypeClicked(v)
            return
        end
    end
end

function M:_initMessageItem(itemInfo)
    local checkBox = self._listviewItemBig:clone()
    self._listMessage:addChild(checkBox)
    checkBox:setVisible(true)
    -- item名称
    local textType = ccui.Helper:seekNodeByName(checkBox, "Text_activityName")
    textType:setString(itemInfo.name)

    local isSelected = false
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then	
            self:_onItemTypeClicked(itemInfo)
            checkBox:setSelected(true)
            game.service.DataEyeService.getInstance():onEvent(itemInfo.ui)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)
    self._btnCheckList[itemInfo.id] = checkBox
    self._textColor[itemInfo.id] = textType
end

function M:_onItemTypeClicked(itemInfo)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == itemInfo.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
    end
    
    -- 改变字体颜色
    for k,v in pairs(self._textColor) do
        if k == itemInfo.id then
            v:setColor(cc.c3b(182, 115, 56))
        else
            v:setColor(cc.c3b(255, 244, 199))
        end
    end

    if self._showUiId == itemInfo.id then
        return
    end

    -- 创建对应的界面
    if self._uiElemList[itemInfo.id] == nil then
        local clz = require("app.game.ui.club.activity.leaderboard." .. itemInfo.ui)
        local ui = clz.new(self)
        self._uiElemList[itemInfo.id] = ui
        self._node:addChild(ui)
    end

    self._showUiId = itemInfo.id

    self:_hideAllPages()
    self._uiElemList[itemInfo.id]:show(itemInfo.id)
end

function M:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function M:onHide()
    self:_hideAllPages()
    self._btnCheckList = {}
    self._textColor = {}
    self._uiElemList = {}
    self._showUiId = 0
    self._listMessage:removeAllChildren()
    game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
end

function M:needBlackMask()
    return true
end

function M:closeWhenClickMask()
    return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return M