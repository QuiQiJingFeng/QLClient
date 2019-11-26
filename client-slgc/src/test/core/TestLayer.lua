local UITableView = game.UITableView
local UIElemTextItem = class("UIElemTextItem")
local TestLayerItem = require("test.core.TestLayerItem")
-- 事件说明
local TestLayer = class("TestLayer", function() return cc.Layer:create() end)

function TestLayer:ctor()
    self:setLocalZOrder(99999)
    local btnEnable = ccui.Button:create()
    btnEnable:setTitleText("打开")
    self:addChild(btnEnable)
    btnEnable:setTitleFontSize(40)
    btnEnable:setPosition(cc.p(display.width-50,display.height-30))
    self._btnEnable = btnEnable

    local scrollView = ccui.ScrollView:create()
    scrollView:setDirection(ccui.ScrollViewDir.vertical)
    scrollView:setPosition(cc.p(0,0))
    local size = cc.size(400,640)
    scrollView:setContentSize(size)
    self:addChild(scrollView)

    local item = ccui.Layout:create()
    scrollView:addChild(item)
    item:setContentSize(cc.size(400,50))
    item:setAnchorPoint(cc.p(0,1))
    item:setPositionY(size.height)

    self._testCaseList = UITableView.extend(scrollView,TestLayerItem,handler(self,self._onItemClick))
    self._testCaseList:setDeltUnit(3)
    self._testCaseList:setVisible(false)

    game.Util:bindTouchEvent(btnEnable,handler(self,self._onBtnOpenClick))

    game.EventCenter:on("TEST_CASE_FILE_REFRESH",handler(self,self._onDataRefresh))
end

function TestLayer:_onBtnOpenClick()
    local title = self._btnEnable:getTitleText()
    if title == "打开" then
        self._btnEnable:setTitleText("关闭")
        self._testCaseList:setVisible(true)
    elseif title == "关闭" then
        self._btnEnable:setTitleText("打开")
        self._testCaseList:setVisible(false)
    end
end

function TestLayer:_onItemClick(item,data)
    if data.func then
        data.func()
    end
end

function TestLayer:_onDataRefresh(datas)
    self._testCaseList:updateDatas(datas)
end

return TestLayer