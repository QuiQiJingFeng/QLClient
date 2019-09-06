local BigLeagueData = class("BigLeagueData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local RankData = require("app.game.service.bigLeague.data.BigLeagueRankData")
local RoomData = require("app.game.service.bigLeague.data.BigLeagueRoomData")
local MemberData = require("app.game.service.bigLeague.data.BigLeagueMemberData")
local RuleData = require("app.game.service.bigLeague.data.BigLeagueRuleData")
local ScoreData = require("app.game.service.bigLeague.data.BigLeagueScoreData")
local SuperLeagueData = require("app.game.service.bigLeague.data.BigLeagueSuperLeagueData")
local LeagueManagerData = require("app.game.service.bigLeague.data.BigLeagueLeagueManagerData")
local LeagueFireScoreData = require("app.game.service.bigLeague.data.BigLeagueFireScoresData")
local GamePlayData = require("app.game.service.bigLeague.data.BigLeagueLocalGamePlayData")
-- 大联盟中俱乐部的状态
local LeagueClubStatus =
{
    NORMAL = 1, -- 正常
    PAUSE = 2, -- 暂停
}

-- 请求成员类型
local MemberType =
{
    MEMBER = 1, -- 成员
    PARTNER = 2, -- 搭档
    MEMBER_PARTNER = 3, -- 搭档成员
}

local ModifyMemberScoreType =
{
    ORDER = 1, -- 指派出战
    FORCE_QUIT = 2, -- 强制退赛
    MODIFY = 3, -- 调整分数
}

function BigLeagueData:getModifyMemberScoreType()
    return ModifyMemberScoreType
end

function BigLeagueData:getMemberType()
    return MemberType
end

function BigLeagueData:getLeagueClubStatus()
    return LeagueClubStatus
end

function BigLeagueData:ctor()
    self:init()
end

function BigLeagueData:init()
    self._leagueId = 0         --联盟Id
    self._leagueName = ""       -- 联盟昵称
    self._cardNum = 0          --联盟房卡数
    self._goldNum = 0          --联盟金币数
    self._teamScore = 0      -- 俱乐部当前赛事分
    self._myScore = 0           -- 我的赛事分
    self._clubId = 0            -- 俱乐部Id
    self._leaderId = 0          -- 盟主id
    self._isRoomOpening = 0     -- 是否房间已开局
    self._title = 0             -- 职位
    self._fireScore = 0         -- 活跃值
    self._partnerNumber = 0 -- 搭档个数
    self._partnerId = 0

    self._currentScore = 0 -- 俱乐部当前比赛分

    self._haveApproval = false -- 是否有未处理的审批

    self._lotteryGold = -1 -- 抽奖金币

    -- self._gameRules = {}    --玩法
    
    self._leaguesInfo = {}  --大联盟中的各俱乐部（联盟）信息列表

    self._trendInfo = {}     --动态列表

    self._approvalInfo = {} --申请列表    

    self._roomHistorys = {} -- 战绩
    self._activeNum = 0 --活跃值

    self._ruleData = RuleData.new()   --玩法

    self._rankData = RankData.new()     --排行榜数据

    self._memberData = MemberData.new() --成员数据

    self._roomData = RoomData.new()     --房间数据

    self._scoreData = ScoreData.new()   --积分数据

    self._spuerLeagueData = SuperLeagueData.new()  --超级盟主数据

    self._leagueManagerData = LeagueManagerData.new() --盟主数据

    self._leagueFireScoreData = LeagueFireScoreData.new() --超级盟主活跃值赠送数据

    self._gamePlayData = GamePlayData:new() --玩法筛选数据
end

function BigLeagueData:setLotteryGold(lotteryGold)
    self._lotteryGold = tonumber(lotteryGold)
end

function BigLeagueData:getLotteryGold()
    return self._lotteryGold
end

function BigLeagueData:getHaveApproval()
    return self._haveApproval
end

function BigLeagueData:setHaveApproval(haveApproval)
    self._haveApproval = haveApproval
end

--基本信息
function BigLeagueData:setBaseInfo(proto)
    self._leagueId = proto.leagueId
    self._leagueName = proto.leagueName
    self._cardNum = proto.clubCard
    self._goldNum = proto.goldCount
    self._myScore = tonumber(proto.myScore) or 0
    self._teamScore = tonumber(proto.currentScore) or 0
    self._leaderId = proto.leaderId
    self._isRoomOpening = proto.show
    self._title = proto.title
    self._fireScore = tonumber(proto.fireScore) or 0
    self._partnerNumber = proto.partnerNumber
    self._partnerId = proto.partnerId
    print("setBaseInfo", self._myScore)
end

function BigLeagueData:setIsRoomOpening(isRoomOpening)
    self._isRoomOpening = isRoomOpening
end

function BigLeagueData:getIsRoomOpening()
    return self._isRoomOpening
end

function BigLeagueData:setLeaderId(leaderId)
    self._leaderId = leaderId
end

function BigLeagueData:getLeaderId()
    return self._leaderId
end

function BigLeagueData:getTitle()
    return self._title
end

function BigLeagueData:getFireScore()
    return self._fireScore
end

function BigLeagueData:setFireScore(fireScore)
    self._fireScore = tonumber(fireScore) or 0
end

-- 判断是不是B
function BigLeagueData:isLeader()
    return self._title == ClubConstant:getClubPosition().MANAFER
end

-- 判断是不是管理
function BigLeagueData:isAssistant()
    return self._title == ClubConstant:getClubPosition().ASSISTANT
end

-- 判断是不是搭档
function BigLeagueData:isPartner()
    return self._title == ClubConstant:getClubPosition().PARTNER
end

-- 判断是否有管理权限
function BigLeagueData:isManager()
    return self:isLeader() or self:isAssistant()
end

function BigLeagueData:setClubId(id)
    Logger.debug("BigLeagueData:setClubId() = %s", id)
    self._clubId = id
end

function BigLeagueData:getClubId()
    Logger.debug("BigLeagueData:getClubId() = %s", self._clubId)
    return self._clubId
end

function BigLeagueData:setLeagueId(id)
    Logger.debug("BigLeagueData:setLeagueId() = %s", id)
    self._leagueId = id
end

function BigLeagueData:getLeagueId()
    Logger.debug("BigLeagueData:getLeagueId() = %s", self._leagueId)
    return self._leagueId
end

function BigLeagueData:getLeagueName()
    return self._leagueName
end

function BigLeagueData:setLeagueName(leagueName)
    self._leagueName = leagueName
end

function BigLeagueData:getCardNum()
    return self._cardNum
end

function BigLeagueData:setCardNum(cardNum)
    self._cardNum = cardNum
end

function BigLeagueData:getGoldNum()
    return self._goldNum
end

function BigLeagueData:setGoldNum(goldNum)
    self._goldNum = goldNum
end

function BigLeagueData:getMyScore()
    return self._myScore
end

function BigLeagueData:setMyScore(myScore)
    self._myScore = tonumber(myScore) or 0
    
end

function BigLeagueData:getTeamScore()
    return self._teamScore
end

function BigLeagueData:setTeamScore(teamScore)
    self._teamScore = tonumber(teamScore) or 0
end

function BigLeagueData:setPartnerNumber(partnerNumber)
    self._partnerNumber = partnerNumber
end

function BigLeagueData:getPartnerNumber()
    return self._partnerNumber
end

function BigLeagueData:getPartnerId()
    return self._partnerId
end
--[[玩法相关
]]--
function BigLeagueData:setGameRules(proto)
    -- self._gameRules = proto.gameplays
    self._ruleData:setGameRules(proto)
end

function BigLeagueData:getGameRules()
    -- 按照玩法创建时间排序
    return self._ruleData:getGameRules()
end

function BigLeagueData:getGameRule(id)
    return self._ruleData:getGameRule(id)
end

function BigLeagueData:getmaxGameplayRegion()
    return self._ruleData:getmaxGameplayRegion()
end

--修改一条玩法
function BigLeagueData:changeOneRule(id, rule)
    self._ruleData:changeOneRule(id, rule)
end
--删除一条玩法
function BigLeagueData:deleteOneRule(id)
    self._ruleData:deleteOneRule(id)
end

function BigLeagueData:getLastSelectIndex()
    return self._ruleData:getLastSelectIndex()
end

function BigLeagueData:setLastCreateRoomSettings(id, time)
    self._ruleData:setLastCreateRoomSettings(id, time)
end

--玩法统计
function BigLeagueData:setGamePlayStatistic(proto)
    self._ruleData:setGamePlayStatistic(proto)
end

function BigLeagueData:getGamePlayStatistic()
    return self._ruleData:getGamePlayStatistic()
end



--[[
    玩法筛选相关
]]
--保存玩法筛选
function BigLeagueData:saveGamePlay(leagueID,tbData)
    self._gamePlayData:SetGamePlayData(leagueID,tbData)
end

--获取玩法筛选
function BigLeagueData:getGamePlay(leagueID)
    local localGamePlay = self._gamePlayData:GetGamePlayData(leagueID)
    local gameRule = self:getGameRules()

    --没有玩法
    if not gameRule or not next(gameRule) then 
        return {}
    end

    --缓存的玩法全部被删除的情况
    local bAllDelete = true
    if localGamePlay and next(localGamePlay) then
        for i,gamePlay in ipairs(gameRule) do 
            if localGamePlay[tostring(gamePlay.id)] and localGamePlay[tostring(gamePlay.id)].showRoomTime > 0 then 
                bAllDelete = false
                break
            end
        end
    end

    --沒有玩法筛选設置|缓存的玩法全部被删除，则默认全部选择，并且没有小红点
    if not localGamePlay or not next(localGamePlay) or bAllDelete then 
        localGamePlay = {}
        for i,gamePlay in ipairs(gameRule) do 
            localGamePlay[tostring(gamePlay.id)] = {showRoomTime = gamePlay.modifyTime,bSelected = true,modifyTime = gamePlay.modifyTime, bRed = false}
        end
        self:saveGamePlay(leagueID,localGamePlay)
    end

    return localGamePlay
end 

--[[排行榜相关]]--
function BigLeagueData:setRankInfo(proto,day)   
    self._rankData:setRankInfo(proto, day)
end

function BigLeagueData:getRankInfo(day)
    return self._rankData:getRankInfo(day)
end

function BigLeagueData:changeRankInfo(clubId, like, day)
    self._rankData:changeRankInfo(clubId, like, day)
end

function BigLeagueData:getRankInfoByClubId(clubId, day)
   return self._rankData:getRankInfoByClubId(clubId, day)
end

function BigLeagueData:getClubRank(clubId, day, strType)
    return self._rankData:getClubRank(clubId, day, strType)
end

function BigLeagueData:getMemberRank(day)
    return self._rankData:getMemberRank(day)
end

function BigLeagueData:getLeagueRankScores(day)
    return self._rankData:getLeagueRankScores(day)
end

function BigLeagueData:clearRankData()
    self._rankData:init()
end
--[[联盟列表相关
message LeagueClubPROTO                         // 联盟信息
{
    optional int32 clubId = 1;                  // 俱乐部ID
    optional string clubName = 2;               // 俱乐部名称
    optional string managerName = 3;            // 盟主昵称
    optional int32 memberCount = 4;             // 俱乐部人数
    optional float initialScore = 5;            // 初始积分数量
    optional float fireScoreRate = 6;           // 火力值
    optional int32 status = 7;                  // 状态
    optional string remark = 8;                 // 备注
}
]]
function BigLeagueData:setLeaguesInfo(proto)
    self._leaguesInfo = proto.leagues
    for _,info in ipairs(self._leaguesInfo) do
        info.currentScore = tonumber(info.currentScore)
        info.fireScoreRate = tonumber(info.fireScoreRate)
    end
    -- dump(self._leaguesInfo)
end

function BigLeagueData:getLeagusInfo()
    return self._leaguesInfo
end

function BigLeagueData:getLeagueByClubId(clubId)
    for k,league in ipairs(self._leaguesInfo) do
        if league.clubId == clubId then
            return league
        end
    end
    return nil
end
--更改联盟数据
function BigLeagueData:changeLeagueInfo(proto)
    local league = self:getLeagueByClubId(proto.clubId)
    if league then
        league.currentScore = tonumber(proto.currentScore)
        league.fireScoreRate = tonumber(proto.fireScoreRate)
        league.remark = proto.remark
    end
end
--暂停联盟比赛
function BigLeagueData:setLeaguePause(clubId)
    local league = self:getLeagueByClubId(clubId)
    if league then
        league.status = LeagueClubStatus.PAUSE
    end
end
--恢复联盟比赛
function BigLeagueData:setLeagueRestore(clubId)
    local league = self:getLeagueByClubId(clubId)
    if league then
        league.status = LeagueClubStatus.NORMAL
    end
end
--强制退赛(提出联盟)
function BigLeagueData:setLeagueStop(clubId)
    for k,league in ipairs(self._leaguesInfo) do
        if league.clubId == clubId then
            table.remove(self._leaguesInfo, k)
            return
        end
    end
end

--[[联盟动态
    message LeagueTrendPROTO                        // 动态
    {
        optional int64 time = 1;                    // 动态时间
        optional int32 type = 2;                    // 动态类型
        optional string data = 3;                   // 动态数据
    }
]]

function BigLeagueData:setTrendInfo(proto)
    self._trendInfo = proto.trends
end

function BigLeagueData:getTrendInfo()
    table.sort(self._trendInfo, function (a, b)
        if a.time > b.time then
            return true
        end
    end)
    return self._trendInfo
end

--[[申请列表相关
message LeagueApprovalPROTO                     // 审批信息
{
    optional int32 clubId = 1;                  // 俱乐部ID
    optional string clubName = 2;               // 俱乐部名称
    optional string clubIcon = 3;			    // 俱乐部的图标
    optional int32 managerId = 4;			    // 经理ID
    optional string managerName = 5;            // 经理名称
    optional int32 memberCount = 6;             // 俱乐部人数
    optional int32 status = 7;                  // 审批状态

     /**
   * 联盟审批状态
   */
  public static class LeagueApprovalStatus
  {
    // 等待审批
    public static final int APPROVAL = 1;
    // 同意
    public static final int AGREE = 2;
    // 拒绝
    public static final int REFUSE = 3;
  }
}
]]

function BigLeagueData:setApprovalInfo(proto)
    self._approvalInfo = proto.approvals
end
function BigLeagueData:getApprovalInfo()
    table.sort(self._approvalInfo, function (a, b)
        if a.status < b.status then
            return true
        end
    end)
    return self._approvalInfo
end

function BigLeagueData:getApprovalByClubId(clubId)
    for k, approval in ipairs(self._approvalInfo) do
        if approval.clubId == clubId then
            return approval
        end
    end
    return nil
end
--设置操作结果
function BigLeagueData:setOperateApproval(proto)
    local approval = self:getApprovalByClubId(proto.clubId)
    if approval ~= nil then
        approval.status = proto.agree and 2 or 3
    end
end


--[[玩家列表相关
]]
function BigLeagueData:setCurrentScore(currentScore)
    self._currentScore = tonumber(currentScore) or 0
end

function BigLeagueData:getCurrentScore()
    return self._currentScore
end


function BigLeagueData:setMemberInfo(proto)
    self._memberData:setMemberInfo(proto)
end

function BigLeagueData:getMemberInfo()
    return self._memberData:getMemberInfo()
end

function BigLeagueData:deleteMember(roleId)
    self._memberData:deleteMember(roleId)
end

function BigLeagueData:getMemberById(roleId)
    return self._memberData:getMemberById(roleId)
end

function BigLeagueData:setIsPauseGame(roleId, isPauseGame)
    self._memberData:setIsPauseGame(roleId, isPauseGame)
end

function BigLeagueData:setMemberScore(proto)
    self._memberData:setMemberScore(proto)
end

function BigLeagueData:setMemberTitle(roleId, title)
    self._memberData:setMemberTitle(roleId, title)
end

--[[
message RoomHistoryPROTO							// 房间战绩
{
	required int32 roomId = 1;						// 房间ID
	required int64 createTime = 2;					// 房间创建时间
	repeated PlayerHistoryPROTO playerRecords = 3;	// 玩家信息和战绩总览
	optional int32 roundType = 4;					// 圈/局类型
	repeated int32 gameplays = 5; 					// 玩法规则
	optional int32 roundCount = 6; 					// 局数
	optional int32 playerMaxCardCount = 7;			// 玩家的最大手牌
	optional bool enableMutilHu = 8;				// 是否允许多次胡牌（赢牌）
	optional bool isProcessed = 9;					// 是否被处理过
	optional bool isAbnormalRoom = 10;				// 是否是异常解散
	optional int32 clubId = 11;                     // 俱乐部ID
	optional int64 destroyTime = 12;				// 房间解散时间
	optional float scoreRatio = 13;					// 联盟赛事分系数
	optional string gameplayName = 14;				// 联盟玩法名称
    repeated ScoreListPROTO scoreList = 15;          // 分数列表
}
]]--

function BigLeagueData:setRoomHistorys(proto)
    self._roomHistorys = proto.roomRecords
end

function BigLeagueData:getRoomHistorys()
    return self._roomHistorys
end



--[[房间相关
]]--

function BigLeagueData:setRoomList(proto)
    self._roomData:setRoomList(proto)
end

function BigLeagueData:getNoDetailRooms()
    return self._roomData:getNoDetailRooms()
end

function BigLeagueData:getRoomList()
    return self._roomData:getRoomList()
end

function BigLeagueData:getShowRoomList()
    return self._roomData:getShowRoomList()
end

function BigLeagueData:setRoomDetails(proto)
    -- self._roomDetail = proto.tableInfos
    return self._roomData:setRoomDetails(proto)
end

function BigLeagueData:getRoomDetailById(roomId)
    return self._roomData:getRoomDetailById(roomId)
end

function BigLeagueData:getRoomDetail()
    return self._roomData:getRoomDetail()
end

function BigLeagueData:filterRoomData()
    self._roomData:filterRoomList()
end

--获取当前桌和当前桌子所在行的信息
function BigLeagueData:getRoomPositionAndLine(roomId)
    
    return self._roomData:getRoomPositionAndLine(roomId)
end

function BigLeagueData:clearRoomData()
    self._roomData:clearRoomData()
end


--[[积分详情
]]
function BigLeagueData:setLeagueScore(proto)
    self._scoreData:setLeagueScore(proto)
end

function BigLeagueData:getLeagueScore()
    return self._scoreData:getLeagueScore()
end

function BigLeagueData:setScoreRecord(proto)
    return self._scoreData:setScoreRecord(proto)
end

function BigLeagueData:getScoreRecord()
    return self._scoreData:getScoreRecord()
end

function BigLeagueData:setMemberRecord(proto, clubId, partnerId)
    return self._scoreData:setMemberRecord(proto, clubId, partnerId)
end

function BigLeagueData:getMemberRecord(clubId)
    return self._scoreData:getMemberRecord(clubId)
end
function BigLeagueData:getPartnerRecord()
    return self._scoreData:getPartnerRecord()
end

function BigLeagueData:getTotalScoreChange()
    return self._scoreData:getTotalScoreChange()
end
function BigLeagueData:getScoreChangeByType(nType)
    return self._scoreData:getScoreChangeByType(nType)
end
function BigLeagueData:getMemberRecordByClubId(clubId)
    return self._scoreData:getMemberRecordByClubId(clubId)
end


function BigLeagueData:getScoreData()
    return self._scoreData
end

function BigLeagueData:getActiveValue()
    return self._scoreData:getActiveValue()
end

function BigLeagueData:getExChangeActiveValue()
    return self._scoreData:getExChangeActiveValue()
end

--[[超级盟主数据]
]]

