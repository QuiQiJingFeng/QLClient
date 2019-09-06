local CommandCenter = require("app.manager.CommandCenter")
-- local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local room = require("app.game.ui.RoomSettingDefine")

-- 子玩法
-- local GamePlay_Zhajinhua_GuiZhou_Normal = require("app.gameMode.zhajinhua.region.gamePlays.zhajinhua.GamePlay_Zhajinhua_GuiZhou_Normal")
-- local GamePlay_Douniu = require("app.gameMode.douniu.region.gamePlays.douniu.GamePlay_Douniu")
-- local GamePlay_TongBiNiuNiu = require("app.gameMode.douniu.region.gamePlays.douniu.GamePlay_TongBiNiuNiu")
-- local GamePlay_Zhajinniu = require("app.gameMode.zhajinhua.region.gamePlays.zhajinhua.GamePlay_Zhajinniu")
local GamePlay_Paodekuai = require("app.gameMode.paodekuai.region.gamePlays.guizhou.GamePlay_Paodekuai")

-- local area_gameplay_config_base = 
-- {
--     registRuleType = {},
--     roomSettings = {},
--     commonEvents = {},
--     UIConfig = {},
--     registCommands = {},
--     registReplayCommands = {},
--     registForbidPlay = {},
-- }

local poker_normal = class("poker_normal", area_gameplay_config_base)
poker_normal.gameType = {
    name = "扑克",
    gameTypes = {
        -- {
        --     -- gamePlayConfig = GamePlay_Douniu,
        --     id = "GAME_TYPE_R_DOUNIU",
        --     name = "斗牛",
        -- },
        -- {
        --     -- gamePlayConfig = GamePlay_TongBiNiuNiu,
        --     id = "GAME_TYPE_R_TONGBINIUNIU",
        --     name = "通比牛牛",
        -- },
        -- {
        --     -- gamePlayConfig = GamePlay_Zhajinhua_GuiZhou_Normal,
        --     id = "GAME_TYPE_ZHAJINHUA_GUIZHOU_NORMAL",
        --     name = "炸金花",
        -- },
        -- {
        --     -- gamePlayConfig = GamePlay_Zhajinniu,
        --     id = "GAME_TYPE_ZHAJINNIU",
        --     name = "炸金牛"
        -- },
        {
            -- gamePlayConfig = GamePlay_Paodekuai,
            id = "GAME_TYPE_PAODEKUAI",
            name = "跑得快"
        }
    },
    
    -- 能否分享战绩
    shareRecord = false,
    clubHelpTxt = [[there no text]]
}

-- for index, info in ipairs(poker_normal.gameType) do
--     local gamePlayConfig = info.gamePlayConfig
--     local strictReg = gamePlayConfig.registRuleType ~= nil 
--         and gamePlayConfig.registRuleType ~= nil 
--         and gamePlayConfig.roomSettings ~= nil 
--         and gamePlayConfig.commonEvents ~= nil 
--         and gamePlayConfig.UIConfig ~= nil 
--         and gamePlayConfig.registCommands ~= nil 
--         and gamePlayConfig.registReplayCommands ~= nil 
--         and gamePlayConfig.registForbidPlay ~= nil
--     if Macro.assertFalse(strictReg, "你错误的配置了某个表名") then
--         table.merge(poker_normal.registRuleType,        gamePlayConfig.registRuleType)
--         table.merge(poker_normal.registRuleType,        gamePlayConfig.registRuleType)
--         table.merge(poker_normal.roomSettings,          gamePlayConfig.roomSettings)
--         table.merge(poker_normal.commonEvents,          gamePlayConfig.commonEvents)
--         table.merge(poker_normal.UIConfig,              gamePlayConfig.UIConfig)
--         table.merge(poker_normal.registCommands,        gamePlayConfig.registCommands)
--         table.merge(poker_normal.registReplayCommands,  gamePlayConfig.registReplayCommands)
--         table.merge(poker_normal.registForbidPlay,      gamePlayConfig.registForbidPlay)
--     end
-- end

