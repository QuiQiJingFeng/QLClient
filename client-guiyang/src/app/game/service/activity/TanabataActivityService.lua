local super = require("app.game.service.activity.ActivityServiceBase")
local TanabataActivityService = class("TanabataActivityService", super)

function TanabataActivityService:initialize()
    -- 二丁拐信息缓存
	self.erDingGuaiProgerss = nil
	self.erDingGuaiRewardRecord = nil

    local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.ACCMagpieWorldProgressRES.OP_CODE, self, self._onACCMagpieWorldProgressRES)
	requestManager:registerResponseHandler(net.protocol.ACCMagpieWorldWinnerListRES.OP_CODE, self, self._onACCMagpieWorldWinnerListRES)
	requestManager:registerResponseHandler(net.protocol.ACCMagpieWorldReceiveRewardRES.OP_CODE, self, self._onACCMagpieWorldReceiveRewardRES)
	requestManager:registerResponseHandler(net.protocol.ACCMagpieRechargeActivityRES.OP_CODE, self, self._onACCMagpieRechargeActivityRES)
	requestManager:registerResponseHandler(net.protocol.ACCMagpieRewardSYN.OP_CODE, self, self._onACCMagpieRewardSYN)
	requestManager:registerResponseHandler(net.protocol.ACCMagpiePrizeRecordRES.OP_CODE, self, self._onACCMagpiePrizeRecordRES)
end

function TanabataActivityService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function TanabataActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 七夕二丁拐完成进度
function TanabataActivityService:sendCACMagpieWorldProgressREQ()    
    net.NetworkRequest.new(net.protocol.CACMagpieWorldProgressREQ, self:getServerId()):execute()
end

function TanabataActivityService:_onACCMagpieWorldProgressRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self.erDingGuaiProgerss = protocol
		self:dispatchEvent({name = "EVENT_TWO_GAY_ACT_PROGRESS", protocol = protocol})
	end
end

-- 七夕二丁拐奖励名单
function TanabataActivityService:sendCACMagpieWorldWinnerListREQ()
    net.NetworkRequest.new(net.protocol.CACMagpieWorldWinnerListREQ, self:getServerId()):execute()
end

function TanabataActivityService:_onACCMagpieWorldWinnerListRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self:dispatchEvent({name = "EVENT_TWO_GAY_WIN_LIST", protocol = protocol})
	end
end

-- 领取进度奖励
function TanabataActivityService:sendCACMagpieWorldReceiveRewardREQ(progress)
    net.NetworkRequest.new(net.protocol.CACMagpieWorldReceiveRewardREQ, self:getServerId()):setBuffer({
        progress = progress
    }):execute()
end

function TanabataActivityService:_onACCMagpieWorldReceiveRewardRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local request = response:getRequest():getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self:dispatchEvent({name = "EVENT_RECEIVE_TWO_GAY_REWARD", rewardProgress = request.progress, protocol = protocol})
	end
end

-- 七夕充值活动请求
function TanabataActivityService:sendCACMagpieRechargeActivityREQ()
    net.NetworkRequest.new(net.protocol.CACMagpieRechargeActivityREQ, self:getServerId()):execute()
end

function TanabataActivityService:_onACCMagpieRechargeActivityRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		if protocol.hasBought then
			game.service.ActivityService:getInstance():removeActivityWithId(net.protocol.activityType.QIXI_CHARGE)
		end
		self:dispatchEvent({name = "EVENT_QTXI_CHARGEINFO", protocol = protocol})
	end
end
--购买成功通知
function TanabataActivityService:_onACCMagpieRewardSYN(response)
	game.service.ActivityService:getInstance():removeActivityWithId(net.protocol.activityType.QIXI_CHARGE)
	self:dispatchEvent({name = "EVENT_QIXI_CHARGE_SUCCESS"})
end

-- 二丁拐获奖记录请求
function TanabataActivityService:sendCACMagpiePrizeRecordREQ()
	net.NetworkRequest.new(net.protocol.CACMagpiePrizeRecordREQ, self:getServerId()):execute()
end
-- 二丁拐获奖记录返回
function TanabataActivityService:_onACCMagpiePrizeRecordRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self.erDingGuaiRewardRecord = protocol
		self:dispatchEvent({name = "EVENT_ER_DING_GUAI_REWARD_RECORD", protocol = protocol})
	end
end

function TanabataActivityService:checkToShowActPage()
	-- if self:isActivitieswithin(net.protocol.activityType.QIXI_CHARGE) then
	-- 	if not self.activeCache.qixiShowwed then
	-- 		self.activeCache.qixiShowwed = true
	-- 		UIManager.getInstance():show("UIQiXiCharge")
	-- 	end
	-- end
	-- local UIQiXiTwoGay = require("app.game.ui.activity.qixi.UIQiXiTwoGay")
	-- if(UIQiXiTwoGay.isInTwoGayUI or storageTools.AutoShowStorage.isNeedShow("UIQiXiTwoGay")) and self:isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY) then
	-- 	UIQiXiTwoGay.isInTwoGayUI = false
	-- 	UIManager.getInstance():show("UIQiXiTwoGay")
	-- end
	
	local UIShuang11 = require("app.game.ui.activity.shuang11.UIShuang11")
	if(UIShuang11.isInTwoGayUI or storageTools.AutoShowStorage.isNeedShow("UIShuang11")) and game.service.ActivityService:getInstance():isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY) then
		UIManager.getInstance():show("UIShuang11")
	end
end

return TanabataActivityService