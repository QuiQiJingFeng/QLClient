--[[	--摇钱树,活动
--]]
local ns		= namespace("game.service")
local activity	= {}


--奖励类型
--[[// 其他类型
public static final int OTHER = 0;
// 房卡
public static final int ROOM_CARD = 1;
// 礼券
public static final int MALL_POINTS = 2;
// 现金红包
public static final int MONEY = 3;
// 比赛门票
public static final int CAMPAIGN_TICKET = 4;
// 实物奖励
public static final int GOOD = 5;
]]
--
local MoneyTreeService = class("MoneyTreeService")
ns.MoneyTreeService = MoneyTreeService

local instance = nil
function MoneyTreeService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");
	
	--抽奖次数
	self._itemCount = 0;
	--个人奖励表
	self.awardList = {};

	--公告表
	self.waitToShow = {};
	--是否显示摇钱树小红点
	self.bShowRedPoint = false;
	self._goodsRed = false
	--是否是断线重连
	self.bReconnection = false;
end

function MoneyTreeService:getInstance()
	if game.service.LocalPlayerService ~= nil then
		return game.service.LocalPlayerService:getInstance():getMoneyTreeService()
	end
	
	return nil
end

function MoneyTreeService:initialize()
	-- 监听网络操作 
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCQueryTurntableInfoRES.OP_CODE, self, self._onQueryTurntableInfoRES);
	requestManager:registerResponseHandler(net.protocol.GCTurntableDrawRES.OP_CODE, self, self._onTurntableDrawRES);
	requestManager:registerResponseHandler(net.protocol.CGShareTurntableRewardRES.OP_CODE, self, self._onShareTurntableRewardRES);
	requestManager:registerResponseHandler(net.protocol.GCPlayerHasItemCountSYN.OP_CODE, self, self._onPlayerHasItemCountSYN);
	
	game.service.GiftService:getInstance():addEventListener("EVENT_RECIEVED_GIFT_LIST", function(event)
		self:_refreshGoodsRed(event.protocol.goodsList)
	end, self)
end

function MoneyTreeService:getItemCount()
	return self._itemCount;
end

function MoneyTreeService:getBShowRedPoint()
	return self.bShowRedPoint or self._goodsRed;
end

function MoneyTreeService:setBReconnection(b)
	self.bReconnection = b;
end

function MoneyTreeService:getBReconnection()
	return self.bReconnection;
end

function MoneyTreeService:_onPlayerHasItemCountSYN(protocol)
	self.bShowRedPoint = true;
end

--发送查询转盘信息请求 
function MoneyTreeService:requestQueryTurntableInfo()
	local request = net.NetworkRequest.new(net.protocol.CGQueryTurntableInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

--发送转盘抽奖请求
function MoneyTreeService:requestTurntableDraw()
	local request = net.NetworkRequest.new(net.protocol.CGTurntableDrawREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

--收到查询转盘返回信息 
function MoneyTreeService:_onQueryTurntableInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	if protocol.result == net.ProtocolCode.GC_QUERY_TURNTABLE_INFO_SUCCESS then
		--获取数据
		if protocol.lastRewardInfo then
			for _, v in ipairs(protocol.lastRewardInfo) do
				table.insert(self.waitToShow, v);
			end
		end
		
		if #protocol.rewards > 0 then
			self.awardList = protocol.rewards;
		else
			self.awardList = {}
		end
		
		--不是断线重连，则需要显示摇钱树界面
		if not self:getBReconnection() then
		else
			self:setBReconnection(false);
		end
		
		self:refreshShowRed(protocol);
		self:_refreshGoodsRed(protocol.goodsList);
		
		self:dispatchEvent({name = "EVENT_MONEY_TREE_DATA_RECEIVED"})
	end
end

--发送转盘分享请求  
function MoneyTreeService:requestShareTurntableReward()
	local request = net.NetworkRequest.new(net.protocol.CGShareTurntableRewardREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

--收到转盘抽奖返回信息  
function MoneyTreeService:_onTurntableDrawRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_TURNTABLE_DRAW_SUCCESS then
		--获取数据
		self:refreshShowRed(protocol);
		
		if protocol.lastRewardInfo then
			for _, v in ipairs(protocol.lastRewardInfo) do
				table.insert(self.waitToShow, v);
			end
		end
		
		local reward = nil
		if protocol.reward and PropReader.getTypeById(protocol.reward.itemId) ~= "RealItem" then
			table.insert(self.awardList, protocol.reward)
			reward = protocol.reward
		else
			self:setGoodsRed(true)
		end
		
		--转盘抽奖成功
		self:dispatchEvent({name = "EVENT_TurntableDrawRES", reward = reward})
		
		UIManager:getInstance():show("UIMoneyTreeAward", protocol.reward.rewardId)
	end
end

--收到转盘分享返回信息 
function MoneyTreeService:_onShareTurntableRewardRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	if protocol.result == net.ProtocolCode.GC_SHARE_TURNTABLE_REWARD_SUCCESS then
		--分享成功
		self:refreshShowRed(protocol);
		--转盘抽奖成功
		self:dispatchEvent({name = "EVENT_ShareTurntableRewardRES"})
	end
end

function MoneyTreeService:refreshShowRed(data)
	if data.itemCount then
		self._itemCount = data.itemCount;
		self:setShowRed(self._itemCount > 0)
	end
end

function MoneyTreeService:setShowRed(value)
	if value ~= self.bShowRedPoint then
		self.bShowRedPoint = value
		self:dispatchEvent({name = "EVENT_MONEY_TREE_SHOW_RED_CHANGE", red = value})
	end
end

function MoneyTreeService:setGoodsRed(value)
	if value ~= self._goodsRed then
		self._goodsRed = value
		self:dispatchEvent({name = "EVENT_MONEY_TREE_GIFT_RED_CHANGE", red = value})
	end
end

function MoneyTreeService:getGoodsRed(value)
	return self._goodsRed
end

function MoneyTreeService:_refreshGoodsRed(goodList)

	for _, v in ipairs(goodList) do
		if(v.status == 0) then
			self:setGoodsRed(true)
			return
		end
	end
	self:setGoodsRed(false)
end

function MoneyTreeService:clear()
	self._itemCount = 0;
	self.awardList = {};

	self.waitToShow = {};
	self.setShowRed(false)
	self.setGoodsRed(false)
end

function MoneyTreeService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	game.service.GiftService:getInstance():removeEventListenersByTag(self)
	-- 解绑事件系统
	cc.unbind(self, "event");
end

