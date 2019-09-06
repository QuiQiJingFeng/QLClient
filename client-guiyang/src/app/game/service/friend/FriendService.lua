local ns = namespace("game.service.friend")
local FriendData = require("app.game.service.friend.FriendData")
-- 好友申请来源
ns.FRIEND_APPLICANT_SOURCE =
{
	ROOM = 1,
	RECOMMEND = 2,
	SEARCH = 3,
	CLUB_MEMBER = 4
}
local FriendService = class("FriendService")
ns.FriendService = FriendService

-- 单例
function FriendService.getInstance()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		return game.service.LocalPlayerService.getInstance():getFriendService()
	end
	
	return nil
end

function FriendService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");

    self._friendData = FriendData.new()

	self._roomInviteInfo = {}
end

function FriendService:getFriendData()
    return self._friendData
end

function FriendService:getEnterShow()
	local bShow = self._enterGameShow;
	self._enterGameShow = true
	return bShow
end

function FriendService:initialize()
	local requestManager = net.RequestManager.getInstance()

	requestManager:registerResponseHandler(net.protocol.GCQueryFriendListRES.OP_CODE, self, self._onGCQueryFriendListRES)
    requestManager:registerResponseHandler(net.protocol.GCQueryFriendRecommendListRES.OP_CODE, self, self._onGCQueryFriendRecommendListRES)
    requestManager:registerResponseHandler(net.protocol.GCQueryFriendApplicantListRES.OP_CODE, self, self._onGCQueryFriendApplicantListRES)
    requestManager:registerResponseHandler(net.protocol.GCSearchRoleInfoRES.OP_CODE, self, self._onGCSearchRoleInfoRES)
    requestManager:registerResponseHandler(net.protocol.GCSendFriendApplicantRES.OP_CODE, self, self._onGCSendFriendApplicantRES)
    requestManager:registerResponseHandler(net.protocol.GCQueryRoomInvitedFriendInfosRES.OP_CODE, self, self._onGCQueryRoomInvitedFriendInfosRES)
    requestManager:registerResponseHandler(net.protocol.GCSendRoomInvitationRES.OP_CODE, self, self._onGCSendRoomInvitationRES)
    requestManager:registerResponseHandler(net.protocol.GCNotifyRoomInvitationSYN.OP_CODE, self, self._onGCNotifyRoomInvitationSYN)
	requestManager:registerResponseHandler(net.protocol.GCDeleteFriendInfoRES.OP_CODE, self, self._onGCDeleteFriendInfoRES)
	requestManager:registerResponseHandler(net.protocol.GCHandleFriendApplicantRES.OP_CODE, self, self._onGCHandleFriendApplicantRES)
	requestManager:registerResponseHandler(net.protocol.GCCheckFriendShipRES.OP_CODE, self, self._onGCCheckFriendShipRES)
	requestManager:registerResponseHandler(net.protocol.GCSendFriendNotifyDataSYN.OP_CODE, self, self._onGCSendFriendNotifyDataSYN)
end

function FriendService:dispose()
    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 请求好友列表
