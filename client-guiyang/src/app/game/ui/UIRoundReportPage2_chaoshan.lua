--[[牌局结算(战绩牌局)界面
--]]
local csbPath = "ui/csb/UIRoundReport2.csb"
local super = require("app.game.ui.UIBase")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Poker_PlayType = require("app.gameMode.zhengshangyou.core.Constants_ZhengShangYou").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local ShareNode = require("app.game.ui.element.UIElemShareNode")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

local UIRoundReportPage2 = class("UIRoundReportPage2", super, function() return kod.LoadCSBNode(csbPath) end)

local huImgs = {
    [PlayType.HU_ZI_MO] = { img = "Icon/icon_zm.png", be = "" },
    [PlayType.HU_DIAN_PAO] = { img = "Icon/icon_ch.png", be = "Icon/icon_dp.png" },
}

local function getHuImg(playType, isAdd)
    if huImgs[playType] then
        return isAdd and huImgs[playType].img or huImgs[playType].be
    else
        return ""
    end
end

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

local function getOpCharForHuData(type, isAdd)
    if type == ScoreCalculateType.TOTAL_ADD then
        return isAdd and "+" or "-"
    else
        return CALC_OP_MAP[type]
    end
end

local tingType = {
    [true] = "胡牌",
    [false] = "未胡牌"
}
local huColor = {
    { r = 81, g = 179, b = 96, img = "img/Icon_frame22.png" },
    { r = 224, g = 155, b = 48, img = "img/Icon_frame33.png" },
    { r = 188, g = 84, b = 66, img = "img/Icon_frame44.png" },
    { r = 49, g = 150, b = 228, img = "img/Icon_frame11.png" },
    { r = 236, g = 186, b = 139, img = "img/Icon_frame11.png" },
}

function UIRoundReportPage2:needBlackMask()
    return true;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIRoundReportPage2:isFullScreen()
    return true;
end

function UIRoundReportPage2:closeWhenClickMask()
    return false
end

function UIRoundReportPage2:ctor()
    self._btnCardInfo = nil	    -- 底牌详情
    self._btnShare = nil		-- 游戏分享
    self._btnContinue = nil		-- 继续游戏
    self._btnHelp = nil         -- 游戏帮助
    self._scheduleOnce = nil
    self._players = {}
    self._playerRecords = {}
    self._playerAllEvent = {}	-- 结算显示的条目
    self._huData = {}
    self._eventData = {}
    self._tingData = {}
    self._val_player = 0
    self._huImg = {}
end

function UIRoundReportPage2:init()
    self._btnCardInfo = seekNodeByName(self, "Button_1_RoundReport", "ccui.CheckBox")
    self._btnShare = seekNodeByName(self, "Button_2_RoundReport", "ccui.CheckBox")
    self._btnContinue = seekNodeByName(self, "Button_3_RoundReport", "ccui.CheckBox")
    self._btnBack = seekNodeByName(self, "Button_fh_RoundReport", "ccui.CheckBox")
    self._btnHelp = seekNodeByName(self, "Button_help_RoundReport", "ccui.CheckBox")
    self._btnRoomCard = seekNodeByName(self, "Button_roomCard", "ccui.Button")
    self._btnBackTop = seekNodeByName(self, "Button_back_HisRecord", "ccui.Button") -- 新版UI左上角统一的返回
    self._imgJiCard = seekNodeByName(self, "Image_jiCard", "ccui.ImageView")
    self._imgJiCard:setVisible(false) -- 潮汕暂时不用
    self._btnRoomCard:setVisible(false) -- 潮汕暂时不用

    bindEventCallBack(self._btnCardInfo, handler(self, self._onClickCardsInfo), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnContinue, handler(self, self._onClickContinue), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBack, handler(self, self._onBack), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRoomCard, handler(self, self._onRoomCard), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBackTop, handler(self, self._onBtnBackTopClick), ccui.TouchEventType.ended)
    self._btnHelp:setVisible(false)

    self._listviewPlayerInfo = ccui.Helper:seekNodeByName(self, "ListView_RoundReport")

    self._listScoreData = ccui.Helper:seekNodeByName(self, "Panel_2_list_1_player1_RoundReport")
    self._listScoreCard = ccui.Helper:seekNodeByName(self, "Panel_2_list_1_player1_RoundReport_0")
    -- 不显示滚动条, 无法在编辑器设置
    self._listviewPlayerInfo:setScrollBarEnabled(false)
    self._listviewPlayerInfo:setTouchEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listviewPlayerInfo, "Panel_Player1_RoundReport")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)
    self._btnShare:setVisible(false)

