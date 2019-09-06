local csbPath = "ui/csb/BigLeague/UIBigLeagueHistory.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueHistory:UIBase
local UIBigLeagueHistory = super.buildUIClass("UIBigLeagueHistory", csbPath)
local UtilsFunctions = require("app.game.util.UtilsFunctions")

local ListFactory = require("app.game.util.ReusedListViewFactory")
-- 一页最多显示多少条战绩
local MAX_HISTORY_COUNT = 20

--[[
    战绩界面
]]

function UIBigLeagueHistory:ctor()

end

function UIBigLeagueHistory:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    self._btnPlayback = seekNodeByName(self, "Button_Playback", "ccui.Button") -- 回放
    self._btnPreviousPage = seekNodeByName(self, "Button_PreviousPage", "ccui.Button") -- 上一页
    self._btnNextPage = seekNodeByName(self, "Button_NextPage", "ccui.Button") -- 下一页
    self._imgTips = seekNodeByName(self, "Image_Tips", "ccui.ImageView") -- 提示没有数据
    self._SearchByRoomID = seekNodeByName(self, "Button_roomid_search", "ccui.Button") --房间号搜索

    self._panelFilter = seekNodeByName(self, "Panel_Filter", "ccui.Layout") -- 筛选Node
    self._btnFilter = seekNodeByName(self, "Button_Filter", "ccui.Button")
    self._textFilter = seekNodeByName(self, "Text_Filter", "ccui.Text")

    self._reusedListRecordInfo = ListFactory.get(
            seekNodeByName(self, "ListView_RecordList", "ccui.ListView"),
            handler(self, self._onListViewInit),
            handler(self, self._onListViewSetData)
    )
    self._reusedListRecordInfo:setScrollBarEnabled(false)


    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPlayback, handler(self, self._onClickPlayback), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPreviousPage, handler(self, self._onClickPreviousPage), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNextPage, handler(self, self._onClickNextPage), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFilter, handler(self, self._onClickFilter), ccui.TouchEventType.ended)
    bindEventCallBack(self._SearchByRoomID, handler(self, self._onClickSearch), ccui.TouchEventType.ended)
end

function UIBigLeagueHistory:_onClickClose()
    if self._bSearchByRoomIdShow and self._roomId <= 0 and self._queryRoleId <= 0 then  --如果是房间号查询，且不是从个人战绩处或活跃值详情处进来的，点击返回按钮，回到之前的战绩查询界面，否则直接关闭界面
        self:_sendCCLQueryLeagueRoomHistoryREQ()
        self._bSearchByRoomIdShow = false
        return 
    end
    self._bSearchByRoomIdShow = false
    self:hideSelf()
end

function UIBigLeagueHistory:_onClickPlayback()
    UIManager:getInstance():show("UIKeyboard", "输入回放码", 6, "请输入正确的回放码", "查询", function (replayCode)
        game.service.HistoryRecordService.getInstance():queryHistoryRoomByCode(replayCode)
    end)
end

function UIBigLeagueHistory:_onClickPreviousPage()
    if self._currPage > 1 then
        self._currPage = self._currPage - 1
    end
    self:_sendCCLQueryLeagueRoomHistoryREQ()
end

function UIBigLeagueHistory:_onClickNextPage()
    if #self._reusedListRecordInfo:getItemDatas() >= MAX_HISTORY_COUNT then
        self._currPage = self._currPage + 1
    end
    self:_sendCCLQueryLeagueRoomHistoryREQ()
end

function UIBigLeagueHistory:_onClickFilter()
    UIManager.getInstance():show("UIBigLeagueHistoryFilter", self._queryTime, self._minScore, true, function (queryTime, minScore, onlyAbnormalRoom)
        UIManager:getInstance():destroy("UIJoinRoom")
        self._bSearchByRoomIdShow = false
        self:_setFilter(queryTime, minScore , onlyAbnormalRoom)
        self:_sendCCLQueryLeagueRoomHistoryREQ()
    end)
end

function UIBigLeagueHistory:_onClickSearch()
    local pFunc = function(roomID)
        self._currPage = 1
        self:_sendCCLQueryLeagueRoomHistoryREQ(roomID, true)
    end
    UIManager:getInstance():show("UIJoinRoom",pFunc)
