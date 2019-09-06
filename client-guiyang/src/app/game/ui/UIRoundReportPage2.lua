--[[牌局结算(战绩牌局)界面
--]]
local csbPath = "ui/csb/UIRoundReport2.csb"
local super = require("app.game.ui.UIBase")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

local UIRoundReportPage2 = class("UIRoundReportPage2", super, function() return kod.LoadCSBNode(csbPath) end)

local huImgs = {
    [PlayType.HU_ZI_MO] = {img = "Icon/z_jstzm.png", be = "Icon/z_jstbzm.png"},
    [PlayType.HU_DIAN_PAO] = {img = "Icon/z_jstch.png", be = "Icon/z_jstdp.png"},
    [PlayType.HU_CHA_DA_JIAO_GUIYANG] = {img = "Icon/z_jsthz.png", be = "Icon/z_jsthz.png"},
}
local huColor = {
    {r = 52, g = 144, b = 65, img = "img/Icon_frame22.png"},
    {r = 213, g = 135, b = 0, img = "img/Icon_frame33.png"},
    {r = 161, g = 93, b = 192, img = "img/Icon_frame44.png"},
    {r = 0, g = 117, b = 201, img = "img/Icon_frame11.png"},
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
    self._btnRoomCard = nil     -- 返回牌桌
    self._scheduleOnce = nil
    self._players = {}
    self._playerRecords = {}
    self._huData = {}
    self._eventData = {}
    self._tingData = {}
    self._val_player = 2
    self._huImg = {}
    self._nodeJiCard = nil
    self._imgJiCard = nil
    self._showCards = {}

    self._timeSchedule = nil        -- 继续定时器
end

function UIRoundReportPage2:init()
    self._btnCardInfo = seekNodeByName(self, "Button_1_RoundReport", "ccui.CheckBox")
    self._btnShare = seekNodeByName(self, "Button_2_RoundReport", "ccui.CheckBox")
    self._btnContinue = seekNodeByName(self, "Button_3_RoundReport", "ccui.CheckBox")
    self._btnBackTop = seekNodeByName(self, "Button_back_HisRecord", "ccui.Button") -- 新版UI左上角统一的返回
    self._btnBack = seekNodeByName(self, "Button_fh_RoundReport", "ccui.CheckBox")
    self._btnHelp = seekNodeByName(self, "Button_help_RoundReport", "ccui.Button")
    self._btnRoomCard = seekNodeByName(self, "Button_roomCard", "ccui.Button")
    self._nodeJiCard = seekNodeByName(self, "Node_jiCard", "cc.Node")
    self._imgJiCard = seekNodeByName(self, "Image_jiCard", "ccui.ImageView")
    self._continueTitle = 
    
    bindEventCallBack(self._btnCardInfo, handler(self, self._onClickCardsInfo), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnContinue, handler(self, self._onClickContinue), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBack, handler(self, self._onBack), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRoomCard, handler(self, self._onRoomCard), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBackTop, handler(self, self._onBtnBackTopClick), ccui.TouchEventType.ended)
    self._btnHelp:setVisible(false)
    
    self._listviewPlayerInfo = ccui.Helper:seekNodeByName(self, "ListView_RoundReport")
    self._listviewPlayerInfo:setClippingEnabled(false)
    
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
    if (self._from == "" or self._from == "historyDetail") and (not self._isPaoDeKuai) then
        UIManager:getInstance():show("UICardsInfo_new", self._players, self._playerRecords, self._from, self._huImg, self._eventData, self._gamePlay)
        self:_onBack()
        return
    end

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
    if self._isPaoDeKuai then
        UIManager:getInstance():show("UICardsInfo_Paodekuai", playerDatas, playerInfos , lastCards)
    else
        UIManager:getInstance():show("UICardsInfo", playerDatas, playerInfos , lastCards)
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

    return playerDetail
end

function UIRoundReportPage2:_convertToPlayerInfo(player)
    local playerInfo = {}
    local playerInfo_ = player.playerData
    playerInfo.roleId = playerInfo_.roleId;
    playerInfo.roleName = playerInfo_.name;
    playerInfo.iconUrl = playerInfo_.faceUrl;
    playerInfo.headFrame = playerInfo_.headFrame;
    playerInfo.position = playerInfo_.position;
    playerInfo.seat = playerInfo_.seat;
    playerInfo.totalScore = playerInfo_.totalPoint;
    return playerInfo
end

function UIRoundReportPage2:_onClickShare()
    Logger.debug("_onClickShare")
    share.ShareWTF.getInstance():share(share.constants.ENTER.FINAL_REPORT ,  {{enter = share.constants.ENTER.FINAL_REPORT}})
end

function UIRoundReportPage2:_onClickContinue()
    -- 清空缓存UI
    game.service.LocalPlayerService:getInstance():clearToundReportPage()

    -- 统计算分详情界面继续点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoomCard_Continue)

    local gameService = gameMode.mahjong.Context.getInstance():getGameService();
    if gameService and gameService:getFinishMachResult() == nil then
        if game.service.LocalPlayerService:getInstance():isWatcher() then
            -- 观察者显示界面的时候，就已经清除了，因为这时可能打牌的玩家已经开局了，所以，这里不能再清除一次了
        else
            gameService:prepareForNextRound()
        end
        self:_onBack()
    else
        local roomService = game.service.RoomService:getInstance()
        if roomService then 
            local isTrustDis = roomService:getIsTrustDismiss() 
            if isTrustDis == true then 
                game.ui.UIMessageTipsMgr.getInstance():showTips("牌局中有玩家未取消托管，房间自动解散", 5) 
            end 
        end

        local players = self._players
        -- 这边拿到的是一个已经被修改过的协议体，直接取字段可能会报错，通过rawget去取
        local roomClubId = rawget(self._playerRecords, "roomClubId") or 0
        local roomLeagueId = rawget(self._playerRecords, "roomLeagueId") or 0
        self:_onBack()
        if roomClubId ~= 0 then
            GameFSM:getInstance():enterState("GameState_Club");
        elseif roomLeagueId ~= 0 then
            GameFSM:getInstance():enterState("GameState_League");
        else
            GameFSM:getInstance():enterState("GameState_Lobby");
        end
        UIManager:getInstance():show("UIFinalReport", players, gameService:getFinishMachResult())
    end
end

-- 返回牌桌
function UIRoundReportPage2:_onBtnBackTopClick()
    local roomService = game.service.RoomService:getInstance()
    if roomService ~= nil and self._from ~= "historyDetail" then 
        -- 检测玩家是否在大联盟牌局结算中且不为最后一局
        if roomService:isBigLeagueReport() then 
            self:_onClickContinue()
            return 
        end 
    end 

    -- 继续和返回 哪个显示调用哪个，优先返回
    if self._btnBack:isVisible() then
        self:_onBack()
    elseif self._btnContinue:isVisible() then
        if not self._isPaoDeKuai and not game.service.LocalPlayerService:getInstance():isWatcher() then -- in mahjong
            self:_onRoomCard()
        else
            self:_onClickContinue()
        end
    else
        self:_onBack()
    end
end

function UIRoundReportPage2:_onBack()
    self:onHide()
    UIManager:getInstance():destroy("UIRoundReportPage2")
end

function UIRoundReportPage2:_destroy()
    UIManager:getInstance():destroy("UIRoundReportPage2")
end

function UIRoundReportPage2:onShow(...)
    --提审相关（结算界面微信分享按钮隐藏）
    if GameMain.getInstance():isReviewVersion() then
        self._btnShare:setVisible(false)
    end
    
    local args = {...}
    self:_clearData()
    local roundReportData = args[2] -- BCMatchResultSYN
    if not roundReportData or not roundReportData.matchResults then return end
    local players = args[1]
    
    self._players = players

    -- 判断是否为跑得快玩法
    local gameType = Constants.SpecialEvents.gameType
    self._gamePlay = args[4]
    if self._gamePlay ~= nil then
        self._isPaoDeKuai = self._gamePlay == 'GAME_TYPE_PAODEKUAI'
    else
        self._isPaoDeKuai = gameType == 'GAME_TYPE_PAODEKUAI'
    end
    --居中显示
    if #self._players == 2 then
        self._listviewPlayerInfo:setContentSize(448, 460)
    elseif #self._players == 3 then
        self._listviewPlayerInfo:setContentSize(700, 460)
    else
        self._listviewPlayerInfo:setContentSize(920, 460)
    end
    
    self:showRoundData(players, roundReportData)
    
    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    if self._mask then
        self._mask:setOpacity(220)
    end
    self._from = args[3] or ""

    -- 初始化定时器相关
    self:_initTimeSchedule()

    if self._from ~= "" and self._from == "historyDetail" then
        self._btnContinue:setVisible(false)
        self._btnBack:setVisible(true)
        self._btnRoomCard:setVisible(false)
        self._btnCardInfo:setVisible(true)
    else
        --self._btnContinue:setVisible(true)
        self._btnBack:setVisible(false)
        self._btnCardInfo:setVisible(true)
        self._btnRoomCard:setVisible((not game.service.LocalPlayerService:getInstance():isWatcher()) and not self._isPaoDeKuai)
    end

    -- 当是观察者的时候，它的下一局准备不会对原牌局产生影响
    -- 同样的，如果其它人都准备了，但是他没有的话，那么也会开局的，如果不处理，会对正常流程的防御性代码产生影响
    -- 最终结算的时候，RoomService已经释放，就不用再管了，直接走平常的处理吧
    local context = gameMode.mahjong.Context.getInstance();
    local gameService = nil;
    if context then   -- 在亲友圈查看结果而不需要打牌环境的时候context为空
        gameService = gameMode.mahjong.Context.getInstance():getGameService();
    end
    if game.service.LocalPlayerService:getInstance():isWatcher()
        and gameService and gameService:getFinishMachResult() == nil then
        gameService:prepareForNextRound(true)
    end

    -- 观战是新游戏开始关闭结算界面
    if gameService then
        gameService:addEventListener("EVT_NEW_GAME_ROUND_BEGIN", handler(self, self._destroy));
    end 

    self:_refreshed()

    self:_setHasPlayFastMode()
