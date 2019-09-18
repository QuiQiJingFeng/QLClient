local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleBottomItem = class("UIBattleHandleBottomItem",app.UIBattleHandleItemBase,UITableViewCell,function() 
    return app.Util:loadCSBNode("csb/mengya/battle/mahjong/bottom/BottomItem.csb")
end)

return UIBattleHandleBottomItem
