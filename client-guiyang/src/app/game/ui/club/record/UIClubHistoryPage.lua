local csbPath = "ui/csb/Club/UIClubHistoryPage.csb"
local super = require("app.game.ui.UIBase")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

--[[
    亲友圈战绩列表
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
    self._bigboss[1]  = seekNodeByName(self, "Image_play1_list_b_ZJ_club", "ccui.ImageView")
    self._bigboss[2]  = seekNodeByName(self, "Image_play2_list_b_ZJ_club", "ccui.ImageView")
    self._bigboss[3]  = seekNodeByName(self, "Image_play3_list_b_ZJ_club", "ccui.ImageView")
    self._bigboss[4]  = seekNodeByName(self, "Image_play4_list_b_ZJ_club", "ccui.ImageView")

    self._checkBoxProcess = seekNodeByName(self, "CheckBox_process", "ccui.CheckBox") -- 处理按钮
    self._btnDetails = seekNodeByName(self, "Button_details", "ccui.Button") -- 房间详情
    self._ingStatus = seekNodeByName(self, "Image_status", "ccui.ImageView") -- 中途解散的标识

    bindEventCallBack(self._btnDetails, handler(self, self._onClickInfoBtn), ccui.TouchEventType.ended)
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
    -- 按照pos进行排序（服务器发来的可能乱序）
    
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

    -- 处理房间战绩
    local club = game.service.club.ClubService.getInstance():getClub(val.clubId)
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    
    if club:isPermissions(roleId) then
        self._checkBoxProcess:setVisible(true)
        self._checkBoxProcess:setSelected(val.isProcessed)
    else
        self._checkBoxProcess:setVisible(false)
    end

    self._ingStatus:setVisible(val.isAbnormalRoom)

    bindEventCallBack(self._checkBoxProcess, function()
        -- 统计战绩点赞统计
        game.service.DataEyeService.getInstance():onEvent(string.format("handle_button_is_%s", val.isProcessed and "grey" or "bright"))
        
        game.service.club.ClubService.getInstance():getClubHistoryService():sendCRProcessHistoryREQ(val.roomId, val.createTime, not val.isProcessed)
    end, ccui.TouchEventType.ended)
end

-- 点击显示房间战绩详情
function UIElemRoomItem:_onClickInfoBtn()
    local service = game.service.LocalPlayerService:getInstance():getHistoryRecordService()
    service:queryHistoryRoom(self._data.createTime, self._data.roomId, 0, false, self._data, self._data.clubId, self._data.isAbnormalRoom)
end

-------------------------------------------------------
local UIClubHistoryPage = class("UIClubHistoryPage", super, function() return kod.LoadCSBNode(csbPath) end)

local MAX_HISTORY_COUNT = 20

function UIClubHistoryPage:ctor()
    -- 当前显示的页数
    self._currPage = 1
    -- 原始数据，这里要不要保存？看设计吧
    self._srcDatas  = {}
    self._filter = nil
    
    self._btnFilter             = nil       -- 搜索
    self._btnPrev               = nil       -- 上一页
    self._btnNext               = nil       -- 下一页
    self._panelInput            = nil       -- 查询的panel
    self._btnQuit               = nil       -- 返回
    self._btnFilterEnd          = nil       -- 结束搜索
    self._textInput             = nil       -- 输入（房间号）
    self._textPrompt            = nil       -- 提示框
    self._reusedListHistorys    = nil       -- 战绩列表

    self._textDetails           = nil       -- 处理
    self._btnPlayback           = nil       -- 回放按钮

    self._roomIdPanel           = nil       -- 输入房间号panel
end

function UIClubHistoryPage:init()
    self._btnFilter             = seekNodeByName(self, "Button_ss_sr_CLubZJ233",      "ccui.Button")
    self._btnDateSet             = seekNodeByName(self, "Button_ss_sr_CLubdate",      "ccui.Button")
    self._btnPrev               = seekNodeByName(self, "Button_up_clubZJ",          "ccui.Button")
    self._btnNext               = seekNodeByName(self, "Button_down_clubZJ",        "ccui.Button")
    self._panelInput            = seekNodeByName(self, "Panel_sr_CLubZJ3",          "ccui.Layout")
    self._roomIdPanel            = seekNodeByName(self, "Panel_sr_CLubZJSS",        "ccui.Layout")
    self._btnQuit               = seekNodeByName(self, "Button_x_CLubZJ2",          "ccui.Button")
    self._btnFilterEnd          = seekNodeByName(self, "Button_x_sr_CLubZJ2",       "ccui.Button")
    self._textInput             = seekNodeByName(self, "TextField_z_sr_CLubZJ2",    "ccui.TextField")
    self._textPrompt             = seekNodeByName(self, "Text_tiao",                "ccui.Text")
    self._textDetails           = seekNodeByName(self, "Text_6_top_b_ZJ_CLubZJ2",   "ccui.Text")
    self._btnPlayback           = seekNodeByName(self, "Button_hf_sr_CLub", "ccui.Button")


    self._filterText             = seekNodeByName(self, "Text_default",    "ccui.Text")
    self._reusedListHistorys    = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_b_ZJ_club", "ccui.ListView"), UIElemRoomItem)
    self._reusedListHistorys:setScrollBarEnabled(false)

    self._panelPosY = self._roomIdPanel:getPositionY()
    
    self:_registerCallBack()
end

function UIClubHistoryPage:_onBtnDateSet()
    -- 统计战绩页面【更改】按钮点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Zhanji_Change);
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local isDisbandShow = club:isPermissions(game.service.LocalPlayerService.getInstance():getRoleId())
    UIManager.getInstance():show('UIClubHistoryFilter', self._queryTime, self._minScore, isDisbandShow, function (queryTime, minScore, isDisbandShow)
        self:_setFilter(queryTime, minScore , isDisbandShow)
        self:_onClickFilter()
    end)
end

-- 点击事件注册
function UIClubHistoryPage:_registerCallBack()
    bindEventCallBack(self._btnFilter, handler(self, self._onClickFilter), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPrev, handler(self, self._onBtnPrev), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDateSet, handler(self, self._onBtnDateSet), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNext, handler(self, self._onBtnNext), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFilterEnd, handler(self, self._onClickFilterEnd), ccui.TouchEventType.ended)

    self._textInput:addEventListener(handler(self, self._onTextFieldChanged))

    bindEventCallBack(self._btnPlayback, handler(self, self._onPlayBack), ccui.TouchEventType.ended)
end


--查看他人回放
function UIClubHistoryPage:_onPlayBack()
    UIManager:getInstance():show("UIKeyboard", "输入回放码", 6, "请输入正确的回放码", "查询", function (replayCode)
        game.service.HistoryRecordService.getInstance():queryHistoryRoomByCode(replayCode)
    end)
end

function UIClubHistoryPage:_onTextFieldChanged(sender, eventType)
    -- 当是插入文字的时候
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		-- 统计战绩页面搜索输入框点击
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Zhanji_soushurukuang);
	end
