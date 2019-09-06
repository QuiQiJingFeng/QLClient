local ClubGroupService = class("ClubGroupService")

function ClubGroupService:ctor(cs)
    -- 绑定事件系统
	cc.bind(self, "event");

    self._clubService = cs
end

function ClubGroupService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CLCQueryClubGroupListRES.OP_CODE, self, self._onCLCQueryClubGroupListRES)
    requestManager:registerResponseHandler(net.protocol.CLCCheckCreateGroupRES.OP_CODE, self, self._onCLCCheckCreateGroupRES)
    requestManager:registerResponseHandler(net.protocol.CLCCreateClubGroupRES.OP_CODE, self, self._onCLCCreateClubGroupRES)
    requestManager:registerResponseHandler(net.protocol.CLCDeleteClubGroupRES.OP_CODE, self, self._onCLCDeleteClubGroupRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyClubGroupRES.OP_CODE, self, self._onCLCModifyClubGroupRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryGroupMembersRES.OP_CODE, self, self._onCLCQueryGroupMembersRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryImportClubInfoRES.OP_CODE, self, self._onCLCQueryImportClubInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCImportGroupMemberRES.OP_CODE, self, self._onCLCImportGroupMemberRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryGroupInfoRES.OP_CODE, self, self._onCLCQueryGroupInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryMemberInfosForGroupRES.OP_CODE, self, self._onCLCQueryMemberInfosForGroupRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyGroupMemberRES.OP_CODE, self, self._onCLCModifyGroupMemberRES)
end

function ClubGroupService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);

    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 请求俱乐部小组列表
function ClubGroupService:sendCCLQueryClubGroupListREQ(clubId, startTime, endTime)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryClubGroupListREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, startTime, endTime)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCQueryClubGroupListRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_CLUB_GROUP_LIST_SUCCESS then
        local groups =
        {
            totalRoomCount = protocol.totalRoomCount, -- 牌桌总数
            totalWinnerCount = protocol.totalWinnerCount, -- 大赢家总数
            totalBigWinCount = protocol.totalBigWinCount, -- 超过最低分的大赢家总数
            groupList = protocol.groupList -- 小组列表
        }
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_LIST", groups = groups})          
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求验证创建俱乐部
function ClubGroupService:sendCCLCheckCreateGroupREQ(clubId, groupName, leaderId, minScore)
	local request = net.NetworkRequest.new(net.protocol.CCLCheckCreateGroupREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, groupName, leaderId, minScore)
    request.clubId = clubId
    request.groupName = groupName
    request.leaderId = leaderId
    request.minScore = minScore

	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCCheckCreateGroupRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CHECK_CREATE_GROUP_SUCCESS then
        local playerInfo =
        {
            leaderName = protocol.leaderName,
            leaderIcon = protocol.leaderIcon,
            clubId = request.clubId,
            groupName = request.groupName,
            leaderId = request.leaderId,
            minScore = request.minScore,
        }
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_LEADER_INFO", playerInfo = playerInfo})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求创建俱乐部小组
function ClubGroupService:sendCCLCreateClubGroupREQ(clubId, groupName, leaderId, minScore)
	local request = net.NetworkRequest.new(net.protocol.CCLCreateClubGroupREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, groupName, leaderId, minScore)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCCreateClubGroupRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CREATE_CLUB_GROUP_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("创建成功")
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_INFO_CHAGE"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求删除俱乐部小组
function ClubGroupService:sendCCLDeleteClubGroupREQ(clubId, groupId)
	local request = net.NetworkRequest.new(net.protocol.CCLDeleteClubGroupREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, groupId)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCDeleteClubGroupRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_DELETE_CLUB_GROUP_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("解除成功")
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_INFO_CHAGE"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求修改俱乐部小组信息
function ClubGroupService:sendCCLModifyClubGroupREQ(clubId, groupId, groupName, minWinnerScore)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyClubGroupREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, groupId, groupName, minWinnerScore)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCModifyClubGroupRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_MODIFY_CLUB_GROUP_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("修改成功")
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_INFO_CHAGE"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求俱乐部小组信息
function ClubGroupService:sendCCLQueryGroupMembersREQ(clubId, groupId, startTime, endTime)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryGroupMembersREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, groupId, startTime, endTime)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCQueryGroupMembersRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_GROUP_MEMBERS_SUCCESS then
        local playerInfo =
        {
            totalBigWinCount = protocol.totalBigWinCount, -- 超过最低分的大赢家总数
            totalWinCount = protocol.totalWinCount, -- 大赢家总数
            totalRoomCount = protocol.totalRoomCount, -- 牌局总数
            memberInfos = protocol.memberInfos, -- 小组成员列表
        }
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_PLAYER_INFO_CHAGE", playerInfo = playerInfo})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求可导入的俱乐部信息
function ClubGroupService:sendCCLQueryImportClubInfoREQ(clubId, leaderId, leagueId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryImportClubInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, leaderId, leagueId)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCQueryImportClubInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_IMPORT_CLUB_INFO_SUCCESS then
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_IMPORT_LIST_INFO", importClubInfos = protocol.importClubInfos})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求导入小组成员
function ClubGroupService:sendCCLImportGroupMemberREQ(groupId, leagueId, targetClubId, sourceClubId, importRoleList)
	local request = net.NetworkRequest.new(net.protocol.CCLImportGroupMemberREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(groupId, leagueId, targetClubId, sourceClubId, importRoleList)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCImportGroupMemberRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_IMPORT_GROUP_MEMBER_SUCCESS then
        if protocol.unImportCount > 0 then
            local text = string.format("%s位玩家由于亲友圈数量已达到上限,加入搭档失败,其余玩家加入成功", protocol.unImportCount)
            game.ui.UIMessageBoxMgr.getInstance():show(text, {"确定"})
        else
            game.ui.UIMessageTipsMgr.getInstance():showTips("导入成功")
        end
        game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_PARTNER"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求小组信息
function ClubGroupService:sendCCLQueryGroupInfoREQ(clubId, groupId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryGroupInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, groupId)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCQueryGroupInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_GROUP_INFO_SUCCESS then
        local groupInfo =
        {
            leaderId = protocol.leaderId,
            leaderName = protocol.leaderName,
            memberCount = protocol.memberCount,
            minWinnerScore = protocol.minWinnerScore,
            createTime = protocol.createTime,
        }
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_MANAGER_INFO", groupInfo = groupInfo})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求俱乐部成员数据
function ClubGroupService:sendCCLQueryMemberInfosForGroupREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryMemberInfosForGroupREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId)
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCQueryMemberInfosForGroupRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_QUERY_MEMBER_INFOS_FOR_GROUP_SUCCESS then
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_MEMBER_INFO", memberInfos = protocol.memberInfos})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求添加或删除俱乐部小组成员
function ClubGroupService:sendCCLModifyGroupMemberREQ(clubId, opType, memberId, groupId)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyGroupMemberREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, opType, memberId, groupId)
    request.roleId = memberId
    request.groupId = groupId
    request.opType = opType
	game.util.RequestHelper.request(request)
end

function ClubGroupService:_onCLCModifyGroupMemberRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_MODIFY_GROUP_MEMBER_SUCCESS then
        self:dispatchEvent({ name = "EVENT_CLUB_GROUP_MEMBER_INFO_CHANGE", roleId = request.roleId, groupId = request.groupId, opType = request.opType})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

return ClubGroupService