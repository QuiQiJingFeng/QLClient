local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIBattleHandleItemBase = import("items.UIBattleHandleItemBase")
local UIBattleHandleBottomItem = class("UIBattleHandleBottomItem",UIBattleHandleItemBase,UITableViewCell,function() 
    return Util:loadCSBNode("csb/mengya/battle/mahjong/bottom/BottomItem.csb")
end)

return UIBattleHandleBottomItem
