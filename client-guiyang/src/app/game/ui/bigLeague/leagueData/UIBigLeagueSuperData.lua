local csbPath = "ui/csb/BigLeague/UIBigLeagueSuperData.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIBigLeagueSuperData = class("UIBigLeagueSuperData", super, function() return kod.LoadCSBNode(csbPath) end)

--排序
local SORT_ORDER =
{
	positive = 1, -- 正序
	inverted = 2, -- 倒序
}


--需要排序的类型 默认不排序
local SORT_TYPE =
{
{name = "Team_PlayNumber", sort = 1}, --团队人数
{name = "PlayerCard_Number", sort = 0}, --打牌人数
{name = "Contribution_Value", sort = 0},--贡献活跃值
{name = "Team_AvtiveValue", sort = 0},--团队活跃值
}

function UIBigLeagueSuperData:ctor()
	
end

function UIBigLeagueSuperData:init()
	
	self._checkBoxSort = {}
	
	self._reusedListManager = ListFactory.get(
	seekNodeByName(self, "ListView_League_SuperData", "ccui.ListView"),
	handler(self, self._onListViewInit),
	handler(self, self._onListViewSetData)
	)
	-- 不显示滚动条, 无法在编辑器设置
	self._reusedListManager:setScrollBarEnabled(false)
	self._btnTimeSelect = seekNodeByName(self, "CheckBox_Date", "ccui.CheckBox") -- 选择时间
	self._leagueFireScore = seekNodeByName(self, "Text_CurryValue", "ccui.TextBMFont")
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭

	self._btnToday = seekNodeByName(self, "CheckBox_Today", "ccui.CheckBox") -- 今日数据
	self._btnYesterDay = seekNodeByName(self, "CheckBox_Yesterday", "ccui.CheckBox") -- 昨日数据
	
	local topPanel = seekNodeByName(self, "Panel_top_Clubpj", "ccui.Layout")
	local panelSize = topPanel:getContentSize()
	topPanel:getChildByName("Image_2"):setPositionX(panelSize.width)

    local tbChkBox = {self._btnTimeSelect, self._btnToday, self._btnYesterDay}
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


function UIBigLeagueSuperData:_onListViewInit(listItem)
	
	listItem._textLeagueName = seekNodeByName(listItem, "Text_LeagueName", "ccui.Text") -- 团队名称
	listItem._textLeagueId = seekNodeByName(listItem, "Text_LeagueID", "ccui.Text") -- 团队id
	listItem._textCaptainName = seekNodeByName(listItem, "Text_CaptainName", "ccui.Text") -- 队长名字
	listItem._textCaptainId = seekNodeByName(listItem, "Text_Captain_Id", "ccui.Text") -- 队长id
	listItem._textTeamNumber = seekNodeByName(listItem, "Text_TeamNumber", "ccui.Text") -- 团队人数
	listItem._textPlayerCount = seekNodeByName(listItem, "Text_Player_Count", "ccui.Text") -- 打牌人数
	listItem._textContributionValue = seekNodeByName(listItem, "Text_ContributionValue", "ccui.Text") --贡献活跃值
	listItem._textActiveValue = seekNodeByName(listItem, "Text_ActiveValue", "ccui.Text") --团队活跃值
	listItem._btnDetalis = seekNodeByName(listItem, "Button_Details", "ccui.Button") -- 在线状态
end

function UIBigLeagueSuperData:_onListViewSetData(listItem, val)
	local name = game.service.club.ClubService.getInstance():getInterceptString(val.clubName, 8)
	local captainName = game.service.club.ClubService.getInstance():getInterceptString(val.managerName, 8)
	listItem._textLeagueName:setString(name)
	listItem._textLeagueId:setString(val.clubId)
	listItem._textCaptainName:setString(captainName)
	listItem._textCaptainId:setString(val.managerId)
	listItem._textTeamNumber:setString(val.clubMemberCount)
	listItem._textPlayerCount:setString(val.playMemberCount)
	listItem._textContributionValue:setString(math.round(val.devoteLeagueFireScore*100)/100)
	listItem._textActiveValue:setString(math.round(val.clubFireScore*100)/100)
	
	--点击详情
	bindEventCallBack(listItem._btnDetalis, function()
		UIManager:getInstance():show("UIBigLeagueManagerData",val.clubId,self._searchTime)
	end, ccui.TouchEventType.ended)
	
	
end

