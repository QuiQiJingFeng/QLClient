local csbPath = "ui/csb/Club/UIClubPersonalRecord.csb"
local super   = require("app.game.ui.UIBase")
local UIClubPersonalRecord = class("UIClubPersonalRecord", super, function() return kod.LoadCSBNode(csbPath) end)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

--[[
    查询个人战绩
]]

local UIElemRoomItem = class("UIElemRoomItem")

function UIElemRoomItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemRoomItem)
    self:_initialize()
    return self
end

function UIElemRoomItem:_initialize()
    self._time = seekNodeByName(self, "Text_name_list_b_ZJ_club", "ccui.Text")              -- 战绩日期
    self._roomid = seekNodeByName(self, "Text_id_list_b_ZJ_club", "ccui.Text")              -- 房间号
    self._card = seekNodeByName(self, "Text_id_list_b_ZJ_club_0", "ccui.Text")              -- 房卡
    self._bosses = {}                                                                       -- 玩家名字以及id
    self._bosses[1]  = seekNodeByName(self, "Text_1_play1_list_b_ZJ_club", "ccui.Text")
    self._bosses[2]  = seekNodeByName(self, "Text_1_play2_list_b_ZJ_club", "ccui.Text")
    self._bosses[3]  = seekNodeByName(self, "Text_1_play3_list_b_ZJ_club", "ccui.Text")
    self._bosses[4]  = seekNodeByName(self, "Text_1_play4_list_b_ZJ_club", "ccui.Text")
    self._scores = {}                                                                       -- 分数
    self._scores[1]  = seekNodeByName(self, "Text_2_play1_list_b_ZJ_club", "ccui.Text")
    self._scores[2]  = seekNodeByName(self, "Text_2_play2_list_b_ZJ_club", "ccui.Text")
    self._scores[3]  = seekNodeByName(self, "Text_2_play3_list_b_ZJ_club", "ccui.Text")
    self._scores[4]  = seekNodeByName(self, "Text_2_play4_list_b_ZJ_club", "ccui.Text")
    self._bigboss = {}                                                                      -- 赢家标识
    self._bigboss[1]  = seekNodeByName(self, "Image_icon_f_list_clubZJ_0", "ccui.ImageView")
    self._bigboss[2]  = seekNodeByName(self, "Image_9_0", "ccui.ImageView")
    self._bigboss[3]  = seekNodeByName(self, "Image_10", "ccui.ImageView")
    self._bigboss[4]  = seekNodeByName(self, "Image_icon_y_list_clubZJ_0", "ccui.ImageView")

    -- 点击事件，应该是整个Item产生的
    self:setTouchEnabled(true)
    bindEventCallBack(self, handler(self, self._onClickInfoBtn), ccui.TouchEventType.ended)
end

function UIElemRoomItem:getData()
    return self._data
end

-- 整体设置数据
function UIElemRoomItem:setData(val)
    self._data = val
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local roomCostList = MultiArea.getRoomCost(areaId)

    local his = {
        -- 战绩时间为结束时间
        time = val.destroyTime / 1000,
        --time = val.createTime / 1000,
        roomId = tostring(val.roomId),
        -- 现在没有钻石消耗，但是有个房间类型，要不要转换，以后再说
        cardUsed = roomCostList[val.roundType],
        bigBoss = 1,
        hostBoss = 2,
        bosses = {},
        scores = {}
    }

    table.sort(val.playerRecords, function (a, b)
        return a.position < b.position
    end)

    local j = 1
    local max = 0
    local indexs = {}
    for j,playerHistory in ipairs(val.playerRecords) do
        local nickname = game.service.club.ClubService.getInstance():getInterceptString(playerHistory.nickname, 8)
        his.bosses[j] = nickname.."(".. playerHistory.roleId ..")"
        his.scores[j] = playerHistory.totalPoint
        if playerHistory.totalPoint > max then
            max = playerHistory.totalPoint
            -- 最高分刷新，清除原有的
            indexs = {j}
        elseif playerHistory.totalPoint == max then
            -- 可以同时存在多个最高分
            table.insert(indexs, j)
        end
    end
    his.bigBoss = indexs
    self._time:setString(os.date("%Y-%m-%d\n%H:%M", his.time))
    self._roomid:setString(his.roomId)
    self._card:setString(his.cardUsed)
    -- bigboss:setString(history.bigBoss)

    for ii=1,#his.bosses do
        self._bosses[ii]:setString(his.bosses[ii])
        self._bosses[ii]:setVisible(true)
        self._scores[ii]:setString(his.scores[ii])
        self._scores[ii]:setVisible(true)
        UtilsFunctions.setScoreWithColor(self._scores[ii], his.scores[ii])
        if table.indexof(his.bigBoss, ii) ~= false then
            self._bigboss[ii]:setVisible(true)
        else
            self._bigboss[ii]:setVisible(false)
        end
    end
    for ii=#his.bosses+1,4 do
        self._bosses[ii]:setVisible(false)
        self._scores[ii]:setVisible(false)
        self._bigboss[ii]:setVisible(false)
    end
