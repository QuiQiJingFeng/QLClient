local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local LEVEL = {
	LOW 	= 1,
	MID 	= 2,
	HIGH 	= 3,
}

-- 游戏更新相关逻辑
local UpdateService = class("UpdateService")
ns.UpdateService = UpdateService

-- 单例支持
-- @return UpdateService
function UpdateService:getInstance()
	return manager.ServiceManager.getInstance():getUpdateService()
end

function UpdateService:ctor()
	self._libVersion = nil
	self._proVersion = nil
	self._isStartWorking = false
	self._useDownloader = false
	self._libDownloadDone = false
    self._productUpdateHostIp = nil
    self._productUpdateHost = nil
    self._productUpdateUrl = nil
end

local _minimumVersionUseDownloader = Version.new("4.1.2.0")
local _isOldAssetsManagerEx = cc.AssetsManagerEx.getInstance == nil
function UpdateService:initialize()
	-- 初始化assetsManager
	local writablePath = cc.FileUtils:getInstance():getAppDataPath()
    if _isOldAssetsManagerEx then
        local storagePath = writablePath .. "download" -- 旧AssetsManagerEx的包下载目录必定是download
    	self._assetsManager = cc.AssetsManagerEx:create(storagePath)
        self._assetsManager:retain()
    else
    	self._assetsManager = cc.AssetsManagerEx:getInstance()
    end
	net.RequestManager:getInstance():registerResponseHandler(net.protocol.ICVersionUpdateRES.OP_CODE, self, self._onCheckVersionRes)
end

function UpdateService:dispose()
    if _isOldAssetsManagerEx then self._assetsManager:release() end
	self._assetsManager = nil
end

function UpdateService:getProductVersion()
	return self._proVersion
end

function UpdateService:start()
	local _, prover = self._assetsManager:checkLocal()
	self._proVersion = Version.new(prover)
	self._libVersion = Version.new(game.plugin.Runtime.getBuildVersion())

    buglyAddUserValue("version", prover)

	-- 只有android版本才支持游戏内整包更新
	-- self._useDownloader = device.platform == "android" and self._libVersion:compare(_minimumVersionUseDownloader) >= 0
	self._useDownloader = false
	Logger.debug("useDownlaoder: " .. tostring(self._useDownloader))
	if not prover then
		self:done()
		return
	end
	self:_sendRequest()
end

function UpdateService:restart()
	self:_sendRequest()
end

function UpdateService:isStartWorking()
	return self._isStartWorking
end

function UpdateService:_sendRequest()
    -- modify by machicheng
    local roleId = game.service.LoginService.getInstance():getSavedRoleId() or 0
	local request = net.NetworkRequest.new(net.protocol.CIVersionUpdateREQ, 0)
	request:getProtocol():setData(
		tonumber(game.plugin.Runtime.getChannelId()),
		tonumber(game.plugin.Runtime.getSubChannelId()),
		self._libVersion:toString(),
        self._proVersion:toString(),
        roleId)
	game.util.RequestHelper.request(request)
end

function UpdateService:_reboot()
	-- UIManager有retain, 需要释放
	UIManager:getInstance():clear()
    if _isOldAssetsManagerEx then self._assetsManager:release() end
	loho.reboot()
end

function UpdateService:_rebootTalkingData()
	-- 统计游戏下载出错的次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.DownloadError_Click)
	
	self:_reboot()
end

function UpdateService:_onCheckVersionRes(response)	
	local protocol = response:getProtocol():getProtocolBuf()
	-- 关闭网络连接
	game.service.ConnectionService.getInstance():close()
    self._isStartWorking = true

    --[[
        1. 先检查是否是提审版本
        2. 检查是否要强制更新整包
        3. 检查是否被白名单拦截
        4. 检查是否需要走热更新
        5. 直接进游戏
    ]]

	if protocol.reviewVersion ~= "" and self._libVersion:compare(protocol.reviewVersion) == 0 then
		-- 审核版本
		GameMain.getInstance():setReviewVersion(true)
		-- 设置审核版服务器地址
		game.service.ConnectionService.getInstance():setConnectionType(net.ConnectionType.Intranet, protocol.reviewUrl)
		-- 重新请求
		self:_sendRequest()
	elseif protocol.rejectByWhiteList == true then
        game.ui.UIMessageBoxMgr.getInstance():show("服务器正在更新，请稍后登录!", {"确定"}, function()
            self:_sendRequest()
        end)
	elseif self._proVersion:compare(protocol.proVersion) < 0 then
    	-- 热更新资源
        self:performResourceUpdate(protocol)
	elseif self._proVersion:compare(protocol.proVersion) < 0 then
		-- 热更新资源
		self:performResourceUpdate(protocol)
	elseif tonumber(protocol.libVersion) == LEVEL.LOW
		or tonumber(protocol.libVersion) == LEVEL.MID
		or self._libVersion:compare(protocol.lastLibVersion) < 0 then
		-- 整包版本更新
		-- 这里不能改，不然不会再弹出已经下载好的提示
		if self._useDownloader then
			-- 安卓整包自下载时, 直接开始后台下载, 并延迟整包更新逻辑
            local url = string.trim(protocol.libUrl)
			self:_startBackgroundLibDownlaod(url)
			scheduleOnce(function()
				self:performFullUpdate(protocol)
			end, 0.1)
		else
			self:performFullUpdate(protocol)
        end    
	else
		-- 无更新
		self:done()
	end
