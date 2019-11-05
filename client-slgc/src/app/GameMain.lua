--------------------------------------------
-- 游戏总入口, 控制整个游戏生命周期.
--------------------------------------------
local GameMain = class("GameMain",function() return cc.Scene:create() end)

-- 单例支持
local _instance = nil

function GameMain.create()
    if _instance ~= nil then
        return false
    end

    _instance = GameMain.new()
    _instance:init()
end

function GameMain.destroy()
    if _instance == nil then
        return
	end

    _instance:dispose()
    _instance = nil
end

function GameMain.getInstance()
    return _instance
end

function GameMain:ctor()
    -- 注册场景回调
	self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end)
end

function GameMain:init()
    display.runScene(self)
end

function GameMain:dispose()
end

function GameMain:onEnter()
    game.GameFSM:getInstance():enterState("GameState_Splash")
end

function GameMain:onExit()
end

return GameMain
