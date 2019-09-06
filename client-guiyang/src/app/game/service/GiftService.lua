local ns = namespace("game.service")
local GiftService = class('GiftService')
ns.GiftService = GiftService

function GiftService.getInstance()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		return game.service.LocalPlayerService.getInstance():getGiftService()
	end
	
	return nil
end

-- 实物奖励Service
function GiftService:ctor()
	cc.bind(self, "event");

	self._giftInfo = {}
end

function GiftService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCApplyGoodsRES.OP_CODE, self, self._onGCApplyGoodsRES);
	requestManager:registerResponseHandler(net.protocol.GCQueryGoodsRES.OP_CODE, self, self._onGCQueryGoodsRES);
	requestManager:registerResponseHandler(net.protocol.GCReceiveGiftRES.OP_CODE, self, self._onGCReceiveGiftRES);
end

function GiftService:dispose()
end

-- Client向Game发送查询实物奖励请求
function GiftService:queryGoods(isJustData)
	local request = net.NetworkRequest.new(net.protocol.CGQueryGoodsREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService.getInstance():getRoleId())
	request.isJustData = isJustData  -- 作为回调保存
	game.util.RequestHelper.request(request)
end

-- RES
function GiftService:_onGCQueryGoodsRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local goodLists = protocol.goodsList
	local request = response:getRequest()
	-- 发起事件
	game.service.BackpackService.getInstance():dispatchEvent({name = "EVENT_BACKPACK_PRACTICAL", protocol = protocol});
end

-- Client向Game领取实物奖励请求
function GiftService:queryApplyGoods(roleId, goodUID, name, phone, address)
	local request = net.NetworkRequest.new(net.protocol.CGApplyGoodsREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(roleId, goodUID, name, phone, address);
	game.util.RequestHelper.request(request)
end

-- RES
function GiftService:_onGCApplyGoodsRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_APPLY_GOODS_FALSE then
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips("提交成功,请等待客服与您联系")
		-- 发起事件
        self:dispatchEvent({name = "EVENT_GCApplyGoodsRES"});
        
		UIManager:getInstance():destroy("UIGiftTextField")
	end
end

function GiftService:queryReceiveGift(id)
	local request = net.NetworkRequest.new(net.protocol.CGReceiveGiftREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(id);
	game.util.RequestHelper.request(request)
end

function GiftService:_onGCReceiveGiftRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_RECEIVE_GIFT_SUCCESS then
		UIManager:getInstance():show("UIGetGiftSuccess",protocol.exchange)
		if UIManager:getInstance():getIsShowing("UIBackpack") then
			game.service.BackpackService:getInstance():queryBackpack()
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 处理礼包
function GiftService:dealWithGiftPack()
	-- 礼包类型
    local GiftType = {
        NEWPLAYER = 1, -- 新手礼包
        REGRESS = 2,   -- 回归礼包
    }

	if next(self._giftInfo) ~= nil then
		if self._giftInfo.type == GiftType.NEWPLAYER then
			UIManager:getInstance():show("UIGiftNewPlayer",self._giftInfo.itemId)
		elseif self._giftInfo.type == GiftType.REGRESS then
			UIManager:getInstance():show("UIGiftRegress", self._giftInfo.itemId)		
		end
	end
	self._giftInfo = {}
end

function GiftService:setGiftInfo(info)
	self._giftInfo = info
end

function GiftService:dispose()
end

return GiftService 