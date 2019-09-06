--[[
麻将牌局状态, 这个状态中处理玩家打牌逻辑
--]]

local GameService = require("app.gameMode.mahjong.GameService_MahjongReplay")

local super = require("app.game.gameState.GameState_InGame")
local GameState_MahjongReplay = class("GameState_MahjongReplay", super)

---------------------------
function GameState_MahjongReplay:ctor(parent)
	super.ctor(self, parent)	
end

function GameState_MahjongReplay:enter()
	super.enter(self)

	CardFactory:getInstance():realChange2or3D()
	
	-- 构造打牌用上下文
	gameMode.mahjong.Context.create();
	
	-- 显示房间界面	
	local gameScene = UIManager:getInstance():show("app.gameMode.mahjong.ui.UIGameScene_Mahjong");
	-- 创建GameService
	self._gameService = GameService.new()	
	gameMode.mahjong.Context.getInstance():setGameService(self._gameService)	
	self._gameService:initialize(gameScene)

	-- 需要关注service
	UIManager:getInstance():show("UIPlayback");	
end

function GameState_MahjongReplay:exit()
	super.exit(self)
	
	-- 销毁GameService
	self._gameService:dispose()
	self._gameService = nil;

	-- 销毁上下文
	gameMode.mahjong.Context.destroy();

	-- 关闭房间界面, 
	UIManager:getInstance():setNeedRestore(true)
end

-- 开始牌局回放
function GameState_MahjongReplay:startReplay(followPlayerId, roomRecord, replayData, recordIndex)
	self._gameService:startReplay(followPlayerId, roomRecord, replayData, recordIndex);
end

return GameState_MahjongReplay