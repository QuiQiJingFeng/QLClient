local CommandCenter = require("app.manager.CommandCenter")

local _utils = {}

local _addGamePlays = function ( area, gamePlays )
    area.roomSettings = {}
    area.commonEvents = {}
    area.UIConfig = {}
    local cmd = {}
    local cmdReplay = {}
    local uis = {}
    for name, gameplay in pairs(gamePlays) do
        table.insert( area.roomSettings, gameplay.roomSetting )
        area.commonEvents[name] = gameplay.commonEvent
        cmd[name] = gameplay.commands
        cmdReplay[name] = gameplay.replayCommands

        table.merge(area.UIConfig, gameplay.UIConfig)
        
        -- 有些地区可能没配
        if gameplay.registGameUI then
            uis[name] = gameplay.registGameUI
        end
        if gameplay.registRuleType then
            table.merge(area.registRuleType, gameplay.registRuleType)
        end
    end

    area.registCommands = function ( gameType )
        CommandCenter.getInstance():unregistAll()
        CommandCenter.getInstance():registCommands(cmd[gameType])
    end
    area.registReplayCommands = function ( gameType )
        CommandCenter.getInstance():unregistAll()
        CommandCenter.getInstance():registCommands(cmdReplay[gameType])
    end

    area.getGameUI = function ( gamePlay, uiType )
        local registGameUi = nil
        if uis[gamePlay] ~= nil then
            registGameUi = uis[gamePlay][uiType]
        end
        return registGameUi
    end
end

_utils.addGamePlays = _addGamePlays

return _utils