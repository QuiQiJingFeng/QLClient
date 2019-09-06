--[[
打牌时用的上下文, 用于存储牌局过程中的单例
--]]
local ns = namespace("gameMode.mahjong")

local Context = class("Context")
ns.Context = Context;

-------------------------
-- 单例支持
local _instance = nil;

-- @return boolean
function Context.create()
    if _instance ~= nil then
        return false;
    end

    _instance = Context.new();
    return true;
end

function Context.destroy()
    if _instance == nil then
        return;
    end
    _instance = nil;
end

function Context.getInstance()
    return _instance;
end

-------------------------
function Context:ctor()
	self._gameService = nil
end

-- GameService单例
function Context:getGameService()				return self._gameService; end
function Context:setGameService(gameService)	self._gameService = gameService; end