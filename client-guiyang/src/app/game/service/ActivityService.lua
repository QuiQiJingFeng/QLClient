--[[    EVENT_WECHAT_ACTIVITY_CHANGED                   微信分享活动状态变更推送
        EVENT_WECHAT_SHARECONTENT_CHANGED               微信分享活动内容变更推送
        EVENT_WECHAT_SHAREURL_CHANGED                   微信分享链接生成推送
]]
local saveKey = "ActivitySaveCache"
local ActivitySaveCache = class("ActivitySaveCache")

function ActivitySaveCache:ctor(...)
	-- 每日自动弹窗的活动数据缓存
	self.autoShowUIData = {}
	-- 七夕充值活动是否弹窗
	self.qixiShowwed = false	
end

local ns = namespace("game.service")
local TimeService = require("app.game.service.TimeService")

local ActivityService = class("ActivityService")
ns.ActivityService = ActivityService

local activity = {}

activity.FreePlayData = {
	activityId = - 1,
	startTime = - 1,
	endTime	= - 1,
}

activity.InviteType = {
    Invite = 1,
    BeInvited = 2,
}

activity.FreePlayData.clone = function(activityId, startTime, endTime)
	local data				= {}
	data.activityId		= activityId
	data.startTime			= startTime
	data.endTime			= endTime
	return data
end

-- 单例
function ActivityService.getInstance()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		return game.service.LocalPlayerService.getInstance():getActivityService()
	end
	
	return nil
end

function ActivityService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");
	
	self._activeData = {}
	self.waitingData = {}
	self.activeData = {}
	self._shareChannels = true       -- 记录分享渠道（true  好友   false 朋友圈）
	
	self._hasGroup = false          -- 是否是分享到朋友圈
	
	-- 微信分享有礼活动的数据
	self._unionId = ""
	-- 本地缓存
	self.activeCache = nil
	
	self._enterGameShow = false     --每日首次进游戏展示 
	self._shareCardShow = false
end


function ActivityService:getEnterShow()
	local bShow = self._enterGameShow;
	self._enterGameShow = true
	return bShow
end

function ActivityService:getShareCardShow()
	local bShow = self._shareCardShow;
	self._shareCardShow = true
	return bShow
end

function ActivityService:initialize()
	local requestManager = net.RequestManager.getInstance()
	-- 微信分享赠房卡活动
	requestManager:registerResponseHandler(net.protocol.ACCMainSceneShareQueryRES.OP_CODE, self, self._onMainSceneShareQueryRES);
	requestManager:registerResponseHandler(net.protocol.ACCMainSceneSharePickRES.OP_CODE, self, self._onMainSceneSharePickRES);
	-- 微信分享有礼活动
    requestManager:registerResponseHandler(net.protocol.ACCQueryShareRewardsRES.OP_CODE, self, self._onACCQueryShareRewardsRES);
    requestManager:registerResponseHandler(net.protocol.CACQueryPickRewardRES.OP_CODE, self, self._onCACQueryPickRewardRES);	
	--同步活动标签
	requestManager:registerResponseHandler(net.protocol.GCActivityTagSYN.OP_CODE, self, self._onGCActivityTagSYN)

	requestManager:registerResponseHandler(net.protocol.ACCActivityInfoSYN.OP_CODE, self, self._onACCActivityInfoSYN)

	requestManager:registerResponseHandler(net.protocol.ACCActivityInfoUpdateSYN.OP_CODE, self, self._onACCActivityInfoUpdateSYN)

	--初始化标签数据
    require("app.game.ui.lobby.mainTag.MainTagData")
end

function ActivityService:_onACCActivityInfoSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	self:_clearData()
	for _, req in ipairs(protocol.info) do
		local data = activity.FreePlayData.clone(req.id, req.startTime, req.endTime)
        table.insert(self._activeData, data)
	end
    self:_startTimer(self._activeData)
    
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEN_JUAN)
    if service and protocol.questionnaireStatus then
        service.questionnaireStatus = protocol.questionnaireStatus
    end

	--self:printActivityInfo()
end

