local csbPath = "ui/csb/TestLayer.csb"

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local ItemType = {
    ["TestModules"] = 1,    -- 测试模块的列表
    ["TestCases"] = 2       -- 测试用例的列表
}

local currentModule = nil   -- 当前测试的模块

local UIElemTextItem = class("UIElemTextItem")

function UIElemTextItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemTextItem)
    self:_initialize()
    return self
end

function UIElemTextItem:_initialize()
    self._text = seekNodeByName(self, "Text_1", "ccui.Text")
end

function UIElemTextItem:setData(val)
    if self._data == val then
        return
    end

    self._data = val

    self._text:setString(self._data[1])

    bindTouchEventWithEffect(self._text, function ()
        if self._data[2] == ItemType.TestModules then
            -- 点击了模块列表，就显示对应cases
            lohotest.testlayer:dispatchEvent({name = "EVENT_SHOW_TESTCASES", module = self._data[1]})
        else
            -- 点击了cases，run之
            if currentModule ~= nil then
                currentModule:run(self._data[1])
            end
        end
    end, 0.95)
end

-- 事件说明
-- EVENT_SHOW_TESTCASES 显示测试用例list
-- EVENT_MODULE_DATA_DIRTY module的数据脏了

local TestLayer = class("TestLayer", function() return cc.CSLoader:createNode(csbPath) end)

function TestLayer:ctor()
    cc.bind(self, "event")

    self._dataDirty = false -- module数据是否需要更新
    self._dataLen = 0

    -- 测试模块列表
    self._listModule = UIItemReusedListView.extend(seekNodeByName(self, "ListView_1", "ccui.ListView"), UIElemTextItem)
    self._listModule:setScrollBarEnabled(false)

    -- 具体模块的测试用例列表
    self._listCase = UIItemReusedListView.extend(seekNodeByName(self, "ListView_2", "ccui.ListView"), UIElemTextItem)
    self._listCase:setScrollBarEnabled(false)

    -- 测试用例的panel
    self._panelCase = seekNodeByName(self, "Panel_4", "ccui.Layout")
    self._panelCase:setVisible(false)

    -- 测试模块的panel
    self._panelModule = seekNodeByName(self, "Panel_1", "ccui.Layout")

    -- 收放testlayer的开关
    self._btnCollapse = seekNodeByName(self, "Button_1", "ccui.Button")
    -- 开关上的字
    self._textBtn = seekNodeByName(self, "Text_3", "ccui.Text")
    self._textBtn:setString("收起")

    -- 清空列表
    self._listModule:deleteAllItems()
    
    bindEventCallBack(self._btnCollapse, handler(self, self._onBtnCollapse), ccui.TouchEventType.ended)
    bindEventCallBack(self._panelCase, handler(self, self._onHidePanelCase), ccui.TouchEventType.ended)
    

    self:addEventListener("EVENT_SHOW_TESTCASES", handler(self, self._onShowCasesList), self)
    self:addEventListener("EVENT_MODULE_DATA_DIRTY", handler(self, self._onModuleDataDirty), self)
    
    -- 每帧检查数据是否有变，如果有则刷新模块列表
    self:scheduleUpdateWithPriorityLua(function(dt)
        self:_update(dt)
    end, 0)

    -- 默认关闭
    self:_onBtnCollapse()
end

-- 数据变化的事件回调
function TestLayer:_onModuleDataDirty()
    self._dataDirty = true
end

function TestLayer:_update( dt )
    if self._dataDirty == false and self._dataLen == lohotest.test_modules.size() then
        return
    end
    -- print(self._dataLen)
    self._dataDirty = false -- 关闭脏标

    local modules = {tconst.runAllTest} -- 顶部添加全部测试
    -- 讲当前require的testmodele显示出来
    local iter = lohotest.test_modules.iterator()
    for i = 1, lohotest.test_modules.size() do
        local v = iter()
        table.insert( modules, v)
    end

    self._dataLen = #modules - 1 -- 设置数据长度，去掉allTest
    
    -- 清空list
    self._listModule:deleteAllItems()

    for i, v in ipairs(modules) do
        self._listModule:pushBackItem({v, ItemType.TestModules})
    end
end

function TestLayer:show()
    self:setVisible(true)
    self:setLocalZOrder(100000) -- 测试用例必须置于最高！！
    for i = 1, 10 do
        self._listModule:pushBackItem()
    end
end

--[[
    @desc: 显示测试用例的列表
            当为runAllTest时，则跑当前模块全部的cases
    author:{author}
    time:2018-04-29 24:21:38
    --@event: {module=具体模块的名字}
    return
]]
function TestLayer:_onShowCasesList(event)
    if event.module == tconst.runAllTest then
        lohotest.runalltest() -- 跑所有模块
    else
        -- require当前模块
        currentModule = require(event.module).new()
        local cases = currentModule:getAllCases() -- 所有cases
        table.insert( cases, 1, tconst.runAllTest ) -- 顶部插入跑所有cases
    
        self._panelCase:setVisible(true)
        self._listCase:deleteAllItems()
        
        for i, v in ipairs(cases) do
            self._listCase:pushBackItem({v, ItemType.TestCases})
        end
    end
end

function TestLayer:_onHidePanelCase()
    self._panelCase:setVisible(false)
    self._listCase:deleteAllItems()
    currentModule = nil
end

function TestLayer:_onBtnCollapse()
    self._textBtn:setString(self._panelModule:isVisible() and "打开" or "收起")
    self._panelModule:setVisible(not self._panelModule:isVisible())
end

function TestLayer:getUI()
    self._panelModule:setVisible(true)
end

function TestLayer:hide()
    -- 清空列表
    self._listModule:deleteAllItems()
    self._listCase:deleteAllItems()

    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)

    self:setVisible(false)
    cc.unbind(self, "event")
end

return TestLayer