end

-- 返回牌桌
function UIRoundReportPage2:_onRoomCard()
    -- 统计算分详情界面查看牌桌点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoundReport_RoomCard)

    UIManager:getInstance():show("UILastCrads", self._players, self._playerRecords, self._from, "UIRoundReportPage2")
    self:_onBack()
end


function UIRoundReportPage2:_onClickCardsInfo()
    -- 统计牌局详情点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoomCard_Details)
    local gameType = Constants.SpecialEvents.gameType

    -- 普通牌局显示新的结算界面
    -- if (self._from == "" or self._from == "historyDetail") and (not self._isPokerGameType) then
    --     UIManager:getInstance():show("UICardsInfo_new", self._players, self._playerRecords, self._from, self._huImg, self._eventData, self._gamePlay)
    --     self:_onBack()
    --     return
    -- end
    local playerInfos = {}
    local playerDatas = {}
    table.foreach(self._players, function(key, val)
        table.insert(playerInfos, self:_convertToPlayerInfo(val))
    end)
    table.foreach(self._playerRecords.matchResults, function(key, val)
        table.insert(playerDatas, self:_convertToPlayerData(val))
    end)

    local function getPosition(roleId)
        for i = 1, #playerInfos do
            if playerInfos[i].roleId == roleId then
                local pos = playerInfos[i].position < playerInfos[i].seat and playerInfos[i].position + 4 or playerInfos[i].position
                -- 在2，3人局时，最后一个人位置，这时position 1会被转换到4
                if #playerInfos == 2 and playerInfos[i].position == 4 then
                    return 1
                elseif #playerInfos == 3 and pos - playerInfos[i].seat == 2 and playerInfos[i].position == 4 then
                    return 1
                else
                    return playerInfos[i].position
                end
            end
        end
    end
    table.sort(playerInfos, function(a, b)
        return getPosition(a.roleId) < getPosition(b.roleId)
    end)
    table.sort(playerDatas, function(a, b)
        return getPosition(a.roleId) < getPosition(b.roleId)
    end)

    local lastCards = self._playerRecords.lastCards
    if type(lastCards) ~= "table" then
        lastCards = clone(CardDefines.getCards(lastCards));
    end

    local gameType = Constants.SpecialEvents.gameType
    if self._isPokerGameType then
        UIManager:getInstance():show("UICardsInfo_Paodekuai", playerDatas, playerInfos, lastCards)
    else
        UIManager:getInstance():show("UICardsInfo", playerDatas, playerInfos, lastCards)
    end
end

function UIRoundReportPage2:_convertToPlayerData(matchResult)
    local playerDetail = {}
    playerDetail.roleId = matchResult.roleId;
    playerDetail.totalPoint = matchResult.totalPoint;
    playerDetail.pointInGame = matchResult.pointInGame;
    playerDetail.events = clone(matchResult.events);
    if type(matchResult.handCards) == "table" then
        playerDetail.handCards = clone(matchResult.handCards);
    else
        playerDetail.handCards = clone(CardDefines.getCards(matchResult.handCards));
    end

    if type(matchResult.outCards) == "table" then
        playerDetail.outCards = clone(matchResult.outCards);
    else
        playerDetail.outCards = clone(CardDefines.getCards(matchResult.outCards));
    end

    if type(matchResult.operateCards) == "table" then
        playerDetail.operateCards = matchResult.operateCards
    else
        playerDetail.operateCards = clone(matchResult.operateCards);
    end

    table.foreach(playerDetail.operateCards, function(key, val)
        if type(val.cards) == "table" then
            val.cards = val.cards
        else
            val.cards = CardDefines.getCards(val.cards)
        end
    end)
    playerDetail.status = matchResult.status;

    -- 玩家的比赛状态更新
    local campaignService = game.service.CampaignService.getInstance()
    campaignService:getCampaignData():setTotalPoint(matchResult.totalPoint)

    return playerDetail
