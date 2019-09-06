local csbPath = "ui/csb/UICardsInfo_new.csb"
local super = require("app.game.ui.UIBase")

local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Constants = require("app.gameMode.mahjong.core.Constants")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local UtilsFunctions = require("app.game.util.UtilsFunctions")

-- 主要牌起始位置
local MAIN_START_X = 170
local MAIN_START_Y = 10
-- 杠牌第四张的空隙 */
local GANG_SPACE = 15

local huImgs = {
    [PlayType.HU_ZI_MO] = {img = "Icon/z_jstzm.png", be = "Icon/z_jstbzm.png"},
    [PlayType.HU_DIAN_PAO] = {img = "Icon/z_jstch.png", be = "Icon/z_jstdp.png"},
    [PlayType.HU_CHA_DA_JIAO_GUIYANG] = {img = "Icon/z_jsthz.png", be = "Icon/z_jsthz.png"},
}

--[[
    新版的牌局详情
]]

local UICardsInfo_new= class("UICardsInfo_new", super, function() return kod.LoadCSBNode(csbPath) end)

function UICardsInfo_new:ctor()
    self._playerRecords = {}
    self._players = {}
    self._playerInfos = {}
    self._playerDatas = {}
    self._showCards = {}
    self._huType = {}
    self._nodeJiCard = nil
    self._imgJiCard = nil
    self._gui = {}
    self._guiSet = {}

    self._timeSchedule = nil 
end

function UICardsInfo_new:init()
	--玩家列表
	self._playerListView = seekNodeByName(self, "ListView_Player", "ccui.ListView");
    self._playerListView:setScrollBarEnabled(false)
    self._playerListView:setTouchEnabled(false)
    --玩家项
    self._playerNode = ccui.Helper:seekNodeByName(self._playerListView, "Panel_player_CardsInfo")
	self._playerNode:removeFromParent(false)
	self:addChild(self._playerNode)
	self._playerNode:setVisible(false)

    -- 继续
    self._btnContinue = seekNodeByName(self, "Button_continue", "ccui.Button")
    -- 算分详情
    self._btnDetails = seekNodeByName(self, "Button_details", "ccui.Button")
    -- 返回
    self._btnBack = seekNodeByName(self, "Button_back", "ccui.Button")
    -- 牌桌
    self._btnRoomCard = seekNodeByName(self, "Button_roomCard", "ccui.Button")
    -- 左上角的统一返回 新版UI
    self._btnBackTop = seekNodeByName(self, "Button_back_HisRecord", "ccui.Button")

    self._nodeJiCard = seekNodeByName(self, "Node_jiCard", "cc.Node")
    self._imgJiCard = seekNodeByName(self, "Image_jiCard", "ccui.ImageView")

    bindEventCallBack(self._btnContinue, handler(self, self._onClickContinue), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBack, handler(self, self._onBack), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDetails, handler(self, self._onDetails), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRoomCard, handler(self, self._onRoomCard), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBackTop, handler(self, self._onBtnBackTopClick), ccui.TouchEventType.ended)
end

-- 显示牌桌
function UICardsInfo_new:_onRoomCard()
    -- 统计牌局详情界面查看牌桌点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoomCard_RoomCard)

     UIManager:getInstance():show("UILastCrads", self._players, self._playerRecords, self._from, "UICardsInfo_new", self._huImg, self._eventData)
     self:_onBack()
end

function UICardsInfo_new:_onDetails()
    -- 清空缓存UI
    game.service.LocalPlayerService:getInstance():clearToundReportPage()

    -- 统计算分详情点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoundReport_Details)

    UIManager:getInstance():show("UIRoundReportPage2", self._players, self._playerRecords, self._from, self._gamePlay)
    self:_onBack()
end

function UICardsInfo_new:_onBack()
    self:onHide()
    UIManager:getInstance():destroy("UICardsInfo_new")
end

function UICardsInfo_new:_onClickContinue()
    -- 清空缓存UI
    game.service.LocalPlayerService:getInstance():clearToundReportPage()

    -- 统计牌局详情界面继续点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoundReport_Continue)

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
        self:_onBack()
        if roomClubId ~= 0 then
            GameFSM:getInstance():enterState("GameState_Club");
        else
            GameFSM:getInstance():enterState("GameState_Lobby");
        end
        UIManager:getInstance():show("UIFinalReport", players, gameService:getFinishMachResult())
    end
end

