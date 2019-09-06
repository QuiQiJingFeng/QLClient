-- 活动相关的缓存
local ClubActivityCache = class("ClubActivityCache")

local saveKey = "ClubActivityCache"

function ClubActivityCache:ctor()
	--捉鸡寻宝用于显示参与红点的缓存(roleVersion:玩家自己的奖励  highestVersion:最高奖励 )
	self.treasure = {roleVersion = {client = 0, server = 0},
	highestVersion = {client = 0, server = 0},
    }

    -- 此人首创俱乐部送房卡数量
    self.firstCreateClubAwardCardCount = 0
end

function ClubActivityCache:checkIsTreasureVersionChanged(roleVersion, highestVersion)
	local flag = false
	if roleVersion ~= self.treasure.roleVersion.server or highestVersion ~= self.treasure.highestVersion.server then
		self.treasure.roleVersion.server = roleVersion
		self.treasure.highestVersion.server = highestVersion
		
		--事件:捉鸡寻宝红点信息改变
		game.service.club.ClubService.getInstance():getClubActivityService():dispatchEvent({name = "EVENT_CLUB_ACTIVITY_TREASURE_VERSION_CHANGED"})
		
		flag = true
	end
	
	return flag
end

function ClubActivityCache:setTreasureRead()
	if self.treasure.roleVersion.client ~= self.treasure.roleVersion.server or
	self.treasure.highestVersion.client ~= self.treasure.highestVersion.server
	then
		self.treasure.roleVersion.client = self.treasure.roleVersion.server
		self.treasure.highestVersion.client = self.treasure.highestVersion.server
		game.service.club.ClubService.getInstance():getClubActivityService():dispatchEvent({name = "EVENT_CLUB_ACTIVITY_TREASURE_VERSION_CHANGED"})
	end
end

function ClubActivityCache:getTreasureIsRead()
	return	self.treasure.roleVersion.client == self.treasure.roleVersion.server and self.treasure.highestVersion.client == self.treasure.highestVersion.server	
end



local ClubActivityService = class("ClubActivityService")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function ClubActivityService:ctor(cs)
	-- 绑定事件系统
	cc.bind(self, "event");
	
	self._clubService = cs
	self._clubActivityCache = ClubActivityCache.new()
	self._clubActivityInfo = {}

	self._clubLeaderBoardActivity = false
	self._clubKoiActivity = false
end

-- 首次显示排行榜活动
function ClubActivityService:getLeaderboardActivityShow()
	local btnShow = self._clubLeaderBoardActivity;
	self._clubLeaderBoardActivity = true
	return btnShow
end

-- 首次显示锦鲤活动
function ClubActivityService:getKoiActivityShow()
	local btnShow = self._clubKoiActivity;
	self._clubKoiActivity = true
	return btnShow
end

function ClubActivityService:initialize()
	local requestManager = net.RequestManager.getInstance()
	
	requestManager:registerResponseHandler(net.protocol.CLCClubNoticeRES.OP_CODE, self, self._onCLCClubNoticeRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryClubTaskListRES.OP_CODE, self, self._onCLCQueryClubTaskListRES)
	requestManager:registerResponseHandler(net.protocol.CLCObtainTaskRewardRES.OP_CODE, self, self._onCLCObtainTaskRewardRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryRedPacketListRES.OP_CODE, self, self._onCLCQueryRedPacketListRES)
	requestManager:registerResponseHandler(net.protocol.CLCGainClubRedPacketRES.OP_CODE, self, self._onCLCGainClubRedPacketRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryClubLotteryInfoRES.OP_CODE, self, self._onCLCQueryClubLotteryInfoRES)
	requestManager:registerResponseHandler(net.protocol.CLCDrawLotteryRES.OP_CODE, self, self._onCLCDrawLotteryRES)
	
	requestManager:registerResponseHandler(net.protocol.CLCQueryManagerActivityListRES.OP_CODE, self, self._onCLCQueryManagerActivityListRES)
	requestManager:registerResponseHandler(net.protocol.CLCAddManagerActivityRES.OP_CODE, self, self._onCLCAddManagerActivityRES)
	requestManager:registerResponseHandler(net.protocol.CLCCloseManagerActivityRES.OP_CODE, self, self._onCLCCloseManagerActivityRES)
	
	----------------------捉鸡活动--------------------
	requestManager:registerResponseHandler(net.protocol.CLCQueryTreasureInfoRES.OP_CODE, self, self._onCLCQueryTreasureInfoRES)
	requestManager:registerResponseHandler(net.protocol.CLCPurchaseCatcherRES.OP_CODE, self, self._onCLCPurchaseCatcherRES)
	requestManager:registerResponseHandler(net.protocol.CLCTreasureRewardInfoRES.OP_CODE, self, self._onCLCTreasureRewardInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCTreasureInfoSYN.OP_CODE, self, self._onCLCTreasureInfoSYN)
    
    -- 初次创建俱乐部有奖
	requestManager:registerResponseHandler(net.protocol.CLCQueryFirstCreateAwardRES.OP_CODE, self, self._onCLCQueryFirstCreateAwardRES)
	
	-- 俱乐部排行榜活动
	requestManager:registerResponseHandler(net.protocol.CLCQueryClubRankListRES.OP_CODE, self, self._onCLCQueryClubRankListRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryClubRankInfoRES.OP_CODE, self, self._onCLCQueryClubRankInfoRES)
	requestManager:registerResponseHandler(net.protocol.CLCQueryRankRewardListRES.OP_CODE, self, self._onCLCQueryRankRewardListRES)
	requestManager:registerResponseHandler(net.protocol.CLCPickClubRankRewardRES.OP_CODE, self, self._onCLCPickClubRankRewardRES)

	-- 活动时间推送
	requestManager:registerResponseHandler(net.protocol.SCActivityInfoSYN.OP_CODE, self, self._onSCActivityInfoSYN)

	self._clubService:addEventListener("EVENT_CLUB_DATA_SYN", handler(self, self._changendClubDta), self)
    self._clubService:getClubMemberService():addEventListener("EVENT_CLUB_CREATE_RESULT", handler(self, self._onEventClubCreateResult), self)
    game.service.LoginService:getInstance():addEventListener("EVENT_USER_LOGIN_SUCCESS", handler(self, self._onEventLoginSuccess), self)
end

function ClubActivityService:dispose()
	self._clubActivityInfo = {}

	net.RequestManager.getInstance():unregisterResponseHandler(self);
	
    self._clubService:removeEventListenersByTag(self)
    self._clubService:getClubMemberService():removeEventListenersByTag(self)
    game.service.LoginService:getInstance():removeEventListenersByTag(self)
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

function ClubActivityService:getActivityCache()
	return self._clubActivityCache
end

function ClubActivityService:loadLocalStorage(...)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	self._clubActivityCache = manager.LocalStorage.getUserData(roleId, saveKey, ClubActivityCache)
end

function ClubActivityService:saveLocalStorage()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, saveKey, self._clubActivityCache)
end

function ClubActivityService:_changendClubDta(event)
	local protocolBuf = event.chanendClubData
	local newClubIds = event.chanendNewClubIds
	local deletedClubs = event.chanendDeletedClubs
	-- 红包
	if protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_RED_PACKET then
		local updateClubData = protocolBuf.clubDatas[1]
		local club = self._clubService:getClub(updateClubData.clubId)
		club.info.redPacketVersion = updateClubData.redPacketVersion
		-- 红包信息变动
		self:dispatchEvent({name = "EVENT_CLUB_REDPACKET_CHANGED", clubId = club.info.clubId});
	end
end

function ClubActivityService:_onEventLoginSuccess(event)
    -- self:sendCCLQueryFirstCreateAwardREQ()
end

function ClubActivityService:_onEventClubCreateResult(event)
    -- 无论成功失败，重新请求下首创信息
    self:sendCCLQueryFirstCreateAwardREQ()
end

--  请求公告
function ClubActivityService:sendCCLClubNoticeREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLClubNoticeREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId)
	game.util.RequestHelper.request(request)
end

-- 请求公告结果
function ClubActivityService:_onCLCClubNoticeRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CLUB_NOTICE_SUCCESS then
		-- 设置数据
		local requestProto = response:getRequest():getProtocol():getProtocolBuf()
		local club = self._clubService:getClub(requestProto.clubId)
		if Macro.assertFalse(club ~= nil) then
			club.notice = protocol.notices
			self:dispatchEvent({name = "EVENT_CLUB_MEMBER_NOTICE_RETRIVED", clubId = requestProto.clubId});
		end
	else
		self._clubService:_showCommonTips(protocol.result)
	end
end

-- 亲友圈任务列表
function ClubActivityService:sendCCLQueryClubTaskListREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryClubTaskListREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	request:getProtocol():setData(clubId)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryClubTaskListRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_CLUB_TASKLIST_SUCCESS then
		local club = self._clubService:getClub(request.clubId)
		if Macro.assertFalse(club ~= nil) then
			club.task = {}
			if protocol.managerTaskList ~= nil and #protocol.managerTaskList > 0 then
				for i, v in ipairs(protocol.managerTaskList) do
					local t = v
					t.clientType = "manager"
					table.insert(club.task, t)
				end
			end
			if protocol.userTaskList ~= nil and #protocol.userTaskList > 0 then
				for i, v in ipairs(protocol.userTaskList) do
					local t = v
					t.clientType = "user"
					table.insert(club.task, t)
				end
			end
			self:dispatchEvent({name = "EVENT_CLUB_TASK", clubId = request.clubId});
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 领取任务奖励
function ClubActivityService:sendCCLObtainTaskRewardREQ(clubId, taskId, clientType)
	local request = net.NetworkRequest.new(net.protocol.CCLObtainTaskRewardREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	request.clientType = clientType
	request:getProtocol():setData(clubId, taskId, clientType)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCObtainTaskRewardRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_OBTAIN_TASK_REWARD_SUCCESS then
		local v = protocol.taskInfo
		v.clientType = request.clientType
		self:dispatchEvent({name = "EVENT_CLUB_TASK_CHANGED", clubId = request.clubId, taskInfo = protocol.taskInfo});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求红包列表
function ClubActivityService:sendCCLQueryRedPacketListREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryRedPacketListREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId)
	request.clubId = clubId
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryRedPacketListRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_RED_PACKET_LIST_SUCCESS then
		local club = game.service.club.ClubService.getInstance():getClub(request.clubId)
		-- 更新本地数据
		if Macro.assertFalse(club ~= nil) and Macro.assertFalse(club.data ~= nil) then
			-- 做一下缓存
			club.redpacket = protocol.redPacketList
			self:dispatchEvent({name = "EVENT_CLUB_REDPACKET_GET", redPacketList = protocol.redPacketList, todayTotalMoney = protocol.todayTotalMoney});
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求领取红包
function ClubActivityService:sendCCLGainClubRedPacketREQ(clubId, redPacketId, status)
	local request = net.NetworkRequest.new(net.protocol.CCLGainClubRedPacketREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	request.status = status
	request:getProtocol():setData(clubId, redPacketId)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCGainClubRedPacketRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_GAIN_CLUB_RED_PACKET_SUCCESS then
		local club = self._clubService:getClub(request.clubId)
		if Macro.assertFalse(club ~= nil) and Macro.assertFalse(club.data ~= nil) then
			UIManager:getInstance():show("UIClubRedPacket", protocol.redPacket, request.status)
			
			for i = 1, #club.redpacket do
				if club.redpacket[i].id == protocol.redPacket.id then
					-- 将红包状态同步更改
					club.redpacket[i] = protocol.redPacket
					break
				end
			end
			-- 更新数据
			self:dispatchEvent({name = "EVENT_CLUB_REDPACKET_GET", redPacketList = club.redpacket, todayTotalMoney = protocol.todayTotalMoney});
		end
	else
		-- 如果请求失败，可能红包消息失效，重新请求一下
		self:sendCCLQueryRedPacketListREQ(request.clubId)
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求抽奖状态
function ClubActivityService:sendCCLQueryClubLotteryInfoREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryClubLotteryInfoREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	request:getProtocol():setData(clubId, game.service.LocalPlayerService:getInstance():getArea())
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryClubLotteryInfoRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_CLUB_LOTTERY_INFO_SUCCESS then
		local club = game.service.club.ClubService.getInstance():getClub(request.clubId)
		-- 更新本地数据
		if Macro.assertFalse(club ~= nil) and Macro.assertFalse(club.data ~= nil) then
			-- 做一下缓存
			club.grabInfo = protocol
			self:dispatchEvent({name = "EVENT_CLUB_GRABINFO", clubId = request.clubId, lotteryInfo = protocol});
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求抽奖
function ClubActivityService:sendCCLDrawLotteryREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLDrawLotteryREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	request:getProtocol():setData(clubId, game.service.LocalPlayerService:getInstance():getArea())
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCDrawLotteryRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_DRAW_LOTTERY_SUCCESS then
		local club = self._clubService:getClub(request.clubId)
		-- 更新本地数据
		if Macro.assertFalse(club ~= nil) and Macro.assertFalse(club.data ~= nil) then
			-- 这里处理投资结果
			UIManager:getInstance():show("UIClubReward", protocol.isLottery, protocol.awardCard)
			
			-- 抽奖后的数据更新
			club.grabInfo.lotteryCount = protocol.lotteryCount
			club.grabInfo.awardCount = protocol.awardCount
			self:dispatchEvent({name = "EVENT_CLUB_GRABINFO", clubId = request.clubId, lotteryInfo = club.grabInfo});
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

------------------------------------------ 活动系统 ---------------------------------------------------------
-- 请求亲友圈活动列表
function ClubActivityService:sendCCLQueryManagerActivityListREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryManagerActivityListREQ, self._clubService:getClubServiceId())
	request.clubId = clubId
	local rankListCounts = 20
	request:getProtocol():setData(clubId, rankListCounts)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryManagerActivityListRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_MANAGER_ACTIVITY_LIST_SUCCESS then
		self:dispatchEvent({name = "EVENT_CLUB_ACTIVITY_LIST_SUCCESS", clubId = request.clubId, acitivtyList = protocol.acitivtyList});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求添加亲友圈活动
function ClubActivityService:sendCCLAddManagerActivityREQ(clubId, title, type, startTime, endTime, minRoomCount)
	local request = net.NetworkRequest.new(net.protocol.CCLAddManagerActivityREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, title, type, startTime, endTime, minRoomCount)
	request.clubId = clubId
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCAddManagerActivityRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_ADD_MANAGER_ACTIVITY_SUCCESS then
		self:sendCCLQueryManagerActivityListREQ(request.clubId)
		game.ui.UIMessageTipsMgr.getInstance():showTips("活动创建成功!")
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求关闭或删除亲友圈活动
function ClubActivityService:sendCCLCloseManagerActivityREQ(clubId, optype, activityId)
	local request = net.NetworkRequest.new(net.protocol.CCLCloseManagerActivityREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, optype, activityId)
	request.clubId = clubId
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCCloseManagerActivityRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_CLOSE_MANAGER_ACTIVITY_SUCCESS then
		self:sendCCLQueryManagerActivityListREQ(request.clubId)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end
---------------------------------------------------捉鸡寻宝-------------------------------------------------
-- 请求捉鸡寻宝活动信息
function ClubActivityService:sendCCLQueryTreasureInfoREQ(opType)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryTreasureInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(opType)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryTreasureInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_TREASURE_INFO_SUCCESS then
		-- 事件:寻宝捉鸡配置获取
		self:dispatchEvent({name = "EVENT_TREASURE_INFO_GET", protocol = protocol});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求购买捉鸡寻宝消耗品