end

function UIRoundReportPage2:_convertToPlayerInfo(player)
    local playerInfo = {}
    local playerInfo_ = player.playerData
    playerInfo.roleId = playerInfo_.id;
    playerInfo.roleName = playerInfo_.name;
    playerInfo.iconUrl = playerInfo_.faceUrl;
    playerInfo.position = playerInfo_.position;
    playerInfo.seat = playerInfo_.seat;
    playerInfo.totalScore = playerInfo_.totalPoint;
    return playerInfo
end

function UIRoundReportPage2:_onClickShare()
    Logger.debug("_onClickShare")
    ShareNode:showShareUI(true, config.LOCALSHARE.result_single)
end

function UIRoundReportPage2:_onClickContinue()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService();
    if gameService and gameService:getFinishMachResult() == nil then
        if game.service.LocalPlayerService:getInstance():isWatcher() then
            -- 观察者显示界面的时候，就已经清除了，因为这时可能打牌的玩家已经开局了，所以，这里不能再清除一次了
        else
            -- 保存一下时间
            -- game.service.club.ClubService.getInstance():isTodayPlayCard(true)
            gameService:prepareForNextRound()
        end
    else
        local players = self._players
        -- 这边拿到的是一个已经被修改过的协议体，直接取字段可能会报错，通过rawget去取
        local roomClubId = rawget(self._playerRecords, "roomClubId") or 0
        if roomClubId ~= 0 then
            GameFSM:getInstance():enterState("GameState_Club");
        else
            GameFSM:getInstance():enterState("GameState_Lobby");
        end
        UIManager:getInstance():show("UIFinalReport", players, gameService:getFinishMachResult())
    end
    UIManager:getInstance():destroy("UIRoundReportPage2")
end

function UIRoundReportPage2:_onCampaignNextRound()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService();

    gameService:prepareForNextRound()
    UIManager:getInstance():destroy("UIRoundReportPage2")
end

function UIRoundReportPage2:_onBack()
    UIManager:getInstance():destroy("UIRoundReportPage2")
end

function UIRoundReportPage2:onShow(...)
    --提审相关（结算界面微信分享按钮隐藏）
    if GameMain.getInstance():isReviewVersion() then
        self._btnShare:setVisible(false)
    end

    local args = { ... }
    self:_clearData()
    local roundReportData = args[2] -- BCMatchResultSYN
    if not roundReportData or not roundReportData.matchResults then return end
    local players = args[1]

    self._players = players
    -- 判断是否为poker类玩法
    local gameType = Constants.SpecialEvents.gameType
    self._gamePlay = args[4]
    if self._gamePlay ~= nil then
        self._isPokerGameType = self._gamePlay == 'GAME_TYPE_PAODEKUAI' or self._gamePlay == "GAME_TYPE_ZHENGSHANGYOU"
    else
        self._isPokerGameType = gameType == 'GAME_TYPE_PAODEKUAI' or gameType == "GAME_TYPE_ZHENGSHANGYOU"
    end
    --居中显示
    if #self._players == 2 then
        self._listviewPlayerInfo:setContentSize(485, 460)
    elseif #self._players == 3 then
        self._listviewPlayerInfo:setContentSize(740, 460)
    else
        self._listviewPlayerInfo:setContentSize(980, 460)
    end

    self:showRoundData(players, roundReportData)

    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    if self._mask then
        self._mask:setOpacity(220)
    end

    self._from = args[3] or ""
    if self._from ~= "" and self._from == "historyDetail" then
        self._btnContinue:setVisible(false)
        self._btnBack:setVisible(true)
        self._btnRoomCard:setVisible(false)
    elseif self._from == "campaign"    then
        self._btnContinue:setVisible(false)
        self._btnBack:setVisible(false)
        self._btnCardInfo:setVisible(false)
        self._btnRoomCard:setVisible(false)

        self._scheduleOnce = scheduleOnce(function()
            self:_onCampaignNextRound()
        end, 2)
        return
    else
        self._btnContinue:setVisible(true)
        self._btnBack:setVisible(false)
        -- self._btnRoomCard:setVisible((not game.service.LocalPlayerService:getInstance():isWatcher()) and not self._isPokerGameType)
    end

    -- 当是观察者的时候，它的下一局准备不会对原牌局产生影响
    -- 同样的，如果其它人都准备了，但是他没有的话，那么也会开局的，如果不处理，会对正常流程的防御性代码产生影响
    -- 最终结算的时候，RoomService已经释放，就不用再管了，直接走平常的处理吧
    local context = gameMode.mahjong.Context.getInstance();
    local gameService = nil;
    if context then   -- 在好友圈查看结果而不需要打牌环境的时候context为空
        gameService = gameMode.mahjong.Context.getInstance():getGameService();
    end
    if game.service.LocalPlayerService:getInstance():isWatcher()
    and gameService and gameService:getFinishMachResult() == nil then
        gameService:prepareForNextRound(true)
    end

    -- 观战是新游戏开始关闭结算界面
    if gameService then
        gameService:addEventListener("EVT_NEW_GAME_ROUND_BEGIN", handler(self, self._onBack));
    end
end

function UIRoundReportPage2:_clearData()
    self._players = {}
    self._playerRecords = {}
end

function UIRoundReportPage2:showRoundData(players, playerRecords)
    -- 构造数据
    table.sort(self._players, function(a, b)
        local chaira = a.playerData.position
        local chairb = b.playerData.position
        return chaira < chairb
    end)
    -- 三个人时 进行重新排序
    if #self._players == 3 then
        if self._players[1].playerData.position == 2 and self._players[2].playerData.position == 3 then
            local val_player = self._players[3]
            table.remove(self._players, 3)
            self._val_player = 1
            table.insert(self._players, 1, val_player)
        end
        if self._players[1].playerData.position == 1 and self._players[2].playerData.position == 2 then
            self._val_player = 3
        end
    end

    if #self._players == 2 then
        if self._players[1].playerData.position == 2 and self._players[2].playerData.position == 4 then
            local val_player = self._players[2]
            table.remove(self._players, 2)
            table.insert(self._players, 1, val_player)
        end
    end

    self._playerRecords = playerRecords
    self:_processData()
    self:_onShowData()
end

function UIRoundReportPage2:onHide()
    local context = gameMode.mahjong.Context.getInstance();
    if context then
        local gameService = context:getGameService();
        if gameService then
            gameService:removeEventListenersByTag("EVT_NEW_GAME_ROUND_BEGIN");
        end
    end

    -- 关闭定时
    if self._scheduleOnce ~= nil then
        unscheduleOnce(self._scheduleOnce)
        self._scheduleOnce = nil
    end
end

