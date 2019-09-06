local ns = namespace("config")

local UrlConfig = class("UrlConfig")
ns.UrlConfig = UrlConfig;

--appid
UrlConfig.AppId = "wx4330c6dd6db846dc"				--正式appid
UrlConfig.testAppId = "wx92cca06b0a446257"			--测试appid

--域名
UrlConfig.FieldName = "http://agtzf.gztr.gymjnxa.com"		--正式域名1
-- UrlConfig.FieldName2 = "http://agtzf.gzgy.majiang01.com"	--正式域名2
UrlConfig.testFieldName = "http://test.agtzf.gzgy.gymjnxa.com"		--测试域名

--判定是否是正式服，返回true为正式服，否则为测试服
local function isPublicServer()
	local startupParameter = nil
	local parameter = game.plugin.Runtime.getStartupParameter()
	if parameter then
		local jsonstr = loho.decodeConfigure(parameter)
		startupParameter = json.decode(jsonstr)
	end
	 -- 处理启动参数
	 if startupParameter then
		-- 默认链接IP
		local serverIp = startupParameter["ip"]
		if serverIp ~= "" then
			return false
		else
			return true
		end		
	end
	if device.platform == "windows" then
		return false
	else
		return true
	end
end

-- 单纯获取 WeChat AppId
function UrlConfig.getAppId()
	if isPublicServer() then
		return UrlConfig.AppId
	else
		return UrlConfig.testAppId
	end
end

--获取收集登录信息上传url
function UrlConfig.getUploadFirstInUrl()
	local gameFirstInInfoUrl = "https://outside.logcollector.majiang01.com/logcollector/data"
	local testGameFirstInInfoUrl = "https://test.outside.logcollector.majiang01.com/logcollector/data"
	if isPublicServer() then
		release_print("gameFirstInInfoUrl~~~~~~")
		return gameFirstInInfoUrl
	else
		release_print("testGameFirstInInfoUrl~~~~~~")
		return testGameFirstInInfoUrl
	end
end

--获取拆红包url
function UrlConfig.getRedPackUrl()
	-- 正式参数
    local redirect_uri = UrlConfig.FieldName.."/wechattools/helpRedpacket/auth"
    local return_uri = UrlConfig.FieldName.."/open"
    --测试参数
    local test_redirect_uri = UrlConfig.testFieldName .. "/wechattools/helpRedpacket/auth"
    local test_return_uri = UrlConfig.testFieldName .. "/open"

    local strUrl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%d*%s*%s*%s*%s"
    local localPlayerService = game.service.LocalPlayerService:getInstance()
    
	if isPublicServer() then
		strUrl = string.format(strUrl,UrlConfig.AppId, redirect_uri, localPlayerService:getArea(), localPlayerService:getUnionId(), string.urlencode(localPlayerService:getName()), localPlayerService:getIconUrl(),return_uri)
	else
		strUrl = string.format(strUrl,UrlConfig.testAppId, test_redirect_uri, localPlayerService:getArea(), localPlayerService:getUnionId(), string.urlencode(localPlayerService:getName()), localPlayerService:getIconUrl(),test_return_uri)
	end
	return strUrl
end

--获取年报url
function UrlConfig.getYearReportUrl() 
	local redirect_uri = UrlConfig.testFieldName .."/wechattools/annualSummary_share"
	local test_redirect_uri = UrlConfig.testFieldName .."/wechattools/annualSummary_share"	

	local strUrl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%s*http://agtzf.gzgy.majiang01.com/annals*%s"
		
	if isPublicServer() then
		strUrl = string.format( strUrl, UrlConfig.AppId, redirect_uri, game.service.LocalPlayerService.getInstance():getArea(),game.service.LocalPlayerService.getInstance():getRoleId())
	else
		strUrl = string.format( strUrl, UrlConfig.testAppId, test_redirect_uri, game.service.LocalPlayerService.getInstance():getArea(),game.service.LocalPlayerService.getInstance():getRoleId())
	end
	return strUrl
end

