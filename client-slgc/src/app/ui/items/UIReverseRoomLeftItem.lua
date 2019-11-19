local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIReverseRoomLeftItem = class("UIReverseRoomLeftItem",UITableViewCell)
local UIManager = game.UIManager

function UIReverseRoomLeftItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
    self._cbxForbid = Util:seekNodeByName(self,"cbxForbid","ccui.CheckBox")
    self._cbxForbid:setVisible(false)
end

-- 整体设置数据
function UIReverseRoomLeftItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIReverseRoomLeftItem