local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIShopLeftItem = class("UIShopLeftItem",UITableViewCell)
local UIManager = app.UIManager

function UIShopLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
end

function UIShopLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIShopLeftItem