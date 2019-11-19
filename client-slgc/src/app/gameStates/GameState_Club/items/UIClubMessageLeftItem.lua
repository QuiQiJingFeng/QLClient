local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIClubMessageLeftItem = class("UIClubMessageLeftItem",UITableViewCell)
local UIManager = game.UIManager

function UIClubMessageLeftItem:init()
    self._txtBmfCbxTitle = Util:seekNodeByName(self,"txtBmfCbxTitle","ccui.TextBMFont")
    self._imgRed = Util:seekNodeByName(self,"imgRed","ccui.ImageView")
end

-- 整体设置数据
function UIClubMessageLeftItem:updateData(data)
    self._txtBmfCbxTitle:setString(data.name)
    self._imgRed:setVisible(data.isRed and true or false)
end

return UIClubMessageLeftItem