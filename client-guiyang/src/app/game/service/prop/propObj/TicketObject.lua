--[[
    @desc: PropObject 门票实例
    author:{贺逸}
    time:2018-05-14
]]
local super = require("app.game.service.prop.PropObject")

local TicketObject = class("TicketObject",super)

function TicketObject:ctor()
    super.ctor(self)
end

function TicketObject:excute()
    super.excute(self)
    return true
end

return TicketObject