--[[
    @desc: PropObject 消耗类道具实例
    author:{贺逸}
    time:2018-10-18
]]
local super = require("app.game.service.prop.PropObject")

local ConsumableObject = class("ConsumableObject",super)

function ConsumableObject:ctor()
    super.ctor(self)
end

function ConsumableObject:excute(external)
    UIManager:getInstance():show("UIBackpackConsumable",self,external)
    return true
end

return ConsumableObject