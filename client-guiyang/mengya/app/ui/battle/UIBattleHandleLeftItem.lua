local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleLeftItem = class("UIBattleHandleLeftItem",app.UIBattleHandleItemBase,UITableViewCell,function() 
    return app.Util:loadCSBNode("csb/mengya/battle/mahjong/left/LeftItem.csb")
end)


return UIBattleHandleLeftItem
