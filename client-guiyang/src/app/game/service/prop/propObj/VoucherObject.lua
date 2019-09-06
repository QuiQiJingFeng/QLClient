--[[
    @desc: PropObject 门票实例
    author:{贺逸}
    time:2018-05-14
]]
local super = require("app.game.service.prop.PropObject")

local VoucherObject = class("VoucherObject",super)

function VoucherObject:ctor()
    super.ctor(self)
end

function VoucherObject:excute()
    super.excute(self)
    UIManager:getInstance():show("UIVoucherDetail", self)
    return true
end

return VoucherObject