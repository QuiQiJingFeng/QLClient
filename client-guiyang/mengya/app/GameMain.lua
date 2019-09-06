--------------------------------------------
-- 游戏总入口, 控制整个游戏生命周期.
--------------------------------------------
local GameMain = class("GameMain", function() return cc.Scene:create() end)

-- 构造函数
function GameMain:ctor()
    -- 注册场景回调
	self:registerScriptHandler(function(event)
        if "enter" == event then
            self:initialize()
        end
    end)

    cc.Director:getInstance():runWithScene(self)
    app.AudioManager:getInstance():playMusic("sound/BGM/bgm.mp3", true)
end

-- 初始化
-- @return boolean
function GameMain:initialize()
    app.GameFSM:getInstance():enterState("GameState_Splash")
end

return GameMain
