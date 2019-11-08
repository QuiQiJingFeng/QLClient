local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIShopItem = class("UIShopItem",UITableViewCell)
local UIManager = game.UIManager

function UIShopItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
    self._txtBmfCost = Util:seekNodeByName(self,"txtBmfCost","ccui.TextBMFont")
    self._imgItem = Util:seekNodeByName(self,"imgItem","ccui.ImageView")
end

function UIShopItem:updateData(data)
    self._txtBmfTitle:setString(data.title)
    self._txtBmfCost:setString(data.cost)
    self._imgItem:loadTexture(data.icon)
end
 

return UIShopItem