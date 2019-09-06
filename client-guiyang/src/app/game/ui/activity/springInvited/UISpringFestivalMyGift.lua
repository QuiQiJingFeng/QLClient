local csbPath = "ui/csb/Activity/SpringFestivalInvited/MyGift.csb"
local super = require("app.game.ui.UIBase")

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
----------------------------------------------------------------------------------
-- 单条奖励显示item
-------------------------------------------------------------------------------------
local GiftItem = class("GiftItem")

function GiftItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, GiftItem)
    self:_initialize()
    -- self:retain()
    return self
end

function GiftItem:_initialize()
    self.textTime = seekNodeByName(self, "Text_4", "ccui.Text")
    self.textReward = seekNodeByName(self, "Text_4_0", "ccui.Text")
end

function GiftItem:getData()
    return self._data
end

function GiftItem:setData( applicationInfo )
    self._data = applicationInfo

    self.textTime:setString(self:_convertToDate(applicationInfo.time))

    local count = 0   
    
    if PropReader.getTypeById(applicationInfo.itemId) == "RedPackage" then
        count = applicationInfo.count
    else
        count = math.floor( applicationInfo.count )
    end

    local tlb = {
        id = applicationInfo.itemId,
        count = count
    }

    self.textReward:setString(PropReader.generatePropTxt({tlb}))
end

function GiftItem:_convertToDate(stamp)
    -- body
    return tonumber(os.date("%m",stamp/1000)).."月"..os.date("%d",stamp/1000).."日"
end
----------------------------------------------------------------------------------
local UISpringFestivalMyGift = class("UISpringFestivalMyGift", super, function () return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalMyGift:ctor()
    self._btnClose = nil
    self._reusedHonorList = nil;
end

function UISpringFestivalMyGift:init()
    self._reusedList = nil;
    self._reusedList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_1", "ccui.ListView"), GiftItem)
    self._btnClose = seekNodeByName(self, "Button_1","ccui.Button")

    self._reusedList:setScrollBarEnabled(false)
    self:_registerCallBack()
end

function UISpringFestivalMyGift:_registerCallBack()
    bindEventCallBack(self._btnClose,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
end

function UISpringFestivalMyGift:onShow(content)
    self._data = content
    table.sort(self._data, function (a, b) return a.time > b.time end )
    self._reusedList:deleteAllItems()

    for idx,member in ipairs(self._data) do
        self._reusedList:pushBackItem(member)
    end
end

function UISpringFestivalMyGift:onHide()
    
end

function UISpringFestivalMyGift:_onBtnClose()
    UIManager:getInstance():destroy("UISpringFestivalMyGift");
end

function UISpringFestivalMyGift:needBlackMask()
    return true
end

return UISpringFestivalMyGift