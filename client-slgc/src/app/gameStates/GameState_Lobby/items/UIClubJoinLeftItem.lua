local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIClubJoinLeftItem = class("UIClubJoinLeftItem",UITableViewCell)
local UIManager = game.UIManager

function UIClubJoinLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
    self._imgRed = Util:seekNodeByName(self,"imgRed","ccui.ImageView")

end

-- 整体设置数据
function UIClubJoinLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIClubJoinLeftItem