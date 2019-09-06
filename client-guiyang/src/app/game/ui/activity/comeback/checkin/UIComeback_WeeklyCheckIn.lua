local ITEM_COUNT = 7
local ITEM_LINE_COUNT = 3
local Array = require("ds.Array")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local csbPath = 'ui/csb/Activity/Comeback/UIComeback_WeeklyCheckIn.csb'
local super = require("app.game.ui.UIBase")
local M = class("UIComeback_WeeklyCheckIn", super, function() return kod.LoadCSBNode(csbPath) end)
function M:init()
    self._itemArr = Array.new()
    self:_initLayoutItems()

    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnRule = seekButton(self, "Button_Rule", handler(self, self._onBtnRuleClicked))
    self._btnInvite = seekButton(self, "Button_Invite", handler(self, self._onBtnInviteClick))

    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    if self._service then
        self._service:addEventListener("EVENT_ACTIVITY_COMEBACK_SIGN_COUNT_SYN", handler(self, self._onEvent), self)
    end
end

function M:onDestroy()
    if self._service then
        self._service:removeEventListenersByTag(self)
    end
end

function M:onShow()
    if self._service then
        for i = 1, self._service:getCheckInMaxSignCount() do
            self:_setItemInfoByIndex(i, self._service:getCheckInRewardBySignCount(i))
        end
    end
end

function M:onHide()
end

function M:_initLayoutItems()
    local container = seekNodeByName(self, "Layout_Items", "ccui.Layout")
    local template = seekNodeByName(container, "Item", "ccui.Layout")
    local tSize = template:getContentSize()
    local start = cc.p(template:getPosition())
    local interval = cc.p(20, 15)
    local item
    for i = 1, ITEM_COUNT do
        if i == 1 then
            item = template
        elseif i == ITEM_COUNT then
            item = seekNodeByName(self, "Item_7", "ccui.Layout")
        else
            item = template:clone()
            container:addChild(item)
            item:setPosition(self:_calcItemPosition(start, interval, tSize, i - 1))
            print(item:getPosition())
        end
        self._itemArr:add({
            layout = item,
            title = seekNodeByName(item, "BMFont_Day", "ccui.TextBMFont"),
            name = seekNodeByName(item, "Text_Name", "ccui.Text"),
            propContainer = seekNodeByName(item, "Layout_Prop_Container", "ccui.Layout"),
            signMask = seekNodeByName(item, "Image_SignMask", "ccui.ImageView")
        })
        bindEventCallBack(item, function() self:_onLayoutItemClicked(i) end, ccui.TouchEventType.ended)
    end
end

-- index: start 0
function M:_calcItemPosition(start, interval, itemSize, index)
    local col = index % ITEM_LINE_COUNT
    local row = math.floor(index / ITEM_LINE_COUNT)
    local x = start.x + col * (interval.x + itemSize.width)
    local y = start.y - row * (interval.y + itemSize.height)
    return cc.p(x, y)
end

function M:_onLayoutItemClicked(index)
    if self._service then
        if self._service:getTodayIsCheckIn() then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请明天再来领取")
        else
            local signedCount = self._service:getSignedCount()
            if signedCount + 1 == index then
                self._service:sendCACBackSignREQ()
            end
        end
    end
end

-- prizeInfo 最后一天才会有的额外奖励
function M:_setItemInfoByIndex(index, info, prizeInfo)
    local item = self._itemArr:get(index)
    if item and info then
        local propInfo = PropReader.getPropById(info.itemId)
        if propInfo then
            local name = self:_buildItemName(info.itemId, info.count, info.time)
            if item.name then
                item.name:setString(name)
            end
            if index ~= ITEM_COUNT then
                PropReader.setIconForNode(item.propContainer, info.itemId)
                item.title:setString("第" .. index .. "天")
            end
        end
        item.layout:setVisible(propInfo ~= nil)
        if prizeInfo and item.name2 then
            local name2 = PropReader.getNameById(prizeInfo.itemId) or ""
            item.name2:setString(name2)
        end
    else
        Macro.assertFalse(false, self.class.__cname .. ", set item info failed! index is " .. index)
    end
end

function M:_buildItemName(itemId, count, time)
    local moneyId = 0x0F000004
    local info = PropReader.getPropById(itemId) or {}
    local name = info.name or ""
    if name ~= "" then
        if time ~= 0 then
            name = name .. "(" .. time .. "天)"
        end
        if count > 1 then
            name = name .. " x" .. count
            if itemId == moneyId then
                name = name .. "元"
            end
        end
    end
    return name
end

function M:_updateSignCount(signCount)
    if signCount == nil or signCount == self._signCount then
        return
    end

    self._signCount = signCount
    for index = 1, ITEM_COUNT, 1 do
        local item = self._itemArr:get(index)
        if item then
            local isSign = index <= self._signCount
            item.layout:setTouchEnabled(not isSign)
            if item.signMask then
                item.signMask:setVisible(isSign)
            elseif index == ITEM_COUNT then
                seekNodeByName(self, "Image_SignMask_7", "ccui.ImageView"):setVisible(isSign)
            end
        end
    end
end

function M:_onBtnCloseClick(sender)
    self:hideSelf()
end

function M:_onBtnRuleClicked(sender)
    UIManager:getInstance():show("UIComeback_Rule", false)
end

function M:_onBtnInviteClick(sender)
    if self._service then
        self._service:comebackShare(false)
    end
end

function M:_onEvent(event)
    if event.name == "EVENT_ACTIVITY_COMEBACK_SIGN_COUNT_SYN" then
        self:_updateSignCount(event.data.signCount or 0)
    end
end

function M:needBlackMask() return true end

return M