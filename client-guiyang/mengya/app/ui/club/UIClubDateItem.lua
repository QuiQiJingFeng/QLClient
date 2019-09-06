local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIClubDateItem = class("UIClubDateItem",UITableViewCell)
local UIManager = app.UIManager

function UIClubDateItem:init()
    self._txtBmfDate = Util:seekNodeByName(self,"txtBmfDate","ccui.TextBMFont")
end

-- 整体设置数据
function UIClubDateItem:updateData(data)
    self._txtBmfDate:setString(Util:getFormatDate("%m-%d",data.time))
    self:setSelected(data.selected)
end
 

return UIClubDateItem