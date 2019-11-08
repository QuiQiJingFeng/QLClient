local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIHelpLeftItem = class("UIHelpLeftItem",UITableViewCell)
local UIManager = game.UIManager

function UIHelpLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
end

function UIHelpLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIHelpLeftItem