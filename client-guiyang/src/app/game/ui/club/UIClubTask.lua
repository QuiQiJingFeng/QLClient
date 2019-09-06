local csbPath = "ui/csb/Club/UIClubTask.csb"
local super = require("app.game.ui.UIBase")

--[[    亲友圈任务系统
]]
-- 亲友圈任务类型
local CLUB_TASK_TYPE =
{
	-- /** 牌局任务 */
	TASK_ROOM = 1,
	-- /** 成员任务 */
	TASK_MEMBER = 2,
	-- /** 充值任务 */
	TASK_CHARGE = 3,
	-- /** 牌局耗卡奖券任务 （抢iphonex） */
	TASK_ROOM_COST_LOTTERY = 4,
	-- /** 成员新增任务 （新增消耗奖励） */
	TASK_MEMBER_INCREASE = 5,
	-- /** 牌局耗卡任务 （打牌消耗奖励） */
	TASK_ROOM_COST = 6,
	-- /** 牌局耗卡红包任务 （春节消耗奉送） */
	TASK_ROOM_COST_RED_PACKET = 7,
	-- /** 牌局分数红包任务 （打牌大红包） */
	TASK_ROOM_SCORE_RED_PACKET = 8,
}

-- 亲友圈任务状态
local CLUB_TASK_STATUS =
{
	-- 已领取
	OBTAINED = 0,
	-- 未完成
	INCOMPLETED = 1,
	-- 已完成，可以领取
	COMPLETED = 2,
}

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemTaskItem = class("UIElemTaskItem")

function UIElemTaskItem.extend(self)
	local t = tolua.getpeer(self)
	if not t then
		t = {}
		tolua.setpeer(self, t)
	end
	setmetatable(t, UIElemTaskItem)
	self:_initialize()
	return self
end

function UIElemTaskItem:_initialize()
	self._btnReceive		= seekNodeByName(self, "Button_lq_t_1_Clubtask",			"ccui.Button")          -- 领取按钮
	self._btnText			= seekNodeByName(self, "BitmapFontLabel_5",			"ccui.TextBMFont")              -- 领取按钮上面的文字
	self._imgComplete		= seekNodeByName(self, "Image_ywc_1_Clubtask",			"ccui.ImageView")       -- 已完成的img
	self._imgComplete:setVisible(false)
	-- 奖励奖券的任务的item
	self._itemTask_Lottery = seekNodeByName(self, "Panel_new", "ccui.Layout")
	self._textTaskTitle = seekNodeByName(self, "Text_z_t_2_Clubtask", "ccui.Text") -- 任务标题
	self._textTaskRules = seekNodeByName(self, "Text_z0_t_2_Clubtask", "ccui.Text") -- 任务规则
	self._taskProgressIndicator = seekNodeByName(self, "BitmapFontLabel_4", "ccui.TextBMFont") -- 任务进度标识
	self._taskProgressBar = seekNodeByName(self, "LoadingBar_2", "ccui.LoadingBar") -- 任务进度条
	self._textTaskCompletionRate = seekNodeByName(self, "Text_z4_t_2_Clubtask_0", "ccui.Text") -- 任务完成进度
	self._imgProgressBar = seekNodeByName(self, "Image_5_1", "ccui.ImageView") -- 进度条背景
	self._imgManager = seekNodeByName(self, "Image_40", "ccui.ImageView") -- 群主标识
	self._imgPlayer = seekNodeByName(self, "Image_40_0", "ccui.ImageView") -- 玩家标识
	
	-- 奖励房卡的任务的item
	self._itemTask_RoomCard = seekNodeByName(self, "Panel_old", "ccui.Layout")
	self._itemTask_RoomCard:setVisible(false)
end

