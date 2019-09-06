local CardDefines_ZhengShangYou = require "app.gameMode.zhengshangyou.core.CardDefines_ZhengShangYou"
local Card = require "app.gameMode.zhengshangyou.core.Card"
local CardFactory_ZhengShangYou = {}

function CardFactory_ZhengShangYou:convert(str)
    return CardDefines_ZhengShangYou.getCards(str)
end

function CardFactory_ZhengShangYou:getInstance()
    return CardFactory_ZhengShangYou
end

function CardFactory_ZhengShangYou:get(value, scale)
    local card = Card.new(value)
    if scale then
        card:setSize(scale)
    end
    return card
end

function CardFactory_ZhengShangYou:release(card)
    card:dispose()
    card:removeFromParent()
end

return CardFactory_ZhengShangYou