function UICardsInfo_new:_onBtnBackTopClick()
    local roomService = game.service.RoomService:getInstance()
    if roomService ~= nil and self._from ~= "historyDetail" then 
        -- 检测玩家是否在大联盟牌局结算中且不为最后一局
        if roomService:isBigLeagueReport() then 
            self:_onClickContinue()
            return 
        end 
    end

    -- 继续、返回，哪个显示就调用哪个相同的按钮回调， 优先返回
    if self._btnBack:isVisible() then
        self:_onBack()
    elseif self._btnContinue:isVisible() then
        self:_onRoomCard()
    else
        self:_onBack()
    end
end

function UICardsInfo_new:_onClickCardsInfo()
    table.foreach(self._players, function(key, val)
        table.insert(self._playerInfos, self:_convertToPlayerInfo(val))
    end)
    table.foreach(self._playerRecords.matchResults, function(key, val)
        table.insert(self._playerDatas, self:_convertToPlayerData(val))
    end)
    
    -- 处理不满四人的情况
    local function getPosition(roleId)
        for i = 1, #self._playerInfos do
            if self._playerInfos[i].roleId == roleId then
                local pos = self._playerInfos[i].position < self._playerInfos[i].seat and self._playerInfos[i].position + 4 or self._playerInfos[i].position
                -- 在2，3人局时，最后一个人位置，这时position 1会被转换到4
                if #self._playerInfos == 2 and self._playerInfos[i].position == 4 then
                    return 1
                elseif #self._playerInfos == 3 and pos - self._playerInfos[i].seat == 2 and self._playerInfos[i].position == 4 then
                    return 1
                else
                    return self._playerInfos[i].position
                end
            end
        end
    end

    -- 根据玩家位置进行排序
    table.sort(self._playerInfos, function(a, b)
        return getPosition(a.roleId) < getPosition(b.roleId)
    end)

    table.sort(self._playerDatas, function(a, b)
        return getPosition(a.roleId) < getPosition(b.roleId)
    end)
end

function UICardsInfo_new:onShow(...)
    local args = {...}
    self._players = args[1]
    self._playerRecords = args[2]    
    self._from = args[3] or ""
    self._huImg = args[4]
    self._eventData = args[5]
    self._gamePlay = args[6]

    -- 算分详情按钮在大联盟牌局中隐藏
    local roomService = game.service.RoomService:getInstance()
    if roomService ~= nil then 
        local leagueId = roomService:getRoomLeagueId()
        if leagueId ~= 0 and self._from ~= "historyDetail" then 
            self._btnDetails:setVisible(false)
        end 
    end

    self:_onClickCardsInfo()

    self._playerListView:removeAllChildren()
    --根据玩家数量插入指定数量的playerUI
	if #self._playerDatas > 0 then
		for i, data in ipairs(self._playerDatas) do
            local node = self._playerNode:clone()
            node:setVisible(true)
            self._playerListView:insertCustomItem(node,i-1)
            -- 玩家信息
            self:_initPlayerInfo(node, i)
            -- 本局胡牌信息
            self:_initHuInfo(node, data, i)
		end
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

    -- 初始化定时器相关
    self:_initTimeSchedule()

    if  self._from ~= "" and  self._from == "historyDetail" then
        self._btnContinue:setVisible(false)
        self._btnBack:setVisible(true)
    else
        self._btnContinue:setVisible(true)
        self._btnBack:setVisible(false)
    end

    -- 观战和战绩不显示牌桌
    self._btnRoomCard:setVisible(not game.service.LocalPlayerService:getInstance():isWatcher() and self._from ~= "historyDetail")

    self:_refreshed()
end

function UICardsInfo_new:_initTimeSchedule()
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

    -- 隐藏算分详情按钮
    self._btnDetails:setVisible(false)

    -- 开始倒计时...
    local titleText = self._btnContinue:getChildByName("BitmapFontLabel_z_fn_JieSuanXin")
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

-- 处理断线重连逻辑
function UICardsInfo_new:_refreshed()
    local data = game.service.LocalPlayerService:getInstance():loadLocalRoundReportPage()
    if self._playerRecords.isRejoin then
        if data:getIsVisible_lastcard() then
            self:_onRoomCard()
            return
        end
    end

    data:setIsVisible(true, false)
    game.service.LocalPlayerService:getInstance():saveLocalRoundReportPage(data)
end

