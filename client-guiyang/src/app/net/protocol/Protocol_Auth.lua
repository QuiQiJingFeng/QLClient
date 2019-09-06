local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

----------------------------
-- 协议加密握手
----------------------------
local ICEncryptSYN = class("ICEncryptSYN", ProtocolBase)
ns.ICEncryptSYN = ICEncryptSYN
ICEncryptSYN.OP_CODE = net.ProtocolCode.P_IC_ENCRYPT_SYN
ICEncryptSYN.CLZ_CODE = "com.kodgames.message.proto.auth.ICEncryptSYN"

-- @param serverId: number
-- @param callback: number
function ICEncryptSYN:ctor(serverId, callback)
    self.super.ctor(self, ICEncryptSYN.OP_CODE, serverId, callback)
end

----------------------------
-- 热更新
----------------------------
local CIVersionUpdateREQ = class("CIVersionUpdateREQ", ProtocolBase)
ns.CIVersionUpdateREQ = CIVersionUpdateREQ

CIVersionUpdateREQ.OP_CODE = net.ProtocolCode.P_CI_VERSION_UPDATE_REQ
CIVersionUpdateREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIVersionUpdateREQ"

-- @param serverId: number
-- @param callback: number
function CIVersionUpdateREQ:ctor(serverId, callback)
	self.super.ctor(self, CIVersionUpdateREQ.OP_CODE, serverId, callback);
end

