local ClubRoomService = class("ClubRoomService")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function ClubRoomService:ctor(cs)
    -- 绑定事件系统
	cc.bind(self, "event");

    self._clubService = cs

    self._clubRoomInviteInfo = {}

    self._roundCount = 0
    self._gamePlays = {}
end

-- 再来一局需要保存一下当前房间玩法
function ClubRoomService:setRoomRule(roundCount, gamePlays)
    self._roundCount = roundCount
    self._gamePlays = {}
    table.foreach(gamePlays,function (k,v)
        self._gamePlays[k] = v
    end)
end

function ClubRoomService:getRoomRule()
    return self._roundCount, self._gamePlays
end

function ClubRoomService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CLCClubTableRES.OP_CODE, self, self._onCLCClubTableRES)
    requestManager:registerResponseHandler(net.protocol.CLCFocusOnRoomListRES.OP_CODE, self, self._onCLCFocusOnRoomListRES)

    requestManager:registerResponseHandler(net.protocol.CLCQueryRoomInvitedMembersRES.OP_CODE, self, self._onCLCQueryRoomInvitedMembersRES)
    requestManager:registerResponseHandler(net.protocol.CLCSendRoomInvitationRES.OP_CODE, self, self._onCLCSendRoomInvitationRES)
    -- requestManager:registerResponseHandler(net.protocol.CLCNotifyRoomInvitaitonSYN.OP_CODE, self, self._onCLCNotifyRoomInvitaitonSYN)
    requestManager:registerResponseHandler(net.protocol.CLCSendRoomInvitedResultRES.OP_CODE, self, self._onCLCSendRoomInvitedResultRES)
    requestManager:registerResponseHandler(net.protocol.CLCUpdateOfflineInvitedSwitchRES.OP_CODE, self, self._onCLCUpdateOfflineInvitedSwitchRES)
    -- 名片信息
    requestManager:registerResponseHandler(net.protocol.GCBusinessCardInfoRES.OP_CODE, self, self._onGCBusinessCardInfoRES)

    self._clubService:addEventListener("EVENT_CLUB_DATA_SYN", handler(self, self._changendClubDta), self)
end

function ClubRoomService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);

    self._clubService:removeEventListenersByTag(self)

    -- 解绑事件系统
	cc.unbind(self, "event");
end

function ClubRoomService:_changendClubDta(event)
    local protocolBuf = event.chanendClubData
    local newClubIds = event.chanendNewClubIds
    local deletedClubs = event.chanendDeletedClubs
    -- 亲友圈房间信息发生变化
    if protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_ROOM_LIST then
        local updateClubInfo = protocolBuf.clubDatas[1]
        local club = self._clubService:getClub(updateClubInfo.clubId)
        -- 俱乐部房间列表变为间隔为2秒，在房间列表变化期间玩家退出俱乐部
        if club ~= nil then
            club.changeRooms = updateClubInfo.clubTableList
            self:dispatchEvent({ name = "EVENT_CLUB_ROOM_DATA_CHANGED", clubId = updateClubInfo.clubId});
        end
    end
end