function UIRoundReportPage2:_onShowData()
    self._listviewPlayerInfo:removeAllChildren()
    local count = #self._players
    for index = 1, count do
        local node = self._listviewItemBig:clone()
        self._listviewPlayerInfo:addChild(node)
        node:setVisible(true)
        local player = self._players[index]
        local matchResult = self:_findPlayerMatchResult(player.playerData.roleId)
        self._textName = ccui.Helper:seekNodeByName(node, "Text_name_Player1_RoundReport")        --名字
        self._imageFace = ccui.Helper:seekNodeByName(node, "Image_face_Player1_RoundReport")      --头像
        self._colorFace = ccui.Helper:seekNodeByName(node, "Image_frame_Player1_RoundReport")      --头像框颜色
        self._textScore = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_ID_Player1_RoundReport_0_0")       --总分
        self._textSZ = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_Score_Player1_RoundReport") --本局的分数
        self._imageHuType = ccui.Helper:seekNodeByName(node, "Image_jst_Player1_RoundReport")    --胡牌类型（自摸点炮）
        self._imageTingType = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_z_tital_Player1_RoundReport")--胡牌类型（叫牌）
        self._textID = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_ID_Player1_RoundReport")             --id
        self._listScore = ccui.Helper:seekNodeByName(node, "ListView_list_1_player1_RoundReport")         --胡牌类型（分数）
        self._zhuang = ccui.Helper:seekNodeByName(node, "Image_iconz_Player1_RoundReport")         --庄
        self._zhuang:setVisible(player.playerData.isBanker)
        self._listScore:setScrollBarEnabled(false)
        game.util.PlayerHeadIconUtil.setIcon(self._imageFace, player.playerData.faceUrl)
        self._textName:setString(kod.util.String.getMaxLenString(player.playerData.name, 8))
        self._textScore:setString(matchResult.totalPoint)
        UtilsFunctions.setScoreWithColor(self._textSZ, matchResult.pointInGame)

        -- 设置头像角标
        local huImage = self._playerAllEvent[index].huData.huImg

        self._imageHuType:setVisible(huImage ~= nil and huImage ~= "")
        if huImage and huImage ~= "" then
            self._imageHuType:loadTexture(huImage)
        end

        self._imageTingType:setString(self._playerAllEvent[index].huData.tingText)
        self._imageTingType:setVisible(Constants.SpecialEvents.gameType ~= "GAME_TYPE_ZHENGSHANGYOU")

        local _colorplay = self:_getcolorFace(player.playerData.roleId)
        self._colorFace:loadTexture(_colorplay.img)

        self._textID:setString("ID:" .. player.playerData.roleId)

        self:_showHistoryData(self._listScore, index, matchResult.pointInGame)

    end
end

function UIRoundReportPage2:_findPlayerMatchResult(id)
    for _, data in ipairs(self._playerRecords.matchResults) do
        if data.roleId == id then
            return data
        end
    end
    -- 若找不到玩家则打印玩家信息
    Macro.assetTrue(true, "ERROR: THERE IS NO PLAYER");
    Logger.debug("========id=" .. id .. "=========");
    for _, data in ipairs(self._playerRecords.matchResults) do
        Logger.debug(data.roleId);
    end
    return nil
end

function UIRoundReportPage2:_showHistoryData(_scoreData, index, point)
    local pos = self:_getPlayerPosition(self._players[index].playerData.id)
    self._listScoreData = ccui.Helper:seekNodeByName(_scoreData, "Panel_2_list_1_player1_RoundReport")
    _scoreData:removeAllChildren()
    local event = {}

    for _, v in ipairs(self._playerAllEvent[index].listHuData) do
        table.insert(event, v)
    end
    for _, v in ipairs(self._playerAllEvent[index].listEventData) do
        table.insert(event, v)
    end

    table.sort(event, function(l, r)
        if (l.targetPosition == r.targetPosition) then
            return l.index < r.index
        else
            local lWeight = pos - l.targetPosition
            local rWeight = pos - r.targetPosition
            lWeight = lWeight < 0 and lWeight + 10 or lWeight
            rWeight = rWeight < 0 and rWeight + 10 or rWeight
            return lWeight < rWeight
        end
    end)

    for _, data in ipairs(event) do
        local node = self._listScoreData:clone()
        _scoreData:addChild(node)
        node:setVisible(true)
        local text1 = seekNodeByName(node, "BitmapFontLabel_z_2_list_1_player1_RoundReportrt", "ccui.TextBMFont") 	--牌形
        local text2 = seekNodeByName(node, "BitmapFontLabel_f_2_list_1_player1_RoundReport", "ccui.TextBMFont")   	--分数
        -- local bimg = ccui.Helper:seekNodeByName(node, "Image_t_2_list_1_player1_RoundReport")       --背景
        text1:setString(data.labelType)

        -- if data.targetPosition == pos then
        -- 	bimg:loadTexture("img/img_bdjs0.png")
        -- else
        -- 	bimg:loadTexture("img/img_bdjs1.png")
        -- end
        if Constants.SpecialEvents.gameType == "GAME_TYPE_ZHENGSHANGYOU" then
            if point < 0 then
                data.labelScore = string.gsub(data.labelScore, "+", "-")
            end
        end
        text2:setString(data.labelScore)

        text1:setColor(cc.c4b(data.targetColor.r, data.targetColor.g, data.targetColor.b, 255))
        text2:setColor(cc.c4b(data.targetColor.r, data.targetColor.g, data.targetColor.b, 255))
    end