end

function UpdateService:performFullUpdate(protocol)
	local isIOS = device.platform == "ios"
	
	local function confirmUpdate()
        local url = string.trim(protocol.libUrl)
		cc.Application:getInstance():openURL(url)
		return false
	end
	local function cancelUpdate()
		if self._proVersion:compare(protocol.proVersion) < 0 then
			self:performResourceUpdate(protocol)
		else
			-- 无更新
			self:done()
		end
	end
	-- 安卓整包自下载
	local function confirmUpdateDownloader()
        local url = string.trim(protocol.libUrl)
		self:_startForegroundLibDownlaod(url)			
	end
	-- 安装整包安装
	local function confirmInstall()
		game.plugin.Downloader.install(string.trim(protocol.libUrl))
		self:_reboot()
	end

    if self._libVersion:compare(protocol.lastLibVersion) < 0 then -- 整包强更
		if self._libDownloadDone then -- 已后台下好
			game.ui.UIMessageBoxMgr.getInstance():show("新版本已下载完成, 请点击安装", {"立即安装"}, confirmInstall, nil, true)
		else
			UIManager:getInstance():show("UIUpdateBS", protocol.updateNotice, isIOS, self._useDownloader and confirmUpdateDownloader or confirmUpdate)
		end
	elseif self._libDownloadDone then -- 整包非强更但已后台下载完成
		-- 已下好状态无提示间隔
		game.ui.UIMessageBoxMgr.getInstance():show("新版本已下载完成, 是否立即安装", {"安装","取消"}, confirmInstall, cancelUpdate)
	else -- 整包非强更
		local now = kod.util.Time.now()
		local lastPromptTime = game.service.GlobalSetting.getInstance().versionPromptTime
		local newTime = now
		local oldTime = lastPromptTime
		local nday = math.floor(newTime/(3600*24))
		local oday = math.floor(oldTime/(3600*24))
	
		local nweek = tonumber(os.date("%w", os.time()))
		nweek = nweek == 0 and nweek + 7 or nweek
		local oweek = tonumber(os.date("%w", oldTime))
		oweek = oweek == 0 and oweek + 7 or oweek

		-- 如果天发生了变化
		if (tonumber(protocol.libVersion) == LEVEL.LOW and (nday ~= oday))
		-- 如果周发生了变化，并最终全部统一到周一提示更新
		or (tonumber(protocol.libVersion) == LEVEL.MID and (nday-oday>=7 or nweek < oweek)) then
			-- 弹出提示更新
			UIManager:getInstance():show("UIUpdateBS", protocol.updateNotice, isIOS,
				self._useDownloader and confirmUpdateDownloader or confirmUpdate, function()
				game.service.GlobalSetting.getInstance().versionPromptTime = now
				game.service.GlobalSetting.getInstance():saveSetting()
				cancelUpdate()
			end)
		else
			cancelUpdate()
		end
    end
end

function UpdateService:performResourceUpdate(protocol)
	-- 设置下载消息listener
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local eventListenerAssetsManagerEx = cc.EventListenerAssetsManagerEx:create(self._assetsManager, handler(self, self._onAssetsManagerExEvent))
    dispatcher:addEventListenerWithFixedPriority(eventListenerAssetsManagerEx, 1)
	-- 下载出错重试次数
	self._retryTimes = 0
	-- 开始下载资源
	local baseUrl = string.trim(protocol.proUrl)
	if baseUrl:sub(-1) ~= "/" then baseUrl = baseUrl .. "/" end

	Logger.debug("Perform resources updating from URL: " .. baseUrl)
    self._productUpdateUrl = baseUrl

    local parsed = kod.util.Http.parseUrl(baseUrl)
    if parsed then
        self._productUpdateHost = parsed.host
    end
    self._assetsManager:update(baseUrl)
	UIManager:getInstance():getUI("UILaunch"):setProgress(0)
	UIManager:getInstance():getUI("UILaunch"):hideCheckVersionText()
end

