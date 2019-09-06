local csbPath = "ui/csb/UIReportMain.csb"
local super = require("app.game.ui.UIBase")

local UIReportMain = class("UIReportMain", super, function () return kod.LoadCSBNode(csbPath) end)

local UIReportList = require("app.game.ui.UIReportList")
local UIReport = require("app.game.ui.UIReport")

--[[
    举报
]]

local REPORT_TYPE =
{
    {name = "违法举报", ui = UIReport, id = 1},
    {name = "封号名单", ui = UIReportList, id = 2},
}

function UIReportMain:ctor()
    self._btnClose = nil -- 关闭
    self._listReport = nil

    self._uiElemList = {}
    self._btnCheckList = {}
end

function UIReportMain:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._listReport = seekNodeByName(self, "ListView_report", "ccui.ListView")

    self._listReport:setScrollBarEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listReport, "CheckBox_report")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)
    self._listReport:setVisible(false)
    
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

function UIReportMain:onShow()
    self:_initListItem()
    UIManager:getInstance():show("UIReportLED")  
end

function UIReportMain:_initListItem()
    self._listReport:removeAllChildren()

    for _, data in ipairs(REPORT_TYPE) do
        local node = self._listviewItemBig:clone()
        self._listReport:addChild(node)
        node:setVisible(true)

        local name = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_2")
        name:setString(data.name)

        local isSelected = false
        node:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = node:isSelected()
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then	
                self:_onItemTypeClicked(data)
                node:setSelected(true)
            elseif eventType == ccui.TouchEventType.canceled then
                node:setSelected(isSelected)
            end
        end)

        self._btnCheckList[data.id] = node
    end

    -- 默认显示第一个
    self:_onItemTypeClicked(REPORT_TYPE[1])
end

function UIReportMain:_onItemTypeClicked(data)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == data.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    -- 创建对应的界面
    if self._uiElemList[data.ui] == nil then
        local ui = data.ui.new(self)
        self._uiElemList[data.ui] = ui
        self:addChild(ui)
    end

    self:_hideAllPages()
    self._uiElemList[data.ui]:show()
end

function UIReportMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end


function UIReportMain:_onBtnClose()
    UIManager:getInstance():destroy("UIReportMain")
end

function UIReportMain:onHide()
    self:_hideAllPages()
    self._uiElemList = {}
    self._btnCheckList = {}
    self._listReport:removeAllChildren()
    UIManager:getInstance():destroy("UIReportLED")
end

function UIReportMain:needBlackMask()
	return true;
end

function UIReportMain:closeWhenClickMask()
	return false
end

return UIReportMain