function UIElemTaskItem:setData(val)
	if self._data == val then
		return
	end
	
	self._data = val
	local callback = function()
		self:_onBtnReceiveClick(val.clubId, val.taskId, val.clientType)
	end
	
	if val.taskType == CLUB_TASK_TYPE.TASK_ROOM_COST_RED_PACKET then
		local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
		local clubId = localStorageClubInfo:getClubId()
		callback = function()
			local club = game.service.club.ClubService:getInstance():getClub(clubId)
			if club then
				club:mergeRedPacketChanged()
				-- self._particleRedPacket:setVisible(club:isRedPacketChanged())
			end
			UIManager:getInstance():show("UIClubRedBox", clubId)
		end
		self._btnText:setString("抢红包")
	else
		self._btnText:setString("领取")
	end
	
	bindEventCallBack(self._btnReceive, callback, ccui.TouchEventType.ended)
	
	self._textTaskTitle:setString(val.taskTitle)
	self._textTaskRules:setString(val.taskDescription)
	
	if val.taskType == CLUB_TASK_TYPE.TASK_ROOM_SCORE_RED_PACKET then
		self._taskProgressIndicator:setVisible(false)
		self._taskProgressBar:setVisible(false)
		self._imgProgressBar:setVisible(false)
	else
		self._taskProgressIndicator:setString(string.format("%d/%d", val.taskSchedule, val.taskCondition))
		self._taskProgressBar:setPercent(val.taskSchedule / val.taskCondition * 100)
		
	end
	
	self._imgManager:setVisible(val.clientType == "manager")
	self._imgPlayer:setVisible(val.clientType == "user")
	
	self._btnReceive:setEnabled(val.canGainTimes ~= 0 or val.taskType == CLUB_TASK_TYPE.TASK_ROOM_COST_RED_PACKET)
	
	if val.isAutoGain then
		self._btnReceive:setVisible(val.taskType == CLUB_TASK_TYPE.TASK_ROOM_COST_RED_PACKET)
		self._textTaskCompletionRate:setString(string.format("已完成:%d次", val.gainTimes))
	else
		self._textTaskCompletionRate:setString(string.format("可领取:%d次 已领取:%d次", val.canGainTimes, val.gainTimes))
	end
	
end

function UIElemTaskItem:_onBtnReceiveClick(clubId, taskId, clientType)
	game.service.club.ClubService.getInstance():getClubActivityService():sendCCLObtainTaskRewardREQ(clubId, taskId, clientType)
end


local UIClubTask = class("UIClubTask", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubTask:ctor()
	self._reusedListTasks		= nil   -- 任务的类型的list
	self._btnQuit				= nil   -- 返回
	self._tasks					= {}    -- 本地缓存任务列表
end

function UIClubTask:init()
	self._btnQuit = seekNodeByName(self, "Button_Close_Clubtask", "ccui.Button")
	self._reusedListTasks = UIItemReusedListView.extend(seekNodeByName(self, "ListView_1_Clubtask", "ccui.ListView"), UIElemTaskItem)
	-- 不显示滚动条
	self._reusedListTasks:setScrollBarEnabled(false)
	
	self:_registerCallBack()
end

-- 按钮的回调事件
function UIClubTask:_registerCallBack()
	bindEventCallBack(self._btnQuit,		handler(self, self._onBtnQuitClick),		ccui.TouchEventType.ended)
end

function UIClubTask:onShow(clubId)
	self._clubId = clubId
	
	local clubActivityService = game.service.club.ClubService.getInstance():getClubActivityService()
	-- 请求任务列表
	clubActivityService:sendCCLQueryClubTaskListREQ(clubId)
	
	clubActivityService:addEventListener("EVENT_CLUB_TASK",			handler(self, self._onClubTaskRetrived), self)
	clubActivityService:addEventListener("EVENT_CLUB_TASK_CHANGED",	handler(self, self._onClubTaskChanged), self)
	
	-- 服务器回复数据有可能慢，先把默认的清空
	self._reusedListTasks:deleteAllItems()
end

-- 获取任务列表
function UIClubTask:_onClubTaskRetrived(event)
	if event.clubId ~= self._clubId then
		return
	end
	
	local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
	
	self._tasks = club.task
	
	self:_initTaskTypeUI()
end

-- 更新任务列表
function UIClubTask:_onClubTaskChanged(event)
	if event.clubId ~= self._clubId then
		return
	end
	
	for i, taskType in pairs(self._tasks) do
		if taskType.taskId == event.taskInfo.taskId then
			self._tasks[i] = event.taskInfo
			self:_initTaskTypeUI()
			return
		end
	end
end

-- 初始化任务UI
function UIClubTask:_initTaskTypeUI()
	-- 先清空一下任务列表
	self._reusedListTasks:deleteAllItems()
	
	if #self._tasks <= 0 then
		return
	end
	
	for _, taskType in pairs(self._tasks) do
		taskType.clubId = self._clubId
		self._reusedListTasks:pushBackItem(taskType)
	end
end

function UIClubTask:_onBtnQuitClick()
	UIManager:getInstance():hide("UIClubTask")
end

function UIClubTask:onHide()
	-- 取消监听事件
	game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
	-- 清空列表
	self._reusedListTasks:deleteAllItems()
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubTask:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

function UIClubTask:needBlackMask()
	return true
end


return UIClubTask 