poker_normal.registRuleType = {}
-- table.merge(poker_normal.registRuleType, GamePlay_Zhajinhua_GuiZhou_Normal.registRuleType)
-- table.merge(poker_normal.registRuleType, GamePlay_Douniu.registRuleType)
-- table.merge(poker_normal.registRuleType, GamePlay_TongBiNiuNiu.registRuleType)
-- table.merge(poker_normal.registRuleType, GamePlay_Zhajinniu.registRuleType)
table.merge(poker_normal.registRuleType, GamePlay_Paodekuai.registRuleType)

poker_normal.roomSettings = {
    -- GamePlay_Zhajinhua_GuiZhou_Normal.roomSetting,
    -- GamePlay_Douniu.roomSetting,
    -- GamePlay_TongBiNiuNiu.roomSetting,
    -- GamePlay_Zhajinniu.roomSetting,
    GamePlay_Paodekuai.roomSetting
}

poker_normal.commonEvents = {
    -- ["GamePlay_Zhajinhua_GuiZhou_Normal"] = GamePlay_Zhajinhua_GuiZhou_Normal.commonEvent,
    ["GAME_TYPE_PAODEKUAI"] = GamePlay_Paodekuai.commonEvent
}

poker_normal.UIConfig = {}
-- table.merge(poker_normal.UIConfig, GamePlay_Zhajinhua_GuiZhou_Normal.UIConfig)
-- table.merge(poker_normal.UIConfig, GamePlay_Douniu.UIConfig)
-- table.merge(poker_normal.UIConfig, GamePlay_TongBiNiuNiu.UIConfig)
-- table.merge(poker_normal.UIConfig, GamePlay_Zhajinniu.UIConfig)
table.merge(poker_normal.UIConfig, GamePlay_Paodekuai.UIConfig)

function poker_normal.registCommands(gameType)
    local cmds = {
        -- ["UI_GAME_TYPE_ZHAJINHUA_GUIZHOU_NORMAL"] = GamePlay_Zhajinhua_GuiZhou_Normal.commands,
        -- ["GAME_TYPE_R_GUIYANG"] = GamePlay_Zhajinhua_GuiZhou_Normal.commands,

        -- ["GAME_TYPE_ZHAJINHUA_GUIZHOU_NORMAL"] = GamePlay_Zhajinhua_GuiZhou_Normal.commands,
        -- ["GAME_TYPE_R_DOUNIU"] = {},
        -- ["GAME_TYPE_R_TONGBINIUNIU"] = {},
        -- ["GAME_TYPE_ZHAJINNIU"] = GamePlay_Zhajinniu.commands,
        ["GAME_TYPE_PAODEKUAI"] = GamePlay_Paodekuai.commands,
    }
    CommandCenter.getInstance():unregistAll()
    CommandCenter.getInstance():registCommands(cmds[gameType])
end

function poker_normal.registReplayCommands(gameType)
    local cmds = {
        -- ["UI_GAME_TYPE_ZHAJINHUA_GUIZHOU_NORMAL"] = GamePlay_Zhajinhua_GuiZhou_Normal.replayCommands,
        -- ["GAME_TYPE_ZHAJINHUA_GUIZHOU_NORMAL"] = GamePlay_Zhajinhua_GuiZhou_Normal.replayCommands,
    }
    CommandCenter.getInstance():unregistAll()
    CommandCenter.getInstance():registCommands(cmds[gameType])
end

poker_normal.registForbidPlay = {
    {name = ""}
}

poker_normal.getGameUI = function ( gamePlay, uiType )
    local uis = {
        -- ["GAME_TYPE_ZHAJINHUA_GUIZHOU_NORMAL"] = GamePlay_Zhajinhua_GuiZhou_Normal.registGameUI,
        -- ["GAME_TYPE_R_DOUNIU"] = GamePlay_Douniu.registGameUI,
        -- ["GAME_TYPE_R_TONGBINIUNIU"] = GamePlay_TongBiNiuNiu.registGameUI,
        -- ["GAME_TYPE_ZHAJINNIU"] = GamePlay_Zhajinniu.registGameUI,
        ["GAME_TYPE_PAODEKUAI"] = GamePlay_Paodekuai.registGameUI
    }
    local registGameUi = uis[gamePlay][uiType]
    if Macro.assertFalse(registGameUi ~= nil, 'gameplay = %s, uiType = %s, getRegistGameUI == nil', gamePlay or 'unknow', uiType or 'unknow') then
        return registGameUi
    end
end

return poker_normal 