local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIClubDataStatisticsItem = class("UIClubDataStatisticsItem",UITableViewCell)
local UIManager = app.UIManager

function UIClubDataStatisticsItem:init()
    self._txtName = Util:seekNodeByName(self,"txtName","ccui.TextBMFont")
end

-- 整体设置数据
function UIClubDataStatisticsItem:updateData(data)
    self._txtName:setString(data.name)
end
 

return UIClubDataStatisticsItem