--[[
丫丫语音模块

现在从im_service中提了出来
把业务Service和sdk接口分离开
这样之后再换sdk，只需提供业务Service所需的接口就好

加了各种状态来保证每次执行的操作是正确
前期只加了assert，如果上线后问题较少，可以把assert改成强制的if-else
如果问题较多，再分析原因调整代码
具体状态见状态的注释
--]]

local YV_State = {
	-- 未初始化，一进游戏还未初始化sdk时的状态，初始化后直到退出游戏应该不需要再次init
	NOT_INIT = 1,
	-- 未连接状态，丫丫语言需要连接他的服务器
	NOT_CONNECT = 2,
	-- 重连中，据泽华说经常重连
	RECONNECTING = 2.5,
	-- 连接成功的状态，这时可以进行绝大部分操作
	CONNECTED = 3,
	-- 录音中，录音中应该避免再次录音
	RECORDING = 4,
	-- 其他状态如播放等，应该不与录音冲突，只需判断是否连接
}

-- 临时文件保存路径
local FILE_DOWNLOAD_TEMP_PATH = cc.FileUtils:getInstance():getAppDataPath() .. "speech/"

local ns = namespace("game.service")

local YVVoiceService = class("YVVoiceService")
ns.YVVoiceService = YVVoiceService

-------------------------
-- 单例支持
local instance = nil
function YVVoiceService.getInstance()
	if instance == nil then
		instance = YVVoiceService.new()
	end
	return instance
end

-------------------------
function YVVoiceService:ctor()
	-- 初始状态
	self._state = YV_State.NOT_INIT
	-- 重连用
	self._nickname = ''
	self._uid = 0
	self._pollEventTask = nil
end

function YVVoiceService:initialize(path)
	if not self:isEnabled() then return end

	self._isDebug = true;
	
	-- 初始化SDK, 热更会重新加载文件, 需要从SDK层判断
	if not self:isInitSDK() then
		release_print("yyappid~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", config.GlobalConfig.getConfig().YYVoice_AppID)
		self:initSDK(config.GlobalConfig.getConfig().YYVoice_AppID, path, false)
	end

	self._state = YV_State.NOT_CONNECT
	
	-- 注册事件回调
	yvHelper:instance():registerLoginListern( handler(self, self.onLoginListern) )
	yvHelper:instance():registerReConnectListern( handler(self, self.onReConnectListern) )
	yvHelper:instance():registerStopRecordListern( handler(self, self.onStopRecordListern) )
	yvHelper:instance():registerFinishSpeechListern( handler(self, self.onFinishSpeechListern) )
	yvHelper:instance():registerFinishPlayListern( handler(self, self.onFinishPlayListern) )
	yvHelper:instance():registerUpLoadFileListern( handler(self, self.onUpLoadFileListern) )
	yvHelper:instance():registerDownLoadFileListern( handler(self, self.onDownLoadFileListern) )
	yvHelper:instance():registerNetWorkSateListern( handler(self, self.onNetWorkSateListern) )
	yvHelper:instance():registerDownloadVoiceListern( handler(self, self.onDownloadVoiceListern) )
	yvHelper:instance():registerRecordVoiceListern( handler(self, self.onRecordVoiceListern) )
	yvHelper:instance():registerCPUserInfoListern( handler(self, self.onCPUserInfoListern) )

	if _hasYVToolFixedRebootIssue then self:_startPollEvent() end
end

-- 开始事件回调更新
function YVVoiceService:_startPollEvent()
	Logger.debug("[YVVoiceService] _startPollEvent")
	if self._pollEventTask == nil then
		local yvtool = YVTool:getInstance()
		self._pollEventTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
			yvtool:dispatchMsg(dt)
		end, 0, false)
	end
end

-- 关闭事件回调更新
function YVVoiceService:_endPollEvent()
	Logger.debug("[YVVoiceService] _endPollEvent")
	if self._pollEventTask then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pollEventTask)
		self._pollEventTask = nil
	end
end

