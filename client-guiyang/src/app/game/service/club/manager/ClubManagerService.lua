local ClubManagerService = class("ClubManagerService")
local ClubConstant = require("app.game.service.club.data.ClubConstant")


function ClubManagerService:ctor(cs)
	-- 绑定事件系统
	cc.bind(self, "event");
	
	self._clubService = cs
end

function ClubManagerService:initialize()
	local requestManager = net.RequestManager.getInstance()
	
	requestManager:registerResponseHandler(net.protocol.CLCKickOffMemberRES.OP_CODE, self, self._onCLCKickOffMemberRES)
	requestManager:registerResponseHandler(net.protocol.CLCClubApplicantListRES.OP_CODE, self, self._onCLCClubApplicantListRES)
	requestManager:registerResponseHandler(net.protocol.CLCClubApplicantRES.OP_CODE, self, self._onCLCClubApplicantRES)
	requestManager:registerResponseHandler(net.protocol.CLCClubBanGameplayRES.OP_CODE, self, self._onCLCClubBanGameplayRES)
	requestManager:registerResponseHandler(net.protocol.CLCModifyClubInfoRES.OP_CODE, self, self._onCLCModifyClubInfoRES)
	requestManager:registerResponseHandler(net.protocol.CLCModifyClubNoticeRES.OP_CODE, self, self._onCLCModifyClubNoticeRES)
	requestManager:registerResponseHandler(net.protocol.CLCRemoveClubRES.OP_CODE, self, self._onCLCRemoveClubRES)
	requestManager:registerResponseHandler(net.protocol.CLCModifyMemberTitleRES.OP_CODE, self, self._onCLCModifyMemberTitleRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryOperationRecordRES.OP_CODE, self, self._onCLCQueryOperationRecordRES)
	requestManager:registerResponseHandler(net.protocol.CLCDestroyRoomRES.OP_CODE, self, self._onCLCDestroyRoomRES)
	requestManager:registerResponseHandler(net.protocol.CLCModifyClubSwitchRES.OP_CODE, self, self._onCLCModifyClubSwitchRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryRecommendPlayerListRES.OP_CODE, self, self._onCLCQueryRecommendPlayerListRES)
	requestManager:registerResponseHandler(net.protocol.CLCModifyClubPresetGameplaysRES.OP_CODE, self, self._onCLCModifyClubPresetGameplaysRES)
	
	self._clubService:addEventListener("EVENT_CLUB_DATA_SYN", handler(self, self._changendClubDta), self)
end

function ClubManagerService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	
	self._clubService:removeEventListenersByTag(self)
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

function ClubManagerService:_changendClubDta(event)
	local protocolBuf = event.chanendClubData
	local newClubIds = event.chanendNewClubIds
	local deletedClubs = event.chanendDeletedClubs
	-- 亲友圈公告信息
	if protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_NOTICE then
		local updateClubInfo = protocolBuf.clubDatas[1]
		local club = self._clubService:getClub(updateClubInfo.clubId)
		if club ~= nil and club.data ~= nil then
			club.data.clubNotice = updateClubInfo.clubNotice
			self:dispatchEvent({name = "EVENT_CLUB_INFO_NOTICE_CHANGED", clubId = updateClubInfo.clubId, clubNotice = updateClubInfo.clubNotice});
		end
		-- 亲友圈群主限制玩法
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_GAMEPLAY then
		local isHaveChange = false;
		local changedCludId = nil;
		local clubData = protocolBuf.clubDatas[1];  -- 每次只推一个
		local club = self._clubService:getClub(clubData.clubId);
		if club then
			club.data = club.data or {}
			club.data.banGameplays = clone(clubData.banGameplays);
			club.data.presetGameplays = clone(clubData.presetGameplays);
			self:dispatchEvent({name = "EVENT_CLUB_BAN_GAMEPLAY_CHANGED", clubId = clubData.clubId});
		end
		-- 亲友圈图标和名字修改推送
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_INFO then
		local updateClubData = protocolBuf.clubDatas[1]
		local club = self._clubService:getClub(updateClubData.clubId)
		if club then
			-- 更新数据
			club.info = updateClubData
			club.data = club.data or {}
			club.data.clubIcon = updateClubData.clubIcon
			club.data.clubName = updateClubData.clubName
			self:dispatchEvent({name = "EVENT_CLUB_INFO_CHANGED", clubId = updateClubData.clubId});
		end
		-- 房卡变化
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().USER_MODIFYCARD then
		local updateClubData = protocolBuf.clubDatas[1]
		local clubId = 0
		local clubCardCount = 0
		if updateClubData then
			clubId = updateClubData.clubId
			clubCardCount = updateClubData.clubCardCount
		else
			clubId = self._clubService:loadLocalStorageClubInfo():getClubId()
			clubCardCount = protocolBuf.userInfo.clubCardCount
		end
		local club = self._clubService:getClub(clubId)

		if club ~= nil then
			club.info.clubCardCount = clubCardCount
			self:dispatchEvent({name = "EVENT_USER_INFO_CARD_COUNT_CHANGED"});
		end

		if game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague() then
			game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setCardNum(clubCardCount)
			self:dispatchEvent({name = "EVENT_LEAGUE_CARD_INFO"})
		end
		-- 亲友圈封停
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_SEALED then
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
		
		local localStorageClubInfo = self._clubService:loadLocalStorageClubInfo()
		if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and localStorageClubInfo:getClubId() == updateClubInfo.clubId then
			localStorageClubInfo:setClubId(0)
			self._clubService:saveLocalStorageClubInfo(localStorageClubInfo)
			game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBMANAGERSERVICE_STRING_100)
			GameFSM.getInstance():enterState("GameState_Lobby")
		end
		-- 亲友圈设置开关推送
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_SWITCHES then
		Macro.assertFalse(#protocolBuf.clubDatas == 1)
		local updateClubInfo = protocolBuf.clubDatas[1]
		local club = self._clubService:getClub(updateClubInfo.clubId)
		if club and club.data then
			club.data.switches = updateClubInfo.switches
			self:dispatchEvent({name = "EVENT_CLUB_SETTING_CHANGED", clubId = updateClubInfo.clubId});
		end
	end
end

-- 请求解散房间
function ClubManagerService:sendCCLDestroyRoomREQ(roomId, clubId, leagueId)
	local request = net.NetworkRequest.new(net.protocol.CCLDestroyRoomREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(roomId, clubId, leagueId)
	game.util.RequestHelper.request(request)
end

-- 请求解散房间返回结果
function ClubManagerService:_onCLCDestroyRoomRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_DESTROY_ROOM_SUCCESS then
		-- 设置数据
		local requestProto = response:getRequest():getProtocol():getProtocolBuf()
		local leagueId = requestProto.leagueId
		--leagueId为0 不在联盟赛事房间
		if leagueId == 0 then
			local club = self._clubService:getClub(requestProto.clubId)
			if Macro.assertFalse(club ~= nil ) then
				club.rooms = protocol.clubTableList
				self:dispatchEvent({name = "EVENT_CLUB_ROOM_DATA_RETRIVED", clubId = requestProto.clubId});
			end
		end 
		game.ui.UIMessageBoxMgr.getInstance():show("解散成功。", {"确定"});
	end
end

-- 请求修改亲友圈名称和图标
function ClubManagerService:sendCCLModifyClubInfoREQ(clubId, clubName, clubIcon)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyClubInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, clubName, clubIcon)
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCModifyClubInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_MODIFY_CLUBINFO_SUCCESS then
		game.ui.UIMessageTipsMgr.getInstance():showTips("修改成功")

		local leagueService = game.service.bigLeague.BigLeagueService:getInstance()
		local isShow = UIManager:getInstance():getIsShowing("UIBigLeagueManager")
		if leagueService and isShow then 
			leagueService:dispatchEvent({name = "EVENT_LEAGUE_CHANGE_B"})
		end 
	else 
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 解散亲友圈
function ClubManagerService:sendCCLRemoveClubREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLRemoveClubREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	request:getProtocol():setData(clubId)
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCRemoveClubRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_REMOVE_CLUB_SUCCESS then
		local localStorageClubInfo = self._clubService:loadLocalStorageClubInfo()
		localStorageClubInfo:setClubId(0)
		self._clubService:saveLocalStorageClubInfo(localStorageClubInfo)
		GameFSM.getInstance():enterState("GameState_Lobby")
	end
end

-- 请求管理
function ClubManagerService:sendCCLModifyMemberTitleREQ(clubId, memberId, title)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyMemberTitleREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, memberId, title)
	request.title = title
	request.clubId = clubId
	request.memberId = memberId
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCModifyMemberTitleRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_MODIFY_MEMBER_TITLE_SUCCESS then
		game.ui.UIMessageTipsMgr.getInstance():showTips("设置成功")
		if game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId() == 0 then
			local data =
			{
				clubId = request.clubId,
				title = request.title,
				memberId = request.memberId,
			}
			self:dispatchEvent({name = "EVENT_CLUB_MANAGER_CHANGED", playerInfo = data})
		else
			game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setMemberTitle(request.memberId, request.title)
			game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = request.memberId})
		end


	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求管理操作记录
function ClubManagerService:sendCCLQueryOperationRecordREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryOperationRecordREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId)
	request.clubId = clubId
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCQueryOperationRecordRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_OPERATION_RECORD_SUCCESS then
		self:dispatchEvent({name = "EVENT_CLUB_ADMINISTEATOR_OPERATION_CHANGED", clubId = request.clubId, recordList = protocol.recordList});
	end
