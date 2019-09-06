local csbPath = "ui/csb/UIHistoryDetail.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants")
local Constants_Paodekuai = require("app.gameMode.paodekuai.core.Constants_Paodekuai")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local bit = require("bit")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

-- 观看类型 和HistoryRecordService一致
local HISTORY_WATCH_TYPE = {
    SELF = 1,
    MANAGER = 2,
    SHARE = 3
}

local UIHistoryDetailBar = class("UIHistoryDetailBar")

local UIPlayerInfo = class("UIPlayerInfo")

function UIPlayerInfo:ctor()
    self.scoreName = nil
    self.score = nil
end

function UIHistoryDetailBar:ctor(root)
    self._uiPlayerInfos = {}
    self._sequenceText = nil
    self._createTimeText = nil
    self._root = root
    self:init()
end

function UIHistoryDetailBar:init()
    local str = nil
    for i = 1, 4 do
        local layout = self._root:getChildByName("Panel_player" .. i .. "_History")
        layout:setTouchEnabled(false)
        local info = UIPlayerInfo.new()
        info.scoreName = layout:getChildByName("Text_name_player" .. i .. "_History")
        info.score = layout:getChildByName("Text_ID_player" .. i .. "_History")
        info.distroy = layout:getChildByName("Image_jiesan_" .. i)
        info.distroy:setVisible(false)
        self._uiPlayerInfos[#self._uiPlayerInfos + 1] = info
    end
    self._textTest = self._root:getChildByName("Text_Test")
    self._sequenceText = self._root:getChildByName("BitmapFontLabel_No_History")
    self._createTimeText = self._root:getChildByName("Text_data_History")
end

function UIHistoryDetailBar:show(barData)
    self._sequenceText:setString(barData.sequence)
    self._createTimeText:setString(os.date("%Y-%m-%d\n  %H:%M", barData.destroyTime / 1000))
    for i = 1, #barData.playerData do
        self._uiPlayerInfos[i].scoreName:setVisible(true)
        self._uiPlayerInfos[i].scoreName:setString(barData.playerData[i].scoreName)
        self._uiPlayerInfos[i].score:setVisible(true)
        UtilsFunctions.setScoreWithColor(self._uiPlayerInfos[i].score ,barData.playerData[i].score)
        if barData.scoreRatio ~= 0 then
            UtilsFunctions.setScoreWithColor(self._textTest , barData.playerData[i].score * barData.scoreRatio)
            local str = self._uiPlayerInfos[i].score:getString()
            self._uiPlayerInfos[i].score:setString(string.format("(%s)%s", self._textTest:getString(), str))
        end
    end

    if barData.distroyIdx then
        self._uiPlayerInfos[barData.distroyIdx].distroy:setVisible(true)
        for i, info in ipairs(self._uiPlayerInfos) do
            info.score:setVisible(false)
            info.scoreName:setVisible(false)
        end
    end


    for i = #barData.playerData + 1, 4 do
        self._uiPlayerInfos[i].scoreName:setVisible(false)
        self._uiPlayerInfos[i].score:setVisible(false)
    end
end

local UIHistoryDetail = class("UIHistoryDetail", super, function() return kod.LoadCSBNode(csbPath) end)

function UIHistoryDetail:ctor()
    self._btnBack = nil -- 返回战绩房间列表
    self._baseBar = nil -- 用于clone
    self._roomData = nil
    self._tilePlayerInfos = {}
    self._baseBarStartPos = {}
    self._roomIdText = nil
    -- self._shareText = nil
end

function UIHistoryDetail:init()
    self._btnBack = seekNodeByName(self, "Button_back_History", "ccui.Button")
    self._baseBar = seekNodeByName(self, "Panel_line1_History", "ccui.Layout")
    self._scrollView = seekNodeByName(self, "ScrollView_details_History", "ccui.ScrollView")
    self._roomIdText = seekNodeByName(self, "Text_room_History", "ccui.TextBMFont")
    self._btnRecord = seekNodeByName(self, "Button_record", "ccui.Button")

    self._btnRecord:setVisible(false)
    -- 不显示滚动条
    self._scrollView:setScrollBarEnabled(false)

    self._baseBarStartPos.x = self._baseBar:getPositionX()
    self._baseBarStartPos.y = self._baseBar:getPositionY()

    self._baseBar:retain()
    self._baseBar:removeFromParent(false)
    self._barHeight = self._baseBar:getContentSize().height
    -- self._shareText = seekNodeByName(self, "Text_3_History", "ccui.Text")
    for i = 1, 4 do
        local tileInfo = {}
        tileInfo.name = seekNodeByName(self, "Text_" .. (3 + i) .. "_History", "ccui.Text")
        tileInfo.clubName = seekNodeByName(self, "Text_" .. (7 + i) .. "_History", "ccui.Text")

        self._tilePlayerInfos[#self._tilePlayerInfos + 1] = tileInfo
    end

    self:_bindCallback()
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIHistoryDetail:isFullScreen()
    return true;
end

-- 更新tile显示
--@param tileInfo: tile信息列表，包含{name， id}
function UIHistoryDetail:_updateTitle(tileInfo)

end

-- 增加新的战绩记录显示
--@param detailData: 战绩详情，{ sequence, createTime, playerDetail = {{ state, score }...} }
function UIHistoryDetail:_addNewDetail(detailData)

end

function UIHistoryDetail:dispose()
    self._baseBar:release()
    self._baseBar = nil
end

function UIHistoryDetail:_bindCallback()
    bindEventCallBack(self._btnBack, handler(self, self._onBackButton), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRecord, handler(self, self._onRecordClick), ccui.TouchEventType.ended)
end

-- 解散房间原因详情
function UIHistoryDetail:_onRecordClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Dissolution_Reason)
    local clubHistoryService = game.service.club.ClubService.getInstance():getClubHistoryService()
    clubHistoryService:sendCRQueryRoomDestroyInfoREQ(self._roomData.roomId, self._roomData.createTime)
end

function UIHistoryDetail:_onBackButton()
    UIManager:getInstance():destroy("UIHistoryDetail")
end

function UIHistoryDetail:_onShareButton(round, createTime, toShareRoleId, clubId)
    -- local url = game.service.MagicWindowService.getInstance():generateMagicWindowLink(
    -- game.service.MAGIC_WINDOW_URL_TYPE_ENUM.QUREY_RECORD,    
    -- {
    --     roleId = tostring(toShareRoleId),
    --     roomId = tostring(self._roomData.roomId),
    --     -- 服务器是从0开始的
    --     round = tostring(round - 1),
    --     createTime = tostring(createTime),
    --     -- 亲友圈Id，为保持一致，默认为0
    --     clubId = clubId or 0
    -- }
    -- )

    -- local msg = string.format("点击此链接查看房间[%s]中第%d局战绩", tostring(self._roomData.roomId), tonumber(round))
    -- game.service.WeChatService.getInstance():sendLinkURL(
    -- url,
    -- "",
    -- config.GlobalConfig.getShareInfo()[1],
    -- msg,
    -- config.GlobalConfig.getDefaultIcon(),
    -- game.service.WeChatService.WXScene.WXSceneSession
    -- )

    -- --牌局回放点击量
    -- game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_History_Share)
