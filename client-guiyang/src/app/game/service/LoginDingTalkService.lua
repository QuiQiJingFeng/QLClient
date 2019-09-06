local LoginDingTalkService = class("LoginDingTalkService")
local h5login = require("app.game.service.h5login")
--[[
    关于钉钉有关的协议在此注册
]]

function LoginDingTalkService:ctor()
    -- 绑定事件系统
	cc.bind(self, "event");

    self._h5login = h5login.new()
end

function LoginDingTalkService:initialize()
    self._h5login:initialize()

    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.ICBindDingTalkRES.OP_CODE, self, self._onICBindDingTalkRES)
end

function LoginDingTalkService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    self._h5login:dispose()
    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 绑定钉钉
function LoginDingTalkService:bindDingTalk()
    self._h5login:login(function(params, str)
        Logger.debug("bindDingTalk()   code = %s", params.code)
        self:dispatchEvent({ name = "EVENT_DING_TALK_BUTTON_STATUS_CHAGE" })
        self:_sendCIBindDingTalkREQ(params.code)
    end)
end

-- 钉钉登录
function LoginDingTalkService:loginDingTalk()
    self._h5login:login(function(params, str)
        Logger.debug("loginDingTalk()   code = %s", params.code)
        self:dispatchEvent({ name = "EVENT_DING_TALK_BUTTON_STATUS_CHAGE" })
        game.service.LoginService:getInstance():loginAuthWithCode(config.GlobalConfig.getLoginChannel().dingtalk, params.code)
    end)
end

-- 钉钉绑定
-- code 钉钉授权码
function LoginDingTalkService:_sendCIBindDingTalkREQ(code)
    -- 地区id
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    -- 玩家显示id
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local request = net.NetworkRequest.new(net.protocol.CIBindDingTalkREQ, 0)
    request:getProtocol():setData(roleId, code, areaId)
    game.util.RequestHelper.request(request)
end

-- 钉钉绑定返回
function LoginDingTalkService:_onICBindDingTalkRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- local request = response:getRequest()
    if protocol.result == net.ProtocolCode.AI_BIND_DINGTALK_SUCCESS then
        game.service.LocalPlayerService:getInstance():setIsBindDingTalk(true)
        game.ui.UIMessageTipsMgr.getInstance():showTips("绑定成功")
        self:dispatchEvent({ name = "EVENT_BING_DING_TALK_CHANGE" })
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

return LoginDingTalkService
