local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIBattleHandleItemBase = import("items.UIBattleHandleItemBase")
local UIBattleHandleLeftItem = class("UIBattleHandleLeftItem",UIBattleHandleItemBase,UITableViewCell,function() 
    return Util:loadCSBNode("csb/mengya/battle/mahjong/left/LeftItem.csb")
end)


return UIBattleHandleLeftItem
