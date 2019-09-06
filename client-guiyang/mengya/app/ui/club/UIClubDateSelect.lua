local csbPath = app.UIClubDateSelectCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableViewEx = app.UITableViewEx
local UIClubDateItem = app.UIClubDateItem
local UIClubDateSelect = class("UIClubDateSelect", super, function() return cc.CSLoader:createNode(csbPath) end)
local MAX_DAY_LIMIT = 15

function UIClubDateSelect:ctor()
    
end

function UIClubDateSelect:init()
    local node = Util:seekNodeByName(self,"scrollListDates","ccui.ScrollView")
    self._scrollListDates = UITableViewEx.extend(node,UIClubDateItem,handler(self,self._onItemClick))
    self._scrollListDates:perUnitNums(5)
    self._scrollListDates:setDeltUnit(10)
    self._scrollListDates:setDeltUnitFlix(5)
end

function UIClubDateSelect:_onItemClick(item,data,eventType)
    if eventType == ccui.TouchEventType.begin or eventType == ccui.TouchEventType.canceled then
        item:setSelected(not item:isSelected())
        return
    end
    if eventType == ccui.TouchEventType.ended then
        self._lastSelectTime = data.time
        self._callBack(data)
        local datas = self._scrollListDates:getDatas()
        local idx = item:getIdx()
        assert(idx,"idx must be none nil")
        for index, info in ipairs(datas) do
            if index ~= idx then
                info.selected = false
            else
                info.selected = true
            end
        end
        self._scrollListDates:updateDatas(datas)
        UIManager:getInstance():hide("UIClubDateSelect")
    end
end

function UIClubDateSelect:needBlackMask()
	return true
end



function UIClubDateSelect:onShow(callBack)
    self._callBack = callBack

    local curDateInfo = Util:getDateInfo()
    local datas = {}
    for i = 1,  MAX_DAY_LIMIT do
        local data = {}
        local dateInfo = clone(curDateInfo)
        dateInfo.day = dateInfo.day - (i - 1)
        local time = os.time(dateInfo)
        data.time = time
        table.insert(datas,data)
        if self._lastSelectTime then
            data.selected = data.date == self._lastSelectTime
        else
            data.selected = i == 1
        end
    end

    self._scrollListDates:updateDatas(datas)
end

return UIClubDateSelect