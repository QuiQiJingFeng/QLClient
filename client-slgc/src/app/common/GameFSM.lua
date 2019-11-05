local GameFSM = class("GameFSM")

local _instance = nil
function GameFSM:getInstance()
    if not _instance then
        _instance = GameFSM.new()
    end

    return _instance
end

function GameFSM:ctor()
 	self._currentState = nil
 	self._lastStateName = ""
end

function GameFSM:getStatesDir()
	return "app.gameStates"
end

function GameFSM:getCurrentState()
	return self._currentState
end

function GameFSM:getCurrentStateDir()
    return self._currentStateDir
end

function GameFSM:getLastStateName()
	return self._lastStateName
end

function GameFSM:enterState(stateName,...)
	print("EnterState : %s", stateName)
	local oldState = self._currentState
    if oldState then
        self._lastStateName = oldState.__cname
    end

	self._currentStateDir = string.format("%s.%s",self:getStatesDir(),stateName)
	local statePath = string.format("%s.main",self._currentStateDir)
	self._currentState = require(statePath).new()
	if oldState ~= nil then
        oldState:prepareExit()
    end
	self._currentState:prepareEnter()

	if oldState ~= nil then
        oldState:exit()
    end

    -- 关闭所有界面
    local oldStateClassName = oldState and oldState.__cname or nil
    game.UIManager:getInstance():clear(oldStateClassName, oldStateClassName ~= stateName)

    self._currentState:enter()

     -- Done
    if oldState ~= nil then
        oldState:afterExit()
        oldState:dispose()
        oldState = nil
    end

    self._currentState:afterEnter()
end


return GameFSM