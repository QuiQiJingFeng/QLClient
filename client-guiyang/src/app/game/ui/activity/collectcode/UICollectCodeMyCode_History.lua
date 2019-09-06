local RewardLevel = {
    -- 贵阳
    [10002] = {
        2888, 888, 188, 18, 5, 2, 1,
    },
    -- 潮汕
    [20001] = {
        168.8, 88.8, 56.8, 28.8, 10.8, 5.68, 1.68, 0.88, 0.58, 0.18,
    },
    -- 内蒙
    [30001] = {
        18800, 8800, 5880, 880, 300, 30,
    }
}


local LevelTextures = {
    [1] = "art/activity/CollectCode/img_jm_39.png",
    [2] = "art/activity/CollectCode/img_jm_38.png",
    [3] = "art/activity/CollectCode/img_jm_40.png",
    [4] = "art/activity/CollectCode/img_jm_40.png",
    [5] = "art/activity/CollectCode/img_jm_40.png",
    [6] = "art/activity/CollectCode/img_jm_40.png",
    [7] = "art/activity/CollectCode/img_jm_40.png",
    [8] = "art/activity/CollectCode/img_jm_40.png",
    [9] = "art/activity/CollectCode/img_jm_40.png",
    [10] = "art/activity/CollectCode/img_jm_40.png",
}

local function getRewardLevelByCount(count)
    count = tonumber(count)
    local ret = 99
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local levels = RewardLevel[areaId]
    if levels then
        for level, cnt in ipairs(levels) do
            if count >= cnt then
                return level
            end
        end
    end
    return ret
end
--[[0
    这个 UI 处理两个界面
    1、 本期的幸运码
    2、 历史记录的幸运码
]]
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeMyCode_History.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local bindClick = UtilsFunctions.bindClick
local CodeSet = require("app.game.ui.activity.collectcode.CodeSet")
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local UICollectCodeMyCode_History = super.buildUIClass("UICollectCodeMyCode_History", csbPath)
function UICollectCodeMyCode_History:init()
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnGetAll = seekButton(self, "Button_Get_All", handler(self, self._onBtnGetAllClick))
    self._textRule = seekNodeByName(self, "Text_Rule", "ccui.Text")
    bindClick(self._textRule, handler(self, function()
        UIManager:getInstance():show("UICollectCodeHelp", true)
    end))

    self._currentCodeSet = CodeSet.new(seekNodeByName(self, "Layout_Current_Code", "ccui.Layout"))
    self._obtainStatusText = seekNodeByName(self, "Text_My_Code_Title", "ccui.Text")
    self._obtainListView = ReusedListViewFactory.get(seekNodeByName(self, "ListView_Code", "ccui.ListView"),
    handler(self, self._onObtainListItemInit),
    handler(self, self._onObtainListItemSetData))

    self._recordListView = ReusedListViewFactory.get(seekNodeByName(self, "ListView_Record", "ccui.ListView"),
    handler(self, self._onRecordListItemInit),
    handler(self, self._onRecordListItemSetData))
    -- self._recordListView:setClippingEnabled(false)
    self._currentShowStage = nil -- 当前显示的场景  history | current
    self._currentShowPeriod = 0 -- 当前显示的是第几期的数据
    self._cache = nil
    self._cboxGroup = CheckBoxGroup.new({}, handler(self, self._onCheckBoxSelected))
end

