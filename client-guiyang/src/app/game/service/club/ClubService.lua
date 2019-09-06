local ns = namespace("game.service.club")

local ClubService = class("ClubService")
ns.ClubService = ClubService

local ClubActivityService = require("app.game.service.club.common.ClubActivityService")
local ClubHistoryService = require("app.game.service.club.common.ClubHistoryService")
local ClubMemberService = require("app.game.service.club.common.ClubMemberService")
local ClubRoomService = require("app.game.service.club.common.ClubRoomService")
local ClubManagerService = require("app.game.service.club.manager.ClubManagerService")
local ClubList = require("app.game.service.club.data.ClubList")
local UserData = require("app.game.service.club.data.UserData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local ClubLeaderboardService = require("app.game.service.club.common.ClubLeaderboardService")
local ClubGroupService = require("app.game.service.club.common.ClubGroupService")


-- 本地保存的申请列表
local LocalApplications = class("LocalApplications")
function LocalApplications:ctor()
	self.clubs = {}	
end

function LocalApplications:getApplications(clubId)
	return self.clubs[tostring(clubId)] or {}
end

function LocalApplications:addApplication(clubId, application)
	local club = self.clubs[tostring(clubId)]
	if club == nil then
		club = {}
		self.clubs[tostring(clubId)] = club
	end
	
	table.insert(club, application)
end

-- 添加本地缓存数据
function ClubService:addLocalApplication(clubId, applicationData)
	self._localApplications:addApplication(clubId, applicationData)
	self:_saveLocalStorage()
end

function ClubService:loadLocalStorage()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	self._localApplications = manager.LocalStorage.getUserData(roleId, "ClubApplications", LocalApplications)
end

function ClubService:loadSubServiceStorage()
	self._clubActivityService:loadLocalStorage()
end

function ClubService:_saveLocalStorage()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "ClubApplications", self._localApplications)
end

-- ClubService
function ClubService.getInstance()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		return game.service.LocalPlayerService.getInstance():getClubService()
	end
	
	return nil
end

function ClubService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");
	
	self._clubServerId = - 1
	-- 判断是否要进去大联盟/俱乐部,还是单纯的用来请求数据
	self._isLeague = false
	
	self._clubActivityService = ClubActivityService.new(self)
	self._clubHistoryService = ClubHistoryService.new(self)
	self._clubMemberService = ClubMemberService.new(self)
	self._clubRoomService = ClubRoomService.new(self)
	self._clubManagerService = ClubManagerService.new(self)
	self._clubLeaderboardService = ClubLeaderboardService.new(self)
	self._clubGroupService = ClubGroupService.new(self)
	
	self._userData = UserData.new()
	self._clubList = ClubList.new()
	
	self._localApplications = LocalApplications.new()
	
	-- 最后一次选择的亲友圈Id, 用于重新显示亲友圈界面时, 恢复之前的选择
	self._lastViewedClubId = nil
end

function ClubService:initialize()
	local requestManager = net.RequestManager.getInstance()
	
	requestManager:registerResponseHandler(net.protocol.CLCClubDataSYN.OP_CODE, self, self._onCLCClubDataSYN)
	requestManager:registerResponseHandler(net.protocol.CLCClubInfoRES.OP_CODE, self, self._onCLCClubInfoRES)
	
	self._clubActivityService:initialize()
	self._clubHistoryService:initialize()
	self._clubMemberService:initialize()
	self._clubRoomService:initialize()
	self._clubManagerService:initialize()
	self._clubLeaderboardService:initialize()
	self._clubGroupService:initialize()
	
	-- game.service.MagicWindowService.getInstance():addEventListener("MW_ON_DELWITH_MLINK", handler(self, self._joinClub), self)
	
	self:addEventListener("EVENT_CLUB_DATA_SYN", handler(self, self._changendClubDta), self)
	game.service.LoginService:getInstance():addEventListener("USER_LOGOUT", handler(self, self._clearClubInfo), self)
