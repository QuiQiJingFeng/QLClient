local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UICreateRoomLeftItem = class("UICreateRoomLeftItem",UITableViewCell)
local UIManager = app.UIManager

function UICreateRoomLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
end

-- 整体设置数据
function UICreateRoomLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UICreateRoomLeftItem