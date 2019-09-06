local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.mahjong.core.Constants"

local Command_HSZ_Select = class("Command_HSZ_Select", super)
function Command_HSZ_Select:ctor(args)
    Command_HSZ_Select.super.ctor(self, args)
end

function Command_HSZ_Select:execute(args)
    local step = self._stepGroup[1]
    local ui = UIManager:getInstance():getUI("UIHuanSanZhang")
    local chairType = self._processor:getRoomSeat():getChairType()
    if ui == nil then
        ui = UIManager:getInstance():show("UIHuanSanZhang")
    end
    ui:onOneMenSelected(chairType)
    -- 1、删除手牌
    self:deleteHandCard(chairType, step)
end

function Command_HSZ_Select:deleteHandCard(chairType, step)
    local cards = step:getCards()
    if chairType ~= CardDefines.Chair.Down then
        -- 不是下方玩家直接过滤掉
        return 
    end
    for _, value in ipairs(cards) do
        self._processor:getCardList():removeHandCardAndReleaseByValue(value)
    end
    -- 清空刚摸到的牌，因为它会影响到排序
    self._processor:getCardList().lastDrewCard = nil
    local seatUI = self._processor:getRoomSeat():getSeatUI()
    seatUI:ManageCardsPositions(self._processor:getCardList(), seatUI:getCardLayout(), true)

    -- 2、如果是下方玩家，关闭手牌多选模式，移除手牌遮罩
    if chairType == CardDefines.Chair.Down then
        self._processor:getRoomSeat():getSeatUI():setMultiSelectedEnabled(false, nil)
        self._processor:_enableAll()
    end
end

return Command_HSZ_Select