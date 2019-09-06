--[[本地玩家数据存储模块
事件:
EVENT_INTERFACE_DATA_RETRIVED
EVENT_GAME_DATA_RETRIVED
EVENT_ROOM_CARD_COUNT_CHANGED
--]]
local ns = namespace("game.service")

--存储玩家的一些全局数据(非展示用)
local PlayerLocalData = class("PlayerLocalData")
function PlayerLocalData:ctor()
	self.hasAutoCodeHuTong = false
end


-- 处理玩家数据相关逻辑
local LocalPlayerService = class("LocalPlayerService")
ns.LocalPlayerService = LocalPlayerService

-- 单例支持
-- @return LoginService
function LocalPlayerService:getInstance()
	return manager.ServiceManager.getInstance():getLocalPlayerService();
end

-- 加载本地存储
function LocalPlayerService:loadLocalStorage()
	self._playerLocalData = manager.LocalStorage.getUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "PlayerLocalData", PlayerLocalData);
end

-- 存储到本地缓存
function LocalPlayerService:saveLocalStorage()
	manager.LocalStorage.setUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "PlayerLocalData", self._playerLocalData);
end

-- 清理类里的数据
function LocalPlayerService:clear()
	-- 用户认证后获得的数据
	self._roleId		= 0;    -- 用户Id, 由游戏服务器获取
	self._iconUrl		= "";   -- 头像图片路径
	self._name			= "";   -- 用户昵称, 用于显示
	self._refreshToken	= "";	-- 认证token
	self._gender		= 0;    -- 性别
	self._ip			= "";   -- 用户登录的ip
	self._btnValue	= 0;    -- 控制用户所选择地区的按钮,32位二进制控制界面按钮开关
	self._area		= config.GlobalConfig.getConfig().AREA_ID;    -- 用户所选择的地区
	self._createTime	= 0;    -- 用户注册时间
	self._isNewPlayer = false; -- 是不是新用户
	self._lastLoginTime = 0; -- 上一次登陆时间戳
	self._isBindDingTalk = false -- 是否绑定钉钉
	self._usingEffects = {}		--玩家当前使用的特效
	self._lastQueryTime = 0;	--为了用户频繁的断线重连请求的数据过多，加入此变量进行控制
	self._interflow = false   -- 账号是否互通过
	self._longitude = 0;	--经度
	self._latitude = 0;		--纬度	
	self._unionId = "";		--unionId
	
	self._isWatcher = false;		-- 是否是旁观者，默认不是

	self._hasPlayFastMode = false; -- 是否玩过极速模式
	
	-- 用户登录到入口服务器获得的数据
	self._gameServerId	= 0; 	-- 用户对应的gameServerId, 于gameServer通信需要
	self._activityManagerServerId = 0; -- 用户对应的activityServerId, 于gameServer通信需要
	self._recordServerId = 0;   -- 用户对应的recordServerId, 于recordServer通信需要
	self._libVersion	= ""
	
	-- 游戏数据
	self._cardCount	= 0;   	-- 房卡数量
	self._ticket		= 0;    -- 门票数量
	self._goldAmount	= 0     -- 金币数量
	self._beanAmount	= 0     -- 金豆数量
	self._CompVoucherCount = 0  -- 参赛券数量
	self._giftTicketCount = 0 -- 礼券数量
	
	--[[        其他包含的service，
        原则上，清理的话只清理从服务器获取的数据，
        如果完全是本地数据，则不清理
    ]]
	self._marqueeService:clear();
	self._historyService:clear();
	self._noticeService:clear();
	self._chatService:clear();
	self._freePlayService:clear();
	self._paymentService:clear()
	game.util.AgtDomainChecker.getInstance():setPoot(nil) -- 退出时设为nil，防止切换地区连错agt
	
	self._playerLocalData = {}
	-- 下面几个数据结构复杂，先不清理，之后再处理
	-- self._moneyTreeService:dispose();
	-- self._clubService:dispose()
	-- self._activityService:dispose()
	-- self._campaignService:dispose()
    --GPS定位信息
    self._location = nil
end



