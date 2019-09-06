local csbPath = "ui/csb/Club/UIClubManagerPage.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local CommonAreaId   = 0;       -- 通用地区编码
local RoomSetting    = config.GlobalConfig.getRoomSetting()
local CheckYearLimit = 2000;    -- 这个时间点以前的显示选择时间或者不显示 

local UIClubManagerPage = class("UIClubManagerPage", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    亲友圈管理界面
]]

function UIClubManagerPage:ctor()
    self._clubId                    = nil   
    self._startSearchTime           = 0     -- 开始查询的时间戳 单位秒
    self._endSearchTime             = 0     -- 截止查询的时间戳

    self._objNodes                  = nil
    self._btnPlayRestrictions       = nil   -- 玩法限制
    self._btnQuit                   = nil   -- 返回

    self._textBMFontRoomCardCount   = nil   -- 亲友圈房卡
    self._btnBuy                    = nil   -- 购买房卡
    
    self._btnClubInfo               = nil   -- 资料

    self._btnDestoryClub            = nil   -- 解散亲友圈

    self._imgSettingRed             = nil   -- 设置上的红点
    self._hasSettingRed             = false -- 是否显示小红点
end

function UIClubManagerPage:init()
    local root                      = seekNodeByName(self, "Panel_2_DZD_ClubGL",                "ccui.Layout")
    self._objNodes                  = bindNodeToTarget(root)
    self._btnPlayRestrictions       = seekNodeByName(self, "Button_wf_ClubCL",                  "ccui.Button")
    self._btnQuit                   = seekNodeByName(self, "Button_fh_ClubCL",                  "ccui.Button")
    self._btnBuy                    = seekNodeByName(self, "Button_gm_ClubCL",                  "ccui.Button")
    self._textBMFontRoomCardCount   = seekNodeByName(self, "BitmapFontLabel_sz_top_ClubCL",     "ccui.TextBMFont")
    self._btnClubInfo               = seekNodeByName(self, "Button_zl_ClubCL",                  "ccui.Button")
    self._btnDestoryClub            = seekNodeByName(self, "Button_js_ClubCL",                  "ccui.Button")
    self._imgSettingRed             = seekNodeByName(self, "Image_SettingRed",                  "ccui.ImageView")

    self:_registerCallBack()
end

-- 点击事件注册
function UIClubManagerPage:_registerCallBack()
    bindEventCallBack(self._btnPlayRestrictions, handler(self, self._onClickPlayRestrictions), ccui.TouchEventType.ended)
    bindEventCallBack(self._objNodes.Button_select_time, handler(self, self._onClickSelTime), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuit, handler(self, self._onClickQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBuy, handler(self, self._onClickBuy), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClubInfo, handler(self, self._onClickClubInfo), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDestoryClub, handler(self, self._onClickDestoryClub), ccui.TouchEventType.ended)
end

function UIClubManagerPage:onShow(clubId)
    self._clubId  = clubId

    -- 监听消息
    local recordService = game.service.RecordService.getInstance();
    recordService:addEventListener("EVENT_CLUB_TODAY_BILL_CHANGE", handler(self, self._refreshBriefDataUI), self);
    recordService:addEventListener("EVENT_CLUB_SEARCH_DATA_CHANGE", function(event) self:_refreshSearchDataUI(event.searchData) end, self);
    game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_USER_INFO_CARD_COUNT_CHANGED", handler(self, self._onCardCountChangedEvent), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)
    
    -- 每次进入都请求一次昨天/今天扣卡数
    recordService:sendCCLCheckClubBillTodayREQ(clubId);

     -- 用户第一次进来显示小红点
    self._hasSettingRed = game.service.club.ClubService.getInstance():loadLocalStoragePlayerInfo():getClubInfo(self._clubId).hasSetting
    self._imgSettingRed:setVisible(self._hasSettingRed)

    -- 初次进入刷新上次的查询界面
    self:_refreshSearchDataUI(recordService:getSearchData(self._clubId));

    -- 只有群主能看见
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    self._btnDestoryClub:setVisible(club:isManager(game.service.LocalPlayerService:getInstance():getRoleId()))

    self:_onCardCountChangedEvent()
    self:_showTabBadge()
end

-- 更新Tab上的Badge状态
function UIClubManagerPage:_showTabBadge()
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
end

function UIClubManagerPage:onHide()
    -- 取消事件监听
    game.service.RecordService.getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
end

-- 实时刷新房卡
function UIClubManagerPage:_onCardCountChangedEvent()
    -- 设置亲友圈房卡数量
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    if club:isManager(localRoleId) then
        local userData = game.service.club.ClubService.getInstance():getUserData();
        self._textBMFontRoomCardCount:setString(userData.info and userData.info.clubCardCount or "0")
    elseif club:isAdministrator(localRoleId) then
        self._textBMFontRoomCardCount:setString(club.info.clubCardCount)
    end
end

-- 刷新今天的扣卡
function UIClubManagerPage:_refreshBriefDataUI(event)
    if event and event.clubId == self._clubId then
        self._objNodes.Text_yesterday_today_cost:setString("今日/昨日已结算牌局数:"..event.todayRoomNum.."/"..event.yesterdayRoomNum);
    end
end

-- 刷新选择时间UI
function UIClubManagerPage:_refreshSelTimeUI(searchData)
    self._startSearchTime = searchData.startTimeStamp;
    self._endSearchTime   = searchData.endTimeStamp;
    local formatStartT = kod.util.Time.time2Date(self._startSearchTime);
    local formatEndT   = kod.util.Time.time2Date(self._endSearchTime);
    local startTimeStr = "<"..self:_getFormatTime(formatStartT);
    local endTimeStr  = self:_getFormatTime(formatEndT)..">";
    self._objNodes.Text_quarry_start_time:setString(startTimeStr);
    self._objNodes.Text_quarry_end_time:setString(endTimeStr);
end

-- 刷新查询结果
function UIClubManagerPage:_refreshSearchDataUI(searchData)
    -- 只接收本亲友圈数据
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
        self._objNodes.Text_total_cost_tickets:setString(config.STRING.UICLUBMANAGERPAGE_STRING_100..searchData.totalCostTickets);
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
            self._objNodes.Text_pre_cost_tickets:setString(config.STRING.UICLUBMANAGERPAGE_STRING_107..searchData.preCostTickets)
        end
    end
end

-- 保留两位的数字
function UIClubManagerPage:_getFormatNum(num)
    local s = "0"..num;
	s = string.sub(s,string.len(s) - 1,-1);
    return s;
end

-- 获取格式化的时间字符串 --<2017-09-27 10:35
function UIClubManagerPage:_getFormatTime(formatTime)
    if not formatTime or formatTime.year < CheckYearLimit then    -- 如果没有选择时间或者时间很久远，显示选择时间
        return "请选择时间"
    end
    local t = formatTime;
    return t.year.."-"..t.month.."-"..t.day.." "..self:_getFormatNum(t.hour)..":"..self:_getFormatNum(t.min);
end

-- 获取格式化的正在进行中时间点
function UIClubManagerPage:_getPlayingTime(formatTime)
    local t = formatTime;
    if not formatTime or formatTime.year < CheckYearLimit then    -- 如果没有选择时间或者时间很久远，隐藏
        return ""
    end
    return t.month.."-"..t.day.." "..self:_getFormatNum(t.hour)..":"..self:_getFormatNum(t.min).." 时"
end

function UIClubManagerPage:_search()
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
function UIClubManagerPage:_onClickSelTime()
    -- 统计点击时间条的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Time);

    UIManager:getInstance():show("UIClubSelectSearchTime", self._clubId, function(searchData)
        self:_refreshSelTimeUI(searchData)
        self:_search();
    end)