end

function UIRoundReportPage2:_initTimeSchedule()
    if self._from == "historyDetail" then 
        return 
    end 
    
    local roomService = game.service.RoomService:getInstance()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if not roomService or not gameService then 
        return 
    end

    -- 检测玩家是否在大联盟牌局结算中且不为最后一局
    if not roomService:isBigLeagueReport() then 
        return 
    end 

    -- 判定剩余时间是否为0
    local retainTime = roomService:getBattleEndRetainTime()
    if retainTime <= 0 then 
        return 
    end 

    -- 开始倒计时...
    local titleText = self._btnContinue:getChildByName("BitmapFontLabel_1_0_0")
    titleText:setString(string.format("继续(%dS)", retainTime))
    if self._timeSchedule ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
    end 

    local function _update(dt)
        retainTime = retainTime - 1 
        titleText:setString(string.format("继续(%dS)", retainTime))
        if retainTime <= 0 then 
            -- 关闭定时器
            if self._timeSchedule ~= nil then 
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
                self._timeSchedule = nil
            end 
            --
            self:_onClickContinue()
        end 
    end 
    self._timeSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_update, 1, false)
end 

-- 由于服务器登录时才把玩家是否玩过极速模式的状态进行更新，客户端暂时保存一份临时数据
function UIRoundReportPage2:_setHasPlayFastMode()
    local playerService = game.service.LocalPlayerService.getInstance()
    if playerService:getHasPlayFastMode() == false then
        local roomService =  game.service.RoomService:getInstance()
        if roomService ~= nil and roomService:isFastMode() then
            playerService:setHasPlayFastMode(true)
        end
    end
end

