local BigLeagueRankData = class("BigLeagueRankData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function BigLeagueRankData:ctor()
    self:init()
end

function BigLeagueRankData:init() 
    self._leagueRank = {}   --排行榜
    self._memberRank = {}   --成员排行
    self._allInitialScore = {}
    self._allCurrentScore = {}
    self._allLotteryScore = {}
    self._allFireScore = {}
end

--[[排行榜相关
message LeagueRankPROTO                         // 联盟排行榜信息
{
    optional int32 clubId = 1;                  // 俱乐部ID
    optional string clubName = 2;               // 俱乐部名称
    optional string managerName = 3;            // 经理名称
    optional float allScore = 4;                // 团队总积分
    optional float winScore = 5;                // 团队优胜分
    optional float initialScore = 6;            // 团队初始分
    optional float fireScore = 7;               // 火力值
    optional int32 memberCount = 8;             // 参赛人数
    optional int32 roomCount = 9;               // 比赛场次
    optional int32 lotteryCount = 10;           // 抽奖次数
    optional bool like = 11;                    // 是否点赞过
}
message ClubMemberRankPROTO                     // 俱乐部中成员的排行榜信息
{
    optional int32 roleId = 1;                  // 玩家ID
    optional string name = 2;                   // 玩家昵称
    optional int32 roomCount = 3;               // 比赛场次
    optional int32 lotteryCount = 4;            // 抽奖次数
}
]]--

function BigLeagueRankData:setRankInfo(proto,day)   
    self._leagueRank[day] = clone(proto.clubRanks)
    for _,info in ipairs(self._leagueRank[day]) do
        info.allScore = tonumber(info.allScore)
        info.winScore = tonumber(info.winScore)
        info.fireScoreRate = tonumber(info.fireScoreRate)
        info.fireScore = tonumber(info.fireScore)
    end
    self._memberRank[day] = clone(proto.memberRanks)
    self._allFireScore[day] = tonumber(proto.allFireScore)
    self._allInitialScore[day] = tonumber(proto.allInitialScore)
    self._allLotteryScore[day] = tonumber(proto.allLotteryScore)
    self._allCurrentScore[day] = tonumber(proto.allCurrentScore)
    dump(self._leagueRank, "setRankInfo~~~~~~~~~~~~~~")
end

function BigLeagueRankData:getRankInfo(day)
    return self._leagueRank[day] or {}
end

function BigLeagueRankData:changeRankInfo(clubId, like, day)
    for _, data in ipairs(self._leagueRank[day]) do
        if data.clubId == clubId then
            data.like = like
            return
        end
    end
end

function BigLeagueRankData:getRankInfoByClubId(clubId, day)
    if self._leagueRank[day] == nil then
        return nil
    end
    for _,info in ipairs(self._leagueRank[day]) do
        if info.clubId == clubId then
            return info
        end
    end
    return nil
end

function BigLeagueRankData:getClubRank(clubId, day, strType)
    table.sort(self._leagueRank[day], function(a ,b)
        return a[strType] > b[strType]
    end)
    for idx, league in ipairs(self._leagueRank[day]) do
        if league.clubId == clubId then
            return idx
        end
    end
    return 0
end

function BigLeagueRankData:getMemberRank(day)
    return self._memberRank[day]
end

function BigLeagueRankData:getLeagueRankScores(day)
    return self._allInitialScore[day], self._allCurrentScore[day],self._allLotteryScore[day], self._allFireScore[day]
end


--测试数据
function BigLeagueRankData:createTestData()
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
return BigLeagueRankData