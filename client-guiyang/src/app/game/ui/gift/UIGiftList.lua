local csbPath = "ui/csb/Gift/UIGiftList.csb"
local super = require("app.game.ui.UIBase")

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIGiftList = class("UIGiftList", super, function () return kod.LoadCSBNode(csbPath) end)

-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIGiftInfoItem = class("UIGiftInfoItem")

function UIGiftInfoItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIGiftInfoItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UIGiftInfoItem:_initialize()
    self.rewardsName = seekNodeByName(self, "rewardsName", "ccui.Text")                  -- 奖品名称
    self.rewardsStatus =  seekNodeByName(self, "TextStatus", "ccui.Text")
    self.btnDetail = seekNodeByName(self, "btnDetail", "ccui.Button") 
    self.btnReceive = seekNodeByName(self, "Receive", "ccui.Button") 
    self.rewardIcon = seekNodeByName(self, "RewardIcon", "ccui.ImageView")
end

function UIGiftInfoItem:getData()
    return self._data
end

function UIGiftInfoItem:setData( applicationInfo )
    self._data = applicationInfo

    self.rewardsName:setString(applicationInfo.goods)
    self.rewardsStatus:setString(self:_convertStatus(applicationInfo.status, applicationInfo.time))

    self.btnDetail:setVisible(applicationInfo.status ~= 0)
    game.util.PlayerHeadIconUtil.setIcon(self.rewardIcon, applicationInfo.image, true)

    bindEventCallBack(self.btnDetail, handler(self, self.onBtnDetail), ccui.TouchEventType.ended)
    bindEventCallBack(self.btnReceive, handler(self, self.onBtnReceive), ccui.TouchEventType.ended)
end

function UIGiftInfoItem:onBtnDetail()
    UIManager:getInstance():show("UIGiftDetail", self._data.name, self._data.phone, self._data.address, self._data.logistics, self._data.order)
end

function UIGiftInfoItem:onBtnReceive()
    UIManager:getInstance():show("UIGiftTextField", self._data.goods, self._data.goodUID)
end

function UIGiftInfoItem:_convertStatus(enum, time)
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
-------------------------------------------------------------------------------------
function UIGiftList:ctor()
    self._btnClose = nil
    self._reusedGiftList = nil;

    self._reusedGiftList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_1", "ccui.ListView"), UIGiftInfoItem)
    self._noneText = seekNodeByName(self, "noneText", "ccui.Text")
    self._btnClose = seekNodeByName(self, "Button_X",  "ccui.Button");
    self._reusedGiftList:setScrollBarEnabled(false)
end

function UIGiftList:init()
    self:_registerCallback()
end

function UIGiftList:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
end

function UIGiftList:onShow( ... )
    game.service.GiftService.getInstance():addEventListener("EVENT_GIFT_DRAW", function ()
        game.service.GiftService.getInstance():queryGoods()
    end, self)

    local args = {...}
    self._reusedGiftList:deleteAllItems()
    local data = args[1]
    self._noneText:setVisible(#data == 0)
    for idx,member in ipairs(data) do
        self._reusedGiftList:pushBackItem(member)
    end
end


function UIGiftList:_onClose()
    UIManager:getInstance():destroy("UIGiftList")
end

function UIGiftList:needBlackMask()
	return true;
end

function UIGiftList:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGiftList:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIGiftList