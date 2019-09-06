--[[
麻将牌局状态, 这个状态中处理玩家打牌逻辑
--]]
local GameService = require("app.gameMode.mahjong.GameService_Mahjong")

local super = require("app.game.gameState.GameState_InGame")
local GameState_Mahjong = class("GameState_Mahjong", super)

---------------------------
function GameState_Mahjong:ctor(parent)
	self.super.ctor(self, parent)
	
	self._gameService = nil
end

function GameState_Mahjong:enter()
	super.enter(self)

	CardFactory:getInstance():realChange2or3D()
	
	-- 构造打牌用上下文
	gameMode.mahjong.Context.create();

	-- 开启语音相关设置
	local roomService = game.service.RoomService.getInstance();
	local uiName = "UIPlayerScene_btns";
	if game.service.LocalPlayerService:getInstance():isWatcher() then
		 uiName = "UIPlayerScene_watch_btns";
	end
	-- 显示房间界面
	local gameScene = UIManager:getInstance():show("app.gameMode.mahjong.ui.UIGameScene_Mahjong");
	UIManager:getInstance():show(uiName, roomService:isRTVoiceRoom());
	
	-- 创建GameService
	self._gameService = GameService.new()
	gameMode.mahjong.Context.getInstance():setGameService(self._gameService)
	self._gameService:initialize(gameScene)

	-- 监听战绩返回牌桌界面时，隐藏设置等按钮
	game.service.LocalPlayerService.getInstance():addEventListener("EVENT_ROOMCARD_HIDESETTIN", function(event)
		if event.isVisible == false then
			-- 房间界面一直缓存，只有有界面隐藏或者销毁都会把缓存的显示出来，这里要特殊处理一下，先把界面缓存中删除
			UIManager:getInstance():hide(uiName)
			UIManager:getInstance():hide("UIPlayerinfo2")
		else
			-- 接收到接听在显示出来
			UIManager:getInstance():show(uiName, roomService:isRTVoiceRoom());
		end
		
	end, self)

	-- 清空一下剪贴板  （防止自己创建的房间自己复制出现加入房间的情况）
	game.plugin.Runtime.setClipboard("")
    -- todo 这个其他地区会有问题，需要改下LOCAL的形式
	game.service.ChatService:getInstance():setDialect(config.ChatConfig.DialectType.LOCAL_GUIYANG)
end

function GameState_Mahjong:exit()
	super.exit(self)
	
	game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)

	-- 销毁GameService
	if Macro.assetFalse(self._gameService ~= nil) then
		self._gameService:dispose()
		self._gameService = nil;
	end

	-- 销毁上下文
	gameMode.mahjong.Context.destroy();
end

function GameState_Mahjong:_onUserDataRefreshed()
	-- 房间已经结束
	-- 切换State有会造成修改Handler, 下一针在调用
	
	scheduleOnce(function()
		-- roomService有可能为空的！
		if game.service.RoomService:getInstance() then
			game.service.RoomService:getInstance():enterNextGameState()
		else
			GameFSM:getInstance():enterState("GameState_Lobby");
		end
	end, 0)	
end

return GameState_Mahjong