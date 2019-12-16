local super = import("items.UIBattleDiscardItemBase")
local UIBattleDiscardRightItem = class("UIBattleDiscardRightItem",super)

function UIBattleDiscardRightItem:updateData(data)
    self.super.updateData(self,data)
    self:setLocalZOrder(100 - self:getIdx())
end
 

return UIBattleDiscardRightItem