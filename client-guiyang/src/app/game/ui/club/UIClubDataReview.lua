local csbPath = "ui/csb/Club/UIClubpjstj.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")


local UIClubDataReview = class("UIClubDataReview", super, function() return kod.LoadCSBNode(csbPath) end)
local CheckYearLimit = 2000;    -- 这个时间点以前的显示选择时间或者不显示 
--[[
    亲友圈管理界面
]]

function UIClubDataReview:ctor()
    self._clubId                    = nil   
    self._startSearchTime           = 0     -- 开始查询的时间戳 单位秒
    self._endSearchTime             = 0     -- 截止查询的时间戳
end

function UIClubDataReview:init()
    local root                      = seekNodeByName(self, "Panel_2_DZD_ClubGL",                "ccui.Layout")
    self._objNodes                  = bindNodeToTarget(root)

    self._textPlayersToday          = seekNodeByName(self, "Text_10",         "ccui.Text")    --今日玩家数
    self._textPlayersYestoday       = seekNodeByName(self, "Text_10_0",       "ccui.Text")    --昨日玩家数
    self._textCardsToday            = seekNodeByName(self, "Text_10_0_0",     "ccui.Text")    --今日局数
    self._textCardsYestoday         = seekNodeByName(self, "Text_10_0_0_0",   "ccui.Text")    --昨日局数


    self._textStartTime             = seekNodeByName(self, "Text_quarry_start_time",    "ccui.Text")    --开始时间
    self._textEndTime               = seekNodeByName(self, "Text_quarry_end_time",    "ccui.Text")    --截止时间
    self._btnChooseTime             = seekNodeByName(self, "Button_select_time",    "ccui.Button")    --选择时间
    self._btnClose                  = seekNodeByName(self, "Button_x_ClubSq",    "ccui.Button")    --关闭
    self:_registerCallBack()
end

-- 点击事件注册
function UIClubDataReview:_registerCallBack()
    bindEventCallBack(self._btnChooseTime, handler(self, self._onClickSelTime), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self,self._onClickQuit), ccui.TouchEventType.ended)
end

function UIClubDataReview:onShow(clubId)
    self._clubId  = clubId

    -- 监听消息
    local clubService =  game.service.club.ClubService.getInstance()
    local recordService = game.service.RecordService.getInstance();
    recordService:addEventListener("EVENT_CLUB_TODAY_BILL_CHANGE", handler(self, self._refreshBriefDataUI), self);
    recordService:addEventListener("EVENT_CLUB_SEARCH_DATA_CHANGE", function(event) self:_refreshSearchDataUI(event.searchData) end, self);
    
    -- 每次进入都请求一次昨天/今天扣卡数
    recordService:sendCCLCheckClubBillTodayREQ(clubId);


    -- 初次进入刷新上次的查询界面
    print("UIClubDataReview onShow~~~~~~~~~~~~~~~~~~~~~~~~",clubId)
    self:_refreshSearchDataUI(recordService:getSearchData(self._clubId));

    local todayPlayerNums,yestodayPlayerNums = clubService:getClubActivePlayerNum(self._clubId)
    self._textPlayersToday:setString("今日打牌玩家数:"..todayPlayerNums)
    self._textPlayersYestoday:setString("昨日打牌玩家数:"..yestodayPlayerNums)
end



function UIClubDataReview:onHide()
    -- 取消事件监听
    game.service.RecordService.getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
end


-- 刷新今天的扣卡
function UIClubDataReview:_refreshBriefDataUI(event)
    -- if event and event.clubId == self._clubId then
    --     self._objNodes.Text_yesterday_today_cost:setString("今日/昨日已结算牌局数:"..event.todayRoomNum.."/"..event.yesterdayRoomNum);
    -- end
    self._textCardsToday:setString(config.STRING.UICLUBDATAREVIEW_STRING_100 .. event.billData.todayRoomCost)
    self._textCardsYestoday:setString(config.STRING.UICLUBDATAREVIEW_STRING_101 .. event.billData.yesterdayRoomCost)
end

-- 刷新选择时间UI
function UIClubDataReview:_refreshSelTimeUI(searchData)
    self._startSearchTime = searchData.startTimeStamp;
    self._endSearchTime   = searchData.endTimeStamp;
    local formatStartT = kod.util.Time.time2Date(self._startSearchTime);
    local formatEndT   = kod.util.Time.time2Date(self._endSearchTime);
    local startTimeStr = "<"..self:_getFormatTime(formatStartT);
    local endTimeStr  = self:_getFormatTime(formatEndT)..">";
    -- self._objNodes.Text_quarry_start_time:setString(startTimeStr);
    -- self._objNodes.Text_quarry_end_time:setString(endTimeStr);
    self._textStartTime:setString(startTimeStr)
    self._textEndTime:setString(endTimeStr)
end

