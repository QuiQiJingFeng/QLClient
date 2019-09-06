local csbPath = "ui/csb/Gold/UIGoldRoundReport.csb"
local super = require("app.game.ui.UIBase")
local UIGoldRoundReport = class("UIGoldRoundReport", super, function() return kod.LoadCSBNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

local ScoreCalculateType = {

    -- 最后分数加减, 不用计算翻数
    NONE = 0,
    -- 二的指数次幂
    TWO_INDEX = 1,
    --最后分数加减, 不用计算翻数
    TOTAL_ADD = 2,
    --最后分数乘翻
    TOTAL_MULTI = 3,
    --最后分数乘翻(第二种)
    TOTAL_MULTI_2ND = 4
}

local CALC_OP_MAP = {
    [ScoreCalculateType.NONE] = "",
    [ScoreCalculateType.TWO_INDEX] = "+",
    [ScoreCalculateType.TOTAL_ADD] = "+",
    [ScoreCalculateType.TOTAL_MULTI] = "x",
    [ScoreCalculateType.TOTAL_MULTI_2ND] = "x",
}

local huImgs = {
    [PlayType.HU_ZI_MO] = { img = "gold/z_zm.png", be = "gold/z_bzm.png" },
    [PlayType.HU_DIAN_PAO] = { img = "gold/z_ch.png", be = "gold/z_dp.png" },
}

local function getHuImg(playType, isAdd)
    if huImgs[playType] then
        return isAdd and huImgs[playType].img or huImgs[playType].be
    else
        return ""
    end
end

local function getOpCharForHuData(type, isAdd)
    if type == ScoreCalculateType.TOTAL_ADD then
        return isAdd and "+" or "-"
    else
        return CALC_OP_MAP[type]
    end
end

-- 初始化listScore
local function initDetailList(listItem)
    listItem.huType = ccui.Helper:seekNodeByName(listItem, "huType")
    listItem.huScore = ccui.Helper:seekNodeByName(listItem, "huScore")
end

--为listScore中每个元素赋值
local function setListData(listItem, value)
    listItem.huType:setString(value.labelType)
    local score = value.labelScore
    if score > 0 then
        score = '+' .. score
    end
    listItem.huScore:setString(score)
end

function UIGoldRoundReport:ctor()
    -- 存放其他玩家的panel位置，这个界面不继续的话不会销毁，下次再进入，不重置计算会失误
    self._panelPositionArray = {}
    self._callback = nil
end

function UIGoldRoundReport:init()
    --其他玩家面板
    self._panelOtherPlayers = {}
    for i = 1, 3 do
        local panel = seekNodeByName(self, "panelPlayer" .. i, "ccui.Layout")
        table.insert(self._panelOtherPlayers, panel)
        panel.imgHead = seekNodeByName(panel, "imgHead", "ccui.ImageView")
        panel.bmTextScore = seekNodeByName(panel, "bmTextScore", "ccui.TextBMFont")
        panel.textName = seekNodeByName(panel, "textName", "ccui.Text")
        panel:setVisible(false)
        self._panelPositionArray[i] = cc.p(panel:getPosition())
    end
    --自己的面板相关控件
    self._mbTextMyScore = seekNodeByName(self, "mbTextMyScore", "ccui.TextBMFont")
    self._imgMyMainType = seekNodeByName(self, "imgMyMainType", "ccui.ImageView")

    --离开按钮
    self._btnReturn = seekNodeByName(self, "btnReturn", "ccui.Button")
    --继续按钮
    self._btnContinue = seekNodeByName(self, "btnContinue", "ccui.Button")

    --自己的分数详细列表
    self._listScore = ListFactory.get(seekNodeByName(self, "listScore", "ccui.ListView"), initDetailList, setListData, "UIGoldRoundReport")
    -- 自己对于这场比分的表情
    self._imageBirdBigEmoji = seekNodeByName(self, "Image_Brid_Emoji", "ccui.ImageView")
    self._imageHuStatusIcon = seekNodeByName(self._imageBirdBigEmoji, "Icon", "ccui.ImageView")

    self:_registerCallBack()
end

function UIGoldRoundReport:needBlackMask()
    return true
end

function UIGoldRoundReport:onShow(...)
    local args = { ... }
    local players = args[1]
    local roundReportData = args[2] -- BCMatchResultSYN
    --matchResults.pointInGame 是金币场的的总得失金币
    local index = 1
    for k, v in ipairs(roundReportData.matchResults) do
        if game.service.LocalPlayerService.getInstance():getRoleId() == v.roleId then
            local huData = self:_changeMatchEventToData(v, roundReportData.isHuang)
            self:_setListScore(huData.eventData)
            local pointInGame = v.pointInGame
            if pointInGame >= 0 then
                self._mbTextMyScore:setFntFile("ui/art/font/font_fx1.fnt")
            else
                self._mbTextMyScore:setFntFile("ui/art/font/font_js2.fnt")
            end
            local isPositive, scoreString = UtilsFunctions.getScoreWithOperator(pointInGame)
            self._mbTextMyScore:setString(scoreString)
            self:setLocalPlayerBridEmojiStatus(v.pointInGame, huData, roundReportData.isHuang)
            game.service.GoldService.getInstance():setShareData({
                events = huData.eventData,
                pointInGame = pointInGame,
                -- 兼容下金币场使用的总分
                totalPoint = v.totalPoint,
                playerInfo = players[k].playerData,
                handCards = v.handCards,
                operateCards = v.operateCards,
                huTypeArray = huData.huTypeArray,
                isPositiveHu = huData.isPositiveHu,
            })
        else
            local panelPlayer = self._panelOtherPlayers[index]
            local playerData = players[k].playerData
            index = index + 1
            game.util.PlayerHeadIconUtil.setIcon(panelPlayer.imgHead, playerData.faceUrl)
            local pointInGame = v.pointInGame
            UtilsFunctions.setScoreWithColor(panelPlayer.bmTextScore, pointInGame)
            panelPlayer.textName:setString(kod.util.String.getMaxLenString(playerData.name, 12))
            panelPlayer:setVisible(true)
        end
    end
    self:_adjustPanelPlayerPosition(#roundReportData.matchResults)
    local goldService = game.service.GoldService.getInstance()
    -- 这里能用LastSelectedGrade，因为如果是快速场次的话，他的枚举是没有对应的房间信息的
    self._btnContinue:setEnabled(goldService:getRoomInfo(goldService:getCurrentRoomGrade()) ~= nil)

    self._from = args[3] or ""
    if self._from == "campaign" then
        self._scheduleOnce = scheduleOnce(function()
            self:_onCampaignNextRound()
        end, 5)
        self._btnContinue:setVisible(false)
        self._btnReturn:setVisible(false)
    end

    if self:_isAutoShowSharePage() then
        UIManager:getInstance():show("UIGoldShareRoundResult")
    end

    goldService:getQuickChargeHelper():onGoldRoundResultShow()
end

function UIGoldRoundReport:_onCampaignNextRound()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService();

    gameService:prepareForNextRound()
    UIManager:getInstance():destroy("UIGoldRoundReport")
end

function UIGoldRoundReport:_adjustPanelPlayerPosition(playerNum)
    self:_resetPlayerPanelPosition()
    --取到panelPlayer2的位置为参考点
    local pos = cc.p(self._panelOtherPlayers[2]:getPosition())
    local middlePlayerX, middlePlayerY = pos.x, pos.y
    local playerWidth = self._panelOtherPlayers[1]:getContentSize().width
    if playerNum == 2 then
        self._panelOtherPlayers[1]:setPosition(pos)
        self._panelOtherPlayers[2]:setVisible(false)
        self._panelOtherPlayers[3]:setVisible(false)
    end
    if playerNum == 3 then
        local offset = math.floor(playerWidth / 5)
        self._panelOtherPlayers[1]:setPosition(cc.p(middlePlayerX - playerWidth / 2 - offset, middlePlayerY))
        self._panelOtherPlayers[2]:setPosition(cc.p(middlePlayerX + playerWidth / 2 + offset, middlePlayerY))
        self._panelOtherPlayers[3]:setVisible(false)
    end
end

function UIGoldRoundReport:_resetPlayerPanelPosition()
    for i, pos in ipairs(self._panelPositionArray) do
        self._panelOtherPlayers[i]:setPosition(pos)
    end
end

function UIGoldRoundReport:onHide()
    if self._callback ~= nil then
        self._callback()
        self._callback = nil
    end
    -- 关闭定时
    if self._scheduleOnce ~= nil then
        unscheduleOnce(self._scheduleOnce)
        self._scheduleOnce = nil
    end
end


function UIGoldRoundReport:_registerCallBack()
    bindEventCallBack(self._btnReturn, handler(self, self._onBtnReturn), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnContinue, handler(self, self._onBtnContinue), ccui.TouchEventType.ended)
end

function UIGoldRoundReport:_onBtnReturn(sender)
    game.service.GoldService.getInstance():getQuickChargeHelper():onCancelContinue()
end

function UIGoldRoundReport:_onBtnContinue()
    game.service.GoldService.getInstance():getQuickChargeHelper():onContinueMatch()
end

function UIGoldRoundReport:_isAutoShowSharePage()
    local goldService = game.service.GoldService.getInstance()
    if goldService == nil then
        return
    end
    local shareData = goldService:getShareData()
    -- 不是自己胡牌直接忽略
    if not shareData.isPositiveHu or self._from == "campaign" then
        return
    end


    local ret = false
    for _, huType in ipairs(shareData.huTypeArray or {}) do
        if huType == PlayType.HU_QI_DUI
        or huType == PlayType.HU_QING_YI_SE
        or huType == PlayType.HU_QING_DAN_DIAO
        or huType == PlayType.HU_LONG_QI_DUI
        or huType == PlayType.HU_QING_DA_DUI
        or huType == PlayType.HU_QING_QI_DUI
        or huType == PlayType.HU_QING_LONG_BE
        or huType == PlayType.HU_DI_LONG
        or huType == PlayType.HU_QING_DI_LONG
        or huType == PlayType.HU_DAN_DIAO
        or huType == PlayType.HU_RUAN_BAO
        or huType == PlayType.HU_YING_BAO
        or huType == PlayType.HU_DI_HU
        -- 以下是潮汕的
        or huType == PlayType.HU_TIAN_HU
        or huType == PlayType.HU_DI_HU
        or huType == PlayType.HU_SI_GANG
        or huType == PlayType.HU_SAN_HAO_HUA_QI_DUI
        or huType == PlayType.HU_DA_SAN_YUAN
        or huType == PlayType.HU_DA_SI_XI
        or huType == PlayType.HU_ZI_YI_SE
        then
            -- ATTENTION !! 同时，这里也要计算要显示的胡牌类型
            ret = true
            shareData.huType = huType
            goldService:setShareData(shareData)
            break
        end
    end
    return ret
end

--转换结算数据成客户端需要显示的数据
function UIGoldRoundReport:_changeMatchEventToData(matchResult, isHuang)
    -- 胡牌类型
    local isPositiveHu = false
    local huTypeArray = {}
    local eventMap = {}
    local listEventData = {}
    local huImg = ""
    --黄庄显示黄庄图片
    if isHuang then
        huImg = "gold/z_hz.png"
    end
    --设置一个key来存放各种显示数据方便合并
    local insertEvent = function(data)
        local key = data.labelType
        if not eventMap[key] then
            eventMap[key] = data
        else
            eventMap[key].labelScore = eventMap[key].labelScore + data.labelScore
        end
    end

    for _, event in ipairs(matchResult.events) do -- ResultEventPROTO
        local op = event.addOperation
        local score = event.score
        local subscores = event.subScores
        local targets = event.targets
        local scoreTotal = event.eventPoint
        local index = 0
        -- 胡牌类型单独处理
        if score.type == PlayType.HU_ZI_MO or score.type == PlayType.HU_DIAN_PAO then

            huImg = getHuImg(score.type, op)
            local targets = #event.targets
            --子胡牌类型加入列表
            for _, subscore in ipairs(subscores) do
                if subscore.point ~= 0 then
                    local operatorCharacter = getOpCharForHuData(subscore.calcType, op)
                    if operatorCharacter == "x" then
                        for k, v in pairs(eventMap) do
                            v.labelScore = v.labelScore * subscore.point
                            v.labelType = v.labelType .. '(' .. Constants.SpecialEvents.getName(subscore.type) .. ')'
                        end
                    else
                        local flag = 1
                        if operatorCharacter == "-" then
                            flag = -1
                        end
                        insertEvent({
                            index = index - 1000,
                            labelScore = subscore.point * targets * flag,
                            target = targets,
                            labelType = Constants.SpecialEvents.getName(subscore.type),
                        })
                        index = index + 1
                    end
                end
                -- 保留所有的胡牌类型
                table.insert(huTypeArray, subscore.type)
                isPositiveHu = op
            end
        elseif event.combinedPoint ~= 0 then -- 不知道这样改会不会影响贵阳的，有问题再说吧
            insertEvent({
                index = index,
                labelScore = event.eventPoint,
                labelType = Constants.SpecialEvents.getName(score.type, op),
            })
            index = index + 1
        end
    end
    --将合并的数据插入列表并排序
    for k, v in pairs(eventMap) do
        if v.labelScore ~= 0 then
            table.insert(listEventData, v)
        end
    end
    table.sort(listEventData, function(l, r)
        return l.index < r.index
    end)
    -- huType 可能为空值
    local huData = { eventData = listEventData, huImg = huImg, huTypeArray = huTypeArray, isPositiveHu = isPositiveHu }
    return huData
end

function UIGoldRoundReport:_setListScore(listEventData)
    self._listScore:deleteAllItems()

    for k, v in ipairs(listEventData) do
        self._listScore:pushBackItem(v)
    end
end

local happyEmojiPath = "art/gold/img_logo2.png"
local sadEmojiPath = "art/gold/img_logo3.png"
local huangZhuangImgPath = "art/gold/z_hz.png"
local victoryImgPath = "art/gold/z_sl.png"
function UIGoldRoundReport:setLocalPlayerBridEmojiStatus(pointInGame, huData, isHuangZhuang)
    local emojiPath, huStatusPath = nil, nil
    if isHuangZhuang then
        huStatusPath = huangZhuangImgPath
    else
        if huData.huImg ~= "" then
            huStatusPath = huData.huImg
        else
            if pointInGame > 0 then
                huStatusPath = victoryImgPath
            else
                huStatusPath = nil
            end
        end
    end
    if pointInGame >= 0 then
        emojiPath = happyEmojiPath
    else
        emojiPath = sadEmojiPath
    end
    self._imageBirdBigEmoji:loadTexture(emojiPath)
    self._imageHuStatusIcon:loadTexture(huStatusPath)
    self._imageBirdBigEmoji:setVisible(emojiPath ~= nil)
    self._imageHuStatusIcon:setVisible(huStatusPath ~= nil)
end

function UIGoldRoundReport:setCallback(callback)
    self._callback = callback
end

function UIGoldRoundReport:getCallback()
    return self._callback
end

return UIGoldRoundReport