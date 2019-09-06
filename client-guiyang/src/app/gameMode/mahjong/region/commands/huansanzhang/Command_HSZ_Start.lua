local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.mahjong.core.Constants"
local UI_ANIM = require("app.manager.UIAnimManager")

local Command_HSZ_Start = class("Command_HSZ_Start", super)
function Command_HSZ_Start:ctor(args)
    Command_HSZ_Start.super.ctor(self, args)
end

function Command_HSZ_Start:execute(args)
    local step = self._stepGroup[1]
    local playType = step:getPlayType()
    local chairType = self._processor:getRoomSeat():getChairType()


    -- 一秒后执行才显示UI，因为要播放开局动画
    scheduleOnce(function()
        if chairType == CardDefines.Chair.Down then
            self._uiRoomSeatDown = self._processor:getRoomSeat():getSeatUI()
            if self._uiRoomSeatDown ~= nil and self._uiRoomSeatDown:getPlayerProcessor() ~= nil then
                local ui = UIManager:getInstance():show("UIHuanSanZhang")
                ui:setOnButtonEnsureClickCallback(handler(self, self._onEnsureClickCallback))
                self._uiRoomSeatDown:setMultiSelectedEnabled(true, handler(self, self._onHandCardSelected))
                local selectedCardObjects = self._uiRoomSeatDown:setMultiSelectedCardByValues(step:getCards())
                self._processor:maskCardsReverseByObject(selectedCardObjects)
            end
        end
    end, 1)
    self._processor:addNextIdleTime(1 + 0.5)
end

function Command_HSZ_Start:_onHandCardSelected(targetCard, isPopUp)
    local isCanSelectedCard = true
    -- card 是已经选中的，不包含当前这个 targetCard
    local cards = self._uiRoomSeatDown:getMuiltSelectCards()
    local selectedCardObjects = { unpack(cards, 1, #cards) } -- pointer ref
    local count = #selectedCardObjects
    if isPopUp then
        if count >= 3 then
            self._processor:maskCardsReverseByObject(selectedCardObjects)
            isCanSelectedCard = false
        elseif count == 2 then
            self._processor:_enableAll()
            table.insert(selectedCardObjects, targetCard)
            self._processor:maskCardsReverseByObject(selectedCardObjects)
        end
    else
        self._processor:_enableAll()
    end
    self:_onSelecetdPost(isPopUp, isCanSelectedCard, count)
    return isCanSelectedCard
end

function Command_HSZ_Start:_onEnsureClickCallback()
    local selectedCardObjects = self._uiRoomSeatDown:getMuiltSelectCards()
    if #selectedCardObjects >= 3 then
        local cards = {}
        table.foreach(selectedCardObjects, function(index, cardObject) table.insert(cards, cardObject._cardValue) end)
        local gameService = gameMode.mahjong.Context.getInstance():getGameService();
        gameService:sendPlayStep(Constants.PlayType.OPERATE_CHANGECARD, cards)
    end
end

function Command_HSZ_Start:_onSelecetdPost(isPopUp, isCanSelect, currentCount)
    local isBtnEnable = true
    local count = currentCount
    if isCanSelect then
        if isPopUp then
            count = count + 1
        else
            count = count - 1
        end
    end
    isBtnEnable = count >= 3
    local ui = UIManager:getInstance():getUI("UIHuanSanZhang")
    if ui then
        ui:setButtonEnsureEnable(isBtnEnable)
    end
end

return Command_HSZ_Start