-- 初始化本局胡牌信息
function UICardsInfo_new:_initHuInfo(node, data, index)
    local point_hu, point_gang = self:_getPoint(data)

    -- 胡牌类型
    local imgHuType = seekNodeByName(node, "Image_huType_CardsInfo", "ccui.ImageView")
    -- 设置头像角标
    local huImage = nil
    if not self._playerRecords.isHuang and #self._huImg > 0 then
        for _, v in ipairs(self._huImg) do
            for _, _data in ipairs(v) do
                if _data.playid == data.roleId then
                    huImage = _data.huimg
                end
            end
        end
    else
        huImage = huImgs[PlayType.HU_CHA_DA_JIAO_GUIYANG].img
    end

    imgHuType:setVisible(huImage ~= nil and huImage ~= "")
    if huImage and huImage ~= "" then
        imgHuType:loadTexture(huImage)
    end


    -- 本局分数
    local textPointInGame = seekNodeByName(node, "Text_pointInGame_CardsInfo", "ccui.TextBMFont")
    UtilsFunctions.setScoreWithColor(textPointInGame ,data.pointInGame)
    -- 总分
    local textTotalPoint = seekNodeByName(node , "Text_totalPoint_CardsInfo", "ccui.Text")
    textTotalPoint:setString(string.format("总分:%d", data.totalPoint))

    -- 胡牌分
    local textPointHu = seekNodeByName(node , "Text_point_hu", "ccui.Text")
    textPointHu:setString(string.format(" %s%d", point_hu > 0 and "+" or "", point_hu))
    -- 杠分（贵阳豆分）
    local textPointGang = seekNodeByName(node , "Text_point_gang", "ccui.Text")
    textPointGang:setString(string.format(" %s%d", point_gang > 0 and "+" or "", point_gang))
    -- 其他分（贵阳鸡分）
    local textPoint = seekNodeByName(node , "Text_point", "ccui.Text")
    local point = data.pointInGame - point_gang - point_hu
    textPoint:setString(string.format(" %s%d", point > 0 and "+" or "",  point))

    -- 胡牌类型
    self:_initHuType(node, index)
end


-- 初始化胡牌类型
function UICardsInfo_new:_initHuType(node, index)
    -- 做一次胡牌类型排序
    local _textHuType = ""

    -- 拼接字符串
    local stringSplice = function(score, text, count)
        -- 正分才显示分数项
        if tonumber(score) > 0 then
            if text ~= "" and kod.util.String.getUTFLen(_textHuType) < 45 then
                _textHuType = string.format("%s%s%s", _textHuType, count == 1 and "" or "、", text)
            elseif kod.util.String.getUTFLen(_textHuType) >= 45 then
                _textHuType = _textHuType .. "..."
                return true
            end
        end

        return false
    end

    for k, v in ipairs(self._eventData[index]) do
        if v.isStatus then
            if stringSplice(v.labelScore, v.labelType, k) then
                break
            end
        else
            local quit = false
            for j = 1, #v.labelType do
                if stringSplice(v.labelScore[j], v.labelType[j], k + j - 1) then
                    quit = true
                    break
                end
            end

            if quit then
                break
            end
        end
    end

    -- 胡牌类型列表
    local scrollViewHuType = seekNodeByName(node, "ScrollView_huType", "ccui.ScrollView")
    local textHuType = seekNodeByName(node, "Text_huType", "ccui.Text")
    scrollViewHuType:setScrollBarEnabled(false)
    scrollViewHuType:setTouchEnabled(false)

    textHuType:setString(_textHuType)
    -- scrollView根据文字长度做适配
    local contentSize = scrollViewHuType:getContentSize()
	textHuType:setTextAreaSize(cc.size(0, contentSize.height))
	local _size = textHuType:getVirtualRendererSize()
	textHuType:setContentSize(cc.size(_size.width, _size.height))
	scrollViewHuType:setInnerContainerSize(cc.size(_size.width, contentSize.height))	
end

-- 获取分数
function UICardsInfo_new:_getPoint(data)
    local point_hu = 0 -- 胡牌分
    local point_gang = 0 -- 杠分
    local events = data.events

    for _, event in ipairs(events) do
        -- 胡牌分通用
        if event.score.type == PlayType.HU_ZI_MO or event.score.type == PlayType.HU_DIAN_PAO then
            if event.addOperation then
                point_hu = point_hu + event.eventPoint
            else
                point_hu = point_hu + event.eventPoint
            end

        -- 杠分通用
        elseif event.score.type == PlayType.OPERATE_AN_GANG or event.score.type == PlayType.OPERATE_BU_GANG_A_CARD or event.score.type == PlayType.OPERATE_GANG_A_CARD then
            if event.addOperation then
                point_gang = point_gang + event.eventPoint
            else
                point_gang = point_gang + event.eventPoint
            end
        end
    end

    return point_hu, point_gang