end

-- 用户主动退出登录要把该玩家的俱乐部数据清空
function ClubService:_clearClubInfo()
	self._clubList.clubs = {}
end

function ClubService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	-- if game.service.MagicWindowService.getInstance() ~= nil then
	-- 	game.service.MagicWindowService.getInstance():removeEventListenersByTag(self)
	-- end

	game.service.LoginService:getInstance():removeEventListenersByTag(self)
	
	self:removeEventListenersByTag(self)
	
	self._clubActivityService:dispose()
	self._clubHistoryService:dispose()
	self._clubMemberService:dispose()
	self._clubRoomService:dispose()
	self._clubManagerService:dispose()
	self._clubLeaderboardService:dispose()
	self._clubGroupService:dispose()
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

-- 获取游戏亲友圈按钮上小红点是否显示
function ClubService:hasClubBadges(clubId)
	local redDotVisible_Application = false;
	local redDotVisible_Task = false;
	
	for itemIdx = 1, #self._clubList.clubs do
		-- 现在牌局跟历史战绩没有明确的状态改变判断，现在都不显示
		local club = self._clubList.clubs[itemIdx]
		if club.info.clubId ~= clubId then
			-- 信息界面，只有当自己是亲友圈群主的时候，才会去判断申请人列表的更新
			redDotVisible_Application = club:hasApplicationBadges()
			redDotVisible_Task = club:hasTaskBadges()
			if redDotVisible_Application or redDotVisible_Task then
				return true;
			end
		end
	end
	
	return redDotVisible_Application or redDotVisible_Task or self:getUserData():hasInvitationBadges() or self:getUserData():hasRecommandInvitationBadges()
end

-- 加载本地存储的数据
function ClubService:getClubApplications(clubId)
	--服务器获取的数据
	local applications = clone(self:getClub(clubId).application)
	
	--倒序插入,最新操作的在前面
	local dataNum = #applications + 1
	
	--本地的数据
	for _, data in ipairs(self._localApplications:getApplications(clubId)) do
		table.insert(applications, dataNum, data);
	end
	
	return applications;
end

--[[-- Access functions
]]
function ClubService:setId(roleId, clubServerId)
	self._roleId = roleId
	self._clubServerId = clubServerId
end

function ClubService:getUserData()
	return self._userData
end

function ClubService:getClubList()
	return self._clubList
end

function ClubService:getClub(clubId)
	local idx = self._clubList:indexOfClub(clubId)
	if idx ~= false then
		return self._clubList.clubs[idx]
	else
		return nil
	end
