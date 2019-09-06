local CATCH_DEBUG = false
local CSBAnimationHelper = require("app.game.util.CSBAnimationHelper")
---@class Catcher: Node
local Catcher = class("Catcher", function()
    return cc.Node:create()
end)

---@param parent Node
---@param level number
function Catcher:ctor(parent, level)
    self._currentPositionX = self:getPositionX()
    self._hookMoveSpeed = 2.0 * 60 -----------------------
    self._dollMoveDefaultSpeed = 1.2 * 60
    self._dollMoveSpeed = self._dollMoveDefaultSpeed -- per second pixels --
    self._dollDropSpeed = 2.0 * 60 -----------------------
    self._isMoving = false
    self._isCatching = false
    ---@type Doll
    self._clonedCatchDollObject = nil
    self._hookLevel = level
    ---@type number
    self._currentCatchDollIndex = nil
    self._parent = parent
    self._parent:addChild(self)
    self._isWaitingResult = false
    ---@type NetworkResponse
    self._waitResultResponse = nil

    -- debug
    self._debugPoint = seekNodeByName(parent, "Point")
    self._debugPoint:setLocalZOrder(10000)
    self._debugPoint:setVisible(CATCH_DEBUG)
end

function Catcher:createHook(level, csbPath)
    self._hookLevel = level
    if self._hookLevel >= 2 then
        self._dollMoveSpeed = self._dollMoveDefaultSpeed * 1.3
    else
        self._dollMoveSpeed = self._dollMoveDefaultSpeed
    end
    if csbPath == self._csbPath then
        self._hookAnimHelper:gotoFrameAndPause(self._hookAnimHelper:tryGetAnimationInfo("release").endIndex)
        return
    end

    if self._hook then
        self._hook:removeFromParent()
    end

    self._csbPath = csbPath
    ---@type Node
    self._hook = cc.CSLoader:createNode(self._csbPath)
    self:addChild(self._hook)
    self._hookNode = seekNodeByName(self._hook, "Hook")
    self._hookAnimHelper = CSBAnimationHelper.new(self._hook, self._csbPath)

    -- 调整下动画时间
    self._hookAnimHelper:setAnimationTime("catch_down", self._hookAnimHelper:getAnimationTime("catch_down") + 1)
    self._hookAnimHelper:setAnimationTime("pull_up", self._hookAnimHelper:getAnimationTime("pull_up") + 0.5)
    self._hookAnimHelper:setAnimationTime("release", self._hookAnimHelper:getAnimationTime("release") + 0.5)
    self._hookAnimHelper:gotoFrameAndPause(self._hookAnimHelper:tryGetAnimationInfo("release").endIndex)
end

function Catcher:setOnCatchDownCallback(func)
    self._onCatchDownCallback = func
end

function Catcher:setOnCatchUpCallback(func)
    self._onCatchUpCallback = func
end

function Catcher:setOnCatchFailureCallback(func)
    self._onCatchFailureCallback = func
end

function Catcher:setOnCatchSuccessCallback(func)
    self._onCatchSuccessCallback = func
end

function Catcher:setOnCatchHalfWayFailureCallback(func)
    self._onCatchHalfwayFailureCallback = func
end

function Catcher:destroy()
    self:destroyCloneDoll()
    self:stopRollDolls()
    self._hookAnimHelper:forceClearAll()
    self:stopAllActions()
    self._hook:removeFromParent()
    self:removeFromParent()
end


---
---@region set information start
---

function Catcher:setCatchPercentFunction(func)
    self._catchPercentFunc = func
end

---@param left number 可移动的最左位置
---@param right number 可移动的最右位置
---设置可移动的范围
function Catcher:setMovableMax(left, right)
    self._movableMaxLeft = left
    self._movableMaxRight = right
    if self._currentPositionX < self._movableMaxLeft or self._currentPositionX > self._movableMaxRight then
        self._currentPositionX = self._movableMaxLeft
        self:setPositionX(self._currentPositionX)
    end
end

---@param pos {x:number, y:number}
---设置抓取成功后的爪子点
function Catcher:setSafeDropDownPosition(pos)
    self._safeDropPosition = pos
end

---@param pos {x:number, y:number}
---设置抓取成功后娃娃的放置点
function Catcher:setSuccessPosition(pos)
    self._successPosition = pos
end

---@param pos {x:number, y:number}
---爪子初始的地方
function Catcher:setSpawnPosition(pos)
    self._spawnPosition = pos
end