function ClubActivityService:sendCCLPurchaseCatcherREQ(clubId, purchaseCount)
	local request = net.NetworkRequest.new(net.protocol.CCLPurchaseCatcherREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, purchaseCount)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCPurchaseCatcherRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_PURCHASE_CATCHER_SUCCESS then
		
		local usedCount = protocol.purchaseCount
		local leftCount = request:getProtocol():getProtocolBuf().purchaseCount - usedCount;
		-- 事件:制作捕捉器
		self:dispatchEvent({name = "EVENT_CLCPurchaseCatcherRES", usedCount = usedCount, leftCount = leftCount});
		
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求捉鸡寻宝获奖信息
function ClubActivityService:sendCCLTreasureRewardInfoREQ()
	local request = net.NetworkRequest.new(net.protocol.CCLTreasureRewardInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(game.service.LocalPlayerService.getInstance():getArea())
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCTreasureRewardInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_TREASURE_REWARD_INFO_SUCCESS then
		--事件:奖励信息获取
		self:dispatchEvent({name = "EVENT_TREASURE_REWARD_INFO_GET", protocol = protocol});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

function ClubActivityService:_onCLCTreasureInfoSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	-- 寻宝捉鸡奖励版本变化
	if self._clubActivityCache:checkIsTreasureVersionChanged(protocol.roleVersion, protocol.highestVersion) then
		self:saveLocalStorage()
	end
	
	-- 事件:捉鸡寻宝进度变化
	self:dispatchEvent({name = "EVENT_TREASURE_PROCESS_INFO_GET", protocol = protocol});
	
end

function ClubActivityService:sendCCLQueryFirstCreateAwardREQ()
	local request = net.NetworkRequest.new(net.protocol.CCLQueryFirstCreateAwardREQ, self._clubService:getClubServiceId())
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryFirstCreateAwardRES(response)
    local protocolBuffer = response:getProtocol():getProtocolBuf()
    if protocolBuffer.result == net.ProtocolCode.CLC_QUERY_FIRST_CREATE_AWARD_SUCCESS then
        self._clubActivityCache.firstCreateClubAwardCardCount = protocolBuffer.awardCard
        self:dispatchEvent({name = "EVENT_CLUB_FIRST_CREATE_AWARD_GET", protocol = protocolBuffer})
    end
end

-- 请求排行榜信息
function ClubActivityService:sendCCLQueryClubRankListREQ(opType)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryClubRankListREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(opType)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryClubRankListRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_CLUB_RANK_LIST_SUCCESS then
		local data = 
		{
			startTime = protocol.startTime,
			endTime = protocol.endTime,
			rewardRank = protocol.rewardRank,
			maxRank = protocol.maxRank,
			rankInfos = rawget(protocol, "rankInfos") or {},
			selfRankInfo = rawget(protocol, "selfRankInfo")
		}
		self:dispatchEvent({name = "EVENT_CLUB_RANK_LIST", data = data})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求详细排行信息
function ClubActivityService:sendCCLQueryClubRankInfoREQ(clubId, rankType, clubName, clubIcon)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryClubRankInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, rankType)
	request.clubName = clubName
	request.clubIcon = clubIcon
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryClubRankInfoRES(response)
	local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_CLUB_RANK_INFO_SUCCESS then
		local clubRankInfo = 
		{
			clubId = protocol.clubId,							-- 俱乐部id
			clubName = request.clubName,						-- 俱乐部名称
			clubIcon = request.clubIcon,						-- 俱乐部Icon
			yesterdayRank = protocol.yesterdayRank,				-- 昨日排名
			yesterdayScore = protocol.yesterdayScore,			-- 昨日积分
			myContribution = protocol.myContribution,			-- 我的贡献
		}
		UIManager:getInstance():show("UIClubRewardInfo", clubRankInfo)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求排行榜领取奖励列表
function ClubActivityService:sendCCLQueryRankRewardListREQ(opType)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryRankRewardListREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(opType)
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCQueryRankRewardListRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_RANK_REWARD_LIST_SUCCESS then
		local rankRewardList = clone(protocol.rankRewardList)
		self:dispatchEvent({name = "EVENT_CLUB_RANK_REWARD_LIST", rankRewardList = rankRewardList})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求领取俱乐部排行榜奖励
function ClubActivityService:sendCCLPickClubRankRewardREQ(clubId, opType, rankType)
	local request = net.NetworkRequest.new(net.protocol.CCLPickClubRankRewardREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, opType, rankType)
	request.clubId = clubId
	request.rankType = rankType
	game.util.RequestHelper.request(request)
end

function ClubActivityService:_onCLCPickClubRankRewardRES(response)
	local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_PICK_CLUB_RANK_REWARD_SUCCESS then
		self:dispatchEvent({name = "EVENT_CLUB_RANK_REWARD_INFO_CHANGE", clubId = request.clubId, status = protocol.status, rankType = request.rankType})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 活动时间
function ClubActivityService:_onSCActivityInfoSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	self._clubActivityInfo = clone(protocol.activityInfo)
	self:dispatchEvent({name = "EVENT_CLUB_ACTIVITY_TIME_INFO"})
end

function ClubActivityService:isActivitiesWithin(activityId)
	local curTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
	for _, req in ipairs(self._clubActivityInfo) do
		if req.id == activityId then
			if curTime > req.startTime and curTime < req.endTime then
				return true
			else
				return false
			end
		end
	end
	
	return false
end

return ClubActivityService 