end

-- 显示玩法设置界面
function UIClubManagerPage:_onClickPlayRestrictions()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Regulations);
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local banGameplays = club and club.data and club.data.banGameplays or {};        -- 服务器传回的已被禁止项
    UIManager:getInstance():show("UICreateRoom", self._clubId, ClubConstant:getGamePlayType().reverse, banGameplays)
end

-- 返回牌局界面
function UIClubManagerPage:_onClickQuit()
    UIManager:getInstance():show("UIClubRoom", self._clubId)
    UIManager:getInstance():hide("UIClubManagerPage")
end

function UIClubManagerPage:_onClickBuy()
    -- 亲友圈房卡【购买】按钮的点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Buy)

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    -- 群主添加代理入口
    if club:isManager(localRoleId) then
        local text = config.STRING.UICLUBMANAGERPAGE_STRING_101
        local btnName = "成为代理"
        local talkingData = game.globalConst.StatisticNames.Club_Buy_Bedaili
        if game.service.AgentService.getInstance():getIsAgency() then
            text = config.STRING.UICLUBMANAGERPAGE_STRING_102
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
                game.ui.UIMessageBoxMgr.getInstance():show(string.format(config.STRING.UICLUBMANAGERPAGE_STRING_103, config.GlobalConfig.getShareInfo()[1]), {"确定"})
            else
                game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMANAGERPAGE_STRING_104, {"确定"})
            end
        end
    end
end

-- 显示亲友圈信息
function UIClubManagerPage:_onClickClubInfo()
    -- 统计点击设置按钮的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.SETUP_CLICK);

    -- 在红点显示的情况下点开设置界面小红点就不显示了
    if self._hasSettingRed then
        local playerInfo = game.service.club.ClubService.getInstance():loadLocalStoragePlayerInfo()
        playerInfo:getClubInfo(self._clubId).hasSetting = false
        game.service.club.ClubService.getInstance():saveLocalStoragePlayerInfo(playerInfo)
        self._imgSettingRed:setVisible(false)
    end

    UIManager:getInstance():show("UIClubSetting", self._clubId)
end

-- 解散亲友圈
function UIClubManagerPage:_onClickDestoryClub()
    game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMANAGERPAGE_STRING_105 , {"确定","取消"}, function()
        local clubService = game.service.club.ClubService.getInstance()
        local club = clubService:getClub(self._clubId)
        if club.data ~= nil then
            -- 给群主二次确认是否解散亲友圈，亲友圈有其他成员就再次让群主确认，没有直接解散
            if club.data.memberCount > 1 then
                game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMANAGERPAGE_STRING_106 , {"确定","取消"}, function()
                    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLRemoveClubREQ(self._clubId)
                end)
            else
                game.service.club.ClubService.getInstance():getClubManagerService():sendCCLRemoveClubREQ(self._clubId)
            end
        end
    end)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubManagerPage:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

return UIClubManagerPage