end


function UIRoundReportPage2:_showCard(_list_card, data)
    self._listCardInfo = ccui.Helper:seekNodeByName(_list_card, "Image_mj1_2_list_1_player1_RoundReport")
    self._listCardInfo:removeFromParent(false)
    self:addChild(self._listCardInfo)
    self._listCardInfo:setVisible(false)

    _list_card:removeAllChildren()
    for index = 1, #data.cardValue do
        local node = self._listCardInfo:clone()
        _list_card:addChild(node)
        node:setVisible(true)
        local cardValue = ccui.Helper:seekNodeByName(node, "Image_t_mj1_2_list_1_player1_RoundReport")  --牌
        local cardCount = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_z_mj1_2_list_1_player1_RoundReport") -- 数量
        cardCount:setString(data.cardValue[index].num)
        cardValue:loadTexture(CardFactory:getInstance():getSurfaceSkin(data.cardValue[index].val), ccui.TextureResType.plistType)
        -- 客户端自己判断
        if data.type ~= PlayType.OPERATE_AN_GANG and data.type ~= PlayType.OPERATE_BU_GANG_A_CARD and data.type ~= PlayType.OPERATE_GANG_A_CARD then
            if data.type ~= PlayType.DISPLAY_JI_WUGU_XINGQI and data.cardValue[index].val == 11 then
                _list_card:setVisible(false)
            end
            if data.cardValue[index].val == 0 or data.cardValue[index].val == 28 then
                _list_card:setVisible(false)
            end
        else
            -- 豆 或者 杠 不需要显示数量
            cardCount:setVisible(false)
        end
    end
end

