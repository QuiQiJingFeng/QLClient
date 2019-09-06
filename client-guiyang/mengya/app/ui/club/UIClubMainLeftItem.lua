local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIClubMainLeftItem = class("UIClubMainLeftItem",UITableViewCell)
local UIManager = app.UIManager

function UIClubMainLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
    self._imgRed = Util:seekNodeByName(self,"imgRed","ccui.ImageView")

end

-- 整体设置数据
function UIClubMainLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIClubMainLeftItem