local ClubMemberService = class("ClubMemberService")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function ClubMemberService:ctor(cs)
    -- 绑定事件系统
	cc.bind(self, "event");

    self._clubService = cs
end

function ClubMemberService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CLCAllInvitationRES.OP_CODE, self, self._onCLCAllInvitationRES)
    requestManager:registerResponseHandler(net.protocol.CLCClubInvitationResultRES.OP_CODE, self, self._onCLCClubInvitationResultRES)
    requestManager:registerResponseHandler(net.protocol.CLCSendClubInvitationRES.OP_CODE, self, self._onCLCSendClubInvitationRES)
    requestManager:registerResponseHandler(net.protocol.CLCQuitClubRES.OP_CODE, self, self._onCLCQuitClubRES)
    requestManager:registerResponseHandler(net.protocol.CLCClubMembersRES.OP_CODE, self, self._onCLCClubMembersRES)
    requestManager:registerResponseHandler(net.protocol.CLCAccedeToClubInfoRES.OP_CODE, self, self._onCLCAccedeToClubInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCAccedeToClubRES.OP_CODE, self, self._onCLCAccedeToClubRES)
    requestManager:registerResponseHandler(net.protocol.CLCCreateClubRES.OP_CODE, self, self._onCLCCreateClubRES)
    requestManager:registerResponseHandler(net.protocol.CLCReleaseRecommandInfoRES.OP_CODE, self, self._onCLCReleaseRecommandInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCCancelRecommandInfoRES.OP_CODE, self, self._onCLCCancelRecommandInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryReleaseStatusRES.OP_CODE, self, self._onCLCQueryReleaseStatusRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyMemberRemarkRES.OP_CODE, self, self._onCLCModifyMemberRemarkRES)

    self._clubService:addEventListener("EVENT_CLUB_DATA_SYN", handler(self, self._changendClubDta), self)
end

function ClubMemberService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);

    self._clubService:removeEventListenersByTag(self)
    
    -- 解绑事件系统
	cc.unbind(self, "event");
end

