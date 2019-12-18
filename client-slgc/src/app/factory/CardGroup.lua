local Util = game.Util
local UITableViewCell = game.UITableViewCell
local Discard = require("app.factory.Discard")
local CardGroup = class("CardGroup",UITableViewCell)

function CardGroup:init()
    self._imgFrom = Util:seekNodeByName(self,"imgFrom","ccui.ImageView")
    self._cards = {}
    for i = 1, 4 do
        local node = Util:seekNodeByName(self,"card"..i,"ccui.Layout")
        local card = Discard:extend(node)
        table.insert(self._cards,card)
    end
end
--[[
    type:number
    gangType:number
    cardValue:number
    from:number
    pos:number
]]
function CardGroup:updateData(data)
    local GROUP_TYPE = game.CardFactory:getInstance():getGroupType()
    self._cards[4]:setVisible(data.type ~= GROUP_TYPE.CHI and data.type ~= GROUP_TYPE.PENG)
    self._imgFrom:setVisible(data.type ~= GROUP_TYPE.CHI and data.type ~= GROUP_TYPE.PENG)
    if self._imgFrom:isVisible() then
        --1/2/3/4
        local rotation = 0
        if data.from - data.pos == 1 then
            rotation = 90
        elseif data.from - data.pos == -1 then
            rotation = -90
        elseif math.abs(data.from - data.pos) == 2 then
            rotation = 0
        elseif data.from - data.pos == 3 then
            rotation = -90
        elseif data.from - data.pos == -3 then
            rotation = 90
        elseif data.from - data.pos == 0 then
            rotation = -180
        end
        self._imgFrom:setRotation(rotation)
    end
    for idx, card in ipairs(self._cards) do
        local cardValue = data.cardValue
        if idx == 4 and data.type == GROUP_TYPE.GANG and data.gangType == GANG_TYPE.ANGANG then
            cardValue = 255
        end
        if data.type == GROUP_TYPE.CHI then
            cardValue = cardValue + (idx - 1)
        end
        card:setData({cardValue=cardValue})
    end
end
 

return CardGroup