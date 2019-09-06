local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIHeadFrameShopItem = class("UIHeadFrameShopItem",UITableViewCell)
local UIManager = app.UIManager
local UIAnimationManager = app.UIAnimationManager

function UIHeadFrameShopItem:init()
    self._imgOwn = Util:seekNodeByName(self,"imgOwn","ccui.ImageView")
    self._imgUsing = Util:seekNodeByName(self,"imgUsing","ccui.ImageView")
    self._imgBoarder = Util:seekNodeByName(self,"imgBoarder","ccui.ImageView")
    self._imgLock = Util:seekNodeByName(self,"imgLock","ccui.ImageView")
    self._imgIcon = Util:seekNodeByName(self,"imgIcon","ccui.ImageView")
end

function UIHeadFrameShopItem:updateData(data)
    local size = self._imgIcon:getContentSize()
    local x = size.width/2
    local y = size.height/2


    UIAnimationManager:getInstance():playAnimationWithParent(self._imgIcon,nil,data.path,nil,cc.p(x,y),nil,nil,nil,true)
    self._imgLock:setVisible(false)
    self._imgBoarder:setVisible(false)
    self._imgUsing:setVisible(false)
    self._imgOwn:setVisible(false)
end
 

return UIHeadFrameShopItem