-- 处理断线重连逻辑
function UIRoundReportPage2:_refreshed()
    local data = game.service.LocalPlayerService:getInstance():loadLocalRoundReportPage()
    if self._playerRecords.isRejoin then
        if data:getIsVisible_cardinfo() then
            self:_onClickCardsInfo()
        elseif data:getIsVisible_lastcard() then
            self:_onRoomCard()
        end
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

    for k,v in pairs(self._showCards) do
        CardFactory:getInstance():releaseCard(v);
    end

    self._showCards = {}

    -- 关闭定时
    if self._scheduleOnce ~= nil then
        unscheduleOnce(self._scheduleOnce)
        self._scheduleOnce = nil 
    end

    -- 关闭定时器
    if self._timeSchedule ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
    end 
end

function UIRoundReportPage2:_onShowData()
    self._listviewPlayerInfo:removeAllChildren()

    -- 处理玩家头像框
    for index, data in ipairs(self._tingData) do
        if data.tingPlayType ~= PlayType.HU_WEI_JIAO_PAI and data.tingPlayType ~= PlayType.HU_JIAO_PAI and data.tingPlayType ~= PlayType.HU_MEN_HU then
            local matchResult = self:_findPlayerMatchResult(data.playid)
            local huInfo = {}

            if matchResult ~= nil then
                for _, event in ipairs(matchResult.events) do
                    local targets = event.targets
                    if event.score.type == PlayType.HU_ZI_MO or event.score.type == PlayType.HU_DIAN_PAO then
                        local huImg = {}
                        table.insert(huImg, {huimg = huImgs[event.score.type].img, playid = data.playid})
                        for i = 1, #targets do
                            table.insert(huImg, {huimg = huImgs[event.score.type].be, playid = targets[i]})
                        end
                        huInfo = huImg
                    end
                end
            end
            if #huInfo > 0 then
                table.insert(self._huImg, huInfo)
            end
        end
    end

    for index = 1, #self._players do
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
        self._imageDianPao = ccui.Helper:seekNodeByName(node, "Image_jst_Player1_RoundReport")    --胡牌类型（自摸点炮）
        self._imageTingType = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_z_tital_Player1_RoundReport")--胡牌类型（叫牌）
        self._textID = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_ID_Player1_RoundReport")             --roleId
        self._listScore = ccui.Helper:seekNodeByName(node, "ListView_list_1_player1_RoundReport")         --胡牌类型（分数）
        self._zhuang = ccui.Helper:seekNodeByName(node, "Image_iconz_Player1_RoundReport")         --庄
        self._zhuang:setVisible(player.playerData.isBanker and not self._isPaoDeKuai)
        self._listScore:setScrollBarEnabled(false)
        game.util.PlayerHeadIconUtil.setIcon(self._imageFace, player.playerData.faceUrl)		
        self._textName:setString(kod.util.String.getMaxLenString(player.playerData.name, 8))

        if matchResult ~= nil then
            self._textScore:setString(matchResult.totalPoint)
            UtilsFunctions.setScoreWithColor(self._textSZ, matchResult.pointInGame)
        end

        
        -- 设置头像角标
        local huImage = nil
        if not self._playerRecords.isHuang and #self._huImg > 0 then
            for index, data in ipairs(self._huImg) do
                for _, _data in ipairs(data) do
                    if _data.playid == player.playerData.roleId then
                        huImage = _data.huimg
                    end
                end
            end
        else
            if Constants.SpecialEvents.gameType == "GAME_TYPE_PAODEKUAI" then

            else
                huImage = huImgs[PlayType.HU_CHA_DA_JIAO_GUIYANG].img
            end
        end

        self._imageDianPao:setVisible(huImage ~= nil and huImage ~= "")
        if huImage and huImage ~= "" then
            self._imageDianPao:loadTexture(huImage)
        end

        -- 处理胡牌类型
        local tingPlayType = nil
        for _, data in ipairs(self._tingData) do
            if data.playid == player.playerData.roleId then
                tingPlayType = data.tingPlayType
            end
        end
        self._imageTingType:setVisible(tingPlayType ~= nil)
        if tingPlayType ~= nil then
            if self._playerRecords.isHuang and tingPlayType ~= PlayType.HU_WEI_JIAO_PAI and tingPlayType ~= PlayType.HU_JIAO_PAI then
                tingPlayType = PlayType.HU_MEN_HU
            end
            self._imageTingType:setString(Constants.SpecialEvents.getName(tingPlayType))
        end
        
        
        local _colorplay = self:_getcolorFace(player.playerData.roleId)
        self._colorFace:loadTexture(_colorplay.img)
        
        self._textID:setString("ID:" .. player.playerData.roleId)
        
        self:_showHistoryData(self._listScore, index)
        
    end

    -- 鸡牌
    self._imgJiCard:setVisible(false)
    if self._playerRecords.spceialsCards ~= nil then
        local spceialsCards = self._playerRecords.spceialsCards
        if type(spceialsCards) ~= "table" then
            spceialsCards = clone(CardDefines.getCards(spceialsCards));
        end
        
        if #spceialsCards > 0 and spceialsCards[1] ~= 0 then
             self._imgJiCard:setVisible(true)
            self:_addOneCard(self._imgJiCard, spceialsCards[1], 50, 40, 0, CardDefines.CardState.Chupai, 1)
        end
    end
