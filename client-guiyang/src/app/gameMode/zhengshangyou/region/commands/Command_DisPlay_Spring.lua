
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.zhengshangyou.core.Constants_ZhengShangYou"
local UIAnimManager = require("app.manager.UIAnimManager")

local Command_DisPlay_Spring = class("Command_DisPlay_Spring", super)
function Command_DisPlay_Spring:ctor(args)
    Command_DisPlay_Spring.super.ctor(self, args)
end

local ANIM_PATH = {
    [Constants.PlayType.POKER_DISPLAY_SPRING] = "ui/csb/GamePlays/zhengshangyou/Pktx_chuntian.csb"
}

function Command_DisPlay_Spring:execute(args)
    local step = self._stepGroup[1]
    local playType = step:getPlayType()
    local roleId = step:getRoleId()

    if Constants.PlayType.POKER_DISPLAY_SPRING == playType then
        local path = ANIM_PATH[playType]
        if path then
            local gameScene = UIManager:getInstance():getUI("UIGameScene_ZhengShangYou")
            UIAnimManager.UIAnimManager:getInstance():onShow({
                _path = path,
                _replay = false,
                _parent = gameScene
            })

        end
    end
end

return Command_DisPlay_Spring