end

-- 初始化玩家信息
function UICardsInfo_new:_initPlayerInfo(node, index)
    -- 玩家头像
    local imgFace = seekNodeByName(node, "Image_face_CardsInfo", "ccui.ImageView")
    game.util.PlayerHeadIconUtil.setIcon(imgFace, self._playerInfos[index].iconUrl)

    -- 玩家头像框
    if self._playerInfos[index].headFrame ~= nil then
        local src = PropReader.getIconById(self._playerInfos[index].headFrame)    
        game.util.PlayerHeadIconUtil.setIconFrame(imgFace,src,1.0)        
    end

    -- 玩家昵称
    local textName = seekNodeByName(node, "Text_name_CardsInfo", "ccui.Text")
    textName:setString(kod.util.String.getMaxLenString(self._playerInfos[index].roleName, 8))
    -- 玩家显示id
    local textId = seekNodeByName(node, "Text_id_CardsInfo", "ccui.Text")
    textId:setString(string.format("ID:%d", self._playerInfos[index].roleId))
    -- 庄家icon
    local imgBanker = seekNodeByName(node, "Image_banker_CardsInfo", "ccui.ImageView")
    imgBanker:setVisible(self._playerInfos[index].isBanker)
    
    -- 玩家牌信息
    self:_setMajiangData(imgFace, self._playerDatas[index])
end

-- 获取玩家基本信息
function UICardsInfo_new:_convertToPlayerInfo(player)
    local playerInfo = {}
    local playerInfo_ = player.playerData
    playerInfo.roleId = playerInfo_.roleId -- id
    playerInfo.roleName = playerInfo_.name -- 昵称
    playerInfo.iconUrl = playerInfo_.faceUrl -- 头像url
    playerInfo.headFrame = playerInfo_.headFrame -- 头像框
    playerInfo.position = playerInfo_.position -- 玩家位置
    playerInfo.seat = playerInfo_.seat
    playerInfo.isBanker = playerInfo_.isBanker -- 庄家

    return playerInfo
end

-- 获取玩家的牌
function UICardsInfo_new:_convertToPlayerData(matchResult)
    local playerDetail = {}
    playerDetail.roleId = matchResult.roleId;
    playerDetail.totalPoint = matchResult.totalPoint;
    playerDetail.pointInGame = matchResult.pointInGame;
    playerDetail.events = clone(matchResult.events);

    -- 玩家手牌
    if type(matchResult.handCards) == "table" then
        playerDetail.handCards = clone(matchResult.handCards);
    else
        playerDetail.handCards = clone(CardDefines.getCards(matchResult.handCards));
    end

    -- 玩家操作的牌
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