function YVVoiceService:dispose()
	self._state = YV_State.NOT_CONNECT
	self:_endPollEvent()
end

function YVVoiceService:registerStopRecordListern(_handler)
	self._onStopRecordCallback = _handler
end

function YVVoiceService:registerFinishPlayListern(_handler)
	self._onFinishPlayCallback = _handler
end

function YVVoiceService:registerUpLoadFileListern(_handler)
	self._onUpLoadFileCallback = _handler
end

function YVVoiceService:registerDownloadVoiceListern(_handler)
	self._onDownloadVoiceCallback = _handler
end

function YVVoiceService:isEnabled()
	return game.plugin.Runtime.isEnabled();
end

function YVVoiceService:getFileType()	
	return _isDebug and ".amr" or "d.amr"
end

function YVVoiceService:isInitSDK()
	Logger.debug("[YVVoiceService] isInitSDK");
	if not self:isEnabled() then return false end
	return YVTool:getInstance():isInitSDK()
end

-- 初始化SDK
-- @param appId:number		应用编号（需向云娃申请获取）
-- @param tempPath:string	一个可写的路径，云娃SDK 生成的中间文件保存的地方
-- @param isTest:string		是否是测试环境，默认值为true
function YVVoiceService:initSDK(appId, tempPath, isDebug)
	Logger.debug("[YVVoiceService] initSDK,%d,%s,%s", appId, tempPath, tostring(isDebug));
	if not self:isEnabled() then return end
	YVTool:getInstance():initSDK(appId, tempPath, isDebug)
end

-- 登录
-- @param nickname:string	用户名称（由CP 自己提供）
-- @param uid:string		用户ID，（由CP 自己提供，请确保唯一性）
function YVVoiceService:cpLogin(nickname, uid)
	if self._state == YV_State.CONNECTED then
		-- 登陆一次之后就再也不登陆了
		return
	end
	Logger.debug("[YVVoiceService] cpLogin,%s,%s", nickname, uid);
	if not self:isEnabled() then return end

	self._nickname = nickname
	self._uid = uid

	YVTool:getInstance():cpLogin(nickname, uid)
end

-- 登录回调
-- @param result:number			登录结果不为0 即为失败
-- @param msg:string			错误描述
-- @param userid:number			云娃ID
-- @param nickName:string		用户昵称
-- @param iconUrl:string		用户头像地址
-- @param thirdUserId:number	CP 提供的用户id
-- @param thirdUserName:string	CP 提供的用户名
function YVVoiceService:onLoginListern(result, msg, userid, nickName, iconUrl, thirdUserId, thirdUserName)
	Logger.debug("[YVVoiceService] onLoginListern,"..result..","..msg..","..nickName..","..iconUrl..","..thirdUserId..","..thirdUserName);
	if result == 0 then
		self._state = YV_State.CONNECTED -- 设置为连接
		game.service.DataEyeService.getInstance():onEvent("YVVoice_Login_Success")
		return 
	end
	game.service.DataEyeService.getInstance():onEvent("YVVoice_Login_Failed")
end

-- 登出
function YVVoiceService:cpLogout()
	Logger.debug("[YVVoiceService] cpLogout");
	if not self:isEnabled() then return end

	YVTool:getInstance():cpLogout()
end

-- 重连通知
-- @param userid:number		云娃ID
function YVVoiceService:onReConnectListern(userid)
	Logger.debug("[YVVoiceService] onReConnectListern,%d", userid)
end

-- 网络状态通知
-- @param state:number 		0 表示断开连接, 1 表示连接
function YVVoiceService:onNetWorkSateListern(state)
	Logger.debug("[YVVoiceService] onNetWorkSateListern,%d", state)
end

-- 开始录音
-- @param savePath:string	带绝对路径的文件名（ 例：xx/test.amr）
-- @param speech:number		0:普通录音，不上传不识别；1：边录边上传语音和识别；2 边录边上传语音
-- @param ext:string		希望传递给结束录音事件回调的值
function YVVoiceService:startRecord(savePath, speech, ext)
	Logger.debug("[YVVoiceService] startRecord,%s,%d,%s", savePath, speech, ext);
	if not self:isEnabled() then return end

	YVTool:getInstance():startRecord(file, speech, ext)
