
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.zhengshangyou.core.Constants_ZhengShangYou"
local CardDefines = require "app.gameMode.zhengshangyou.core.CardDefines_ZhengShangYou"
local PlayType = Constants.PlayType

local Command_Display_RoundFinish = class("Command_Display_RoundFinish", super)
function Command_Display_RoundFinish:ctor(args)
    self.super.ctor(self, args)
end

function Command_Display_RoundFinish:execute(args)
    local step = self._stepGroup[1]
    local results = step._result.matchResults
    local playType = step:getPlayType()
    local roundInfo = {}
    for idx, result in ipairs(results) do
        table.insert(roundInfo, self:getCardList(result))
    end

    local gameScene = UIManager:getInstance():getUI("UIGameScene_ZhengShangYou")
    scheduleOnce(function() 
        UIManager:getInstance():show("UIRoundReportPage2", roundInfo, step._result, 'ZhengShangYou')
    end, 2, gameScene)
end

function Command_Display_RoundFinish:getCardList(result)
    local roundReportInfo ={
        anGang = {},
        chi = {},
        gang = {},
        hand = {},
        hus = {},
        peng = {},
        hua = {},
        guiCards = {},
        playerData = {},
        huStatus = {},
        player = nil
    }

    local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(result.roleId)
    roundReportInfo.player = processor
    local playerInfo = processor:getPlayerInfo()

    roundReportInfo.playerData.chairType = playerInfo.cPosition
    roundReportInfo.playerData.roleId = playerInfo.roleId
    roundReportInfo.playerData.position = playerInfo.position
    roundReportInfo.playerData.isBanker = playerInfo:isBanker()
    roundReportInfo.playerData.faceUrl = playerInfo.headIconUrl
    roundReportInfo.playerData.name = playerInfo.nickname
    roundReportInfo.playerData.totalPoint = playerInfo.totalPoint
    roundReportInfo.playerData.seat = playerInfo.seat

    for i=1,#result.handCards do
        local cardValue = nil
        if type(result.handCards) == "table" then
            cardValue = result.handCards[i]
        else
            cardValue = string.byte(result.handCards, i)
        end
        table.insert(roundReportInfo.hand, cardValue)
    end

    local operateCardsData = result.operateCards
    table.foreach(operateCardsData, function(key, val)
        local cardsArray = val.cards
        if type(cardsArray) == "string" then
            cardsArray = CardDefines.getCards(cardsArray)
        end
        if PlayType.Check(val.playType, PlayType.DISPLAY_MASTER_HONG_ZHONG) then
            -- 鬼牌
            table.foreach(cardsArray, function(k, v)
                table.insert(roundReportInfo.guiCards, v)
            end)
        elseif PlayType.Check(val.playType, PlayType.DISPLAY_SHOW_MASTER_CARD) then
            -- 鬼牌
            table.foreach(cardsArray, function(k, v)
                table.insert(roundReportInfo.guiCards, v)
            end)
        elseif PlayType.Check(val.playType, PlayType.DISPLAY_HUA_PAI) then
            -- 鬼牌
            table.foreach(cardsArray, function(k, v)
                table.insert(roundReportInfo.guiCards, v)
            end)
        elseif PlayType.Check(val.playType, PlayType.OPERATE_GANG_A_CARD) then
            table.insert(roundReportInfo.gang, cardsArray[1])
        elseif PlayType.Check(val.playType, PlayType.OPERATE_BU_GANG_A_CARD) then
            table.insert(roundReportInfo.gang, cardsArray[1])
        elseif PlayType.Check(val.playType, PlayType.DISPLAY_EX_CARD) then
            table.insert(roundReportInfo.hua, cardsArray[1])
        elseif PlayType.Check(val.playType, PlayType.OPERATE_AN_GANG) then
            table.insert(roundReportInfo.anGang, cardsArray[1])
        elseif PlayType.Check(val.playType, PlayType.OPERATE_PENG_A_CARD) then
            table.insert(roundReportInfo.peng, cardsArray[1])
        elseif PlayType.Check(val.playType, PlayType.OPERATE_CHI_A_CARD) then
            table.insert(roundReportInfo.chi, cardsArray[1])
        elseif PlayType.Check(val.playType, PlayType.OPERATE_HU) then
            table.insert(roundReportInfo.hus, cardsArray[1])
        end
    end)

    -- 当有人胡时，在桌面上显示是否叫牌或者胡牌类型（点炮、自摸）
    local hu_status = {}
    -- for _, event in ipairs(result.events) do -- ResultEventPROTO
    -- 	local score = event.score
    -- 	local op = event.addOperation
    -- 	if score.type == PlayType.HU_ZI_MO or score.type == PlayType.HU_DIAN_PAO then
    -- 		if score.type == PlayType.HU_DIAN_PAO  or (score.type == PlayType.HU_ZI_MO and op)then
    -- 			hu_status = {playType = score.type, op = op}
    -- 		end
    -- 	end
    -- 	-- 闷胡算是叫牌的一种
    -- 	if score.type == PlayType.HU_JIAO_PAI or score.type == PlayType.HU_WEI_JIAO_PAI or score.type == PlayType.HU_MEN_HU then
    -- 		if op then
    -- 			hu_status = {playType = score.type, op = op}
    -- 		end
    -- 	end
    -- end
    roundReportInfo.huStatus = hu_status

    return roundReportInfo
end

return Command_Display_RoundFinish