local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIBattleHandleItemBase = import("items.UIBattleHandleItemBase")
local UIBattleHandleTopItem = class("UIBattleHandleTopItem",UIBattleHandleItemBase,UITableViewCell,function() 
    return Util:loadCSBNode("csb/mengya/battle/mahjong/top/TopItem.csb")
end)

function UIBattleHandleTopItem:updateData(data)
    self:setLocalZOrder(100 - self:getIdx())
    return self.super.updateData(self,data)
end


return UIBattleHandleTopItem
