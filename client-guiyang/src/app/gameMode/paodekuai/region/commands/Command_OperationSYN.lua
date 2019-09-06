local RoomSetting = config.GlobalConfig.getRoomSetting()
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.paodekuai.core.Constants_Paodekuai"
local TipsHelper = require("app.gameMode.paodekuai.utils.TipsHelper")
local CardDefines = require("app.gameMode.paodekuai.core.CardDefines_Paodekuai")
local UIAnimManager = require("app.manager.UIAnimManager")
--[[    POKER_OPERATE_LAST_PLAY_A_CARD
    roleId：上次出牌的玩家
    playType：
    cards：上次出的牌值
]]
local Command_OperationSYN = class("Command_OperationSYN", super)

function Command_OperationSYN:ctor(args)
    self.super.ctor(self, args)
end


function Command_OperationSYN:execute(args)
    local step = self._stepGroup[1]
    local playType = step:getPlayType()
    local roleId = step:getRoleId()
    local cards = step:getCards()

    if playType == Constants.PlayType.POKER_OPERATE_LAST_PLAY_A_CARD then
        self:onPlayCardsSYN(playType, roleId, cards)
    elseif playType == Constants.PlayType.POKER_OPERATE_PASS then
        self:onPassSYN(playType, roleId, cards)
    else
        Macro.assertFalse(false, 'unhandle playType ' .. playType)
    end

    self:resetCounter(playType, roleId, cards)
end

local ANIM_PATH = {
    [Constants.PlayType.POKER_DISPLAY_PAI_SHUNZI] = "ui/csb/Paodekuai/Effect_Paodekuai_Shunzi.csb",
    [Constants.PlayType.POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG] = "ui/csb/Paodekuai/Effect_Paodekuai_Feiji.csb",
    [Constants.PlayType.POKER_DISPLAY_PAI_ZHADAN] = "ui/csb/Paodekuai/Effect_Paodekuai_Zhadan.csb"
}
function Command_OperationSYN:playEffect(playType)
    local path = ANIM_PATH[playType]
    if path then
        local gameScene = UIManager:getInstance():getUI("UIGameScene_Paodekuai")
        UIAnimManager.UIAnimManager:getInstance():onShow({
            _path = path,
            _replay = false,
            _parent = gameScene
        })
    end
end

function Command_OperationSYN:onPlayCardsSYN(playType, roleId, cards)
    local gameService = gameMode.mahjong.Context:getInstance():getGameService()
    -- 是否是自己第一次出牌（这次出牌的第一次）例如自己出了2222别人要不起，再出个3，这个3认为是第一次出牌
    local isFirstDiscard = false
    local lastInfo = gameService:getLastDiscardInfo()
    if lastInfo == nil or lastInfo.roleId == nil or lastInfo.roleId == roleId then
        isFirstDiscard = true
    end

    local set = gameService:getAllPlayerProcessor()
    for idx, processor in pairs(set) do
        local playerInfo = processor:getPlayerInfo()
        if playerInfo.roleId == roleId then
            -- 播放音效和特效
            local cardType = TipsHelper:getCardType(cards)
            -- todo 排序
            cards = self:sortCardByType(cards, cardType)
            processor:onDiscard(cards, cardType)
            processor:cleanUpOperation()
            processor:playCardTypeSound(cardType, cards, isFirstDiscard)
            self:playEffect(cardType)

            Logger.debug("====LAST CARD SYN ====")
            Logger.debug("CARDS = " .. table.concat(cards, ","))
            Logger.debug("RoleID= " .. playerInfo.roleId)
        else
            processor:onDiscard({})
            processor:cleanUpOperation()
        end
    end

    local lastDiscardInfo = { value = { unpack(cards) }, roleId = roleId }

    -- local remainCardNum = self._processor:getUIPlayer():getCardRemainNum()
    -- local optValueRules = game.service.RoomService:getInstance():getRoomRules()
    -- if remainCardNum == 1 and table.indexof(optValueRules, "GAME_PLAY_BAO_DAN_BI_DING") then
    --     lastDiscardInfo.MUST_DISCARD_BIG_ONE_SINGLE_CARD = true
    -- else
    --     lastDiscardInfo.MUST_DISCARD_BIG_ONE_SINGLE_CARD = false
    -- end
    gameService:setLastDiscardInfo(lastDiscardInfo)
end

function Command_OperationSYN:onPassSYN(playType, roleId, cards)
    -- self._processor:onDiscard({})
    if self._processor:getPlayerInfo().cPosition == 1 then
        self._processor:cleanUpOperation()
    end
    self._processor:getUIPlayer():setPassVisible(true)
    self._processor:playCardTypeSound(playType, cards)
end

function Command_OperationSYN:resetCounter(playType, roleId, cards)
    if self._processor:getPlayerInfo().cPosition == 1 then
        local cardList = self._processor:getCardList()
        cardList:popDownAll()
        cardList:resetTipsCounter()
    end
end

function Command_OperationSYN:sortCardByType(cards, cardType)
    cards = CardDefines.sort(cards)
    local debugsort = CardDefines.convertToSortValue(cards)
    if cardType == Constants.PlayType.POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG then

        local result = { _3 = {}, _2 = {}, _1 = {} }
        local cache = {}
        local cur = CardDefines.getSortValue(cards[1])
        local cnt = 0
        for _, value in ipairs(cards) do
            local temp = CardDefines.getSortValue(value)
            if cur == temp then
                cnt = cnt + 1
            else
                if cnt == 3 then
                    table.insertto(result._3, cache)
                elseif cnt == 2 then
                    table.insertto(result._2, cache)
                elseif cnt == 1 then
                    table.insertto(result._1, cache)
                end
                cnt = 1
                cur = temp
                cache = {}
            end
            table.insert(cache, value)
        end
        if cnt == 3 then
            table.insertto(result._3, cache)
        elseif cnt == 2 then
            table.insertto(result._2, cache)
        elseif cnt == 1 then
            table.insertto(result._1, cache)
        end

        cards = {}
        table.insertto(cards, result._3)
        table.insertto(cards, result._2)
        table.insertto(cards, result._1)
    end
    return cards
end

return Command_OperationSYN