local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local CardGroup = class("CardGroup")

-- @param cardState: CardDefiness.CardState
function CardGroup:ctor(cardState)
	self.cardState = cardState;
	self.cards = {};	-- 
	self.cardTop = nil;	-- 摞在上面的那张卡。也包含在cards里。
end

function CardGroup:getCardValue()
	if #self.cards ~= 0 then
		return self.cards[1]._cardValue;
	else
		return CardDefines.CardType.Invalid;
	end
end

return CardGroup