local super = require("app.game.service.activity.ActivityServiceBase")
local ChristmasServiceActivity = class("ChristmasServiceActivity", super)
local CurrencyHelper = require("app.game.util.CurrencyHelper")

-- 设定礼包刷新的时间标志
function ChristmasServiceActivity:getTimeMark()
	local time = game.service.TimeService:getInstance():getCurrentTime()
	local date = os.date("*t", time)
	local dayMark = date.hour < 16 and 1 or 2
	return date.day .. "-" .. dayMark
end
-- 检查是否是礼包的时间
function ChristmasServiceActivity:checkTime()
	local time = game.service.TimeService:getInstance():getCurrentTime()
	local date = os.date("*t", time)
	local time1 = date.hour >= 12 and date.hour < 14
	local time2 = date.hour >= 18 and date.hour < 20
	--return time1 or time2
	return true
end

local PACKAGE_STATUS = {
	NEED_SHARE = 0,
	DISAPPEAR = 1,
}

function ChristmasServiceActivity:initialize()
    self._currentBlessId = nil
	self._signData = nil
	
	-- 红包信息
	self._packageInfo = {time = "", data = nil, packageMap = {}}
	
	local requestManager = net.RequestManager.getInstance()
	-- 圣诞活动
	requestManager:registerResponseHandler(net.protocol.ACCPrayInfoRES.OP_CODE, self, self._onACCPrayInfoRES)
	requestManager:registerResponseHandler(net.protocol.ACCPrayRES.OP_CODE, self, self._onACCPrayRES)
	
	requestManager:registerResponseHandler(net.protocol.ACCPraySignInfoRES.OP_CODE, self, self._onACCPraySignInfoRES)
	requestManager:registerResponseHandler(net.protocol.ACCPraySignRES.OP_CODE, self, self._onACCPraySignRES)
	
	requestManager:registerResponseHandler(net.protocol.ACCThrowRewardInfoRES.OP_CODE, self, self._onACCThrowRewardInfoRES)
	requestManager:registerResponseHandler(net.protocol.ACCThrowRewardOpenRES.OP_CODE, self, self._onACCThrowRewardOpenRES)
	requestManager:registerResponseHandler(net.protocol.ACCThrowRewardShareRES.OP_CODE, self, self._onACCThrowRewardShareRES)
	
	event.EventCenter:addEventListener("EVENT_LOGIN_OUT", function()
		self._currentBlessId = nil
		self._signData = nil
		-- 红包信息
		self._packageInfo = {time = "", data = nil, packageMap = {}}
	end, self)
end

function ChristmasServiceActivity:dispose()
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function ChristmasServiceActivity:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

function ChristmasServiceActivity:getBlessId()
	return self._currentBlessId
end

function ChristmasServiceActivity:getSignData()
	return self._signData
end

function ChristmasServiceActivity:getPackageInfo()
	return self._packageInfo
end

-- 尝试请求礼包数据,如果有且在时间内直接派发消息(在需要显示礼包的场景调用)
function ChristmasServiceActivity:queryPackageInfo(...)
	if self:_checkPackageInfo() then
		event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_PACKAGE_INFO"})
	end
end

-- 检查本地礼包数据,如果在时间外直接不管,时间内如果没有本地数据则请求
function ChristmasServiceActivity:_checkPackageInfo()
	if not self:checkTime() then
		return false
	end
	if self._packageInfo.time ~= self:getTimeMark() or self.data == nil then
		self:CACThrowRewardInfoREQ()
		return false
	end
	
	return true
end


-- 祈福活动信息请求
function ChristmasServiceActivity:CACPrayInfoREQ()
    net.NetworkRequest.new(net.protocol.CACPrayInfoREQ, self:getServerId()):execute()
end
-- 祈福活动信息应答
function ChristmasServiceActivity:_onACCPrayInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self._currentBlessId = protocol.itemId
		event.EventCenter:dispatchEvent({name = "EVENT_BLESSING_INFO_RECEIVE", protocol = protocol})
	end
end

-- 祈福请求
function ChristmasServiceActivity:CACPrayREQ(itemId)
    net.NetworkRequest.new(net.protocol.CACPrayREQ, self:getServerId()):setBuffer({
        itemId = itemId
    }):execute()
end
-- 祈福应答
function ChristmasServiceActivity:_onACCPrayRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self._currentBlessId = response:getRequest():getProtocol():getProtocolBuf().itemId
		event.EventCenter:dispatchEvent({name = "EVENT_BLESS_SUCCESS", protocol = protocol})
	end
end

-- 祈福签到活动信息请求
function ChristmasServiceActivity:CACPraySignInfoREQ()
	net.NetworkRequest.new(net.protocol.CACPraySignInfoREQ, self:getServerId()):execute()
end
-- 祈福签到活动信息回应
function ChristmasServiceActivity:_onACCPraySignInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self._signData = protocol
		event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_SING_INFO_RECEIVE"})
	end
end

-- 请求签到
function ChristmasServiceActivity:CACPraySignREQ()
	net.NetworkRequest.new(net.protocol.CACPraySignREQ, self:getServerId()):execute()
end
-- 签到回应
function ChristmasServiceActivity:_onACCPraySignRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self._signData.signCount = self._signData.signCount + 1
		self._signData.canSign = false
		event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_SING_RECEIVE_SUCCESS", itemData = self._signData.reward[self._signData.signCount]})
	end
end

-- 请求洒落礼包
function ChristmasServiceActivity:CACThrowRewardInfoREQ()
	net.NetworkRequest.new(net.protocol.CACThrowRewardInfoREQ, self:getServerId()):execute()
end
-- 回复洒落礼包
function ChristmasServiceActivity:_onACCThrowRewardInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:isSuccessful() then
		self._packageInfo.data = protocol
		self._packageInfo.time = self:getTimeMark()		
		
		-- 服务器为了方便未碰过的礼包不存在信息,这里手动整理一下方便使用
		self._packageInfo.packageMap = {
			{}, {}, {}
		}
		for k, v in ipairs(protocol.rewards) do
			self._packageInfo.packageMap[v.number] = v
		end
		
		event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_PACKAGE_INFO"})
	end

	local result = response:getBuffer().result
	if result == net.ProtocolCode.ACC_THROW_REWARD_OPEN_NO_ITEM then
		-- 房卡不足
		CurrencyHelper.getInstance():requestCharge(CurrencyHelper.CURRENCY_TYPE.CARD)
	end
end

-- 请求拆礼包
function ChristmasServiceActivity:CACThrowRewardOpenREQ(number, freeOpen)
	net.NetworkRequest.new(net.protocol.CACThrowRewardOpenREQ, self:getServerId()):setBuffer({
		number = number,
		freeOpen = freeOpen,
    }):execute()
end

-- 回复拆礼包
function ChristmasServiceActivity:_onACCThrowRewardOpenRES(response)
	local protocol = response:getProtocol():getProtocolBuf()   
	if response:isSuccessful() then
		local number = response:getRequest():getProtocol():getProtocolBuf().number
		self._packageInfo.data.freeOpen = protocol.freeOpen
		self._packageInfo.packageMap[number] = protocol.reward
		-- 直接领取的礼包和需要分享离去的礼包派发不同事件
		if protocol.reward.status == PACKAGE_STATUS.DISAPPEAR then
			event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_PACKAGE_GET", number = number})
		else
			event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_PACKAGE_OPEN", number = number})
		end
	elseif protocol.result == net.ProtocolCode.ACC_THROW_REWARD_OPEN_NO_ITEM then
		game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UIMALLMAIN_STRING_101, {"取消","确认"},
			function()
			end,
			function()
				CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
			end
			)                
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 洒落礼包分享
function ChristmasServiceActivity:CACThrowRewardShareREQ()
	net.NetworkRequest.new(net.protocol.CACThrowRewardShareREQ, self:getServerId()):execute()
end
-- 回复洒落礼包分享
function ChristmasServiceActivity:_onACCThrowRewardShareRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		local num = 0
		for k, v in ipairs(protocol.reward) do
			self._packageInfo.packageMap[v.number] = v
			num = num + v.count
		end
		
		event.EventCenter:dispatchEvent({name = "EVENT_CHRISTMAS_PACKAGE_SHARE_GET", num = num})
	end
end

return ChristmasServiceActivity