function LocalPlayerService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");
	
	self._localPlayerSettingService = game.service.LocalPlayerSettingService.new();
	self._roomCreatorService = game.service.RoomCreatorService.new();
	self._marqueeService	= game.service.MarqueeService.new()
	self._historyService	= game.service.HistoryRecordService.new();
	self._noticeService	= game.service.NoticeService.new()
	self._chatService		= game.service.ChatService.new();
	self._freePlayService	= game.service.FreePlayService.new();
	self._activityService = game.service.ActivityService.new()
	self._moneyTreeService = game.service.MoneyTreeService.new()
	self._clubService	= game.service.club.ClubService.new() -- 亲友圈
	self._certificationService = game.service.CertificationService.new() -- 身份证认证
	self._pushService	= game.service.PushService.new();
	self._agentService	= game.service.AgentService.new();    --  游戏内的Agt
	self._recordService	= game.service.RecordService.new();    --  历史记录服务器
	self._paymentService	= game.service.PaymentService.new();
	self._mallService	= game.service.MallService.new()    -- 礼券商城
	self._campaignService	= game.service.CampaignService.new() -- 比赛
	self._paymentService	= game.service.PaymentService.new();
	self._giftService	= game.service.GiftService.new();
	self._noticeMailService = game.service.NoticeMailService.new();
	self._backpackService	= game.service.BackpackService.new();
	self._goldService	= game.service.GoldService.new() -- 金币场
	self._headFrameService	= game.service.HeadFrameService.new(); -- 头像商城
	self._localPushService = game.service.LocalPushService.new() --本地推送
	self._friendService = game.service.friend.FriendService.new() -- 好友
	self._uploadLogService = game.service.UploadLogService.new()
	self._bigLeagueService = game.service.bigLeague.BigLeagueService.new()
	
	self:clear()
end

--------------------------
-- Data Accessor
function LocalPlayerService:getIconUrl()				return self._iconUrl; end
function LocalPlayerService:setIconUrl(value)			self._iconUrl = value; end

function LocalPlayerService:getName()					return self._name; end
function LocalPlayerService:setName(value)				self._name = value; end

function LocalPlayerService:getGender()				return self._gender; end
function LocalPlayerService:setGender(value)			self._gender = value; end

function LocalPlayerService:getRoleId()				return self._roleId; end
function LocalPlayerService:setRoleId(value)			self._roleId = value; end

function LocalPlayerService:getIp()					return self._ip; end
function LocalPlayerService:setIp(value)				self._ip = value; end

function LocalPlayerService:getGameServerId()			return self._gameServerId; end
function LocalPlayerService:getRecordServerId()		return self._recordServerId; end

function LocalPlayerService:getBattleServerId()		return self._battleServerId; end
function LocalPlayerService:setBattleServerId(value)	self._battleServerId = value; end

function LocalPlayerService:getActivityManagerServerId()		return self._activityManagerServerId; end

function LocalPlayerService:getCardCount()				return self._cardCount; end
function LocalPlayerService:setCardCount(value)
	self._cardCount = value
	self:dispatchEvent({name = "EVENT_ROOM_CARD_COUNT_CHANGED", value = value})
end

function LocalPlayerService:getGoldAmount()			return self._goldAmount end
function LocalPlayerService:setGoldAmount(value)
	self._goldAmount = value
    self:dispatchEvent({name = "EVENT_GOLD_COUNT_CHANGED", value = value})
    Logger.debug("=================")
    print("EVENT_GOLD_COUNT_CHANGED", value)
    Logger.debug("=================")
end

function LocalPlayerService:getBeanAmount()			return self._beanAmount end
function LocalPlayerService:setBeanAmount(value)
	self._beanAmount = value
	self:dispatchEvent({name = "EVENT_BEAN_COUNT_CHANGED", value = value})
end

function LocalPlayerService:getCompVoucherCount()			return self._CompVoucherCount end
function LocalPlayerService:setCompVoucherCount(value)
	self._CompVoucherCount = value
	self:dispatchEvent({name = "EVENT_COMPVOUCHER_COUNT_CHANGED", value = value})
end

function LocalPlayerService:getGiftTicketCount() return self._giftTicketCount end
function LocalPlayerService:setGiftTicketCount(value)
    self._giftTicketCount = value
    self:dispatchEvent({ name = "EVENT_GIFT_TICKET_COUNT_CHANGED", value = value })
end

function LocalPlayerService:getIsBindDingTalk() return self._isBindDingTalk end
function LocalPlayerService:setIsBindDingTalk(isBindDingTalk) self._isBindDingTalk = isBindDingTalk end


-- competitionVoucherCount
function LocalPlayerService:getPushRegisterId()		return self._pushRegisterId end

function LocalPlayerService:getTicket()				return self._ticket; end
function LocalPlayerService:setBindPhone(phone)			self.phone = phone end
-- 这里的手机号是已经加密过的，例如  138****1234 不要对他进行额外的处理了
function LocalPlayerService:getBindPhone()			return self.phone; end
function LocalPlayerService:setTicket(value)			self._ticket = value; end
function LocalPlayerService:getDotArray()			return self._dotArray end
function LocalPlayerService:getUnionId()			return self._unionId end

function LocalPlayerService:isWatcher()
	return self._isWatcher;
end

function LocalPlayerService:setIsWatcher(is)
	self._isWatcher = is
end

function LocalPlayerService:getArea()					return self._area; end
function LocalPlayerService:setArea(value)				self._area = value; end

function LocalPlayerService:getBtnValue()				return self._btnValue; end
function LocalPlayerService:setBtnValue(value)			self._btnValue = value; end

-- 玩家头像id
function LocalPlayerService:getHeadFrameId()				return self._headFrameId; end
function LocalPlayerService:setHeadFrameId(value)			self._headFrameId = value; end
-- 玩家账号是否互通
function LocalPlayerService:getInterflow()					return self._interflow; end
function LocalPlayerService:setInterflow(value)				
	self._interflow = value
	self:dispatchEvent({name = "EVENT_INTERFLOW_CHANGE", value = value})
end

function LocalPlayerService:getCreateTime()
	return self._createTime
end

-- 玩家是否玩过极速模式
function LocalPlayerService:getHasPlayFastMode()
	return self._hasPlayFastMode
end

function LocalPlayerService:setHasPlayFastMode(hasPlayFastMode)
	self._hasPlayFastMode = hasPlayFastMode
end

function LocalPlayerService:getIsNewPlayer()
	-- 如果是新用户要时刻刷新时间
	if self._isNewPlayer then
		self:_setIsNewPlater()
	end
	return self._isNewPlayer
end

function LocalPlayerService:getLastLoginTime() return self._lastLoginTime end
function LocalPlayerService:isFirstLoginForTimeSpan(days) 
	days = days or 0 -- 日数，可以为小数
	local timeSpan = days * 86400000
	local curremtTimeStamp = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()

	if (curremtTimeStamp - self._lastLoginTime) > timeSpan then
		return true
	end
	return false
end

function LocalPlayerService:isTodayFirstLogin()
    local currentTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    if currentTime < self._lastLoginTime then
        return false
    end
    local currentDate = string.split(os.date("%y-%m-%d", currentTime / 1000), '-')
    local lastLoginDate = string.split(os.date("%y-%m-%d", self._lastLoginTime / 1000), '-')
    if currentDate[3] <= lastLoginDate[3] then -- 比日
        if currentDate[2] <= lastLoginDate[2] then -- 比月
            if currentDate[1] <= lastLoginDate[1] then -- 比年
                Logger.debug("==== NO FIRST LOGIN TODAY ====")
					Logger.debug("==== LAST LOGIN DATE:" .. table.concat(lastLoginDate, '-') .. " ====")
					Logger.debug("==== CURRENT DATE:" .. table.concat(currentDate, '-') .. " ====")
                return false
            end
        end
    end
    return true
end

