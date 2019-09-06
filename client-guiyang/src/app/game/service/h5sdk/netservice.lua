
--[[
    主要是处理H5交互相关的一些网络数据处理
    生存周期依旧是基于localplayer
]]
local netservice = class("netservice")

function netservice:ctor()
    self._accessTokenCallback = nil
    self._paymentCallback = nil
    self._onlineTimer = nil
    self._parsedUrl = nil
end

function netservice:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCQueryH5AccessTokenRES.OP_CODE, self, self._onGCQueryH5AccessTokenRES);
	requestManager:registerResponseHandler(net.protocol.GCQueryH5PayUrlRES.OP_CODE, self, self._onGCQueryH5PayUrlRES);
	requestManager:registerResponseHandler(net.protocol.GCUploadH5BIRES.OP_CODE, self, self._onGCUploadH5BIRES);
end

function netservice:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
    if self._onlineTimer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._onlineTimer)
        self._onlineTimer = nil
    end
end

-------------------------   设置相关回调    -------------------------
--[[
    设置H5登陆的回调，收到服务器返回后的处理
]]
function netservice:setAccessTokenCallback(callback)
    self._accessTokenCallback = callback
end

--[[
    设置支付请求后的回调
]]
function netservice:setPaymentCallback(callback)
    self._paymentCallback = callback
end

-------------------------       登陆相关    -------------------------
--[[
    请求H5登陆
]]
function netservice:sendCGQueryH5AccessTokenREQ(appkey)
    local request = net.NetworkRequest.new(net.protocol.CGQueryH5AccessTokenREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(appkey)
    game.util.RequestHelper.request(request)
    Logger.debug("===========send request   [accessToken]")
end

--[[
    请求H5登陆的返回
]]
function netservice:_onGCQueryH5AccessTokenRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_QUERY_H5_ACCESS_TOKEN_SUCCESS then
        -- 登陆信息查询成功
        Logger.debug("===========success    [accessToken]")
    else
        -- 错误提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
        Logger.debug("===========fail       [accessToken]")
    end

    if self._accessTokenCallback then
        self._accessTokenCallback(protocol.result == net.ProtocolCode.GC_QUERY_H5_ACCESS_TOKEN_SUCCESS, protocol.loginUrl)
    end
end

-------------------------       支付相关    -------------------------
--[[
    请求H5登陆
]]
function netservice:sendCGQueryH5PayUrlREQ(prepayId)
    local request = net.NetworkRequest.new(net.protocol.CGQueryH5PayUrlREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(prepayId)
    game.util.RequestHelper.request(request)
    Logger.debug("===========send request   [payment]")
end

--[[
    请求H5登陆的返回
]]
function netservice:_onGCQueryH5PayUrlRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_QUERY_H5_PAY_URL_SUCCESS then
        -- 登陆信息查询成功
        Logger.debug("===========success    [payment]")
    else
        -- 错误提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
        Logger.debug("===========fail       [payment]")
    end

    local url = ""
    if protocol.toPayUrl ~= nil and protocol.toPayUrl ~= "" then
        url = protocol.toPayUrl
    else
        url = "http://agtzf.gzgy.gymjnxa.com:8110/plug_in/wxpay?isapp=true&payto=" .. string.urlencode(protocol.payUrl)
    end
    if self._paymentCallback then
        self._paymentCallback(protocol.result == net.ProtocolCode.GC_QUERY_H5_PAY_URL_SUCCESS, url)
    end
end

-------------------------       BI相关    -------------------------
--[[
    @desc: 向服务器发送h5报过来的log
    author:{author}
    time:2018-08-16 15:03:03
    --@log: 
    @return:
]]
function netservice:sendBILog(log)
    local accessToken = self:_getParams('access_token')
    if accessToken == nil then
        return
    end

    -- log 中添加roleId和areaId
    log["roleId"] = game.service.LocalPlayerService.getInstance():getRoleId()
    log["areaId"] = game.service.LocalPlayerService:getInstance():getArea()

    local request = net.NetworkRequest.new(net.protocol.CGUploadH5BIREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(accessToken, json.encode(log))
    game.util.RequestHelper.request(request)
end

local _genTimer = function()
	local i = 0
	return function()
		i = i + 1
		return i
	end
end

--[[
    @desc: 游戏开始后，开一个计时器每分钟向服务器报告活着
    author:{author}
    time:2018-08-16 15:03:21
    @return:
]]
function netservice:gameStarted(url)
    self:_clearOnlineTimer()
    self._parsedUrl = self:_parseUrl(url)
    local timer = _genTimer()
    self._onlineTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            local currentTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
            local log = {
                type = "duration",
                custom = {
                    time = os.date("%Y-%m-%d %H:%M:%S", currentTime/1000),
                    duration = timer()
                }
            }
            self:sendBILog(log)
        end, game.globalConst.Chuanqi_BI_Time, false)
end

--[[
    @desc: 死了
    author:{author}
    time:2018-08-16 15:10:16
    @return:
]]
function netservice:gameExited()
    self:_clearOnlineTimer()
	local currentTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    local log = {
        type = "logout",
        custom = {
            time = os.date("%Y-%m-%d %H:%M:%S", currentTime/1000)
        }
    }
    self:sendBILog(log)

    self._parsedUrl = nil
end

function netservice:_onGCUploadH5BIRES( response )
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_UPLOAD_H5_BI_SUCCESS then
        -- 登陆信息查询成功
        Logger.debug("===========success    [_onGCUploadH5BIRES]")
    else
        -- 错误提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
        Logger.debug("===========fail       [_onGCUploadH5BIRES]")
    end
end

--[[
    @desc: 清掉timer
    author:{author}
    time:2018-08-21 17:49:44
    @return:
]]
function netservice:_clearOnlineTimer()
    if self._onlineTimer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._onlineTimer)
        self._onlineTimer = nil
    end
end

--[[
    @desc: 解析url，把参数放到params里
    author:{author}
    time:2018-08-20 16:14:12
    --@url: 游戏链接
    @return: 解析好的数据
]]
function netservice:_parseUrl(url)
    local p = kod.util.Http.parseUrl(url)
    local params = {}
    for i, v in ipairs(string.split(p.query,"&")) do
        local val = string.split(v,"=")
        params[val[1]] = val[2]
    end
    p.params = params
    return p
end

--[[
    @desc: 获取链接里的参数
    author:{author}
    time:2018-08-20 16:13:40
    --@key: 参数名(url里的)
    @return: 值
]]
function netservice:_getParams(key)
    if self._parsedUrl ~= nil then
        if self._parsedUrl.params ~= nil then
            return self._parsedUrl.params[key]
        end
    end
    return nil
end

return netservice