-- todo 之后优化下 抽下出一个数据结构， 从各个场景 取值到统一的数据结构赋值
function UICollectCodeMyCode_History:onShow(showStage, buffer)
    self._cache = buffer
    self._currentShowStage = showStage
    if showStage == "history" then
        local periods = {}
        for i, info in ipairs(buffer.record) do
            -- 最后一期的不展示
            if not self._service:isFinalPeriod(info.period) then
                table.insert(periods, { period = info.period })
            end
        end
        self._recordListView:show()
        UtilsFunctions.resetListViewData(self._recordListView, periods)
        if #periods >= 1 then
            self._cboxGroup:setSelectedIndex(1)
        end
        self._obtainStatusText:setString("已获得0组幸运码")
    elseif showStage == "current" then
        self._currentShowPeriod = self._service:getCollectCodeInfo().period -- 这个显示的其实是上一期的，需要加1
        self._recordListView:hide()
        self._currentCodeSet:setCodes(self._service:convertToCodeArray(self._service:getCollectCodeInfo().luckyCode))
        UtilsFunctions.resetListViewData(self._obtainListView, self:_sortCodeByStatus(self._cache.codes))
        self._obtainStatusText:setString("已获得" .. #self._cache.codes .. "组幸运码")
    end
end

function UICollectCodeMyCode_History:_sortCodeByStatus(codes)
    -- table.sort 不好做
    local sortDataArr = { {}, {}, {} }
    for idx, data in ipairs(codes) do
        if data.status == 1 then -- 未中奖
            table.insert(sortDataArr[3], data)
        elseif data.status == 2 then -- 中奖未领取
            table.insert(sortDataArr[1], data)
        elseif data.status == 3 then -- 已领取
            table.insert(sortDataArr[2], data)
        end
        data.codeId = idx
    end
    local sortData = {}
    for _, arr in ipairs(sortDataArr) do
        table.sort(arr, function(a, b)
            return tonumber(a.count) > tonumber(b.count)
        end)
        table.insertto(sortData, arr)
    end
    return sortData
end

function UICollectCodeMyCode_History:onHide()
    if self._cboxGroup then
        self._cboxGroup:dispose()
    end
    self._cboxGroup = CheckBoxGroup.new({}, handler(self, self._onCheckBoxSelected))
end

function UICollectCodeMyCode_History:_onRecordListItemInit(listItem)
    self._cboxGroup:append(listItem)
    listItem.text = seekNodeByName(listItem, "Text", "ccui.Text")
end

function UICollectCodeMyCode_History:_onRecordListItemSetData(listItem, data)
    listItem.text:setString("第" .. data.period + 1 .. "期")
    -- print(data.period, self._currentShowPeriod)
    listItem:setSelected(data.period == self._currentShowPeriod)
    listItem.period = data.period
end

function UICollectCodeMyCode_History:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeMyCode_History:_onBtnPeriodClick(index)
    if self._cache then
        local info = self._cache.record[index]
        if info then
            self._currentShowPeriod = info.period
            self:setCodeInfo(info)
        else
            Macro.assertFalse(false, index .. " index info is nil")
            self:hideSelf()
        end
    end
end

function UICollectCodeMyCode_History:setCodeInfo(codeInfo)
    self._currentCodeSet:setCodes(self._service:convertToCodeArray(codeInfo.luckyCode))
    self._obtainStatusText:setString("已获得" .. #codeInfo.codes .. "组幸运码")
    UtilsFunctions.resetListViewData(self._obtainListView, self:_sortCodeByStatus(codeInfo.codes))
end

function UICollectCodeMyCode_History:_onObtainListItemInit(listItem)
    listItem.codeSet = CodeSet.new(listItem)
    listItem.btnRecv = seekNodeByName(listItem, "Button_Recv", "ccui.Button")
    listItem.btnRecv.text = seekNodeByName(listItem.btnRecv, "BMFont", "ccui.Text")
    -- listItem.btnRecv.icon = seekNodeByName(listItem.btnRecv, "Icon", "ccui.ImageView")
    listItem.txtRecved = seekNodeByName(listItem, "Text_Recved", "ccui.Text")
    listItem.level = seekNodeByName(listItem, "Image_Level", "ccui.ImageView")
    listItem.level.text = seekNodeByName(listItem.level, "Text", "ccui.Text")
end

function UICollectCodeMyCode_History:_onObtainListItemSetData(listItem, data)
    local str = PropReader.generatePropTxt({ data }, "", "")
    listItem.codeSet:setCodes(self._service:convertToCodeArray(data.code))
    listItem.btnRecv:hide()
    listItem.txtRecved:hide()
    listItem.level:hide()
    if data.status == 1 then -- 未中奖
        listItem.txtRecved:show()
        listItem.txtRecved:setString("本组幸运码未获得奖励")
    elseif data.status == 2 then -- 中奖未领取
        listItem.btnRecv:show()
        listItem.btnRecv.text:setString(str)
        local level = getRewardLevelByCount(data.count)
        local levelResPath = LevelTextures[level]
        if levelResPath then
            listItem.level:show()
            listItem.level:loadTexture(levelResPath)
            listItem.level.text:setString(level)
        end
        -- 这里也要赋值，因为会刷新到显示
        listItem.txtRecved:setString("幸运码已领取\n" .. str)
    elseif data.status == 3 then -- 已领取
        listItem.txtRecved:show()
        listItem.txtRecved:setString("幸运码已领取\n" .. str)
        listItem.btnRecv.text:setString("领取" .. str)
    end
    bindClick(listItem.btnRecv, function()
        -- 当领取按钮被点击
        if data.codeId then
            self._service:sendCACCollectCodeReceiveLotteryRewardREQ({
                period = self._currentShowPeriod,
                index = data.codeId - 1
            })
            data.status = 3
            listItem.txtRecved:show()
            listItem.btnRecv:hide()
        end
    end)
end

function UICollectCodeMyCode_History:_onBtnGetAllClick()
    self._service:sendCACCollectCodeReceiveLotteryRewardREQ({
        period = self._currentShowPeriod,
        index = -1,
    })
    local data = self._obtainListView._itemDatas
    for idx, itemData in ipairs(data) do
        itemData.status = 3
        self._obtainListView:updateItem(idx, itemData)
    end
end

function UICollectCodeMyCode_History:_onCheckBoxSelected(group, index)
    self:_onBtnPeriodClick(index)
end

function UICollectCodeMyCode_History:needBlackMask() return true end


return UICollectCodeMyCode_History