local AgentService = class("AgentService")
local ns = namespace("game.service")
ns.AgentService = AgentService

local Version = require "app.kod.util.Version"

local Agt_Status = {
    None = 1,   -- 不是代理
    Apply =2,   -- 申请中
    Agt = 3     -- 是代理
}
--[[
    EVENT_AGT_STATUS_CHANGED -- AGT状态变化通知
]]

function AgentService.getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getAgentService()
    end
    return nil
end

function AgentService:ctor()
    -- 绑定事件系统
	cc.bind(self, "event");
    self._isAgent = false
    self._agtPoot = ""
    self._agtStyle = 1
end

function AgentService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);

    -- 解绑事件系统
	cc.unbind(self, "event");
end

function AgentService:initialize()
    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.GCGetAgentInfoRES.OP_CODE, self, self._onGCGetAgentInfoRES);
    requestManager:registerResponseHandler(net.protocol.GCAgentStatusSYN.OP_CODE, self, self._sendGCAgentStatusSYN);
    requestManager:registerResponseHandler(net.protocol.GCGetAgtWebUrlRES.OP_CODE, self, self._onGCGetAgtWebUrlRES);
    requestManager:registerResponseHandler(net.protocol.GCQueryAgtInfoRES.OP_CODE, self, self._onGCQueryAgtInfoRES)
    requestManager:registerResponseHandler(net.protocol.GCApplyToAgtRES.OP_CODE, self, self._onGCApplyToAgtRES)
end