function BigLeagueData:setMatchActivityInfo(protocol)
     self._spuerLeagueData:setMatchActivityInfo(protocol)
 
end

function BigLeagueData:getMatchActivityInfo()
    return self._spuerLeagueData:getMatchActivityInfo()

end


function BigLeagueData:setSuperLeagueData(proto)
    self._spuerLeagueData:setSuperLeagueData(proto) 
end

function BigLeagueData:getSuperLeagueData()
    return self._spuerLeagueData:getSuperLeagueData()
 
end


function BigLeagueData:getSuperLeagueActiveValue()
    return self._spuerLeagueData:getSuperLeagueActiveValue()
 
end

--[[盟主数据]
]]
function BigLeagueData:setLeagueManagerMemberData(proto)
    self._leagueManagerData:setLeagueManagerMemberData(proto)
 
end

function BigLeagueData:getLeagueManagerMemberData()
    return self._leagueManagerData:getLeagueManagerMemberData()
 
end


function BigLeagueData:getLeagueManagerActiveValue()
    return self._leagueManagerData:getLeagueManagerActiveValue()
 
end

--[[超级盟主活跃值赠送数据]
]]

function BigLeagueData:setClubFireScores(proto)
    self._leagueFireScoreData:setClubFireScores(proto)
 
end


function BigLeagueData:getClubFireScores()
    return self._leagueFireScoreData:getClubFireScores()
 
end








return BigLeagueData