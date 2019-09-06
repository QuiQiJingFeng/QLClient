local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local csbPath = "ui/csb/Mall/UIMallBill.csb"
local UIMallBill = class("UIMallBill", super, function() return kod.LoadCSBNode(csbPath) end)
local Time = kod.util.Time
local STATUS_ENUM = {
    [-2] = "奖品信息：订单异常，请尽快联系在线客服",
    [-1] = "奖品信息：兑换失败，礼券已退还，请重新兑换",
    [0] = "奖品信息：奖品已发放，请您注意查收",
    [1] = "奖品信息：已确认，正在发送中，请耐心等待",
    [2] = "奖品信息：正在等待工作人员确认",
    DONT_SHOW = -999
}

local None_Text = {
    pay = "您暂无任何支出账单，快去兑换奖品吧",
    income = "您暂无任何收入账单，快去赢得礼券吧"
}

function UIMallBill:ctor()
    super.ctor(self)
    self:_init()
    self:setEnable(false)
end

function UIMallBill:_init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._checkBoxGroup = CheckBoxGroup.new({
        seekNodeByName(self, "CheckBox_Pay", "ccui.CheckBox"), -- 支出
       seekNodeByName(self, "CheckBox_Income", "ccui.CheckBox"), -- 收入
    }, handler(self, self._onCheckBoxGroupClick))

    self._listView = ListFactory.get(
    seekNodeByName(self, "ListView", "ccui.ListView"),
    handler(self, self._onListItemInit), handler(self, self._onListItemSetData),
    "UIMallBillList")
    self._listView:setScrollBarEnabled(false)
    seekNodeByName(self, "ListView_1", "ccui.ListView"):setScrollBarEnabled(false)

    self._noneText = seekNodeByName(self, "noneTxt", "ccui.Text")
    self._noneBG = seekNodeByName(self, "LOGO", "ccui.ImageView")
    self:_registerCallback()
end

function UIMallBill:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    require("app.game.util.UIElementUtils"):createMaskLayer(self)
end

function UIMallBill:setEnable(value)
    local name = self:getName()
    self:setVisible(value or false)
end

function UIMallBill:onShow(protocol)
    self:setEnable(true)
    local data = { pay = protocol.pay or {}, income = protocol.income or {} }
    self._cache = {}
    for category, table in pairs(data) do
        local t = {}
        local isIncome = category == "income"
        local reasonFormat = isIncome == true and "恭喜您在%s中获得礼券,祝您好运连连" or "恭喜您兑换%s"
        local reason = "恭喜您在%s中获得礼券, 礼券已经发放到您的账户，祝您好运连连"
        local priceFormat = isIncome == true and "礼券+%s" or "礼券-%s"
        for index, value in pairs(table) do
            t[index] = {
                exchangeTime = self:getFormatDate(value.exchangeTime / 1000),
                goodPrice = string.format(priceFormat, value.goodPrice),
                exchangeReason = string.format(value.exchangeReason == "摇钱树" and reason or reasonFormat, value.exchangeReason),
                status = isIncome == true and STATUS_ENUM.DONT_SHOW or value.status
            }
        end
        self._cache[category] = t
    end
    self._checkBoxGroup:setSelectedIndex(2)
end

--[[    index:
        1 == 支出
        2 == 收入
]]
function UIMallBill:_onCheckBoxGroupClick(group, index, token)
    self._listView:deleteAllItems()
    local category = index == 2 and "income" or "pay"
    local t = self._cache[category] or {}
    for i = #t, 1, -1 do
        self._listView:pushBackItem(t[i])
    end

    if #t == 0 then
        self._noneText:setVisible(true)
        self._noneText:setString(None_Text[category] or "暂无")
    else
        self._noneText:setVisible(false)
    end
    self._noneBG:setVisible(self._noneText:isVisible())
end

function UIMallBill:_onListItemInit(listItem)
    listItem.dateText = seekNodeByName(listItem, "Date_Text", "ccui.Text")
    listItem.priceText = seekNodeByName(listItem, "BMFont_Price", "ccui.TextBMFont")
    listItem.statusText = seekNodeByName(listItem, "Status_Text", "ccui.Text")
    listItem.descriptionText = seekNodeByName(listItem, "Description_Text", "ccui.Text")

    listItem.statusBG = seekNodeByName(listItem, "Status_BG", "ccui.ImageView")
end

function UIMallBill:_onListItemSetData(listItem, value)
    local function getNumFromStr(str)
        local n1 = string.find(str, "+")
        if n1 ~= nil then
            return string.sub(str, n1)
        end
        local n2 = string.find(str, "-")
        if n2 ~= nil then
            return string.sub(str, n2)
        end
        return str
    end
    listItem.dateText:setString(value.exchangeTime)
    listItem.priceText:setString(getNumFromStr(value.goodPrice))
    listItem.descriptionText:setString(value.exchangeReason)
    listItem.statusText:setVisible(value.status ~= STATUS_ENUM.DONT_SHOW)
    listItem.statusBG:setVisible(value.status ~= STATUS_ENUM.DONT_SHOW)

    if value.status ~= STATUS_ENUM.DONT_SHOW then
        listItem.statusText:setString(STATUS_ENUM[value.status] or "")
    end
end


function UIMallBill:getFormatDate(stamp)
    if stamp == nil then return "" end
    local d = Time.time2Date(stamp)
    return string.format("%d月%d日%d:%02d", d.month, d.day, d.hour, d.min)
end

function UIMallBill:_onBtnCloseClick()
    -- self:setEnable(false)
    UIManager:getInstance():destroy(self.class.__cname)
end

function UIMallBill:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

-- function UIMallBill:dispose()
--     self:setEnable(false)
--     self._listView:deleteAllItems()
--     self:removeFromParent()
--     self = nil
-- end

function UIMallBill:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return UIMallBill