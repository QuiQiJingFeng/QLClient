local HandCard = class("HandCard")

function HandCard:init()
    self._imgFace = app.Util:seekNodeByName(self,"imgFace","ccui.ImageView")
    self._imgBack = app.Util:seekNodeByName(self,"imgBack","ccui.ImageView")
    self._originSize = self:getContentSize()
    self.getContentSize = self.getContentSize2
end

function HandCard:setData(data)
    local cardValue = data.cardValue
    if cardValue == 255 then
        self._imgBack:setVisible(true)
    else
        self._imgBack:setVisible(false)
        self._imgFace:loadTexture("art/mahjong/faces/"..tostring(cardValue)..".png")
    end

    if data.isLastCard then
        app.Util:scheduleOnce(function() 
            self:setPositionX(self:getPositionX() + 10)
        end,0,self)
    end
end

return HandCard