-- 刷新查询结果
function UIClubDataReview:_refreshSearchDataUI(searchData)
    -- 只接收本亲友圈数据
    dump(searchData,"searchData~~~~~~~~~~~~~~~~")
    if not searchData or searchData.clubId ~= self._clubId then
        return 
    end

    -- 显示选中时间
    self:_refreshSelTimeUI(searchData);

    -- 截止时间
    local formatEndT   = kod.util.Time.time2Date(self._endSearchTime);
    self._objNodes.Text_end_time:setString(self:_getPlayingTime(formatEndT));

    -- 房卡消耗
    if searchData.totalCostTickets ~= nil then
        self._objNodes.Text_total_cost_tickets:setString(config.STRING.UICLUBDATAREVIEW_STRING_102..searchData.totalCostTickets);
    end

    -- 牌局数
    if searchData.totalRoundNum ~= nil then
        self._objNodes.Text_total_round:setString("已结算牌局数: "..searchData.totalRoundNum);
    end

    -- 预口卡数    
    if searchData.preCostTickets ~= nil then
        if formatEndT.year < CheckYearLimit then
            self._objNodes.Text_pre_cost_tickets:setString("")
        else
            self._objNodes.Text_pre_cost_tickets:setString(config.STRING.UICLUBDATAREVIEW_STRING_109..searchData.preCostTickets)
        end
    end
end

-- 保留两位的数字
function UIClubDataReview:_getFormatNum(num)
    local s = "0"..num;
    s = string.sub(s,string.len(s) - 1,-1);
    return s;
end

-- 获取格式化的时间字符串 --<2017-09-27 10:35
function UIClubDataReview:_getFormatTime(formatTime)
    if not formatTime or formatTime.year < CheckYearLimit then    -- 如果没有选择时间或者时间很久远，显示选择时间
        return "请选择时间"
    end
    local t = formatTime;
    return t.year.."-"..t.month.."-"..t.day.." "..self:_getFormatNum(t.hour)..":"..self:_getFormatNum(t.min);
end

-- 获取格式化的正在进行中时间点
function UIClubDataReview:_getPlayingTime(formatTime)
    local t = formatTime;
    if not formatTime or formatTime.year < CheckYearLimit then    -- 如果没有选择时间或者时间很久远，隐藏
        return ""
    end
    return t.month.."-"..t.day.." "..self:_getFormatNum(t.hour)..":"..self:_getFormatNum(t.min).." 时"
end

function UIClubDataReview:_search()
    -- 统计点击时间滚轮内查询按钮的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Time_Query);

    if self._startSearchTime >= self._endSearchTime then
        game.ui.UIMessageTipsMgr.getInstance():showTips("您输入的起止时间有误!")
    else
        local recordService = game.service.RecordService.getInstance();
        recordService:sendCCLCheckClubBillREQ(self._clubId, self._startSearchTime * 1000, self._endSearchTime * 1000);
    end
end

-- 点击时间选择
function UIClubDataReview:_onClickSelTime()
    -- 统计点击时间条的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Time);

    UIManager:getInstance():show("UIClubSelectSearchTime", self._clubId, function(searchData)
        self:_refreshSelTimeUI(searchData)
        self:_search();
    end)
end

-- 显示玩法设置界面
function UIClubDataReview:_onClickPlayRestrictions()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Regulations);
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local banGameplays = club and club.data and club.data.banGameplays or {};        -- 服务器传回的已被禁止项
    UIManager:getInstance():show("UICreateRoom", self._clubId, ClubConstant:getGamePlayType().reverse, banGameplays)
end

-- 返回牌局界面
function UIClubDataReview:_onClickQuit()
    -- UIManager:getInstance():show("UIClubRoom", self._clubId)
    UIManager:getInstance():hide("UIClubDataReview")
end

function UIClubDataReview:_onClickBuy()
    -- 亲友圈房卡【购买】按钮的点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Buy)

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    -- 群主添加代理入口
    if club:isManager(localRoleId) then
        local text = config.STRING.UICLUBDATAREVIEW_STRING_103
        local btnName = "成为代理"
        local talkingData = game.globalConst.StatisticNames.Club_Buy_Bedaili
        if game.service.AgentService.getInstance():getIsAgency() then
            text = config.STRING.UICLUBDATAREVIEW_STRING_104
            btnName = "代理后台"
            talkingData = game.globalConst.StatisticNames.Club_Buy_Dailihoutai
        end

        game.ui.UIMessageBoxMgr.getInstance():show(text, {btnName}, function()
            -- 亲友圈代理按钮的点击
            game.service.DataEyeService.getInstance():onEvent(talkingData)

            game.service.AgentService.getInstance():openWebView(config.AGTSTYLE.club)
        end, nil, false, true)
    else
        -- 管理显示房卡
        local clubList = game.service.club.ClubService.getInstance():getClubList()
        local idx = clubList:indexOfClub(self._clubId)
        if idx ~= false then
            if clubList.clubs[idx]:isManager(game.service.LocalPlayerService:getInstance():getRoleId()) then
                game.ui.UIMessageBoxMgr.getInstance():show(string.format(config.STRING.UICLUBDATAREVIEW_STRING_105, config.GlobalConfig.getShareInfo()[1]), {"确定"})
            else
                game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBDATAREVIEW_STRING_106, {"确定"})
            end
        end
    end
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubDataReview:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

function UIClubDataReview:needBlackMask()
    return true
end

return UIClubDataReview