---@param dolls Doll[]
---@param size {width:number, height:number}
---设置娃娃对象与大小 因为是node 所以大小需要手动写
function Catcher:setDollsInfo(dolls, size)
    self._dolls = dolls
    self._dollSize = size
    self._dollOriginPositions = {}
    self._dollParent = dolls[1]:getParent()
    self._dollPosY = dolls[1]:getPositionY()
    self._debugPoint:setPositionY(self._dollPosY)

    local left = dolls[1]:getPositionX()
    local right = left
    for idx, doll in ipairs(dolls or {}) do
        -- 找到最左与最右的
        local pos = cc.p(doll:getPosition())
        if pos.x > right then
            right = pos.x
        elseif pos.x < left then
            left = pos.x
        end
        self._dollOriginPositions[idx] = pos
    end

    local dollSpacing = (right - left) / #self._dolls
    Logger.debug("dollSpacing %s", dollSpacing)

    self._dollMoveMax = {
        left = cc.p(left, self._dollPosY),
        right = cc.p(seekNodeByName(dolls[1]:getParent(), "Item_Position_Right_Max"):getPosition())
    }
    self._dollTotalMoveTime = self:getMoveTime(self._dollMoveMax.left.x, self._dollMoveMax.right.x)
end


---
---@region set information end
---

--function Catcher:moveToSafeDropPoint(callback)
--    self:moveToPositionByAction(self._safeDropPoint, callback)
--end

---@param destPos table 目标点
---@param callback function 到达后的回调
function Catcher:moveToPositionByAction(destPos, callback)
    if self._isMoving then
        return
    end

    local time = self:getMoveTime(self._currentPositionX, destPos.x)
    local action = cc.Sequence:create(cc.MoveTo:create(time, destPos),
            cc.CallFunc:create(function()
                self._isMoving = false
                self._currentPositionX = destPos.x
                if callback then
                    callback()
                end
            end))
    self._isMoving = true
    self:runAction(action)
end

---重置状态： 爪子的位置， 娃娃的位置， 并且停止滚动
function Catcher:reset()
    self:setPosition(self._spawnPosition)
    self._currentPositionX = self._spawnPosition.x
    self._isMoving = false
    self._isCatching = false
    self._isWaitingResult = false
    self._waitResultResponse = nil

    for idx, doll in ipairs(self._dolls) do
        doll:stopAllActions()
        doll:setPosition(self._dollOriginPositions[idx])
    end
    self:startRollDolls()
    self:destroyCloneDoll()
    self._debugPoint:setPositionX(0)
end

---@return boolean 是否处于抓取中
function Catcher:isCatching()
    return self._isCatching or false
end

function Catcher:replaceToSpawnPosition()
    self:setPosition(self._spawnPosition)
    self._currentPositionX = self._spawnPosition.x
end

---@return boolean 是否可以抓起
---是否可以抓起， 但是实际是否可以获得娃娃由服务器判断， 服务器返回后， 走 continueCatch 的逻辑
function Catcher:startCatch()
    if self._hookLevel >= 2 then
        return self:_startCatch100()
    end
    -- 判断是否算抓中
    local hookX = self._currentPositionX
    local offset = self._dollSize.width * 0.5
    local expectX -- 预计在爪子落下后，娃娃的 x 坐标
    local canCatchUp = false

    -- 这里需要在爪子落下后，物体与爪子的相对位置
    -- 这里没有考虑到方向性
    -- debug
    self._debugPoint:setPositionX(0)
    local waitHookCatchDownTime = self._hookAnimHelper:getAnimationTime("catch_down")
    local dollMoveOffset = self._dollMoveSpeed * waitHookCatchDownTime
    Logger.debug("time: %s, move: %s", waitHookCatchDownTime, dollMoveOffset)

    self:destroyCloneDoll()

    self._currentCatchDollIndex = nil
    for idx, doll in ipairs(self._dolls) do
        expectX = doll:getPositionX() - dollMoveOffset
        if hookX >= expectX - offset and hookX <= expectX + offset then
            self._currentCatchDollIndex = idx
            Logger.debug("catch level %s, current x %s, waitHookCatchDownTime %s, excepted x %s, diff %s", doll.level, doll:getPositionX(), waitHookCatchDownTime, expectX, dollMoveOffset)
            self._debugPoint:setPositionX(expectX)
            break
        end
    end

    if self._currentCatchDollIndex == nil then
        self:catchFailure()
    else
        local percent = math.abs(1 - (expectX + offset - hookX) / self._dollSize.width)
        -- debug
        self._dolls[self._currentCatchDollIndex].percentPoint:setPositionPercent(cc.p(percent, 1))

        Macro.assertFalse(percent >= 0 and percent <= 1, "percent error, percent = " .. percent)

        Logger.debug("percent " .. percent)

        local status = self._catchPercentFunc(percent)
        local dollHookOffset = math.max(expectX - hookX, 0)
        local waitDollMoveToPullUpTime = dollHookOffset / self._dollMoveSpeed
        Logger.debug("dollHookOffset  %s, waitDollMoveToPullUpTime %s", dollMoveOffset, waitDollMoveToPullUpTime)
        --assert(waitDollMoveToPullUpTime > 0)
        if status == "success" then
            canCatchUp = true
            --self:cloneDoll(self._dolls[self._currentCatchDollIndex])
            --self:catchSuccess(catchDollIndex, waitDollMoveToPullUpTime)
            self:catchDownUpAndWait(waitDollMoveToPullUpTime)
        else
            --if status == "failure" then
            self:catchFailure()
            --elseif status == "failure_halfway" then
            --    self:catchHalfWayFailure(catchDollIndex, waitDollMoveToPullUpTime)
        end
    end
    return canCatchUp