end

function UIBigLeagueHistory:_setFilter(queryTime, minScore, onlyAbnormalRoom)
    self._queryTime= queryTime
    self._minScore= minScore
    self._textFilter:setString(string.format("%s\n赢家分不低于:%s", os.date("%Y-%m-%d", queryTime), minScore))
    if self._onlyAbnormalRoom ~= onlyAbnormalRoom then
        self._onlyAbnormalRoom = onlyAbnormalRoom
    end
end

function UIBigLeagueHistory:onShow(queryRoleId, roomId, queryTime)
    self._queryRoleId = queryRoleId or 0
    self._roomId = roomId or 0
    self._queryTime = queryTime or game.service.TimeService:getInstance():getCurrentTime() -- 时间

    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._panelFilter:setVisible((self._bigLeagueService:getIsSuperLeague() or self._bigLeagueService:getLeagueData():isManager()) and self._queryRoleId == 0)
    self._SearchByRoomID:setVisible(self._bigLeagueService:getIsSuperLeague() or self._bigLeagueService:getLeagueData():isManager())

    self._currPage = 1 -- 当前显示的页数
    self._minScore = 0
    self._onlyAbnormalRoom = false
    self:_sendCCLQueryLeagueRoomHistoryREQ()
    self:_setFilter(self._queryTime, self._minScore, self._onlyAbnormalRoom)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_ROOMHISTORY", handler(self, self._RefreshHistory), self)
    self._bSearchByRoomIdShow = false 
end



function UIBigLeagueHistory:_sendCCLQueryLeagueRoomHistoryREQ(roomID, bSearchRoomID)
    roomID = tonumber(roomID) or self._roomId

    self._bigLeagueService:sendCCLQueryLeagueRoomHistoryREQ(
            self._bigLeagueService:getLeagueData():getLeagueId(),
            self._bigLeagueService:getLeagueData():getClubId(),
            (self._currPage-1) * MAX_HISTORY_COUNT,
            MAX_HISTORY_COUNT,
            self._queryTime,
            self._minScore,
            self._onlyAbnormalRoom,
            self._queryRoleId,
            roomID,
            bSearchRoomID
    )
end

function UIBigLeagueHistory:_RefreshHistory(event)
    if event.bSearchByRoomID and (not event.roomRecords or not next(event.roomRecords)) then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("房间不存在")
        return 
    elseif event.bSearchByRoomID then 
        self._bSearchByRoomIdShow = true 
    end
    UIManager:getInstance():destroy("UIJoinRoom")
    self:_upadtaListView()
end

