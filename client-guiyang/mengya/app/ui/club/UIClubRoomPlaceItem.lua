local Util = app.Util

local UIFreeListItem = app.UIFreeListItem
local UIClubRoomPlaceItem = class("UIClubRoomPlaceItem",UIFreeListItem)
function UIClubRoomPlaceItem:init()
    self._imgFace = Util:seekNodeByName(self,"imgFace","ccui.ImageView")
    self._imgBack = Util:seekNodeByName(self,"imgBack","ccui.ImageView")
    self._btnWatcher = Util:seekNodeByName(self,"btnWatcher","ccui.Button")
    self._btnJoinRoom = Util:seekNodeByName(self,"btnJoinRoom","ccui.Button")
    self._imgWaite = Util:seekNodeByName(self,"imgWaite","ccui.ImageView")
end

-- 整体设置数据
function UIClubRoomPlaceItem:updateData(data)
end
 

return UIClubRoomPlaceItem