function ActivityService:_onACCActivityInfoUpdateSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local isUpdata = false
	local activeData = {}
	if #self._activeData > 0 then
		for k, v in ipairs(self._activeData) do
			local data
			if v.activityId == protocol.info.id then
				data = activity.FreePlayData.clone( protocol.info.id,  protocol.info.startTime,  protocol.info.endTime)
				isUpdata = true
			else
				data = activity.FreePlayData.clone(v.activityId, v.startTime, v.endTime)
			end
			table.insert(activeData, data)
		end

		if isUpdata == false then
			local data = activity.FreePlayData.clone( protocol.info.id,  protocol.info.startTime,  protocol.info.endTime)
			table.insert(activeData, data)
		end
	end
	-- 先这样处理俱乐部锦鲤活动
	if protocol.info.id == 300028 then
		self:dispatchEvent({name = "EVENT_ACTIVITY_KOI"})
	end

	self:_clearData()
	for _, req in ipairs(activeData) do
		local data = activity.FreePlayData.clone(req.activityId, req.startTime, req.endTime)
		table.insert(self._activeData, data)
	end

	self:_startTimer(self._activeData)
end

function ActivityService:_clearData()
	self._activeData = {}
	self.waitingData = {}
	self.activeData = {}
end

function ActivityService:getNeedAutoShowActivityIDList()
	local openingActivityIDList = self:getOpeningActivityIDList()
	local ret = {}
	local time = game.service.TimeService:getInstance():getCurrentTime()
	local currentDate = os.date("%x", time)
	for _, id in ipairs(openingActivityIDList) do
		if self.activeCache.autoShowUIData[tostring(id)] ~= currentDate then
			self.activeCache.autoShowUIData[tostring(id)] = currentDate
			table.insert(ret, id)
		end
	end
	if #ret ~= 0 then
		self:saveData()
	end
	return ret
end

function ActivityService:saveData()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, saveKey, self.activeCache)
end

function ActivityService:loadLocalStorage()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	self.activeCache = manager.LocalStorage.getUserData(roleId, saveKey, ActivitySaveCache)
end

function ActivityService:dispose()
	game.service.WeChatService.getInstance():removeEventListenersByTag(self);
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	
	-- 清空计时器
	if self._endTimerScheduler ~= nil then
		unscheduleOnce(self._endTimerScheduler)
		self._endTimerScheduler = nil
	end
	if self._startTimerScheduler ~= nil then
		unscheduleOnce(self._startTimerScheduler)
		self._startTimerScheduler = nil
	end

	if self._shareCardTimer ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareCardTimer)
		self._shareCardTimer = nil
	end
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

-- @param type: net.protocol.activityType
function ActivityService:isActivitieswithin(activityType)
	local curTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
	for _, req in ipairs(self._activeData) do
		if req.activityId == activityType then
			if curTime > req.startTime and curTime < req.endTime then
				return true
			else
				return false
			end
		end
	end
	
	return false
end

function ActivityService:getOpeningActivityIDList()
	local curTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
	local idList = {}
	for _, req in ipairs(self._activeData) do
		if curTime > req.startTime and curTime < req.endTime then
			table.insert(idList, req.activityId)
		end
	end
	return idList
end

--移除对应活动
function ActivityService:removeActivityWithId(activityType)
	for i = 1, #self._activeData do
		if self._activeData[i].activityId == activityType then
			table.remove(self._activeData, i)
			self:dispatchEvent({name = "EVENT_ACTIVITY_CHANGE"})
			break
		end
	end
end

-- 获取活动时间
function ActivityService:activityTime(activityType)
	for _, req in ipairs(self._activeData) do
		if req.activityId == activityType then
			return req
		end
	end
	
	return nil
end

function ActivityService:setShareChannels(channel)
	self._shareChannels = channel
end

function ActivityService:setHasGroup(hasGroup)
	self._hasGroup = hasGroup
end

--------------------------------------------------------------
--[[    微信分享赠房卡活动
]]
-- 请求微信分享活动
function ActivityService:queryMainSceneShareQuery()
	net.NetworkRequest.new(net.protocol.CACMainSceneShareQueryREQ, game.service.LocalPlayerService:getInstance():getActivityManagerServerId()):execute()
end

function ActivityService:_onMainSceneShareQueryRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:isSuccessful() then
		local isVisible = protocol.remainderCount > 0
		UIManager.getInstance():show("UICollectionActivity", isVisible)
	end
end

function ActivityService:getReceiveCard()
	if self._shareCardTimer ~= nil then
		return
	end
	self._shareCardTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		self:sendCACMainSceneSharePickREQ()
		if self._shareCardTimer ~= nil then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareCardTimer)
			self._shareCardTimer = nil
		end
	end, 7, false)
end

-- 分享成功请求领取
function ActivityService:sendCACMainSceneSharePickREQ()
	net.NetworkRequest.new(net.protocol.CACMainSceneSharePickREQ, game.service.LocalPlayerService:getInstance():getActivityManagerServerId()):execute()
