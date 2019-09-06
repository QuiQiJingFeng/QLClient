-- 玩家相关信息
local UserData = class("UserData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function UserData:ctor()
    self.info = {}     -- 当前玩家信息
    self.oldInfo = {}  -- 最后一次更新数据时玩家的信息, 用于脏数据对比
    self.invitations = nil
    self.RecommandInvitation = nil
end

-- 玩家邀请信息是否有变化
function UserData:isInvitationChanged()
    return self.info.normalInvitedCount == nil or self.info.normalInvitedCount ~= self.oldInfo.normalInvitedCount
        or self.info.invitationVersion == nil or self.info.invitationVersion ~= self.oldInfo.invitationVersion;
end

-- 标记邀请信息数据已经更新
function UserData:mergeInvitationChange()
    self.oldInfo.normalInvitedCount = self.info.normalInvitedCount
    self.oldInfo.invitationVersion = self.info.invitationVersion
    game.service.club.ClubService.getInstance():dispatchEvent({ name = "EVENT_CLUB_REDDOT_CHANGED" })
end

-- 获取指定的邀请数据
-- @return 存在就返回数据序号, 否则false
function UserData:indexOfInvitation(clubId, inviterId)
    if self.invitations ~= nil then
        for idx,invitation in ipairs(self.invitations) do
            if invitation.clubId == clubId and invitation.inviterId == inviterId then
                return idx
            end
        end
    end

    return false
end

-- 删除指定的邀请数据
-- @return 替换成功返回被替换的数据, 否则false
function UserData:replaceInvitation(clubId, inviterIdvitee, invitation)
    local index = self:indexOfInvitation(clubId, inviterIdvitee)
    if index ~= false then
        table.remove(self.invitations, index)
        table.insert(self.invitations, index, invitation)
        return invitation
    end

    return false
end


-- 删除指定的邀请数据
-- @return 删除成功返回删除的数据, 否则false
function UserData:removeInvitation(clubId, inviterId)
    local index = self:indexOfInvitation(clubId, inviterId)
    if index ~= false then
        local invitation = self.invitations[index]
        table.remove(self.invitations, index)
        return invitation
    end

    return false
end

-- 获取当前亲友圈邀请界面小红点是否显示
function UserData:hasInvitationBadges()
    if self.info.normalInvitedCount and self.info.normalInvitedCount > 0 then
        return true;
    end

    return false;
end

---------------------------------------------------推荐------------------------------------------------------
-- 获取指定的邀请数据
-- @return 存在就返回数据序号, 否则false
function UserData:indexOfRecommandInvitation(clubId, inviterId)
    if self.RecommandInvitation ~= nil then
        for idx,invitation in ipairs(self.RecommandInvitation) do
            if invitation.clubId == clubId and invitation.inviterId == inviterId then
                return idx
            end
        end
    end

    return false
end

-- 删除指定的邀请数据
-- @return 替换成功返回被替换的数据, 否则false
function UserData:replaceRecommandInvitation(clubId, inviterIdvitee, invitation)
    local index = self:indexOfRecommandInvitation(clubId, inviterIdvitee)
    if index ~= false then
        table.remove(self.RecommandInvitation, index)
        table.insert(self.RecommandInvitation, index, invitation)
        return invitation
    end

    return false
end


-- 删除指定的邀请数据
-- @return 删除成功返回删除的数据, 否则false
function UserData:removeRecommandInvitation(clubId, inviterId)
    local index = self:indexOfRecommandInvitation(clubId, inviterId)
    if index ~= false then
        local invitation = self.RecommandInvitation[index]
        table.remove(self.RecommandInvitation, index)
        return invitation
    end

    return false
end

function UserData:hasRecommandInvitationBadges()
    if self.info.recommandInvitedCount and self.info.recommandInvitedCount > 0 then
        return true;
    end

    return false;
end

-- 标记邀请信息数据已经更新
function UserData:mergeRecommandInvitationChange()
    self.oldInfo.recommandInvitedCount = self.info.recommandInvitedCount
    game.service.club.ClubService.getInstance():dispatchEvent({ name = "EVENT_CLUB_REDDOT_CHANGED" })
end

------------------------------------------------------------------------------------------------------------
-- 新用户推荐玩家白名单
function UserData:getIsInWhiteList()
    return self.info.isInWhiteList
end

-- 离线邀请开关状态
function UserData:getOfflineInvitesSwitch()
    return self.info.offlineInvtiedSwitch == 1
end

function UserData:setOfflineInvitesSwitch(offlineInvtiedSwitch)
    self.info.offlineInvtiedSwitch = offlineInvtiedSwitch
end

-- 判断是否要弹推荐邀请弹窗
function UserData:isPopUps()
    local clubService = game.service.club.ClubService.getInstance()
    local gamePlayerInfo = clubService:loadLocalStorageGamePlayInfo()

    if gamePlayerInfo:getPlayerInfo().recommandInvitedVersion == nil or self.info.recommandInvitedVersion == nil then
        return false
    end

    if self.info.recommandInvitedVersion > gamePlayerInfo:getPlayerInfo().recommandInvitedVersion then
        gamePlayerInfo:getPlayerInfo().recommandInvitedVersion = self.info.recommandInvitedVersion
        clubService:saveLocalStorageGamePlayInfo(gamePlayerInfo)
        return true
    end

    return false
end

return UserData