function FriendService:sendCGQueryFriendListREQ()
	local request = net.NetworkRequest.new(net.protocol.CGQueryFriendListREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCQueryFriendListRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_FRIEND_LIST_SUCCESS then
        -- 做一下数据保存，防止以后好友系统扩张
        self._friendData.friendList = protocol.friendList
        self:dispatchEvent({name = "EVENT_FRIEND_LIST_INFO", friendList = protocol.friendList})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求好友推荐列表
function FriendService:sendCGQueryFriendRecommendListREQ()
	local request = net.NetworkRequest.new(net.protocol.CGQueryFriendRecommendListREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCQueryFriendRecommendListRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_FRIEND_RECOMMEND_LIST_SUCCESS then
		self._friendData.friendRecommendList = protocol.recommendList
		self:dispatchEvent({name = "EVENT_FRIEND_RECOMMEND_LIST_INFO", friendRecommendList = protocol.recommendList});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求好友申请列表
function FriendService:sendCGQueryFriendApplicantListREQ()
	local request = net.NetworkRequest.new(net.protocol.CGQueryFriendApplicantListREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCQueryFriendApplicantListRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_FRIEND_APPLICANT_LIST_SUCCESS then
		self._friendData.friendApplicantList = protocol.applicantList
		self:dispatchEvent({name = "EVENT_FRIEND_APPLICANT_INFO", friendApplicantList = protocol.applicantList});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求查询某个玩家的信息
function FriendService:sendCGSearchRoleInfoREQ(searchId)
	local request = net.NetworkRequest.new(net.protocol.CGSearchRoleInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(searchId)
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCSearchRoleInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_SEARCH_ROLE_INFO_SUCCESS then
		local playerInfo =
		{
			{
				roleId = protocol.roleId,
				roleName =protocol.roleName,
				roleIcon = protocol.roleIcon,
				recommendReason = 3
			}
		}
		self:dispatchEvent({name = "EVENT_FRIEND_RECOMMEND_SEARCH", playerInfo = playerInfo});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求添加好友
function FriendService:sendCGSendFriendApplicantREQ(recipientId, sourceType)
	local request = net.NetworkRequest.new(net.protocol.CGSendFriendApplicantREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(recipientId, sourceType)
	request.recipientId = recipientId
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCSendFriendApplicantRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_SEND_FRIEND_APPLICANT_SUCCESS then
		-- 如果在本地缓存中没有找到该玩家就不进行处理
		local isDelete = self._friendData:deleteRecommend(request.recipientId)
		self:dispatchEvent({name = "EVENT_FRIEND_RECOMMEND_LIST_INFO_CHANGE", isDelete = isDelete});
		game.ui.UIMessageTipsMgr.getInstance():showTips("发送成功")
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求房间好友邀请列表
function FriendService:sendCGQueryRoomInvitedFriendInfosREQ(roomId)
	local request = net.NetworkRequest.new(net.protocol.CGQueryRoomInvitedFriendInfosREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(roomId)
	request.roomId = roomId
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCQueryRoomInvitedFriendInfosRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_ROOM_INVITED_FRIEND_INFOS_SUCCESS then
		if #protocol.friendInfos < 1 then
			game.ui.UIMessageTipsMgr.getInstance():showTips("你暂时没有好友")
			return
		end
		self._friendData.roomInvitedList = protocol.friendInfos
		UIManager:getInstance():show("UIFriendRoomInviteList", request.roomId, protocol.friendInfos)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求发送房间好友邀请
function FriendService:sendCGSendRoomInvitationREQ(roomId, inviteeId)
	local request = net.NetworkRequest.new(net.protocol.CGSendRoomInvitationREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(roomId, inviteeId)
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCSendRoomInvitationRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_SEND_ROOM_INVITATION_SUCCESS then
		self:dispatchEvent({name = "EVENT_ROOM_Friend_INFO_CHENGE", friendInfo = protocol.friendInfo})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 通知接受到房间邀请
function FriendService:_onGCNotifyRoomInvitationSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
    local roomInfo =
    {
		clubId = protocol.clubId, -- 俱乐部id
        clubName = protocol.clubName, -- 俱乐部昵称
        inviterId = protocol.inviterId, -- 邀请人id
        inviterName = protocol.inviterName, -- 邀请人昵称
        inviterIcon = protocol.inviterIcon, -- 邀请人头像
        inviterHeadFrame = protocol.inviterHeadFrame, --玩家头像框
        roomId = protocol.roomId, -- 房间id
        roundType = protocol.roundType, -- 房间圈/局规则
        gamePlays = protocol.gamePlays,-- 房间规则
		sourceType = protocol.sourceType, -- 房间邀请的来源（1：立即组局，2：好友邀请）
    }
	local ui = protocol.clubId == 0 and "UIFriendRoomInvite" or "UIClubRoomInvite"

	table.insert(self._roomInviteInfo, 1, roomInfo)
    if UIManager:getInstance():getIsShowing(ui) then
        UIManager:getInstance():destroy(ui)
    end

	-- 在房间内不再接受邀请
	if game.service.RoomService:getInstance():getRoomId() ~= 0 then
		return
	end

    if self:_isTodayAcceptInvitation() then
        return
	end
	scheduleOnce(function()
		UIManager:getInstance():show(ui, roomInfo)
	end, 0)
end

-- 做一下房间邀请信息缓存
function FriendService:getClubRoomInviteInfo(ui)
    if UIManager:getInstance():getIsShowing(ui) then
        UIManager:getInstance():destroy(ui)
    end

    if self:_isTodayAcceptInvitation() then
        return
    end

    table.remove(self._roomInviteInfo, 1)
    if #self._roomInviteInfo == 0 then
        return
    end

    local roomInfo = self._roomInviteInfo[1]
    
	UIManager:getInstance():show(ui, roomInfo)
end

-- 判断今天是否要接受好友邀请
function FriendService:_isTodayAcceptInvitation()
	local time = self:loadLocalStorageInvitationTime():getInvitationTime()
	local newTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
	-- 现在时间跟本地时间对比
	local currentDate = string.split(os.date("%y-%m-%d", newTime / 1000), '-')
	local lastLoginDate = string.split(os.date("%y-%m-%d", time / 1000), '-')
	if currentDate[1] == currentDate[1] then
		if currentDate[2] == lastLoginDate[2] then
			if currentDate[3] == lastLoginDate[3] then
				self:clearClubRoomInviteInfo()
				return true
			end
		end
	end
	
	return false
end

function FriendService:setIsAcceptInvitation(isAcceptInvitation)
    self._isAcceptInvitation = isAcceptInvitation
end

-- 清除缓存
function FriendService:clearClubRoomInviteInfo()
    self._roomInviteInfo = {}
end

-- 请求删除好友
function FriendService:sendCGDeleteFriendInfoREQ(deleteRoleId)
	local request = net.NetworkRequest.new(net.protocol.CGDeleteFriendInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(deleteRoleId)
	request.deleteRoleId = deleteRoleId
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCDeleteFriendInfoRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_DELETE_FRIEND_INFO_SUCCESS then
		self._friendData:deleteFriend(request.deleteRoleId)
		self:dispatchEvent({name = "EVENT_FRIEND_DELETE", deleteRoleId = request.deleteRoleId});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求处理好友申请的请求
function FriendService:sendCGHandleFriendApplicantREQ(opType, applicantId)
	local request = net.NetworkRequest.new(net.protocol.CGHandleFriendApplicantREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(opType, applicantId)
	request.applicantId = applicantId
	request.opType = opType
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCHandleFriendApplicantRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_HANDLE_FRIEND_APPLICANT_SUCCESS then
		if request.opTyp == 1 then
			game.ui.UIMessageTipsMgr.getInstance():showTips("操作成功,已成为好友")
		end
		self:dispatchEvent({name = "EVENT_FRIEND_APPLICANT_INFO_CHANGE", applicantId = request.applicantId})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求检测是否是好友关系
function FriendService:sendCGCheckFriendShipREQ(checkRoleId)
	local a = game.service.LocalPlayerService:getInstance():getGameServerId()
	local request = net.NetworkRequest.new(net.protocol.CGCheckFriendShipREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(checkRoleId)
	game.util.RequestHelper.request(request)
end

function FriendService:_onGCCheckFriendShipRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_CHECK_FRIENDSHIP_SUCCESS then
		self:dispatchEvent({name = "EVENT_CHECK_FRIEND_SHIP", isFriend = protocol.isFriend})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 好友申请红点推送
function FriendService:_onGCSendFriendNotifyDataSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local dotArray = game.service.LocalPlayerService:getInstance():getDotArray()
	local index = table.indexof(dotArray, net.protocol.NMDotType.FRIEND)
	local add = protocol.applicantCount ~= 0
	if index == false and add then
		table.insert(dotArray, net.protocol.NMDotType.FRIEND)
	elseif add == false and index ~= false then
		table.remove(dotArray, index)
	end
	self:dispatchEvent({name = "EVENT_FRIEND_RED_CHAGE"})
end

function FriendService:isApplicant()
	return table.indexof(game.service.LocalPlayerService:getInstance():getDotArray(), net.protocol.NMDotType.FRIEND) ~= false
end

-- 保存一个本地时间
local LocalStorageInvitationTime = class("LocalStorageInvitationTime")
function LocalStorageInvitationTime:ctor()
	self._invitationTime = 0
end

function LocalStorageInvitationTime:getInvitationTime()
	return self._invitationTime
end

function LocalStorageInvitationTime:setInvitationTime(invitationTime)
	self._invitationTime = invitationTime
end

function FriendService:loadLocalStorageInvitationTime()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalStorageInvitationTime", LocalStorageInvitationTime)
end

function FriendService:saveLocalStorageInvitationTime(localStorageInvitationTime)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalStorageInvitationTime", localStorageInvitationTime)
end

return FriendService