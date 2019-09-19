local super = app.UIBattleDiscardItemBase
local UIBattleDiscardTopItem = class("UIBattleDiscardTopItem",super)

function UIBattleDiscardTopItem:updateData(data)
    self.super.updateData(self,data)
    self._imgBg = app.Util:seekNodeByName(self,"imgBg","ccui.ImageView")

    self:setLocalZOrder(100 - self:getIdx())
end
 

return UIBattleDiscardTopItem