--获取名片功能url
function UrlConfig.getBusinessCardUrl()
	-- 正式参数
   	local strUrl = ""
	if isPublicServer() then
		strUrl = UrlConfig.FieldName .. "/personalcard/detailRecord?areaid=%s&roomId=%s&roomCreateTime=%s&clubId=%s"
	else
		strUrl = UrlConfig.testFieldName .. "/personalcard/detailRecord?areaid=%s&roomId=%s&roomCreateTime=%s&clubId=%s"
	end
	return strUrl
end

--获取二维码Url
function UrlConfig.getTwoDimensionUrl(source)
	local redirect_uri = UrlConfig.FieldName.."/wechattools/bind_invite.do"	
	local test_redirect_uri = UrlConfig.testFieldName .. "/wechattools/bind_invite.do"

	local State = game.service.LocalPlayerService:getInstance():getArea().."*"..game.service.LocalPlayerService:getInstance():getRoleId().."*"..source

	local urlPath = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%s"
	if isPublicServer() then
		urlPath = string.format( urlPath, UrlConfig.AppId, redirect_uri, State)
	else
		urlPath = string.format( urlPath, UrlConfig.testAppId, test_redirect_uri, State)
	end
	return urlPath	
end

function UrlConfig:getComebackActivityUrl()
	if isPublicServer() then
		return UrlConfig.FieldName .. "/wechattools/back_share"
	else
		return UrlConfig.testFieldName .. "/wechattools/back_share"
	end
end

-- 俱乐部微信邀请的参数
function UrlConfig.getClubWeChatParameter()
	if isPublicServer() then
		return string.format("%s", UrlConfig.FieldName)
	else
		return string.format("%s", UrlConfig.testFieldName)
	end
end

-- 钉钉参数
function UrlConfig.getDingTalkParameter(areaId)
	if areaId ==  10002 then
		local field = "test.servicebus.callback.majiang01.com"
		local appid = "dingoamy4bvwv32ek5hduw"
		if isPublicServer() then
			field = "servicebus.callback.majiang01.com"
			appid = "dingoaui3nsa2bi3nxynjk"
		end
		return {appid = appid, redirect_uri = string.format("http://%s:8060/html/dingtalklogin.html", field)}
	elseif areaId ==  20001 then
		local field = "test.servicebus.callback.majiang01.com"
		if isPublicServer() then
			field = "servicebus.callback.majiang01.com"
		end
		return {appid = "dingoa5zhd0hgvnrssn55k", redirect_uri = string.format("http://%s:8060/html/dingtalklogin.html", field)}
	else
		return {appid = "", redirect_uri = ""}
	end
end

-- 回流活动
function UrlConfig.getComebackInviteUrl()
	-- 正式参数
    local strUrl = ""
	if isPublicServer() then
		strUrl = UrlConfig.FieldName .. "/wechattools/share_activity.do"
	else
		strUrl = UrlConfig.testFieldName .. "/wechattools/share_activity.do"
	end
	return strUrl
end

--配置地址
function UrlConfig.getConfigServer()
	if isPublicServer() then
		return "http://out.configserver.majiang01.com/client/v1/config?areaId=%s&configName=%s&version=%s"
	else
		return "http://test.out.configserver.majiang01.com/client/v1/config?areaId=%s&configName=%s&version=%s"
	end
end

--BI地址
function UrlConfig.getBIUrl(...)
	local t = {...}
	local strUrl = ""
	if isPublicServer() then
		strUrl = "https://outside.logcollector.majiang01.com/logcollector/bi?table=%s"
	else
		--strUrl = "http://172.16.2.126:9020/logcollector/bi?table=%s"
        strUrl = "https://test.outside.logcollector.majiang01.com/logcollector/bi?table=%s"
	end
	if #t > 0 then
		strUrl = string.format(strUrl, ...)
	end
	return strUrl
end

--userEvent上传地址
function UrlConfig.getUserEventUrl()
	local strUrl = ""
	if isPublicServer() then
		strUrl = "https://outside.logcollector.majiang01.com/logcollector/compressFileUpload?areaid=%d&playerid=%d&table=client_action&"
	else
        strUrl = "https://test.outside.logcollector.majiang01.com/logcollector/compressFileUpload?areaid=%d&playerid=%d&table=client_action&"
	end
	return strUrl
end