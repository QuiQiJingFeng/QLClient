--[[0
    Example:
        local machine = Machine.new()
        self:addChild(machine)
        machine:setCharPool({"1", "2", "3", "4", "5"})
        machine:setResultCode("9453")
        machine:startScroll(function()
            print("Scroll Done!")
        end)
]]
local SET_COUNT = 6 -- 组的个数
local SET_LENTH = 10 -- 一组中有多少个字
local SET_SCROLL_REPEAT_COUNT = 3 -- 单组字的滚动次数
local RESULT_CHAR_INDEX = 2 -- 最终结果的那个字的下标

local Array = require("ds.Array")
local csbPath = 'ui/csb/Activity/CollectCode/Machine.csb'
local Machine = class("Machine", function() return kod.LoadCSBNode(csbPath) end)

function Machine:ctor()
    self._setTemplate = seekNodeByName(self, "Set_Template", "ccui.Layout")
    self._container = seekNodeByName(self, "Layout", "ccui.Layout")
    self._container:setClippingEnabled(true)
    self._setArray = Array.new()
    self._textArray = Array.new() -- 二维数组

    self._setTemplate:setAnchorPoint(cc.p(0.5, 0))
    self._startPosY = seekNodeByName(self, "POS_AP_BOT", "cc.Node"):getPositionY()
    self._endPosY = seekNodeByName(self, "POS_AP_TOP", "cc.Node"):getPositionY()

    self._isScrolling = false


    self._resultCodeArray = nil
    self._hasSetCodeArrayFinish = true
    self._isPlayStartSound = true


    -- 初始化其他节点
    for i = 1, SET_COUNT do
        local layout = self._setTemplate:clone()
        self._setArray:add(layout)
        self._container:addChild(layout)
        layout:setPosition(seekNodeByName(self, "POS_" .. i, "cc.Node"):getPosition())
        local textArr = Array.new()
        for j = 1, SET_LENTH do
            local text = seekNodeByName(layout, "Text_" .. j, "ccui.Text")
            textArr:add(text)
        end
        self._textArray:add(textArr)
    end
    self._setTemplate:hide()
end

function Machine:getResultCode()
    return self._resultCodeArray
end

function Machine:startScroll(callback)
    self._isScrolling = true
    self._setArray:forEach(function(item, index)
        scheduleOnce(function()
            self:_onTextSetScrollStart(index)
            self:playAnimation(index, function()
                self:_onTextSetScrollStop(index)
                if index == self._setArray:getCount() then
                    self._isScrolling = false
                    if callback then
                        callback()
                    end
                end
            end)
        end, index * 0.2, self)
    end)
end

function Machine:_onTextSetScrollStart(index)
    if index == 1 and self._isPlayStartSound then
        manager.AudioManager.getInstance():playEffect("sound/SFX/Activity/CollectCode/machine_start.mp3")
    end
end

function Machine:_onTextSetScrollStop(index)
    if index == SET_COUNT then
        -- self:refreshCharWithOutResult()
    end
end

function Machine:_onTextSetScrollSlow(index)
    if self._hasSetCodeArrayFinish == false then
        if self._resultCodeArray and self._resultCodeArray[index] then
            self._textArray:get(index):get(RESULT_CHAR_INDEX):setString(self._resultCodeArray[index])
        end
        if index >= #self._resultCodeArray then
            self._hasSetCodeArrayFinish = true
        end
    end
end

function Machine:_onTextSetScrollFast(index)
    self._textArray:get(index):forEach(function(text)
        text:setString(self:getRandomChar())
    end)
end

function Machine:isScrolling()
    return self._isScrolling
end

-- 播放单组动画
function Machine:playAnimation(index, callback)
    local target = self._setArray:get(index)
    local startPos = cc.p(target:getPositionX(), self._startPosY)
    local endPos = cc.p(target:getPositionX(), self._endPosY)

    target:setPosition(startPos)
    -- printf("startPos = {%s, %s}", startPos.x, startPos.y)
    -- printf("endPostion = {%s, %s}", endPos.x, endPos.y)
    local action = cc.Sequence:create(
    cc.EaseSineIn:create(cc.MoveTo:create(0.5, endPos)) -- move1
    ,
    cc.CallFunc:create(function()
        self:_onTextSetScrollFast(index)
    end)
    ,
    cc.Repeat:create(
    cc.Sequence:create(
    cc.Place:create(startPos),
    cc.MoveTo:create(0.2, endPos)
    ), SET_SCROLL_REPEAT_COUNT * SET_SCROLL_REPEAT_COUNT
    ) -- repeatMove
    ,
    cc.Place:create(startPos)-- resetPos
    ,
    cc.CallFunc:create(function()
        self:_onTextSetScrollSlow(index)
    end)
    ,
    cc.EaseSineOut:create(cc.MoveTo:create(0.5, endPos)) -- move2
    ,
    cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)
    )
    target:stopAllActions()
    target:runAction(action)
end

-- 重置组的位置， 有问题再调用， 动画中已经重置了位置
function Machine:resetCodePosition()
    self._setArray:forEach(function(item)
        item:setPositionY(self._startPosY)
    end)
end

function Machine:resetToResultPosition()
    self._setArray:forEach(function(item)
        item:setPositionY(self._endPosY)
    end)
end

-- 设置结果码
function Machine:setResultCode(codeArray)
    if codeArray == nil then
        return
    end
    self._hasSetCodeArrayFinish = false
    local len = #codeArray
    if Macro.assertFalse(len == SET_COUNT, 'resule codes illegal, expect len :[%s], got [%s]', SET_LENTH, len) then
        self._resultCodeArray = codeArray
        if self._isScrolling == false then
            self._hasSetCodeArrayFinish = true
            self._textArray:forEach(function(arr, index)
                arr:get(RESULT_CHAR_INDEX):setString(codeArray[index])
            end)
        end
    end
end

function Machine:getRandomChar()
    if self._charPool then
        return self._charPool[math.random(1, #self._charPool)]
    end
end

-- 设置字池
function Machine:setCharPool(charPool)
    self._charPool = charPool
    if self._charPool then
        for i = 1, SET_COUNT do
            for j = 1, SET_LENTH do
                self._textArray:get(i):get(j):setString(self:getRandomChar())
            end
        end
    end
end

-- 设置是否播放音效
function Machine:setIsPlayStartSound(value)
    self._isPlayStartSound = value or false
end

return Machine