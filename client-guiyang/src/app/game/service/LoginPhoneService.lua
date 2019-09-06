local LoginPhoneService = class("LoginPhoneService")

--[[
    关于手机验证有关的协议在此注册
        1.手机绑定登录（等待重构）
        2.新老帐号关联
]]

function LoginPhoneService:ctor()
    -- 绑定事件系统
	cc.bind(self, "event");
end

function LoginPhoneService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.GCQueryPlayerInfoRES.OP_CODE, self, self._onGCQueryPlayerInfoRES)
    requestManager:registerResponseHandler(net.protocol.ICBindOldPlayerRES.OP_CODE, self, self._onICBindOldPlayerRES)
end

function LoginPhoneService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)

    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 验证手机号是否正确
function LoginPhoneService:isVerificationPhone(phone)
    if phone == "" then return false end
    -- 手机号正则：^1\d{10}$
    return string.match(phone,"[1]%d%d%d%d%d%d%d%d%d%d") == phone
end

-- 验证微信号是否正确
function LoginPhoneService:isVerificationWeChat(weChat)
    if weChat == "" then return false end
    -- 微信号正则：^[a-zA-Z][-_a-zA-Z0-9]{5,19}$
    if string.match(weChat,"[%a][%-%_%w]+") == weChat then
        local len = string.len(weChat)
        return len > 5 and len < 21
    end

    return false
end

-- 获取手机验证码类型
function LoginPhoneService:getCodeType()
    local codeType =
    {
        TYPE_BIND = 1, -- 手机号绑定
        TYPE_CHANGE = 2, -- 手机号更换
        TYPE_UNTIED = 3, -- 手机号解绑
        TYPE_PHONE_LOGIN = 4, -- 手机登录
        TYPE_BIND_OLD_ROLEID = 5, -- 帐号关联
    }
    
    return codeType
end

-- 请求老帐号信息
function LoginPhoneService:sendCIQueryPlayerInfoREQ(oldBindPhone, verifyCode, area)
    local request = net.NetworkRequest.new(net.protocol.CIQueryPlayerInfoREQ, 0)
    request:getProtocol():setData(oldBindPhone, verifyCode, area)
    request.oldBindPhone = oldBindPhone
    game.util.RequestHelper.request(request)
end

-- 返回老帐号信息
function LoginPhoneService:_onGCQueryPlayerInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest()
    if protocol.result == net.ProtocolCode.AI_QUERY_PLAYER_SUCCESS then
        local oldPlayerInfo =
        {
        oldRoleId = protocol.oldRoleId,			-- 老的账号id
        -- nowRoleId = protocol.nowRoleId,			-- 现在的的账号id
        oldName = protocol.oldName,             -- 老的帐号昵称
        cardNum = protocol.cardNum,				-- 钻石数量
        -- time = protocol.time,				    -- 时间
        sign = protocol.sign,				    -- 加密字段
        phone = request.oldBindPhone,           -- 手机号
        }
        self:dispatchEvent({ name = "EVENT_OLDPLAYERINFO", oldPlayerInfo = oldPlayerInfo})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

-- 请求绑定老帐号
function LoginPhoneService:sendCIBindOldPlayerREQ(sign, phone)
    local request = net.NetworkRequest.new(net.protocol.CIBindOldPlayerREQ, 0)
    request:getProtocol():setData(sign, phone)
    game.util.RequestHelper.request(request)
end

-- 绑定结果
function LoginPhoneService:_onICBindOldPlayerRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.AI_BIND_OLD_PLAYER_SUCCESS then
        -- 绑定成功,重新登陆
        game.ui.UIMessageBoxMgr.getInstance():show("账号已关联成功，请重新登录游戏", {"重新登录"}, function()
            local serverId = game.service.LocalPlayerService.getInstance():getGameServerId();
            game.service.LoginService.getInstance():logout(serverId);
        end, function() end, true)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

return LoginPhoneService