end

-- 百分百抓中
function Catcher:_startCatch100()
    self:destroyCloneDoll()
    local hookX = self._currentPositionX
    local catchDownTime = self._hookAnimHelper:getAnimationTime("catch_down")
    local dollMoveOffset = self._dollMoveSpeed * catchDownTime
    local waitDollMoveToPullUpTime = 0
    self._currentCatchDollIndex = nil
    local minOffset = self._dollMoveMax.right.x
    -- 找到 catchDownTime 时间后，依然在爪子正下方或者右边的娃娃
    for idx, doll in ipairs(self._dolls) do
        local dollX = doll:getPositionX() - dollMoveOffset
        if dollX < self._dollMoveMax.left.x then
            dollX = self._dollMoveMax.right.x - (self._dollMoveMax.left.x - dollX)
        end
        local offset = dollX - hookX
        -- found
        if offset >= 0 and offset < minOffset then
            self._currentCatchDollIndex = idx
            self._debugPoint:setPositionX(hookX)
            waitDollMoveToPullUpTime = offset / self._dollMoveSpeed
            minOffset = offset
        end
    end
    local str = ("Catcher:_startCatch100, waitMoveTime: %s, dollIdx:%s "):format(waitDollMoveToPullUpTime, self._currentCatchDollIndex or "nil")
    Logger.debug(str)
    Macro.assertFalse(self._currentCatchDollIndex, 'not found doll on catch100')
    self:catchDownUpAndWait(waitDollMoveToPullUpTime)
    return true
end

---抓取失败，这里不需要等服务器
function Catcher:catchFailure()
    if self._isCatching then
        return
    end
    Logger.debug("Catcher:catchFailure")
    self._isCatching = true
    self._hookAnimHelper
        :play("catch_down")
        :call(
            function()
                if self._onCatchDownCallback then
                    self._onCatchDownCallback()
                end
            end)
        :play("pull_up")
        :call(
            function()
                if self._onCatchUpCallback then
                    self._onCatchUpCallback()
                end
            end)
        :call(
            function()
                self._isCatching = false
                if self._onCatchFailureCallback then
                    self._onCatchFailureCallback()
                end
            end)
end

---@private
---@param waitDollMoveToPullUpTime number 爪子下去后等待物体移动的时间
function Catcher:catchDownUpAndWait(waitDollMoveToPullUpTime)
    if self._isCatching then
        return
    end
    Logger.debug("Catcher:catchDownUpAndWait")
    self._isCatching = true
    self._hookAnimHelper
        :play("catch_down")
        :delay(waitDollMoveToPullUpTime)
        :call(
            function()
                if self._onCatchDownCallback then
                    self._onCatchDownCallback()
                end
                self:cloneDollToHook(self._currentCatchDollIndex)
                self._dolls[self._currentCatchDollIndex]:setVisible(false)
            end)
        :play("pull_up")
        :call(
            function()
                if self._onCatchUpCallback then
                    self._onCatchUpCallback()
                end
                self._isWaitingResult = true
                if self._waitResultResponse then
                    self:catchContinue(not self._waitResultResponse:getBuffer().isCatch)
                end
            end)
end

---@param isRelease boolean 是否放卡抓起的娃娃
---这个是等服务器返回后调用的
function Catcher:catchContinue(isRelease)
    if not self._isCatching then
        return
    end

    self._isWaitingResult = false
    self._waitResultResponse = nil
    if isRelease then
        -- 抓中 但是失败
        self._hookAnimHelper
            :call(
                function()
                    self:dropCloneDoll(cc.p(self:getPositionX(), self._dollPosY))
                end)
        --:play("release") -- 即便失败了，也不释放
            :delay(self._hookAnimHelper:getAnimationTime("release"))
            :call(
                function()
                    -- 抓中但失败 结束
                    self._isCatching = false
                    if self._onCatchHalfwayFailureCallback then
                        self._onCatchHalfwayFailureCallback()
                    end
                end)
    else
        -- 抓中且 成功移动到目标点
        self:moveToPositionByAction(self._safeDropPosition, function()
            self._hookAnimHelper
                :call(
                    function()
                        self:dropCloneDoll(self._successPosition)
                    end)
                :play("release")
                :call(
                    function()
                        if self._onCatchSuccessCallback then
                            self._onCatchSuccessCallback()
                        end
                        self._isCatching = false
                    end)
        end)
    end
