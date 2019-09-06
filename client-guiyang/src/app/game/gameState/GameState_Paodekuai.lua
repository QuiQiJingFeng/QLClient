local super = require("app.game.gameState.GameState_InGame")
local GameState_Paodekuai = class("GameState_Paodekuai",super)
local GameService_Paodekuai = require("app.gameMode.paodekuai.GameService_Paodekuai")

function GameState_Paodekuai:ctor(parent)
    super.ctor(self, parent)
    
    self._gameService = nil
end

function GameState_Paodekuai:enter()
    super.enter(self)
    gameMode.mahjong.Context.create()

    local roomService = game.service.RoomService.getInstance();
    local uiName = "UIPlayerScene_btns";
    if game.service.LocalPlayerService:getInstance():isWatcher() then
         uiName = "UIPlayerScene_watch_btns";
    end
    -- 显示房间界面
    local gameScene = UIManager:getInstance():show("UIGameScene_Paodekuai");
    UIManager:getInstance():show(uiName, roomService:isRTVoiceRoom());
    -- 创建GameService
    self._gameService = GameService_Paodekuai.new()
    gameMode.mahjong.Context.getInstance():setGameService(self._gameService)
    self._gameService:initialize(gameScene)

    -- 清空一下剪贴板  （防止自己创建的房间自己复制出现加入房间的情况）
    game.plugin.Runtime.setClipboard("")
    game.service.ChatService:getInstance():setDialect(config.ChatConfig.DialectType.PAODEKUAI)
end

function GameState_Paodekuai:exit()
    super.exit(self)
    
    -- 销毁GameService
    if Macro.assetFalse(self._gameService ~= nil) then
        self._gameService:dispose()
        self._gameService = nil;
    end

    -- 销毁上下文
    gameMode.mahjong.Context.destroy();
end

--[[
    当在牌局内重连的时候，若重连后牌局已不存在，则通过此handler来进入大厅或者亲友圈
]]
function GameState_Paodekuai:_onUserDataRefreshed()
    
    scheduleOnce(function()
        -- roomService有可能为空的！
        if game.service.RoomService:getInstance() then
            game.service.RoomService:getInstance():enterNextGameState()
        else
            GameFSM:getInstance():enterState("GameState_Lobby");
        end
    end, 0)	
end

return GameState_Paodekuai
