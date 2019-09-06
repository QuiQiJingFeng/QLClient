
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.paodekuai.core.Constants_Paodekuai"

local Command_Unimplement = class("Command_Unimplement", super)
function Command_Unimplement:ctor(args)
    self.super.ctor(self, args)
end

function Command_Unimplement:execute(args)
    assert(false)
end

return Command_Unimplement