--[[
--玩家打牌操作基类
--]]
local CommandCenter = require("app.manager.CommandCenter")
local Time = kod.util.Time

local Processor = class(Processor)

function Processor:ctor()
	-- 监听操作事件
	gameMode.mahjong.Context.getInstance():getGameService():addEventListener("PROC_STEP", function(event)
		self:_processStep(event.isRecover, event.stepGroup)
	end, self)
	self._nextIdleTime = Time.now()
end

function Processor:dispose()
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	if gameService then
		gameService:removeEventListenersByTag(self)
	end
end

-- 处理step
-- @param isRecover: boolean
-- @param stepGroup: PlayStep[]
-- @return void
function Processor:_processStep(isRecover, stepGroup)
	-- 基本打牌逻辑处理
    local firstStep = stepGroup[1];
    
    -- 忽略掉非自己的消息
    if not self:_checkSelf(firstStep) then
        return
    end

	local time = CommandCenter.getInstance():executeCommand(firstStep:getPlayType(), {isRecover, stepGroup, self})
	return time or -1
end

-- 检查这条step是否应该有自己处理
function Processor:_checkSelf( step )
	Macro.assertFalse(false, 'must override by subclass')
end

function Processor:getNextIdleTime()
	return self._nextIdleTime
end

--[[
	调整  processor 空闲实现， 可以为负数来减少时间
	GameServier 获取 idleTime 时， 会根据当前socket时间进行定时执行
]]
function Processor:addNextIdleTime(elapse)
	self._nextIdleTime = Time.now() + elapse
end
return Processor