-- 设置玩家手牌位置
function UICardsInfo_new:_setMajiangData(face, playerData)
    local root = face
    root:getParent():setVisible(true)
    local nowX = MAIN_START_X
    local nowY = MAIN_START_Y
    local mainScale = 1
    local subScale = 1

    local historyRecordService = game.service.HistoryRecordService:getInstance()
    -- 对显示顺序排序
    table.bubbleSort(playerData.operateCards, function(l, r) return historyRecordService:playTypeToSortValue(l.playType) <= historyRecordService:playTypeToSortValue(r.playType) end)

    local huPai = {}

    -- 胡牌单独提出来(胡牌大于1时改变显示格局)
    local husData = {}
    for _, n in ipairs(playerData.operateCards) do
        if Constants.PlayType.Check(n.playType, Constants.PlayType.OPERATE_HU) or Constants.PlayType.Check(n.playType, Constants.PlayType.OPERATE_MEN) then
            table.insert(husData, n)
        end
    end

    if #husData > 0 then
        for i = 1, #husData do
            for j=1, #husData[i].cards do
                table.insert(huPai, husData[i].cards[j])
            end
        end
    end

    -- 鬼牌
	local guisData = {}
	for _, n in ipairs(playerData.operateCards) do
		if Constants.PlayType.Check(n.playType, Constants.PlayType.DISPLAY_SHOW_MASTER_CARD) then
			table.insert(guisData, n)
		end
	end
	
	if #guisData > 0 then
		for i = 1, #guisData do
			for j = 1, #guisData[i].cards do
				table.insert(self._gui, guisData[i].cards[j])
				self._guiSet[guisData[i].cards[j]] = true
			end
		end
	end

    -- 显示吃碰杠
    for _, operateCard in ipairs(playerData.operateCards) do
        if operateCard.playType == Constants.PlayType.OPERATE_AN_GANG then
            for i=1, 3 do
                local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY, 0, CardDefines.CardState.GangPai2)
                nowX = nowX + cardInfo:getContentSize().width * cardInfo:getScale() 
            end

            local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY + GANG_SPACE * mainScale, 10)
            cardInfo:setPositionX(cardInfo:getPositionX() - 2 * cardInfo:getContentSize().width * cardInfo:getScale())
            nowX = nowX + 12
        elseif  operateCard.playType == Constants.PlayType.OPERATE_GANG_A_CARD then
            for i = 1, 3 do
                local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY)
                nowX = nowX + cardInfo:getContentSize().width * cardInfo:getScale()
            end

            local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY + GANG_SPACE * mainScale, 10);
            cardInfo:setPositionX(cardInfo:getPositionX() - 2 * cardInfo:getContentSize().width * cardInfo:getScale())
            nowX = nowX + 12
        elseif operateCard.playType == Constants.PlayType.OPERATE_BU_GANG_A_CARD then
            for i = 1, 3 do
                local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY)
                nowX = nowX + cardInfo:getContentSize().width * cardInfo:getScale()
            end

            local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY + GANG_SPACE * mainScale, 10, CardDefines.CardState.GangPai2)
            cardInfo:setPositionX(cardInfo:getPositionX() - 2 * cardInfo:getContentSize().width * cardInfo:getScale())
            nowX = nowX + 12;
        elseif operateCard.playType == Constants.PlayType.OPERATE_PENG_A_CARD then
            for i=1, 3 do
                local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY)
                nowX = nowX + cardInfo:getContentSize().width * cardInfo:getScale()
            end

            nowX = nowX + 12
        elseif operateCard.playType == Constants.PlayType.OPERATE_CHI_A_CARD then
            for _, cardValue in ipairs(operateCard.cards) do
                local cardInfo = self:_addOneCard(root, cardValue, nowX, nowY)
                nowX = nowX + cardInfo:getContentSize().width * cardInfo:getScale()
            end

            nowX = nowX + 12
        end
    end

    -- 对手牌做一次排序
    table.sort(playerData.handCards, function(a, b)
        local aIsGui = self._guiSet[a] and 1 or 0
		local bIsGui = self._guiSet[b] and 1 or 0
		if aIsGui == 1 or bIsGui == 1 then
			return bIsGui < aIsGui
		end
        return a < b
    end)

    for _, cardValue in ipairs(playerData.handCards) do
        local cornerTypes = {}
		if self._guiSet[cardValue] then
			table.insert(cornerTypes, CardDefines.CornerType.GuiPai)
		end
        local cardInfo = self:_addOneCard(root, cardValue, nowX, nowY, nil, nil, nil, cornerTypes)
        nowX = nowX + cardInfo:getContentSize().width * cardInfo:getScale()
    end

    nowX = nowX + 12

    -- 如果胡牌大于1显示最后一张
    if #huPai > 0 then
        local cardValue = huPai[#huPai]
        local cornerTypes = {}
		if self._guiSet[cardValue] then
			table.insert(cornerTypes, CardDefines.CornerType.GuiPai)
		end
        self:_addOneCard(root, cardValue, nowX, nowY, nil, nil, nil, cornerTypes)
    end
end

-- 创建牌
function UICardsInfo_new:_addOneCard(box, cardValue, x, y, zOrder, playtype, scale, cornerTypes)
    if type(cardValue) ~= "number" then
        return
    end

    local cardInfo = CardFactory:getInstance():CreateCard({ chair = CardDefines.Chair.Down, state = playtype or CardDefines.CardState.Chupai, cardValue = cardValue, cornerTypes = cornerTypes});
    table.insert(self._showCards,cardInfo);
    zOrder = zOrder or 0
    scale = scale or 1.5
    box:addChild(cardInfo, zOrder)
    cardInfo:setPositionX(x);
    cardInfo:setPositionY(y - 13);
    cardInfo:setScale(scale)

    return cardInfo;
end

function UICardsInfo_new:onHide()
    for k,v in pairs(self._showCards) do
        CardFactory:getInstance():releaseCard(v);
    end
    -- 清空数据
    self._playerInfos = {}
    self._playerDatas = {}
    self._showCards = {}
    self._huType = {}
    self._playerListView:removeAllChildren()

    -- 清空倒计时
    if self._timeSchedule ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
    end 
end

function UICardsInfo_new:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return UICardsInfo_new