end

-- 请求修改亲友圈功能开关
function ClubManagerService:sendCCLModifyClubSwitchREQ(clubId, switchType, switchValue)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyClubSwitchREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, switchType, switchValue)
	request.switchType = switchType
	request.switchValue = switchValue
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCModifyClubSwitchRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_MODIFY_CLUB_SWITCH_SUCCESS then
		if request.switchType == ClubConstant:getClubSwitchType().FROZEN_ROOM then
			if request.switchValue then
				game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBMANAGERSERVICE_STRING_101)
			else
				game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBMANAGERSERVICE_STRING_102)
			end
		else
			game.ui.UIMessageTipsMgr.getInstance():showTips("设置成功")

			local leagueService = game.service.bigLeague.BigLeagueService:getInstance()
			local isShow = UIManager:getInstance():getIsShowing("UIBigLeagueManager")
			if leagueService and isShow then 
				leagueService:dispatchEvent({name = "EVENT_LEAGUE_CHANGE_B"})
			end 
		end
	end
end

-- 请求修改亲友圈公告（牌桌界面）
function ClubManagerService:sendCCLModifyClubNoticeREQ(clubId, notice)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyClubNoticeREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, notice)
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCModifyClubNoticeRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_MODIFY_CLUB_NOTICE_SUCCESS then
		-- game.ui.UIMessageBoxMgr.getInstance():show("亲友圈通知已发布，客服审核通过后即可展示\n工作日预计1小时内审核完成!", {"确定"}, function()
		game.ui.UIMessageTipsMgr.getInstance():showTips("修改成功")
		if UIManager:getInstance():getIsShowing("UIClubEditNotice") then
			UIManager:getInstance():hide("UIClubEditNotice")
		end
		if UIManager:getInstance():getIsShowing("UIBigleagueEditNotice") then
			UIManager:getInstance():hide("UIBigleagueEditNotice")
		end
		-- end, {}, true)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 群主禁用某些玩法
-- clubId,  
-- areaId,  地区玩法的编码  如贵阳，RoomSetting.GamePlay.REGION_GUIYANG,
-- 传0表示该亲友圈所有地区的都限制,根据产品需求，目前只需要支持通用地区的
-- gameplays 禁止的规则数组，如本鸡 CHICKEN_BENJI
function ClubManagerService:sendCCLClubBanGameplayREQ(clubId, areaId, gameplays)
	local request = net.NetworkRequest.new(net.protocol.CCLClubBanGameplayREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, areaId, gameplays)
	game.util.RequestHelper.request(request)
end

-- 禁用结果返回
function ClubManagerService:_onCLCClubBanGameplayRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CLUB_BAN_GAMEPLAY_SUCCESS then
		game.ui.UIMessageTipsMgr.getInstance():showTips("设置成功");
		local isShowingCreateRoom = UIManager:getInstance():getIsShowing("UICreateRoom"); 
    	if isShowingCreateRoom then
        	UIManager:getInstance():destroy("UICreateRoom");
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 群主请求把玩家踢出 
function ClubManagerService:sendCCLKickOffMemberREQ(clubId, roleId, leagueId, partnerId)
	local request = net.NetworkRequest.new(net.protocol.CCLKickOffMemberREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, roleId, leagueId, partnerId)
	game.util.RequestHelper.request(request)
end

-- 接受踢出结果
function ClubManagerService:_onCLCKickOffMemberRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_KICK_OFF_MEMBER_SUCCESS then
		local requestProto = response:getRequest():getProtocol():getProtocolBuf()
		if game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId() == 0 then
			-- 修改数据
			local club = self._clubService:getClub(requestProto.clubId)
			if Macro.assertFalse(club ~= nil) then
				-- 删除指定玩家
				local memberIdx = club:indexOfMember(requestProto.roleId)
				if memberIdx ~= false then
					--本地存储这个踢出请求
					local QUIT_MEMBER = 2;
					self._clubService:addLocalApplication(requestProto.clubId,
							{
								roleId = club.members[memberIdx].roleId,
								roleName = club.members[memberIdx].roleName,
								isManager = false,
								applyTimestamp = math.ceil(kod.util.Time.now() * 1000),
								status = QUIT_MEMBER
							});

					table.remove(club.members, memberIdx)
				end
				self:dispatchEvent({name = "EVENT_CLUB_MEMBER_DATA_CHANGED", clubId = requestProto.clubId, memberId = requestProto.roleId});
				game.ui.UIMessageTipsMgr.getInstance():showTips("踢出成功")
				Logger.info("Player: " .. requestProto.roleId .. ", has been kicked out")
			end
		else
			game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():deleteMember(requestProto.roleId)
			game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = requestProto.roleId})
			game.ui.UIMessageTipsMgr.getInstance():showTips("踢出成功")
			Logger.info("Player: " .. requestProto.roleId .. ", has been kicked out")
		end
	else
		self._clubService:_showCommonTips(protocol.result)
		end
