--[[
    @desc: PropObject 礼包实例
    author:{贺逸}
    time:2018-05-14
]]
local super = require("app.game.service.prop.PropObject")

local GiftObject = class("GiftObject",super)

function GiftObject:ctor()
    super.ctor(self)
end

function GiftObject:excute()
    UIManager:getInstance():show("UIBackpackGiftDetail",self)
    return true
end

return GiftObject