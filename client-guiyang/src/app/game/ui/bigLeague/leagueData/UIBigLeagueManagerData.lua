local csbPath = "ui/csb/BigLeague/UIBigLeagueManagerData.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIBigLeagueManagerData = class("UIBigLeagueManagerData", super, function() return kod.LoadCSBNode(csbPath) end)

--排序
local SORT_ORDER =
{
	positive = 1, -- 正序
	inverted = 2, -- 倒序
}


--需要排序的类型 默认不排序
local SORT_TYPE =
{
	{name = "Player_Count", sort = 1}, --成员场次
	{name = "Winner_Count", sort = 0}, --大赢家次数
	{name = "Contribution_Value", sort = 0},--贡献活跃值
}

function UIBigLeagueManagerData:ctor()
	
end

function UIBigLeagueManagerData:init()
	self._checkBoxSort = {}
	self._reusedListManager = ListFactory.get(
	seekNodeByName(self, "ListView_Manager_Data", "ccui.ListView"),
	handler(self, self._onListViewInit),
	handler(self, self._onListViewSetData)
	)
	
	-- 不显示滚动条, 无法在编辑器设置
	self._reusedListManager:setScrollBarEnabled(false)
	self._btnTimeSelect = seekNodeByName(self, "CheckBox_Date", "ccui.CheckBox") -- 选择时间
	
	self._curryValue = seekNodeByName(self, "Text_CurryValue", "ccui.TextBMFont")
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	self._btnToday = seekNodeByName(self, "CheckBox_Today", "ccui.CheckBox") -- 今日数据
	self._btnYesterDay = seekNodeByName(self, "CheckBox_Yesterday", "ccui.CheckBox") -- 昨日数据
	local tbChkBox = {self._btnToday, self._btnYesterDay, self._btnTimeSelect}
	
	local topPanel = seekNodeByName(self, "Panel_top_Clubpj", "ccui.Layout")
	local panelSize = topPanel:getContentSize()
	topPanel:getChildByName("Image_3"):setPositionX(panelSize.width)

    local isSelected = false
    local pFunc = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = sender:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if sender:getName() == "CheckBox_Today" then 
                self:_onClickToday()
            elseif sender:getName() == "CheckBox_Yesterday" then 
                self:_onClickYesterDay()
            elseif sender:getName() == "CheckBox_Date" then 
                self:_onClickSelectTime()
            end

            for _,btn in ipairs(tbChkBox) do 
                btn:setSelected(sender == btn)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setSelected(isSelected)
        end
    end

    self._btnTimeSelect:addTouchEventListener(pFunc)
    self._btnToday:addTouchEventListener(pFunc)
    self._btnYesterDay:addTouchEventListener(pFunc)

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	--初始化按钮
	for index, data in ipairs(SORT_TYPE) do
		local node = seekNodeByName(self, "Button_" .. data.name, "ccui.Button")
		self._checkBoxSort[data.name] = node
	end
end


function UIBigLeagueManagerData:_onListViewInit(listItem)
	listItem._imgHeadFrame = seekNodeByName(listItem, "Image_headFrame", "ccui.ImageView") 			-- 头像框
	listItem._imgHead = seekNodeByName(listItem, "Image_Head", "ccui.ImageView")					-- 头像
	listItem._imgStatus = seekNodeByName(listItem, "Image_status", "ccui.ImageView")				-- 状态

	listItem._textMemberName = seekNodeByName(listItem, "Text_MemberName", "ccui.Text") 			-- 成员名字
	listItem._textMemberId = seekNodeByName(listItem, "Text_MemberId", "ccui.Text") 				-- 成员id
	listItem._textMemeberCount = seekNodeByName(listItem, "Text_MemeberCount", "ccui.Text") 		-- 成员场次
	listItem._textWinnerCount = seekNodeByName(listItem, "Text_WinnerCount", "ccui.Text") 			-- 大赢家次数
	listItem._textActiveValue = seekNodeByName(listItem, "Text_ActiveValue", "ccui.Text") 			-- 贡献活跃值
end

function UIBigLeagueManagerData:_onListViewSetData(listItem, val)
	local headFrameUrl = PropReader.getIconById(val.memberHeadFrameId)
	game.util.PlayerHeadIconUtil.setIconFrame(listItem._imgHeadFrame,headFrameUrl,0.6)
	game.util.PlayerHeadIconUtil.setIcon(listItem._imgHead, val.memberHeadUrl)
	listItem._imgStatus:loadTexture(ClubConstant:getOnlineStatusIcon("member", val.memberStatus))

	local name = game.service.club.ClubService.getInstance():getInterceptString(val.memberName, 8)
	listItem._textMemberName:setString(name)
	listItem._textMemberId:setString(val.memberId)
	listItem._textMemeberCount:setString(val.matchCount)
	listItem._textWinnerCount:setString(val.winCount)
	listItem._textActiveValue:setString(math.round(val.devoteClubFireScore*100)/100)
end


function UIBigLeagueManagerData:onShow(...)

    local args = {...}
	self._clubId = args[1]
	self._clubDate = args[2]

	--当前时间
	self._preDate = 0

	self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
	if self._clubId == nil  and self._clubDate == nil then 
		local  clubId = self._bigLeagueService:getLeagueData():getClubId()
		self._bigLeagueService:sendCCLQueryClubMemberActivityInfoREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
		clubId,
		game.service.TimeService:getInstance():getStartTime(self._preDate) * 1000)
	else 
		local now = game.service.TimeService.getInstance():getCurrentTime()
		local deltTime = now - self._clubDate/1000
		local num = math.floor(deltTime / (24 * 3600))
		self._preDate = num

		self._bigLeagueService:sendCCLQueryClubMemberActivityInfoREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
		self._clubId,self._clubDate)

	end 
	self._bigLeagueService:addEventListener("EVENT_LEAGUEMANAGER_DATA", handler(self, self._updateMemberList), self)
	self._originZOrder = self:getLocalZOrder()
	self:setLocalZOrder(-1)
    self._btnTimeSelect:setSelected(false)
    self._btnToday:setSelected(false)
    self._btnYesterDay:setSelected(false)