function ClubMemberService:_changendClubDta(event)
    local protocolBuf = event.chanendClubData
    local newClubIds = event.chanendNewClubIds
    local deletedClubs = event.chanendDeletedClubs
    -- 用户 - 被踢
    if protocolBuf.notifyType == ClubConstant:getClubNotifyType().USER_BEKICKED then
        -- clubDatas包含退出的亲友圈
        Macro.assertFalse(#protocolBuf.clubDatas == 1)
        local deletedClub = self._clubService:getClubList():removeClub(protocolBuf.clubDatas[1].clubId)
        Macro.assertFalse(deletedClub ~= nil and deletedClub ~= false)        
        table.insert(deletedClubs, deletedClub)
        local localStorageClubInfo = self._clubService:loadLocalStorageClubInfo()
        local lastState = GameFSM.getInstance():getCurrentState().class.__cname
        -- 判断是不是被当前亲友圈踢出，如果是就本地清除缓存
        if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and 
		localStorageClubInfo:getClubId() == deletedClub.info.clubId then
            localStorageClubInfo:setClubId(0)
            self._clubService:saveLocalStorageClubInfo(localStorageClubInfo)
            game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_DISBAND"})
            if lastState == "GameState_Club" or lastState == "GameState_League" then
                GameFSM.getInstance():enterState("GameState_Lobby")
            end
        end
        
        if lastState == "GameState_Club" or lastState == "GameState_Lobby" then
            game.ui.UIMessageBoxMgr.getInstance():show(string.format(config.STRING.CLUBMEMBERSERVICE_STRING_100, deletedClub.info.clubName) , {"确定"})
        end

        -- 清除玩家联盟id
        game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setLeagueId(0)
        game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setClubId(0)

    -- 用户 - 加入亲友圈
    elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().USER_JOINCLUB then
        -- clubDatas包含新加的亲友圈
        Macro.assertFalse(#protocolBuf.clubDatas == 1)
        local newClubInfo = protocolBuf.clubDatas[1]
        local club = self._clubService:getClub(newClubInfo.clubId)
        if Macro.assertFalse(club == nil) then
            club = self._clubService:getClubList():addClub(newClubInfo)
            table.insert(newClubIds, club.info.clubId)
        else
            -- 更新现有数据
            club.oldInfo = club.oldInfo and club.info
            club.info = clubInfo
        end
        self:_sendCCLAllInvitationREQ(ClubConstant:getClubInvitationSourceType().NORMAL)
    -- 玩家
    elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().USER_JOINCLUB
            or protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_APPLICATION
            or protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_TASK then
        -- clubDatas包含改变的
        Macro.assertFalse(#protocolBuf.clubDatas == 1)
        local updateClubInfo = protocolBuf.clubDatas[1]
        local club = self._clubService:getClub(updateClubInfo.clubId)
        if Macro.assertTrue(club == nil) then
            club = self._clubService:getClubList():addClub(updateClubInfo)
            table.insert(newClubIds, club.info.clubId)
        else
            -- 更新现有数据
            club.oldInfo = club.oldInfo and club.info
            club.info = updateClubInfo
        end
    -- 成员头衔变动
    elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().USER_TITLE then
        local updateClubData = protocolBuf.clubDatas[1]

        self:dispatchEvent({ name = "EVENT_CLUB_PERMISSIONS_CHANGED", clubId = updateClubData.clubId});
    -- 更细亲友圈邀请信息
    elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().USER_INVITATION then
        self:_sendCCLAllInvitationREQ(ClubConstant:getClubInvitationSourceType().NORMAL);
    end
end

-- 尝试请求玩家邀请信息
function ClubMemberService:tryQueryDirtyUserInvitations()
    self:_sendCCLAllInvitationREQ(ClubConstant:getClubInvitationSourceType().NORMAL)
end

-- 请求用户邀请列表
-- sourceType 邀请类型
function ClubMemberService:_sendCCLAllInvitationREQ(sourceType)
    local request = net.NetworkRequest.new(net.protocol.CCLAllInvitationREQ, self._clubService:getClubServiceId())
    request.sourceType = sourceType
    request:getProtocol():setData(sourceType)
    game.util.RequestHelper.request(request)
end

-- 邀请信息返回
function ClubMemberService:_onCLCAllInvitationRES(response)
    local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_ALL_CLUB_INVITATION_SUCCESS then
        -- 更新邀请数据
        -- 判断是不是用户推荐
        if request.sourceType == ClubConstant:getClubInvitationSourceType().RECOMMAND then
            self._clubService:getUserData().RecommandInvitation = clone(protocol.invitationList)
            self:dispatchEvent({ name = "EVENT_USER_RECOMMAND_INVITATION_RETRIVED", unprocessedCount = protocol.unprocessedCount});
        elseif request.sourceType == ClubConstant:getClubInvitationSourceType().NORMAL then
            self._clubService:getUserData().invitations = clone(protocol.invitationList)
            self:dispatchEvent({ name = "EVENT_USER_INVITATION_RETRIVED"});
        end
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

-- 邀请信息结果
-- accept 同意拒绝
-- sourceType 邀请类型
function ClubMemberService:sendCCLClubInvitationResultREQ(invitation, accept, sourceType)
    -- 0拒绝邀请，1接受邀请并成为成员，2接受邀请等待群主审批
    local opType = 0
    if sourceType == ClubConstant:getClubInvitationSourceType().RECOMMAND then
        if accept == true then
            opType = 1
        else
            opType = 0
        end
    elseif sourceType == ClubConstant:getClubInvitationSourceType().NORMAL then
        if accept == true then
            opType = 1
        else
            opType = 0
        end
    end

    -- 发送协议
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local request = net.NetworkRequest.new(net.protocol.CCLClubInvitationResultREQ, self._clubService:getClubServiceId())
    request.sourceType = sourceType
    request:getProtocol():setData(invitation.clubId, opType, areaId)
    game.util.RequestHelper.request(request)
end

-- 邀请信息返回
-- 注意处理，返回的数据，有的需要删除此条消息
function ClubMemberService:_onCLCClubInvitationResultRES(response)
    local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
    local requestProto = response:getRequest():getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CLUB_INVITATION_RESULT_SUCCESS then
        -- 判断是不是用户推荐
        if request.sourceType == ClubConstant:getClubInvitationSourceType().RECOMMAND then
             -- 替换邀请数据
            -- self._clubService:getUserData():replaceRecommandInvitation(requestProto.clubId, protocol.invitation.inviterId, protocol.invitation)
            -- self:dispatchEvent({ name = "EVENT_USER_RECOMMAND_INVITATION_CHANGED", clubId = requestProto.clubId, inviterId = protocol.invitation.inviterId, unprocessedCount = protocol.unprocessedCount});
            
            -- 如果换回原来的邀请界面时，只需要把下面的注释掉，放开上面的代码
            self._clubService:getUserData():replaceInvitation(requestProto.clubId, protocol.invitation.inviterId, protocol.invitation)
            -- 发送更新事件
            self:dispatchEvent({ name = "EVENT_USER_INVITATION_CHANGED", clubId = requestProto.clubId, inviterId = protocol.invitation.inviterId});
        elseif request.sourceType == ClubConstant:getClubInvitationSourceType().NORMAL then
            -- 0拒绝邀请，1接受邀请并成为成员，2接受邀请等待群主审批
            if protocol.opType ~= 2 then
                -- 删除邀请数据
                self._clubService:getUserData():removeInvitation(requestProto.clubId, protocol.invitation.inviterId)
            else
                -- 替换邀请数据
                self._clubService:getUserData():replaceInvitation(requestProto.clubId, protocol.invitation.inviterId, protocol.invitation)
            end
            -- 发送更新事件
            self:dispatchEvent({ name = "EVENT_USER_INVITATION_CHANGED", clubId = requestProto.clubId, inviterId = protocol.invitation.inviterId});
        end
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

-- 从亲友圈发起邀请
function ClubMemberService:sendCCLSendClubInvitationREQ(clubId, inviterId, sourceType, invitedMsg)
    local request = net.NetworkRequest.new(net.protocol.CCLSendClubInvitationREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, inviterId, sourceType, invitedMsg)
    request.clubId = clubId
    request.inviterId = inviterId
    game.util.RequestHelper.request(request)
end

function ClubMemberService:_onCLCSendClubInvitationRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    local isSuccess = protocol.result == net.ProtocolCode.CLC_SEND_CLUB_INVITATION_SUCCESS
    event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = not isSuccess, isDestroy = isSuccess})

    if isSuccess then
        local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
        local club = self._clubService:getClub(request.clubId)

        if club:isPermissions(roleId) then
            game.ui.UIMessageTipsMgr.getInstance():showTips("邀请成功，玩家已加入")
            if club:getLeagueId() == 0 then 
                self:sendCCLClubMembersREQ(request.clubId)
            else --大联盟内的俱乐部邀请成功之后请求一下最新成员
                game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Suc_SuperLeague_Invite)
                event.EventCenter:dispatchEvent({ name = "EVENT_CLUB_INVITE_SUC" })
            end
        else
            game.ui.UIMessageTipsMgr.getInstance():showTips("您已成功发送邀请")
        end
        self:dispatchEvent({name = "EVENT_CLUB_RECOMMEND_INVITATION_CHANGED", clubId = request.clubId, inviterId = request.inviterId, todayInvitedTimes = protocol.todayInvitedTimes})
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

