local GameService = require("app.gameMode.zhengshangyou.GameService_ZhengShangYouReplay")

local super = require("app.game.gameState.GameState_InGame")
local GameState_ZhengShangYouReplay = class("GameState_ZhengShangYouReplay", super)

---------------------------
function GameState_ZhengShangYouReplay:ctor(parent)
    super.ctor(self, parent)
end

function GameState_ZhengShangYouReplay:enter()
    super.enter(self)
    
    -- 构造打牌用上下文
    gameMode.mahjong.Context.create();
    
    -- 显示房间界面	
    local gameScene = UIManager:getInstance():show("UIGameScene_ZhengShangYou");
    -- 创建GameService
    self._gameService = GameService.new()
    gameMode.mahjong.Context.getInstance():setGameService(self._gameService)
    self._gameService:initialize(gameScene)

    -- 需要关注service
    UIManager:getInstance():show("UIPlayback");
end

function GameState_ZhengShangYouReplay:exit()
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
function GameState_ZhengShangYouReplay:startReplay(followPlayerId, roomRecord, replayData, recordIndex)
    self._gameService:startReplay(followPlayerId, roomRecord, replayData, recordIndex);
end

return GameState_ZhengShangYouReplay