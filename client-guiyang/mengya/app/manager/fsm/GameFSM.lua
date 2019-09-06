--[[游戏过程有限状态机
--]]
local GameFSM = class("GameFSM")

-------------------------
-- 单例支持
local _instance = nil
function GameFSM:destroy()
    if _instance == nil then
        return
    end

    _instance:dispose()
    _instance = nil
end

function GameFSM:getInstance()
    if _instance then
        return _instance
    end

    _instance = GameFSM:new()
    return _instance
end

--------------------------
function GameFSM:ctor()
    self._currentState = nil
end

function GameFSM:dispose()
    if self._currentState then
        self._currentState:dispose()
        self._currentState = nil
    end
end

function GameFSM:getCurrentState()
    return self._currentState
end

--切换状态
function GameFSM:enterState(stateClassName)
    print("EnterState : %s", stateClassName)
    local oldState = self._currentState
    local stateClass = app[stateClassName]
    self._currentState = stateClass.new()
    -- Prepare
    if oldState then
        oldState:prepareExit()
    end

    self._currentState:prepareEnter()

    -- Do change state
    if oldState then
        oldState:exit()
    end

    -- 关闭所有界面
    local oldStateClassName = oldState and oldState.__cname or nil
    app.UIManager:getInstance():clear(oldStateClassName, oldStateClassName ~= stateClassName)

    self._currentState:enter()

    -- Done
    if oldState then
        oldState:afterExit()
        oldState:dispose()
    end

    self._currentState:afterEnter()

    return self._currentState
end

return GameFSM