-- 请求退出亲友圈
function ClubMemberService:sendCCLQuitClubREQ(clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLQuitClubREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId)
    game.util.RequestHelper.request(request)
end

-- 退出亲友圈的返回
function ClubMemberService:_onCLCQuitClubRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CLUB_QUIT_SUCCESS then
        local requestProto = response:getRequest():getProtocol():getProtocolBuf()
        -- 服务器不会会推送亲友圈变化, 直接删除亲友圈
        self._clubService:getClubList():removeClub(requestProto.clubId)

        self:dispatchEvent({ name = "EVENT_USER_CLUB_QUIT_INFO", clubId = requestProto.clubId});
        game.ui.UIMessageTipsMgr.getInstance():showTips("退出成功")
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

-- 请求成员信息
function ClubMemberService:sendCCLClubMembersREQ(clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLClubMembersREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId)
    game.util.RequestHelper.request(request)
end

-- 返回亲友圈成员
function ClubMemberService:_onCLCClubMembersRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CLUB_MEMBERS_SUCCESS then
        local requestProto = response:getRequest():getProtocol():getProtocolBuf()

        -- 设置数据
        local club = self._clubService:getClub(requestProto.clubId)
        if Macro.assertFalse(club ~= nil) then
            club.members = protocol.members
            self:dispatchEvent({ name = "EVENT_CLUB_MEMBER_DATA_RETRIVED", clubId = requestProto.clubId, maxMemberCount = protocol.maxMemberCount, maxAssistantCount = protocol.maxAssistantCount});
        end
    else
        self._clubService:_showCommonTips(protocol.result)
    end
end

------------------------------------