end

-- 结束录音
-- @param cancel:string 	是否取消上传
function YVVoiceService:stopRecord(cancel)
	Logger.debug("[YVVoiceService] stopRecord,%s", tostring(cancel));
	if not self:isEnabled() then return end
	
	YVTool:getInstance():stopRecord()
end

-- 录音完成事件
-- @param time:number			录音时长（以毫秒计）
-- @param strfilepath:string	录音保存文件路径名
-- @param ext:string			录音请求时传递过来的
function YVVoiceService:onStopRecordListern(time, strfilepath, ext)
	Logger.debug("[YVVoiceService] onStopRecordListern,%d,%s,%s", time, strfilepath, ext);
	
	if self._onStopRecordCallback ~= nil then
		self._onStopRecordCallback(time, strfilepath, ext)
	end
end

-- 播放录音请求
-- @param url:string	语音在服务器的地址（识别或者上传返回的）
-- @param path:string	带绝对路径的文件名（ 例：xx/test.amr）
-- @param ext:string	希望传递给结束播放事件回调的值
function YVVoiceService:playRecord(url, path, ext)
	Logger.debug("[YVVoiceService] playRecord,%s,%s,%s", url, path, ext);
	if not self:isEnabled() then return end

	YVTool:getInstance():playRecord(url, path, ext);	
end

-- 播放录音请求
-- @param url:string	语音在服务器的地址（识别或者上传返回的）
-- @param ext:string	希望传递给结束播放事件回调的值
function YVVoiceService:playFromUrl(url, ext)
	Logger.debug("[YVVoiceService] playFromUrl,%s,%s", url, ext);
	if not self:isEnabled() then return end
	
	YVTool:getInstance():playFromUrl(url, ext);
	-- 播放时，应该可以录制，所以不设置状态
end

-- 停止播放录音请求
function YVVoiceService:stopPlay()
	Logger.debug("[YVVoiceService] stopPlay");
	if not self:isEnabled() then return end
	YVTool:getInstance():stopPlay();
end

-- 播放录音完成事件
-- @param result:number		播放完成为0,失败为1
-- @param describe:string	错误描述
-- @param ext:string		调用播放请求时，传递进来的值
function YVVoiceService:onFinishPlayListern(result, describe, ext)
	Logger.debug("[YVVoiceService] onFinishPlayListern,%d,%s,%s", result, describe, ext)
	
	if self._onFinishPlayCallback ~= nil then
		self._onFinishPlayCallback(result, describe, ext)
	end
end

-- 语音文件下载完毕事件
-- @param percent:number	下载完成为100
-- @param ext:string		调用播放请求时，传递进来的值
function YVVoiceService:onDownloadVoiceListern(percent, ext)
	Logger.debug("[YVVoiceService] onDownloadVoiceListern,%d,%s", percent, ext)
	
	if self._onDownloadVoiceCallback ~= nil then
		self._onDownloadVoiceCallback(percent, ext)
	end
end

-- 语音识别请求
-- @param path:string		带绝对路径的文件名（ 例：xx/test.amr）
-- @param ext:string		希望传递给识别结束事件回调的值
-- @param isUpLoad:bool		是否识别后上传,会在识别完成后生成一个远程的url 地址
function YVVoiceService:speechVoice(path, ext, isUpload)
	Logger.debug("[YVVoiceService] speechVoice,%s,%s,%s", path, ext, tostring(isUpload))
	if not self:isEnabled() then return end
	YVTool:getInstance():speechVoice(path, ext, isUpload)
end

-- 设置语音识别语言类型请求（非必需）
-- @param inType:number 	1=中文,2=粤语,3=英语
-- @param outType:number 	0=简体中文,1=繁体中文
function YVVoiceService:setSpeechType(inType, outType)
	Logger.debug("[YVVoiceService] setSpeechType,%d,%d", inType, inType)
	if not self:isEnabled() then return end
	YVTool:getInstance():setSpeechType(path, ext)