end



function UIHistoryDetail:_onShowDetail(idx)
    -- UIManager:getInstance():show("UICardsInfo", self._roomData.roundReportRecords[idx].playerDetailRecords, self._roomData.playerRecords)
    local roundReportData = {}
    roundReportData.matchResults = {}
    roundReportData.lastCards = self._roomData.roundReportRecords[idx].lastCards
    table.foreach(self._roomData.roundReportRecords[idx].playerDetailRecords, function(key, val) table.insert(roundReportData.matchResults, val) end)

    -- 黄庄标识
    roundReportData.isHuang = self._roomData.roundReportRecords[idx].isHuang
    roundReportData.spceialsCards = self._roomData.roundReportRecords[idx].spceialsCards

    local playerRecods = self._roomData.playerRecords
    local rounds = self:_getRoundDetailStruct(self._roomData, idx)

    for i = 1, #rounds do
        local playerData = playerRecods[i]
        rounds[i].playerData.chairType = playerData.seat
        rounds[i].playerData.seat = playerData.seat
        rounds[i].playerData.roleId = playerData.roleId
        rounds[i].playerData.position = playerData.position
        rounds[i].playerData.isBanker = bit.band(self._roomData.roundReportRecords[idx].playerDetailRecords[i].status, Constants.PlayerStatus.ZHUANGJIA) ~= 0
        rounds[i].playerData.faceUrl = playerData.iconUrl
        rounds[i].playerData.name = playerData.roleName
    end

    -- 历史战绩玩法判断
    local roomSettingInfo = RoomSettingInfo.new(self._roomData.gameplays, self._roomData.roundType)
    local gameType = roomSettingInfo:getENArray()[1]

    UIManager:getInstance():show("UIRoundReportPage2", rounds, roundReportData, "historyDetail", gameType)

    --统计
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_History_Detail);
end

