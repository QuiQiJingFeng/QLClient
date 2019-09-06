local csbPath = "ui/csb/Club/UIClubActivityTime.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubActivityTime = class("UIClubActivityTime", super, function() return cc.CSLoader:createNode(csbPath) end)

--[[
    活动时间选择界面
]]

local MIN =
{
    0, 5, 10, 15, 20,  25, 30, 35, 40, 45, 50, 55
}

local timeType =
{
    1, -- day
    2, -- hour
    3, -- min
}

local txetType =
{
    "选择日期",
    "选择小时",
    "选择分钟"
}

function UIClubActivityTime:ctor(parent)
    self._parent = parent

    self._btnBack = seekNodeByName(self, "Button_Activity_Back", "ccui.Button")
    self._textDate = seekNodeByName(self, "Text_Activity_Data", "ccui.Text")
    self._textTips = seekNodeByName(self, "Text_Activity_Tips", "ccui.Text")

    self._listActivityData = seekNodeByName(self, "ListView_Time", "ccui.ListView")
    self._listActivityData:setScrollBarEnabled(false)
    self._listActivityData:setTouchEnabled(false)
    -- 日期的item
	self._listviewItemDay = ccui.Helper:seekNodeByName(self._listActivityData, "Panel_day")
	self._listviewItemDay:removeFromParent(false)
	self:addChild(self._listviewItemDay)
	self._listviewItemDay:setVisible(false)
    -- 时 分的item
	self._listviewItemTime = ccui.Helper:seekNodeByName(self._listActivityData, "Panel_Time")
	self._listviewItemTime:removeFromParent(false)
	self:addChild(self._listviewItemTime)
	self._listviewItemTime:setVisible(false)

    bindEventCallBack(self._btnBack, handler(self, self._onBtnBackClick), ccui.TouchEventType.ended)
end

--[[
    type 类型(开始、结束时间)
]]
function UIClubActivityTime:show(type, clubId)
    self:setVisible(true)
    
    self._oldnowTime = game.service.TimeService:getInstance():getCurrentTime()
    self._formatT = kod.util.Time.time2Date(self._oldnowTime)

    self._nowTime = self._oldnowTime

    self._type = type

    self._clubId = clubId

    -- 时间类型
    self._timeType = timeType[1]

    -- 格式化时间
    self._saveTime = 
    {
        year = 0,
        month = 0,
        day = 0,
        hour = 0,
        min = 0
    }

    self._textDate:setString("")

    self:_initActivityData()
end

-- 初始化活动日期
function UIClubActivityTime:_initActivityData()
    -- 清空列表
    self._listActivityData:removeAllChildren()

    self._nowTime = self._oldnowTime

    self._textTips:setString(txetType[self._timeType])

    for i = 1, 5 do
        -- 判断是否显示的时间内容
        local node = nil
        if self._timeType == timeType[1] then
            node = self._listviewItemDay:clone()
        else
            node = self._listviewItemTime:clone()
        end
        if node then
            self._listActivityData:addChild(node)
            node:setVisible(true)
            self:_initDta(i, node)
        end
    end
end

-- 初始化日期
function UIClubActivityTime:_initDta(i, node)
    -- 不同类型的时间显示内容不同
    local count = self._timeType == timeType[1] and 7 or 5
    for j = 1, count do
        local btn = ccui.Helper:seekNodeByName(node, "Button_Activity_Date_" .. j)
        local text = ccui.Helper:seekNodeByName(btn, "BitmapFontLabel_Data")
        if self._timeType == timeType[1] then
            -- 设置日期
            local formatT = kod.util.Time.time2Date(self._nowTime)
            text:setString(string.format("%d/%d", formatT.month, formatT.day))
            self._nowTime = self._nowTime + 24 * 60 * 60
            -- 限制不能点击的日期
            btn:setEnabled(self:_comparedTime(formatT.year, formatT.month, formatT.day))
            -- 设置显示的日期
            self._textDate:setString("")

            bindEventCallBack(btn, function()
                -- 保存时间
                self:_setSaveTime(formatT.year, formatT.month, formatT.day, nil, nil)
                self._timeType = timeType[2]
                self:_onBtnBackClick()
            end, ccui.TouchEventType.ended)
        elseif self._timeType == timeType[2] then
            local hour = j + 5 * (i - 1) - 1
            text:setString(string.format("%d时", hour))
            -- 超过二十四小时就隐藏
            if hour >= 24 then
                btn:setVisible(false)
            else
                btn:setVisible(true)
                -- 限制不能点击的小时
                btn:setEnabled(self:_comparedTime(self._saveTime.year, self._saveTime.month, self._saveTime.day, hour))
                -- 设置显示的日期
                self._textDate:setString(string.format("%d月%d日", self._saveTime.month, self._saveTime.day))

                bindEventCallBack(btn, function()
                    -- 保存时间
                    self:_setSaveTime(nil, nil, nil, hour, nil)
                    self._timeType = timeType[3]
                    self:_onBtnBackClick()
                end, ccui.TouchEventType.ended)
            end
        elseif self._timeType == timeType[3] then
            if MIN[j + 5 * (i - 1)] ~= nil then
                text:setString(string.format("%d分", MIN[j + 5 * (i - 1)]))
                btn:setVisible(true)
                -- 限制不能点击的分
                btn:setEnabled(self:_comparedTime(self._saveTime.year, self._saveTime.month, self._saveTime.day, self._saveTime.hour, MIN[j + 5 * (i - 1)]))
                -- 设置显示的日期
                self._textDate:setString(string.format("%d月%d日 %d时", self._saveTime.month, self._saveTime.day, self._saveTime.hour))

                bindEventCallBack(btn, function()
                    -- 保存时间
                    self:_setSaveTime(nil, nil, nil, nil, MIN[j + 5 * (i - 1)])
                    self._parent._parent._saveTime[self._type] = self._saveTime
                    self._timeType = timeType[1]
                    self:_onBtnBackClick()
                end, ccui.TouchEventType.ended)
            else
                text:setString("")
                btn:setVisible(false)
            end
        end
    end
