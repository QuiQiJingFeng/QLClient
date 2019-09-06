local UploadLogService = class("UploadLogService")
local ns = namespace("game.service")
ns.UploadLogService = UploadLogService

-- 身份验证相关
-- 主要处理验证消息的收发，以及身份验证状态的存储
-- 单例
function UploadLogService:getInstance()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		return game.service.LocalPlayerService.getInstance():getUploadLogService()
	end
	
	return nil
end

function UploadLogService:ctor()
	self._needUpload = false
	self._updateTime = 0
	self._tryTime = 0
	self:initialize()
end


function UploadLogService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCUploadClientLogSYN.OP_CODE, self, self._onReceiveUpload);  --活动信息
	requestManager:registerResponseHandler(net.protocol.GCUploadClientLogRES.OP_CODE, self, self._onUploadSucceed);  --活动信息
end

function UploadLogService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

-- 上传成功，通知服务器
function UploadLogService:queryUpdateSucceed()
	local request = net.NetworkRequest.new(net.protocol.CGUploadClientLogREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

-- 接收活动信息
function UploadLogService:_onReceiveUpload(response)
	self._needUpload = true
	self:doUpload()
end


local ZIPLOGFILE_UPLOAD_URL = "https://outside.logcollector.majiang01.com/logcollector/errorlog/%d/%d"
function UploadLogService:_uploadZippedLogs(zipFilePath)
	local fileUtils = cc.FileUtils:getInstance()
	-- release_print("do upload 3333333333333333333333333333333333", zipFilePath)
	if zipFilePath and fileUtils:isFileExist(zipFilePath) then
		-- release_print("do upload 44444444444444444444444444444444444444", zipFilePath)
		local content = fileUtils:getStringFromFile(zipFilePath)
		release_print("zip file length:", string.len(content))
		if string.len(content) == 0 then
			self:doUpload(true)
			return
		end
        local url = string.format(ZIPLOGFILE_UPLOAD_URL, 
            game.service.LocalPlayerService:getInstance():getArea(),
            game.service.LocalPlayerService:getInstance():getRoleId())
		kod.util.Http.sendRequest(url, content, function(response, readyState, status)                        
           
			if status == 200 then
				fileUtils:removeFile(zipFilePath)				
                -- local text = string.format("日志已成功上传服务器(ID:%d)", game.service.LocalPlayerService:getInstance():getRoleId())
				-- game.ui.UIMessageBoxMgr.getInstance():show(text, { "确定" })
				-- release_print("do upload enddddddddddddddddddddddddddddddd", zipFilePath)
				if self._needUpload then 
					release_print("do upload succeedddddddddddddddddd", zipFilePath)
					self._needUpload = false
					self:queryUpdateSucceed()
				else
					game.ui.UIMessageTipsMgr.getInstance():showTips("上报成功，感谢反馈")
					release_print("do upload no dfjskafjlkdjsafkljasdfkljasdklfjklsj", zipFilePath)
				end
			else
				self._tryTime = self._tryTime - 1
				release_print("do upload failed~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",zipFilePath,self._tryTime)				
				if self._tryTime > 0 then
					release_print("try upload again~~~~~~~~~~~~~~~~~~~~")
					self:_uploadZippedLogs(zipFilePath)
				else
					fileUtils:removeFile(zipFilePath)
					self._needUpload = false
				end
            end
        end, "POST", "blob")
	end
end
function UploadLogService:doUpload(bForce)
	if not bForce then
		if not self._needUpload and kod.util.Time.now() - self._updateTime < 10 then
			game.ui.UIMessageTipsMgr.getInstance():showTips("请不要频繁操作")
			return
		end
		self._updateTime = kod.util.Time.now()
		if not self:canUpload() then
			game.ui.UIMessageTipsMgr.getInstance():showTips("上报成功，感谢反馈")
			return
		end
	end
	self._tryTime = 3

	local logFilePath = game.plugin.Runtime.getLogFilePath() .. "/"
    local maxLogFiles = 5
    local logFileName = "KodGame.Log"
    local previousLogFileName = "KodGamePre%d.Log"
	local fileUtils = cc.FileUtils:getInstance()
	release_print("do upload 11111111111111111111111111111111111111111")
	-- release_print("logFilePath:", logFilePath)
	-- release_print("logFileName:", logFileName)
	-- release_print("logFilePath .. logFileName", logFilePath .. logFileName)
	
    if fileUtils:isFileExist(logFilePath .. logFileName) then
        local zipFilePath = logFilePath .. os.date("%Y-%m-%d-%H-%M-%S.zip", os.time())
		local zf = loho.zipOpen(zipFilePath, 0)
		-- release_print(string.format("zf = %x", zf))
        loho.addFileToZip(zf, logFileName, logFilePath .. logFileName)
        for i = maxLogFiles - 1, 1, -1 do
            local preLogFileName = string.format(previousLogFileName, i)
            if fileUtils:isFileExist(logFilePath .. preLogFileName) then
                loho.addFileToZip(zf, preLogFileName, logFilePath .. preLogFileName)
            end
        end
        loho.zipClose(zf)
		-- release_print("do upload 22222222222222222222222222222222222222")
        self:_uploadZippedLogs(zipFilePath)
    end
end

function UploadLogService:canUpload()
	if loho.zipOpen then
		return true
	end
	return false
end

function UploadLogService:setNeedUpload(bNeed)
	self._needUpload = bNeed
end

function UploadLogService:_onUploadSucceed()
	-- todo nothing
end
return UploadLogService 