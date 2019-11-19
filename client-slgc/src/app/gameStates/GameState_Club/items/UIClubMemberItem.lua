local Util = game.Util

local UITableViewCell = game.UITableViewCell
local UIClubMemberItem = class("UIClubMemberItem",UITableViewCell)
local UIManager = game.UIManager
 
function UIClubMemberItem:init()
    self._btnOperate = Util:seekNodeByName(self,"btnOperate","ccui.Button")
    Util:bindTouchEvent(self._btnOperate,handler(self,self._onBtnOperateClick))
end

function UIClubMemberItem:_onBtnOperateClick()
    UIManager:getInstance():show("views.UIClubMemberSetting")
end

-- 整体设置数据
function UIClubMemberItem:updateData(data)
end
 

return UIClubMemberItem