--------------------------
-- Service Accessor
function LocalPlayerService:getLocalPlayerSettingService()	return self._localPlayerSettingService; end
function LocalPlayerService:getRoomCreatorService()		return self._roomCreatorService; end
function LocalPlayerService:getMarqueeService()		return self._marqueeService; end
function LocalPlayerService:getMailService()			return self._mailService; end
function LocalPlayerService:getHistoryRecordService()	return self._historyService; end
function LocalPlayerService:getBattleService()			return self._battleService; end
function LocalPlayerService:getChatService()			return self._chatService; end
function LocalPlayerService:getNoticeService()			return self._noticeService; end
function LocalPlayerService:getActivityService()		return self._activityService; end
function LocalPlayerService:getClubService()			return self._clubService end
function LocalPlayerService:getFreePlayService()		return self._freePlayService end
function LocalPlayerService:getMoneyTreeService()		return self._moneyTreeService end
function LocalPlayerService:getCertificationService()	return self._certificationService end
function LocalPlayerService:getPushService()			return self._pushService; end
function LocalPlayerService:getAgentService()			return self._agentService; end
function LocalPlayerService:getRecordService()			return self._recordService; end
function LocalPlayerService:getPaymentService()			return self._paymentService; end
function LocalPlayerService:getMallService()			return self._mallService end
function LocalPlayerService:getCampaignService()		return self._campaignService; end
function LocalPlayerService:getPaymentService()			return self._paymentService; end
function LocalPlayerService:getGiftService()			return self._giftService end
function LocalPlayerService:getNoticeMailService()		return self._noticeMailService end
function LocalPlayerService:getGoldService()			return self._goldService; end
function LocalPlayerService:getBackpackService()		return self._backpackService end
function LocalPlayerService:getHeadFrameService()		return self._headFrameService end
function LocalPlayerService:getLocalPushService()		return self._localPushService end
function LocalPlayerService:getFriendService() 			return self._friendService end
function LocalPlayerService:getSpecialEffect()			return self._usingEffects end
function LocalPlayerService:getUploadLogService() 		return self._uploadLogService end
function LocalPlayerService:getBigLeagueService() 		return  self._bigLeagueService end

function LocalPlayerService:getSpecialEffectArray()			
	local result = {}
	table.foreach(self._usingEffects,function (k,v)
		table.insert(result, v.itemId)
	end)
	return result
end

function LocalPlayerService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCRoomCardModifySYNC.OP_CODE, self, self._onGCRoomCardModifySYNC);
	requestManager:registerResponseHandler(net.protocol.GCContactRES.OP_CODE, self, self._onGCContactRES);
	requestManager:registerResponseHandler(net.protocol.GCKickoffSYNC.OP_CODE, self, self._onGCKickoffSYNC);
	requestManager:registerResponseHandler(net.protocol.GCAccountGpsRES.OP_CODE, self, self._onGCAccountGpsRES);
	requestManager:registerResponseHandler(net.protocol.GCTicketModifySYNC.OP_CODE, self, self._onGCTicketModifySYNC)
	requestManager:registerResponseHandler(net.protocol.ACCPlayWinPrizeSYN.OP_CODE, self, self._onACCPlayWinPrizeSYN)
	requestManager:registerResponseHandler(net.protocol.GCNotifyItemsChangeSYN.OP_CODE, self, self._onGCNotifyItemsChangeSYN)
	requestManager:registerResponseHandler(net.protocol.GCSpecialEffectSYN.OP_CODE, self, self._onGCSpecialEffectSYN)
	requestManager:registerResponseHandler(net.protocol.GCRedDotStatusSYN.OP_CODE, self, self._onGCRedDotStatusSYN)
	
	-- 注册定位服务器回调
	game.service.AMapService.getInstance():addEventListener("LOCAL_SERVICE_EVENT_GET_LOCATION_SUCCESS", handler(self, self._onGetLocationSuccess), self)
	
	self._localPlayerSettingService:initialize();
	self._roomCreatorService:initialize();
	self._marqueeService:initialize();
	self._historyService:initialize();
	self._noticeService:initialize();
	self._chatService:initialize();
	self._freePlayService:initialize();
	self._moneyTreeService:initialize();
	self._clubService:initialize()
	-- self._mailService:initialize();
	self._activityService:initialize()
	self._certificationService:initialize()
	self._pushService:initialize()
	self._agentService:initialize()
	self._recordService:initialize()
	self._mallService:initialize()
	self._campaignService:initialize()
	self._paymentService:initialize()
	self._giftService:initialize()
	self._noticeMailService:initialize()
	self._goldService:initialize()
	self._backpackService:initialize()
	self._headFrameService:initialize()
	self._localPushService:initialize()
	self._friendService:initialize()
	self._bigLeagueService:initialize()

	--初始化标签数据
	require("app.game.ui.lobby.mainTag.MainTagData")
	game.service.activity.ActivityServiceManager.getInstance():initialize()
end