end

-- 语音识别完成事件
-- @param err_id:number		识别结果，不为0 即为失败
-- @param err_msg:string	错误描述
-- @param result:string		识别后的文本（注意目前SDK 提供给win32 的是GBK 编码，其它平台都是UTF8 编码）
-- @param ext:string		请求识别传入的ext
-- @param url:string		如果识别时加了上传，则这个值就有了
function YVVoiceService:onFinishSpeechListern(err_id, err_msg, result, ext, url)
	Logger.debug("[YVVoiceService] onFinishSpeechListern,%d,%s,%s,%s,%s", err_id, err_msg, result, ext, url)
end

-- 上传文件请求
-- @param path:string		带绝对路径的文件名（ 例：xx/test.amr）
-- @param fileid:string		希望传递给上传结束事件回调的值
function YVVoiceService:upLoadFile(path, fileid)
	Logger.debug("[YVVoiceService] upLoadFile,%s,%s", path, fileid)
	if not self:isEnabled() then return end
	
	YVTool:getInstance():upLoadFile(path, fileid)
end

-- 上传文件完成事件
-- @param result:number		上传结果，不为0 即为失败
-- @param msg:string		错误描述
-- @param fileid:string		请求上传接口传的值
-- @param fileurl:string	返回URL 地址
-- @param percent:number	完成百分比
function YVVoiceService:onUpLoadFileListern(result, msg, fileid, fileurl, percent)
	Logger.debug("[YVVoiceService] onUpLoadFileListern,%d,%s,%s,%s,%d", result, msg, fileid, fileurl, percent)
	
	if self._onUpLoadFileCallback ~= nil then
		self._onUpLoadFileCallback(result, msg, fileid, fileurl, percent)
	end
end

-- 下载文件请求
-- @param url:string		所下载的文件所在的URL 地址
-- @param savePath:string	保存路径， 带绝对路径的文件名
-- @param savePath:fileid	希望传递给下载结束事件回调的值
function YVVoiceService:downLoadFile(url, savePath, fileid)
	Logger.debug("[YVVoiceService] downLoadFile,%s,%s,%s", url, savePath, fileid)
	if not self:isEnabled() then return end

	YVTool:getInstance():downLoadFile(url, savePath, fileid)
end

-- 下载文件完成事件
-- @param result:number		上传结果，不为0 即为失败
-- @param msg:string		错误描述
-- @param fileid:string		请求下载接口传的值
-- @param filename:string	文件保存的路径
-- @param percent:number	完成百分比
function YVVoiceService:onDownLoadFileListern(result, msg, fileid, filename, percent)
	Logger.debug("[YVVoiceService] onDownLoadFileListern,%d,%s,%s,%s,%d", result, msg, fileid, filename, percent)
	if result == 0 then
		-- 下载成功
	end
end

-- 录音音量事件, 需要调用设置录音接口，打开后才有回调
-- @param ext:string		扩展字段
-- @param volume:number		音量大小(0-100)
function YVVoiceService:onRecordVoiceListern(ext, volume)
	Logger.debug("[YVVoiceService] onRecordVoiceListern,%s,%d", ext, volume)
end

-- 设置录音, 貌似没用
-- @param timeNum:number	音的时长单位为秒,默认是60 秒
-- @param isGetVolume:bool	为打开录音音量事件回调
function YVVoiceService:setRecord(timeNum, isGetVolume)
	Logger.debug("[YVVoiceService] downLoadFile,%d,%s", timeNum, tostring(isGetVolume))
	if not self:isEnabled() then return end
	YVTool:getInstance():setRecord(timeNum, isGetVolume)
end

-- 没有文档, 不知道这是啥玩意
function YVVoiceService:onCPUserInfoListern(result, ext, yunvaid, nickname, iconUrl, level, vip, ext2)
	Logger.debug("[YVVoiceService] onCPUserInfoListern => params:", result, ext, yunvaid, nickname, iconUrl, level, vip, ext2)
end

