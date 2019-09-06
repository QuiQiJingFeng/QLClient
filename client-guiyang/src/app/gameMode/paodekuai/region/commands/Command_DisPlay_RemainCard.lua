
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.paodekuai.core.Constants_Paodekuai"

local Command_DisPlay_RemainCard = class("Command_DisPlay_RemainCard", super)
function Command_DisPlay_RemainCard:ctor(args)
    self.super.ctor(self, args)
end

function Command_DisPlay_RemainCard:execute(args)
    local step = self._stepGroup[1]
    local cardCount = step:getCards()[1] or 0
    local uiPlayer = self._processor:getUIPlayer()
    uiPlayer:setCardRemainNum(cardCount)
end

return Command_DisPlay_RemainCard