end

-- 初始化排序UI
function UIBigLeagueManagerData:_initSort(leagueMembers)
	for index, data in ipairs(SORT_TYPE) do
		bindEventCallBack(self._checkBoxSort[data.name], function()
			self:_onClickButton(leagueMembers, data, true)
		end, ccui.TouchEventType.ended)
	end
end

function UIBigLeagueManagerData:_onClickButton(leagueMembers, data, isSort)
	-- 修改排序顺序 0 不排序  1为正序 2为倒序
	for k, v in ipairs(SORT_TYPE) do
		local img = seekNodeByName(self._checkBoxSort[v.name], "Image_img", "ccui.ImageView")
		if isSort then
			if v.name == data.name then
				v.sort =(v.sort + 1) % 2 == 0 and SORT_ORDER.inverted or SORT_ORDER.positive
			else
				v.sort = 0
			end
		end
		
		-- 排序
		if v.name == data.name then
			self:_setMemberSort(leagueMembers, v.name, v.sort)
		end
		-- 修改按钮图片显示信息
		img:loadTexture(string.format("club4/btn_fy%d.png", v.sort))
	end
	
end

--成员列表排序
function UIBigLeagueManagerData:_setMemberSort(leagueMembers, sortName, sortType)
	-- 团队人数排序
	if sortName == SORT_TYPE[1].name then
		leagueMembers = self:_tableSort(leagueMembers, "matchCount", sortType)
		--打牌人数排序
	elseif sortName == SORT_TYPE[2].name then
		leagueMembers = self:_tableSort(leagueMembers, "winCount", sortType)
		--贡献值排序
	elseif sortName == SORT_TYPE[3].name then
		leagueMembers = self:_tableSort(leagueMembers, "devoteClubFireScore", sortType)
	end
	-- 清空数据
	self._reusedListManager:deleteAllItems()
	
	for _, member in ipairs(leagueMembers) do
		self._reusedListManager:pushBackItem(member)
	end
	
	-- if #self._reusedListManager:getItemDatas() == 0 then
	-- 	game.ui.UIMessageTipsMgr.getInstance():showTips("该时间内成员无牌局")
	-- end
end

-- 排序函数
function UIBigLeagueManagerData:_tableSort(loaclTable, type, sortType)
	
	table.sort(loaclTable, function(a, b)
		-- 正序
		if sortType == SORT_ORDER.positive then
			return a[type] > b[type]
			-- 倒序
		elseif sortType == SORT_ORDER.inverted then
			return a[type] < b[type]
		end
	end)
	
	return loaclTable
end

--点击时间
function UIBigLeagueManagerData:_onClickSelectTime()
	UIManager:getInstance():show("UIBigLeagueDateSet", game.service.TimeService.getInstance():getStartTime(self._preDate), self)
	
end

--点击今日
function UIBigLeagueManagerData:_onClickToday()
	self:_setTime(0)	
end

--点击昨日
function UIBigLeagueManagerData:_onClickYesterDay()
	self:_setTime(1)	
end

--获取时间
function UIBigLeagueManagerData:_setTime(date)
	if self._preDate == date then
		return
	end
	self._preDate = date
	self:_sendQueryRequest()
end

--发送请求
function UIBigLeagueManagerData:_sendQueryRequest()
	if self._clubId == nil then 
		self._clubId = self._bigLeagueService:getLeagueData():getClubId()
	end 
	self._bigLeagueService:sendCCLQueryClubMemberActivityInfoREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
	self._clubId,
	game.service.TimeService:getInstance():getStartTime(self._preDate) * 1000)
	
end

function UIBigLeagueManagerData:_updateMemberList()
	--获取成员数据
	local members = self._bigLeagueService:getLeagueData():getLeagueManagerMemberData()
	self:_initSort(members)
	self:_updataActiveValue()
	self:_updateDateShow()
	self:setLocalZOrder(self._originZOrder)
	for k, v in ipairs(SORT_TYPE) do
		if v.sort ~= 0 then
			self:_onClickButton(members, v, false)
			return
		end
	end	
end

function UIBigLeagueManagerData:_updataActiveValue()
	local curryValue = self._bigLeagueService:getLeagueData():getLeagueManagerActiveValue()
	self._curryValue:setString('当日团队活跃值:' .. math.round(curryValue*100)/100)
	self._curryValue:setVisible(true)
end

-- 更新日期显示
function UIBigLeagueManagerData:_updateDateShow()
	local titleText = self._btnTimeSelect:getChildByName("BitmapFontLabel_startTime")
	local _date = game.service.TimeService:getInstance():getStartTime(self._preDate)
	titleText:setString(os.date("%m-%d", _date))
end 

--
function UIBigLeagueManagerData:_onClickClose()
	--下一次返回的时候为默认排序
	for i, data in ipairs(SORT_TYPE) do
		data.sort = i == 1 and 1 or 0
	end
	self:hideSelf()
end

function UIBigLeagueManagerData:onHide()
	self._bigLeagueService:removeEventListenersByTag(self)
end

return UIBigLeagueManagerData 