end

-- 点击显示房间战绩详情
function UIElemRoomItem:_onClickInfoBtn()
    local service = game.service.LocalPlayerService:getInstance():getHistoryRecordService()
    service:queryHistoryRoom(self._data.createTime, self._data.roomId, 0, false, self._data, self._data.clubId)
end

-------------------------------------------------------

local MAX_HISTORY_COUNT = 20

function UIClubPersonalRecord:ctor()
    -- 当前显示的页数
    self._currPage = 1
    -- 原始数据，这里要不要保存？看设计吧
    self._srcDatas  = {}
    self._filter = nil
   
    self._panelManager = seekNodeByName(self, "Panel_b_ZJ_club", "ccui.Layout")
    self._reusedListHistorys = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_b_ZJ_club", "ccui.ListView"), UIElemRoomItem)
    self._reusedListHistorys:setScrollBarEnabled(false)

    self._btnPrev = seekNodeByName(self, "Button_up_clubZJ", "ccui.Button")
    self._btnNext = seekNodeByName(self, "Button_down_clubZJ", "ccui.Button")
    self._panelInput = seekNodeByName(self, "Panel_cx_ZJ", "ccui.Layout")
    self._btnClose = seekNodeByName(self, "Button_x_CLubZJ2", "ccui.Button")
    self._textPrompt = seekNodeByName(self, "Text_tiao", "ccui.Text")

    bindEventCallBack(self._btnPrev, handler(self, self._onBtnPrev), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNext, handler(self, self._onBtnNext), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

function UIClubPersonalRecord:onShow(...)
    local args = {...}
    self._clubId = args[1]
    self._queryRoleId = args[2]
    local clubHistoryService = game.service.club.ClubService.getInstance():getClubHistoryService()

    self._queryTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()

    self:_updateListView()

    -- 请求亲友圈战绩
    -- 这里先请求前50条，后面再去完整的做
    clubHistoryService:sendClubHistoryREQ(self._clubId, 0 , MAX_HISTORY_COUNT, self._queryRoleId, 0, self._queryTime)

    -- 监听事件    
    clubHistoryService:addEventListener("EVENT_CLUB_HISTORY_DATA_RETRIVED", handler(self, self._onHistoryDataRetrived), self)
end

function UIClubPersonalRecord:_updateListView()
    self._reusedListHistorys:deleteAllItems()
 
    local histories = game.service.club.ClubService.getInstance():getClub(self._clubId).histories
    -- 这里的数据需要去service里面去取！！！
    -- TODO: 这里的房卡消耗数跟房主当前是没有值的
    -- 现在这里就改为filter过滤吧
    for key,val in ipairs(histories) do
        if self._filter ~= nil and val.roomId ~= self._filter then
        else
            self._reusedListHistorys:pushBackItem(val)
        end
    end

    -- 默认上下页都显示
    self._btnPrev:setVisible(true)
    self._btnNext:setVisible(true)

    -- 这一页小于二十条时不显示下一页
    if #self._reusedListHistorys:getItemDatas() < MAX_HISTORY_COUNT then
        self._btnNext:setVisible(false)
    end

    -- 只有一页时不显示上一页
    if self._currPage == 1 then
        self._btnPrev:setVisible(false)
    end

    -- 没有战绩显示提示条
    self._textPrompt:getParent():setVisible(not (#self._reusedListHistorys:getItemDatas() > 0))
end

function UIClubPersonalRecord:_onBtnPrev()
    if self._currPage > 1 then
        self._currPage = self._currPage - 1
        game.service.club.ClubService.getInstance():getClubHistoryService():sendClubHistoryREQ(self._clubId, (self._currPage-1)*MAX_HISTORY_COUNT , MAX_HISTORY_COUNT, self._queryRoleId,0, self._queryTime)
    end
end

function UIClubPersonalRecord:_onBtnNext()
    if #self._reusedListHistorys:getItemDatas() >= MAX_HISTORY_COUNT then
        self._currPage = self._currPage + 1
    end
    game.service.club.ClubService.getInstance():getClubHistoryService():sendClubHistoryREQ(self._clubId, (self._currPage-1)*MAX_HISTORY_COUNT , MAX_HISTORY_COUNT, self._queryRoleId,0, self._queryTime)
end

-- 查询战绩结果
function UIClubPersonalRecord:_onHistoryDataRetrived(event)
    -- 更新List中数据
    -- 原始数据保存
    if event.clubId ~= self._clubId then
        return
    end
    self:_updateListView()
end

function UIClubPersonalRecord:needBlackMask()
	return true
end

function UIClubPersonalRecord:closeWhenClickMask()
	return false
end

function UIClubPersonalRecord:_onBtnClose()
    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubHistoryService():removeEventListenersByTag(self)
    UIManager:getInstance():show("UIClubMemberPage", self._clubId)
    UIManager:getInstance():destroy("UIClubPersonalRecord")
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubPersonalRecord:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

return UIClubPersonalRecord