end
--获取俱乐部头像
function ClubService:getClubIconName(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubIconName()
	end
	return ""
end
--获取俱乐部名称
function ClubService:getClubName(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club.data.clubName
	end
	return ""
end
--获取俱乐部邀请码
function ClubService:getClubInvitationCode(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubInvitationCode()
	end
	return 0
end
--获取俱乐部群主Id
function ClubService:getClubManagerRoleId(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubManagerRoleId()
	end
	return 0
end
--获取俱乐部创建时间
function ClubService:getClubCreateTime(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubCreateTime()
	end
	return 0
end
--获取俱乐部经理名称
function ClubService:getClubManagerName(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubManagerName()
	end
	return ""
end
--获取俱乐部设置
function ClubService:getClubSettingInfo(clubId, setTypeId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubSettingInfo(setTypeId)
	end
	return false
end
--获取俱乐部今日和昨日玩家数
function ClubService:getClubActivePlayerNum(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getActivePlayerNum()
	end
	return 0, 0
end
--获取俱乐部群主真实Id
function ClubService:getClubManagerId(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getClubManagerId()
	end
	return 0
end
-- 获取禁用玩法
function ClubService:getBanGameplays(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getBanGameplays()
	end
	
	return {}
end
-- 获取模版玩法
function ClubService:getPresetGameplays(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getPresetGameplays()
	end
	
	return {}
end

-- 获取小组id
function ClubService:getGroupId(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getGroupId()
	end
	
	return ""
end

-- 获取可以设置预设玩法的数量
function ClubService:getMaxPresetGamePlay(clubId)
	local club = self:getClub(clubId)
	if club ~= nil then
		return club:getMaxPresetGamePlay()
	end

	return 1
end

-- 获取玩法字符串转中文
function ClubService:_getGameTypeName(optionType)
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	local ruleType = MultiArea.getRuleType(areaId) [1]
	local temp = ruleType[optionType]
	
	if not temp then
		Logger.info("Invalie OptionType : " .. optionType)
		return 0
	end
	
	return temp[2]
end

function ClubService:setLastViewedClubId(clubId)
	self._lastViewedClubId = clubId
end

function ClubService:getLastViewedClubId()
	return self._lastViewedClubId
end

function ClubService:getClubActivityService()
	return self._clubActivityService
end

function ClubService:getClubHistoryService()
	return self._clubHistoryService
end

function ClubService:getClubMemberService()
	return self._clubMemberService
end

function ClubService:getClubRoomService()
	return self._clubRoomService
end

function ClubService:getClubManagerService()
	return self._clubManagerService
end

function ClubService:getClubLeaderboardService()
	return self._clubLeaderboardService
end

function ClubService:getClubGroupService()
	return self._clubGroupService
end

function ClubService:_showCommonTips(result)
	if result == net.ProtocolCode.CLC_ERROR_CODE_CLUB_SEALED then
		game.ui.UIMessageBoxMgr.getInstance():show(net.ProtocolCode.code2Str(result), {"确定"})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(result))
	end
end

function ClubService:getClubServiceId()
	return self._clubServerId
end

-- 我是不是这个club的群主，在没有获取到该亲友圈具体信息前，可以用这个函数
function ClubService:isMeManager(clubId)
	local club = self:getClub(clubId);
	if not club or not club.info or not club.info.isManager then
		return false;
	end
	return true;
end
-- 判断玩家是否是club的管理员
function ClubService:playerIsPermissions(clubId, playerId)
	local club = self:getClub(clubId);
	if club then
		return club:isPermissions(playerId);
	end
	return false;
end

function ClubService:_onCLCClubDataSYN(response)
	local protocolBuf = response:getProtocol():getProtocolBuf()
	
	local newClubIds = {}
	local deletedClubs = {}
	
	-- 保存新数据(保留原有的旧数据)
	Macro.assertFalse(protocolBuf.userInfo ~= nil)
	
	self._userData.oldInfo = self._userData.info
	self._userData.info = clone(protocolBuf.userInfo)
	
	-- 加个闭包
	local refreshClubData = function()
		-- 添加/更新亲友圈基本信息
		for _, clubInfo in ipairs(protocolBuf.clubDatas) do
			local club = self:getClub(clubInfo.clubId)
			if club == nil then
				-- 添加新数据
				club = self._clubList:addClub(clubInfo)
				table.insert(newClubIds, club.info.clubId)
			else
				-- 更新现有数据
				club.oldInfo = club.oldInfo and club.info
				club.info = clubInfo
			end
		end
		
		-- 检查亲友圈删除变化
		for _, club in ipairs(self._clubList.clubs) do
			local deleted = true
			for _, clubInfo in ipairs(protocolBuf.clubDatas) do
				if club.info.clubId == clubInfo.clubId then
					deleted = false
					break
				end
			end
			
			if deleted == true then
				-- 保存要删除的亲友圈
				table.insert(deletedClubs, club)
			end
		end
		
		-- 删除亲友圈
		for _, club in ipairs(deletedClubs) do
			self._clubList:removeClub(club.info.clubId)
		end
	end

	Logger.debug("protocolBuf.notifyType = %s", tostring(protocolBuf.notifyType))
	Logger.dump(protocolBuf, "_onCLCClubDataSYN~~~~~~~~~~~");
	
	-- 登录game后的推送
	if protocolBuf.notifyType == ClubConstant:getClubNotifyType().NORMAL then
		refreshClubData();
		scheduleOnce(function()
			-- 为了保证clubdata有数据先请求一下
			for _, data in ipairs(self._clubList.clubs) do
				-- 防止重复请求，当data为nil时去请求
				if data.data == nil then
					self:tryQueryDirtyClubData(data.info.clubId, false, true)
				end
			end
			self:dispatchEvent({name = "EVENT_QUERY_CLUB_INFO"})
		end, 0.5)
		-- 删除亲友圈
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().CLUB_REMOVED then
		refreshClubData();
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().JOIN_LEAGUE then
		local localStorageClubInfo = self:loadLocalStorageClubInfo()
		-- 判断当前亲友圈加入联盟
		if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and localStorageClubInfo:getClubId() == protocolBuf.clubDatas[1].clubId then
			local lastState = GameFSM.getInstance():getCurrentState().class.__cname
			if lastState == "GameState_Club" then
				local str = string.format("您所在的%s已被批准参加比赛", config.STRING.COMMON)
				game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定"}, function ()
					self:enterClub()
				end, function()end, true)
			end
		end
	elseif protocolBuf.notifyType == ClubConstant:getClubNotifyType().QUIT_LEAGUE then
		local localStorageClubInfo = self:loadLocalStorageClubInfo()
		-- 判断当前亲友圈被踢出联盟
		if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and localStorageClubInfo:getClubId() == protocolBuf.clubDatas[1].clubId then
			local lastState = GameFSM.getInstance():getCurrentState().class.__cname
			if lastState == "GameState_League" then
				game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setLeagueId(0)
				game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setClubId(0)
				game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_DISBAND"})
				local str = string.format("您所在的%s被强制退赛", config.STRING.COMMON)
				game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定"}, function ()
					GameFSM.getInstance():enterState("GameState_Club")
				end, function()end, true)
			end
		end
	end
	
	self:dispatchEvent({name = "EVENT_CLUB_DATA_SYN", chanendClubData = protocolBuf, chanendNewClubIds = newClubIds, chanendDeletedClubs = deletedClubs})
	
	self:_clubDataPush(newClubIds, deletedClubs)
end

function ClubService:_clubDataPush(newClubIds, deletedClubs)
	if self._userData.oldInfo == nil then
		self:dispatchEvent({name = "EVENT_CLUB_INFO_RETRIVED"});
		local playerData = self:loadLocalStoragePlayerInfo()

		self:saveLocalStoragePlayerInfo(playerData)
	else
		
		-- 邀请信息变化
		if self._userData:isInvitationChanged() then
			self:dispatchEvent({name = "EVENT_USER_INFO_INVITATION_CHANGED"});
		end
		
		-- 对比亲友圈增/删
		if #newClubIds ~= 0 then
			self:dispatchEvent({name = "EVENT_CLUB_ADDED", clubIds = newClubIds});
		end
		
		if #deletedClubs ~= 0 then
			self:dispatchEvent({name = "EVENT_CLUB_DELETED", clubs = deletedClubs});
		end
		
		-- 亲友圈数据变化
		for _, club in pairs(self._clubList.clubs) do
			if club.oldInfo ~= nil then
				-- 新亲友圈不检查
				Macro.assertFalse(table.indexof(newClubIds, club.clubId) == false)
				
				if club and club.info then
					-- 邀请信息变化
					if club.info.clubApplicationCount ~= club.oldInfo.clubApplicationCount
					or club.info.clubApplicationVersion ~= club.oldInfo.clubApplicationVersion then
						self:dispatchEvent({name = "EVENT_CLUB_INFO_APPLICATION_CHANGED", clubId = club.info.clubId});
					end
					
					-- 任务变动推送
					local taskVersion = self:loadLocalStoragePlayerInfo():getClubInfo(club.info.clubId).taskVersion
					if club.info.clubTaskVersion ~= taskVersion then
						self:dispatchEvent({name = "EVENT_CLUB_INFO_TASK_CHANGED", clubId = club.info.clubId, clubTaskVersion = club.info.clubTaskVersion});
					end
				end
			end
		end
		-- 做一次保护，在亲友圈中断线中，该亲友圈不存在了
		local localStorageClubInfo = self:loadLocalStorageClubInfo()
		if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 then
			local lastState = GameFSM.getInstance():getCurrentState().class.__cname
			if self:getClub(localStorageClubInfo:getClubId()) == nil and lastState == "GameState_Club" then
				-- 说明已经不在这个亲友圈内,并且在亲友圈这个状态下
				localStorageClubInfo:setClubId(0)
				self:saveLocalStorageClubInfo(localStorageClubInfo)
				GameFSM.getInstance():enterState("GameState_Lobby")
				return
			end
		end
		
		self:dispatchEvent({name = "EVENT_CLUB_REDDOT_CHANGED"})
	end
end

function ClubService:_changendClubDta(event)
	local protocolBuf = event.chanendClubData
	local newClubIds = event.chanendNewClubIds
	local deletedClubs = event.chanendDeletedClubs
end

-- 尝试更新亲友圈信息, 返回发起更新的亲友圈id数组
-- isClosure       bool        是否判断亲友圈封停
-- isChangeState bool 是否要判断切换状态
function ClubService:tryQueryDirtyClubData(clubId, isClosure, isChangeState)
	local club = self:getClub(clubId)
	if Macro.assertTrue(club == nil) then
		return false
	end
	if isClosure == nil then
		isClosure = false
	end
	if isChangeState == nil then
		isChangeState = false
	end
	-- 只请求没有数据的亲友圈
	self:_sendCCLClubInfoREQ(clubId, isClosure, isChangeState)
	return true
end

-- 请求亲友圈详细信息
function ClubService:_sendCCLClubInfoREQ(clubId, isClosure, isChangeState)
	local request = net.NetworkRequest.new(net.protocol.CCLClubInfoREQ, self._clubServerId)
	request:getProtocol():setData(clubId)
	request.isClosure = isClosure
	request.isChangeState = isChangeState
	game.util.RequestHelper.request(request)
end

-- 返回亲友圈数据
function ClubService:_onCLCClubInfoRES(response)
	local request = response:getRequest()
	local protocolBuf = response:getProtocol():getProtocolBuf()
	if protocolBuf.result == net.ProtocolCode.CLC_CLUB_INFO_SUCCESS then
		-- 收到亲友圈的详细数据
		local clubInfo = self:getClub(protocolBuf.clubInfo.clubId)
		if Macro.assertFalse(clubInfo ~= nil) then
			clubInfo.data = protocolBuf.clubInfo
			clubInfo.playerInfo = {title = protocolBuf.title}
			
			if request.isClosure and clubInfo.data.status == 1 then
				game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.CLUBSERVICE_STRING_100)
				local localStorageClubInfo = self:loadLocalStorageClubInfo()
				localStorageClubInfo:setClubId(0)
				self:saveLocalStorageClubInfo(localStorageClubInfo)
				GameFSM.getInstance():enterState("GameState_Lobby")
				return
			end
		end
		-- 发起事件
		self:dispatchEvent({name = "EVENT_CLUB_DATA_RETRIVED", clubId = protocolBuf.clubInfo.clubId});
		if request.isChangeState then
			return
		end
		self:_onIsLeagueState(protocolBuf.clubInfo.clubId)
	else
		self:_showCommonTips(protocolBuf.result)
	end
end

function ClubService:_sendCCLQueryClubInfosREQ()
	local request = net.NetworkRequest.new(net.protocol.CCLQueryClubInfosREQ, self._clubServerId)
	game.util.RequestHelper.request(request)
end

function ClubService:_onCLCQueryClubInfosRES()
	local protocolBuf = response:getProtocol():getProtocolBuf()
	if protocolBuf.result == net.ProtocolCode.CLC_QUERY_CLUB_INFOS_SUCCESS then
		Logger.debug("ClubService:_onCLCQueryClubInfosRES()")
	else
		self:_showCommonTips(protocolBuf.result)
	end
end

-----------------------------------------------------------------------------------------------------------------
-- 加入亲友圈
function ClubService:_joinClub(event)
	if event.urlType == game.service.MAGIC_WINDOW_URL_TYPE_ENUM.JOIN_CLUB then
		local invitationCode = tonumber(event.param.invitationCode)
		local inviterId = tonumber(event.param.inviterId)
		-- TODO : 尝试加入亲友圈
		if Macro.assetTrue(invitationCode == nil or inviterId == nil, "解析加入亲友圈失败!") then
			return false
		end
		Logger.debug(string.format("_joinClub, %s, %d", invitationCode, inviterId));
		self._clubMemberService:sendCCLAccedeToClubREQ(invitationCode, inviterId)
		-- 操作结果保存
		event.result = true
	end
end

-- 获取亲友圈图标
function ClubService:getClubIcon(clubIconName)
	-- 没有图标，默认第一个
	local clubIcon = ClubConstant:getClubIcon()
	if clubIconName == nil or clubIconName == "" then
		return clubIcon[ClubConstant:getClubDefaultIconName()]
	else
		return clubIcon[clubIconName]
	end
end

---------------------------------------------------------------------------------------------------------
-- 截取字符串（因为太多地方调用，防止产品时不时修改，所以放在这里统一管理）
function ClubService:getInterceptString(string, len)
	-- 如果没有传长度，默认为12个字符
	if len == nil then
		len = 12
	end

	-- 线上有报错为空的情况，先判断一下字符串是否为空
	if string == nil then
		return ""
	end
	
	if kod.util.String.getUTFLen(string) > len then
		return kod.util.String.getMaxLenString(string, len)
	end
	
	return string
end

--[[
	截图字符串 中间添加	*
	str:字符串
	lenStart:前面显示的位数
	lenEnd:后面显示的位数
]]
function ClubService:getShieldString(str, lenStart, lenEnd)
	if str == "" or str == nil then
		return ""
	end

	local sTable = kod.util.String.stringToTable(str)
	
	if lenStart == nil then
		lenStart = 1
	end

	if lenEnd == nil then
		lenEnd = 1
	end

	-- 如果前后预留位数相加大于等于原本str的长度就不必添加*
	if lenStart + lenEnd >= #sTable then
		return str
	end

	local startStr = ""
	local endStr = ""
	for i = 1, #sTable do
		if i <= lenStart then
			startStr = string.format("%s%s", startStr, sTable[i])
		end
		if #sTable - i < lenEnd then
			endStr = string.format("%s%s", endStr, sTable[i])
		end
	end

	return string.format("%s****%s", startStr, endStr)
end

function ClubService:hasTaskChange(clubId, clubTaskVersion)
	local playerInfo = self:loadLocalStoragePlayerInfo()
	if playerInfo:getClubInfo(clubId).taskVersion ~= clubTaskVersion then
		playerInfo:getClubInfo(clubId).taskVersion = clubTaskVersion
		self:saveLocalStoragePlayerInfo(playerInfo)
		return true
	end
	
	return false
end

-- 保存亲友圈公告、任务版本号、成员排序类型、任务类型
local LocalClubInfo = class("LocalClubInfo")
function LocalClubInfo:ctor()
	self.clubId = 0
	self.noticeVersion = 0
	self.taskVersion = 0
	self.sortType = 0
	self.hasSetting = true
	self.normalAnnouncementVersion = 0
	self.managerAnnouncementVersion = 0
	self._gamePlay = {}
	self.activityTime = 0
	self.isRecommend = true
	self.presetGamePlayId = 0
end

local LocalStoragePlayerInfo = class("LocalStoragePlayerInfo")

function LocalStoragePlayerInfo:ctor()
	self._clubInfo = {}

end

function LocalStoragePlayerInfo:getClubInfo(clubId)
	for i, data in ipairs(self._clubInfo) do
		if data.clubId == clubId then
			return data
		end
	end
	-- 如果本地没有保存就新创建一个
	local clubInfo = LocalClubInfo.new()
	clubInfo.clubId = clubId
	table.insert(self._clubInfo, clubInfo)
	return clubInfo
end

function ClubService:loadLocalStoragePlayerInfo()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalStoragePlayerInfo", LocalStoragePlayerInfo)
end

function ClubService:saveLocalStoragePlayerInfo(localStoragePlayerInfo)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalStoragePlayerInfo", localStoragePlayerInfo)
end

-- 保存亲友圈Id
local LocalStorageClubInfo = class("LocalStorageClubInfo")
function LocalStorageClubInfo:ctor()
	self._clubId = 0
end

function LocalStorageClubInfo:getClubId()
	return self._clubId
end

function LocalStorageClubInfo:setClubId(clubId)
	self._clubId = clubId
end

function ClubService:loadLocalStorageClubInfo()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalStorageClubInfo", LocalStorageClubInfo)
end

function ClubService:saveLocalStorageClubInfo(localStorageClubInfo)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalStorageClubInfo", localStorageClubInfo)
end

-------------------------------------------------------------------------------------------------
-- 保存玩家信息
local LocalPlayerInfo = class("LocalPlayerInfo")
function LocalPlayerInfo:ctor()
	self.playId = 0
	self.recommandInvitedVersion = 0
	self.inviteStatus = false
	self.invitetime = 0
	self.isFirstLogin = false
	self.phone = ""
	self.weChat = ""
	self.isShowRetain = false
end

local LocalStorageGamePlayInfo = class("LocalStorageGamePlayInfo")

function LocalStorageGamePlayInfo:ctor()
	self._playerInfo = {}
end

function LocalStorageGamePlayInfo:getPlayerInfo()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	for i, data in ipairs(self._playerInfo) do
		if data.playId == roleId then
			return data
		end
	end
	-- 如果本地没有保存就新创建一个
	local playerInfo = LocalPlayerInfo.new()
	playerInfo.playId = roleId
	table.insert(self._playerInfo, playerInfo)
	return playerInfo
end

function ClubService:loadLocalStorageGamePlayInfo()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalStorageGamePlayInfo", LocalStorageGamePlayInfo)
end

function ClubService:saveLocalStorageGamePlayInfo(localStorageGamePlayInfo)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalStorageGamePlayInfo", localStorageGamePlayInfo)
end

function ClubService:enterClub()
	local localStorageClubInfo = self:loadLocalStorageClubInfo()
	if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and self:getClub(localStorageClubInfo:getClubId()) ~= nil then
		self._isLeague = true
		self:tryQueryDirtyClubData(localStorageClubInfo:getClubId(), true)
	else
		UIManager:getInstance():show("UIClubMain", true)
	end
end

--FYD 俱乐部切换的时候,如果判断是大联盟就进入联盟界面,否则进入俱乐部界面
function ClubService:_onIsLeagueState(clubId)
	if GameFSM.getInstance():getCurrentState().class.__cname == "GameState_Mahjong" then
		return
	end

	local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
	local club = self:getClub(clubId)
	if club.data ~= nil then
		if club.data.leagueId ~= 0 then
			bigLeagueService:getLeagueData():setClubId(clubId)
			bigLeagueService:setIsSuperLeague(false)
			bigLeagueService:getLeagueData():setLeagueId(club.data.leagueId)
			GameFSM.getInstance():enterState("GameState_League")
		elseif self._isLeague then
			GameFSM.getInstance():enterState("GameState_Club")
			bigLeagueService:getLeagueData():setLeagueId(club.data.leagueId)
		end
		self._isLeague =false
	else
		Logger.debug("GameState_Club Club data is Nill")
	end
end