-- 请求亲友圈牌桌信息
function ClubRoomService:sendCCLClubTableREQ(roleId, clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLClubTableREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(roleId, clubId)
    game.util.RequestHelper.request(request)
end

-- 返回亲友圈牌桌列表
function ClubRoomService:_onCLCClubTableRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CLUB_TABLE_SUCCESS then
        local requestProto = response:getRequest():getProtocol():getProtocolBuf()
        -- 设置数据
        local club = self._clubService:getClub(requestProto.clubId)
        if Macro.assertFalse(club ~= nil) then
            club.rooms = protocol.clubTableList
            self:dispatchEvent({ name = "EVENT_CLUB_ROOM_DATA_RETRIVED", clubId = requestProto.clubId});
        end
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

-- club 关注和取消关注亲友圈房间列表变化
-- clubId 亲友圈Id
-- optype 操作类型（0：取消关注，1：开始关注）
function ClubRoomService:sendCCLFocusOnRoomListREQ(clubId, optype)
    local request = net.NetworkRequest.new(net.protocol.CCLFocusOnRoomListREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, optype)
    game.util.RequestHelper.request(request)
end

function ClubRoomService:_onCLCFocusOnRoomListRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_FOCUS_ON_ROOM_LIST_SUCCESS then 
        local requestProto = response:getRequest():getProtocol():getProtocolBuf()
		-- 取消注册时不需要刷新数据
        if requestProto.optype == 0 then return end
        -- 设置数据
        local club = self._clubService:getClub(requestProto.clubId)
        if Macro.assertFalse(club ~= nil) then
            club.rooms = protocol.clubTableList

            self:dispatchEvent({ name = "EVENT_CLUB_ROOM_DATA_RETRIVED", clubId = requestProto.clubId});
        end
    end
end

-- 请求俱乐部房间邀请信息列表
function ClubRoomService:sendCCLQueryRoomInvitedMembersREQ(clubId, roomId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryRoomInvitedMembersREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, roomId)
    request.clubId = clubId
    game.util.RequestHelper.request(request)
end

function ClubRoomService:_onCLCQueryRoomInvitedMembersRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_QUERY_ROOM_INVITED_MEMBERS_SUCCESS then 
        self:dispatchEvent({ name = "EVENT_CLUB_ROOM_MEMBER_INFO", clubId = request.clubId, memberInfos = protocol.memberInfos})
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

-- 发送俱乐部房间邀请
function ClubRoomService:sendCCLSendRoomInvitationREQ(clubId, roomId, inviteeId, gameplaysDesc)
    local request = net.NetworkRequest.new(net.protocol.CCLSendRoomInvitationREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, roomId, inviteeId, gameplaysDesc)
    request.clubId = clubId
    game.util.RequestHelper.request(request)
end

function ClubRoomService:_onCLCSendRoomInvitationRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_SEND_ROOM_INVITATION_SUCCESS then 
        self:dispatchEvent({ name = "EVENT_CLUB_ROOM_MEMBER_INFO_CHENGE", clubId = request.clubId, inviteeMemberInfo = protocol.inviteeMemberInfo})
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

function ClubRoomService:sendCCLSendRoomInvitedResultREQ(clubId, roomId, opType, areaId, inviterId)
    local request = net.NetworkRequest.new(net.protocol.CCLSendRoomInvitedResultREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, roomId, opType, areaId, inviterId)
    game.util.RequestHelper.request(request)
end

function ClubRoomService:_onCLCSendRoomInvitedResultRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CLC_SEND_ROOM_INVITED_RESULT_SUCCESS then 
    end
end

-- 玩家离线邀请开关状态
function ClubRoomService:sendCCLUpdateOfflineInvitedSwitchREQ(switchStatus)
    local request = net.NetworkRequest.new(net.protocol.CCLUpdateOfflineInvitedSwitchREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(switchStatus)
    request.switchStatus = switchStatus
    game.util.RequestHelper.request(request)
end

function ClubRoomService:_onCLCUpdateOfflineInvitedSwitchRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_UPDATE_OFFLINE_INVITED_SWITCH_SUCCESS then
        self._clubService:getUserData():setOfflineInvitesSwitch(request.switchStatus)
    end
end

function ClubRoomService:_sendCGBusinessCardInfoREQ(buffer)
    net.NetworkRequest.new(net.protocol.CGBusinessCardInfoREQ, game.service.LocalPlayerService.getInstance():getGameServerId()):setBuffer(buffer):execute()
end

function ClubRoomService:_onGCBusinessCardInfoRES(response)
    self:dispatchEvent({name = "GCBusinessCardInfoRES", buffer = response:getBuffer()})
end

return ClubRoomService