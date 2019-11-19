local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIClubMessageOperationItem = class("UIClubMessageOperationItem",UITableViewCell)
local UIManager = game.UIManager

function UIClubMessageOperationItem:init()
    self._txtMessageTime = Util:seekNodeByName(self,"txtMessageTime","ccui.Text")
    self._txtMessageContent = Util:seekNodeByName(self,"txtMessageContent","ccui.Text")
end

-- 整体设置数据
function UIClubMessageOperationItem:updateData(data)
    
end
 

return UIClubMessageOperationItem