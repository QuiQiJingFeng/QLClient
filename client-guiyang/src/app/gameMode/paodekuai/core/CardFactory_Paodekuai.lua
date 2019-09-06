local CardDefines_Paodekuai = require "app.gameMode.paodekuai.core.CardDefines_Paodekuai"
local Card = require "app.gameMode.paodekuai.core.Card"
local CardFactory_Paodekuai = {}

function CardFactory_Paodekuai:convert(str)
    return CardDefines_Paodekuai.getCards(str)
end

function CardFactory_Paodekuai:getInstance()
    return CardFactory_Paodekuai
end

function CardFactory_Paodekuai:get(value, scale)
    local card = Card.new(value)
    if scale then
        card:setSize(scale)
    end
    return card
end

function CardFactory_Paodekuai:release(card)
    card:dispose()
    card:removeFromParent()
end

return CardFactory_Paodekuai