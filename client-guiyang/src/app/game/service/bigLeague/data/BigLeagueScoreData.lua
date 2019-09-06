local BigLeagueScoreData = class("BigLeagueScoreData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function BigLeagueScoreData:ctor()
    self:init()
end

function BigLeagueScoreData:init() 
    self._currentScore = 0
    self._fireScore = 0
    self._allScore = 0
    self._activeValue = 0
    self._exChangeValue = 0
    self._managerId = ""
    self._managerName = ""
    self._scoreRecord = {}
    self._clubRecord = {}           --俱乐部成员积分，每条数据为俱乐部中玩家的积分状况
    self._partnerRecord = {}         --搭档成员积分，每条数据为搭档下属玩家的积分状况
    self._memberRecord = {}         --联盟成员积分，每条数据为联盟下俱乐部的积分状况
end

--[[积分相关
message CCLQueryScoreRecordREQ                      // 请求赛事分或者活跃值记录
{
    optional int32 leagueId = 1;                    // 联盟ID
    optional int32 clubId = 2;                      // 俱乐部ID
    optional int32 type = 3;                        // 玩家类型（1：盟主；2：俱乐部经理；3：普通成员）
    optional int32 scoreType = 4;                   // 分数类型（1：赛事分；2：活跃值）
    optional int64 date = 5;                        // 查询日期
}
message ClubMemberRankPROTO                     // 俱乐部中成员的排行榜信息
{
    optional int32 roleId = 1;                  // 玩家ID
    optional string name = 2;                   // 玩家昵称
    optional int32 roomCount = 3;               // 比赛场次
    optional int32 lotteryCount = 4;            // 抽奖次数
}
]]--

function BigLeagueScoreData:setLeagueScore(proto)   
    dump(proto,"setLeagueScore~~~~~~~")
    self._currentScore = tonumber(proto.currentScore)
    self._fireScore = tonumber(proto.fireScore)
    self._allScore = tonumber(proto.allScore)
    self._managerId = proto.managerId
    self._managerName = proto.managerName
    self._fireScoreRate = proto.fireScoreRate
end

function BigLeagueScoreData:getLeagueScore()
    return self._currentScore, self._fireScore, self._allScore, self._managerId, self._managerName,self._fireScoreRate 
end

function BigLeagueScoreData:setFireScore()
    self._fireScore = 0
end

function BigLeagueScoreData:setScoreRecord(proto, clubId)
    dump(proto, "setScoreRecord~~~~~~~~~~~~~~")
    self._scoreRecord = proto.record
    -- self._activeValue = proto.getFireScore
    -- self._exChangeValue = proto.convertFireScore 
    self._activeValue = 0
    self._exChangeValue = 0
    for _,info in ipairs(self._scoreRecord) do
        info.score = tonumber(info.score)
        info.afterScore = tonumber(info.afterScore)
        info.remainScore = tonumber(info.remainScore)
        if info.score > 0 then
            self._activeValue = self._activeValue + info.score
        else
            self._exChangeValue = self._exChangeValue - info.score
        end
    end
    table.sort(self._scoreRecord, function(a, b)
        if a.time ~= b.time then
            return a.time > b.time
        elseif a.type ~= b.type then
            return a.type > b.type
        else
            return a.afterScore > b.afterScore
        end
    end)
end

function BigLeagueScoreData:getScoreRecord()
    return self._scoreRecord
end

function BigLeagueScoreData:setMemberRecord(proto, clubId, partnerId)
    -- dump(proto, "setScoreRecord~~~~~~~~~~~~~~")
    if partnerId ~= 0 then
        self._partnerRecord = proto.records
        for _,info in ipairs(self._partnerRecord) do
            info.score = tonumber(info.score)
        end
    elseif clubId == 0 then
        self._memberRecord = proto.records
        for _,info in ipairs(self._scoreRecord) do
            info.score = tonumber(info.score)
        end
    else
        self._clubRecord = proto.records
        for _,info in ipairs(self._clubRecord) do
            info.score = tonumber(info.score)
        end
    end
end

function BigLeagueScoreData:getMemberRecord(clubId)
    if clubId == 0 or clubId == nil then
        return self._memberRecord
    else
        return self._clubRecord
    end
end

function BigLeagueScoreData:getPartnerRecord()
    return self._partnerRecord
end

function BigLeagueScoreData:getMemberRecordByClubId(clubId)
    for _,info in ipairs(self._memberRecord) do
        if info.clubId == clubId then
            return info
        end
    end
    return nil
end

function BigLeagueScoreData:getTotalScoreChange()
    local num = 0
    for _,info in ipairs(self._scoreRecord) do
        num = num + info.score
    end
    return num
end

function BigLeagueScoreData:getScoreChangeByType(nType)
    local num = 0
    for _,info in ipairs(self._scoreRecord) do
        if info.type == nType then
            num = num + info.score
        end
    end
    return num
end

--测试数据
function BigLeagueScoreData:createTestData()
    self._leagueRank[0] = {}
    self._memberRank[0] = {}
    for i = 1, 100 do
        local obj ={
            clubId = i,
            clubName = "clubName"..i,
            managerName = "managerName"..i,
            allScore = 100 + i,
            winScore = 10 + i,
            fireScore = 10 - i,
            memberCount = 30 + i,
            roomCount = 50 -i,
            lotteryCount = 8 * i,
            like = i%2 == 0
        }
        table.insert(self._leagueRank[0], obj)

        local obj2 = {
            roleId = i,                  
            name = "name"..i,                 
            roomCount = 100+i,
            lotteryCount = 200-i,
        }
        table.insert(self._memberRank[0], obj2)
    end
end

--获取活跃值和活跃值数
function BigLeagueScoreData:getExChangeActiveValue()
    return self._exChangeValue
end

function BigLeagueScoreData:getActiveValue()
    return self._activeValue
end
return BigLeagueScoreData