-- 通过邀请码加入亲友圈
function ClubMemberService:sendCCLAccedeToClubInfoREQ(invitationCode)
    local request = net.NetworkRequest.new(net.protocol.CCLAccedeToClubInfoREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(invitationCode)
    game.util.RequestHelper.request(request)
end

-- 通过邀请码加入亲友圈的返回信息
function ClubMemberService:_onCLCAccedeToClubInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()

    local isSuccess = protocol.result == net.ProtocolCode.CLC_ACCEDE_TO_CLUB_INFO_SUCCESS
    event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = not isSuccess, isDestroy = isSuccess})

    if isSuccess then
        local str = " 是否申请加入["..protocol.clubName..config.STRING.CLUBMEMBERSERVICE_STRING_101..protocol.managerName.."\n\n 人数:"..protocol.memberCount.."/"..protocol.maxMemberCount;
        --亲友圈邀请码正确
        game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定","取消"}, function()
            -- --判断亲友圈是否满员
            if protocol.memberCount < protocol.maxMemberCount then
                --发送申请
                local requestProto = response:getRequest():getProtocol():getProtocolBuf()
                self:sendCCLAccedeToClubREQ(requestProto.invitationCode, game.service.LocalPlayerService:getInstance():getRoleId());
            else
                game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBMEMBERSERVICE_STRING_102)
            end
        end,nil,nil,nil,0)
    elseif protocol.result == net.ProtocolCode.CLC_ACCEDE_TO_CLUB_INFO_FAILED_ERROR_CODE then
        game.ui.UIMessageTipsMgr.getInstance():showTips("邀请码输入有误，请重新输入")
    else
        --亲友圈邀请码错误
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求加入亲友圈
function ClubMemberService:sendCCLAccedeToClubREQ(invitationCode, inviterId)
    local request = net.NetworkRequest.new(net.protocol.CCLAccedeToClubREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(invitationCode, inviterId)
    game.util.RequestHelper.request(request)
end

-- 请求加入亲友圈的返回结果
function ClubMemberService:_onCLCAccedeToClubRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_ACCEDE_CLUB_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBMEMBERSERVICE_STRING_103)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 创建亲友圈
function ClubMemberService:sendCCLCreateClubREQ(clubName, clubIcon)
    local request = net.NetworkRequest.new(net.protocol.CCLCreateClubREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubName, clubIcon)
    game.util.RequestHelper.request(request)
end

function ClubMemberService:_onCLCCreateClubRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local isSuccess = protocol.result == net.ProtocolCode.CLC_CREATE_CLUB_SUCCESS
    if isSuccess then 
        game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBMEMBERSERVICE_STRING_104)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
    self:dispatchEvent({ name = "EVENT_CLUB_CREATE_RESULT", result = isSuccess})
end


-- 请求发布推荐信息
function ClubMemberService:sendCCLReleaseRecommandInfoREQ(areaId, releaseMsg, releaseMsgType)
    local request = net.NetworkRequest.new(net.protocol.CCLReleaseRecommandInfoREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(areaId, releaseMsg, releaseMsgType)
    game.util.RequestHelper.request(request)
end

function ClubMemberService:_onCLCReleaseRecommandInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_RELEASE_RECOMMAND_INFO_SUCCESS then 
        self:dispatchEvent({ name = "EVENT_CLUB_RECOMMENDINFO_RETRIVED", isVisible = true, releaseTime = -1})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求撤销推荐信息
function ClubMemberService:sendCCLCancelRecommandInfoREQ(areaId)
    local request = net.NetworkRequest.new(net.protocol.CCLCancelRecommandInfoREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(areaId)
    game.util.RequestHelper.request(request)
end

function ClubMemberService:_onCLCCancelRecommandInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CANCEL_RECOMMAND_INFO_SUCCESS then 
        self:dispatchEvent({ name = "EVENT_CLUB_RECOMMENDINFO_RETRIVED", isVisible = false, releaseTime = protocol.releaseTime})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求推荐信息发布的状态
function ClubMemberService:sendCCLQueryReleaseStatusREQ(area)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryReleaseStatusREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(area)
    game.util.RequestHelper.request(request)
end

function ClubMemberService:_onCLCQueryReleaseStatusRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_QUERY_RELEASE_STATUS_SUCCESS then
        local releaseInfo =
        {
            checkTimes = protocol.checkTimes,
            invitedTimes = protocol.invitedTimes,
            releaseTime = protocol.releaseTime,
            isInRecommandList = protocol.isInRecommandList,
            isFirstTime = protocol.isFirstTime,
        }
        self:dispatchEvent({ name = "EVENT_CLUB_RELEASE_STATUS", releaseInfo = releaseInfo})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

--请求修改备注
function ClubMemberService:sendCCLModifyMemberRemarkREQ(clubId, roleId, remark)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyMemberRemarkREQ, self._clubService:getClubServiceId())
    request:getProtocol():setData(clubId, roleId, remark)
    request.clubId = clubId
    request.roleId = roleId
    request.remark = remark
    game.util.RequestHelper.request(request)
end

function ClubMemberService:_onCLCModifyMemberRemarkRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_MODIFY_MEMBER_REMARK_SUCCESS then
        self:dispatchEvent({ name = "EVENT_CLUB_REMARK_CHANGE", clubId = request.clubId, roleId = request.roleId, remark = request.remark})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

return ClubMemberService
