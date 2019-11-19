local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIClubMessageEmailItem = class("UIClubMessageEmailItem",UITableViewCell)
local UIManager = game.UIManager

function UIClubMessageEmailItem:init()
    self._imgItemBg = Util:seekNodeByName(self,"imgItemBg","ccui.ImageView")
    self._imgItemBgGray = Util:seekNodeByName(self,"imgItemBgGray","ccui.ImageView")
    self._mailIcon = Util:seekNodeByName(self,"mailIcon","ccui.ImageView")
    self._mailIconGray = Util:seekNodeByName(self,"mailIconGray","ccui.ImageView")

    self._imgRed = Util:seekNodeByName(self,"imgRed","ccui.ImageView")
    
    
    self._textMailTitle = Util:seekNodeByName(self,"textMailTitle","ccui.Text")
    self._textSummary = Util:seekNodeByName(self,"textSummary","ccui.Text")
    self._textDate = Util:seekNodeByName(self,"textDate","ccui.Text")

    self._btnDeleteAllRead = Util:seekNodeByName(self,"btnDeleteAllRead","ccui.Button")
end

-- 整体设置数据
function UIClubMessageEmailItem:updateData(data)
    
end
 

return UIClubMessageEmailItem