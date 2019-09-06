
--[[本次功能相关事件

EVENT_GAMBLE_INFO_RECEIVE  			-- 获取到竞彩比赛的总信息
EVENT_GAMBLE_GAME_STAKE    			-- 成功押注某比赛
EVENT_GAMBLE_GAME_ODD_CHANGE		-- 某比赛的赔率发生变化
EVENT_PLAYER_GAMBLE_RECEIVE			-- 获取玩家的竞彩信息
EVENT_PLAYER_GAMBLE_REWARD_GET		-- 领取竞彩的奖励

EVENT_GAMBLE_REWARD_COUNT_CHANGE	-- 可领取奖励次数发生变化(红点需要)
EVENT_SHOW_GAMBLE_STAKE_UI			-- 显示押注界面(用于不同界面的通信)
EVENT_STAKE_UI_HIDE					-- 押注界面关闭(用于不同界面的通信)
EVENT_NEW_GAMBLE_REWARD_CAN_GET		-- 可领取新的竞彩奖励
]]
local ns = namespace("game.service")
local GambleService = class("GambleService")
ns.GambleService = GambleService

local stakeTeamType = net.protocol.stakeTeamType

local instance = nil
function GambleService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");
	self.commonConfig = {}
	--记录尚有多少可领取奖励
	self._rewardCount = 0
end

function GambleService:getInstance()
	if instance == nil then
		instance = GambleService.new()
		instance:initialize()
	end
	return instance
end

function GambleService:initialize()
	
	
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCQueryLotteryInfoRES.OP_CODE, self, self._onGCQueryLotteryInfoRES);
	requestManager:registerResponseHandler(net.protocol.GCQueryStakeRES.OP_CODE, self, self._onGCQueryStakeRES);
	requestManager:registerResponseHandler(net.protocol.GCOddsModifySYN.OP_CODE, self, self._onGCOddsModifySYN);
	requestManager:registerResponseHandler(net.protocol.GCQueryPlayerBetsRES.OP_CODE, self, self._onGCQueryPlayerBetsRES);
	requestManager:registerResponseHandler(net.protocol.GCQueryReceiveRES.OP_CODE, self, self._onGCQueryReceiveRES);
	requestManager:registerResponseHandler(net.protocol.GCLotteryRedDotSYN.OP_CODE, self, self._onGCLotteryRedDotSYN);
end

function GambleService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	-- 解绑事件系统
	cc.unbind(self, "event");
end
--登录时初始化竞彩可领取的奖励
function GambleService:initRewardCount(listRed)
	local index = table.indexof(listRed, net.protocol.activityType.LOTTERY)
	if index then
		self._rewardCount = 1
	end
end
--获取能否领取竞彩奖励
function GambleService:canDrawReward()
	return self._rewardCount > 0
end


-- operate 1打开 2关闭
function GambleService:sendCGQueryLotteryInfoREQ(operate)
	local request = net.NetworkRequest.new(net.protocol.CGQueryLotteryInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea(), operate)
	game.util.RequestHelper.request(request)
end

function GambleService:_onGCQueryLotteryInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_LOTTERY_INFO_SUCCESS then
		-- 获取竞彩的数据
		self.commonConfig.serviceCharge = tonumber(protocol.serviceCharge)
		self.commonConfig.limitOfMoney = tonumber(protocol.limitOfMoney)
		self.commonConfig.games = {}
		for k, v in ipairs(protocol.games) do
			self.commonConfig.games[v.id] = v
		end
		self:dispatchEvent({name = "EVENT_GAMBLE_INFO_RECEIVE", protocol = protocol});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
	
end

function GambleService:sendCGQueryStakeREQ(id, team, money)
	local request = net.NetworkRequest.new(net.protocol.CGQueryStakeREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea(), id, team, money)
	game.util.RequestHelper.request(request)
end

function GambleService:_onGCQueryStakeRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local request = response:getRequest():getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_STAKE_SUCCESS then
		local data = self.commonConfig.games[request.id]
		if request.team == stakeTeamType.home then
			data.homeMoney = data.homeMoney + request.money
		elseif request.team == stakeTeamType.away then
			data.visitingMoney = data.visitingMoney + request.money
		else
			data.dogFallMoney = data.dogFallMoney + request.money
		end
		
		self:dispatchEvent({name = "EVENT_GAMBLE_GAME_STAKE", id = request.id})
		
		UIManager.getInstance():show("UIGambleTips", request.id, request.team, request.money)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
	
end

function GambleService:_onGCOddsModifySYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local changedIds = {}
	--有可能没有退出服务器关注列表,导致没数据的时候收到推送,加个判空
	if not self.commonConfig.games then
		return
	end
	
	for k, v in ipairs(protocol.odds) do
		if self.commonConfig.games[v.id] then
			self.commonConfig.games[v.id].homeOdds = v.homeOdds
			self.commonConfig.games[v.id].visitingOdds = v.visitingOdds
			self.commonConfig.games[v.id].dogFall = v.dogFall
		end
		table.insert(changedIds, v.id)
	end
	
	self:dispatchEvent({name = "EVENT_GAMBLE_GAME_ODD_CHANGE", changedIds = changedIds});
end

function GambleService:sendCGQueryPlayerBetsREQ()
	local request = net.NetworkRequest.new(net.protocol.CGQueryPlayerBetsREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea())
	game.util.RequestHelper.request(request)
end

function GambleService:_onGCQueryPlayerBetsRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_PLAYER_BETS_SUCCESS then
		local count = 0
		for k, v in ipairs(protocol.playerBets) do
			if v.status == net.protocol.betStatus.canReceive then
				count = count + 1
			end
		end
		
		self._rewardCount = count
		self:dispatchEvent({name = "EVENT_PLAYER_GAMBLE_RECEIVE", protocol = protocol});
		-- self:dispatchEvent({name = "EVENT_GAMBLE_REWARD_COUNT_CHANGE"})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
	
end


function GambleService:sendCGQueryReceiveREQ(id, odds, index)
	local request = net.NetworkRequest.new(net.protocol.CGQueryReceiveREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea(), id, odds)
	request.index = index
	game.util.RequestHelper.request(request)
end

function GambleService:_onGCQueryReceiveRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local request = response:getRequest()
	
	if protocol.result == net.ProtocolCode.GC_QUERY_RECEIVE_SUCCESS then
		--领取竞彩奖励的事件
		self:dispatchEvent({name = "EVENT_PLAYER_GAMBLE_REWARD_GET", index = request.index});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
	
	--有可能延时导致没收到回复再次请求就会次数混乱所以在这里改变一下次数
	self._rewardCount = self._rewardCount - 1
	self:dispatchEvent({name = "EVENT_GAMBLE_REWARD_COUNT_CHANGE"})
end

function GambleService:_onGCLotteryRedDotSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	self._rewardCount = 1
	self:dispatchEvent({name = "EVENT_GAMBLE_REWARD_COUNT_CHANGE"})
	self:dispatchEvent({name = "EVENT_NEW_GAMBLE_REWARD_CAN_GET"})
end