--FYD 点击请求 回放码
function UIHistoryDetail:_onShareCode(roomId, createTime, roundIndex,name)
    local clubId = self._roomData.clubId
    if clubId then
        local managerId = game.service.club.ClubService.getInstance():getClubManagerId(clubId)
        local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
        if roleId ~= managerId then
            clubId = nil
        end
    end
    game.service.HistoryRecordService.getInstance():queryShareBattleCode(roomId, createTime, roundIndex,name,clubId)
end

function UIHistoryDetail:_onPlaybackButton(sender)
    local idx = sender:getTag()
    game.service.HistoryRecordService.getInstance():queryHistoryPlayback(
    game.service.LocalPlayerService.getInstance():getRecordServerId(),
    self._roomData.createTime,
    self._roomData.roomId,
    -- index 需要-1
    idx - 1,
    self._roomData
    )

    --牌局回放点击量
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_History_Playback)
end

function UIHistoryDetail:onShow(...)
    local args = { ... }

    self._roomData = args[1]
    local type = args[2] or 0 -- 观看的类型

    local roundDatas = self._roomData.roundReportRecords
    local playerDatas = self._roomData.playerRecords

    self._btnRecord:setVisible(self._roomData.isAbnormalRoom)

    local selfPos = 0

    -- 设置标题栏
    for i = 1, #playerDatas do
        local playerInfo = string.format("%s(%s)", kod.util.String.getMaxLenString(playerDatas[i].roleName, 8), playerDatas[i].roleId)
        self._tilePlayerInfos[i].name:setString(playerInfo)
        if playerDatas[i].clubId ~= 0 and playerDatas[i].clubName ~= "" then
            local clubInfo = string.format("%s(%s)", kod.util.String.getMaxLenString(playerDatas[i].clubName, 8), playerDatas[i].clubId)
            self._tilePlayerInfos[i].clubName:setString(clubInfo)
            self._tilePlayerInfos[i].clubName:setVisible(true)
        else
            self._tilePlayerInfos[i].clubName:setVisible(false)
        end

        -- 如果是自己看，找到自己的位置
        -- 如果是分享的人看，找到其的位置
        if type == HISTORY_WATCH_TYPE.SELF then
            if playerDatas[i].roleId == game.service.LocalPlayerService.getInstance():getRoleId() then
                selfPos = i
            end
        elseif type == HISTORY_WATCH_TYPE.SHARE then
            if playerDatas[i].roleId == self._roomData.requestRoleId then
                selfPos = i
            end
        end
    end

    for i = #playerDatas + 1, 4 do
        self._tilePlayerInfos[i].name:setVisible(false)
        self._tilePlayerInfos[i].clubName:setVisible(false)
    end

    if self._scrollView:getContentSize().height < #roundDatas * self._barHeight then
        self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, #roundDatas * self._barHeight))
        self._baseBarStartPos.y = #roundDatas * self._barHeight - self._barHeight * 0.5
    else
        self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, self._scrollView:getContentSize().height))
        self._baseBarStartPos.y = self._scrollView:getContentSize().height - self._barHeight * 0.5
    end

    -- 每局信息
    local count = 0
    for i = 1, #roundDatas do
		--FYD 解散当局需要特殊处理一下
        local distroy = roundDatas[i].destroyerId > 0
        if type == HISTORY_WATCH_TYPE.MANAGER or #roundDatas[i].playerDetailRecords >= selfPos or distroy then
            local newBarRoot = self._baseBar:clone()
            count = count + 1
            -- 当前要显示的回合数，如果是观看其它人战绩的时候，并不是从1开始的，并且只有一局的信息
            local round = self._roomData.currectRound and self._roomData.currectRound + 1 or i

            local playbackButton = seekNodeByName(newBarRoot, "Button_2_0", "ccui.Button")
            playbackButton:setTag(round)
            local outOfDateRecord = seekNodeByName(newBarRoot, "Image_2_0_No", "ccui.ImageView")
            outOfDateRecord:setVisible(not self._roomData.playbackExist)
            playbackButton:setVisible(self._roomData.playbackExist)
            seekNodeByName(newBarRoot, "Image_2_No", "ccui.ImageView"):setVisible(false)
            bindEventCallBack(playbackButton, handler(self, self._onPlaybackButton), ccui.TouchEventType.ended)

            self._scrollView:addChild(newBarRoot)
            newBarRoot:setPositionY(self._baseBarStartPos.y - (count - 1) * self._barHeight)

            local barData = {}
            barData.sequence = round
            barData.createTime = roundDatas[i].startTime
            barData.destroyTime = roundDatas[i].endTime
            barData.playerData = {}
            barData.isHuang = roundDatas[i].isHuang
            barData.scoreRatio = self._roomData.scoreRatio or 0
            
            for pid = 1, #playerDatas do
                local roleId = playerDatas[pid].roleId
                if roleId == roundDatas[i].destroyerId then
                    barData.distroyIdx = pid
                end
            end

            -- 当前局的房主
            local hostPlayer = nil
            -- 自己是否参与本局
            local isSelfInRound = false
            for j = 1, #roundDatas[i].playerDetailRecords do
                local record = roundDatas[i].playerDetailRecords[j]
                local playerDetail = {}
                playerDetail.scoreName = self:_getHuType(record.events)
                playerDetail.score = record.pointInGame
                table.insert(barData.playerData, playerDetail)
                -- 找到本局的房主，如果分享战绩的时候，是亲友圈群主分享的话，那么要以房主为视角
                if bit.band(record.status, Constants.PlayerStatus.ZHUANGJIA) ~= 0 then
                    hostPlayer = record.roleId
                end
                -- 判断本局是不是本人参与了，如果本人没有参与，那么可能就是群主在看，也可能是分享出去的别人在看，如果是群主在看，那么也会分享战绩的
                if not isSelfInRound and record.roleId == game.service.LocalPlayerService.getInstance():getRoleId() then
                    isSelfInRound = true
                end
            end
            -- 当前观战主视角
            -- local toShareRoleId = isSelfInRound and game.service.LocalPlayerService.getInstance():getRoleId() or hostPlayer
            -- 分享战绩的处理
            -- local shareButton = seekNodeByName(newBarRoot, "Button_Detail_Data", "ccui.Button")
            -- shareButton:setTag(round)
            -- -- 有的地区不能分享战绩
            -- local showShare = false
            -- if MultiArea.getShareRecord(game.service.LocalPlayerService:getInstance():getArea()) == true then
            --     -- 如果当前战绩是分享来的
            --     showShare = self._roomData.currectRound == nil   
            -- end
            -- -- 分享按钮隐藏
            -- shareButton:setVisible(false)
            -- -- 标题的“分享”二字
            -- self._shareText:setVisible(false)
            --    -- 提审战绩分享隐藏
            -- if GameMain.getInstance():isReviewVersion() then
            --      -- 分享按钮隐藏
            --     shareButton:setVisible(false)
            --     -- 标题的“分享”二字
            --     self._shareText:setVisible(false)
            -- end
            -- bindEventCallBack(shareButton, function()
            --     self:_onShareButton(round, self._roomData.createTime, toShareRoleId, self._roomData.clubId)
            -- end, ccui.TouchEventType.ended)
            local detailBar = UIHistoryDetailBar.new(newBarRoot)
            detailBar:show(barData)

            if not barData.distroyIdx then
                --FYD 将原来的详情界面的功能放到整个CELL上
                bindEventCallBack(newBarRoot,function() 
                    self:_onShowDetail(round)
                end, ccui.TouchEventType.ended)
            end
            --FYD UI 上有兩個分享按鈕，隱藏一個
            seekNodeByName(newBarRoot, "Button_2", "ccui.Button"):setVisible(false)
            local btnShare = seekNodeByName(newBarRoot, "Button_2_1", "ccui.Button")
            if not self._roomData.playbackExist then
                seekNodeByName(newBarRoot, "Image_2_No", "ccui.ImageView"):setVisible(true)
            else
                seekNodeByName(newBarRoot, "Image_2_No", "ccui.ImageView"):setVisible(false)
                bindEventCallBack(btnShare, function()
                    local roomSettingInfo = RoomSettingInfo.new(self._roomData.gameplays, self._roomData.roundType)
                    local gameType = roomSettingInfo:getENArray()[1]
                    local areaId = game.service.LocalPlayerService:getInstance():getArea()
                    local config = MultiArea.getGameTypeMap(areaId)
                    local name = config[gameType].name
                    self:_onShareCode(self._roomData.roomId,self._roomData.createTime, round,name)
                end, ccui.TouchEventType.ended)
            end

            
            

            
        end
    end

    self._roomIdText:setString(tostring("房间号：" .. self._roomData.roomId))
