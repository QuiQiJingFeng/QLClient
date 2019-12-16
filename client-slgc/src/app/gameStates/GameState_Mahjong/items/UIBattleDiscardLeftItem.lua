local super = import("items.UIBattleDiscardItemBase")
local UIBattleDiscardLeftItem = class("UIBattleDiscardLeftItem",super)

function UIBattleDiscardLeftItem:updateData(data)
    self.super.updateData(self,data)
    self:setLocalZOrder(self:getIdx())
end
 

return UIBattleDiscardLeftItem