local ERROR_FILE_CRC = 1
function UpdateService:_onAssetsManagerExEvent(event)
	local rebootFunc = handler(self, self._reboot)
	local rebootFunc_TalkingData = handler(self, self._rebootTalkingData)
	local eventCode = event:getEventCode()
	if eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
        local assetId = event:getAssetId()
        local percent = event:getPercent()
        if assetId == cc.EventAssetsManagerEx.MANIFEST_ID then
			Logger.debug("Manifest file: %.2f%%", percent)
        else
			Logger.debug("Resources updating: %.2f%%", percent)
			UIManager:getInstance():getUI("UILaunch"):setProgress(percent)
        end
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
        Logger.debug("UPDATE_FINISHED")
		--game.ui.UIMessageBoxMgr.getInstance():show("更新完成, 重新启动", {"确定"}, rebootFunc)
		UIManager:getInstance():getUI("UILaunch"):setProgress(100)
		scheduleOnce(rebootFunc, 0.1)
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
		Logger.debug("UPDATE_FAILED")
		self._retryTimes = self._retryTimes + 1
		-- if self._retryTimes > 1 then
		game.ui.UIMessageBoxMgr.getInstance():show("下载出错，请重新下载", {"确定"}, rebootFunc_TalkingData)
		-- else
			-- 尝试下载出错的文件
			-- self._assetsManager:downloadFailedAssets()
		-- end
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
        Logger.debug("ERROR_DOWNLOAD_MANIFEST")
		game.ui.UIMessageBoxMgr.getInstance():show("下载出错，请重新下载", {"确定"}, rebootFunc_TalkingData)
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
        Logger.debug("ERROR_PARSE_MANIFEST")
		game.ui.UIMessageBoxMgr.getInstance():show("下载出错，请重新下载", {"确定"}, rebootFunc_TalkingData) 
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
		-- 单个文件下载出错
        Logger.debug("ERROR_UPDATING, file: %s", event:getAssetId())
		-- 若文件crc32错误上报bugly
		if not _isOldAssetsManagerEx and event:getErrorCode() == ERROR_FILE_CRC then
            self:_reportCRCError(event:getAssetId())
        end
    end
end

function UpdateService:_reportCRCError(assetId)    
    if self._productUpdateHostIp then
        Macro.assertTrue(true, "ERROR_FILE_CRC: %s, ip: %s", assetId, self._productUpdateHostIp)
    elseif self._productUpdateHost then
        self._productUpdateHostIp = ""
        loho.getAddrInfoAsync(self._productUpdateHost, function(addrinfo, err)
            if not err and addrinfo and #addrinfo > 0 then
                self._productUpdateHostIp = addrinfo[1].addr
            end
            Macro.assertTrue(true, "ERROR_FILE_CRC: %s, ip: %s", assetId, self._productUpdateHostIp)
        end)
    end

    --self:_uploadErrorContent(assetId)
end

--[[
function UpdateService:_uploadErrorContent(assetId)
    local fileUtils = cc.FileUtils:getInstance()
    local downloadDir = "download"
    if loho.getDownloadDir then downloadDir = loho.getDownloadDir() end

    -- CRC32错误时, 文件仍在临时目录
    local filePath = fileUtils:getAppDataPath() .. downloadDir .. "_temp/" .. assetId
    local file = io.open(filePath, "rb")
    if file then
        local content = "url:" .. tostring(self._productUpdateUrl) .. ";file:" .. assetId .. ";data:" .. file:read("*a")
        io.close(file)
        Logger.uploadFile(content, "ERRCRC")
    end
end]]

function UpdateService:done()
	game.service.ConnectionService:getInstance():getConnection():removeEventListenersByTag(self)
    GameFSM.getInstance():enterState("GameState_Login")
end

-- 安卓后台整包下载
function UpdateService:_startBackgroundLibDownlaod(url)	
	game.plugin.Downloader.start(url, true, function(param_json) -- progress
		local param = json.decode(param_json)
		local percent = param["bytes"] / param["totalBytes"]
		Logger.debug("background percent = %.2f", percent)
	end, function(param_json) -- error
		local param = json.decode(param_json)
		Logger.debug("background error: %s", param["message"])
	end, function() -- completed
		Logger.debug("background completed")
		self._libDownloadDone = true
    end)
end

-- 安卓前台整包下载
function UpdateService:_startForegroundLibDownlaod(url)
	game.plugin.Downloader.stop()
	game.plugin.Downloader.start(url, false, function(param_json) -- progress
		local param = json.decode(param_json)
		local percent = param["bytes"] / param["totalBytes"] * 100
		UIManager:getInstance():getUI("UILaunch"):setProgress(percent)
	end, function() -- error
		game.ui.UIMessageBoxMgr.getInstance():show("下载出错，请重新下载", {"确定"}, handler(self, self._rebootTalkingData))
	end, function() -- completed
		game.plugin.Downloader.install(url)
		self:_reboot()
    end)
end

function UpdateService:clearDownloadedData()
    local fileUtils = cc.FileUtils:getInstance()
    local downloadDir = "download"
    if loho.getDownloadDir then downloadDir = loho.getDownloadDir() end
    local downloadPath = fileUtils:getAppDataPath() .. downloadDir .. "/"
    local downloadTempPath = fileUtils:getAppDataPath() .. downloadDir .. "_temp/"
    local succ = fileUtils:removeDirectory(downloadPath)
    Logger.debug("clearDownloadedData, removeDirectory %s %s", downloadPath, tostring(succ))
    succ = fileUtils:removeDirectory(downloadTempPath)
    Logger.debug("clearDownloadedData, removeDirectory %s %s", downloadTempPath, tostring(succ))
    self:_reboot()
end

return UpdateService