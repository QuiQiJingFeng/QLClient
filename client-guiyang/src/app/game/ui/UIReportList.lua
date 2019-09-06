local csbPath = "ui/csb/UIReportList.csb"
local super = require("app.game.ui.UIBase")
local UIReportList = class("UIReportList", super, function() return cc.CSLoader:createNode(csbPath) end)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

--[[
    封号玩家列表
]]

local UIElemReportItem = class("UIElemReportItem")

function UIElemReportItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemReportItem)
    self:_initialize()
    return self
end

function UIElemReportItem:_initialize()
    self._textId = seekNodeByName(self, "Text_id", "ccui.Text") -- id
	self._textDuration = seekNodeByName(self, "Text_duration", "ccui.Text") -- -- 封号时长
    self._textDate = seekNodeByName(self, "Text_date", "ccui.Text") -- -- 封号日期
end

function UIElemReportItem:setData(val)

    self._textId:setString(val.id)
    self._textDuration:setString(val.duration)
    self._textDate:setString(val.date)
end

function UIReportList:ctor()
    -- 封号玩家列表
    self._reusedListReport = UIItemReusedListView.extend(seekNodeByName(self, "ListView_report", "ccui.ListView"), UIElemReportItem)
    -- 不显示滚动条, 无法在编辑器设置
	self._reusedListReport:setScrollBarEnabled(false)
end

-- 界面显示
function UIReportList:show()
    self:setVisible(true)

    self:_initReportPlayerInfo()
end

-- 初始化封号玩家数据
function UIReportList:_initReportPlayerInfo()
       -- 清空数据
    self._reusedListReport:deleteAllItems()

    -- 暂时写死数据
    local reportList =
    {
        {id = "309262389", duration = "永久", date = "2018年6月19日"},
        {id = "301600478", duration = "永久", date = "2018年6月16日"},
        {id = "302452888", duration = "永久", date = "2018年6月8日"},
        {id = "20725213", duration = "永久", date = "2018年6月1日"},
        {id = "70634682", duration = "永久", date = "2018年5月23日"},
        {id = "218274316", duration = "永久", date = "2018年5月2日"},
        {id = "311790305", duration = "永久", date = "2018年5月2日"},
        {id = "93190358", duration = "永久", date = "2018年4月30日"},
        {id = "313066467", duration = "永久", date = "2018年4月18日"},
        {id = "302654832", duration = "永久", date = "2018年4月3日"},
        {id = "302166654", duration = "永久", date = "2018年3月24日"},
        {id = "302265234", duration = "永久", date = "2018年3月23日"},
        {id = "219224766", duration = "永久", date = "2018年3月5日"},
        {id = "228674548", duration = "永久", date = "2018年2月6日"},
        {id = "300526482", duration = "永久", date = "2018年1月27日"},
        {id = "301756248", duration = "永久", date = "2018年1月19日"},
        {id = "301135245", duration = "永久", date = "2017年12月15日"},
        {id = "254142702", duration = "永久", date = "2017年12月4日"},
    }

    -- 按日期排序(日期大小排序，日期相同按照玩家id大小排序)


    for _, data in ipairs(reportList) do
        self._reusedListReport:pushBackItem(data)
    end
end

function UIReportList:hide()
    self._reusedListReport:deleteAllItems()
    self:setVisible(false)
end


return UIReportList