function UIBigLeagueHistory:_upadtaListView()
    self._reusedListRecordInfo:deleteAllItems()
    for _, roomHistory in ipairs(self._bigLeagueService:getLeagueData():getRoomHistorys()) do
        self._reusedListRecordInfo:pushBackItem(roomHistory)
    end

    -- 默认上下页都显示
    self._btnPreviousPage:setVisible(true)
    self._btnNextPage:setVisible(true)

    -- 这一页小于二十条时不显示下一页
    if #self._reusedListRecordInfo:getItemDatas() < MAX_HISTORY_COUNT then
        self._btnNextPage:setVisible(false)
    end

    -- 只有一页时不显示上一页
    if self._currPage == 1 then
        self._btnPreviousPage:setVisible(false)
    end

    -- 没有战绩显示提示条
    self._imgTips:setVisible(not (#self._reusedListRecordInfo:getItemDatas() > 0))
end

-- 查找item
function UIBigLeagueHistory:_indexOfInvitation(roomId, createTime)
    for idx,item in ipairs(self._reusedListRecordInfo:getItemDatas()) do
        if item.roomId == roomId and item.createTime == createTime then
            return idx, item
        end
    end

    return false;
end

function UIBigLeagueHistory:_onListViewInit(listItem)
    listItem._checkBoxProcess = seekNodeByName(listItem, "CheckBox_Process", "ccui.CheckBox") -- 点赞
    listItem._btnDetails = seekNodeByName(listItem, "Button_Details", "ccui.Button") -- 房间详情
    listItem._ingStatus = seekNodeByName(listItem, "Image_Status", "ccui.ImageView") -- 解散的标识
    listItem._textTime = seekNodeByName(listItem, "Text_Time", "ccui.Text") -- 战绩日期
    listItem._textRoomId = seekNodeByName(listItem, "Text_RoomId", "ccui.Text") -- 房间号
    listItem._textCard = seekNodeByName(listItem, "Text_Card", "ccui.Text") -- 房卡
    listItem._textGameRule = seekNodeByName(listItem, "Text_GameRule", "ccui.Text") -- 房间玩法

    listItem._playerInfo = {} -- 玩家信息
    for i = 1, 4 do
        local item = seekNodeByName(listItem, "Panel_PlayerInfo_" .. i, "ccui.Layout")
        listItem._playerInfo[i] =
        {
            playerId = seekNodeByName(item, "Text_PlayreInfo", "ccui.Text"),
            score = seekNodeByName(item, "Text_PlayerScore", "ccui.Text"),
            bigBoss = seekNodeByName(item, "Image_Winner", "ccui.ImageView"),
            eventPoints = seekNodeByName(item, "Text_EventPoints", "ccui.Text")
        }
    end
end


function UIBigLeagueHistory:_onListViewSetData(listItem, val)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local roomCostList = MultiArea.getRoomCost(areaId)
    -- 战绩时间为结束时间 val.createTime / 1000
    listItem._textTime:setString(os.date("%Y-%m-%d\n%H:%M", val.destroyTime / 1000))
    listItem._textRoomId:setString(tostring(val.roomId))
    listItem._textCard:setString(roomCostList[val.roundType])
    listItem._textGameRule:setString(val.gameplayName)

    listItem._checkBoxProcess:setVisible(false)
    --listItem._checkBoxProcess:setSelected(val.isProcessed)
    
    -- 解散标识
    if val.destoryReason == 13 then 
        -- 分数不足
        listItem._ingStatus:loadTexture("art/club4/icon_fsbz.png")
        listItem._ingStatus:setVisible(true)
    elseif val.isAbnormalRoom then 
        -- 中途解散
        listItem._ingStatus:loadTexture("art/club4/icon_ztjs.png")
        listItem._ingStatus:setVisible(true)
    else 
        listItem._ingStatus:setVisible(false)
    end 
    
    table.sort(val.playerRecords, function (a, b)
        return a.position < b.position
    end)

    local maxScores = 0
    local indexs = {}
    for i, playerHistory in ipairs(val.playerRecords) do
        local name = game.service.club.ClubService.getInstance():getInterceptString(playerHistory.nickname, 8)
        listItem._playerInfo[i].playerId:setString(string.format("%s(%s)", name, playerHistory.roleId))
        UtilsFunctions.setScoreWithColor(listItem._playerInfo[i].score, playerHistory.totalPoint)
        UtilsFunctions.setScoreWithColor(listItem._playerInfo[i].eventPoints, playerHistory.totalPoint * val.scoreRatio)
        local str = listItem._playerInfo[i].eventPoints:getString()
        listItem._playerInfo[i].eventPoints:setString(string.format("(%s)", str))

        listItem._playerInfo[i].score:ignoreContentAdaptWithSize(true)
        -- 大赢家标识
        if playerHistory.totalPoint > maxScores then
            maxScores = playerHistory.totalPoint
            -- 最高分刷新，清除原有的
            indexs = {i}
        elseif playerHistory.totalPoint == maxScores then
            -- 可以同时存在多个最高分
            table.insert(indexs, i)
        end
    end

    -- 隐藏多余的玩家信息
    for i, item in ipairs(listItem._playerInfo) do
        item.playerId:setVisible(i <= #val.playerRecords)
        item.score:setVisible(i <= #val.playerRecords)
        item.eventPoints:setVisible(i <= #val.playerRecords)
        item.bigBoss:setVisible(table.indexof(indexs, i) ~= false)
    end


    bindEventCallBack(listItem._btnDetails, function()
        local service = game.service.LocalPlayerService:getInstance():getHistoryRecordService()
        service:queryHistoryRoom(val.createTime, val.roomId, 0, false, val, val.clubId, val.isAbnormalRoom)
    end, ccui.TouchEventType.ended)
end

function UIBigLeagueHistory:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

return UIBigLeagueHistory