local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UICreateRoomLeftItem = class("UICreateRoomLeftItem",UITableViewCell)
local UIManager = game.UIManager

function UICreateRoomLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
end

-- 整体设置数据
function UICreateRoomLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UICreateRoomLeftItem