function LocalPlayerService:dispose()
	-- 解绑事件系统
	cc.unbind(self, "event");
	
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	game.service.AMapService.getInstance():removeEventListenersByTag(self)
	
	self._localPlayerSettingService:dispose();
	self._roomCreatorService:dispose();
	self._marqueeService:dispose();
	self._historyService:dispose();
	self._noticeService:dispose();
	self._chatService:dispose();
	self._freePlayService:dispose();
	-- self._mailService:dispose();
	self._moneyTreeService:dispose();
	self._clubService:dispose()
	self._activityService:dispose()
	self._certificationService:dispose()
	self._pushService:dispose()
	self._agentService:dispose()
	game.util.AgtDomainChecker.getInstance():setPoot(nil) -- 退出时设为nil，防止切换地区连错agt
	self._recordService:dispose()
	self._mallService:dispose()
	self._campaignService:dispose()
	self._paymentService:dispose()
	self._giftService:dispose()
	self._goldService:dispose()
	self._backpackService:dispose()
	self._headFrameService:dispose()
	self._localPushService:dispose()
	self._friendService:dispose()
	self._bigLeagueService:dispose()
    
    game.service.activity.ActivityServiceManager.getInstance():dispose()
end

function LocalPlayerService:initInterfaceData(protocol)
	Logger.dump(protocol,"initInterfaceData~~~~~~~~~~~~~~~~")
	self._roleId = protocol.roleId
	self._iconUrl = protocol.headImageUrl
	self._name = protocol.nickname
	self._gender = protocol.sex
	self._gameServerId = protocol.gameServerId
	self._recordServerId = protocol.replayServerId
	self._ip = protocol.ip
	self._chatService:setRoleId(protocol.roleId);
	self._pushService:setId(protocol.roleId, protocol.pushServerId);
	self._clubService:setId(protocol.roleId, protocol.clubServerId);
	self._recordService:setId(protocol.roleId, protocol.replayServerId);
	self._campaignService:setId(protocol.campaignServerId)
	self._goldService:setId(protocol.goldServerId)
	self._activityManagerServerId = protocol.activityServerId
	self._bigLeagueService:setId(protocol.roleId, protocol.clubServerId);
	
	self:dispatchEvent({name = "EVENT_INTERFACE_DATA_RETRIVED"});
end

-- @param cardCount: number
-- @param marqueeVersion: number
-- @param hasNewMail: boolean
-- @param noticeVersion: number
function LocalPlayerService:initGameData(protocol, unionId)
	self._area = protocol.area
	
	self:_loadLocalStorage(self._roleId);

	self._createTime = protocol.createTime
	self:_setIsNewPlater()
	self:setCardCount(protocol.roomCardCount)
	self._ticket = protocol.ticket
	self._marqueeVersion = protocol.marqueeVersion
	self._hasNewMail = protocol.newMail
	self._noticeVersion = protocol.noticeVersion
	self._btnValue = protocol.buttonValue
	self._headFrameId = protocol.headFrameId
	self._lastLoginTime = protocol.lastLastLoginTime
	self._isBindDingTalk = protocol.isBindDingTalk
	self._marqueeService:setServerVersion(protocol.marqueeVersion);		
	self._certificationService:setCertificationStatus(protocol.isIdentityVerify)
	self._agentService:setIsAgency(protocol.isAgency)
	self._hasPlayFastMode = protocol.hasPlayFastMode
	
	-- 不同地区的agt通过端口号区分
	self._agentService:setAgtPoot(protocol.agtWebUrl)
	self._unionId = unionId
	self._activityService:setUnionId(unionId)
	game.util.AgtDomainChecker.getInstance():setPoot(protocol.agtWebUrl)
	self._campaignService:getCampaignList():setCurrentCampaignId(protocol.combatId)
	self._campaignService:getCampaignList():setMttStartTime(protocol.mttStartTime)
	
	-- 设置礼包信息
    self._giftService:setGiftInfo(protocol.giftInfo)

	local s = protocol.phone ~= '' and protocol.phone or nil
	self.phone = s
	
	-- 登录之后同步一次系统时间
	game.service.TimeService:getInstance():updateTimeFromServer()
	-- self._mailService:setIsNew(hasNewMail);
	self._dotArray = protocol.notifyRedDot
	
	self._pushRegisterId = protocol.pushRegisterId
	self._getuiRegisterId = protocol.pushClientId
	game.service.PushService.getInstance():setRegisterId(protocol.pushRegisterId, protocol.pushClientId)
	
	-- 加载地区道具配置
	PropReader.loadAreaConfig(self:getArea())
	self:setGoldAmount(protocol.goldAmount)
	self:setBeanAmount(protocol.goldBeanCount)
	self:setCompVoucherCount(protocol.competitionVoucherCount)
	self:dispatchEvent({name = "EVENT_GAME_DATA_RETRIVED"});
	
	
	--金币场相关,如果重连还处于匹配状态则显示匹配界面
	local goldService = game.service.GoldService.getInstance()
	if(protocol.isInGoldMatch) then
		goldService:dispatchEvent({name = "EVENT_GOLD_MATCH_START", roomGrade = goldService:getCurrentRoomGrade()})
	else
		goldService:dispatchEvent({name = "EVENT_GOLD_MATCH_CANCEL"})
	end
	
	local gambleService = game.service.GambleService.getInstance()
	gambleService:initRewardCount(self._dotArray)

	if self._lastQueryTime == 0 					--首次登陆
	or kod.util.Time.now() - self._lastQueryTime > 3600		--距离上次登陆已经过去一小时
	or kod.util.Time.isAnotherDay(self._lastQueryTime) then		--上次登陆还是昨天		
		self._noticeService:queryMainPageNotice()
		self._freePlayService:queryActivity(false);
		
		self._noticeMailService:CGQueryActivityREQ("login")
		self._noticeService:_queryNotice(false)
		self._lastQueryTime = kod.util.Time.now()
		print("query Activity Time~~~~~~~~~~~~~~~~~~~~~~~~~~~:", self._lastQueryTime)
	end
    --更新GPS设置
    self:updateGPSLocation()
