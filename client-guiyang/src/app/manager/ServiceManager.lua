local ns = namespace("manager")

---------------------
-- 游戏过程状态基类
---------------------
local ServiceManager = class("ServiceManager")
ns.ServiceManager = ServiceManager

-------------------------
-- 单例支持
local _instance = nil;

-- @return boolean
function ServiceManager.create()
    if _instance ~= nil then
        return false;
    end

    _instance = ServiceManager.new();
	_instance:initialize()
    return true;
end

function ServiceManager.destroy()
    if _instance == nil then
        return;
    end

    _instance:dispose();
    _instance = nil;
end

function ServiceManager.getInstance()
    return _instance;
end

--------------------------
function ServiceManager:ctor()
	self._connectionService = game.service.ConnectionService.new();
	self._waitingService = game.service.WaitingService.new();
    self._loginService = game.service.LoginService.new();
    self._updateService = game.service.UpdateService.new()
    self._weChatService = game.service.WeChatService.new()
    self._dingTalkService = game.service.DingTalkService.new()
	self._rtVoiceService	= game.service.RT_VoiceService:new();
    -- self._magicWindowService = game.service.MagicWindowService.new();
    self._meiQiaService = game.service.MeiQiaService.new();
    self._IAPService = game.service.IAPService.new();
    self._GetuiService = game.service.GetuiService.new();
	-- self._imVoiceService = game.service.IM_VoiceService.new();
	self._dataEyeService = game.service.DataEyeService.new();
	self._amapService = game.service.AMapService.new();
	self._tdAdTrackingService = game.service.TDAdTrackingService.new();
	self._jPushService = game.service.JPushService.new();
	self._tdGameAnalyticsService = game.service.TDGameAnalyticsService.new();
    self._webViewService = game.service.WebViewService.new()
    self._localPlayerService = game.service.LocalPlayerService.new()
end

function ServiceManager:initialize()
	self._connectionService:initialize();
	self._waitingService:initialize();
    self._weChatService:initialize()
    self._dingTalkService:initialize()
    self._updateService:initialize()
    self._dataEyeService:initialize();
	self._rtVoiceService:initialize();
    -- self._magicWindowService:initialize();
    self._meiQiaService:initialize();
    self._IAPService:initialize();
    self._GetuiService:initialize();
	-- self._imVoiceService:initialize();
	self._amapService:initialize();
    self._loginService:initialize();
	self._tdAdTrackingService:initialize();
	self._jPushService:initialize();
	self._tdGameAnalyticsService:initialize();
	self._webViewService:initialize()
    self._localPlayerService:initialize();
end

function ServiceManager:dispose()
    self._localPlayerService:dispose();
	self._connectionService:dispose();
	self._waitingService:dispose();
    self._loginService:dispose();
    self._updateService:dispose()
    self._weChatService:dispose()
    self._dingTalkService:dispose()
	self._rtVoiceService:dispose();
    -- self._magicWindowService:dispose();
    self._meiQiaService:dispose();
    self._IAPService:dispose();
    self._GetuiService:dispose();
	self._dataEyeService:dispose();
	-- self._imVoiceService:dispose();
	self._amapService:dispose();
	self._tdAdTrackingService:dispose();
	self._jPushService:dispose();
	self._tdGameAnalyticsService:dispose();
	self._webViewService:dispose()
    self._localPlayerService:dispose();
end

function ServiceManager:getConnectionService()   	return self._connectionService; end
function ServiceManager:getWaitingService()    		return self._waitingService;	end
function ServiceManager:getLoginService()    		return self._loginService		end
function ServiceManager:getIconManagerService()    	return self._iconManagerService end
function ServiceManager:getUpdateService()    		return self._updateService 		end
function ServiceManager:getWeChatService()          return self._weChatService      end
function ServiceManager:getDingTalkService()        return self._dingTalkService    end
function ServiceManager:getRTVoiceService() 		return self._rtVoiceService;    end
function ServiceManager:getMagicWindowService()     return self._magicWindowService end
function ServiceManager:getMeiQiaService()          return self._meiQiaService      end
function ServiceManager:getIAPService()             return self._IAPService         end
function ServiceManager:getGetuiService()           return self._GetuiService       end
function ServiceManager:getDataEyeService()  		return self._dataEyeService     end
-- function ServiceManager:getIMVoiceService()   		return self._imVoiceService     end
function ServiceManager:getAMapService()   			return self._amapService     	end
function ServiceManager:getLocalPlayerService()    	return self._localPlayerService end
function ServiceManager:getTDAdTrackingService()    return self._tdAdTrackingService end
function ServiceManager:getJPushService()    		return self._jPushService 		end
function ServiceManager:getTDGameAnalyticsService() return self._tdGameAnalyticsService end
function ServiceManager:getWebViewService()         return self._webViewService     end


function ServiceManager:clearLocalPlayerData()
	if self._localPlayerService ~= nil then
		self._localPlayerService:clear();
	end
end