

local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local csbPath = "ui/csb/Gamble/UIGambleHistory.csb"

local UIGambleHistory = class("UIGambleHistory", super, function() return cc.CSLoader:createNode(csbPath) end)

local stakeTeamType = net.protocol.stakeTeamType
local betStatus = net.protocol.betStatus
--初始化列表子空间
local function initDetailList(self)
	
	-- 队伍名称
	self.textNameHome = seekNodeByName(self, "textNameHome", "ccui.Text")
	self.textNameAway = seekNodeByName(self, "textNameAway", "ccui.Text")
	--队伍图标
	self.imgHome = seekNodeByName(self, "imgHome", "ccui.ImageView")
	self.imgAway = seekNodeByName(self, "imgAway", "ccui.ImageView")
	--赔率信息
	self.textOddsInfo = seekNodeByName(self, "textOddsInfo", "ccui.Text")
	--投注信息
	self.textCapital = seekNodeByName(self, "textCapital", "ccui.Text")
	--比赛部分
	self.textMatchName = seekNodeByName(self, "textMatchName", "ccui.Text")
	self.textMatchState = seekNodeByName(self, "textMatchState", "ccui.Text")
	--回报部分
	self.textWinAward = seekNodeByName(self, "textWinAward", "ccui.Text")
	--状态部分
	self.flags = {
		[betStatus.canReceive] = seekNodeByName(self, "btnDraw", "ccui.Button"),
		[betStatus.yes] = seekNodeByName(self, "imgWin", "ccui.ImageView"),
		[betStatus.no] = seekNodeByName(self, "imgLose", "ccui.ImageView"),
		[betStatus.wait] = seekNodeByName(self, "imgWait", "ccui.ImageView"),
		[betStatus.huang] = seekNodeByName(self, "imgHuang", "ccui.ImageView"),
		[betStatus.dealing] = seekNodeByName(self, "imgDealing", "ccui.ImageView"),
	}
end

--显示比赛时间的逻辑
local function changeTimeToShow(gameTime, status)
	local currentTime = game.service.TimeService:getInstance():getCurrentTime()
	local diff = gameTime - currentTime
	if status~= betStatus.wait then
		return "已结束"
	elseif diff < 0 then
		return "已开赛"
	elseif diff < 60 * 5 then
		return "即将开赛"
	elseif diff < 60 * 60 then
		return math.floor(diff / 60) .. "分钟后"
	elseif diff < 3600 * 5 then
		return math.floor(diff / 3600) .. "小时后"
	else
		local date = os.date("*t", gameTime)
		return string.format("%02d:%02d", date.hour, date.min)
	end
end

--为列表子控件赋值
local function setListData(self, data)
	local value = data.value
	
	self.textNameHome:setString(value.game.homeTeam)
	game.util.PlayerHeadIconUtil.setIcon(self.imgHome, value.game.homeIcon, "WORLD_CUP")
	
	self.textNameAway:setString(value.game.visitingTeam)
	game.util.PlayerHeadIconUtil.setIcon(self.imgAway, value.game.visitingIcon, "WORLD_CUP")
	
	self.textMatchName:setString(value.game.name)
	self.textMatchState:setString(changeTimeToShow(value.game.time / 1000, value.status))
	
	--赔率信息
	local oddInfo = ''
	if value.team == stakeTeamType.home then
		oddInfo = "主胜:"
	elseif value.team == stakeTeamType.away then
		oddInfo = "客胜:"
	else
		oddInfo = "平  : "
	end
	oddInfo = oddInfo .. value.odds
	
	self.textOddsInfo:setString(oddInfo)
	--投注信息
	self.textCapital:setString("投注:" .. kod.util.String.formatMoney(value.money, 2))
	
	--回报部分
	self.textWinAward:setString("猜中得: " .. kod.util.String.formatMoney(value.canEarn, 2))
	--按钮部分
	for k, v in pairs(self.flags) do
		v:setVisible(false)
	end
	self.flags[value.status]:setVisible(true)
	bindEventCallBack(self.flags[betStatus.canReceive], function()
		game.service.GambleService.getInstance():sendCGQueryReceiveREQ(value.id, value.odds, data.index)
	end, ccui.TouchEventType.ended);
end


function UIGambleHistory:ctor()
	
end

function UIGambleHistory:init()
	-- 我的竞彩列表
	self._listGamble = ListFactory.get(seekNodeByName(self, "listGamble", "ccui.ListView"), initDetailList, setListData)
	
	-- 没有数据时的提示
	self._textNone = seekNodeByName(self, "textNone", "ccui.Text")

	self._listGamble:setScrollBarEnabled(false)
end

function UIGambleHistory:show()
	self:setVisible(true)
	self._listGamble:jumpToTop()
	local GambleService = game.service.GambleService.getInstance()
	--监听获得个人押注信息事件
	GambleService:addEventListener("EVENT_PLAYER_GAMBLE_RECEIVE", handler(self, self._onGameStakeInfoReceive), self)
	--监听领取奖励的事件
	GambleService:addEventListener("EVENT_PLAYER_GAMBLE_REWARD_GET", handler(self, self._onGambleRewardget), self)
	-- 监听是否有新的奖励可领取
	GambleService:addEventListener("EVENT_NEW_GAMBLE_REWARD_CAN_GET", function ( ... )
		GambleService:sendCGQueryPlayerBetsREQ()
	end, self)
	
	GambleService:sendCGQueryPlayerBetsREQ()
	
	self._textNone:getParent():setVisible(self._listGamble:getChildrenCount() == 0)
end

function UIGambleHistory:hide()
	self:setVisible(false)
	local GambleService = game.service.GambleService.getInstance()
	GambleService:removeEventListenersByTag(self)
	
end

--收到竞彩协议时的处理
function UIGambleHistory:_onGameStakeInfoReceive(event)
	self._listGamble:deleteAllItems()
	
	local betStatusWeight = {
		[betStatus.canReceive] = 1,
		[betStatus.yes] = 4,
		[betStatus.no] = 4,
		[betStatus.wait] = 2,
		[betStatus.huang] = 4,
		[betStatus.dealing] = 3,
	}
	
	-- 自己的竞彩排序先按状态排序再按比赛时间
	table.sort(event.protocol.playerBets, function(l, r)
		if betStatusWeight[l.status] ~= betStatusWeight[r.status] then
			return betStatusWeight[l.status] < betStatusWeight[r.status]
		elseif betStatusWeight[l.status] <= 2 then
			return l.game.time < r.game.time
		else
			return l.game.time > r.game.time
		end
	end)
	
	
	for k, v in ipairs(event.protocol.playerBets) do
		self._listGamble:pushBackItem({value = v, index = k})
	end
	
	self._textNone:getParent():setVisible(self._listGamble:getChildrenCount() == 0)
end

function UIGambleHistory:_onGambleRewardget(event)
	local data = self._listGamble:getItemDatas() [event.index]
	if data then
		local newData = {value = data.value, index = event.index}
		newData.value.status = betStatus.yes
		self._listGamble:updateItem(event.index, newData)
	end
end


return UIGambleHistory 