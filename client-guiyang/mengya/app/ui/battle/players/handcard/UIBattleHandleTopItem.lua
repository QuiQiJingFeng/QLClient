local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleTopItem = class("UIBattleHandleTopItem",app.UIBattleHandleItemBase,UITableViewCell,function() 
    return app.Util:loadCSBNode("csb/mengya/battle/mahjong/top/TopItem.csb")
end)

function UIBattleHandleTopItem:updateData(data)
    self:setLocalZOrder(100 - self:getIdx())
    return self.super.updateData(self,data)
end


return UIBattleHandleTopItem
