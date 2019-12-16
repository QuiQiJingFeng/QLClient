local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleDiscardItemBase = class("UIBattleDiscardItemBase",UITableViewCell)

function UIBattleDiscardItemBase:init()
    self._imgFace = app.Util:seekNodeByName(self,"imgFace","ccui.ImageView")
    self._imgBack = app.Util:seekNodeByName(self,"imgBack","ccui.ImageView")
end

function UIBattleDiscardItemBase:updateData(data)
    local cardValue = data.cardValue
    if cardValue == 255 then
        self._imgBack:setVisible(true)
    else
        self._imgBack:setVisible(false)
        self._imgFace:loadTexture("art/mahjong/faces/"..tostring(cardValue)..".png")
    end
end
 

return UIBattleDiscardItemBase