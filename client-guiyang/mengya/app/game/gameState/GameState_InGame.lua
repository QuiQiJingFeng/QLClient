--[[
所有可以获取玩家数据的游戏状态的父类, 统一处理一些流程相关操作
--]]
local UIManager = app.UIManager
local super = app.GameStateBase
local GameState_InGame = class("GameState_InGame", super)

function GameState_InGame:ctor()
end

function GameState_InGame:enter()
	-- app.service.LoginService.getInstance():addEventListener("USER_DATA_RETRIVED", handler(self, self._onUserDataRefreshed), self);
	-- app.service.LoginService.getInstance():addEventListener("USER_LOGOUT", handler(self, self._onUserLogout), self);
end

function GameState_InGame:exit()    
	-- app.service.LoginService.getInstance():removeEventListenersByTag(self);
end

-- 当重新获取玩家数据时被调用
function GameState_InGame:_onUserDataRefreshed()
	-- 重载的函数没有调用这里
end

-- 当用户登出时被调用
function GameState_InGame:_onUserLogout()
	GameFSM.getInstance():enterState("GameState_Login")
end

return GameState_InGame