-- @param channel: string
-- @param username: string
function CIVersionUpdateREQ:setData(channel, subchannel, libVersion, proVersion, roleId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.channel = channel
	protocolBuf.subchannel = subchannel
	protocolBuf.libVersion = libVersion
    protocolBuf.proVersion = proVersion
    protocolBuf.roleId = roleId
end

----------------------------
local ICVersionUpdateRES = class("ICVersionUpdateRES", ProtocolBase)
ns.ICVersionUpdateRES = ICVersionUpdateRES

ICVersionUpdateRES.OP_CODE = net.ProtocolCode.P_IC_VERSION_UPDATE_RES
ICVersionUpdateRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICVersionUpdateRES"

-- @param serverId: number
-- @param callback: number
function ICVersionUpdateRES:ctor(serverId, callback)
    self.super.ctor(self, ICVersionUpdateRES.OP_CODE, serverId, callback);
end

----------------------------
-- 登录InterfaceServer
----------------------------
local CIAccountAuthREQ = class("CIAccountAuthREQ", ProtocolBase)
ns.CIAccountAuthREQ = CIAccountAuthREQ

CIAccountAuthREQ.OP_CODE = net.ProtocolCode.P_CI_ACCOUNT_AUTH_REQ;
CIAccountAuthREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIAccountAuthREQ"

-- @param serverId: number
-- @param callback: number
function CIAccountAuthREQ:ctor(serverId, callback)
	self.super.ctor(self, CIAccountAuthREQ.OP_CODE, serverId, callback);
end

-- @param channel: string
-- @param username: string
-- @param code: string
-- @param refreshToken: string
function CIAccountAuthREQ:setData(channel, username, code, refreshToken,area, subChannel, updateChannel)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.channel = channel;
	protocolBuf.username = username;
	protocolBuf.refreshToken = refreshToken;
	protocolBuf.code = code;
	protocolBuf.platform = game.plugin.Runtime.getPlatform();
	protocolBuf.proVersion = tostring(game.service.UpdateService.getInstance():getProductVersion():getVersions()[1]);
	protocolBuf.libVersion = game.plugin.Runtime.getBuildVersion()
	protocolBuf.appCode = tonumber(game.plugin.Runtime.getChannelId());
	protocolBuf.deviceId = game.plugin.Runtime.getDeviceId()
	protocolBuf.area = area;
	protocolBuf.subChannel = tonumber(game.plugin.Runtime.getSubChannelId());
	protocolBuf.updateChannel = tonumber(game.plugin.Runtime.getChannelId());
end

----------------------------
local ICAccountAuthRES = class("ICAccountAuthRES", ProtocolBase)
ns.ICAccountAuthRES = ICAccountAuthRES

ICAccountAuthRES.OP_CODE = net.ProtocolCode.P_IC_ACCOUNT_AUTH_RES;
ICAccountAuthRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICAccountAuthRES"

-- @param serverId: number
-- @param callback: number
function ICAccountAuthRES:ctor(serverId, callback)
    self.super.ctor(self, ICAccountAuthRES.OP_CODE, serverId, callback);
end

--手机绑定登录相关
-- phone code response
local ICVerifyCodeRES = class("ICVerifyCodeRES", ProtocolBase)
ns.ICVerifyCodeRES = ICVerifyCodeRES
ICVerifyCodeRES.OP_CODE = net.ProtocolCode.P_IC_VERIFY_CODE_RES
ICVerifyCodeRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICVerifyCodeRES"
function ICVerifyCodeRES:ctor(serverId, callback)
    self.super.ctor(self, ICVerifyCodeRES.OP_CODE, serverId, callback);
end

-- mobile to interface
local CIPhoneLoginREQ = class("CIPhoneLoginREQ", ProtocolBase)
ns.CIPhoneLoginREQ = CIPhoneLoginREQ
CIPhoneLoginREQ.OP_CODE = net.ProtocolCode.P_CI_PHONE_LOGIN_REQ;
CIPhoneLoginREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIPhoneLoginREQ"

function CIPhoneLoginREQ:ctor(serverId, callback)
	self.super.ctor(self, CIPhoneLoginREQ.OP_CODE, serverId, callback);
end

function CIPhoneLoginREQ:setData(channel, phone, verifyCode, token, area, subChannel, updateChannel)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.channel = channel;
	protocolBuf.phone = phone;
	protocolBuf.token = token;
	protocolBuf.verifyCode = verifyCode;
	protocolBuf.platform = game.plugin.Runtime.getPlatform();
	protocolBuf.proVersion = tostring(game.service.UpdateService.getInstance():getProductVersion():getVersions()[1]);
	protocolBuf.libVersion = game.plugin.Runtime.getBuildVersion()
	protocolBuf.appCode = tonumber(game.plugin.Runtime.getChannelId());
	protocolBuf.deviceId = game.plugin.Runtime.getDeviceId();
	protocolBuf.area = area;
	protocolBuf.subChannel = tonumber(game.plugin.Runtime.getSubChannelId());
	protocolBuf.updateChannel = tonumber(game.plugin.Runtime.getChannelId());
end

-- phonecode request
local CIVerifyCodeREQ = class("CIVerifyCodeREQ", ProtocolBase)
ns.CIVerifyCodeREQ = CIVerifyCodeREQ
CIVerifyCodeREQ.OP_CODE = net.ProtocolCode.P_CI_VERIFY_CODE_REQ
CIVerifyCodeREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIVerifyCodeREQ"
function CIVerifyCodeREQ:ctor(serverId, callback)
	self.super.ctor(self, CIVerifyCodeREQ.OP_CODE, serverId, callback);
end
function CIVerifyCodeREQ:setData(phone, type)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.appCode = tonumber(game.plugin.Runtime.getChannelId())
	protocolBuf.phone = phone
	protocolBuf.type = type
end

-- phone bind req
local CIBindPhoneREQ = class("CIBindPhoneREQ", ProtocolBase)
ns.CIBindPhoneREQ = CIBindPhoneREQ
CIBindPhoneREQ.OP_CODE = net.ProtocolCode.P_CI_BIND_PHONE_REQ
CIBindPhoneREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIBindPhoneREQ"
function CIBindPhoneREQ:ctor(serverId, callback)
	self.super.ctor(self, CIBindPhoneREQ.OP_CODE, serverId, callback);
end
function CIBindPhoneREQ:setData(newphone,verifyCode,type,oldphone)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.phone = newphone
	protocolBuf.oldPhone = oldphone
	--2绑定 3更改
	protocolBuf.area = game.service.LocalPlayerService:getInstance():getArea()
	protocolBuf.verifyCode = verifyCode
	protocolBuf.type = type
	--todo
	protocolBuf.accountId = game.service.LocalPlayerService.getInstance():getRoleId()
	dump(protocolBuf)
end


-- phone bind result respone
local ICBindPhoneRES = class("ICBindPhoneRES", ProtocolBase)
ns.ICBindPhoneRES = ICBindPhoneRES
ICBindPhoneRES.OP_CODE = net.ProtocolCode.P_IC_BIND_PHONE_RES
ICBindPhoneRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICBindPhoneRES"
function ICBindPhoneRES:ctor(serverId, callback)
    self.super.ctor(self, ICBindPhoneRES.OP_CODE, serverId, callback);
end

--------------------------------新老帐号关联--------------------------------------------
-- 请求老帐号信息
local CIQueryPlayerInfoREQ = class("CIQueryPlayerInfoREQ", ProtocolBase)
ns.CIQueryPlayerInfoREQ = CIQueryPlayerInfoREQ

CIQueryPlayerInfoREQ.OP_CODE = net.ProtocolCode.P_CI_QUERY_PLAYER_REQ;
CIQueryPlayerInfoREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIQueryPlayerInfoREQ"

-- @param serverId: number
-- @param callback: number
function CIQueryPlayerInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CIQueryPlayerInfoREQ.OP_CODE, serverId, callback);
end

function CIQueryPlayerInfoREQ:setData(oldBindPhone, verifyCode, area)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.oldBindPhone = oldBindPhone;
	protocolBuf.verifyCode = verifyCode;
	protocolBuf.area = area;
end

-- 请求绑定老帐号
local CIBindOldPlayerREQ = class("CIBindOldPlayerREQ", ProtocolBase)
ns.CIBindOldPlayerREQ = CIBindOldPlayerREQ

CIBindOldPlayerREQ.OP_CODE = net.ProtocolCode.P_CI_BIND_OLD_PLAYER_REQ;
CIBindOldPlayerREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIBindOldPlayerREQ"

-- @param serverId: number
-- @param callback: number
function CIBindOldPlayerREQ:ctor(serverId, callback)
	self.super.ctor(self, CIBindOldPlayerREQ.OP_CODE, serverId, callback);
end

function CIBindOldPlayerREQ:setData(sign, phone)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.sign = sign;
	protocolBuf.phone = phone;
end

-- 绑定结果
local ICBindOldPlayerRES = class("ICBindOldPlayerRES", ProtocolBase)
ns.ICBindOldPlayerRES = ICBindOldPlayerRES

ICBindOldPlayerRES.OP_CODE = net.ProtocolCode.P_IC_BIND_OLD_PLAYER_RES;
ICBindOldPlayerRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICBindOldPlayerRES"

-- @param serverId: number
-- @param callback: number
function ICBindOldPlayerRES:ctor(serverId, callback)
    self.super.ctor(self, ICBindOldPlayerRES.OP_CODE, serverId, callback);
end

-- 钉钉绑定协议
local CIBindDingTalkREQ = class("CIBindDingTalkREQ", ProtocolBase)
ns.CIBindDingTalkREQ = CIBindDingTalkREQ

CIBindDingTalkREQ.OP_CODE = net.ProtocolCode.P_CI_BIND_DINGTALK_REQ;
CIBindDingTalkREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIBindDingTalkREQ"

-- @param serverId: number
-- @param callback: number
function CIBindDingTalkREQ:ctor(serverId, callback)
	self.super.ctor(self, CIBindDingTalkREQ.OP_CODE, serverId, callback);
end

function CIBindDingTalkREQ:setData(accountId, code, area)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.accountId = accountId
	protocolBuf.code = code
	protocolBuf.cardNum = cardNum
	protocolBuf.area = area
end

-- 绑定结果
local ICBindDingTalkRES = class("ICBindDingTalkRES", ProtocolBase)
ns.ICBindDingTalkRES = ICBindDingTalkRES

ICBindDingTalkRES.OP_CODE = net.ProtocolCode.P_IC_BIND_DINGTALK_RES;
ICBindDingTalkRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICBindDingTalkRES"

-- @param serverId: number
-- @param callback: number
function ICBindDingTalkRES:ctor(serverId, callback)
    self.super.ctor(self, ICBindDingTalkRES.OP_CODE, serverId, callback);
end

--------------------------新老账号互通----------------------
-- 请求账号互通
local CIAccountHuTongCodeREQ = class("CIAccountHuTongCodeREQ", ProtocolBase)
ns.CIAccountHuTongCodeREQ = CIAccountHuTongCodeREQ

CIAccountHuTongCodeREQ.OP_CODE = net.ProtocolCode.P_CI_ACCOUNT_HUTONG_REQ;
CIAccountHuTongCodeREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIAccountHuTongCodeREQ"
-- @param serverId: number
-- @param callback: number
function CIAccountHuTongCodeREQ:ctor(serverId, callback)
	self.super.ctor(self, CIAccountHuTongCodeREQ.OP_CODE, serverId, callback);
end

function CIAccountHuTongCodeREQ:setData(roleId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roleId = roleId;
end

-- 请求账号互通回复
local ICAccountHuTongCodeRES = class("ICAccountHuTongCodeRES", ProtocolBase)
ns.ICAccountHuTongCodeRES = ICAccountHuTongCodeRES

ICAccountHuTongCodeRES.OP_CODE = net.ProtocolCode.P_IC_ACCOUNT_HUTONG_RES;
ICAccountHuTongCodeRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICAccountHuTongCodeRES"

-- @param serverId: number
-- @param callback: number
function ICAccountHuTongCodeRES:ctor(serverId, callback)
    self.super.ctor(self, ICAccountHuTongCodeRES.OP_CODE, serverId, callback);
end


-- 请求互通
local CIAccountHuTongByCodeREQ = class("CIAccountHuTongByCodeREQ", ProtocolBase)
ns.CIAccountHuTongByCodeREQ = CIAccountHuTongByCodeREQ

CIAccountHuTongByCodeREQ.OP_CODE = net.ProtocolCode.P_CI_ACCOUNT_HUTONG_BY_CODE_REQ;
CIAccountHuTongByCodeREQ.CLZ_CODE = "com.kodgames.message.proto.auth.CIAccountHuTongByCodeREQ"
-- @param serverId: number
-- @param callback: number
function CIAccountHuTongByCodeREQ:ctor(serverId, callback)
	self.super.ctor(self, CIAccountHuTongByCodeREQ.OP_CODE, serverId, callback);
end

function CIAccountHuTongByCodeREQ:setData(code,newRoleId,bAuto)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.code = code;
	protocolBuf.newRoleId = newRoleId;
	protocolBuf.autoFlag = bAuto
end

-- 请求互通回复
local ICAccountHuTongByCodeRES = class("ICAccountHuTongByCodeRES", ProtocolBase)
ns.ICAccountHuTongByCodeRES = ICAccountHuTongByCodeRES

ICAccountHuTongByCodeRES.OP_CODE = net.ProtocolCode.P_IC_ACCOUNT_HUTONG_BY_CODE_RES;
ICAccountHuTongByCodeRES.CLZ_CODE = "com.kodgames.message.proto.auth.ICAccountHuTongByCodeRES"

-- @param serverId: number
-- @param callback: number
function ICAccountHuTongByCodeRES:ctor(serverId, callback)
    self.super.ctor(self, ICAccountHuTongByCodeRES.OP_CODE, serverId, callback);
end