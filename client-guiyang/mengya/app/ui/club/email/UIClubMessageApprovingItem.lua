local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIClubMessageApprovingItem = class("UIClubMessageApprovingItem",UITableViewCell)
local UIManager = app.UIManager

function UIClubMessageApprovingItem:init()
    self._txtRoleName = Util:seekNodeByName(self,"txtRoleName","ccui.Text")
    self._txtRoleId = Util:seekNodeByName(self,"txtRoleId","ccui.Text")
    self._txtApplyDate = Util:seekNodeByName(self,"txtApplyDate","ccui.Text")
    self._txtEnterMethod = Util:seekNodeByName(self,"txtEnterMethod","ccui.Text")
    self._imgStateOK = Util:seekNodeByName(self,"imgStateOK","ccui.ImageView")
    self._btnOK = Util:seekNodeByName(self,"btnOK","ccui.Button")
    self._btnRefuse = Util:seekNodeByName(self,"btnRefuse","ccui.ImageView")
end

-- 整体设置数据
function UIClubMessageApprovingItem:updateData(data)
    
end
 

return UIClubMessageApprovingItem