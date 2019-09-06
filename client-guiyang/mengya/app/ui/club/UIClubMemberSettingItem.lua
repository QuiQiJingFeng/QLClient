local Util = app.Util

local UITableViewCell = app.UITableViewCell
local UIClubMemberSettingItem = class("UIClubMemberSettingItem",UITableViewCell)
local UIManager = app.UIManager
 
function UIClubMemberSettingItem:init()
    self._txtBmfTitle = Util:seekNodeByName(self,"txtBmfTitle","ccui.TextBMFont")
end

-- 整体设置数据
function UIClubMemberSettingItem:updateData(data)
    self._txtBmfTitle:setString(data.name)
end
 

return UIClubMemberSettingItem