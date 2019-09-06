local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

local buildMessage = ProtocolBase.getBuildMessageFunction("com.kodgames.message.proto.game")
local Code = net.ProtocolCode

ns.ItemType = {
	GOLD = 2
}

------------------------------------
-- 登录到游戏服务器,获取基本游戏数据
------------------------------------
local CGLoginREQ = class("CGLoginREQ", ProtocolBase)
ns.CGLoginREQ = CGLoginREQ

CGLoginREQ.OP_CODE = net.ProtocolCode.P_CG_LOGIN_REQ;
CGLoginREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGLoginREQ"

-- @param serverId: number
-- @param callback: number
function CGLoginREQ:ctor(serverId, callback)
	self.super.ctor(self, CGLoginREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
-- @param  sex: number
-- @param  nickname: string
-- @param  headImageUrl: string
-- @param  channel: string
-- @param username string 渠道用户名
-- @param unionid string 微信unionid
function CGLoginREQ:setData(roleId, sex, nickname, headImageUrl, channel, signature, area, developerId, unionId, username, channelId, type, phone, libVersion)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roleId = roleId;
	protocolBuf.sex = sex;
	protocolBuf.nickname = nickname;
	protocolBuf.headImageUrl = headImageUrl;
	protocolBuf.accountId = roleId;
	protocolBuf.channel = channel;
	protocolBuf.signature = signature;
	protocolBuf.appCode = tonumber(game.plugin.Runtime.getChannelId());
	protocolBuf.area = area;
	protocolBuf.developerId = developerId;
	protocolBuf.unionId = unionId;
	protocolBuf.username = username;
	protocolBuf.channelId = channelId;
	protocolBuf.type = type
	protocolBuf.phone = phone
	protocolBuf.libVersion = libVersion
end

------------------------------------
local GCLoginRES = class("GCLoginRES", ProtocolBase)
ns.GCLoginRES = GCLoginRES

GCLoginRES.OP_CODE = net.ProtocolCode.P_GC_LOGIN_RES;
GCLoginRES.CLZ_CODE = "com.kodgames.message.proto.game.GCLoginRES"

-- @param serverId: number
-- @param callback: number
function GCLoginRES:ctor(serverId, callback)
	self.super.ctor(self, GCLoginRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 登出
------------------------------------
local CGLogoutREQ = class("CGLogoutREQ", ProtocolBase)
ns.CGLogoutREQ = CGLogoutREQ

CGLogoutREQ.OP_CODE = net.ProtocolCode.P_CG_LOGOUT_REQ;
CGLogoutREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGLogoutREQ"

-- @param serverId: number
-- @param callback: number
function CGLogoutREQ:ctor(serverId, callback)
	self.super.ctor(self, CGLogoutREQ.OP_CODE, serverId, callback);
end

------------------------------------
local GCLogoutRES = class("GCLogoutRES", ProtocolBase)
ns.GCLogoutRES = GCLogoutRES

GCLogoutRES.OP_CODE = net.ProtocolCode.P_GC_LOGOUT_RES;
GCLogoutRES.CLZ_CODE = "com.kodgames.message.proto.game.GCLogoutRES"

-- @param serverId: number
-- @param callback: number
function GCLogoutRES:ctor(serverId, callback)
	self.super.ctor(self, GCLogoutRES.OP_CODE, serverId, callback);
end

----------------------------
-- 服务器主动断开
----------------------------
local GCKickoffSYNC = class("GCKickoffSYNC", ProtocolBase)
ns.GCKickoffSYNC = GCKickoffSYNC

GCKickoffSYNC.OP_CODE = net.ProtocolCode.P_GC_KICKOFF_SYNC;
GCKickoffSYNC.CLZ_CODE = "com.kodgames.message.proto.game.GCKickoffSYNC"

-- @param serverId: number
-- @param callback: number
function GCKickoffSYNC:ctor(serverId, callback)
	self.super.ctor(self, GCKickoffSYNC.OP_CODE, serverId, callback);
end

----------------------------
-- 请求联系代理商
----------------------------
local CGContactREQ = class("CGContactREQ", ProtocolBase)
ns.CGContactREQ = CGContactREQ

CGContactREQ.OP_CODE = net.ProtocolCode.P_CG_CONTACT_REQ;
CGContactREQ.CLZ_CODE = "com.kodgames.message.proto.contact.CGContactREQ"

-- @param serverId: number
-- @param callback: number
function CGContactREQ:ctor(serverId, callback)
	self.super.ctor(self, CGContactREQ.OP_CODE, serverId, callback);
end

----------------------------
-- 联系代理商返回
----------------------------
local GCContactRES = class("GCContactRES", ProtocolBase)
ns.GCContactRES = GCContactRES

GCContactRES.OP_CODE = net.ProtocolCode.P_GC_CONTACT_RES;
GCContactRES.CLZ_CODE = "com.kodgames.message.proto.contact.GCContactRES"

-- @param serverId: number
-- @param callback: number
function GCContactRES:ctor(serverId, callback)
	self.super.ctor(self, GCContactRES.OP_CODE, serverId, callback);
end

----------------------------
-- 房卡改变
----------------------------
local GCRoomCardModifySYNC = class("GCRoomCardModifySYNC", ProtocolBase)
ns.GCRoomCardModifySYNC = GCRoomCardModifySYNC

GCRoomCardModifySYNC.OP_CODE = net.ProtocolCode.P_GC_ROOMCARD_MODIFY_SYNC;
GCRoomCardModifySYNC.CLZ_CODE = "com.kodgames.message.proto.game.GCRoomCardModifySYNC"

-- @param serverId: number
-- @param callback: number
function GCRoomCardModifySYNC:ctor(serverId, callback)
	self.super.ctor(self, GCRoomCardModifySYNC.OP_CODE, serverId, callback);
end

----------------------------
local CGTimeSynchronizationREQ = class("CGTimeSynchronizationREQ", ProtocolBase)
ns.CGTimeSynchronizationREQ = CGTimeSynchronizationREQ

CGTimeSynchronizationREQ.OP_CODE = net.ProtocolCode.P_GC_TIME_SYNCHRONIZATION_REQ;
CGTimeSynchronizationREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGTimeSynchronizationREQ"

-- @param serverId: number
-- @param callback: number
function CGTimeSynchronizationREQ:ctor(serverId, callback)
	self.super.ctor(self, CGTimeSynchronizationREQ.OP_CODE, serverId, callback);
end

----------------------------
local GCTimeSynchronizationRES = class("GCTimeSynchronizationRES", ProtocolBase)
ns.GCTimeSynchronizationRES = GCTimeSynchronizationRES

GCTimeSynchronizationRES.OP_CODE = net.ProtocolCode.P_GC_TIME_SYNCHRONIZATION_RES;
GCTimeSynchronizationRES.CLZ_CODE = "com.kodgames.message.proto.game.GCTimeSynchronizationRES"

-- @param serverId: number
-- @param callback: number
function GCTimeSynchronizationRES:ctor(serverId, callback)
	self.super.ctor(self, GCTimeSynchronizationRES.OP_CODE, serverId, callback);
end

--客户端向服务器请求常驻公告栏
local CGQueryHomePageNoticeREQ = class("CGQueryHomePageNoticeREQ", ProtocolBase)
ns.CGQueryHomePageNoticeREQ = CGQueryHomePageNoticeREQ

CGQueryHomePageNoticeREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_HOME_PAGE_NOTICE_REQ;
CGQueryHomePageNoticeREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryHomePageNoticeREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryHomePageNoticeREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryHomePageNoticeREQ.OP_CODE, serverId, callback);
end

function CGQueryHomePageNoticeREQ:setData(areaId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.areaId = areaId;
end

--常驻公告栏请求结果返回
------------------------------------
local GCQueryHomePageNoticeRES = class("GCQueryHomePageNoticeRES", ProtocolBase)
ns.GCQueryHomePageNoticeRES = GCQueryHomePageNoticeRES

GCQueryHomePageNoticeRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_HOME_PAGE_NOTICE_RES
GCQueryHomePageNoticeRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryHomePageNoticeRES"

-- @param serverId: number
-- @param callback: number
function GCQueryHomePageNoticeRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryHomePageNoticeRES.OP_CODE, serverId, callback);
end

----------------------------
local GCAntiAddictionSYN = class("GCAntiAddictionSYN", ProtocolBase)
ns.GCAntiAddictionSYN = GCAntiAddictionSYN

GCAntiAddictionSYN.OP_CODE = net.ProtocolCode.P_GC_ANTI_ADDICTION_SYN;
GCAntiAddictionSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCAntiAddictionSYN"

-- @param serverId: number
-- @param callback: number
function GCAntiAddictionSYN:ctor(serverId, callback)
	self.super.ctor(self, GCAntiAddictionSYN.OP_CODE, serverId, callback);
end

----------------------------
local CGIdentityVerifyREQ = class("CGIdentityVerifyREQ", ProtocolBase)
ns.CGIdentityVerifyREQ = CGIdentityVerifyREQ

CGIdentityVerifyREQ.OP_CODE = net.ProtocolCode.P_CG_IDENTITYVERIFY_REQ;
CGIdentityVerifyREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGIdentityVerifyREQ"

-- @param serverId: number
-- @param callback: number
function CGIdentityVerifyREQ:ctor(serverId, callback)
	self.super.ctor(self, CGIdentityVerifyREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CGIdentityVerifyREQ:setData(roleId, name, identity)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.name = name
	protocolBuf.identity = identity
end

----------------------------
local GCIdentityVerifyRES = class("GCIdentityVerifyRES", ProtocolBase)
ns.GCIdentityVerifyRES = GCIdentityVerifyRES

GCIdentityVerifyRES.OP_CODE = net.ProtocolCode.P_GC_IDENTITYVERIFY_RES;
GCIdentityVerifyRES.CLZ_CODE = "com.kodgames.message.proto.game.GCIdentityVerifyRES"

-- @param serverId: number
-- @param callback: number
function GCIdentityVerifyRES:ctor(serverId, callback)
	self.super.ctor(self, GCIdentityVerifyRES.OP_CODE, serverId, callback);
end


----------------------------
local CGGetAgentInfoREQ = class("CGGetAgentInfoREQ", ProtocolBase)
ns.CGGetAgentInfoREQ = CGGetAgentInfoREQ

CGGetAgentInfoREQ.OP_CODE = net.ProtocolCode.P_CG_GETAGENTINFO_REQ
CGGetAgentInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGGetAgentInfoREQ"
-- @param serverId: number
-- @param callback: number
function CGGetAgentInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGGetAgentInfoREQ.OP_CODE, serverId, callback);
end

----------------------------
local GCGetAgentInfoRES = class("GCGetAgentInfoRES", ProtocolBase)
ns.GCGetAgentInfoRES = GCGetAgentInfoRES

GCGetAgentInfoRES.OP_CODE = net.ProtocolCode.P_GC_GETAGENTINFO_RES
GCGetAgentInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCGetAgentInfoRES"
-- @param serverId: number
-- @param callback: number
function GCGetAgentInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCGetAgentInfoRES.OP_CODE, serverId, callback);
end