end

function ActivityService:_onMainSceneSharePickRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		local text = "恭喜您获得1张房卡！"
		local playerInfo = self:loadLocalPlayerInfo()
		playerInfo:getPlayerInfo()._shareCardCount = 4
		self:saveLocalPlayerInfo(playerInfo)
		-- 更新房卡数量和飘窗内容
		self:dispatchEvent({name = "EVENT_WECHAT_SHARECONTENT_CHANGED", shareContent = text})
	end

	UIManager.getInstance():hide("UICollectionActivity")
end

function ActivityService:getSharecontent()
	self:queryMainSceneShareQuery()
	return self._shareContent
end

--------------------------------------------------------------
--[[    微信分享有礼活动
]]
-- 微信分享有礼活动
function ActivityService:isShareQuality()
	if self:isActivitieswithin(net.protocol.activityType.WEIXIN_SHARE) then
		return true
	end
	
	return false
end

function ActivityService:setUnionId(unionId)
	self._unionId = unionId
end

function ActivityService:getUnionId()
	return self._unionId
end

-- 查询领奖信息
function ActivityService:sendCACQueryShareRewardsREQ()
	local request = net.NetworkRequest.new(net.protocol.CACQueryShareRewardsREQ, game.service.LocalPlayerService:getInstance():getActivityManagerServerId())
	game.util.RequestHelper.request(request)
end

-- 奖励更新
function ActivityService:_onACCQueryShareRewardsRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_QUERY_SHARE_REWARD_SUCCESS then
        if protocol.inviteType == activity.InviteType.Invite then
            if UIManager:getInstance():getIsShowing("UIComebackInvite") then
                UIManager:getInstance():getUI("UIComebackInvite"):refreshData(protocol)
            else
                UIManager:getInstance():show("UIComebackInvite", protocol)
            end
        elseif protocol.inviteType == activity.InviteType.BeInvited then
            if UIManager:getInstance():getIsShowing("UIComebackBeInvited") then
                UIManager:getInstance():getUI("UIComebackBeInvited"):refreshData(protocol)
            else
                UIManager:getInstance():show("UIComebackBeInvited", protocol)
            end
        end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 回流活动领奖
function ActivityService:sendCACQueryPickRewardREQ(inviteType,pick)
    local request = net.NetworkRequest.new(net.protocol.CACQueryPickRewardREQ, game.service.LocalPlayerService:getInstance():getActivityManagerServerId())
    request:getProtocol():setData(inviteType,pick)
    game.util.RequestHelper.request(request)
end

-- 回流活动领奖
function ActivityService:_onCACQueryPickRewardRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_QUERY_PICK_REWARD_SUCCESS then
        self:sendCACQueryShareRewardsREQ()
		game.ui.UIMessageBoxMgr.getInstance():show("领取成功，红包奖励请前往公众号“myqhd2017”领取。", {"复制"},function ()
            if game.plugin.Runtime.setClipboard("myqhd2017") then
                game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功！")    
            end
        end)
    elseif protocol.result == net.ProtocolCode.ACC_QUERY_PICK_REWARD_VERIFY then
        self:sendCACQueryShareRewardsREQ()
        game.ui.UIMessageBoxMgr.getInstance():show("申请成功，审核将在1-2个工作日内完成，审核成功即可前往公众号提现，并邮件通知。", {"我知道了"})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 生成链接
function ActivityService:changeLongUrl2Short(url)
	--  lua urlencode urldecode URL编码
	local encodeURL = function(s)
		s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
		return string.gsub(s, " ", "+")
	end
	
	-- 一个免费生成二维码api应该能直接用
	local requestUrl = "http://b.bshare.cn/barCode?site=weixin&url=" ..(encodeURL(url))
	local FILE_TYPE = "playericon"
	
	-- 下载二维码
	manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, requestUrl, function(tf, fileType, fileName)
		if Macro.assetFalse(tf) then
			-- 获取成功之后设置图片			
			local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
			self:dispatchEvent({name = "EVENT_WECHAT_SHAREURL_CHANGED", imgPath = filePath})
		end
	end)
end

