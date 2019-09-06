local csbPath = "ui/csb/Activity/Comeback2/UIComebackBeInvited.csb"
local super = require("app.game.ui.UIBase")

local UIComebackBeInvited = class("UIComebackBeInvited", super, function () return kod.LoadCSBNode(csbPath) end)
-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIComebackRewardItem = class("UIComebackRewardItem")

function UIComebackRewardItem:ctor( uiroot , data, idx)
    self._uiroot = uiroot
    self.idx = idx

    self:_initialize()
    self:setData(data)
end

function UIComebackRewardItem:_initialize()
    self._rewardIcon = seekNodeByName(self._uiroot, "Image_Reward", "ccui.ImageView")
    self._rewardText = seekNodeByName(self._uiroot, "Text_Reward", "ccui.TextBMFont")
    self._btnReward  = seekNodeByName(self._uiroot, "Button_Receive", "ccui.Button")
    self._flagReceive = seekNodeByName(self._uiroot, "hasReceivedFlag", "ccui.ImageView")
    self._examine = seekNodeByName(self._uiroot, "hasReceivedFlag_0", "ccui.ImageView")
    self._scheduleNode = seekNodeByName(self._uiroot, "Image_9", "ccui.ImageView")
    self._scheduleText = seekNodeByName(self._uiroot, "TextSchedule", "ccui.TextBMFont")
    self._outofdata = seekNodeByName(self._uiroot, "TextSchedule", "ccui.TextBMFont")
end

function UIComebackRewardItem:getData()
    return self._data
end

function UIComebackRewardItem:setData( applicationInfo )
    self._data = applicationInfo
    PropReader.setIconForNode(self._rewardIcon,PropReader.getIconById("0x0F000004"))
    self._rewardText:setString(applicationInfo.count .. "元红包")
    if self.idx == 1 then
        self._scheduleText:setString(string.format( "今日完成%s/%s局", applicationInfo.now,applicationInfo.total ))
    elseif self.idx == 2 then
        if applicationInfo.displayToday == true then
            self._scheduleText:setString(string.format( "今日完成%s/%s局", applicationInfo.now,applicationInfo.total ))
        else
            self._scheduleText:setString(string.format( "次日完成%s/%s局", applicationInfo.now,applicationInfo.total ))
        end
    else
        self._scheduleText:setString(string.format( "连续登陆%s/%s天", applicationInfo.now,applicationInfo.total ))
    end
    self._btnReward:setVisible(applicationInfo.status == 1)
    self._flagReceive:setVisible(applicationInfo.status == 2)
    self._scheduleNode:setVisible(applicationInfo.status == 0 or applicationInfo.status == 4 or applicationInfo.status == 5)
    self._examine:setVisible(applicationInfo.status == 3)
    
    if applicationInfo.status == 4 then
        self._scheduleText:setString("已过期")
    elseif applicationInfo.status == 5 then
        self._scheduleText:setString("未通过")
    end

    bindEventCallBack(self._btnReward, handler(self, self._onBtnReward), ccui.TouchEventType.ended)
end

function UIComebackRewardItem:_onBtnReward()
    game.service.ActivityService.getInstance():sendCACQueryPickRewardREQ(2,self.idx)
end
-------------------------------------------------------------------------------------
function UIComebackBeInvited:ctor()
    self._btnClose = nil
    self._btnInvite = nil
    self._rewardList = nil
    self._btnHelp = nil
end

function UIComebackBeInvited:init()
    self._btnClose = seekNodeByName(self, "Button_1_0", "ccui.Button")
    self._btnHelp = seekNodeByName(self, "Button_Help", "ccui.Button")
    self._rewardList = seekNodeByName(self, "ListView_Reward", "ccui.ListView")
    self._panelModel = seekNodeByName(self, "Panel_2", "ccui.Layout")

    self._panelModel:removeFromParent()
    self._panelModel:retain()
    self._panelModel:setVisible(false)

    self:_registerCallback()
end

function UIComebackBeInvited:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
end

function UIComebackBeInvited:onShow( ... )
    local args = { ... }
    self._data = args[1]
    game.service.ActivityService.getInstance():addEventListener("EVENT_WECHAT_SHAREURL_CHANGED", handler(self, self._setQRCodeIcon), self)
    self._rewardList:removeAllItems()
    -- 添加状态
    local first = self._data.rewards[1]
    local second = self._data.rewards[2]

    -- 是今天的话显示的字要不一样...
    for idx,member in ipairs(self._data.rewards) do
        member.displayToday = false
    end

    if first and second and (first.status ~= 0 and first.status ~= 1) then
        second.displayToday = true
    end

    for idx,member in ipairs(self._data.rewards) do
        local item = self._panelModel:clone()
        item:setVisible(true)
        local cell = UIComebackRewardItem.new(item,member,idx)
        self._rewardList:addChild(item)
    end
end

function UIComebackBeInvited:refreshData(data)
    self._data = data
    self._rewardList:removeAllItems()
    -- 添加状态
    local first = self._data.rewards[1]
    local second = self._data.rewards[2]

    -- 是今天的话显示的字要不一样...
    for idx,member in ipairs(self._data.rewards) do
        member.displayToday = false
    end

    if first and second and (first.status ~= 0 and first.status ~= 1) then
        second.displayToday = true
    end

    for idx,member in ipairs(self._data.rewards) do
        local item = self._panelModel:clone()
        item:setVisible(true)
        local cell = UIComebackRewardItem.new(item,member,idx)
        self._rewardList:addChild(item)
    end
end

function UIComebackBeInvited:_onClickHelp()
	-- str = string.format(str, self._rewardInfo[self._currentPageId].gongZhongHao)
	local str = [[
被邀请人奖励：

1.符合条件玩家，返回游戏当天完成8局好友桌牌局，可获得2元红包奖励；        
2.第二天完成8局好友桌牌局，可获得3元红包奖励；        
3.活动期间，玩家连续登录5天，可获得5元红包奖励；        
4.红包奖励可关注微信公众号“聚友互动”，点击“领红包”、“提现”领取红包；        
	]]
	UIManager:getInstance():show('UITurnCardHelp', str)
end

function UIComebackBeInvited:_onClose()
    UIManager:getInstance():destroy("UIComebackBeInvited")
end

function UIComebackBeInvited:needBlackMask()
	return true;
end

function UIComebackBeInvited:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIComebackBeInvited:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIComebackBeInvited