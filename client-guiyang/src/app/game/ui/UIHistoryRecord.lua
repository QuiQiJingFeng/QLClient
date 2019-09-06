local UtilsFunctions = require("app.game.util.UtilsFunctions")
local csbPath = "ui/csb/UIHistoryRecord.csb"
local super = require("app.game.ui.UIBase")

-- 单条战绩记录显示
local UIHistoryRecordBar = class("UIHistoryRecordBar")

function UIHistoryRecordBar:ctor(root)
    self._createTimeText = nil
    self._nameTexts = {}
    self._scoreTexts = {}
    self._roomNumText = nil
    self._root = root

    self:initialize()

end

function UIHistoryRecordBar:initialize()
    self._textCreateTime = self._root:getChildByName("Text_Create_Time")
    self._roomNumText = self._root:getChildByName("Text_2_History")
    self._createTimeText = self._root:getChildByName("Text_6_History")
    self._card = self._root:getChildByName("Text_id_list_b_ZJ_club_0")
    
    for i = 1, 4 do
        local layout = self._root:getChildByName("Panel_player" .. i .. "_HisRecord")
        layout:setTouchEnabled(false)
        local str = "Text_name_player" .. i .. "_History"
        self._nameTexts[#self._nameTexts + 1] = layout:getChildByName(str)
        str = "Text_score_player" .. i .. "_History"
        self._scoreTexts[#self._scoreTexts + 1] = layout:getChildByName(str)
    end
    
    self._root:setVisible(false)
end

-- 显示单条记录
--@param roomData: 房间记录数据
--@param sequence: 记录数据序号
function UIHistoryRecordBar:show(roomData, sequence)
    self:setVisible(true)

    -- 按照pos进行排序（服务器发来的可能乱序）
    table.sort(roomData.playerRecords, function (a, b)
        return a.position < b.position
    end)

    for i, playerData in ipairs(roomData.playerRecords) do
        self._nameTexts[i]:setString(string.format("%s(%s)", kod.util.String.getMaxLenString(playerData.roleName, 8), playerData.roleId))
        UtilsFunctions.setScoreWithColor(self._scoreTexts[i], playerData.totalScore)
        -- self._scoreTexts[i]:setString((playerData.totalScore >= 0 and "+" or "") .. playerData.totalScore)
        self._nameTexts[i]:getParent():setVisible(true)
    end

    for i = #roomData.playerRecords + 1, 4 do
        self._nameTexts[i]:getParent():setVisible(false)
    end

    self._roomNumText:setString(roomData.roomId)

    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local roomCostList = MultiArea.getRoomCost(areaId)
    self._card:setString(roomCostList[roomData.roundType])
    local formatData = roomData.destroyTime/1000
    local data = os.date("%Y-%m-%d\n%H:%M", formatData)
    self._createTimeText:setString(data)
    -- self._createTimeText:setString(os.date("%Y-%m-%d %H: %M", roomData.createTime/1000) )
end

-- 隐藏或显示记录
--@param b: boolean
function UIHistoryRecordBar:setVisible(b)
    self._root:setVisible(b)
end

-- 战绩记录主界面
local UIHistoryRecord= class("UIHistoryRecord", super, function() return kod.LoadCSBNode(csbPath) end)

function UIHistoryRecord:ctor()
    self._btnBack = nil -- 返回按钮
    self._btnPrePage = nil -- 向前翻页
    self._btnNextpage = nil -- 向后翻页
    self._recordBase = nil -- 单条记录模板
    self._curPage = 0 -- 当前页，0开始计数
    self._maxPage = 0 -- 最大页个数
    self._recordCount = 0   -- 记录总数
    self._isFirst = true
    self._recordData = nil  -- 记录数据
    self._recordBars = {} -- 记录显示条列表
	self._MaxRecord = nil
	self._recordDay = 10
    self._textPrompt = nil -- 提示框
    self._btnPlayback = nil -- 回放按钮

    game.service.LoginService.getInstance():addEventListener("EVENT_PLAYER_REGION_CHANGED", handler(self, self._onRegionChanged), self)
end

function UIHistoryRecord:init()
    self._btnBack = seekNodeByName(self, "Button_back_HisRecord", "ccui.Button")
    self._btnPrePage= seekNodeByName(self, "Button_1_HisRecord", "ccui.Button")
    self._btnNextpage = seekNodeByName(self, "Button_2_HisRecord", "ccui.Button")
    self._recordBase = seekNodeByName(self, "Panel_line1_HisRecord", "ccui.Layout")
    self._scrollView = seekNodeByName(self, "ScrollView_details_HisRecord", "ccui.ScrollView")
	self._MaxRecord =seekNodeByName(self, "Text_Explain_HisRecord","ccui.Text")
    self._textPrompt = seekNodeByName(self, "Image_none", "ccui.ImageView")
    self._btnPlayback = seekNodeByName(self, "Button_hf_sr_CLub", "ccui.Button")

    self._scrollView:setScrollBarEnabled(false)
    self._recordBase:retain()
    self._recordBase:removeFromParent(false)
    self._recordHeight = self._recordBase:getContentSize().height
    self._scrollView:setInnerContainerSize(self._scrollView:getContentSize())
    local basePositionY = self._recordBase:getPositionY()

    for i=1, 4 do
        local bar = self._recordBase:clone()
        self._scrollView:addChild(bar)
        bar:setPositionY(basePositionY - (i - 1) * self._recordHeight)
        bar:setTag(i)
        bindEventCallBack(bar, handler(self, self._onRecordSelect), ccui.TouchEventType.ended)
        table.insert(self._recordBars, UIHistoryRecordBar.new(bar))
    end

    self:_bindCallback()
end

function UIHistoryRecord:dispose()
    if self._recordBase ~= nil then
        self._recordBase:release()
        self._recordBase = nil
    end    
end

function UIHistoryRecord:destroy()
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
end

function UIHistoryRecord:_bindCallback()
    bindEventCallBack(self._btnBack, handler(self, self._onBackButton), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPrePage, handler(self, self._onPrePageButton), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNextpage, handler(self, self._onNextPageButton), ccui.TouchEventType.ended)
    bindEventCallBack(self._recordBase, handler(self, self._onRecordSelect), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPlayback, handler(self, self._onPlayBack), ccui.TouchEventType.ended)
end


--查看他人回放
function UIHistoryRecord:_onPlayBack()
    UIManager:getInstance():show("UIKeyboard", "输入回放码", 6, "请输入正确的回放码", "查询", function (replayCode)
        game.service.HistoryRecordService.getInstance():queryHistoryRoomByCode(replayCode)
    end)
end

-- 返回到大厅
function UIHistoryRecord:_onBackButton()
    UIManager:getInstance():destroy("UIHistoryRecord")
end

-- 向前翻页
function UIHistoryRecord:_onPrePageButton()
    self._curPage = self._curPage - 1
    if self._curPage < 0 then
        self._curPage = self._maxPage - 1
    end

    self:_showPage()
end

-- 向后翻页
function UIHistoryRecord:_onNextPageButton()
    self._curPage = self._curPage + 1
    if self._curPage >= self._maxPage then
        self._curPage = 0
    end

    self:_showPage()
end

-- 响应记录点击事件
function UIHistoryRecord:_onRecordSelect(sender)
    local idx = self._curPage * 4 + sender:getTag()
    local service = game.service.LocalPlayerService:getInstance():getHistoryRecordService()

    local detailData = self._recordData.roomRecordDatas[idx]
    --TODO:每次都请求战绩，以后修改
    service:queryHistoryRoom(detailData.createTime, detailData.roomId, 0, true)
    -- if #detailData.roundReportRecords == 0 then
    --     service:queryHistoryRoom(detailData.createTime, detailData.roomId, 0, true)
    -- else
    --     UIManager:getInstance():show("UIHistoryDetail", detailData)
    -- end
end

--@arg
function UIHistoryRecord:onShow(...)
	--提审相关（战绩）
	if GameMain.getInstance():isReviewVersion() then
		self._recordData = 20
		self._recordDay = 15
    else
        self._recordData = 100
		self._recordDay = 15
	end
    self._MaxRecord:setString("可看最近"..self._recordDay.."天最多"..self._recordData.."条房间的对战记录，包括解散房间内已完成的对战记录")

    local args = { ... }
    local refresh = args[1]

    local recordDatas = game.service.LocalPlayerService:getInstance():getHistoryRecordService():getDatas()._recordDatas;

    self._recordData = recordDatas[1]

    -- 有数据则显示
    local count = self._recordData and #self._recordData.roomRecordDatas or 0
    if nil ~= self._recordData and count > 0 then
        self._recordCount = count
        self._curPage = 0
        self._maxPage = math.ceil(count / 4)

        self._btnPrePage:setVisible(self._maxPage > 1)
        self._btnNextpage:setVisible(self._maxPage > 1)
        self._textPrompt:setVisible(false)
    else
        -- 没有数据显示对应提示
        -- todo
        self._btnPrePage:setVisible(false)
        self._btnNextpage:setVisible(false)
        self._textPrompt:setVisible(true)
    end

    -- TODO 这里加了下保护，如果是bug，可能要改，现在怀疑是原记录被删除
    if self._recordData ~= nil then
        self:_showPage()
    end
end

-- 显示指定页数据
function UIHistoryRecord:_showPage()
    local idx = 0
    for i = 1, 4 do
        self._recordBars[i]:setVisible(false)
        idx = self._curPage * 4 + i
        if idx <= self._recordCount then
            self._recordBars[i]:show(self._recordData.roomRecordDatas[idx], idx)
        end
    end
end

-- 切换游戏区域时调用的函数
function UIHistoryRecord:_onRegionChanged()
    UIManager:getInstance():destroy("UIHistoryRecord")
end


function UIHistoryRecord:needBlackMask()
	return true;
end

function UIHistoryRecord:closeWhenClickMask()
	return false
end

return UIHistoryRecord
