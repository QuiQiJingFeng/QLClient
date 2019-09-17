local CardGroup = class("CardGroup")
local POINTER_POS = {
    [1] = "art/mahjong/pointer/icon_zs1.png",
    [2] = "art/mahjong/pointer/icon_zs2.png",
    [3] = "art/mahjong/pointer/icon_zs3.png",
    [4] = "art/mahjong/pointer/icon_zs4.png",
}

function CardGroup:init()
    self._imgFrom = app.Util:seekNodeByName(self,"imgFrom","ccui.ImageView")
    self._cards = {}
    for i = 1, 4 do
        local node = app.Util:seekNodeByName(self,"card"..i,"ccui.Widget")
        local card = app.Util:seekNodeByName(node,"btnDiscard","ccui.Button")
        table.insert(self._cards,card)
    end
end

function CardGroup:setData(data)
    self._cards[4]:setVisible(data.type ~= "peng")
    self._imgFrom:loadTexture(POINTER_POS[data.from])
    
    for idx, card in ipairs(self._cards) do
        local cardValue = data.cardValue
        if idx ~= 4 and data.type == "angang" then
            cardValue = 255
        end
        card:setData({cardValue=cardValue})
    end
end

return CardGroup