-- 请求代理商信息（用户点击代理商按钮时请求，客户端拿到数据后拉起webview）
function AgentService:_sendCGGetAgentInfoREQ()
    local request = net.NetworkRequest.new(net.protocol.CGGetAgentInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    game.util.RequestHelper.request(request)
end

function AgentService:_onGCGetAgentInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_GETAGENTINFO_SUCCESS then
        local localPlayerService = game.service.LocalPlayerService:getInstance()
        local roleName = self:encodeURL(localPlayerService:getName())
        local roleId = tostring(localPlayerService:getRoleId())
        
        local areaId = game.service.LocalPlayerService:getInstance():getArea();
        self:_openAGT(true, roleId, roleName, tostring(protocol.sTime), protocol.sign, areaId, self._agtStyle)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- AGT 推送
function AgentService:_sendGCAgentStatusSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    self:setIsAgency(protocol.status == Agt_Status.Agt)
end

function AgentService:_onGCGetAgtWebUrlRES( response )
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_GET_AGT_WEB_URL_SUCCESS then
        self._currentAvailableDomain = protocol.url
        self:_openWebView()
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
        self._currentAvailableDomain = nil
    end
end

--  lua urlencode urldecode URL编码
function AgentService:encodeURL(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function AgentService:getIsAgency()
    return self._isAgent
end

function AgentService:setIsAgency(value)
    self._isAgent = value
    self:dispatchEvent({ name = "EVENT_AGT_STATUS_CHANGED", isAgent = self._isAgent}); 
end

function AgentService:setAgtPoot(agtPoot)
    self._agtPoot = agtPoot
end

function AgentService:openWebView(agtStyle)
    -- 想服务器请求一个可用的域名
    self._agtStyle = agtStyle
    local request = net.NetworkRequest.new(net.protocol.CGGetAgtWebUrlREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    game.util.RequestHelper.request(request)
end

function AgentService:_openWebView()
    if self._isAgent then
        self:_sendCGGetAgentInfoREQ()
    else
        local localPlayerService = game.service.LocalPlayerService:getInstance()
        local roleName = self:encodeURL(localPlayerService:getName())
        local roleId = tostring(localPlayerService:getRoleId())
        
        local areaId = game.service.LocalPlayerService:getInstance():getArea()
        self:_openAGT(self._isAgent, roleId, roleName, areaId, self._agtStyle)
    end
end

function AgentService:_openAGT(...)
    local args = {...}
    local isAgent = args[1]
    table.remove( args, 1)
    -- 检查agt安全组开关
    local url = string.format(self:_getAgentUrl(isAgent, config.GlobalConfig.AGT_SECURITY_SWITCH), unpack(args))
    self._openURL(url)
end

function AgentService._openURL( url )
    -- 支持4.1.2.0以下支持Agt
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    if currentVersion:compare(Version.new("4.1.2.0")) >= 0 then
        game.service.WebViewService.getInstance():openWebView(url)
    else
        cc.Application:getInstance():openURL(url)
    end
end

 
function AgentService:_getAgentUrl(isAgent, security)
    -- 由安全组取出的域名和login时得到的poot拼接成最后的agt域名
    -- 如果是关闭安全组的状态，那么poot字段里就存的是domain
    local _domain = security and self._currentAvailableDomain or self._agtPoot
    if isAgent then
        return _domain .."/?roleid=%s&nickname=%s&isInGame=true&stime=%s&sign=%s&areaid=%s&entry=%s"
    else
        return _domain .. "/agent/?roleid=%s&nickname=%s&isInGame=true&areaid=%s&entry=%s"
    end
end

-- 请求Agt弹窗信息
function AgentService:sendCGQueryAgtInfoREQ()
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local request = net.NetworkRequest.new(net.protocol.CGQueryAgtInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(areaId)
    game.util.RequestHelper.request(request)
end

function AgentService:_onGCQueryAgtInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_QUERY_AGT_INFO_SUCCESS then
        if protocol.status == Agt_Status.Agt then
            game.ui.UIMessageTipsMgr.getInstance():showTips("您已经是代理了")
        elseif protocol.status == Agt_Status.Apply then            
            UIManager:getInstance():show("UIAgentHasApply", protocol.weChat)
        else
            local data =
            {
                weChat = protocol.weChat, -- 微信号
                sowingMapUrl = protocol.sowingMapUrl, -- 轮播图
            }
            self:dispatchEvent({ name = "EVENT_AGT_RECRUIT_CHANGED", recruitInfo = data});         
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

function AgentService:_onGCApplyToAgtRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest():getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_APPLY_TO_AGT_SUCCESS then
        self:applyForAgentByHttp( request.phone, request.weChat, protocol.sTime, protocol.sign)
    end
end

-- 
function AgentService:queryCGApplyToAgt(phone, weChat)
    local request = net.NetworkRequest.new(net.protocol.CGApplyToAgtREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(phone, weChat)
    game.util.RequestHelper.request(request)
end

-- http请求申请代理
function AgentService:applyForAgentByHttp( phone, wechat, sTime, sign)
    local url = self:_getApplyAgentDomain(config.GlobalConfig.AGT_SECURITY_SWITCH, phone, self:encodeURL(wechat), sTime, sign)

    dispatchGlobalEvent("EVENT_BUSY_RETAIN")
    kod.util.Http.sendRequest(url, {}, function(response, readyState, status)        
        dispatchGlobalEvent("EVENT_BUSY_RELEASE")
        if status == 200 then
            local param = json.decode(response)
            if param.code == 0 then
                UIManager:getInstance():destroy("UIAgentApply")
                --UIManager:getInstance():show("UIAgentHasApply")                
                UIManager:getInstance():destroy("UIRecruit")
                game.ui.UIMessageTipsMgr.getInstance():showTips("申请成功")
            else
                game.ui.UIMessageTipsMgr.getInstance():showTips(param.des)
            end
        else
            local state = "申请失败，错误码:" .. tonumber(status) or "nil"
            game.ui.UIMessageTipsMgr.getInstance():showTips(state)
        end
    end, "POST", nil)

    --[[
    -- 复制信息
    local text = string.format("你好，我已成功提交了代理申请\n手机：%s\n微信号：%s", phone, wechat)
    if game.plugin.Runtime.setClipboard(text) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end
    -- 把玩家手机号和微信号保存在本地
    local playersInfo = game.service.club.ClubService:getInstance():loadLocalStorageGamePlayInfo()
    playersInfo:getPlayerInfo(self._roleId).phone = phone
    playersInfo:getPlayerInfo(self._roleId).weChat = wechat
    game.service.club.ClubService:getInstance():saveLocalStorageGamePlayInfo(playersInfo)
    -- 跳转客服
    game.service.MeiQiaService:getInstance():openMeiQia()
    ]]
end

-- get domain
function AgentService:_getApplyAgentDomain(security, phone, wechat, sTime, sign)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId();
    local name = game.service.LocalPlayerService:getInstance():getName();

    local defaultUrl = security and self._currentAvailableDomain or self._agtPoot 
        .. "/agentboot/agent/client/apply/%s?id=%s&phone=%s&wechat=%s&name=%s&stime=%s&sign=%s"
    local url = string.format(defaultUrl, areaId, roleId, phone, wechat, self:encodeURL(name), sTime, sign)
    -- 获取domain域名前缀
    return url
end

function AgentService:encodeURL(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

return AgentService