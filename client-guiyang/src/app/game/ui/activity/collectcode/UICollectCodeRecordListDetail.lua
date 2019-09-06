local LevelTextures = {
    [1] = "art/activity/CollectCode/img_jm_39.png",
    [2] = "art/activity/CollectCode/img_jm_38.png",
    [3] = "art/activity/CollectCode/img_jm_40.png",
}

local Num2ZHChar = {
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
    [7] = "七",
}
-- 中奖详情
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeRecordListDetail.csb'
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local Array = require("ds.Array")
local UICollectCodeRecordListDetail = super.buildUIClass("UICollectCodeRecordListDetail", csbPath)
function UICollectCodeRecordListDetail:init()
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._listViewDetail = ReusedListViewFactory.get(seekNodeByName(self, "ListView", "ccui.ListView"),
    handler(self, self._onDetailListItemInit),
    handler(self, self._onDetailListItemSetData))
    self._listViewDetail:setScrollBarEnabled(true)

    self._noneText = seekNodeByName(self, "None_Text")
end

function UICollectCodeRecordListDetail:onShow(playerInfo)
    UtilsFunctions.resetListViewData(self._listViewDetail, playerInfo)
    self._noneText:setVisible(#playerInfo == 0)
end

function UICollectCodeRecordListDetail:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeRecordListDetail:_onDetailListItemInit(listItem)
    listItem.txtLevel = seekNodeByName(listItem, "Text_Level", "ccui.Text")
    listItem.txtName = seekNodeByName(listItem, "Text_Name", "ccui.Text")
    listItem.txtId = seekNodeByName(listItem, "Text_ID", "ccui.Text")
    listItem.txtReward = seekNodeByName(listItem, "Text_Reward", "ccui.Text")
    listItem.level = seekNodeByName(listItem, "Image_Level", "ccui.ImageView")
    listItem.level.text = seekNodeByName(listItem.level, "Text", "ccui.Text")
end

local function unpackNum(value)
    if type(value) == "number" and value > 0 then
        if value < 10 then
            return { value }
        end
        local ret = {}
        local x = value
        while x >= 10 do
            table.insert(ret, x % 10)
            x = math.floor(x / 10)
        end
        table.insert(ret, x)
        return Array.new(ret):reverse().innerTable
    end
end

function UICollectCodeRecordListDetail:_onDetailListItemSetData(listItem, data)
    local name = kod.util.String.getMaxLenString(data.nickname, 8)
    listItem.txtName:setString(name)
    listItem.txtLevel:setString((Num2ZHChar[data.level] or "") .. "等奖")
    local str = ""
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    if 10002 == areaId or 20001 == areaId then
        -- 贵阳、潮汕 红包
        str = string.format("￥%.1f元", data.count)
    elseif 30001 == areaId then
        -- 内蒙 礼券
        str = string.format("礼券x%.1f", data.count)
    end
    listItem.txtReward:setString(str)
    local t = {}
    local nums = unpackNum(data.roleId)
    -- 显示 xxx***xxx
    if data.roleId >= 10000 and data.roleId <= 99999 then -- 如果id小于5位数 显示 xx***xx
        table.insert(t, nums[1])
        table.insert(t, nums[2])
        table.insert(t, "****")
        table.insert(t, nums[4])
        table.insert(t, nums[5])
    elseif data.roleId >= 100000 then
        table.insert(t, nums[1])
        table.insert(t, nums[2])
        table.insert(t, "****")
        table.insert(t, nums[5])
        table.insert(t, nums[6])
    else
        t = { "****" }
    end
    listItem.txtId:setString("ID: " .. table.concat(t))

    listItem.level:hide()
    local level = data.level
    local levelResPath = LevelTextures[level]
    if levelResPath then
        listItem.level:show()
        listItem.level:loadTexture(levelResPath)
        listItem.level.text:setString(level)
    end
end

function UICollectCodeRecordListDetail:needBlackMask() return true end

return UICollectCodeRecordListDetail