end

-- 设置本地玩家基本信息之后，加载保存在本地的数据
function LocalPlayerService:_loadLocalStorage()
	if self._roleId == 0 then
		Logger.error("loadLocalStorage roleId not set");
		return;
	end
	
	self:loadLocalStorage()
	self._localPlayerSettingService:loadLocalStorage();
	self._marqueeService:loadLocalStorage();
	self._chatService:loadLocalStorage();
	self._historyService:loadLocalStorage();
	self._noticeService:loadLocalStorage()
	self._roomCreatorService:loadLocalStorage();
	self._clubService:loadLocalStorage();
	self._pushService:loadLocalStorage();
	self._campaignService:loadLocalStorage();
	self._recordService:loadLocalStorage();
	self._goldService:loadLocalStorage();
	self._activityService:loadLocalStorage();
	self._backpackService:loadLocalStorage();
	self._headFrameService:loadLocalStorage();
	self._clubService:loadSubServiceStorage()
	self._paymentService:loadLocalStorage();
	
	storageTools.AutoShowStorage.initData()
end

-- 放开数量改变通知
function LocalPlayerService:_onGCRoomCardModifySYNC(response)
	local playerService = ns.LocalPlayerService:getInstance();
	local protocol = response:getProtocol():getProtocolBuf();
	local _value = protocol.roomCardCount;
	playerService:setCardCount(_value);
	local ui = UIManager:getInstance():getUI("UIMain");
	if nil ~= ui then
		ui:changeCardValue(_value)
	end
	
end

-- 门票数量改变通知
function LocalPlayerService:_onGCTicketModifySYNC(response)
	local playerService = ns.LocalPlayerService:getInstance();
	local protocol = response:getProtocol():getProtocolBuf();
	local _value = protocol.ticket;
	playerService:setTicket(_value);
	
	self:dispatchEvent({name = "EVENT_TICKET_COUNT_CHANGED"});
end

function LocalPlayerService:getWinPrizeNum()
	return self.winPirzeNum
end

--打牌赢奖
function LocalPlayerService:_onACCPlayWinPrizeSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	self.winPirzeNum = protocol.prizeNumber
	-- UIManager:getInstance():show("UIAward",protocol.prizeNumber)
end

-- 请求代理信息
function LocalPlayerService:queryContact()
	local request = net.NetworkRequest.new(net.protocol.CGContactREQ, self._gameServerId);
	game.util.RequestHelper.request(request);
end

function LocalPlayerService:_onGCContactRES(response)
	local protocol = response:getProtocol():getProtocolBuf();
	if protocol.result == net.ProtocolCode.GC_CONTACT_SUCCESS then
		self:dispatchEvent({name = "EVENT_CONTACT_INFO_GET", protocol = protocol});
	end
end

