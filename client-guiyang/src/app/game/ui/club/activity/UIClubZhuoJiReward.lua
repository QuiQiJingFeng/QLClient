local csbPath = "ui/csb/Club/UIClubZhuoJi_MyReward.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIClubZhuoJiReward = class("UIClubZhuoJiReward", super, function() return kod.LoadCSBNode(csbPath) end)

--初始化list控件中的每个单元
local function initDetailList(listItem)
	listItem.round = ccui.Helper:seekNodeByName(listItem, "textRound")
	listItem.date = ccui.Helper:seekNodeByName(listItem, "textDate")
	listItem.reward = ccui.Helper:seekNodeByName(listItem, "textReward")
	listItem.LuckManager = ccui.Helper:seekNodeByName(listItem, "LuckManager")
	listItem.cost = ccui.Helper:seekNodeByName(listItem, "cost")
end

--给list中的控件赋值
local function setListData(listItem, value)
	local d = kod.util.Time.time2Date(value.winTime / 1000)
	local str = string.format("开奖时间:%d-%d %d:%02d", d.month, d.day, d.hour, d.min)
	listItem.date:setString(str)
	listItem.round:setString(string.format("第%d期", value.period))
	listItem.reward:setString(string.format(config.STRING.UICLUBZHUOJIREWARD_STRING_100, value.rewardNumber))
	listItem.LuckManager:setString(value.winnerName)
	listItem.cost:setString(string.format("%d张", value.costCard))
end

function UIClubZhuoJiReward:ctor()
	
end

function UIClubZhuoJiReward:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._tips = seekNodeByName(self, "Panel_tips", "ccui.Layout")
	--我的奖励列表
	self._listReward = ListFactory.get(seekNodeByName(self, "ListView_ZhuoJiReward", "ccui.ListView"),	initDetailList, setListData)
	self._listReward:setScrollBarEnabled(false)
	self:_registerCallBack()
end

function UIClubZhuoJiReward:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
end

function UIClubZhuoJiReward:needBlackMask()
	return true
end

function UIClubZhuoJiReward:onShow(...)
	local clubActivity = game.service.club.ClubService.getInstance():getClubActivityService()
	--监听 奖励获取后刷新界面并标记红点
	clubActivity:addEventListener("EVENT_TREASURE_REWARD_INFO_GET", handler(self, self._onRewardReceive), self)
	
	--监听红点相关信息变化
	clubActivity:addEventListener("EVENT_CLUB_ACTIVITY_TREASURE_VERSION_CHANGED", handler(self, self._onTreasureNumberChange), self)
	--请求奖励信息,收到回复后标记红点已读
	clubActivity:sendCCLTreasureRewardInfoREQ()
	self._listReward:deleteAllItems()
	
	self._tips:setVisible(false)
end


function UIClubZhuoJiReward:_onClose()
	
	UIManager.getInstance():hide("UIClubZhuoJiReward")
end

function UIClubZhuoJiReward:onHide()
	game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
	game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
end

--倒序排序
local function sort(array)
	local len = #array
	for i = 1, math.floor(len / 2) do
		local rand = len - i + 1
		local temp = array[rand]
		array[rand] = array[i]
		array[i] = temp
	end
	
end

--受到奖励信息时刷新奖励表,并记录红点已读取消红点显示
function UIClubZhuoJiReward:_onRewardReceive(event)
	self._listReward:deleteAllItems()
	
	sort(event.protocol.rewards)
	
	for _, v in ipairs(event.protocol.rewards) do
		self._listReward:pushBackItem(v)
	end
	
	self._tips:setVisible(#event.protocol.rewards == 0)
	
	local activityService = game.service.club.ClubService.getInstance():getClubActivityService()
	local cache = game.service.club.ClubService.getInstance():getClubActivityService():getActivityCache()
	
	cache:setTreasureRead()
	activityService:saveLocalStorage()
	
end

--收到奖品信息改变时请求新的奖励
function UIClubZhuoJiReward:_onTreasureNumberChange()
	game.service.club.ClubService.getInstance():getClubActivityService():sendCCLTreasureRewardInfoREQ()
end



return UIClubZhuoJiReward 