end

-- 请求亲友圈申请人员列表
function ClubManagerService:sendCCLClubApplicantListREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLClubApplicantListREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId)
	game.util.RequestHelper.request(request)
end

-- 请求申请人列表
function ClubManagerService:_onCLCClubApplicantListRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local requestProto = response:getRequest():getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CLUB_APPLICANTS_SUCCESS then
		local club = self._clubService:getClub(requestProto.clubId)
		if Macro.assertFalse(club ~= nil) then
			club.application = protocol.applicants
			--status 是记录成员状态的,为空在后面判断的时候会报错
			for i, v in ipairs(club.application) do
				v.status = false;
			end
			
			self:dispatchEvent({name = "EVENT_CLUB_APPLICATION_DATA_RETRIVED", clubId = requestProto.clubId});			
		end
	else
		self._clubService:_showCommonTips(protocol.result)
	end
end

-- 同意/拒绝申请的结果
function ClubManagerService:sendCCLClubApplicantREQ(clubId, roleId, optype)
	local request = net.NetworkRequest.new(net.protocol.CCLClubApplicantREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, roleId, optype)
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCClubApplicantRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local requestProto = response:getRequest():getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CLUB_APPLICANT_SUCCESS then
		local club = self._clubService:getClub(requestProto.clubId)
		if Macro.assertFalse(club ~= nil) then
			--本地存储这个同意/拒绝的申请
			local applications = self._clubService:getClub(requestProto.clubId).application
			local applicationData = nil;
			
			for i = 1, #applications do
				if applications[i].roleId == requestProto.roleId then
					applications[i].applyTimestamp = math.ceil(kod.util.Time.now() * 1000);
					applications[i].status = requestProto.optype;
					applicationData = applications[i];
				end
			end
			
			Macro.assertFalse(applicationData ~= nil)
			self._clubService:addLocalApplication(requestProto.clubId, applicationData);
			
			self:dispatchEvent({name = "EVENT_CLUB_APPLICATION_DATA_CHANGED", clubId = requestProto.clubId, roleId = requestProto.roleId, optype = requestProto.optype});
		end
	else
		self._clubService:_showCommonTips(protocol.result)
	end
end

-- 请求推荐玩家列表
function ClubManagerService:sendCCLQueryRecommendPlayerListREQ(areaId, clubId, opType, managerId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryRecommendPlayerListREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(areaId, clubId, opType, managerId)
	request.clubId = clubId
	request.opType = opType
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCQueryRecommendPlayerListRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_RECOMMAND_PLAYER_LIST_SUCCESS then
		local recommendPlayerInfo =
		{
			clubId = request.clubId,
			opType = request.opType,
			recommandInfos = protocol.recommandInfos, -- 推荐玩家列表
			todayInvitedTimes = protocol.todayInvitedTimes, -- 今日邀请次数
			unprocessedCount = protocol.unprocessedCount, -- 未处理的邀请数
			todayAcceptTimes = protocol.todayAcceptTimes, -- 今日成功邀请的次数
			maxInvitedTimes = protocol.maxInvitedTimes, -- 每日最大邀请的次数
		}
		self:dispatchEvent({name = "EVENT_CLUB_RECOMMEND_PLAYER_INFO", recommendPlayerInfo = recommendPlayerInfo})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 设置预选玩法
function ClubManagerService:sendCCLModifyClubPresetGameplaysREQ(clubId, opType, presetGameplay)
	local request = net.NetworkRequest.new(net.protocol.CCLModifyClubPresetGameplaysREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, opType, presetGameplay)
	request.opType = opType
	request.clubId = clubId
	game.util.RequestHelper.request(request)
end

function ClubManagerService:_onCLCModifyClubPresetGameplaysRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_MODIFY_CLUB_PRESET_GAMEPLAY_SUCCESS then
		if self._clubService:getMaxPresetGamePlay(request.clubId) == 1 then
			if request.opType == ClubConstant:getOperationType().delete then
				game.ui.UIMessageTipsMgr.getInstance():showTips("已清空开房模板")
			else
				game.ui.UIMessageTipsMgr.getInstance():showTips("开房模板保存成功")
			end
		end
		local club = self._clubService:getClub(request.clubId);
		if club then
			club.data = club.data or {};
			club.data.presetGameplays = clone(protocol.presetGameplays)
		end
		self:dispatchEvent({name = "EVENT_CLUB_PRESET_GAMEPLAY"})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

return ClubManagerService 
