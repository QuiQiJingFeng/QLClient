--[[
背包实物奖励
--]]
local csbPath = "ui/csb/Backpack/UIBackpack_Practicallity.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local super = require("app.game.ui.UIBase")

-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIElemBackpackPracticallityItem = class("UIElemBackpackPracticallityItem")

function UIElemBackpackPracticallityItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemBackpackPracticallityItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UIElemBackpackPracticallityItem:_initialize()
    self.rewardsName = seekNodeByName(self, "rewardsName", "ccui.Text")                  -- 奖品名称
    self.rewardsStatus =  seekNodeByName(self, "TextStatus", "ccui.Text")
    self.btnDetail = seekNodeByName(self, "btnDetail", "ccui.Button") 
    self.btnReceive = seekNodeByName(self, "Receive", "ccui.Button") 
    self.rewardIcon = seekNodeByName(self, "RewardIcon", "ccui.ImageView")
end

function UIElemBackpackPracticallityItem:getData()
    return self._data
end

function UIElemBackpackPracticallityItem:setData( applicationInfo )
    self._data = applicationInfo

    self.rewardsName:setString(applicationInfo.goods)
    self.rewardsStatus:setString(self:_convertStatus(applicationInfo.status, applicationInfo.time))

    self.btnDetail:setVisible(applicationInfo.status ~= 0)
    game.util.PlayerHeadIconUtil.setIcon(self.rewardIcon, applicationInfo.image, true)

    bindEventCallBack(self.btnDetail, handler(self, self.onBtnDetail), ccui.TouchEventType.ended)
    bindEventCallBack(self.btnReceive, handler(self, self.onBtnReceive), ccui.TouchEventType.ended)
end

function UIElemBackpackPracticallityItem:onBtnDetail()
    UIManager:getInstance():show("UIGiftDetail", self._data.name, self._data.phone, self._data.address, self._data.logistics, self._data.order)
end

function UIElemBackpackPracticallityItem:onBtnReceive()
    UIManager:getInstance():show("UIGiftTextField", self._data.goods, self._data.goodUID)
end

function UIElemBackpackPracticallityItem:_convertStatus(enum, time)
    if enum == 0 then 
        return string.format("未领取 %s",os.date("%Y-%m-%d %H:%M",time/1000))
    elseif enum == 1 then
        return string.format("待发货 %s",os.date("%Y-%m-%d %H:%M",time/1000))
    elseif enum == 2 then
        return string.format("已发货 %s",os.date("%Y-%m-%d %H:%M",time/1000))
    else
        return ""
    end
end

----------------------------------------------------------------------
--比赛场历史记录list
local UIElemBackpackPracticallity = class("UIElemBackpackPracticallity", super, function () return cc.CSLoader:createNode(csbPath) end)

function UIElemBackpackPracticallity:ctor(parent)
    self._parent = parent;
    self._reusedParcticallityList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_practicality", "ccui.ListView"), UIElemBackpackPracticallityItem);
    self._imgnone = seekNodeByName(self, "Image_No_0", "ccui.ImageView")
    self._reusedParcticallityList:setScrollBarEnabled(false)
end

function UIElemBackpackPracticallity:show(data)
    self:setVisible(true)
    self._imgnone:setVisible(#data.goodsList == 0)
    self._reusedParcticallityList:deleteAllItems()
    for idx,member in ipairs(data.goodsList) do
        self._reusedParcticallityList:pushBackItem(member)
    end
end

function UIElemBackpackPracticallity:hide()
    self:setVisible(false)
end


return UIElemBackpackPracticallity;