
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.zhengshangyou.core.Constants_ZhengShangYou"

local Command_Unimplement = class("Command_Unimplement", super)
function Command_Unimplement:ctor(args)
    self.super.ctor(self, args)
end

function Command_Unimplement:execute(args)
    assert(false)
end

return Command_Unimplement