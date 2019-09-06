--[[
    比赛有限状态机
        受Campaign service 驱动
        改变状态时，隐藏上个状态的ui，显示(或新建)这个状态的ui，并广播状态切换的事件
        改变状态是，网络消息也可以放状态机里？？？（待实现时考察）
        do something ...
---------------------
Event:
    Campaign_STATE_CHANGING -- 状态切换
--]]
local ns = namespace("campaign")

local CampaignFSM = class("CampaignFSM")
ns.CampaignFSM = CampaignFSM

-------------------------
-- 单例支持
local _instance = nil;

function CampaignFSM:destroy()
    if _instance == nil then
        return;
    end

    _instance:dispose();
    _instance = nil;
end

function CampaignFSM:getInstance()
    if _instance == nil then
        _instance = CampaignFSM:new();
    end
    
    return _instance;
end

--------------------------
function CampaignFSM:ctor()
	cc.bind(self,"event");
	
    self._currentState = nil
end

function CampaignFSM:dispose()
	cc.unbind(self,"event");
	
    if self._currentState ~= nil then
        self._currentState:dispose();
        self._currentState = nil
    end
end

function CampaignFSM:getCurrentState()
    return self._currentState;
end

-- 判断状态
function CampaignFSM:isState(name)
    if self._currentState._name == name then
        return true
    else 
        return false
    end
end

--切换状态
function CampaignFSM:enterState(stateClassName)
    Logger.debug("EnterState : %s", stateClassName)
    local oldState = self._currentState
    local stateClass = require("app.game.campaign.campaignStates."..stateClassName)
    self._currentState = stateClass:new(self);

    self:dispatchEvent({name = "CAMPAIGN_STATE_CHANGING", 
                        old = oldState ~= nil and oldState:getName() or nil, 
                        current = self._currentState:getName()});

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

    self:dispatchEvent({name = "CAMPAIGN_STATE_CHANGED", current = self._currentState:getName()});

    return self._currentState;
end