end

-- 创建牌
function UIRoundReportPage2:_addOneCard(box, cardValue, x, y, zOrder, playtype, scale)
    if type(cardValue) ~= "number" then
        return
    end

    local cardInfo = CardFactory:getInstance():CreateCard({ chair = CardDefines.Chair.Down, state = playtype or CardDefines.CardState.Chupai, cardValue = cardValue });
    table.insert(self._showCards,cardInfo);
    zOrder = zOrder or 0
    scale = scale or 1.5
    box:addChild(cardInfo, zOrder)
    cardInfo:setPositionX(x);
    cardInfo:setPositionY(y - 13);
    cardInfo:setScale(scale)

    return cardInfo;
end

function UIRoundReportPage2:_findPlayerMatchResult(roleId)
    for _, data in ipairs(self._playerRecords.matchResults) do
        if data.roleId == roleId then
            return data
        end
    end
    -- 若找不到玩家则打印玩家信息
    -- Macro.assetTrue( true, "ERROR: THERE IS NO PLAYER");
    -- Logger.debug("========roleId="..roleId.."=========");
    -- for _, data in ipairs(self._playerRecords.matchResults) do
    --     Logger.debug(data.roleId);
    -- end
    return nil
end

function UIRoundReportPage2:_showHistoryData(_scoreData, _index)
    self._listScoreData = ccui.Helper:seekNodeByName(_scoreData, "Panel_2_list_1_player1_RoundReport")
    self._listScoreCard = ccui.Helper:seekNodeByName(_scoreData, "Panel_2_list_1_player1_RoundReport_0")
    
    self._listScoreData:removeFromParent(false)
    self:addChild(self._listScoreData)
    self._listScoreData:setVisible(false)
    
    self._listScoreCard:removeFromParent(false)
    self:addChild(self._listScoreCard)
    self._listScoreCard:setVisible(false)
    
    _scoreData:removeAllChildren()
    
    for _, data in ipairs(self._eventData[_index]) do
        
        if data.isStatus then
            local node1 = self._listScoreCard:clone()
            _scoreData:addChild(node1)
            node1:setVisible(true)
            local text1 = ccui.Helper:seekNodeByName(node1, "BitmapFontLabel_z_2_list_2_player1_RoundReportrt_0") 	--牌形
            local text2 = ccui.Helper:seekNodeByName(node1, "BitmapFontLabel_f_2_list_2_player1_RoundReport_0")   	--分数
            local list_card = ccui.Helper:seekNodeByName(node1, "ListView_2_list_1_player1_RoundReport") --牌值
            local bimg = ccui.Helper:seekNodeByName(node1, "Image_t_2_list_2_player1_RoundReport")       --背景
            list_card:setScrollBarEnabled(false)
            
            text1:setString(data.labelType)
            
            if tonumber(data.labelScore) < 0 then
                bimg:loadTexture("img/img_bdjs1.png")
            else
                bimg:loadTexture("img/img_bdjs0.png")
            end
            
            if data.labelCount ~= 1 and data.labelCount1 ~= 1 then
                local num_Score = tonumber(data.labelScore) * data.labelCount
                if tonumber(data.labelScore) > 0 then
                    text2:setString("+" .. num_Score .. "×" .. data.labelCount1)
                else
                    text2:setString(num_Score .. "×" .. data.labelCount1)
                end
                
            elseif data.labelCount ~= 1 then
                local num_Score = tonumber(data.labelScore) * data.labelCount
                if tonumber(data.labelScore) > 0 then
                    text2:setString("+" .. num_Score)
                else
                    text2:setString(num_Score)
                end
            elseif data.labelCount1 > 1 then
                text2:setString(data.labelScore .. "×" .. data.labelCount1)
            else
                text2:setString(data.labelScore)
            end
            
            text1:setColor(cc.c4b(data.targetColor.r, data.targetColor.g, data.targetColor.b, 255))
            text2:setColor(cc.c4b(data.targetColor.r, data.targetColor.g, data.targetColor.b, 255))
            
            self:_showCard(list_card, data)
        else
            for i = 1, #data.labelType do
                local node = self._listScoreData:clone()
                _scoreData:addChild(node)
                node:setVisible(true)
                local text1 = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_z_2_list_1_player1_RoundReportrt") 	--牌形
                local text2 = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_f_2_list_1_player1_RoundReport")   	--分数
                local bimg = ccui.Helper:seekNodeByName(node, "Image_t_2_list_1_player1_RoundReport")       --背景
                text1:setString(data.labelType[i])
                
                local c = string.sub(data.labelScore[i],1,1)
                if string.sub(data.labelScore[i],1,1) ~= "+" and string.sub(data.labelScore[i],1,1) ~= "-" then
                    bimg:loadTexture("img/img_bdjs0.png")
                elseif tonumber(data.labelScore[i]) < 0 then
                    bimg:loadTexture("img/img_bdjs1.png")
                else
                    bimg:loadTexture("img/img_bdjs0.png")
                end
                
                if  data.labelCount[i] > 1 then
                    text2:setString(data.labelScore[i] .. "×" .. data.labelCount[i])
                else
                    text2:setString(data.labelScore[i])
                end
                
                text1:setColor(cc.c4b(data.targetColor.r, data.targetColor.g, data.targetColor.b, 255))
                text2:setColor(cc.c4b(data.targetColor.r, data.targetColor.g, data.targetColor.b, 255))
            end
        end
        
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
        local roleId = player.playerData.roleId
        local matchResult = self:_findPlayerMatchResult(roleId)
        local listHuData = {}
        local listEventData = {}
        local listTingData = {}
        local newList = {}
        
        if matchResult == nil then
            return
        end
        for _, event in ipairs(matchResult.events) do -- ResultEventPROTO
            local op = event.addOperation
            local score = event.score
            local subscores = event.subScores
            local targets = event.targets
            local scoreTotal = event.eventPoint
            local tingText = nil

            if score.type == PlayType.HU_ZI_MO or score.type == PlayType.HU_DIAN_PAO then
                if op then 
                    -- 记录胡牌牌形
                    if #self._tingData > 0 then
                        for i =1, #self._tingData do
                            if self._tingData[i].playid == roleId then
                                for _, data in ipairs(subscores) do
                                    if data.type ~= PlayType.HU_ZI_MO and data.type ~= PlayType.HU_GANG_SHANG_HUA and data.type ~= PlayType.HU_GANG_SHANG_PAO then
                                        self._tingData[i].tingPlayType = data.type
                                    end
                                end
                            elseif i == #self._tingData then
                                for _, data in ipairs(subscores) do
                                    if data.type ~= PlayType.HU_ZI_MO and data.type ~= PlayType.HU_GANG_SHANG_HUA and data.type ~= PlayType.HU_GANG_SHANG_PAO then
                                        table.insert(self._tingData, {
                                            tingPlayType = data.type,
                                            playid = roleId
                                        })
                                    end
                                end
                            end
                        end
                    else
                        for _, data in ipairs(subscores) do
                            if data.type ~= PlayType.HU_ZI_MO and data.type ~= PlayType.HU_GANG_SHANG_HUA and data.type ~= PlayType.HU_GANG_SHANG_PAO then
                                table.insert(self._tingData, {
                                    tingPlayType = data.type,
                                    playid = roleId
                                })
                            end
                        end
                    end
                end

                local huScoreList = {}
                local huTypeList = {}
                local list_count = 1
                local eventCount = {}
                for _, subscore in ipairs(subscores) do
                    if subscore.point ~= 0 then
                        local oopp = subscore.calcType == 2 and(event.addOperation and(subscore.point < 0 and "-" or "+") or(subscore.point < 0 and "+" or "-")) or ""
                        if score.type ~= PlayType.DISPLAY_MULTIPLE then
                            huScoreList[list_count] = oopp .. subscore.point
                            huTypeList[list_count] = Constants.SpecialEvents.getName(subscore.type)
                            eventCount[list_count] = #targets
                            list_count = list_count + 1
                        end
                    end
                end
                table.insert(listHuData, {
                    labelScore = huScoreList,
                    labelType = huTypeList,
                    labelCount = eventCount,
                    isStatus = false,
                    targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[1], event.eventPoint >= 0),
                    target = event.eventPoint >= 0 and player.playerData.position or event.targets[1],
                })
            elseif score.type == PlayType.HU_JIAO_PAI or score.type == PlayType.HU_WEI_JIAO_PAI or score.type == PlayType.HU_MEN_HU then
                -- 贵阳专有，叫牌，未叫牌
                if op then
                    -- op 是自己的才会添加
                    if #self._tingData > 0 then
                        for i =1, #self._tingData do
                            if self._tingData[i].playid == roleId and self._tingData[i].tingPlayType ~= PlayType.HU_MEN_HU then
                                self._tingData[i].tingPlayType = score.type
                            elseif i == #self._tingData then
                                table.insert(self._tingData, {
                                    tingPlayType = score.type,
                                    playid = roleId
                                })
                            end
                        end
                    else
                        table.insert(self._tingData, {
                            tingPlayType = score.type,
                            playid = roleId
                        })
                    end
                end
                
                local huScoreList = {}
                local huTypeList = {}
                local list_count = 1
                local addHuList = false
                local eventCount = {}
                for _, subscore in ipairs(subscores) do
                    -- 如果有 HU_CHA_DA_JIAO_GUIYANG 说明当前没有胡牌，需要用叫牌来处理胡牌得分
                    -- huImg 胡牌的最前面图片也要改
                    if subscore.type == PlayType.HU_CHA_DA_JIAO_GUIYANG then
                        -- huImg = huImgs[subscore.type].img
                        addHuList = true
                    else
                        if subscore.point ~= 0 then
                            local oopp = subscore.calcType == 2 and(event.addOperation and(subscore.point < 0 and "-" or "+") or(subscore.point < 0 and "+" or "-")) or ""
                            if score.type ~= PlayType.DISPLAY_MULTIPLE then
                                huScoreList[list_count] = oopp .. subscore.point
                                huTypeList[list_count] = Constants.SpecialEvents.getName(subscore.type)
                                eventCount[list_count] = #targets
                                list_count = list_count + 1
                            end
                        end
                    end
                end
                if addHuList then
                    table.insert(listHuData, {
                        labelScore = huScoreList,
                        labelType = huTypeList,
                        isStatus = false,
                        labelCount = eventCount,
                        targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[1], event.eventPoint >= 0),
                        target = event.eventPoint >= 0 and player.playerData.position or event.targets[1],

                    })
                end
            else
                if event.eventPoint ~= 0 and #subscores > 0 then					
                    local subscore = subscores[1] -- 只会有1个					
                    local sformat = subscore.calcType == 2 and(event.addOperation and(subscore.point < 0 and "-%d" or "+%d") or(subscore.point < 0 and "+%d" or "-%d")) or "%d"
                    local eventName = Constants.SpecialEvents.getName(subscore.type, event.addOperation)
                    local eventCount = math.floor(math.abs(event.eventPoint) / math.abs(subscore.point))
                    local huType = subscore.type
                    if score.type ~= PlayType.DISPLAY_MULTIPLE then		
                        table.insert(listEventData, {
                            labelType = eventName,
                            labelScore = string.format(sformat, math.abs(subscore.point)),
                            labelCount = 1,
                            labelCount1 = eventCount,
                            isStatus = true,
                            targetColor = self:_convertTargetsToColor2(event.eventPoint >= 0 and player.playerData.position or event.targets[1], event.eventPoint >= 0),
                            cardValue = {{val = event.sourceCard, num = 1}},
                            target = event.eventPoint >= 0 and player.playerData.position or event.targets[1],
                            type = huType
                        })
                    end
                end
            end
        end
        table.foreach(listEventData, function(key, val)
            for i, newval in ipairs(newList) do
                if newval.labelType == val.labelType and newval.target == val.target and newval.type == val.type then
                    -- 合并
                    for index = 1, #newval.cardValue do
                        if newval.cardValue[index].val ~= 0 then
                            if newval.cardValue[index].val ~= val.cardValue[1].val and #newval.cardValue == 1 then
                                table.insert(newval.cardValue, val.cardValue[1])
                                newval.labelCount = newval.labelCount + val.labelCount
                                return
                            end
                            if newval.cardValue[index].val == val.cardValue[1].val then
                                newval.cardValue[index].num = newval.cardValue[index].num + val.cardValue[1].num
                                newval.labelCount = newval.labelCount + val.labelCount
                                return
                            end
                            if index == #newval.cardValue then
                                table.insert(newval.cardValue, val.cardValue[1])
                                newval.labelCount = newval.labelCount + val.labelCount
                                return
                            end
                        end
                    end
                end
            end
            table.insert(newList, val)
        end)
        -- 排序
        local list_jia = {}
        local list_PlayerInfo = {}
        
        for index = 1, #listHuData do
            if tonumber(listHuData[index].labelScore[1]) ~= nil then
                if tonumber(listHuData[index].labelScore[1]) > 0 then
                    table.insert(list_jia, 1, listHuData[index])
                else
                    if #list_PlayerInfo ~= 0 then
                        local isStatus1 = true
                        local isIndex = #list_PlayerInfo + 1
                        for index1 = 1, #list_PlayerInfo do
                            if list_PlayerInfo[index1].target > self:_getPlayerPosition(listHuData[index].target) and isStatus1 then
                                isIndex = index1
                                isStatus1 = false
                            end
                        end
                        table.insert(list_PlayerInfo, isIndex, listHuData[index])
                    else
                        table.insert(list_PlayerInfo, 1, listHuData[index])
                    end
                end
            end
        end
        
        for index = 1, #newList do
            if tonumber(newList[index].labelScore) ~= nil then
                if tonumber(newList[index].labelScore) > 0 then
                    table.insert(list_PlayerInfo, 1, newList[index])
                else
                    if #list_PlayerInfo ~= 0 then
                        local isStatus1 = true
                        local isIndex = #list_PlayerInfo + 1
                        for index1 = 1, #list_PlayerInfo do
                            if list_PlayerInfo[index1].target > newList[index].target and isStatus1 then
                                isIndex = index1
                                isStatus1 = false
                            end
                        end
                        table.insert(list_PlayerInfo, isIndex, newList[index])
                    else
                        table.insert(list_PlayerInfo, 1, newList[index])
                    end
                end
            end
        end
        
        for index = 1, #list_jia do
            table.insert(list_PlayerInfo, 1, list_jia[index])
        end
        
        table.insert(self._huData, listHuData)
        table.insert(self._eventData, list_PlayerInfo)
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

function UIRoundReportPage2:_getcolorFace(roleId)
    local seat_o = self:_getPlayerPosition(roleId)
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

function UIRoundReportPage2:_getPlayerPosition(roleId)
    for i = 1, #self._players do
        if roleId == self._players[i].playerData.roleId then
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

return UIRoundReportPage2