local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleRightItem = class("UIBattleHandleRightItem",app.UIBattleHandleItemBase,UITableViewCell,function() 
    return app.Util:loadCSBNode("csb/mengya/battle/mahjong/right/RightItem.csb")
end)

function UIBattleHandleRightItem:updateData(data)
    self:setLocalZOrder(100 - self:getIdx())
    return self.super.updateData(self,data)
end


return UIBattleHandleRightItem