-- 活动状态根据开启或者结束时间更新
function ActivityService:_startTimer(datas)
	for _, data in ipairs(datas) do
		if data.startTime < game.service.TimeService:getInstance():getCurrentTimeInMSeconds() then
			-- 活动已经开始
			table.insert(self.activeData, data)
		else
			-- 等待活动开始
			table.insert(self.waitingData, data)
		end
	end
	
	table.sort(self.activeData, function(a, b) return a.endTime < b.endTime end)
	table.sort(self.waitingData, function(a, b) return a.startTime < b.startTime end)
	
	-- 根据情况启动计时器
	if #self.waitingData > 0 then
		self:_startNextWaitData()
	end
	if #self.activeData > 0 then
		self:_endNextActData()
	end
end

function ActivityService:_startNextWaitData()
	if self._startTimerScheduler ~= nil then
		unscheduleOnce(self._startTimerScheduler)
		self._startTimerScheduler = nil
	end
	
	while #self.waitingData > 0 do
		local delayTime = self.waitingData[1].startTime - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
		-- 当前活动开启了
		if delayTime <= 0 then
			table.insert(self.activeData, self.waitingData[1])
			table.remove(self.waitingData, 1)
		else
			self._startTimerScheduler = scheduleOnce(handler(self, self._startNextWaitData), delayTime / 1000, false)
			break
		end
	end
	
	self:_refreshMainFreeFlag()
	table.sort(self.activeData, function(a, b) return a.endTime < b.endTime end)
	
	-- 清空上次的定时器
	if self._endTimerScheduler ~= nil then
		unscheduleOnce(self._endTimerScheduler)
		self._endTimerScheduler = nil
	end
	
	if #self.activeData > 0 then
		self._endTimerScheduler = nil
		self:_endNextActData()
	end	
end

function ActivityService:_endNextActData()
	if self._endTimerScheduler ~= nil then
		unscheduleOnce(self._endTimerScheduler)
		self._endTimerScheduler = nil
	end
	
	while #self.activeData > 0 do
		local delayTime = self.activeData[1].endTime - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
		if delayTime <= 0 then
			-- 当前活动结束
			table.remove(self.activeData, 1)
		else
			-- 开启下次活动
			self._endTimerScheduler = scheduleOnce(handler(self, self._endNextActData), delayTime / 1000, false)
			break
		end
    end
    
	self:_refreshMainFreeFlag()
end

-- 活动时间开启或者关闭刷新客户端显示
function ActivityService:_refreshMainFreeFlag()
	self:dispatchEvent({name = "EVENT_WECHAT_ACTIVITY_CHANGED"});
end

-- 新的类新手引导的统计，依赖于UIMain，改为UIMain在刷新限免时去刷新
function ActivityService:checkNewerGuide()
	if self:isActivitieswithin(net.protocol.activityType.NEWER_GUIADE) then
		self:dispatchEvent({name = "NEWER_GUAIDE"});
	end
end

function ActivityService:endActivity(id)
	if self:isActivitieswithin(id) then
		for idx, req in ipairs(self._activeData) do
			if req.activityId == id then
				table.remove(self._activeData, idx)
				break
			end
		end
	end
end

--活动标签
function ActivityService:_onGCActivityTagSYN(response)
	self:dispatchEvent({name = "EVENT_MAIN_TAG_DATA_RECEIVE", protocol = response:getProtocol():getProtocolBuf()})
end

local PlayerInfo = class("PlayerInfo")
function PlayerInfo:ctor()
	self.playId = 0
	self._shareCardCount = 1
end

local LocalPlayerInfo = class("LocalPlayerInfo")

function LocalPlayerInfo:ctor()
	self._playerInfo = {}
end

function LocalPlayerInfo:getPlayerInfo()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	for i, data in ipairs(self._playerInfo) do
		if data.playId == roleId then
			return data
		end
	end
	-- 如果本地没有保存就新创建一个
	local playerInfo = PlayerInfo.new()
	playerInfo.playId = roleId
	table.insert(self._playerInfo, playerInfo)
	return playerInfo
end

function ActivityService:loadLocalPlayerInfo()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalPlayerInfo", LocalPlayerInfo)
end

function ActivityService:saveLocalPlayerInfo(localPlayerInfo)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalPlayerInfo", localPlayerInfo)
end

function ActivityService:printActivityInfo()
	Logger.debug("========== printActivityInfo ==========")
	for _, req in ipairs(self._activeData) do
		local s = kod.util.Time.dateWithFormat(nil, req.startTime * 0.001)
		local e = kod.util.Time.dateWithFormat(nil, req.endTime * 0.001)
		Logger.debug("[%s]: [%s, %s]", req.activityId, s, e)
	end
	Logger.debug("========== printActivityInfo ==========")
end