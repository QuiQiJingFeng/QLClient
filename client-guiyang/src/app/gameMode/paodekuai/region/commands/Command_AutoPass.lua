
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.paodekuai.core.Constants_Paodekuai"

local Command_AutoPass = class("Command_AutoPass", super)
function Command_AutoPass:ctor(args)
    Command_AutoPass.super.ctor(self, args)
end

function Command_AutoPass:execute(args)
    local step = self._stepGroup[1]
    local playType = step:getPlayType()
    
    local isWatcher = game.service.LocalPlayerService:getInstance():isWatcher()
    local isReplay = gameMode.mahjong.Context.getInstance():getGameService():isInReplay()
    if isWatcher or isReplay then
        return
    end

    if Constants.PlayType.POKER_OPERATE_AUTO_PASS == playType then
        if self._processor:getPlayerInfo().cPosition == 1 then
            -- 没有大过的牌， 直接PASS
            local uiTableOptions = self._processor:getUITableOptions()
            uiTableOptions:cleanUp()
            scheduleOnce(function() 
                self._processor:autoPass()
            end, 0.5, uiTableOptions._root)
            Logger.debug("====AUTO PASS  ---- NOT HAVE CARD MORE THAN LAST CARD")
        end
    end
end

return Command_AutoPass