end

-- 保存当前选择的时间
function UIClubActivityTime:_setSaveTime(newYear, newMonth, newDay, newHour, newMin)
    self._saveTime = 
    {
        year = newYear or self._saveTime.year,
        month = newMonth or self._saveTime.month,
        day = newDay or self._saveTime.day,
        hour = newHour or self._saveTime.hour,
        min = newMin or self._saveTime.min
    }
end

-- 时间对比
function UIClubActivityTime:_comparedTime( ... )
    local data = { ... }
    -- 判断活动开始时间是否设定
    local startTime = self._parent._parent._saveTime[ClubConstant:getTimeType().START]

    -- 已经设置好开始时间时再次设置开始时间时原来的设定不生效
    if self._type == ClubConstant:getTimeType().START then
        startTime = nil
    end

    -- 没有设定默认现在时间为最小时间
    if startTime ==  nil then
        startTime =
        {
            year = self._formatT.year,
            month = self._formatT.month,
            day = self._formatT.day,
            hour = self._formatT.hour,
            min = self._formatT.min,
        }
    end

    local endTime = self._parent._parent._saveTime[ClubConstant:getTimeType().END]
    -- 设置一个最大的时间(不可能达到的时间)
    local newtime = 32503654800 -- 3000/01/01 01:00:00

    -- 判断是否已经设置好结束时间
    -- 已经设置好结束时间时再次设置结束时间时原来的设定不生效
    if endTime and self._type ~= ClubConstant:getTimeType().END then
        newtime = os.time{
            year = endTime.year,
            month = endTime.month,
            day = endTime.day,
            hour = data[4] and endTime.hour or 0,
            min = data[5] and endTime.min or 0
        }
    end
    -- 现在的时间
    local time = os.time{
        year = data[1],
        month = data[2],
        day = data[3],
        hour = data[4] or 0,
        min = data[5] or 0
    }
    -- 开始时间（当前时间）
    local oldtime = os.time{
        year = startTime.year,
        month = startTime.month,
        day = startTime.day,
        hour = data[4] and startTime.hour or 0,
        min = data[5] and startTime.min or 0
    }
    
    -- 可以同一天同一个小时但是不能同一分钟
    if data[5] then
        return (time > oldtime) and (time < newtime)
    else
        return (time >= oldtime) and (time <= newtime)
    end 
end

function UIClubActivityTime:_onBtnBackClick(sender)
    -- 在选择日期界面就直接返回创建活动界面
    if self._timeType == timeType[1] then
        -- 显示创建活动界面
        if self._parent._parent._uiElemList["UIClubActivityCreate"] == nil then
            local clz = require("app.game.ui.club.activity.UIClubActivityCreate")
            local ui = clz.new(self)
            self._parent._parent._uiElemList["UIClubActivityCreate"] = ui
            self._parent._parent._node:addChild(ui)
        end
        self._parent._parent:_hideAllPages()
        self._parent._parent._uiElemList["UIClubActivityCreate"]:show(self._clubId)
    else
        -- 在选择时间期间点击返回时
        if sender then
            self._timeType = self._timeType - 1
        end
        self:_initActivityData()
    end
end


function UIClubActivityTime:hide()
    self:setVisible(false)
end

return UIClubActivityTime