end

function UIHistoryDetail:needBlackMask()
    return true;
end

function UIHistoryDetail:closeWhenClickMask()
    return false
end

-- 根据每个玩家本局的event来确定如何显示玩家的概况,多个胡的情况下只显示胡牌和未胡牌 */
function UIHistoryDetail:_getHuType(events)
    local huEvents = {}
    for i = 1, #events do
        local _type = events[i].score.type
        if _type == Constants.PlayType.HU_ZI_MO or
        _type == Constants.PlayType.HU_DIAN_PAO or
        _type == Constants_Paodekuai.PlayType.HU_POKER_WIN or
        _type == Constants_Paodekuai.PlayType.HU_POKER_GUAN_MEN then
            table.insert(huEvents, events[i])
        end
    end

    if #huEvents == 0 then
        return "未胡牌"
    elseif #huEvents == 1 then
        return Constants.SpecialEvents.getName(huEvents[1].score.type, huEvents[1].addOperation)
    else
        for i = 1, #huEvents do
            if huEvents[i].addOperation == true then
                return "胡牌"
            end
        end

        return "未胡牌"
    end
end

function UIHistoryDetail:_getRoundDetailStruct(roomData, roundIndex)
    local Player = require("app.gameMode.base.core.Player")

    local ret = {}
    local roundReports = roomData.roundReportRecords[roundIndex]
    local function getPlayerInfo(roleId)
        for _, item in ipairs(roomData.playerRecords) do
            if roleId == item.roleId then
                return Player.new(item)
            end
        end
    end
    -- 每个人的结算信息
    for idx, oneManRoundReport in ipairs(roundReports.playerDetailRecords) do
        local convertedRoundReport = self:_getCardListWithoutPlayerInfo(oneManRoundReport)
        local playerInfo = getPlayerInfo(oneManRoundReport.roleId)
        convertedRoundReport.playerData = playerInfo
        table.insert(ret, convertedRoundReport)
    end
    return ret
end

function UIHistoryDetail:_getCardListWithoutPlayerInfo(result)
    local roundReportInfo = {
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

    for i = 1, #result.handCards do
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
    for _, event in ipairs(result.events) do -- ResultEventPROTO
        local score = event.score
        local op = event.addOperation
        if score.type == PlayType.HU_ZI_MO or score.type == PlayType.HU_DIAN_PAO then
            if score.type == PlayType.HU_DIAN_PAO or (score.type == PlayType.HU_ZI_MO and op) then
                hu_status = { playType = score.type, op = op }
            end
        end
        -- 闷胡算是叫牌的一种
        if score.type == PlayType.HU_JIAO_PAI or score.type == PlayType.HU_WEI_JIAO_PAI or score.type == PlayType.HU_MEN_HU then
            if op then
                hu_status = { playType = score.type, op = op }
            end
        end
    end
    roundReportInfo.huStatus = hu_status

    return roundReportInfo
end

return UIHistoryDetail