-- 被服务器主动断开的通知
-- @param response: NetworkResponse<protocol.GCKickoffSYNC>
function LocalPlayerService:_onGCKickoffSYNC(response)
	local protocol = response:getProtocol():getProtocolBuf();
	local bRelogin = protocol.reason == net.ProtocolCode.GC_KICKOFF_HUTONG_SUCCESS
	game.ui.UIMessageBoxMgr.getInstance():show(net.ProtocolCode.code2Str(protocol.reason), {"确定"}, function()
		game.service.LoginService.getInstance():forceLogout(bRelogin)
		return true
	end)
end

--gps 更新
function LocalPlayerService:updateGPSLocation()
    if game.service.AMapService.getInstance():isLocationServiceEnabled() == false then
        self._location = nil
        return
    end
    if self._location and self._location.expireTime > kod.util.Time.now() then
        return
    end
	game.service.AMapService.getInstance():startLocation(true,true)
end

--这里单独提出来,保证跟原来一样，一个房间同步一次
function LocalPlayerService:updateAccountGpsInfo(province, city, district)
    self:_sendCGAccountGpsREQ(province, city, district)
end

-- gps 获取成功
function LocalPlayerService:_onGetLocationSuccess(event)
	-- dump(event, "_onGetLocationSuccess~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	self._latitude = event.latitude
	self._longitude = event.longitude
    
    self._location = { status = 4, latitude = event.latitude, longitude = event.longitude}
    --一次定位的失效时间为5分钟
    self._location.expireTime = kod.util.Time.now() + 300
end

--如果GPS在某个时刻关掉了,那么需要置为nil
function LocalPlayerService:getGpsLocationInfo()
    if game.service.AMapService.getInstance():isLocationServiceEnabled() == false then
        self._location = nil
    end
    return self._location
end

function LocalPlayerService:getGpsPosition()
	return self._longitude,self._latitude
end

-- 同步玩家GPS信息
function LocalPlayerService:_sendCGAccountGpsREQ(province, city, district)
	province	= province or ""
	city		= city or ""
	district	= district or ""
	local request = net.NetworkRequest.new(net.protocol.CGAccountGpsREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:setWaitForResponse(false)
	request:getProtocol():setData(self._roleId, province, city, district)
	game.util.RequestHelper.request(request)
end

function LocalPlayerService:_onGCAccountGpsRES(response)
	local protocol = response:getProtocol():getProtocolBuf();
	if protocol.result == net.ProtocolCode.GC_ACCOUNT_GPS_SUCCESS then
		-- 输出一下log说明成功了
		Logger.debug("LocalPlayerService:_onGCAccountGpsRES")
	end
end

-- 判断是不是新用户
function LocalPlayerService:_setIsNewPlater()
	-- 获取当前时间
	local curTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
	-- 一天的时间
	local dayTiem = 86400000
	-- 当前时间 - 注册时间 < 24小时
	if curTime - self._createTime < dayTiem then
		self._isNewPlayer = true
	else
		self._isNewPlayer = false
	end
end

--金币id,物品系统还没做好,这里临时定义一下
-- local goldId = 251658243
function LocalPlayerService:_onGCNotifyItemsChangeSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local type = PropReader.getTypeById(protocol.id)
	if type == "Gold" then
		self:setGoldAmount(protocol.count)
	elseif type == "GameMoney" then
		self:setBeanAmount(protocol.count)
	elseif type == "CompetitionVoucher" then
		self:setCompVoucherCount(protocol.count)
	elseif type == "NormalCard" then
		self:setCardCount(protocol.count)
	end
end

-- 玩家当前拥有的特效同步
function LocalPlayerService:_onGCSpecialEffectSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local spEffect = protocol.specialEffect
	if spEffect ~= nil then
		self._usingEffects = spEffect
	end
end

-- 同步红点状态值
function LocalPlayerService:_onGCRedDotStatusSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	manager.RedDotStateTreeManager.getInstance():setRedDotData(protocol.redDots)
end

-- 保存玩家断线时界面信息
local LocalRoundReportPage = class("LocalRoundReportPage")

function LocalRoundReportPage:ctor()
	self._cardinfo = false -- 牌局界面UI是否显示
	self._lastcard = false -- 剩余牌池界面UI是否显示
end

function LocalRoundReportPage:setIsVisible(cardinfo, lastcard)
	self._cardinfo = cardinfo
	self._lastcard = lastcard
end

function LocalRoundReportPage:getIsVisible_cardinfo()
	return self._cardinfo
end

function LocalRoundReportPage:getIsVisible_lastcard()
	return self._lastcard
end

function LocalPlayerService:loadLocalRoundReportPage()
	local roleId = self:getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalRoundReportPage", LocalRoundReportPage)
end

function LocalPlayerService:saveLocalRoundReportPage(localRoundReportPage)
	local roleId = self:getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalRoundReportPage", localRoundReportPage)
end

function LocalPlayerService:clearToundReportPage()
	local data = self:loadLocalRoundReportPage()
    data:setIsVisible(false, false)
    self:saveLocalRoundReportPage(data)
end

--[[0
    获得当前处于的大厅， 普通、金币场、比赛场、俱乐部 ...
    若不在任何大厅，则返回枚举值 None
]]
function LocalPlayerService:getCurrentLobbyType()
    local currentStateName = GameFSM.getInstance():getCurrentState().class.__cname
    local isInLobby_Gold = currentStateName == "GameState_Gold"
    local isInLobby_Club = currentStateName == "GameState_Club"
    local isInLobby_Camp = UIManager:getInstance():getIsShowing("UICampaignMain")
    -- 进入比赛场并不会切换普通的状态机，所以，在进行校验普通大厅的时候，要判断其他是否满足
    local isInLobby_Norm = (currentStateName == "GameState_Lobby" 
    and not isInLobby_Gold 
    and not isInLobby_Club 
    and not isInLobby_Camp)

    if isInLobby_Norm then
        return game.globalConst.LobbyType.Normal
    elseif isInLobby_Gold then
        return game.globalConst.LobbyType.Gold
    elseif isInLobby_Club then
        return game.globalConst.LobbyType.Club
    elseif isInLobby_Camp then
        return game.globalConst.LobbyType.Campaign
    else
        return game.globalConst.LobbyType.None
    end
end

--[[0
    获得当前的房间类型，若不在房间内，则返回 roomType.none
]]
function LocalPlayerService:getCurrentRoomType()
    local roomService = game.service.RoomService.getInstance()
    if roomService == nil then
        return game.globalConst.roomType.none
    end
    return roomService:getRoomType()
end

--检测是否要打开推送界面
function LocalPlayerService:checkShowTuisong()
	local buttonConst = require("app.gameMode.mahjong.core.Constants").ButtonConst
	release_print("checkShowTuisong1111111111", game.plugin.Runtime.notificationsEnabled(), bit.band(self._btnValue, buttonConst.TUI_SONG))
	if game.plugin.Runtime.notificationsEnabled() == 1 or bit.band(self._btnValue, buttonConst.TUI_SONG) == 0 then
		return false
	end
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.not_open_tuisong);
	local nowTime = game.service.TimeService.getInstance():getCurrentTime()
	local lastTime = cc.UserDefault:getInstance():getIntegerForKey("Time_Tuisong_Check", 0)
	local typeTuisong = cc.UserDefault:getInstance():getIntegerForKey("Type_Tuisong_Check", 1)
	release_print("checkShowTuisong22222222222222222", lastTime, nowTime)
	if lastTime == 0 then
		cc.UserDefault:getInstance():setIntegerForKey("Time_Tuisong_Check", nowTime)
		cc.UserDefault:getInstance():flush()
		return false
	else
		local dayTime = 24 * 3600
		if (typeTuisong == 1 and nowTime - lastTime > 3* dayTime) or (nowTime - lastTime > 7 * dayTime)then
			cc.UserDefault:getInstance():setIntegerForKey("Time_Tuisong_Check", nowTime)
			return true
		end		
	end
end

-- 检测是否显示UI改版弹窗
function LocalPlayerService:getIsShowUIChange()
	local isShow = false 
	local Version = require "app.kod.util.Version"
	local curVersionStr = game.plugin.Runtime.getBuildVersion()
    -- 获取存储版本信息，若为空，表示要显示
    local saveVersionStr = cc.UserDefault:getInstance():getStringForKey("First_Version") 
    if string.len(saveVersionStr) <= 0 then 
		isShow = true 
	else
		-- 若存在，存储版本小于当前版本时，要显示
		local saveVersion = Version.new(saveVersionStr)
		local currentVersion = Version.new(curVersionStr)
		local code = saveVersion:compare(currentVersion)
		if code < 0 then 
			isShow = true  
		end 
    end 

	-- 存储下版本信息
	if isShow then 
		cc.UserDefault:getInstance():setStringForKey("First_Version", curVersionStr) 
	end 
	return isShow 
end 