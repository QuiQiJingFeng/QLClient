local BigLeagueMemberData = class("BigLeagueMemberData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")


function BigLeagueMemberData:ctor()
    self:init()
end

function BigLeagueMemberData:init() 
    self._memberInfo = {}   --玩家信息
end
--[[玩家相关
message LeagueMemberPROTO                       // 成员信息
{
    optional int32 roleId = 1;                  // 成员ID
    optional string nickname = 2;               // 昵称
    optional string headUrl = 3;                // 头像url
    optional int32 headFrameId = 4;             // 头像框ID
    optional int32 status = 5;                  // 状态
    optional int32 roomCount = 6;               // 参赛场次
    optional float gameScore = 7;               // 当前赛事分
    optional float initialScore = 8;            // 初始赛事分
    optional string remark = 9;                 // 备注
    optional int32 yesterdayRoomCount = 10;     // 昨日场次
    optional int32 yesterdayLotteryCount = 11;  // 昨日抽奖次数
    optional int32 allRoomCount = 12;           // 累计场次
    optional int32 allLotteryCount = 13;        // 累计抽奖次数
    optional bool isRealNameAuth = 14;          // 实名认证
    optional int64 joinClubTime = 15;           // 加入亲友圈时间
    optional bool isPauseGame = 16;             // 是否被暂停比赛
    optional int32 title = 17;                  // 职位
}
]]--


function BigLeagueMemberData:setMemberInfo(proto)
    self._memberInfo = proto.members
    for _,info in ipairs(self._memberInfo) do
        info.gameScore = tonumber(info.gameScore)
        info.initialScore = tonumber(info.initialScore)
    end
end

function BigLeagueMemberData:getMemberInfo()
    table.sort(self._memberInfo, function (a, b)
        if a.status == b.status then
            if  ClubConstant:getClubTitleSort(a.title) == ClubConstant:getClubTitleSort(b.title) then
                return a.joinClubTime < b.joinClubTime
            end
            return ClubConstant:getClubTitleSort(a.title) > ClubConstant:getClubTitleSort(b.title)
        end
        return a.status < b.status
    end)
    return self._memberInfo
end

function BigLeagueMemberData:deleteMember(roleId)
    for k,user in ipairs(self._memberInfo) do
        if user.roleId == roleId then
            table.remove(self._memberInfo, k)
            return
        end
    end
end

function BigLeagueMemberData:getMemberById(roleId)
    for k,user in ipairs(self._memberInfo) do
        if user.roleId == roleId then
            return user
        end
    end
    return nil
end

function BigLeagueMemberData:setIsPauseGame(roleId, isPauseGame)
    local user = self:getMemberById(roleId)
    if user ~= nil then
        user.isPauseGame = isPauseGame
    end
end

function BigLeagueMemberData:setMemberScore(proto)
    local user = self:getMemberById(proto.roleId)
    if user ~= nil then
        user.gameScore = tonumber(proto.score)
        user.initialScore = tonumber(proto.score)
    end
end

function BigLeagueMemberData:setMemberTitle(roleId, title)
    local user = self:getMemberById(roleId)
    if user ~= nil then
        user.title = title
    end
end
return BigLeagueMemberData