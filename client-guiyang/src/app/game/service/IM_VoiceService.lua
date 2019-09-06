--[[
语音消息模块

事件
EVENT_UPLOAD_FINISNED	url		上传完成事件
EVENT_PLAY_STARTED		roleId	下载完成,开始播放事件
EVENT_PLAY_FINISNED		roleId	播放完成事件
--]]

-- 临时文件保存路径
local FILE_DOWNLOAD_TEMP_PATH = cc.FileUtils:getInstance():getAppDataPath() .. "speech/"

local ns = namespace("game.service")

local IM_VoiceService = class("IM_VoiceService")
ns.IM_VoiceService = IM_VoiceService

-------------------------
-- 单例支持
function IM_VoiceService.getInstance()
	return manager.ServiceManager.getInstance():getIMVoiceService()
end

-------------------------
function IM_VoiceService:ctor()
	cc.bind(self, "event")
	self._recordIndex = 0
	self._canceledRecords = {}
	self._playRecords = {}

	-- 如果之后换sdk，只需要修改adapter即可
	self._adapter = game.service.YVVoiceService.getInstance()
end

function IM_VoiceService:initialize()
	if not self._adapter:isEnabled() then return end

	self._isDebug = true;

	self._adapter:initialize(FILE_DOWNLOAD_TEMP_PATH)
	
	-- 注册事件回调
	self._adapter:registerStopRecordListern( handler(self, self.onStopRecordListern) )
	self._adapter:registerFinishPlayListern( handler(self, self.onFinishPlayListern) )
	self._adapter:registerUpLoadFileListern( handler(self, self.onUpLoadFileListern) )
	self._adapter:registerDownloadVoiceListern( handler(self, self.onDownloadVoiceListern) )
end

function IM_VoiceService:dispose()
	cc.unbind(self, "event");
end

function IM_VoiceService:isEnabled()
	return self._adapter:isEnabled()
end

function IM_VoiceService:getFileType()	
	return _isDebug and ".amr" or "d.amr"
end

-- 登录
-- @param nickname:string	用户名称（由CP 自己提供）
-- @param uid:string		用户ID，（由CP 自己提供，请确保唯一性）
function IM_VoiceService:cpLogin(nickname, uid)
	Logger.debug("[IM_VoiceService] cpLogin,%s,%s", nickname, uid)
	self._adapter:cpLogin(nickname, uid)
end

-- 登出
function IM_VoiceService:cpLogout()
	Logger.debug("[IM_VoiceService] cpLogout");
	self._adapter:cpLogout()
end

-- 开始录音
function IM_VoiceService:startRecord()
	self._recordIndex = self._recordIndex + 1;
	local file = FILE_DOWNLOAD_TEMP_PATH..tostring(self._recordIndex)..self:getFileType();
	self._adapter:startRecord(file, 0, tostring(self._recordIndex))

	-- 统计语音时长
	game.service.TDGameAnalyticsService.getInstance():onBegin("YV_RecordVoice")
end

-- 结束录音
-- @param cancel:string 	是否取消上传
function IM_VoiceService:stopRecord(cancel)
	Logger.debug("[IM_VoiceService] stopRecord,%s", tostring(cancel));
	
	if cancel == true then
		-- 记录取消的语音
		self._canceledRecords[self._recordIndex] = true;
	end
	
	self._adapter:stopRecord(cancel)
end

-- 录音完成事件
-- @param time:number			录音时长（以毫秒计）
-- @param strfilepath:string	录音保存文件路径名
-- @param ext:string			录音请求时传递过来的
function IM_VoiceService:onStopRecordListern(time, strfilepath, ext)
	Logger.debug("[IM_VoiceService] onStopRecordListern,%d,%s,%s", time, strfilepath, ext);
	
	-- 判断当前语音是否取消了
	local recordIndex = tonumber(ext);
	if self._canceledRecords[recordIndex] == true then
		self._canceledRecords[recordIndex] = nil;
		game.service.TDGameAnalyticsService.getInstance():onFailed("YV_RecordVoice")
		return;
	end

	-- 录音完成之后直接上传
	self._adapter:upLoadFile(strfilepath, ext)

	-- 统计
	game.service.DataEyeService.getInstance():onEvent("YV_RecordFinished_Time", time / 1000)
	game.service.TDGameAnalyticsService.getInstance():onCompleted("YV_RecordVoice")
end

-- 播放录音请求
-- @param url:string
-- @param roleId:number 发起说话的玩家id
function IM_VoiceService:playFromUrl(url, roleId)
	local ext = tostring(roleId)..kod.util.Time.now();
	self._adapter:playFromUrl(url, ext);
	
	Macro.assertFalse(self._playRecords[ext] == nil)	
	self._playRecords[ext] = {
		url = url,
		ext = ext,
		roleId = roleId,
		tryTimes = 3,
	}
end

-- 停止播放录音请求
function IM_VoiceService:stopPlay()
	Logger.debug("[IM_VoiceService] stopPlay");
	self._adapter:stopPlay();
end

-- 播放录音完成事件
-- @param result:number		播放完成为0,失败为1
-- @param describe:string	错误描述
-- @param ext:string		调用播放请求时，传递进来的值
function IM_VoiceService:onFinishPlayListern(result, describe, ext)
	Logger.debug("[IM_VoiceService] onFinishPlayListern,%d,%s,%s", result, describe, ext)
	Macro.assertFalse(self._playRecords[ext] ~= nil)
	if result == 0 or self._playRecords[ext].tryTimes == 0 then
		-- 播放完成 或者重试次数使用完
		self:dispatchEvent({name = "EVENT_PLAY_FINISNED", roleId = self._playRecords[ext].roleId});
		self._playRecords[ext] = nil;
	else
		-- 播放失败, 重试
		self._playRecords[ext].tryTimes = self._playRecords[ext].tryTimes - 1
		self._adapter:playFromUrl(self._playRecords[ext].url, self._playRecords[ext].ext);
	end
end

-- 语音文件下载完毕事件
-- @param percent:number	下载完成为100
-- @param ext:string		调用播放请求时，传递进来的值
function IM_VoiceService:onDownloadVoiceListern(percent, ext)
	Logger.debug("[IM_VoiceService] onDownloadVoiceListern,%d,%s", percent, ext)
	if percent == 100 then
		-- 下载完毕
		self:dispatchEvent({name = "EVENT_PLAY_STARTED", roleId = self._playRecords[ext].roleId});
	end
end

-- 上传文件完成事件
-- @param result:number		上传结果，不为0 即为失败
-- @param msg:string		错误描述
-- @param fileid:string		请求上传接口传的值
-- @param fileurl:string	返回URL 地址
-- @param percent:number	完成百分比
function IM_VoiceService:onUpLoadFileListern(result, msg, fileid, fileurl, percent)
	Logger.debug("[IM_VoiceService] onUpLoadFileListern,%d,%s,%s,%s,%d", result, msg, fileid, fileurl, percent)
	if result == 0 then
		-- 上传完成
		self:dispatchEvent({name = "EVENT_UPLOAD_FINISNED", url = fileurl});
	end
end

-- 下载文件请求
-- @param url:string		所下载的文件所在的URL 地址
-- @param savePath:string	保存路径， 带绝对路径的文件名
-- @param savePath:fileid	希望传递给下载结束事件回调的值
function IM_VoiceService:downLoadFile(url, savePath, fileid)
	Logger.debug("[IM_VoiceService] downLoadFile,%s,%s,%s", url, savePath, fileid)
	self._adapter:downLoadFile(url, savePath, fileid)
end