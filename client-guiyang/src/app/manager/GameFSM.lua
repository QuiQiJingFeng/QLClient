--[[
游戏过程有限状态机
---------------------
Event:
GAME_STATE_CHANGING : 登录成功并获得用户基本数据
--]]

cc.exports.GameFSM = class("GameFSM")

-------------------------
-- 单例支持
local _instance = nil;
-- @return boolean
function GameFSM:create()
    if _instance ~= nil then
        return false;
    end

    _instance = GameFSM:new();
    return true;
end

function GameFSM:destroy()
    if _instance == nil then
        return;
    end

    _instance:dispose();
    _instance = nil;
end

function GameFSM:getInstance()
	return _instance;
end

--------------------------
function GameFSM:ctor()
	cc.bind(self,"event");
	
    self._currentState = nil
end

function GameFSM:dispose()
	cc.unbind(self,"event");
	
    if self._currentState ~= nil then
        self._currentState:dispose();
        self._currentState = nil
    end
end

function GameFSM:getCurrentState()
    return self._currentState;
end

--切换状态
function GameFSM:enterState(stateClassName)
    Logger.debug("EnterState : %s", stateClassName)
    local oldState = self._currentState
    local stateClass = require("app.game.gameState."..stateClassName)
    self._currentState = stateClass:new(self);

    self:dispatchEvent({name = "GAME_STATE_CHANGING"});

    -- Prepare
    if oldState ~= nil then
        oldState:prepareExit();
    end

    self._currentState:prepareEnter();

    -- Do change state
    if oldState ~= nil then
        oldState:exit();
    end

    -- 关闭所有界面
    local oldStateClassName = oldState and oldState.__cname or nil;
    UIManager:getInstance():clear(oldStateClassName, oldStateClassName ~= stateClassName);

    self._currentState:enter();

    -- Done
    if oldState ~= nil then
        oldState:afterExit();
        oldState:dispose();
        oldState = nil;
    end

    self._currentState:afterEnter();

    self:dispatchEvent({name = "GAME_STATE_CHANGED", current = self._currentState.__cname});

    return self._currentState;
end

--return GameFSM