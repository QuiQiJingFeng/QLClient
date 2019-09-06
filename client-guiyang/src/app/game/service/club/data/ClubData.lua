-- 亲友圈相关信息
local ClubData = class("ClubData")

function ClubData:ctor()
    self.info = nil         -- 当前亲友圈信息
    self.oldInfo = {}       -- 最后一次更新数据是亲友圈信息, 用于脏数据对比
    self.data = nil         -- 亲友圈详细信息
    self.rooms = nil        -- 房间列表
    self.members = nil      -- 用户列表
    self.applicants = nil   -- 用户申请列表
    self.histories = {}     -- 历史战绩
    self.task = {}          -- 任务列表
    self.redpacket = {}     -- 红包列表
    self.grabInfo = {}      -- 抢手机相关信息
    self.playerInfo = {}    -- 自己信息
end

-- 获取当前亲友圈入会申请小红点是否显示
function ClubData:hasApplicationBadges()
    local localPlayer = game.service.LocalPlayerService:getInstance()
    return self.info.clubApplicationCount > 0 and self:isPermissions(localPlayer:getRoleId());
end

-- 获取当前亲友圈任务小红点是否显示 
function ClubData:hasTaskBadges()
    local localPlayer = game.service.LocalPlayerService:getInstance()
    return self.info.completedTaskCount > 0 and self:isPermissions(localPlayer:getRoleId());
end

-- 亲友圈邀请信息是否改变
function ClubData:isApplicationChanged()
    return self.info.clubApplicationCount ~= self.oldInfo.clubApplicationCount
        or self.info.clubApplicationVersion ~= self.oldInfo.clubApplicationVersion
end

-- 标记亲友圈邀请信息已经更新
function ClubData:mergeApplicationChange()
    self.oldInfo.clubApplicationCount = self.info.clubApplicationCount
    self.oldInfo.clubApplicationVersion = self.info.clubApplicationVersion
    game.service.club.ClubService.getInstance():dispatchEvent({ name = "EVENT_CLUB_REDDOT_CHANGED" })
end

function ClubData:updateOldInfo(oldInfo)
    for k, v in pairs(oldInfo) do
        self.oldInfo[k] = v
    end
end

-- 亲友圈红包信息变化
function ClubData:isRedPacketChanged()
    -- 如果有未打开的红包，直接返回，如果没有检查版本号
    for i=1,#self.redpacket do
        if self.redpacket[i].status == 1 then
            return true
        end
    end
    if self.oldInfo.redPacketVersion then
        return self.info.redPacketVersion ~= self.oldInfo.redPacketVersion
    end
    self.oldInfo.redPacketVersion = self.info.redPacketVersion
    return false
end

-- 亲友圈红包信息变化
function ClubData:mergeRedPacketChanged()
    self.oldInfo.redPacketVersion = self.info.redPacketVersion
end

-- 获取红包个数
function ClubData:numOfRedPacket()
    local num = 0
    for i=1,#self.redpacket do
        if self.redpacket[i].status == 1 then
            num = num + 1
        end
    end
    return num
end

-- 获取指定的成员序号, 如果没有返回false
function ClubData:indexOfMember(memberId)
    if self.members ~= nil then
        for idx,member in ipairs(self.members) do
            if member.roleId == memberId then
                return idx
            end
        end
    end

    return false
end

-- 判断是否是群主
function ClubData:isManager(memberId)
    -- 有可能为空，没有加assert，因为出现几率太高了
    if self.data ~= nil then
        return memberId == self.data.managerId
    end
    return false
end

-- 判断是否为管理
function ClubData:isAdministrator(playerId)
    if self.data ~= nil and self.data.assistantIds ~= nil then
        -- 有可能为空，没有加assert，因为出现几率太高了
        for _, id in ipairs(self.data.assistantIds) do
            if id == playerId then return true end
        end
    end
    return false
end

-- 判断是否有权限管理亲友圈
function ClubData:isPermissions(playerId)
    -- 有可能为空，没有加assert，因为出现几率太高了
    if self.data ~= nil then
        if #self.data.assistantIds > 0 then
            for _, id in ipairs(self.data.assistantIds) do
                if id == playerId then return true end
            end
        end
        
        return playerId == self.data.managerId
    else
        if #self.info.assistantIds > 0 then
            for _, id in ipairs(self.info.assistantIds) do
                if id == playerId then return true end
            end
        end
        
        return playerId == self.info.managerId
    end
end

--获取俱乐部名称
function ClubData:getClubName()
    if self.data ~= nil then
        return self.data.clubName or ""
    end
    return ""
end

--获取俱乐部头像名称
function ClubData:getClubIconName()
    if self.data ~= nil then
        return self.data.clubIcon or ""
    end
    return ""
end

--获取俱乐部邀请码
function ClubData:getClubInvitationCode()
    if self.data ~= nil then
        return self.data.invitationCode or 0
    end
    return 0
end

--获取俱乐部群主Id
function ClubData:getClubManagerRoleId()
    if self.data ~= nil then
        return self.data.managerId or 0
    end
    return 0
end

--获取俱乐部创建时间
function ClubData:getClubCreateTime()
    if self.data ~= nil then
        return self.data.clubCreateTime or 0
    end
    return 0
end

--获取俱乐部经理名称
function ClubData:getClubManagerName()
    if self.data ~= nil then
        return self.data.managerName or ""
    end
    return ""
end

--获取俱乐部设置信息
function ClubData:getClubSettingInfo(setTypeId)
    if self.data ~= nil then
        return bit.band(self.data.switches, setTypeId) > 0
    end
    return false
end

--获取活跃玩家数
function ClubData:getActivePlayerNum()
    if self.data ~= nil then
        return self.data.todayPlayCount, self.data.yesterdayPlayCount
    end
    return 0,0
end
-- 获取亲友圈群主真实id
function ClubData:getClubManagerId()
    if self.data ~= nil then
        return self.data.managerId or 0
    end
    return 0
end

-- 获取禁用玩法
function ClubData:getBanGameplays()
    if self.data ~= nil then
        return self.data.banGameplays
    end

    return {}
end

-- 获取模版玩法
function ClubData:getPresetGameplays()
    if self.data ~= nil then
        return self.data.presetGameplays
    end

    return {}
end

-- 获取小组id
function ClubData:getGroupId()
    if self.data ~= nil then
        if self.data.groupId ~= nil then
            return self.data.groupId
        end
    end

    return ""
end

-- 获取可以设置预设玩法的数量
function ClubData:getMaxPresetGamePlay()
    if self.data ~= nil then
        if self.data.maxPresetGameplay ~= nil then
            return self.data.maxPresetGameplay
        end
    end

    return 1
end

--获取俱乐部的联盟ID
function ClubData:getLeagueId()
    if self.data and self.data.leagueId then
        return self.data.leagueId
    end

    return 0
end

return ClubData