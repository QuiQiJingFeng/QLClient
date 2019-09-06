local Util = app.Util

local UITableViewCell = app.UITableViewCell
local UIClubRoomItem = class("UIClubRoomItem",UITableViewCell)
local UIFreeList = app.UIFreeList
local UIClubRoomPlaceItem = app.UIClubRoomPlaceItem
local UIManager = app.UIManager
local MAX_PLAYER_NUM = 4
function UIClubRoomItem:init()
    self._txtDetail = Util:seekNodeByName(self,"txtDetail","ccui.Text")
    self._btnDetail = Util:seekNodeByName(self,"btnDetail","ccui.Button")
    local places = {}
    for pos = 1, MAX_PLAYER_NUM do
        local place = Util:seekNodeByName(self,"panelPlayerInfo"..pos,"ccui.Layout")
        table.insert(places,place)
    end
    self._places = UIFreeList.extend(places,UIClubRoomPlaceItem)

    Util:bindTouchEvent(self._btnDetail,handler(self,self._onBtnDetailClick))
end

function UIClubRoomItem:_onBtnDetailClick(data)
    UIManager:getInstance():show("UIClubRoomInfo")
end

-- 整体设置数据
function UIClubRoomItem:updateData(data)
end
 

return UIClubRoomItem