function UIBigLeagueSuperData:onShow(searchTime)
    self._btnTimeSelect:setSelected(false)
    self._btnToday:setSelected(false)
    self._btnYesterDay:setSelected(false)
	--当前时间
	--self._curDate = 0
	self._searchTime = searchTime
	local now = game.service.TimeService.getInstance():getCurrentTime()
	local deltTime = now - self._searchTime/1000
	local num = math.floor(deltTime / (24 * 3600))
	self._preDate = num

	self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
	self._bigLeagueService:sendCCLQueryLeagueClubActivityInfoREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
	self._bigLeagueService:getLeagueData():getClubId(),self._searchTime)
	self._bigLeagueService:addEventListener("EVENT_SUPERLEAGUE_DATA", handler(self, self._updateMemberList), self)
	self._originZOrder = self:getLocalZOrder()
	self:setLocalZOrder(-1)

	

end

-- 初始化排序UI
function UIBigLeagueSuperData:_initSort(leagueMembers)
	for index, data in ipairs(SORT_TYPE) do
		bindEventCallBack(self._checkBoxSort[data.name], function()
			self:_onClickButton(leagueMembers, data, true)
		end, ccui.TouchEventType.ended)
	end
end

function UIBigLeagueSuperData:_onClickButton(leagueMembers, data, isSort)
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
function UIBigLeagueSuperData:_setMemberSort(leagueMembers, sortName, sortType)
	-- 团队人数排序
	if sortName == SORT_TYPE[1].name then
		leagueMembers = self:_tableSort(leagueMembers, "clubMemberCount", sortType)
		--打牌人数排序
	elseif sortName == SORT_TYPE[2].name then
		leagueMembers = self:_tableSort(leagueMembers, "playMemberCount", sortType)
		--贡献值排序
	elseif sortName == SORT_TYPE[3].name then
		leagueMembers = self:_tableSort(leagueMembers, "devoteLeagueFireScore", sortType)
		--团队活跃值排序
	elseif sortName == SORT_TYPE[4].name then
		leagueMembers = self:_tableSort(leagueMembers, "clubFireScore", sortType)
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
function UIBigLeagueSuperData:_tableSort(loaclTable, type, sortType)
	
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
function UIBigLeagueSuperData:_onClickSelectTime()
	UIManager:getInstance():show("UIBigLeagueDateSet", game.service.TimeService.getInstance():getStartTime(self._preDate), self)
	
end 

--点击今日
function UIBigLeagueSuperData:_onClickToday()
	self:_setTime(0)
	self._searchTime = game.service.TimeService:getInstance():getStartTime(0) * 1000
end

--点击昨日
function UIBigLeagueSuperData:_onClickYesterDay()
	self:_setTime(1)
	self._searchTime = game.service.TimeService:getInstance():getStartTime(1) * 1000
end

--获取时间
function UIBigLeagueSuperData:_setTime(date)
	if self._preDate == date then
		return
	end
	
	--self._curDate = date
	self._preDate = date
	self:_sendQueryRequest()
end

--发送请求
function UIBigLeagueSuperData:_sendQueryRequest()  
	self._bigLeagueService:sendCCLQueryLeagueClubActivityInfoREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
	self._bigLeagueService:getLeagueData():getClubId(),game.service.TimeService:getInstance():getStartTime(self._preDate) * 1000)
	
end

function UIBigLeagueSuperData:_updateMemberList()
	--获取成员数据
	local leagueMembers = self._bigLeagueService:getLeagueData():getSuperLeagueData()
	self:_initSort(leagueMembers)
	self:_updataActiveValue()
	self:_updateDateShow()
	self:setLocalZOrder(self._originZOrder)
	
	for k, v in ipairs(SORT_TYPE) do
		if v.sort ~= 0 then
			self:_onClickButton(leagueMembers, v, false)
			return
		end
	end
	
end

function UIBigLeagueSuperData:_updataActiveValue()
	local leagueFireScore = self._bigLeagueService:getLeagueData():getSuperLeagueActiveValue()
	self._leagueFireScore:setString('当日赛事活跃值:' .. math.round(leagueFireScore*100)/100)
end

-- 更新日期显示
function UIBigLeagueSuperData:_updateDateShow()
	local titleText = self._btnTimeSelect:getChildByName("BitmapFontLabel_startTime")
	local _date = game.service.TimeService:getInstance():getStartTime(self._preDate)
	titleText:setString(os.date("%m-%d", _date))
end 


function UIBigLeagueSuperData:_onClickClose()
	--下一次返回的时候为默认排序
	for i, data in ipairs(SORT_TYPE) do
		data.sort = i == 1 and 1 or 0
	end
	self:hideSelf()
end


function UIBigLeagueSuperData:onHide()
	self._bigLeagueService:removeEventListenersByTag(self)
end

return UIBigLeagueSuperData 