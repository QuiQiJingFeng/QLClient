local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local RobotComponent = class("RobotComponent")
local ROBOT_WAIT_TIME = 0.8

-- 机器人打牌组件类 author heyi

function RobotComponent:ctor(parent,player)
    self._processor = player

    self._robotCanDiscardFlag = false	-- 是否能自动出牌，自动出牌/胡牌需要接到discardable后才能出
    self._isWorking = false     -- 机器人当前是否有工作正在做，如果是则先加入队列
    
    self._schedule = nil
    self._robotTaskQueue = {}
end


-- 机器人操作
function RobotComponent:_robotProcessStep( isRecover, firstStep)
	if firstStep:getPlayType() == PlayType.OPERATE_CAN_CHI_A_CARD 
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_PENG_A_CARD  then
        self:addWork(function()
            self._processor:_sendPlayStep(PlayType.OPERATE_PASS , {})
        end)
        return true
    elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_GANG_A_CARD then
        self._processor:getPlayerFsm():enterState("PlayerState_Normal")
        return false
    elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_AN_GANG 
    or firstStep:getPlayType() == PlayType.OPERATE_CAN_BU_GANG_A_CARD then
        self._processor:getPlayerFsm():enterState("PlayerState_Normal")
        game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})	
	elseif firstStep:getPlayType() == PlayType.OPERATE_DEAL then
		self._processor:_onDrawCard(firstStep._cards[1])
		self._robotCanDiscardFlag = true
		return true
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_PLAY_A_CARD  then
		-- 可打牌
		Macro.assetFalse(isRecover == false)
		self._processor:_onDiscardable(PlayType.OPERATE_PLAY_A_CARD, firstStep._cards);
        if self._robotCanDiscardFlag == true then
            self:addWork(function()
                self._processor:discardCard(self._processor._cardList.lastDrewCard, true)
            end)
			self._robotCanDiscardFlag = false
			return true
		end
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_HU then
        self._processor:_sendPlayStep(PlayType.OPERATE_HU , firstStep:getCards())
        self:reset()
		return true
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_PASS then
		return true
	end
	return false
end

-- 机器人所做的一切操作都要延时进行，如果期间取消了自动，则需要清空这些操作并取消
function RobotComponent:_excuteRobotTask()
	local firstStep = self._robotTaskQueue[1];
    if firstStep == nil then
        self._isWorking = false
		return
    else
        self._isWorking = true
        self._robotTaskQueue[1]()
        table.remove(self._robotTaskQueue,1)
        unscheduleOnce(self._schedule)
		self._schedule = scheduleOnce(function ()
			self:_excuteRobotTask()
		end,ROBOT_WAIT_TIME)
	end
end

-- 给机器人加活
function RobotComponent:addWork(work)
    if self._isWorking then
        table.insert(self._robotTaskQueue,work)
    else
        table.insert(self._robotTaskQueue,work)
        unscheduleOnce(self._schedule)
        self._schedule = scheduleOnce(function ()
			self:_excuteRobotTask()
		end,ROBOT_WAIT_TIME)
    end
end

-- 如果自动的时候，是属于出牌的状态，且task是空的，加一个出牌的任务
function RobotComponent:onStartAutoStatus()
    if self._processor._discardCardOperation == PlayType.OPERATE_PLAY_A_CARD and
        self._robotTaskQueue[1] == nil then
            self:addWork(self._processor:discardCard(self._processor._cardList.lastDrewCard, true))
    end
end

function RobotComponent:reset()
    self:stopActionAndClean()
    self._robotCanDiscardFlag = false
    self._isWorking = false
end

-- 停止执行队列，并清空所有队列任务
function RobotComponent:stopActionAndClean()
    unscheduleOnce(self._schedule)
    self._schedule = nil
    self._robotTaskQueue = {}
end

return RobotComponent