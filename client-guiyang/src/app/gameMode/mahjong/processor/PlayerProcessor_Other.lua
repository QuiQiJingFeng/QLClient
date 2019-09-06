local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local Super = require("app.gameMode.mahjong.processor.PlayerProcessor")
local PlayerProcessor_Other = class("PlayerProcessor_Other", Super)

function PlayerProcessor_Other:ctor(roomUI, roomSeat, seatUI)
    Super.ctor(self, roomUI, roomSeat, seatUI)
end

-- 出牌
--@return number, 下个操作的等待时间
function PlayerProcessor_Other:_onDiscardCard(cardValue)
    -- 收到服务器通知出牌
    -- 尝试按照牌值选择，即便不是明打，出牌的时候也有值
    local cardDiscard = nil;
    if CardDefines.isValidCardNumber(cardValue) then
        cardDiscard = self._cardList:getCard(cardValue, true);
    end
    if cardDiscard == nil then
        cardDiscard = self._cardList.lastDrewCard;
    end
    if cardDiscard == nil then
        cardDiscard = self._cardList.handCards[1];
    end
    if cardDiscard == nil then
        Logger.debug(self._cardList:toStrings())
        local errorStr = string.format("Discard failed, value = %s, lastDrewCard value = %s, handCardValues = %s",
        	tostring(cardValue), tostring(self._cardList.lastDrewCard), table.concat(self._cardList.handCards or {}))
        Macro.assertFalse(false, errorStr)
    end
    self:_onDiscardCard_Internal(cardValue, cardDiscard);
end

return PlayerProcessor_Other