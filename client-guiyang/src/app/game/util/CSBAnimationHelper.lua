local Array = require("ds.Array")
local Map = require("ds.Map")
---@class CSBAnimationHelper
local CSBAnimationHelper = class("CSBAnimationHelper")

---@param node Node
---@param csbPath string
function CSBAnimationHelper:ctor(node, csbPath)
    self._node = node
    ---@type ActionTimeline
    self._animAction = cc.CSLoader:createTimeline(csbPath)
    self._node:runAction(self._animAction)
    self._animAction:gotoFrameAndPause(0)
    self._duration = self._animAction:getDuration()
    self._speed = 1 --self._animAction:getTimeSpeed()
    self._infoMap = Map.new()
    ---@type Action
    self._currentRunAction = nil
    self._isPlaying = false
    self._actionArray = Array.new()

    self._scheduleTime = 0
end

function CSBAnimationHelper:setAnimationNames(names)
    for _, name in ipairs(names) do
        if self._animAction:IsAnimationInfoExists(name) then
            self._infoMap:put(name, self._animAction:getAnimationInfo(name))
        else
            Logger.warn(string.format("[%s] name :%s dont exist!", self.class.__cname, name))
        end
    end
end

---@param animationName string
---@param loop boolean
---@param onStartCallback function
---@param onFinishCallback function
function CSBAnimationHelper:playAnimationByName(animationName, loop, onStartCallback, onFinishCallback)
    if self._animAction then
        ---@type AnimationInfo
        local info = self:tryGetAnimationInfo(animationName)
        if info == nil then
            Macro.assertFalse(false, string.format('[%s] get animation info failed! doest exist name is :%s', self.class.__cname, animationName))
            return

        end
        --info:get
        --endIndex = {number} 40
        --name = {string} "animation1"
        --startIndex = {number} 0
        if onStartCallback then
            onStartCallback()
        end
        self._animAction:gotoFrameAndPlay(info.startIndex, info.endIndex, info.startIndex, loop)
        if onFinishCallback then
            local animTime = (info.endIndex - info.startIndex) / (60 / self._speed)
            local action = cc.Sequence:create(cc.DelayTime:create(animTime), cc.CallFunc:create(onFinishCallback))
            if loop then
                action = cc.RepeatForever:create(action)
            end
            self._node:runAction(action)
            self._currentRunAction = action
            return animTime
        end
    end
end

---@param loop boolean
---@param callback function
---播放所有帧
function CSBAnimationHelper:playAnimationWholeFrame(loop, callback)
    self._animAction:gotoFrameAndPlay(0, loop)
    if callback then
        local delay = self._duration / (60 * self._speed)
        local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callback))
        if loop then
            action = cc.RepeatForever:create(action)
        end
        self._node:runAction(action)
        self._currentRunAction = action
    end
end

---@return number 动画的播放时间（s），因为是帧动画，所有这个是不稳定的，根据感觉加上一些offset
function CSBAnimationHelper:getAnimationTime(animationName)
    local ret = 0
    if animationName then
        local info = self:tryGetAnimationInfo(animationName)
        if info then
            if info.animTime then
                ret = info.animTime
            else
                ret = (info.endIndex - info.startIndex) / (60 / self._speed)
                info.animTime = ret
            end
        end
    end
    return ret
end

function CSBAnimationHelper:setAnimationTime(animationName, duration)
    if duration >= 0 then
        local info = self:tryGetAnimationInfo(animationName)
        info.animTime = duration
    end
end

function CSBAnimationHelper:tryGetAnimationInfo(animationName)
    local ret = self._infoMap:get(animationName)
    if ret == nil then
        if self._animAction:IsAnimationInfoExists(animationName) then
            ret = self._animAction:getAnimationInfo(animationName)
            self._infoMap:put(animationName, ret)
        end
    end
    return ret
end

function CSBAnimationHelper:gotoFrameAndPause(frameIndex)
    self._animAction:gotoFrameAndPause(frameIndex)
end

---
---

function CSBAnimationHelper:play(animationName, loop)
    local time = self:getAnimationTime(animationName)
    local action = cc.Sequence:create(cc.CallFunc:create(function()
        self:playAnimationByName(animationName, loop)
    end), cc.DelayTime:create(time))
    self:insertAction(time, action)
    return self
end

function CSBAnimationHelper:delay(delayTime)
    local action = cc.DelayTime:create(delayTime)
    self:insertAction(delayTime, action)
    return self
end

function CSBAnimationHelper:call(func)
    local action = cc.CallFunc:create(func)
    self:insertAction(0, action)
    return self
end

function CSBAnimationHelper:insertAction(duration, action)
    self._actionArray:add(action)
    self:runNextAction(duration)
end

function CSBAnimationHelper:runNextAction(duration)
    if self._actionArray:getCount() == 0 then
        return
    end

    local action = self._actionArray:remove(self._actionArray:getCount())
    local _action = cc.Sequence:create(
            cc.DelayTime:create(self._scheduleTime),
            action,
            cc.CallFunc:create(function()
                self._scheduleTime = self._scheduleTime - duration
                if self._scheduleTime < 0.01 then
                    self._scheduleTime = 0
                end
                --printf("minus duration %s, total %s", duration, self._scheduleTime)
                self:runNextAction(0)
            end))
    self._node:runAction(_action)


    self._scheduleTime = self._scheduleTime + duration
    --printf("add duration %s, total %s", duration, self._scheduleTime)
end

function CSBAnimationHelper:forceClearAll()
    self._actionArray:forEach(function(action)
        self._node:stopAction(action)
    end)
    self._actionArray:clear()
    self._scheduleTime = 0
end

function CSBAnimationHelper:setVisible(value)
    value = value or false
    self._node:setVisible(value or false)
    return self
end

return CSBAnimationHelper