function UIRoundReportPage2:_processData()
    self._huData = {}
    self._eventData = {}

    for index, player in ipairs(self._players) do
        local id = player.playerData.id
        local matchResult = self:_findPlayerMatchResult(id)
        local listHuData = {}
        local listEventData = {}
        local huData = { tingText = tingType[false], huImg = "" }

        --用于记录每一组的次序,方便排序
        local index = 1
        for _, event in ipairs(matchResult.events) do -- ResultEventPROTO
            local op = event.addOperation
            local score = event.score
            local subscores = event.subScores
            local targets = event.targets
            local scoreTotal = event.eventPoint

            -- 胡牌类型单独处理
            if score.type >= PlayType.HU_PING_HU and score.type <= PlayType.HU_END then
                huData.tingText = tingType[op]
                huData.huImg = getHuImg(score.type, op)

                --子胡牌类型加入列表
                for _, subscore in ipairs(subscores) do
                    if subscore.point ~= 0 then
                        local operatorCharacter = getOpCharForHuData(subscore.calcType, op)
                        local labelScore = operatorCharacter .. subscore.point
                        local targets = ""
                        if (subscore.type ~= PlayType.DISPLAY_BETTING_HORSE) then
                            targets = #event.targets > 1 and ("x" .. #event.targets) or ""
                        end
                        table.insert(listHuData, {
                            index = index - 1000,
                            labelScore = labelScore .. targets,
                            labelType = Constants.SpecialEvents.getName(subscore.type),
                            targetPosition = self:_getPlayerPosition(event.eventPoint >= 0 and player.playerData.id or event.targets[1]),
                            targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[1], event.eventPoint >= 0),
                        })
                        index = index + 1
                    end
                end
                --买马相关特殊处理
            elseif score.type >= PlayType.DISPLAY_HU_BUY_HORSE_SCORE and score.type <= PlayType.DISPLAY_BE_HU_PUNISH_HORSE_SCORE then
                --// 这个score用来表示事件内容 吃碰杠等
                local labelScore = ""
                local mutliTimes = "";
                local times = #event.targets;
                for _, subscore in ipairs(subscores) do
                    local operatorCharacter = ''

                    --因为calcType在服务器不好修改，所以判断逻辑放到client，解释如下：只有在calcType为x的时候才去取得，否则根据addOperation去判断+ 还是 -
                    if subscore.calcType == ScoreCalculateType.TOTAL_MULTI or subscore.calcType == ScoreCalculateType.TOTAL_MULTI_2ND then
                        operatorCharacter = CALC_OP_MAP[subscore.calcType]
                    else
                        operatorCharacter = event.addOperation and "+" or "-";
                    end

                    -- 买马和罚马的个数直接放到马的分数后面×
                    if subscore.type == PlayType.DISPLAY_BUY_HORSE or subscore.type == PlayType.DISPLAY_PUNISH_HORSE then
                        mutliTimes = "x" .. subscore.point
                    else
                        labelScore = operatorCharacter .. math.abs(subscore.point)
                    end
                end

                for i = 1, times do
                    table.insert(listEventData, {
                        index = index,
                        labelScore = labelScore .. mutliTimes,
                        labelType = Constants.SpecialEvents.getName(score.type, op),
                        targetPosition = self:_getPlayerPosition(event.eventPoint >= 0 and player.playerData.id or event.targets[1]),
                        targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[1], event.eventPoint >= 0),
                    })
                    index = index + 1
                end
            elseif score.type == PlayType.DISPLAY_FOLLOW_BANKER then
                local labelScore = ""
                for _, subscore in ipairs(subscores) do
                    local operatorCharacter = ''
                    -- 跟庄比较特殊，在服务器依旧不好判断，逻辑放在客户端
                    if (score.type == PlayType.DISPLAY_FOLLOW_BANKER) then
                        operatorCharacter = event.addOperation and "-" or "+";
                    end
                    labelScore = operatorCharacter .. math.abs(subscore.point)
                end
                for index, targetId in ipairs(event.targets) do
                    table.insert(listEventData, {
                        index = index,
                        labelScore = labelScore,
                        labelType = Constants.SpecialEvents.getName(score.type, event.addOperation),
                        targetPosition = self:_getPlayerPosition(event.eventPoint >= 0 and player.playerData.id or event.targets[index]),
                        targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[index], event.eventPoint >= 0),
                    })
                end
            elseif score.type == PlayType.DISPLAY_MULTIPLE then
                local labelScore = ""
                for _, subscore in ipairs(subscores) do
                    local operatorCharacter = ''

                    --因为calcType在服务器不好修改，所以判断逻辑放到client，解释如下：只有在calcType为x的时候才去取得，否则根据addOperation去判断+ 还是 -
                    if subscore.calcType == ScoreCalculateType.TOTAL_MULTI or subscore.calcType == ScoreCalculateType.TOTAL_MULTI_2ND then
                        operatorCharacter = CALC_OP_MAP[subscore.calcType]
                    else
                        operatorCharacter = event.addOperation and "+" or "-";
                    end


                    local mutliTimes = ''
                    -- 根据合并次数判断该项是否发生多次，发生多次则使用乘
                    if (event.combinedTimes > 0 and score.type == subscore.type) then
                        local times = event.combinedTimes + 1;
                        mutliTimes = "x" .. times;
                    end
                    labelScore = labelScore .. operatorCharacter .. math.abs(subscore.point) .. mutliTimes
                end
                --乘的次数，默认为1，不显示
                local targets = ''
                table.insert(listEventData, {
                    index = -10000,
                    labelScore = labelScore,
                    labelType = Constants.SpecialEvents.getName(score.type, event.addOperation),
                    targetPosition = self:_getPlayerPosition(player.playerData.id),
                    targetColor = huColor[5],
                })
            else
                -- 争上游的胡牌文字不显示
                if score.type >= Poker_PlayType.POKER_DISPLAY_PAI_SI_DAI_1_ZHANG and score.type <= Poker_PlayType.POKER_DISPLAY_BOTTOM_SCORE then
                    huData.tingText = ""
                end
                local labelScore = ""
                for _, subscore in ipairs(subscores) do
                    local operatorCharacter = ''

                    --因为calcType在服务器不好修改，所以判断逻辑放到client，解释如下：只有在calcType为x的时候才去取得，否则根据addOperation去判断+ 还是 -
                    if subscore.calcType == ScoreCalculateType.TOTAL_MULTI or subscore.calcType == ScoreCalculateType.TOTAL_MULTI_2ND then
                        operatorCharacter = CALC_OP_MAP[subscore.calcType]
                    else
                        operatorCharacter = event.addOperation and "+" or "-";
                    end


                    local mutliTimes = ''
                    -- 根据合并次数判断该项是否发生多次，发生多次则使用乘
                    if (event.combinedTimes > 0 and score.type == subscore.type) then
                        local times = event.combinedTimes + 1;
                        mutliTimes = "x" .. times;
                    end
                    labelScore = labelScore .. operatorCharacter .. math.abs(subscore.point) .. mutliTimes
                end
                --乘的次数，默认为1，不显示
                local targets = ''
                targets = #event.targets > 1 and ("x" .. #event.targets) or ""
                table.insert(listEventData, {
                    index = index,
                    labelScore = labelScore .. targets,
                    labelType = Constants.SpecialEvents.getName(score.type, event.addOperation),
                    targetPosition = self:_getPlayerPosition(event.eventPoint >= 0 and player.playerData.id or event.targets[1]),
                    targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[1], event.eventPoint >= 0),
                })
                index = index + 1
            end
        end

        table.insert(self._playerAllEvent, {
            listHuData = listHuData,
            listEventData = listEventData,
            huData = huData
        })
    end
