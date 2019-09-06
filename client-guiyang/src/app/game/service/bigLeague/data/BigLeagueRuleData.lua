local BigLeagueRuleData = class("BigLeagueRuleData")
local RoomSetting = config.GlobalConfig.getRoomSetting()

local LastRoomSettings = class("CreateRoomSettings")
function LastRoomSettings:ctor()
    self._id = 0
    self._modifyTime = 0
end

function BigLeagueRuleData:ctor()
    self:init()
end

function BigLeagueRuleData:init() 
    self._gameRules = {}   --玩家信息
    self._maxGameplayRegion = 0 --盟主可以设置最多区间数
    self._gameplayStatistics = {}  --玩法统计

    self._lastCreateRoomSettings = nil
end
--[[玩法相关
    message LeagueGameplayPROTO                     // 大联盟玩法详细设定
    {
        optional int64 id = 1;                    // 玩法序号（创建玩法的时间戳）
        optional string name = 2;                   // 玩法名称
        optional int32 joinThreshold = 3;           // 入场赛事分数门槛
        optional float scoreCoefficient = 4;        // 赛事分系数
        optional int32 winnerThreshold = 5;         // 大赢家分数门槛
        optional int32 lotteryCost = 6;             // 抽奖消耗分数
        optional int32 lotteryMin = 7;              // 奖品最小值
        optional int32 lotteryMax = 8;              // 奖品最大值
        required int32 roomType = 9;			    // 房间类型
        required int32 roundType = 10;			    // 房间圈/局规则
        repeated int32 gameplays = 11;              // 房间玩法
    }
]]--

function BigLeagueRuleData:setGameRules(proto)
    -- 删除实时语音玩法显示
    local voiceOpenType = RoomSetting.GamePlay.COMMON_VOICE_OPEN
    for _, gameplays in ipairs(proto.gameplays) do
        for i, rule in ipairs(gameplays.gameplays) do
            if rule == voiceOpenType then
                table.remove(gameplays.gameplays, i)
                break
            end
        end
    end

    self._gameRules = proto.gameplays
    self._maxGameplayRegion  = proto.maxGameplayRegion 
end

--获取最大抽奖区间个数
function BigLeagueRuleData:getmaxGameplayRegion()
    return  self._maxGameplayRegion
end

function BigLeagueRuleData:getGameRules()
    -- 按照玩法创建时间排序
    table.sort(self._gameRules, function (a, b)
        if a.modifyTime > b.modifyTime then
            return true
        end
    end)
    return self._gameRules
end

function BigLeagueRuleData:getGameRule(id)
    for i, gameRule in ipairs(self._gameRules) do
        if gameRule.id == id then
            return gameRule
        end
    end

    return nil
end

--修改一条玩法
function BigLeagueRuleData:changeOneRule(id, rule)
    local isAdd = false
    for i, gameRule in ipairs(self._gameRules) do
        if gameRule.id == id then
            gameRule = rule
            isAdd = true
        end
    end

    if isAdd == false then
        rule.id = id
        self._gameRules[#self._gameRules + 1] = rule
    end
end
--删除一条玩法
function BigLeagueRuleData:deleteOneRule(id)
    for i, gameRule in ipairs(self._gameRules) do
        if gameRule.id == id then
            table.remove(self._gameRules, i)
            return
        end
    end
end

function BigLeagueRuleData:saveLocalStorage()
    local roldId = game.service.LocalPlayerService:getInstance():getRoleId();
    manager.LocalStorage.setUserData(roldId, "LastBigLeagueRoomSettings", self._lastCreateRoomSettings)
end

function BigLeagueRuleData:setLastCreateRoomSettings(id, time)
    self._lastCreateRoomSettings._id = id
    self._lastCreateRoomSettings._modifyTime = time
    -- dump(self._lastCreateRoomSettings, "setLastCreateRoomSettings~~~~")
    self:saveLocalStorage();
end


function BigLeagueRuleData:loadLocalStorage()
    -- 设置本地规则为房间规则
    local roldId = game.service.LocalPlayerService:getInstance():getRoleId();
    self._lastCreateRoomSettings = manager.LocalStorage.getUserData(roldId, "LastBigLeagueRoomSettings", LastRoomSettings)
end

function BigLeagueRuleData:getLastSelectIndex()
    self:loadLocalStorage()
    for idx, info in ipairs(self._gameRules) do
        if info.id == self._lastCreateRoomSettings._id and info.modifyTime == self._lastCreateRoomSettings._modifyTime then
            return idx
        end
    end
    return 1
end

--玩法统计
function BigLeagueRuleData:setGamePlayStatistic(proto)
    local tabGamePlay = proto.gameplayStatistics
    --把日期加进去 保存玩法的时候用于发送时间
    for _,gameplay in ipairs(tabGamePlay) do 
        gameplay.date = proto.date
    end 
    self._gameplayStatistics = tabGamePlay

end

function BigLeagueRuleData:getGamePlayStatistic()
    return self._gameplayStatistics
   
end


return BigLeagueRuleData