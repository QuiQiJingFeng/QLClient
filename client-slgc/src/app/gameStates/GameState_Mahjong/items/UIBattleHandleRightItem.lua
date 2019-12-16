local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIBattleHandleItemBase = import("items.UIBattleHandleItemBase")
local UIBattleHandleRightItem = class("UIBattleHandleRightItem",UIBattleHandleItemBase,UITableViewCell,function() 
    return Util:loadCSBNode("csb/mengya/battle/mahjong/right/RightItem.csb")
end)

function UIBattleHandleRightItem:updateData(data)
    self:setLocalZOrder(100 - self:getIdx())
    return self.super.updateData(self,data)
end


return UIBattleHandleRightItem