end

---@param dir string "left":"right"
---移动爪子的位置
function Catcher:move(dir)
    if not self._isMoving and not self._isCatching then
        if dir == 'left' then
            self._currentPositionX = self._currentPositionX - self._hookMoveSpeed / 60
            if self._currentPositionX <= self._movableMaxLeft then
                self._currentPositionX = self._movableMaxLeft
            end
        elseif dir == 'right' then
            self._currentPositionX = self._currentPositionX + self._hookMoveSpeed / 60
            if self._currentPositionX >= self._movableMaxRight then
                self._currentPositionX = self._movableMaxRight
            end
        end

        self:setPositionX(self._currentPositionX)
    end
end

---@param srcPosX number 起始点
---@param destPosX number 目标点
---@return number 移动的时间
---计算两点之间的移动时间， 会对时间进行 abs
function Catcher:getMoveTime(srcPosX, destPosX)
    return math.abs(((destPosX - srcPosX) / (self._hookMoveSpeed))) --* 0.2 -- debug time
end

---@private
---移动抓住的娃娃到爪子中 这里是克隆的一个对象去移动，实际的不会动
function Catcher:cloneDollToHook(dollIndex)
    self:destroyCloneDoll()
    local doll = self:cloneDoll(self._dolls[dollIndex])
    doll:stopAllActions()
    doll:retain()
    doll:removeFromParent()
    self._hookNode:addChild(doll)
    doll:release()
    doll:setPosition(cc.p(0, 0))
end

---@private
---@param destPos {x:number, y:number} @下落的目标点 self的相对坐标
---放开克隆的娃娃
function Catcher:dropCloneDoll(destPos)
    -- 要把 destPos 转为 _clonedCatchDollObject 的相对坐标
    local worldDestPos = self:getParent():convertToWorldSpace(destPos)
    local real_destPos = self._clonedCatchDollObject:getParent():convertToNodeSpace(worldDestPos)
    local dropTime = (self._clonedCatchDollObject:getPositionY() - real_destPos.y) / self._dollDropSpeed
    local action = cc.MoveTo:create(dropTime, real_destPos)
    self._clonedCatchDollObject:runAction(action)
end

---开始滚动娃娃 这里没有考虑方向
function Catcher:startRollDolls()
    for idx, doll in ipairs(self._dolls) do
        doll:setPosition(self._dollOriginPositions[idx])
        doll:setVisible(true)
    end
    local updateInterval = 0.03
    -- 这个更新会有一个问题，updateInterval 只能约等于 update
    -- 扩大 updateInterval 的值可以减少误差
    self._updateId = scheduleUpdate(self._updateId, function()
        for _, doll in ipairs(self._dolls) do
            --if idx ~= self._currentCatchDollIndex then
            local x = doll:getPositionX() - self._dollMoveSpeed * updateInterval
            if x <= self._dollMoveMax.left.x then
                x = self._dollMoveMax.right.x
            end
            doll:setPositionX(x)
            --end
            --print(deltaTime)
            --for i = 1, 10000000 do
            --    local j = 1
            --    j = i * 10 + j
            --end
        end
    end, updateInterval)
end

---停止滚动娃娃
function Catcher:stopRollDolls()
    unscheduleUpdate(self._updateId)
end

---@private
---@param doll Doll
---克隆一个娃娃，最终他会被直接抛弃
function Catcher:cloneDoll(doll)
    --Logger.debug("cloneDoll")
    --Logger.debug(debug.traceback())
    self:destroyCloneDoll()

    local object = doll:clone()
    self._dollParent:addChild(object)
    self._clonedCatchDollObject = object
    return object
end

---摧毁克隆的娃娃 如果存在的话
function Catcher:destroyCloneDoll()
    --Logger.debug("destroyCloneDoll")
    --Logger.debug(debug.traceback())
    if self._clonedCatchDollObject then
        self._clonedCatchDollObject:removeFromParent()
        self._clonedCatchDollObject = nil
    end
end

---@return Doll
function Catcher:getCurrentCatchDoll()
    if self._currentCatchDollIndex then
        return self._dolls[self._currentCatchDollIndex]
    end
end

---设置等待的结果
function Catcher:setWaitResult(response)
    self._waitResultResponse = response
    if self._isWaitingResult == true then
        self:catchContinue(not response:getBuffer().isCatch)
        self._waitResultResponse = nil
    end
end

return Catcher