local enum = net.protocol.CGoldMatchREQ.Enum_RoomGrade
local RoomGradeSloganResPathConfig = {
    [enum.SECOND] = "art/gold/img_jblhhc.png",
    [enum.THIRD] = "art/gold/img_jblzgc.png",
    [enum.FOUR] = "art/gold/img_jblqsc.png",
}
local super = require("app.game.ui.gold.quick_charge.UIGoldQuickCharge_Luck")
local csbPath = 'ui/csb/Gold/QuickCharge/UIGoldQuickCharge_Luck_Downgrade.csb'
local M = class("UIGoldQuickCharge_Luck_Downgrade", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor(...)
    super.ctor(self, ...)
    self._imgRoomGrade = seekNodeByName(self, "ImageView_Room_Grade", "ccui.ImageView")
end

function M:onShow(...)
    super.onShow(self, ...)

    local grade = game.service.GoldService.getInstance():getCurrentRoomGrade()
    local resPath = RoomGradeSloganResPathConfig[grade]
    if resPath then
        self._imgRoomGrade:loadTexture(resPath)
    end
    self._imgRoomGrade:setVisible(resPath ~= nil)
end

return M