end

function UIRoundReportPage2:_convertTargetsToColor2(what, isSeat)
    if isSeat then
        if #self._players == 2 then
            if what == 4 then
                what = 1
            end
            if what == 3 then
                what = 2
            end
        end
        if #self._players == 3 then
            if what == 4 then
                what = self._val_player
            end
        end
        return huColor[what]
    end

    local seat_o = self:_getPlayerPosition(what)
    return huColor[seat_o]
end

function UIRoundReportPage2:_getcolorFace(id)
    local seat_o = self:_getPlayerPosition(id)
    if #self._players == 2 then
        if seat_o == 4 then
            seat_o = 1
        end
        if seat_o == 3 then
            seat_o = 2
        end
    end
    return huColor[seat_o]
end

function UIRoundReportPage2:_getPlayerPosition(id)
    for i = 1, #self._players do
        if id == self._players[i].playerData.id then
            if #self._players == 2 then
                if self._players[i].playerData.position == 4 then
                    return 1
                end
                if self._players[i].playerData.position == 3 then
                    return 2
                end
            end
            if #self._players == 3 then
                if self._players[i].playerData.position == 4 then
                    return self._val_player
                end
            end
            return self._players[i].playerData.position
        end
    end
end

function UIRoundReportPage2:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

function UIRoundReportPage2:_onBtnBackTopClick()
    -- 继续和返回 哪个显示调用哪个，优先返回
    if self._btnBack:isVisible() then
        self:_onBack()
    elseif self._btnContinue:isVisible() then
        -- if not self._isPokerGameType then -- in mahjong
        --     self:_onRoomCard()
        -- else
        self:_onClickContinue()
        -- end
    else
        self:_onBack()
    end
end

return UIRoundReportPage2