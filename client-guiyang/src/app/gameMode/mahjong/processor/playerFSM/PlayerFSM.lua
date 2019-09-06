--[[
    人物有限状态机
        对人物状态进行管理 如 托管，自动打牌等
        author heyi
---------------------
Event:
    Campaign_STATE_CHANGING -- 状态切换
--]]
local PlayerFSM = class("PlayerFSM")
--------------------------
function PlayerFSM:ctor( parent, player)
	cc.bind(self,"event");
	
    self._currentState = nil
    self._player = player
end

function PlayerFSM:dispose()
	cc.unbind(self,"event");
	
    if self._currentState ~= nil then
        self._currentState:dispose();
        self._currentState = nil
    end
end

function PlayerFSM:getPlayer()
    return self._player
end

function PlayerFSM:getCurrentState()
    return self._currentState;
end

-- 判断状态
function PlayerFSM:isState(name)
    if self._currentState._name == name then
        return true
    else 
        return false
    end
end

--切换状态
function PlayerFSM:enterState(stateClassName)
    Logger.debug("EnterPlayerState : %s", stateClassName)
    local oldState = self._currentState
    local stateClass = require("app.gameMode.mahjong.processor.playerFSM."..stateClassName)
    self._currentState = stateClass:new(self);

    -- Prepare
    if oldState ~= nil then
        oldState:prepareExit();
    end

    self._currentState:prepareEnter();

    -- Do change state
    if oldState ~= nil then
        oldState:exit();
    end

    self._currentState:enter();

    -- Done
    if oldState ~= nil then
        oldState:afterExit();
        oldState:dispose();
        oldState = nil;
    end

    self._currentState:afterEnter();
    return self._currentState;
end

return PlayerFSM
