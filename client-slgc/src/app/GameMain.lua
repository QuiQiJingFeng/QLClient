--------------------------------------------
-- 游戏总入口, 控制整个游戏生命周期.
--------------------------------------------
local GameMain = class("GameMain",function() return cc.Scene:create() end)

-- 单例支持
local _instance = nil

function GameMain.create(callBack)
    if _instance ~= nil then
        return false
    end

    _instance = GameMain.new()
    _instance:init(callBack)
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

function GameMain:ctor(callBack)
    -- 注册场景回调
	self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter(callBack)
        elseif "exit" == event then
            self:onExit()
        end
    end)
end

function GameMain:init()
    game.AudioManager.getInstance():playMusic("sound/BGM/bgm.mp3", true)
    display.runScene(self)

    if device.platform == "android" then
        -- self.touchLayer = display.newLayer()
        -- self.touchLayer:addTouchEventListener(cc.KEYPAD_EVENT, function(event)
        --     if event.key == "back" then  
        --         luaj.callStaticMethod("com/mengya/game", "checkExitGame")
        --     end
        -- end)
        -- self.touchLayer:setKeypadEnabled(true)
        -- self:addChild(self.touchLayer)
    end 
end

function GameMain:dispose()
end

function GameMain:onEnter(callBack)
    if callBack then
        callBack()
    end
    game.GameFSM:getInstance():enterState("GameState_Splash")
end

function GameMain:onExit()
end

return GameMain