----------------------------
local GCAgentStatusSYN = class("GCAgentStatusSYN", ProtocolBase)
ns.GCAgentStatusSYN = GCAgentStatusSYN

GCAgentStatusSYN.OP_CODE = net.ProtocolCode.P_GC_AGENT_STATUS_SYN
GCAgentStatusSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCAgentStatusSYN"
-- @param serverId: number
-- @param callback: number
function GCAgentStatusSYN:ctor(serverId, callback)
	self.super.ctor(self, GCAgentStatusSYN.OP_CODE, serverId, callback);
end

-- 新版支付相关
----------------------------
-- 购买类型
ns.PayType = {
	NORMAL = 0,			-- 正常内购
	QUICK_PAY = 1,		-- 快捷内购
	ACTIVITY_PAY = 2,	-- 活动首充
	GOLD_PAY = 3		-- 金币场特殊内购
}

local CGPayOrderREQ = class("CGPayOrderREQ", ProtocolBase)
ns.CGPayOrderREQ = CGPayOrderREQ

CGPayOrderREQ.OP_CODE = net.ProtocolCode.P_CG_PAY_ORDER_REQ
CGPayOrderREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGPayOrderREQ"

-- @param serverId: number
-- @param callback: number
function CGPayOrderREQ:ctor(serverId, callback)
	self.super.ctor(self, CGPayOrderREQ.OP_CODE, serverId, callback);
end

function CGPayOrderREQ:setData(roleId, payType, osType, rmb, itemId, deviceType, channelId, subChannelId, custom, goodId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.payType = payType
	protocolBuf.osType = osType
	protocolBuf.rmb = rmb
	protocolBuf.itemId = itemId
	protocolBuf.deviceType = deviceType
	protocolBuf.channelId = channelId
	protocolBuf.subChannelId = subChannelId
	protocolBuf.custom = custom
	protocolBuf.goodId = goodId
end

----------------------------
local GCPayOrderRES = class("GCPayOrderRES", ProtocolBase)
ns.GCPayOrderRES = GCPayOrderRES

GCPayOrderRES.OP_CODE = net.ProtocolCode.P_GC_PAY_ORDER_RES
GCPayOrderRES.CLZ_CODE = "com.kodgames.message.proto.game.GCPayOrderRES"

-- @param serverId: number
-- @param callback: number
function GCPayOrderRES:ctor(serverId, callback)
	self.super.ctor(self, GCPayOrderRES.OP_CODE, serverId, callback);
end

----------------------------
local CGPayVerifyREQ = class("CGPayVerifyREQ", ProtocolBase)
ns.CGPayVerifyREQ = CGPayVerifyREQ

CGPayVerifyREQ.OP_CODE = net.ProtocolCode.P_CG_PAY_VERIFY_REQ
CGPayVerifyREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGPayVerifyREQ"

-- @param serverId: number
-- @param callback: number
function CGPayVerifyREQ:ctor(serverId, callback)
	self.super.ctor(self, CGPayVerifyREQ.OP_CODE, serverId, callback);
end

function CGPayVerifyREQ:setData(orderId, roleId, transactionId, receipt)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.orderId = orderId
	protocolBuf.roleId = roleId
	protocolBuf.transactionId = transactionId
	protocolBuf.receipt = receipt
end

----------------------------
local GCPayVerifyRES = class("GCPayVerifyRES", ProtocolBase)
ns.GCPayVerifyRES = GCPayVerifyRES

GCPayVerifyRES.OP_CODE = net.ProtocolCode.P_GC_PAY_VERIFY_RES
GCPayVerifyRES.CLZ_CODE = "com.kodgames.message.proto.game.GCPayVerifyRES"

-- @param serverId: number
-- @param callback: number
function GCPayVerifyRES:ctor(serverId, callback)
	self.super.ctor(self, GCPayVerifyRES.OP_CODE, serverId, callback);
end

local CGAccountGpsSYN = class("CGAccountGpsSYN", ProtocolBase)
ns.CGAccountGpsSYN = CGAccountGpsSYN
-- 新版支付相关
----------------------------
local CGPayOrderREQ = class("CGPayOrderREQ", ProtocolBase)
ns.CGPayOrderREQ = CGPayOrderREQ

CGPayOrderREQ.OP_CODE = net.ProtocolCode.P_CG_PAY_ORDER_REQ
CGPayOrderREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGPayOrderREQ"

-- @param serverId: number
-- @param callback: number
function CGPayOrderREQ:ctor(serverId, callback)
	self.super.ctor(self, CGPayOrderREQ.OP_CODE, serverId, callback);
end

function CGPayOrderREQ:setData(roleId, payType, osType, rmb, goodId, deviceType, channelId, subChannelId, custom, itemId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.payType = payType
	protocolBuf.osType = osType
	protocolBuf.rmb = rmb
	protocolBuf.goodId = goodId
	protocolBuf.deviceType = deviceType
	protocolBuf.channelId = channelId
	protocolBuf.subChannelId = subChannelId
	protocolBuf.custom = custom
	protocolBuf.itemId = itemId
end

----------------------------
local GCPayOrderRES = class("GCPayOrderRES", ProtocolBase)
ns.GCPayOrderRES = GCPayOrderRES

GCPayOrderRES.OP_CODE = net.ProtocolCode.P_GC_PAY_ORDER_RES
GCPayOrderRES.CLZ_CODE = "com.kodgames.message.proto.game.GCPayOrderRES"

-- @param serverId: number
-- @param callback: number
function GCPayOrderRES:ctor(serverId, callback)
	self.super.ctor(self, GCPayOrderRES.OP_CODE, serverId, callback);
end

----------------------------
local CGPayVerifyREQ = class("CGPayVerifyREQ", ProtocolBase)
ns.CGPayVerifyREQ = CGPayVerifyREQ

CGPayVerifyREQ.OP_CODE = net.ProtocolCode.P_CG_PAY_VERIFY_REQ
CGPayVerifyREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGPayVerifyREQ"

-- @param serverId: number
-- @param callback: number
function CGPayVerifyREQ:ctor(serverId, callback)
	self.super.ctor(self, CGPayVerifyREQ.OP_CODE, serverId, callback);
end

function CGPayVerifyREQ:setData(orderId, roleId, transactionId, receipt)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.orderId = orderId
	protocolBuf.roleId = roleId
	protocolBuf.transactionId = transactionId
	protocolBuf.receipt = receipt
end

----------------------------
local GCPayVerifyRES = class("GCPayVerifyRES", ProtocolBase)
ns.GCPayVerifyRES = GCPayVerifyRES

GCPayVerifyRES.OP_CODE = net.ProtocolCode.P_GC_PAY_VERIFY_RES
GCPayVerifyRES.CLZ_CODE = "com.kodgames.message.proto.game.GCPayVerifyRES"

-- @param serverId: number
-- @param callback: number
function GCPayVerifyRES:ctor(serverId, callback)
	self.super.ctor(self, GCPayVerifyRES.OP_CODE, serverId, callback);
end

-------------------------------------------
-- 向服务器发送玩家GPS信息
local CGAccountGpsREQ = class("CGAccountGpsREQ", ProtocolBase)
ns.CGAccountGpsREQ = CGAccountGpsREQ

CGAccountGpsREQ.OP_CODE = net.ProtocolCode.P_CG_ACCOUNT_GPS_REQ
CGAccountGpsREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGAccountGpsREQ"
-- @param serverId: number
-- @param callback: number
function CGAccountGpsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGAccountGpsREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number		玩家ID
-- @param province:	string		省份
--@param city:string			城市
-- @param district: string		县区
function CGAccountGpsREQ:setData(roleId, province, city, district)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.province = province
	protocolBuf.city = city
	protocolBuf.district = district
end

--[[	积分商城 开始
]]
--  请求打开
local CGMallREQ = class("CGMallREQ", ProtocolBase)
ns.CGMallREQ = CGMallREQ
CGMallREQ.OP_CODE = net.ProtocolCode.P_CG_MALL_REQ
CGMallREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGMallREQ"
function CGMallREQ:ctor(serverId, callback)
	self.super.ctor(self, CGMallREQ.OP_CODE, serverId, callback)
end

-- 打开响应
local GCMallRES = class("GCMallRES", ProtocolBase)
ns.GCMallRES = GCMallRES
GCMallRES.OP_CODE = net.ProtocolCode.P_GC_MALL_RES
GCMallRES.CLZ_CODE = "com.kodgames.message.proto.game.GCMallRES"
function GCMallRES:ctor(serverId, callback)
	self.super.ctor(self, GCMallRES.OP_CODE, serverId, callback)
end

-- 请求账单
local CGMallBillREQ = class("CGMallBillREQ", ProtocolBase)
ns.CGMallBillREQ = CGMallBillREQ
CGMallBillREQ.OP_CODE = net.ProtocolCode.P_CG_MALL_BILL_REQ
CGMallBillREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGMallBillREQ"
function CGMallBillREQ:ctor(serverId, callback)
	self.super.ctor(self, CGMallBillREQ.OP_CODE, serverId, callback)
end

-- 账单响应
local GCMallBillRES = class("GCMallBillRES", ProtocolBase)
ns.GCMallBillRES = GCMallBillRES
GCMallBillRES.OP_CODE = net.ProtocolCode.P_GC_MALL_BILL_RES
GCMallBillRES.CLZ_CODE = "com.kodgames.message.proto.game.GCMallBillRES"
function GCMallBillRES:ctor(serverId, callback)
	self.super.ctor(self, GCMallBillRES.OP_CODE, serverId, callback)
end

-- 请求购买
local CGQueryExchangeREQ = class("CGQueryExchangeREQ", ProtocolBase)
ns.CGQueryExchangeREQ = CGQueryExchangeREQ
CGQueryExchangeREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_EXCHANGE_REQ
CGQueryExchangeREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryExchangeREQ"
function CGQueryExchangeREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryExchangeREQ.OP_CODE, serverId, callback)
end

function CGQueryExchangeREQ:setData(goodId, phoneNumber, address, name, time)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.goodId = goodId
	protocolBuf.phoneNumber = phoneNumber
	protocolBuf.address = address
	protocolBuf.addressee = name
	protocolBuf.time = time
end

-- 购买响应
local GCQueryExchangeRES = class("GCQueryExchangeRES", ProtocolBase)
ns.GCQueryExchangeRES = GCQueryExchangeRES
GCQueryExchangeRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_EXCHANGE_RES
GCQueryExchangeRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryExchangeRES"
function GCQueryExchangeRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryExchangeRES.OP_CODE, serverId, callback)
end

-- 同步信息
local GCRefreshGoodsSYN = class("GCRefreshGoodsSYN", ProtocolBase)
ns.GCRefreshGoodsSYN = GCRefreshGoodsSYN
GCRefreshGoodsSYN.OP_CODE = net.ProtocolCode.P_GC_REFRESH_GOODS_SYN
GCRefreshGoodsSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCRefreshGoodsSYN"
function GCRefreshGoodsSYN:ctor(serverId, callback)
	self.super.ctor(self, GCRefreshGoodsSYN.OP_CODE, serverId, callback)
end

local GCAccountGpsRES = class("GCAccountGpsRES", ProtocolBase)
ns.GCAccountGpsRES = GCAccountGpsRES

GCAccountGpsRES.OP_CODE = net.ProtocolCode.P_GC_ACCOUNT_GPS_RES
GCAccountGpsRES.CLZ_CODE = "com.kodgames.message.proto.game.GCAccountGpsRES"

-- @param serverId: number
-- @param callback: number
function GCAccountGpsRES:ctor(serverId, callback)
	self.super.ctor(self, GCAccountGpsRES.OP_CODE, serverId, callback);
end




-- game向Client发送可选择的地区
----------------------------
local GCSelectAreaREQ = class("GCSelectAreaREQ", ProtocolBase)
ns.GCSelectAreaREQ = GCSelectAreaREQ

GCSelectAreaREQ.OP_CODE = net.ProtocolCode.P_GC_SERVERAREA_SELECT_REQ
GCSelectAreaREQ.CLZ_CODE = "com.kodgames.message.proto.game.GCSelectAreaREQ"

-- @param serverId: number
-- @param callback: number
function GCSelectAreaREQ:ctor(serverId, callback)
	self.super.ctor(self, GCSelectAreaREQ.OP_CODE, serverId, callback);
end


-- Client向Game发送首次登录时的选择地
----------------------------
local CGSelectAreaREQ = class("CGSelectAreaREQ", ProtocolBase)
ns.CGSelectAreaREQ = CGSelectAreaREQ

CGSelectAreaREQ.OP_CODE = net.ProtocolCode.P_CG_SELECT_AREA_REQ
CGSelectAreaREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGSelectAreaREQ"

-- @param serverId: number
-- @param callback: number
function CGSelectAreaREQ:ctor(serverId, callback)
	self.super.ctor(self, CGSelectAreaREQ.OP_CODE, serverId, callback);
end

-- @param area: number
function CGSelectAreaREQ:setData(area, appCode, username)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.area = area
	protocolBuf.appCode = appCode
	protocolBuf.username = username
end


-- 选择完毕后服务器回复
----------------------------
local GCSelectAreaRES = class("GCSelectAreaRES", ProtocolBase)
ns.GCSelectAreaRES = GCSelectAreaRES

GCSelectAreaRES.OP_CODE = net.ProtocolCode.P_GC_SELECT_AREA_RES
GCSelectAreaRES.CLZ_CODE = "com.kodgames.message.proto.game.GCSelectAreaRES"

-- @param serverId: number
-- @param callback: number
function GCSelectAreaRES:ctor(serverId, callback)
	self.super.ctor(self, GCSelectAreaRES.OP_CODE, serverId, callback);
end

-- Client向Game请求地区列表
----------------------------
local CGAreaListREQ = class("CGAreaListREQ", ProtocolBase)
ns.CGAreaListREQ = CGAreaListREQ

CGAreaListREQ.OP_CODE = net.ProtocolCode.P_CG_AREA_LIST_REQ
CGAreaListREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGAreaListREQ"

-- @param serverId: number
-- @param callback: number
function CGAreaListREQ:ctor(serverId, callback)
	self.super.ctor(self, CGAreaListREQ.OP_CODE, serverId, callback);
end

-- 服务器回复服务器列表
----------------------------
local GCAreaListRES = class("GCAreaListRES", ProtocolBase)
ns.GCAreaListRES = GCAreaListRES

GCAreaListRES.OP_CODE = net.ProtocolCode.P_GC_AREA_LIST_REQ
GCAreaListRES.CLZ_CODE = "com.kodgames.message.proto.game.GCAreaListRES"

-- @param serverId: number
-- @param callback: number
function GCAreaListRES:ctor(serverId, callback)
	self.super.ctor(self, GCAreaListRES.OP_CODE, serverId, callback);
end

-- 实物奖励相关协议
-----------------------------
-- client 向 game 发送查询实物奖励请求
local CGQueryGoodsREQ = class("CGQueryGoodsREQ", ProtocolBase)
ns.CGQueryGoodsREQ = CGQueryGoodsREQ

CGQueryGoodsREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_GOODS_REQ
CGQueryGoodsREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryGoodsREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryGoodsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryGoodsREQ.OP_CODE, serverId, callback);
end

-- @param area: number
function CGQueryGoodsREQ:setData(roleId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
end

-- game 向 client 发送查询实物奖励返回
----------------------------
local GCQueryGoodsRES = class("GCQueryGoodsRES", ProtocolBase)
ns.GCQueryGoodsRES = GCQueryGoodsRES

GCQueryGoodsRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_GOODS_RES
GCQueryGoodsRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryGoodsRES"

-- @param serverId: number
-- @param callback: number
function GCQueryGoodsRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryGoodsRES.OP_CODE, serverId, callback);
end

-- 玩家申请实物奖励
local CGApplyGoodsREQ = class("CGApplyGoodsREQ", ProtocolBase)
ns.CGApplyGoodsREQ = CGApplyGoodsREQ

CGApplyGoodsREQ.OP_CODE = net.ProtocolCode.P_CG_APPLY_GOODS_REQ
CGApplyGoodsREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGApplyGoodsREQ"

function CGApplyGoodsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGApplyGoodsREQ.OP_CODE, serverId, callback)
end

-- @param campaignId: number
function CGApplyGoodsREQ:setData(roleId, goodUID, name, phone, address)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roleId = roleId;
	protocolBuf.goodUID = goodUID;
	protocolBuf.name = name;
	protocolBuf.phone = phone;
	protocolBuf.address = address;
end

-- 玩家申请实物奖励RES
local GCApplyGoodsRES = class("GCApplyGoodsRES", ProtocolBase)
ns.GCApplyGoodsRES = GCApplyGoodsRES

GCApplyGoodsRES.OP_CODE = net.ProtocolCode.P_GC_APPLY_GOODS_RES
GCApplyGoodsRES.CLZ_CODE = "com.kodgames.message.proto.game.GCApplyGoodsRES"

function GCApplyGoodsRES:ctor(serverId, callback)
	self.super.ctor(self, GCApplyGoodsRES.OP_CODE, serverId, callback)
end

----------------------------
-- 服务器同步
----------------------------
local GCTicketModifySYNC = class("GCTicketModifySYNC", ProtocolBase)
ns.GCTicketModifySYNC = GCTicketModifySYNC

GCTicketModifySYNC.OP_CODE = net.ProtocolCode.P_GC_TICKET_MODIFY_SYN;
GCTicketModifySYNC.CLZ_CODE = "com.kodgames.message.proto.game.GCTicketModifySYNC"

-- @param serverId: number
-- @param callback: number
function GCTicketModifySYNC:ctor(serverId, callback)
	self.super.ctor(self, GCTicketModifySYNC.OP_CODE, serverId, callback);
end

----------------------------
-- 服务器同步红点相关信息
----------------------------
local GCNotifyRedDotSYNC = class("GCNotifyRedDotSYNC", ProtocolBase)
ns.GCNotifyRedDotSYNC = GCNotifyRedDotSYNC

GCNotifyRedDotSYNC.OP_CODE = net.ProtocolCode.P_GC_NOTIFY_RED_DOT_SYN
GCNotifyRedDotSYNC.CLZ_CODE = "com.kodgames.message.proto.game.GCNotifyRedDotSYNC"

-- @param serverId: number
-- @param callback: number
function GCNotifyRedDotSYNC:ctor(serverId, callback)
	self.super.ctor(self, GCNotifyRedDotSYNC.OP_CODE, serverId, callback);
end

----------------------------
-- 请求邮件信息
----------------------------
local MailStatus = {
	READ = 0,
	UNREAD = 1,
	DELETE = 2,
	RECEIVED = 3
}
local NMDotType = {
	MAIL = 1,
	ANNOUNCEMENT = 2,
	ACTIVITY = 3,
	LOTTERY = 4,
	FRIEND = 5,
}
-- 跳转类型
local ActivityTarget = {
	NONE = 0,
	CLUB = 1,
	CAMPAIGN = 2,
	GOLD = 3,
	CAMPAIGN_1 = 4,
	CAMPAIGN_2 = 5,
	CAMPAIGN_3 = 6,
}
ns.MailStatus = MailStatus
ns.NMDotType = NMDotType
ns.ActivityTarget = ActivityTarget
local CGQueryMailREQ = class("CGQueryMailREQ", ProtocolBase)
ns.CGQueryMailREQ = CGQueryMailREQ

CGQueryMailREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_MAIL_REQ
CGQueryMailREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryMailREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryMailREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryMailREQ.OP_CODE, serverId, callback);
end

----------------------------
-- 邮件信息回应
----------------------------
local GCQueryMailRES = class("GCQueryMailRES", ProtocolBase)
ns.GCQueryMailRES = GCQueryMailRES

GCQueryMailRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_MAIL_RES
GCQueryMailRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryMailRES"

-- @param serverId: number
-- @param callback: number
function GCQueryMailRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryMailRES.OP_CODE, serverId, callback);
end

----------------------------
-- 邮件已读回执
----------------------------
local CGChangeMailREQ = class("CGChangeMailREQ", ProtocolBase)
ns.CGChangeMailREQ = CGChangeMailREQ

CGChangeMailREQ.OP_CODE = net.ProtocolCode.P_CG_CHANGE_MAIL_REQ
CGChangeMailREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGChangeMailREQ"

-- @param serverId: number
-- @param callback: number
function CGChangeMailREQ:ctor(serverId, callback)
	self.super.ctor(self, CGChangeMailREQ.OP_CODE, serverId, callback);
end

function CGChangeMailREQ:setData(id, operate)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.id = id
	protocolBuf.operate = operate
end
----------------------------
-- 邮件已读服务器返回
----------------------------
local GCChangeMailRES = class("GCChangeMailRES", ProtocolBase)
ns.GCChangeMailRES = GCChangeMailRES

GCChangeMailRES.OP_CODE = net.ProtocolCode.P_GC_CHANGE_MAIL_RES
GCChangeMailRES.CLZ_CODE = "com.kodgames.message.proto.game.GCChangeMailRES"

-- @param serverId: number
-- @param callback: number
function GCChangeMailRES:ctor(serverId, callback)
	self.super.ctor(self, GCChangeMailRES.OP_CODE, serverId, callback);
end


----------------------------
-- 删除所有已读邮件
----------------------------
local CGDeleteReadMailsREQ = class("CGDeleteReadMailsREQ", ProtocolBase)
ns.CGDeleteReadMailsREQ = CGDeleteReadMailsREQ

CGDeleteReadMailsREQ.OP_CODE = net.ProtocolCode.P_CG_DELETE_READ_MAILS_REQ
CGDeleteReadMailsREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGDeleteReadMailsREQ"

-- @param serverId: number
-- @param callback: number
function CGDeleteReadMailsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGDeleteReadMailsREQ.OP_CODE, serverId, callback);
end

----------------------------
-- 删除所有已读邮件返回
----------------------------
local GCDeleteReadMailsRES = class("GCDeleteReadMailsRES", ProtocolBase)
ns.GCDeleteReadMailsRES = GCDeleteReadMailsRES

GCDeleteReadMailsRES.OP_CODE = net.ProtocolCode.P_GC_DELETE_READ_MAILS_RES
GCDeleteReadMailsRES.CLZ_CODE = "com.kodgames.message.proto.game.GCDeleteReadMailsRES"

-- @param serverId: number
-- @param callback: number
function GCDeleteReadMailsRES:ctor(serverId, callback)
	self.super.ctor(self, GCDeleteReadMailsRES.OP_CODE, serverId, callback);
end

----------------------------
-- 公告数据请求
----------------------------
local CGQueryAnnouncementREQ = class("CGQueryAnnouncementREQ", ProtocolBase)
ns.CGQueryAnnouncementREQ = CGQueryAnnouncementREQ

CGQueryAnnouncementREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_ANNOUNCEMENT_REQ
CGQueryAnnouncementREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryAnnouncementREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryAnnouncementREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryAnnouncementREQ.OP_CODE, serverId, callback);
end

----------------------------
-- 公告数据请求返回
----------------------------
local GCQueryAnnouncementRES = class("GCQueryAnnouncementRES", ProtocolBase)
ns.GCQueryAnnouncementRES = GCQueryAnnouncementRES

GCQueryAnnouncementRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_ANNOUNCEMENT_RES
GCQueryAnnouncementRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryAnnouncementRES"

-- @param serverId: number
-- @param callback: number
function GCQueryAnnouncementRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryAnnouncementRES.OP_CODE, serverId, callback);
end

-- Game向Client回复活动弹板
----------------------------
local GCQueryActivityRES = class("GCQueryActivityRES", ProtocolBase)
ns.GCQueryActivityRES = GCQueryActivityRES

GCQueryActivityRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_ACTIVITY_RES
GCQueryActivityRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryActivityRES"

-- @param serverId: number
-- @param callback: number
function GCQueryActivityRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryActivityRES.OP_CODE, serverId, callback);
end

-- REQ
local CGQueryActivityREQ = class("CGQueryActivityREQ", ProtocolBase)
ns.CGQueryActivityREQ = CGQueryActivityREQ

CGQueryActivityREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_ACTIVITY_REQ
CGQueryActivityREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryActivityREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryActivityREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryActivityREQ.OP_CODE, serverId, callback);
end

-- 活动Notice
-- Client向Game发送活动已读
----------------------------
local CGReadActivityREQ = class("CGReadActivityREQ", ProtocolBase)
ns.CGReadActivityREQ = CGReadActivityREQ

CGReadActivityREQ.OP_CODE = net.ProtocolCode.P_CG_READ_ACTIVITY_REQ
CGReadActivityREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGReadActivityREQ"

-- @param serverId: number
-- @param callback: number
function CGReadActivityREQ:ctor(serverId, callback)
	self.super.ctor(self, CGReadActivityREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CGReadActivityREQ:setData(id)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.id = id;
end
----------------------------
local GCReadActivityRES = class("GCReadActivityRES", ProtocolBase)
ns.GCReadActivityRES = GCReadActivityRES

GCReadActivityRES.OP_CODE = net.ProtocolCode.P_GC_READ_ACTIVITY_RES
GCReadActivityRES.CLZ_CODE = "com.kodgames.message.proto.game.GCReadActivityRES"

-- @param serverId: number
-- @param callback: number
function GCReadActivityRES:ctor(serverId, callback)
	self.super.ctor(self, GCReadActivityRES.OP_CODE, serverId, callback);
end


-- 客户端请求agt地址
local CGGetAgtWebUrlREQ = class("CGGetAgtWebUrlREQ", ProtocolBase)
ns.CGGetAgtWebUrlREQ = CGGetAgtWebUrlREQ

CGGetAgtWebUrlREQ.OP_CODE = net.ProtocolCode.P_CG_GET_AGT_WEB_URL_REQ;
CGGetAgtWebUrlREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGGetAgtWebUrlREQ"

-- @param serverId: number
-- @param callback: number
function CGGetAgtWebUrlREQ:ctor(serverId, callback)
	self.super.ctor(self, CGGetAgtWebUrlREQ.OP_CODE, serverId, callback);
end

function CGGetAgtWebUrlREQ:setData()
end

-- message GCGetAgtWebUrlRES
-- {
--     required int32 result = 1;      // 返回结果
--     required string url = 2;        // 地址，形如：http://1.1.1.1:1
-- }
local GCGetAgtWebUrlRES = class("GCGetAgtWebUrlRES", ProtocolBase)
ns.GCGetAgtWebUrlRES = GCGetAgtWebUrlRES

GCGetAgtWebUrlRES.OP_CODE = net.ProtocolCode.P_GC_GET_AGT_WEB_URL_RES
GCGetAgtWebUrlRES.CLZ_CODE = "com.kodgames.message.proto.game.GCGetAgtWebUrlRES"

function GCGetAgtWebUrlRES:ctor(serverId, callback)
	self.super.ctor(self, GCGetAgtWebUrlRES.OP_CODE, serverId, callback)
end

---------------------------------------------------------------------------------------
--查询转盘信息
local CGQueryTurntableInfoREQ = class("CGQueryTurntableInfoREQ", ProtocolBase)
ns.CGQueryTurntableInfoREQ = CGQueryTurntableInfoREQ

CGQueryTurntableInfoREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_TURNTABLE_INFO_REQ
CGQueryTurntableInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryTurntableInfoREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryTurntableInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryTurntableInfoREQ.OP_CODE, serverId, callback);
end
---------------------------------------------------------------------------
--回复查询转盘信息
local GCQueryTurntableInfoRES = class("GCQueryTurntableInfoRES", ProtocolBase)
ns.GCQueryTurntableInfoRES = GCQueryTurntableInfoRES

GCQueryTurntableInfoRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_TURNTABLE_INFO_RES
GCQueryTurntableInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryTurntableInfoRES"

-- @param serverId: number
-- @param callback: number
function GCQueryTurntableInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryTurntableInfoRES.OP_CODE, serverId, callback);
end
---------------------------------------------------------------------------
--转盘抽奖
local CGTurntableDrawREQ = class("CGTurntableDrawREQ", ProtocolBase)
ns.CGTurntableDrawREQ = CGTurntableDrawREQ

CGTurntableDrawREQ.OP_CODE = net.ProtocolCode.P_CG_TURNTABLE_DRAW_REQ
CGTurntableDrawREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGTurntableDrawREQ"

-- @param serverId: number
-- @param callback: number
function CGTurntableDrawREQ:ctor(serverId, callback)
	self.super.ctor(self, CGTurntableDrawREQ.OP_CODE, serverId, callback);
end
---------------------------------------------------------------------------
--回复转盘抽奖
local GCTurntableDrawRES = class("GCTurntableDrawRES", ProtocolBase)
ns.GCTurntableDrawRES = GCTurntableDrawRES

GCTurntableDrawRES.OP_CODE = net.ProtocolCode.P_GC_TURNTABLE_DRAW_RES
GCTurntableDrawRES.CLZ_CODE = "com.kodgames.message.proto.game.GCTurntableDrawRES"

-- @param serverId: number
-- @param callback: number
function GCTurntableDrawRES:ctor(serverId, callback)
	self.super.ctor(self, GCTurntableDrawRES.OP_CODE, serverId, callback);
end
---------------------------------------------------------------------------
--转盘奖励分享
local CGShareTurntableRewardREQ = class("CGShareTurntableRewardREQ", ProtocolBase)
ns.CGShareTurntableRewardREQ = CGShareTurntableRewardREQ

CGShareTurntableRewardREQ.OP_CODE = net.ProtocolCode.P_CG_SHARE_TURNTABLE_REWARD_REQ
CGShareTurntableRewardREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGShareTurntableRewardREQ"

-- @param serverId: number
-- @param callback: number
function CGShareTurntableRewardREQ:ctor(serverId, callback)
	self.super.ctor(self, CGShareTurntableRewardREQ.OP_CODE, serverId, callback);
end
---------------------------------------------------------------------------
--回复转盘奖励分享
local CGShareTurntableRewardRES = class("CGShareTurntableRewardRES", ProtocolBase)
ns.CGShareTurntableRewardRES = CGShareTurntableRewardRES

CGShareTurntableRewardRES.OP_CODE = net.ProtocolCode.P_GC_SHARE_TURNTABLE_REWARD_RES
CGShareTurntableRewardRES.CLZ_CODE = "com.kodgames.message.proto.game.CGShareTurntableRewardRES"

-- @param serverId: number
-- @param callback: number
function CGShareTurntableRewardRES:ctor(serverId, callback)
	self.super.ctor(self, CGShareTurntableRewardRES.OP_CODE, serverId, callback);
end
---------------------------------------------------------------------------
local GCPlayerHasItemCountSYN = class("GCPlayerHasItemCountSYN", ProtocolBase)
ns.GCPlayerHasItemCountSYN = GCPlayerHasItemCountSYN

GCPlayerHasItemCountSYN.OP_CODE = net.ProtocolCode.P_GC_PLAYER_HAS_ITEM_COUNT_SYN
GCPlayerHasItemCountSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCPlayerHasItemCountSYN"

-- @param serverId: number
-- @param callback: number
function GCPlayerHasItemCountSYN:ctor(serverId, callback)
	self.super.ctor(self, GCPlayerHasItemCountSYN.OP_CODE, serverId, callback);
end

---------------------------------------------------------------------------
--上传玩家可以接收的推送类型
local CGUploadRolePushTypeREQ = class("CGUploadRolePushTypeREQ", ProtocolBase)
ns.CGUploadRolePushTypeREQ = CGUploadRolePushTypeREQ

CGUploadRolePushTypeREQ.OP_CODE = net.ProtocolCode.P_CG_UPLOAD_ROLE_PUSHTYPE_REQ
CGUploadRolePushTypeREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGUploadRolePushTypeREQ"

-- @param serverId: number
-- @param callback: number
function CGUploadRolePushTypeREQ:ctor(serverId, callback)
	self.super.ctor(self, CGUploadRolePushTypeREQ.OP_CODE, serverId, callback);
end

function CGUploadRolePushTypeREQ:setData(roleId, pushType)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roleId = roleId;
	protocolBuf.pushType = pushType;
end
---------------------------------------------------------------------------
-- 上传玩家可以接收的推送类型
local GCUploadRolePushTypeRES = class("GCUploadRolePushTypeRES", ProtocolBase)
ns.GCUploadRolePushTypeRES = GCUploadRolePushTypeRES

GCUploadRolePushTypeRES.OP_CODE = net.ProtocolCode.P_GC_UPLOAD_ROLE_PUSHTYPE_RES
GCUploadRolePushTypeRES.CLZ_CODE = "com.kodgames.message.proto.game.GCUploadPushInfoRES"

-- @param serverId: number
-- @param callback: number
function GCUploadRolePushTypeRES:ctor(serverId, callback)
	self.super.ctor(self, GCUploadRolePushTypeRES.OP_CODE, serverId, callback);
end



--上传客户端的推送id
local CGUploadPushInfoREQ = class("CGUploadPushInfoREQ", ProtocolBase)
ns.CGUploadPushInfoREQ = CGUploadPushInfoREQ

CGUploadPushInfoREQ.OP_CODE = net.ProtocolCode.P_CG_UPLOAD_PUSHINFO_REQ
CGUploadPushInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGUploadPushInfoREQ"

-- @param serverId: number
-- @param callback: number
function CGUploadPushInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGUploadPushInfoREQ.OP_CODE, serverId, callback);
end

function CGUploadPushInfoREQ:setData(roleId, channelId, pushRegisterId, getuiId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roleId = roleId;
	protocolBuf.channelId = channelId;
	protocolBuf.pushRegisterId = pushRegisterId;
	protocolBuf.pushClientId = getuiId;
end
---------------------------------------------------------------------------
--上传客户端的推送id
local GCUploadPushInfoRES = class("GCUploadPushInfoRES", ProtocolBase)
ns.GCUploadPushInfoRES = GCUploadPushInfoRES

GCUploadPushInfoRES.OP_CODE = net.ProtocolCode.P_GC_UPLOAD_PUSHINFO_RES
GCUploadPushInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCUploadPushInfoRES"

-- @param serverId: number
-- @param callback: number
function GCUploadPushInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCUploadPushInfoRES.OP_CODE, serverId, callback);
end

-- ---------------------------------------------------------------------------
-- -- 请求接受邮件附件
local CGReceiveItemREQ = class("CGReceiveItemREQ", ProtocolBase)
ns.CGReceiveItemREQ = CGReceiveItemREQ

CGReceiveItemREQ.OP_CODE = net.ProtocolCode.P_CG_RECEIVE_ITEM_REQ
CGReceiveItemREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGReceiveItemREQ"

-- @param serverId: number
-- @param callback: number
function CGReceiveItemREQ:ctor(serverId, callback)
	self.super.ctor(self, CGReceiveItemREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CGReceiveItemREQ:setData(id)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.id = id;
end

-- ---------------------------------------------------------------------------
-- -- 请求接受邮件附件返回
local GCReceiveItemRES = class("GCReceiveItemRES", ProtocolBase)
ns.GCReceiveItemRES = GCReceiveItemRES

GCReceiveItemRES.OP_CODE = net.ProtocolCode.P_GC_RECEIVE_ITEM_RES
GCReceiveItemRES.CLZ_CODE = "com.kodgames.message.proto.game.GCReceiveItemRES"

-- @param serverId: number
-- @param callback: number
function GCReceiveItemRES:ctor(serverId, callback)
	self.super.ctor(self, GCReceiveItemRES.OP_CODE, serverId, callback);
end

-- ---------------------------------------------------------------------------
-- -- 请求背包
local CGQueryRoleItemsREQ = class("CGQueryRoleItemsREQ", ProtocolBase)
ns.CGQueryRoleItemsREQ = CGQueryRoleItemsREQ

CGQueryRoleItemsREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_ROLE_ITEMS_REQ
CGQueryRoleItemsREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryRoleItemsREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryRoleItemsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryRoleItemsREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CGQueryRoleItemsREQ:setData(id)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.id = id;
end

-- -- 请求背包返回
local GCQueryRoleItemsRES = class("GCQueryRoleItemsRES", ProtocolBase)
ns.GCQueryRoleItemsRES = GCQueryRoleItemsRES

GCQueryRoleItemsRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_ROLE_ITEMS_RES
GCQueryRoleItemsRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryRoleItemsRES"

-- @param serverId: number
-- @param callback: number
function GCQueryRoleItemsRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryRoleItemsRES.OP_CODE, serverId, callback);
end

-- 请求Agt弹窗信息
local CGQueryAgtInfoREQ = class("CGQueryAgtInfoREQ", ProtocolBase)
ns.CGQueryAgtInfoREQ = CGQueryAgtInfoREQ

CGQueryAgtInfoREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_AGT_INFO_REQ
CGQueryAgtInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryAgtInfoREQ"

function CGQueryAgtInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryAgtInfoREQ.OP_CODE, serverId, callback);
end

function CGQueryAgtInfoREQ:setData(area)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area;
end

local GCQueryAgtInfoRES = class("GCQueryAgtInfoRES", ProtocolBase)
ns.GCQueryAgtInfoRES = GCQueryAgtInfoRES

GCQueryAgtInfoRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_AGT_INFO_RES
GCQueryAgtInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryAgtInfoRES"

-- @param serverId: number
-- @param callback: number
function GCQueryAgtInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryAgtInfoRES.OP_CODE, serverId, callback);
end

------------
local GCNotifyItemsChangeSYN = class("GCNotifyItemsChangeSYN", ProtocolBase)
ns.GCNotifyItemsChangeSYN = GCNotifyItemsChangeSYN

GCNotifyItemsChangeSYN.OP_CODE = net.ProtocolCode.P_GC_NOTIFY_ITEMS_CHANGE_SYN
GCNotifyItemsChangeSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCNotifyItemsChangeSYN"

-- @param serverId: number
-- @param callback: number
function GCNotifyItemsChangeSYN:ctor(serverId, callback)
	self.super.ctor(self, GCNotifyItemsChangeSYN.OP_CODE, serverId, callback);
end

-- 头像商城相关协议
---------------------------------------------------------------------------
-- 请求头像框商城信息
local CGQueryHeadFrameREQ = class("CGQueryHeadFrameREQ", ProtocolBase)
ns.CGQueryHeadFrameREQ = CGQueryHeadFrameREQ

CGQueryHeadFrameREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_HEAD_FRAME_REQ
CGQueryHeadFrameREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryHeadFrameREQ"

function CGQueryHeadFrameREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryHeadFrameREQ.OP_CODE, serverId, callback);
end

function CGQueryHeadFrameREQ:setData(area)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area;
end

---------------------------------------------------------------------------
local GCQueryHeadFrameRES = class("GCQueryHeadFrameRES", ProtocolBase)
ns.GCQueryHeadFrameRES = GCQueryHeadFrameRES

GCQueryHeadFrameRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_HEAD_FRAME_RES
GCQueryHeadFrameRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryHeadFrameRES"

-- @param serverId: number
-- @param callback: number
function GCQueryHeadFrameRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryHeadFrameRES.OP_CODE, serverId, callback);
end

-- 购买头像框
local CGPurchaseHeadFrameREQ = class("CGPurchaseHeadFrameREQ", ProtocolBase)
ns.CGPurchaseHeadFrameREQ = CGPurchaseHeadFrameREQ

CGPurchaseHeadFrameREQ.OP_CODE = net.ProtocolCode.P_CG_PURCHASE_HEAD_FRAME_REQ
CGPurchaseHeadFrameREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGPurchaseHeadFrameREQ"

function CGPurchaseHeadFrameREQ:ctor(serverId, callback)
	self.super.ctor(self, CGPurchaseHeadFrameREQ.OP_CODE, serverId, callback);
end

function CGPurchaseHeadFrameREQ:setData(area, id, time)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area;
	protocolBuf.id = id
	protocolBuf.time = time
end

---------------------------------------------------------------------------
local GCPurchaseHeadFrameRES = class("GCPurchaseHeadFrameRES", ProtocolBase)
ns.GCPurchaseHeadFrameRES = GCPurchaseHeadFrameRES

GCPurchaseHeadFrameRES.OP_CODE = net.ProtocolCode.P_GC_PURCHASE_HEAD_FRAME_RES
GCPurchaseHeadFrameRES.CLZ_CODE = "com.kodgames.message.proto.game.GCPurchaseHeadFrameRES"

-- @param serverId: number
-- @param callback: number
function GCPurchaseHeadFrameRES:ctor(serverId, callback)
	self.super.ctor(self, GCPurchaseHeadFrameRES.OP_CODE, serverId, callback);
end

-- 切换头像框
local CGSwitchHeadFrameREQ = class("CGSwitchHeadFrameREQ", ProtocolBase)
ns.CGSwitchHeadFrameREQ = CGSwitchHeadFrameREQ

CGSwitchHeadFrameREQ.OP_CODE = net.ProtocolCode.P_CG_SWITCH_HEAD_FRAME_REQ
CGSwitchHeadFrameREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGSwitchHeadFrameREQ"

function CGSwitchHeadFrameREQ:ctor(serverId, callback)
	self.super.ctor(self, CGSwitchHeadFrameREQ.OP_CODE, serverId, callback);
end

function CGSwitchHeadFrameREQ:setData(id)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.id = id;
end

---------------------------------------------------------------------------
local GCSwitchHeadFrameRES = class("GCSwitchHeadFrameRES", ProtocolBase)
ns.GCSwitchHeadFrameRES = GCSwitchHeadFrameRES

GCSwitchHeadFrameRES.OP_CODE = net.ProtocolCode.P_GC_SWITCH_HEAD_FRAME_RES
GCSwitchHeadFrameRES.CLZ_CODE = "com.kodgames.message.proto.game.GCSwitchHeadFrameRES"

-- @param serverId: number
-- @param callback: number
function GCSwitchHeadFrameRES:ctor(serverId, callback)
	self.super.ctor(self, GCSwitchHeadFrameRES.OP_CODE, serverId, callback);
end

--------------------------------新老帐号关联--------------------------------------------
-- 返回老帐号信息
local GCQueryPlayerInfoRES = class("GCQueryPlayerInfoRES", ProtocolBase)
ns.GCQueryPlayerInfoRES = GCQueryPlayerInfoRES

GCQueryPlayerInfoRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_PLAYER_RES
GCQueryPlayerInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryPlayerInfoRES"

-- @param serverId: number
-- @param callback: number
function GCQueryPlayerInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryPlayerInfoRES.OP_CODE, serverId, callback);
end

-- 举报
local CGAccusePlayerREQ = class("CGAccusePlayerREQ", ProtocolBase)
ns.CGAccusePlayerREQ = CGAccusePlayerREQ

CGAccusePlayerREQ.OP_CODE = net.ProtocolCode.P_CG_ACCUSE_PLAYER_REQ
CGAccusePlayerREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGAccusePlayerREQ"

function CGAccusePlayerREQ:ctor(serverId, callback)
	self.super.ctor(self, CGAccusePlayerREQ.OP_CODE, serverId, callback);
end

function CGAccusePlayerREQ:setData(mailAddress, content)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.mailAddress = mailAddress;
	protocolBuf.content = content
end

local GCAccusePlayerRES = class("GCAccusePlayerRES", ProtocolBase)
ns.GCAccusePlayerRES = GCAccusePlayerRES

GCAccusePlayerRES.OP_CODE = net.ProtocolCode.P_GC_ACCUSE_PLAYER_RES
GCAccusePlayerRES.CLZ_CODE = "com.kodgames.message.proto.game.GCAccusePlayerRES"

-- @param serverId: number
-- @param callback: number
function GCAccusePlayerRES:ctor(serverId, callback)
	self.super.ctor(self, GCAccusePlayerRES.OP_CODE, serverId, callback);
end


----------------------------
local GCPushParameterSYN = class("GCPushParameterSYN", ProtocolBase)
ns.GCPushParameterSYN = GCPushParameterSYN

GCPushParameterSYN.OP_CODE = net.ProtocolCode.P_GC_PUSH_PARAMETER_SYN;
GCPushParameterSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCPushParameterSYN"

-- @param serverId: number
-- @param callback: number
function GCPushParameterSYN:ctor(serverId, callback)
	self.super.ctor(self, GCPushParameterSYN.OP_CODE, serverId, callback);
end

-------------------------------------------------------------------------
-- 								礼包相关								--
-------------------------------------------------------------------------
--请求领取礼包
----------------------------
local CGReceiveGiftREQ = class("CGReceiveGiftREQ", ProtocolBase)
ns.CGReceiveGiftREQ = CGReceiveGiftREQ

CGReceiveGiftREQ.OP_CODE = net.ProtocolCode.P_CG_RECEIVE_GIFT_REQ;
CGReceiveGiftREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGReceiveGiftREQ"

-- @param serverId: number
-- @param callback: number
function CGReceiveGiftREQ:ctor(serverId, callback)
	self.super.ctor(self, CGReceiveGiftREQ.OP_CODE, serverId, callback);
end

function CGReceiveGiftREQ:setData(itemId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.itemId = itemId;
end

--请求领取礼包回复
----------------------------
local GCReceiveGiftRES = class("GCReceiveGiftRES", ProtocolBase)
ns.GCReceiveGiftRES = GCReceiveGiftRES

GCReceiveGiftRES.OP_CODE = net.ProtocolCode.P_GC_RECEIVE_GIFT_RES;
GCReceiveGiftRES.CLZ_CODE = "com.kodgames.message.proto.game.GCReceiveGiftRES"

-- @param serverId: number
-- @param callback: number
function GCReceiveGiftRES:ctor(serverId, callback)
	self.super.ctor(self, GCReceiveGiftRES.OP_CODE, serverId, callback);
end

-- 申请代理相关
---------------------------
local CGApplyToAgtREQ = class("CGApplyToAgtREQ", ProtocolBase)
ns.CGApplyToAgtREQ = CGApplyToAgtREQ

CGApplyToAgtREQ.OP_CODE = net.ProtocolCode.P_CG_APPLY_TO_AGT_REQ;
CGApplyToAgtREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGApplyToAgtREQ"

-- @param serverId: number
-- @param callback: number
function CGApplyToAgtREQ:ctor(serverId, callback)
	self.super.ctor(self, CGApplyToAgtREQ.OP_CODE, serverId, callback);
end

function CGApplyToAgtREQ:setData(phone, weChat)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.phone = phone;
	protocolBuf.weChat = weChat
end

-- 申请代理回复sign
----------------------------
local GCApplyToAgtRES = class("GCApplyToAgtRES", ProtocolBase)
ns.GCApplyToAgtRES = GCApplyToAgtRES

GCApplyToAgtRES.OP_CODE = net.ProtocolCode.P_GC_APPLY_TO_AGT_RES;
GCApplyToAgtRES.CLZ_CODE = "com.kodgames.message.proto.game.GCApplyToAgtRES"

-- @param serverId: number
-- @param callback: number
function GCApplyToAgtRES:ctor(serverId, callback)
	self.super.ctor(self, GCApplyToAgtRES.OP_CODE, serverId, callback);
end

----------------------------
local CGQueryH5AccessTokenREQ = class("CGQueryH5AccessTokenREQ", ProtocolBase)
ns.CGQueryH5AccessTokenREQ = CGQueryH5AccessTokenREQ

CGQueryH5AccessTokenREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_H5_ACCESS_TOKEN_REQ;
CGQueryH5AccessTokenREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryH5AccessTokenREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryH5AccessTokenREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryH5AccessTokenREQ.OP_CODE, serverId, callback);
end

function CGQueryH5AccessTokenREQ:setData(appkey)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.appkey = appkey
end

----------------------------
local GCQueryH5AccessTokenRES = class("GCQueryH5AccessTokenRES", ProtocolBase)
ns.GCQueryH5AccessTokenRES = GCQueryH5AccessTokenRES

GCQueryH5AccessTokenRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_H5_ACCESS_TOKEN_RES;
GCQueryH5AccessTokenRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryH5AccessTokenRES"

-- @param serverId: number
-- @param callback: number
function GCQueryH5AccessTokenRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryH5AccessTokenRES.OP_CODE, serverId, callback);
end

----------------------------
local CGQueryH5PayUrlREQ = class("CGQueryH5PayUrlREQ", ProtocolBase)
ns.CGQueryH5PayUrlREQ = CGQueryH5PayUrlREQ

CGQueryH5PayUrlREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_H5_PAY_URL_REQ;
CGQueryH5PayUrlREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryH5PayUrlREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryH5PayUrlREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryH5PayUrlREQ.OP_CODE, serverId, callback);
end

function CGQueryH5PayUrlREQ:setData(prepayId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.prepayId = prepayId
end

----------------------------
local GCQueryH5PayUrlRES = class("GCQueryH5PayUrlRES", ProtocolBase)
ns.GCQueryH5PayUrlRES = GCQueryH5PayUrlRES

GCQueryH5PayUrlRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_H5_PAY_URL_RES;
GCQueryH5PayUrlRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryH5PayUrlRES"

-- @param serverId: number
-- @param callback: number
function GCQueryH5PayUrlRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryH5PayUrlRES.OP_CODE, serverId, callback);
end

----------------------------
local CGUploadH5BIREQ = class("CGUploadH5BIREQ", ProtocolBase)
ns.CGUploadH5BIREQ = CGUploadH5BIREQ

CGUploadH5BIREQ.OP_CODE = net.ProtocolCode.P_CG_UPLOAD_H5_BI_REQ;
CGUploadH5BIREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGUploadH5BIREQ"

-- @param serverId: number
-- @param callback: number
function CGUploadH5BIREQ:ctor(serverId, callback)
	self.super.ctor(self, CGUploadH5BIREQ.OP_CODE, serverId, callback);
end

function CGUploadH5BIREQ:setData(accessToken, biInfo)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.accessToken = accessToken
	protocolBuf.biInfo = biInfo
end

----------------------------
local GCUploadH5BIRES = class("GCUploadH5BIRES", ProtocolBase)
ns.GCUploadH5BIRES = GCUploadH5BIRES

GCUploadH5BIRES.OP_CODE = net.ProtocolCode.P_GC_UPLOAD_H5_BI_RES;
GCUploadH5BIRES.CLZ_CODE = "com.kodgames.message.proto.game.GCUploadH5BIRES"

-- @param serverId: number
-- @param callback: number
function GCUploadH5BIRES:ctor(serverId, callback)
	self.super.ctor(self, GCUploadH5BIRES.OP_CODE, serverId, callback);
end



-- 请求好友列表
local CGQueryFriendListREQ = class("CGQueryFriendListREQ", ProtocolBase)
ns.CGQueryFriendListREQ = CGQueryFriendListREQ

CGQueryFriendListREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_FRIEND_LIST_REQ;
CGQueryFriendListREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryFriendListREQ"

function CGQueryFriendListREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryFriendListREQ.OP_CODE, serverId, callback);
end

local GCQueryFriendListRES = class("GCQueryFriendListRES", ProtocolBase)
ns.GCQueryFriendListRES = GCQueryFriendListRES

GCQueryFriendListRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_FRIEND_LIST_RES;
GCQueryFriendListRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryFriendListRES"

function GCQueryFriendListRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryFriendListRES.OP_CODE, serverId, callback);
end

-- 请求好友推荐列表
local CGQueryFriendRecommendListREQ = class("CGQueryFriendRecommendListREQ", ProtocolBase)
ns.CGQueryFriendRecommendListREQ = CGQueryFriendRecommendListREQ

CGQueryFriendRecommendListREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_FRIEND_RECOMMEND_LIST_REQ;
CGQueryFriendRecommendListREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryFriendRecommendListREQ"

function CGQueryFriendRecommendListREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryFriendRecommendListREQ.OP_CODE, serverId, callback);
end

local GCQueryFriendRecommendListRES = class("GCQueryFriendRecommendListRES", ProtocolBase)
ns.GCQueryFriendRecommendListRES = GCQueryFriendRecommendListRES

GCQueryFriendRecommendListRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_FRIEND_RECOMMEND_LIST_RES;
GCQueryFriendRecommendListRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryFriendRecommendListRES"

function GCQueryFriendRecommendListRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryFriendRecommendListRES.OP_CODE, serverId, callback);
end

-- 请求好友申请列表
local CGQueryFriendApplicantListREQ = class("CGQueryFriendApplicantListREQ", ProtocolBase)
ns.CGQueryFriendApplicantListREQ = CGQueryFriendApplicantListREQ

CGQueryFriendApplicantListREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_FRIEND_APPLICANT_LIST_REQ;
CGQueryFriendApplicantListREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryFriendApplicantListREQ"

function CGQueryFriendApplicantListREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryFriendApplicantListREQ.OP_CODE, serverId, callback);
end

local GCQueryFriendApplicantListRES = class("GCQueryFriendApplicantListRES", ProtocolBase)
ns.GCQueryFriendApplicantListRES = GCQueryFriendApplicantListRES

GCQueryFriendApplicantListRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_FRIEND_APPLICANT_LIST_RES;
GCQueryFriendApplicantListRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryFriendApplicantListRES"

function GCQueryFriendApplicantListRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryFriendApplicantListRES.OP_CODE, serverId, callback);
end

-- 请求查询某个玩家的信息
local CGSearchRoleInfoREQ = class("CGSearchRoleInfoREQ", ProtocolBase)
ns.CGSearchRoleInfoREQ = CGSearchRoleInfoREQ

CGSearchRoleInfoREQ.OP_CODE = net.ProtocolCode.P_CG_SEARCH_ROLE_INFO_REQ;
CGSearchRoleInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGSearchRoleInfoREQ"

function CGSearchRoleInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGSearchRoleInfoREQ.OP_CODE, serverId, callback);
end

function CGSearchRoleInfoREQ:setData(searchId)
	self:getProtocolBuf().searchId = searchId
end

local GCSearchRoleInfoRES = class("GCSearchRoleInfoRES", ProtocolBase)
ns.GCSearchRoleInfoRES = GCSearchRoleInfoRES

GCSearchRoleInfoRES.OP_CODE = net.ProtocolCode.P_GC_SEARCH_ROLE_INFO_RES;
GCSearchRoleInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCSearchRoleInfoRES"

function GCSearchRoleInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCSearchRoleInfoRES.OP_CODE, serverId, callback);
end

-- 请求发送添加好友的申请
local CGSendFriendApplicantREQ = class("CGSendFriendApplicantREQ", ProtocolBase)
ns.CGSendFriendApplicantREQ = CGSendFriendApplicantREQ

CGSendFriendApplicantREQ.OP_CODE = net.ProtocolCode.P_CG_SEND_FRIEND_APPLICANT_REQ;
CGSendFriendApplicantREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGSendFriendApplicantREQ"

function CGSendFriendApplicantREQ:ctor(serverId, callback)
	self.super.ctor(self, CGSendFriendApplicantREQ.OP_CODE, serverId, callback);
end

function CGSendFriendApplicantREQ:setData(recipientId, sourceType)
	self:getProtocolBuf().recipientId = recipientId
	self:getProtocolBuf().sourceType = sourceType
end

local GCSendFriendApplicantRES = class("GCSendFriendApplicantRES", ProtocolBase)
ns.GCSendFriendApplicantRES = GCSendFriendApplicantRES

GCSendFriendApplicantRES.OP_CODE = net.ProtocolCode.P_GC_SEND_FRIEND_APPLICANT_RES;
GCSendFriendApplicantRES.CLZ_CODE = "com.kodgames.message.proto.game.GCSendFriendApplicantRES"

function GCSendFriendApplicantRES:ctor(serverId, callback)
	self.super.ctor(self, GCSendFriendApplicantRES.OP_CODE, serverId, callback);
end

-- 请求房间好友邀请列表
local CGQueryRoomInvitedFriendInfosREQ = class("CGQueryRoomInvitedFriendInfosREQ", ProtocolBase)
ns.CGQueryRoomInvitedFriendInfosREQ = CGQueryRoomInvitedFriendInfosREQ

CGQueryRoomInvitedFriendInfosREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_ROOM_INVITED_FRIEND_INFOS_REQ;
CGQueryRoomInvitedFriendInfosREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryRoomInvitedFriendInfosREQ"

function CGQueryRoomInvitedFriendInfosREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryRoomInvitedFriendInfosREQ.OP_CODE, serverId, callback);
end

function CGQueryRoomInvitedFriendInfosREQ:setData(roomId)
	self:getProtocolBuf().roomId = roomId
end

local GCQueryRoomInvitedFriendInfosRES = class("GCQueryRoomInvitedFriendInfosRES", ProtocolBase)
ns.GCQueryRoomInvitedFriendInfosRES = GCQueryRoomInvitedFriendInfosRES

GCQueryRoomInvitedFriendInfosRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_ROOM_INVITED_FRIEND_INFOS_RES;
GCQueryRoomInvitedFriendInfosRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryRoomInvitedFriendInfosRES"

function GCQueryRoomInvitedFriendInfosRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryRoomInvitedFriendInfosRES.OP_CODE, serverId, callback);
end

-- 请求发送房间好友邀请
local CGSendRoomInvitationREQ = class("CGSendRoomInvitationREQ", ProtocolBase)
ns.CGSendRoomInvitationREQ = CGSendRoomInvitationREQ

CGSendRoomInvitationREQ.OP_CODE = net.ProtocolCode.P_CG_SEND_ROOM_INVITATION_REQ;
CGSendRoomInvitationREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGSendRoomInvitationREQ"

function CGSendRoomInvitationREQ:ctor(serverId, callback)
	self.super.ctor(self, CGSendRoomInvitationREQ.OP_CODE, serverId, callback);
end

function CGSendRoomInvitationREQ:setData(roomId, inviteeId)
	self:getProtocolBuf().inviteeId = inviteeId
	self:getProtocolBuf().roomId = roomId
end

local GCSendRoomInvitationRES = class("GCSendRoomInvitationRES", ProtocolBase)
ns.GCSendRoomInvitationRES = GCSendRoomInvitationRES

GCSendRoomInvitationRES.OP_CODE = net.ProtocolCode.P_GC_SEND_ROOM_INVITATION_RES;
GCSendRoomInvitationRES.CLZ_CODE = "com.kodgames.message.proto.game.GCSendRoomInvitationRES"

function GCSendRoomInvitationRES:ctor(serverId, callback)
	self.super.ctor(self, GCSendRoomInvitationRES.OP_CODE, serverId, callback);
end

local GCNotifyRoomInvitationSYN = class("GCNotifyRoomInvitationSYN", ProtocolBase)
ns.GCNotifyRoomInvitationSYN = GCNotifyRoomInvitationSYN

GCNotifyRoomInvitationSYN.OP_CODE = net.ProtocolCode.P_GC_NOTIFY_ROOM_INVITATION_SYN
GCNotifyRoomInvitationSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCNotifyRoomInvitationSYN"

function GCNotifyRoomInvitationSYN:ctor(serverId, callback)
	self.super.ctor(self, GCNotifyRoomInvitationSYN.OP_CODE, serverId, callback);
end

-- 请求删除好友
local CGDeleteFriendInfoREQ = class("CGDeleteFriendInfoREQ", ProtocolBase)
ns.CGDeleteFriendInfoREQ = CGDeleteFriendInfoREQ

CGDeleteFriendInfoREQ.OP_CODE = net.ProtocolCode.P_CG_DELETE_FRIEND_INFO_REQ;
CGDeleteFriendInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGDeleteFriendInfoREQ"

function CGDeleteFriendInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGDeleteFriendInfoREQ.OP_CODE, serverId, callback);
end

function CGDeleteFriendInfoREQ:setData(deleteRoleId)
	self:getProtocolBuf().deleteRoleId = deleteRoleId
end

local GCDeleteFriendInfoRES = class("GCDeleteFriendInfoRES", ProtocolBase)
ns.GCDeleteFriendInfoRES = GCDeleteFriendInfoRES

GCDeleteFriendInfoRES.OP_CODE = net.ProtocolCode.P_GC_DELETE_FRIEND_INFO_RES;
GCDeleteFriendInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCDeleteFriendInfoRES"

function GCDeleteFriendInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCDeleteFriendInfoRES.OP_CODE, serverId, callback);
end

-- 请求处理好友申请的请求
local CGHandleFriendApplicantREQ = class("CGHandleFriendApplicantREQ", ProtocolBase)
ns.CGHandleFriendApplicantREQ = CGHandleFriendApplicantREQ

CGHandleFriendApplicantREQ.OP_CODE = net.ProtocolCode.P_CG_HANDLE_FRIEND_APPLICANT_REQ;
CGHandleFriendApplicantREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGHandleFriendApplicantREQ"

function CGHandleFriendApplicantREQ:ctor(serverId, callback)
	self.super.ctor(self, CGHandleFriendApplicantREQ.OP_CODE, serverId, callback);
end

function CGHandleFriendApplicantREQ:setData(opType, applicantId)
	self:getProtocolBuf().opType = opType
	self:getProtocolBuf().applicantId = applicantId
end

local GCHandleFriendApplicantRES = class("GCHandleFriendApplicantRES", ProtocolBase)
ns.GCHandleFriendApplicantRES = GCHandleFriendApplicantRES

GCHandleFriendApplicantRES.OP_CODE = net.ProtocolCode.P_GC_HANDLE_FRIEND_APPLICANT_RES;
GCHandleFriendApplicantRES.CLZ_CODE = "com.kodgames.message.proto.game.GCHandleFriendApplicantRES"

function GCHandleFriendApplicantRES:ctor(serverId, callback)
	self.super.ctor(self, GCHandleFriendApplicantRES.OP_CODE, serverId, callback);
end

-- 请求检测是否是好友关系
local CGCheckFriendShipREQ = class("CGCheckFriendShipREQ", ProtocolBase)
ns.CGCheckFriendShipREQ = CGCheckFriendShipREQ

CGCheckFriendShipREQ.OP_CODE = net.ProtocolCode.P_CG_CHECK_FRIENDSHIP_REQ;
CGCheckFriendShipREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGCheckFriendShipREQ"

function CGCheckFriendShipREQ:ctor(serverId, callback)
	self.super.ctor(self, CGCheckFriendShipREQ.OP_CODE, serverId, callback);
end

function CGCheckFriendShipREQ:setData(checkRoleId)
	self:getProtocolBuf().checkRoleId = checkRoleId
end

local GCCheckFriendShipRES = class("GCCheckFriendShipRES", ProtocolBase)
ns.GCCheckFriendShipRES = GCCheckFriendShipRES

GCCheckFriendShipRES.OP_CODE = net.ProtocolCode.P_GC_CHECK_FRIENDSHIP_RES;
GCCheckFriendShipRES.CLZ_CODE = "com.kodgames.message.proto.game.GCCheckFriendShipRES"

function GCCheckFriendShipRES:ctor(serverId, callback)
	self.super.ctor(self, GCCheckFriendShipRES.OP_CODE, serverId, callback);
end

-- 推送好友系统的通知数据
local GCSendFriendNotifyDataSYN = class("GCSendFriendNotifyDataSYN", ProtocolBase)
ns.GCSendFriendNotifyDataSYN = GCSendFriendNotifyDataSYN

GCSendFriendNotifyDataSYN.OP_CODE = net.ProtocolCode.P_GC_SEND_FRIEND_NOTIFY_DATA_SYN
GCSendFriendNotifyDataSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCSendFriendNotifyDataSYN"

function GCSendFriendNotifyDataSYN:ctor(serverId, callback)
	self.super.ctor(self, GCSendFriendNotifyDataSYN.OP_CODE, serverId, callback);
end

------------------------活动标签协议--------------------------------
local GCActivityTagSYN = class("GCActivityTagSYN", ProtocolBase)
ns.GCActivityTagSYN = GCActivityTagSYN

GCActivityTagSYN.OP_CODE = net.ProtocolCode.P_GC_ACTIVITY_TAG_SYN;
GCActivityTagSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCActivityTagSYN"

-- @param serverId: number
-- @param callback: number
function GCActivityTagSYN:ctor(serverId, callback)
	self.super.ctor(self, GCActivityTagSYN.OP_CODE, serverId, callback);
end

-- 魔法表情
local CGSendEmojiREQ = class("CGSendEmojiREQ", ProtocolBase)
ns.CGSendEmojiREQ = CGSendEmojiREQ

CGSendEmojiREQ.OP_CODE = net.ProtocolCode.P_CG_SEND_EMOJI_REQ;
CGSendEmojiREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGSendEmojiREQ"

function CGSendEmojiREQ:ctor(serverId, callback)
	self.super.ctor(self, CGSendEmojiREQ.OP_CODE, serverId, callback);
end

function CGSendEmojiREQ:setData(emojiId, receiver)
	self:getProtocolBuf().emojiId = emojiId
	self:getProtocolBuf().receiver = receiver
end

local GCSendEmojiRES = class("GCSendEmojiRES", ProtocolBase)
ns.GCSendEmojiRES = GCSendEmojiRES

GCSendEmojiRES.OP_CODE = net.ProtocolCode.P_GC_SEND_EMOJI_RES;
GCSendEmojiRES.CLZ_CODE = "com.kodgames.message.proto.game.GCSendEmojiRES"

function GCSendEmojiRES:ctor(serverId, callback)
	self.super.ctor(self, GCSendEmojiRES.OP_CODE, serverId, callback);
end

local GCSendEmojiSYN = class("GCSendEmojiSYN", ProtocolBase)
ns.GCSendEmojiSYN = GCSendEmojiSYN

GCSendEmojiSYN.OP_CODE = net.ProtocolCode.P_GC_SEND_EMOJI_SYN;
GCSendEmojiSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCSendEmojiSYN"

-- @param serverId: number
-- @param callback: number
function GCSendEmojiSYN:ctor(serverId, callback)
	self.super.ctor(self, GCSendEmojiSYN.OP_CODE, serverId, callback);
end

-- 购买选择
local CGQueryPayTypesREQ = class("CGQueryPayTypesREQ", ProtocolBase)
ns.CGQueryPayTypesREQ = CGQueryPayTypesREQ

CGQueryPayTypesREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_PAY_TYPES_REQ;
CGQueryPayTypesREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryPayTypesREQ"

function CGQueryPayTypesREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryPayTypesREQ.OP_CODE, serverId, callback);
end

function CGQueryPayTypesREQ:setData(osType)
	self:getProtocolBuf().osType = osType
end


local GCQueryPayTypesRES = class("GCQueryPayTypesRES", ProtocolBase)
ns.GCQueryPayTypesRES = GCQueryPayTypesRES

GCQueryPayTypesRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_PAY_TYPES_RES;
GCQueryPayTypesRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryPayTypesRES"

function GCQueryPayTypesRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryPayTypesRES.OP_CODE, serverId, callback);
end

-----------------------------------------------------------------------------
local CGQueryEmojiREQ = class("CGQueryEmojiREQ", ProtocolBase)
ns.CGQueryEmojiREQ = CGQueryEmojiREQ

CGQueryEmojiREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_EMOJI_REQ
CGQueryEmojiREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryEmojiREQ"

function CGQueryEmojiREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryEmojiREQ.OP_CODE, serverId, callback);
end

local GCQueryEmojiRES = class("GCQueryEmojiRES", ProtocolBase)
ns.GCQueryEmojiRES = GCQueryEmojiRES

GCQueryEmojiRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_EMOJI_RES;
GCQueryEmojiRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryEmojiRES"

function GCQueryEmojiRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryEmojiRES.OP_CODE, serverId, callback);
end

----------------------------
-- 同步玩家当前使用特效
----------------------------
local GCSpecialEffectSYN = class("GCSpecialEffectSYN", ProtocolBase)
ns.GCSpecialEffectSYN = GCSpecialEffectSYN

GCSpecialEffectSYN.OP_CODE = net.ProtocolCode.P_GC_SPECIAL_EFFECCT_SYN;
GCSpecialEffectSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCSpecialEffectSYN"

-- @param serverId: number
-- @param callback: number
function GCSpecialEffectSYN:ctor(serverId, callback)
	self.super.ctor(self, GCSpecialEffectSYN.OP_CODE, serverId, callback);
end

-- 使用特效req
----------------------------
local CGUseSpecialEffectREQ = class("CGUseSpecialEffectREQ", ProtocolBase)
ns.CGUseSpecialEffectREQ = CGUseSpecialEffectREQ

CGUseSpecialEffectREQ.OP_CODE = net.ProtocolCode.P_CG_USE_SPECIAL_EFFECT_REQ
CGUseSpecialEffectREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGUseSpecialEffectREQ"

function CGUseSpecialEffectREQ:ctor(serverId, callback)
	self.super.ctor(self, CGUseSpecialEffectREQ.OP_CODE, serverId, callback);
end

function CGUseSpecialEffectREQ:setData(itemId,operate)
	self:getProtocolBuf().itemId = itemId
	self:getProtocolBuf().operate = operate
end

-- res
---------------------------
local GCUseSpecialEffectRES = class("GCUseSpecialEffectRES", ProtocolBase)
ns.GCUseSpecialEffectRES = GCUseSpecialEffectRES

GCUseSpecialEffectRES.OP_CODE = net.ProtocolCode.P_GC_USE_SPECIAL_EFFECCT_RES;
GCUseSpecialEffectRES.CLZ_CODE = "com.kodgames.message.proto.game.GCUseSpecialEffectRES"

-- @param serverId: number
-- @param callback: number
function GCUseSpecialEffectRES:ctor(serverId, callback)
	self.super.ctor(self, GCUseSpecialEffectRES.OP_CODE, serverId, callback);
end

--发送deviceId统计，为账号互通服务
----------------------------
local CGUploadClientInfoREQ = class("CGUploadClientInfoREQ", ProtocolBase)
ns.CGUploadClientInfoREQ = CGUploadClientInfoREQ

CGUploadClientInfoREQ.OP_CODE = net.ProtocolCode.P_CG_UPLOAD_CLIENT_INFO_REQ;
CGUploadClientInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGUploadClientInfoREQ"

-- @param serverId: number
-- @param callback: number
function CGUploadClientInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGUploadClientInfoREQ.OP_CODE, serverId, callback);
end

function CGUploadClientInfoREQ:setData(writeOp, readOp, deviceId, deivceName, deviceVersion)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.writeOpType = writeOp;
	protocolBuf.readOpType = readOp;
	protocolBuf.deviceId = deviceId;
	protocolBuf.deviceName = deivceName;
	protocolBuf.deviceVersion = deviceVersion;
end

----------------------------
local GCUploadClientInfoRES = class("GCUploadClientInfoRES", ProtocolBase)
ns.GCUploadClientInfoRES = GCUploadClientInfoRES

GCUploadClientInfoRES.OP_CODE = net.ProtocolCode.P_GC_UPLOAD_CLIENT_INFO_RES;
GCUploadClientInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCUploadClientInfoRES"

-- @param serverId: number
-- @param callback: number
function GCUploadClientInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCUploadClientInfoRES.OP_CODE, serverId, callback);
end

-- 向客户端同步红点状态值
local GCRedDotStatusSYN = class("GCRedDotStatusSYN", ProtocolBase)
ns.GCRedDotStatusSYN = GCRedDotStatusSYN

GCRedDotStatusSYN.OP_CODE = net.ProtocolCode.P_GC_RED_DOT_STATUS_SYN;
GCRedDotStatusSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCRedDotStatusSYN"

-- @param serverId: number
-- @param callback: number
function GCRedDotStatusSYN:ctor(serverId, callback)
	self.super.ctor(self, GCRedDotStatusSYN.OP_CODE, serverId, callback);
end


-- 服务器要求客户端上传日志
local GCUploadClientLogSYN = class("GCUploadClientLogSYN", ProtocolBase)
ns.GCUploadClientLogSYN = GCUploadClientLogSYN

GCUploadClientLogSYN.OP_CODE = net.ProtocolCode.P_GC_UPLOAD_CLIENT_LOG_SYN;
GCUploadClientLogSYN.CLZ_CODE = "com.kodgames.message.proto.game.GCUploadClientLogSYN"

-- @param serverId: number
-- @param callback: number
function GCUploadClientLogSYN:ctor(serverId, callback)
	self.super.ctor(self, GCUploadClientLogSYN.OP_CODE, serverId, callback);
end

-- 上传日志完成通知服务器
local CGUploadClientLogREQ = class("CGUploadClientLogREQ", ProtocolBase)
ns.CGUploadClientLogREQ = CGUploadClientLogREQ

CGUploadClientLogREQ.OP_CODE = net.ProtocolCode.P_CG_UPLOAD_CLIENT_LOG_REQ;
CGUploadClientLogREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGUploadClientLogREQ"

-- @param serverId: number
-- @param callback: number
function CGUploadClientLogREQ:ctor(serverId, callback)
	self.super.ctor(self, CGUploadClientLogREQ.OP_CODE, serverId, callback);
end


-- 服务器收到上传完成的返回
local GCUploadClientLogRES = class("GCUploadClientLogRES", ProtocolBase)
ns.GCUploadClientLogRES = GCUploadClientLogRES

GCUploadClientLogRES.OP_CODE = net.ProtocolCode.P_GC_UPLOAD_CLIENT_LOG_RES;
GCUploadClientLogRES.CLZ_CODE = "com.kodgames.message.proto.game.GCUploadClientLogRES"

-- @param serverId: number
-- @param callback: number
function GCUploadClientLogRES:ctor(serverId, callback)
	self.super.ctor(self, GCUploadClientLogRES.OP_CODE, serverId, callback);
end

-- 向客户端同步活动信息
local SCActivityInfoSYN = class("SCActivityInfoSYN", ProtocolBase)
ns.SCActivityInfoSYN = SCActivityInfoSYN

SCActivityInfoSYN.OP_CODE = net.ProtocolCode.P_GC_ACTIVITY_INFO_SYN;
SCActivityInfoSYN.CLZ_CODE = "com.kodgames.message.proto.game.SCActivityInfoSYN"

-- @param serverId: number
-- @param callback: number
function SCActivityInfoSYN:ctor(serverId, callback)
	self.super.ctor(self, SCActivityInfoSYN.OP_CODE, serverId, callback);
end

-- 玩家查询门票背包道具请求
local CGQueryRoleTicketsREQ = class("CGQueryRoleTicketsREQ", ProtocolBase)
ns.CGQueryRoleTicketsREQ = CGQueryRoleTicketsREQ

CGQueryRoleTicketsREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_ROLE_TICKETS_REQ;
CGQueryRoleTicketsREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryRoleTicketsREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryRoleTicketsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryRoleTicketsREQ.OP_CODE, serverId, callback);
end

-- 玩家查询门票背包道具返回
local GCQueryRoleTicketsRES = class("GCQueryRoleTicketsRES", ProtocolBase)
ns.GCQueryRoleTicketsRES = GCQueryRoleTicketsRES

GCQueryRoleTicketsRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_ROLE_TICKETS_RES;
GCQueryRoleTicketsRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryRoleTicketsRES"

-- @param serverId: number
-- @param callback: number
function GCQueryRoleTicketsRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryRoleTicketsRES.OP_CODE, serverId, callback);
end

---
--- 钱包系统
---
--信息请求
buildMessage("CGWalletInfoREQ", Code.P_CG_WALLET_INFO_REQ)
--信息回复
buildMessage("GCWalletInfoRES", Code.P_GC_WALLET_INFO_RES, Code.WALLET_INFO_SUCCESS)
--提现请求
buildMessage("CGWalletWithdrawREQ", Code.P_CG_WALLET_WITHDRAW_REQ)
--提现回复
buildMessage("GCWalletWithdrawRES", Code.P_GC_WALLET_WITHDRAW_RES, Code.WALLET_WITHDRAW_SUCCESS)
--账单请求
buildMessage("CGWalletWithdrawRecordREQ", Code.P_CG_WALLET_WITHDRAW_RECORD_REQ)
--账单回复
buildMessage("GCWalletWithdrawRecordRES", Code.P_GC_WALLET_WITHDRAW_RECORD_RES, Code.WALLET_WITHDRAW_RECORD_SUCCESS)
--请求提现配置
buildMessage("CGWalletConfigREQ", Code.P_CG_WALLET_CONFIG_REQ)
--回应提现配置
buildMessage("GCWalletConfigRES", Code.P_GC_WALLET_CONFIG_RES, Code.WALLET_CONFIG_SUCCESS)

--请求名片信息
buildMessage("CGBusinessCardInfoREQ", Code.P_CG_BUSINESS_CARD_INFO_REQ)
--回应名片信息
buildMessage("GCBusinessCardInfoRES", Code.P_GC_BUSINESS_CARD_INFO_RES, Code.BUSINESS_CARD_INFO_SUCCESS)