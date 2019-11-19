local Util = game.Util

local UITableViewCell = game.UITableViewCell
local UIClubMemberSettingItem = class("UIClubMemberSettingItem",UITableViewCell)
local UIManager = game.UIManager
 
function UIClubMemberSettingItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
end

-- 整体设置数据
function UIClubMemberSettingItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIClubMemberSettingItem