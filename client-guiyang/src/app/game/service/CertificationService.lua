local CertificationService = class("CertificationService")
local ns = namespace("game.service")
ns.CertificationService = CertificationService

-- 身份验证相关
-- 主要处理验证消息的收发，以及身份验证状态的存储
-- 单例
function CertificationService:getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getCertificationService()
    end

    return nil
end

function CertificationService:ctor()
    -- 身份证认证状态
    self._certificationStatus = false
    -- 绑定事件系统
	cc.bind(self, "event");
	-- 验证码互通的码
	self._code = ""
end

function CertificationService:getCode()
	return self._code
end

-- 获取验证状态
function CertificationService:getCertificationStatus()
	return self._certificationStatus
end

-- 验证状态的设置
function CertificationService:setCertificationStatus(value)
 	self._certificationStatus = value 
end

function CertificationService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCIdentityVerifyRES.OP_CODE, self, self._onIdentityVerifyRES);
	requestManager:registerResponseHandler(net.protocol.ICAccountHuTongCodeRES.OP_CODE, self, self._onICAccountHuTongCodeRES);
	requestManager:registerResponseHandler(net.protocol.ICAccountHuTongByCodeRES.OP_CODE, self, self._onICAccountHuTongByCodeRES);
end

function CertificationService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 发送身份验证
function CertificationService:queryIdentityVerify(roleId, name, identity)
    local request = net.NetworkRequest.new(net.protocol.CGIdentityVerifyREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(roleId, name, identity);
    game.util.RequestHelper.request(request)
end

-- 验证消息的返回结果
function CertificationService:_onIdentityVerifyRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_IDENTITYVERIFY_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("认证成功！")
        self._certificationStatus = true
        UIManager:getInstance():hide("UICertification")
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
    
    self:dispatchEvent({name = "EVENT_VERIFIED_CHANGED"});
end


function CertificationService:CIAccountHuTongCodeREQ()
	local request = net.NetworkRequest.new(net.protocol.CIAccountHuTongCodeREQ, 0)
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getRoleId());
	game.util.RequestHelper.request(request)
end
function CertificationService:_onICAccountHuTongCodeRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.AI_ACCOUNT_HUTONG_SUCCESS then
		self._code = protocol.code
		game.plugin.Runtime.setClipboard(self._code)
		self:dispatchEvent({name = "EVENT_INTERFLOW_CODE_RECEIVE", code = protocol.code})
	else
		--game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
	
end



function CertificationService:CIAccountHuTongByCodeREQ(code, bAuto)
	local request = net.NetworkRequest.new(net.protocol.CIAccountHuTongByCodeREQ, 0)
	request:getProtocol():setData(code, game.service.LocalPlayerService:getInstance():getRoleId(), bAuto);
	game.util.RequestHelper.request(request)
end
function CertificationService:_onICAccountHuTongByCodeRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local request = response:getRequest()
	if protocol.result == net.ProtocolCode.AI_ACCOUNT_HUTONG_BY_CODE_SUCCESS then
		game.ui.UIMessageTipsMgr.getInstance():showTips("恭喜您完成更新，礼券奖励已发放至您的账户")
		self:dispatchEvent({name = "EVENT_INTERFLOW_BIND_SUCCESS"})
		-- dispatchGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND")
	elseif not request:getProtocol().bAuto then
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

return CertificationService 