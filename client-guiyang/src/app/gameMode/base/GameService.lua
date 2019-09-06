--[[
    GameService 所有游戏的GameService的父类

    todo:会将麻将扎金花等游戏通用的部分提取出来，放到这里

        目前暂时不实现
]]
local Time = kod.util.Time
local GameService = class("GameService")

function GameService:ctor()
	      
	self._playerProcessors = {}         -- 每个player的processor, addPlayer的时候会往里添加对应的processor
    self._stepSequencer = {}            -- step执行队列
    self._processStepTask = nil         -- step执行任务
    self._gameScene = nil
	self._seatFlag = {}
	self._roomProcessor = nil -- 由子类创建
end

function GameService:initialize(gameScene)
    cc.bind(self, "event")
	self._gameScene = gameScene
end

function GameService:dispose()
	self:_cancelProcessStepTask()
	self._stepSequencer = {}
	cc.unbind(self, "event")
end

--[[
    @desc: 添加一个player
    author:{author}
    time:2018-01-11 17:20:33
    --@player: 
    return
]]
function GameService:addPlayer( player )
    -- 1.获取player.pos
    local pos = player.position
    -- 2.转换pos到客户端位置(我永远在下面)
	local cPos = self:_convertServerPos(pos)
	player.cPosition = cPos
    -- 3.添加ui
    local playerUIObj = self._gameScene:addPlayer(player, cPos)
    -- 4.创建playerProcessor
    local processor = self:_createPlayerProcessor(cPos, player, playerUIObj)
    -- 5.加入_playerProcessors
    local roleId = player.roleId
    self._playerProcessors[roleId] = processor
end

-- 删除所有player
function GameService:removeAllPlayers()
    
	-- 1.释放所有processor
    for _, processor in pairs(self._playerProcessors) do
        processor:dispose()
	end

	-- 2、删除所有玩家
    self._gameScene:removeAllPlayers()

    self._playerProcessors = {}
end

--[[
    @desc: 删除某个player
    author:{author}
    time:2018-01-11 17:20:51
    --@player: 玩家数据
    --@cPos: client 位置
    return
]]
function GameService:removePlayer(player, cPos)
	-- 1.删除ui
	self._gameScene:removePlayer(cPos)
	-- 2.删除processor
	local processors = self._playerProcessors[player.roleId]
	processors:dispose()
	self._playerProcessors[player.roleId] = nil
end

--[[
    @desc: update某个player
    author:{author}
    time:2018-01-11 17:25:16
    --@player: 玩家数据
    --@cPos: client 位置
    return
]]
function GameService:updatePlayer(player, cPos)
	-- 1.更新ui
	self._gameScene:updatePlayer(player, cPos)
	-- 2.更新processor
	local processors = self._playerProcessors[player.roleId]
	processors:updatePlayerInfo(player)
end

-- 服务器的位置转换到客户端，由各个游戏自己具体实现
function GameService:_convertServerPos( pos )
    Macro.assertFalse(false, "your must override the function")
end

-- 根据客户端位置和玩家数据生成玩家processor，由各个游戏自己具体实现
function GameService:_createPlayerProcessor( pos, player, playerUIObj )
    Macro.assertFalse(false, "your must override the function")
end

function GameService:getPlayerProcessorByPlayerId( roleId )
	local ret = self._playerProcessors[roleId]
    return ret
end

function GameService:getAllPlayerProcessor()
	return self._playerProcessors
end

-- 处理当前缓存的操作
-- @param isRecover: boolean, 当前是否是复牌模式
function GameService:_processStep(isRecover)
	if self._processStepTask ~= nil then
		Macro.assertFalse(isRecover == false)
		-- 有正在等待的处理, 不用执行
		return
	end

	while #self._stepSequencer ~= 0	do
		-- 获取下一个要执行的Step
		local stepGroup = self._stepSequencer[1]
		table.remove(self._stepSequencer, 1)

		local roleId = stepGroup[1]:getRoleId() -- roleId == -1 表示基于房间的操作
		local playerProcessor = roleId == -1 and nil or self:getPlayerProcessorByPlayerId(roleId)

		if isRecover == true then
			-- 复牌不需要等待

			-- 交给相应的处理器
			if playerProcessor == nil then
				self._roomProcessor:processStep(isRecover, stepGroup)
			else
				playerProcessor:processStep(isRecover, stepGroup)
			end
		else
			-- 正常处理过程

			-- 这里应该是可以处理状态
			local checkTime = self._roomProcessor:getNextIdleTime();
			checkTime = playerProcessor == nil and checkTime or math.max(checkTime, playerProcessor:getNextIdleTime())
			-- Macro.assertFalse(Time.now() >= checkTime)
				-- 派发操作处理事件
			local event = {name = "PROC_STEP", isRecover = isRecover, stepGroup = stepGroup}
			self:dispatchEvent(event);

			-- 检查是否可以继续处理
			local nextIdleTime = self._roomProcessor:getNextIdleTime();
			nextIdleTime = playerProcessor == nil and nextIdleTime or math.max(nextIdleTime, playerProcessor:getNextIdleTime())
			if Time.now() < nextIdleTime then
				-- 当前还不能继续操作, 计划下次更新
				self:_scheduleProcessStepTask(isRecover, nextIdleTime - Time.now())
				return;
			end
		end
	end
end

-- 规划下一次处理step的任务
function GameService:_scheduleProcessStepTask(isRecover, nextTime)
	Macro.assertFalse(self._processStepTask == nil);

	self._processStepTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		-- 取消当前任务
		self:_cancelProcessStepTask();
		-- 处理操作
		self:_processStep(isRecover);
	end, nextTime, false);
end

-- 取消step处理任务
function GameService:_cancelProcessStepTask()
	if self._processStepTask ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._processStepTask)
		self._processStepTask = nil
	end
end

function GameService:isInReplay()
	Macro.assertFalse(false, 'the function implement by subclass')
end

function GameService:getMaxPlayerCount()
	local service = game.service.RoomService:getInstance()
	if service then
		return service:getMaxPlayerCount()
	else
		Macro.assertFalse(false , 'roomService is nil')
	end
end

return GameService