end

function UIClubHistoryPage:_setFilter(time,score,isdisband)
    local date = os.date("%Y-%m-%d", time)
    self._queryTime=time
    self._minScore=score
    self._filterText:setString(date..'\n赢家分不低于'..score)
    if self._disband ~= isdisband then
        self._disband = isdisband
    end
    
end

function UIClubHistoryPage:onShow(clubId, ui)
    self._clubId = clubId
    self._ui = ui or "UIClubRoom"
    local clubHistoryService = game.service.club.ClubService.getInstance():getClubHistoryService()

    self:_updataInput()
    self:_updateListView() 

    -- 设置输入框的颜色
    self._textInput:setPlaceHolderColor(config.ColorConfig.InputField.White.InputHolder)
    self._textInput:setTextColor(config.ColorConfig.InputField.White.inputTextColor)

    -- 请求亲友圈战绩
    -- 这里先请求前50条，后面再去完整的做
    -- 最少分数
    self._minScore = self._minScore or 0
    -- 查询日期
    self._queryTime = self._queryTime or kod.util.Time.now()
    self:_setFilter(self._queryTime, self._minScore)

    clubHistoryService:sendClubHistoryREQ(self._clubId, 0 , MAX_HISTORY_COUNT, 0, self._minScore, self._queryTime, self._disband)
    -- 监听事件    
    clubHistoryService:addEventListener("EVENT_CLUB_HISTORY_DATA_RETRIVED", handler(self, self._onHistoryDataRetrived), self)

    clubHistoryService:addEventListener("EVENT_CLUB_HISTORY_PROCESS", handler(self, self._onHistoryDataUpdata), self)
end

-- self._panelPosY
function UIClubHistoryPage:_updataInput()
    local platForm = cc.Application:getInstance():getTargetPlatform()
	local function textFieldEvent(sender, eventType)
        -- 输入框的监听事件
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            if platForm ~= cc.PLATFORM_OS_ANDROID then
                self._roomIdPanel:setPositionY(self._panelPosY + display.height/2)
                self._roomIdPanel:setLocalZOrder(2)
            end 
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
            if platForm ~= cc.PLATFORM_OS_ANDROID then
                self._roomIdPanel:setPositionY(self._panelPosY)
                self._roomIdPanel:setLocalZOrder(0)
            end 
        elseif eventType == ccui.TextFiledEventType.insert_text then
            -- 判断输入的是不是数字
            local str = self._textInput:getString()
            local sTable = kod.util.String.stringToTable(str)
            local roomNumber = ""
            for i=1,#sTable do
                -- 如果不是number不保存
                if tonumber(sTable[i]) ~= nil then
                    roomNumber = roomNumber .. sTable[i]
                end
            end
            self._textInput:setString(roomNumber)
        elseif eventType == ccui.TextFiledEventType.delete_backward then
        end  
    end

    self._textInput:addEventListener(textFieldEvent)
end

function UIClubHistoryPage:onHide()
    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubHistoryService():removeEventListenersByTag(self)

    -- 键盘自动隐藏
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end

function UIClubHistoryPage:_updateListView()
    self._reusedListHistorys:deleteAllItems()
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    
    self._panelInput:setVisible(club:isPermissions(game.service.LocalPlayerService.getInstance():getRoleId()))
    self._textDetails:setVisible(club:isPermissions(game.service.LocalPlayerService.getInstance():getRoleId()))
    
    local histories = game.service.club.ClubService.getInstance():getClub(self._clubId).histories
    -- 这里的数据需要去service里面去取！！！
    -- TODO: 这里的房卡消耗数跟房主当前是没有值的
    -- 现在这里就改为filter过滤吧
    for key,val in ipairs(histories) do
        if self._filter ~= nil and val.roomId ~= self._filter then
        else
            val.clubId = self._clubId
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

function UIClubHistoryPage:_onBtnPrev()
    if self._currPage > 1 then
        self._currPage = self._currPage - 1
        game.service.club.ClubService.getInstance():getClubHistoryService():sendClubHistoryREQ(self._clubId, (self._currPage-1)*MAX_HISTORY_COUNT , MAX_HISTORY_COUNT, 0, self._minScore, self._queryTime, self._disband)
    end
end

function UIClubHistoryPage:_onBtnNext()
    if #self._reusedListHistorys:getItemDatas() >= MAX_HISTORY_COUNT then
        self._currPage = self._currPage + 1
    end
    game.service.club.ClubService.getInstance():getClubHistoryService():sendClubHistoryREQ(self._clubId, (self._currPage-1)*MAX_HISTORY_COUNT , MAX_HISTORY_COUNT, 0, self._minScore,self._queryTime, self._disband)
end

-- 点击搜索战绩
function UIClubHistoryPage:_onClickFilter(sender)
    -- 统计战绩页面搜索【确定】按钮点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Zhanji_sousuo);

    self._filter = tonumber(self._textInput:getString()) 
    -- self:_updateListView()
    game.service.club.ClubService.getInstance():getClubHistoryService():sendClubHistoryREQ(self._clubId, (self._currPage-1)*MAX_HISTORY_COUNT , MAX_HISTORY_COUNT, 0, self._minScore,self._queryTime,self._disband)
end

-- 点击取消搜索战绩
function UIClubHistoryPage:_onClickFilterEnd(sender)
    if self._filter ~= nil then
        self._filter = nil
        self._textInput:setString("")
        self:_updateListView()
    elseif self._textInput:getString() ~= nil or self._textInput:getString() ~= "" then
        self._textInput:setString("")
    end
    self._roomIdPanel:setPositionY(self._panelPosY)
end

-- 查询战绩结果
function UIClubHistoryPage:_onHistoryDataRetrived(event)
    -- 更新List中数据
    -- 原始数据保存
    if event.clubId ~= self._clubId then
        return
    end
    self:_updateListView()
end

function UIClubHistoryPage:_onBtnQuit()
    UIManager:getInstance():show(self._ui, self._clubId)
    UIManager:getInstance():hide("UIClubHistoryPage")
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubHistoryPage:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

-- 更新处理按钮状态
function UIClubHistoryPage:_onHistoryDataUpdata(event)
    local itemIdx, data = self:_indexOfInvitation(event.roomId, event.createTime)
    -- 删除数据        
    if Macro.assertFalse(itemIdx ~= false) then
        data.isProcessed = event.isProcessed
        self._reusedListHistorys:updateItem(itemIdx, data)
    end
end

-- 查找item
function UIClubHistoryPage:_indexOfInvitation(roomId, createTime)
    for idx,item in ipairs(self._reusedListHistorys:getItemDatas()) do
        if item.roomId == roomId and item.createTime == createTime then
            return idx, item
        end
    end

    return false;
end

return UIClubHistoryPage