--[[
    联盟状态机
--]]
local super = require("app.game.gameState.GameState_InGame")

local GameState_League = class("GameState_League",super)

function GameState_League:ctor(parent)
    super.ctor(self, parent)
end

function GameState_League:enter()
    super.enter(self)

    if game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague() == false and game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId() == 0 then
        GameFSM.getInstance():enterState("GameState_Lobby")
    else
        local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
        if UIManager:getInstance():needRestore()  then
            UIManager:getInstance():restoreUIs("GameState_League")
            UIManager:getInstance():setNeedRestore(false)
        else
            UIManager:getInstance():show("UIBigLeagueMain")
        end
    end

    game.service.bigLeague.BigLeagueService:getInstance():addEventListener("EVENT_LEAGUE_MEMBER_TITLE_CHANGE", function ()
        game.ui.UIMessageBoxMgr.getInstance():show("您的权限发生变动" , {"确定"}, function ()
            GameFSM.getInstance():enterState("GameState_League")
        end, function()end, true)
    end, self)
end


function GameState_League:exit()
    super.exit(self)
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

return GameState_League