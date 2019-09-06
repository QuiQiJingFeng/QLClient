--[[聊天相关逻辑
1. 用户输入文字
2. 表情
3. 常用语
4. 语音消息

Chat相关的Event
event = {
	name = "SHOW_CHAT"
	chatType =
	roleId = 0
	code = 0
	content = ""
}
]]
local ns = namespace("game.service")
local Constants = require("app.gameMode.mahjong.core.Constants");
local ExpressionConfig = require("app.config.ExpressionConfig")

local SEND_INTERVAL = 0.1

local CURRECT_CHAT_VERSION = 1000
local CHAT_VERSION_NOSET = -1
----------------------------------
-- 聊天相关的本地存储
local ChatSetting = class("ChatSetting")
function ChatSetting:ctor()
	-- 贵阳默认为贵阳话
	self.dialect = config.ChatConfig.DialectType.NORMAL;
	-- 添加一个默认值，如果当前此值为默认值，那么要将语音默认值置为地方话
	self.version = CHAT_VERSION_NOSET
end

----------------------------------
-- ChatService
local ChatService = class("ChatService")
ns.ChatService = ChatService

-- 单例
function ChatService.getInstance()
	return game.service.LocalPlayerService.getInstance():getChatService();
end

function ChatService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");

	self:clear()
end

function ChatService:clear()
	self._chatSetting = nil
	self._roomServerId = 0
	self._messageShowTime = 5000;	-- 文本在界面上面显示持续时间
	self._lastSendTime = 0;			-- 上一次发送聊天信息的时间
	self._recordBlock = false      -- 记录上次是否记录了消息间隔（默认否）
	self._enabled = true 			-- 禁用模式，如果观战的时候，收到消息不再分发
	self._timer = nil
	self._isPlay = false

	self._playerInfoCache = nil
end

function ChatService:initialize()
	-- 监听网络操作
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.BCChatRES.OP_CODE, self, self._onChatRes);
	requestManager:registerResponseHandler(net.protocol.BCChatSYN.OP_CODE, self, self._onChatrSync);
	requestManager:registerResponseHandler(net.protocol.GCSendEmojiRES.OP_CODE, self, self._onGCSendEmojiRES)
	requestManager:registerResponseHandler(net.protocol.GCSendEmojiSYN.OP_CODE, self, self._onGCSendEmojiSYN)
	requestManager:registerResponseHandler(net.protocol.GCQueryEmojiRES.OP_CODE, self, self._onGCQueryEmojiRES)
	
    -- game.service.IM_VoiceService.getInstance():addEventListener("EVENT_UPLOAD_FINISNED", handler(self, self._onIMUploadFinished), self)
    game.service.RT_VoiceService.getInstance():addEventListener("EVENT_UPLOAD_FINISNED", handler(self, self._onIMUploadFinished), self)
	
	return true;
end

function ChatService:dispose()
	if self._timer ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer)
		self._timer = nil
	end
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	game.service.RT_VoiceService.getInstance():removeEventListenersByTag(self)
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

function ChatService:setRoleId(roleId)
	self._roleId = roleId;
end

function ChatService:setEnabled(tf)
	self._enabled = tf
end

function ChatService:setRoomServerId(serverId)
	self._roomServerId = serverId;
end

function ChatService:loadLocalStorage()
	self._chatSetting = manager.LocalStorage.getUserData(self._roleId, "ChatSetting", ChatSetting);
	if self._chatSetting.version ~= CURRECT_CHAT_VERSION then
		if self._chatSetting.version == CHAT_VERSION_NOSET then
			-- 因为以前贵阳保存过一个默认值，但是这个默认值是不对的，所以设置一个version为-1，此时将默认值改回！
			-- GlobalConfig添加默认语音选项
			self._chatSetting.dialect = config.ChatConfig.defaultDialect
			self._chatSetting.version = CURRECT_CHAT_VERSION
		else
			-- 版本更新了，是不是要重置回普通话呢？
			-- 这里的index已经不能保证还能对的上
			self._chatSetting.version = CURRECT_CHAT_VERSION
		end
	end
	-- 现在只保留贵阳话。。。
	-- 配置保留吧，资源删除
	-- self._chatSetting.dialect = config.ChatConfig.defaultDialect
end

function ChatService:_saveLocalSetting()
	manager.LocalStorage.setUserData(self._roleId, "ChatSetting", self._chatSetting);
end

-- 获取方言类型
function ChatService:getDialect()
	local gameType = Constants.SpecialEvents.gameType
	if gameType == 'GAME_TYPE_ZHENGSHANGYOU' then
		return config.ChatConfig.DialectType.ZHENGSHANGYOU
	end
	return self._chatSetting.dialect;
end

-- 获取方言类型
function ChatService:getDialectConfig(dialect)
	return config.ChatConfig.getLocalConfig(dialect)
end

-- 获取方言显示的默认名字
-- 这里需要说明一下，如果是多个方言的时候，显示的是“方言”，但是只有一个方言的时候，显示的就是当前的方言的对应的名字，
-- 所以直接在这里封装一个函数单独处理吧
function ChatService:getDefaultDialectName()
	local dialectNames, dialectEnums = self:getLocalNames()
	if #dialectNames == 1 then
		return self:getDialectConfig(dialectEnums[1]).name
	else
		return "方言"
	end
end

-- 设置方言类型
function ChatService:setDialect(dialect)
	local d_type = type(dialect)
	Macro.assertFalse(d_type == 'number', 'error dialect ' .. tostring(dialect))

	self._chatSetting.dialect = dialect
	self:_saveLocalSetting();

	-- 方言发生改变
	local event = {name = "DIALECT_CHANGED"}
	event.dialect = dialect
	self:dispatchEvent(event);
end
-- 设置语言，但是不是保存到硬盘中，只会保存到内存中
function ChatService:setDialectWithoutSaveStorage(dialect)
	local d_type = type(dialect)
	Macro.assertFalse(d_type == 'number', 'error dialect ' .. tostring(dialect))
	-- 方言发生改变
	local event = {name = "DIALECT_CHANGED"}
	event.dialect = dialect
	self:dispatchEvent(event);
end

-- 检测发送间隔, 如果小于间隔, 返回false
function ChatService:checkSendInterval()
	local interval = kod.util.Time.now() - self._lastSendTime;
	if interval > SEND_INTERVAL then
		return true
	end
	
	if self._recordBlock == false then
		-- 记录时间block时间
		game.service.DataEyeService.getInstance():onEvent("SendMsg_Block", interval)
		self._recordBlock = true;
	end
	
	return false
end

-- 获取语音文件所在路径
-- @return string
function ChatService:getSoundPath(gender)
	return config.ChatConfig.getPath(self:getDialect(), gender);
end

-- 获取特效文件所在路径（打牌的声效文件）
-- @return string
function ChatService:getSFXPath()
	return config.ChatConfig.getSFXPath(self:getDialect());
end

-- 获取内置闲话文本数组
-- @return string[]
function ChatService:getSoundTexts()
	return config.ChatConfig.getTextArray(self:getDialect());
end

-- 获取内置闲话文本数组
-- @return string[]
function ChatService:getSoundVoices()
	return config.ChatConfig.getVoiceArray(self:getDialect());
end

-- 获取当前的地方话类型，可能有多个，一个，没有
function ChatService:getLocalNames()
	return config.ChatConfig.getLocalNames()
end

-- 发送常用语
-- @param index: number
function ChatService:sendBuildinText(index)
	self:_sendChatMessage(net.protocol.ChatType.BUILDIN, "", index);
end

-- 发送表情
-- @param index: number
function ChatService:sendEmotion(index)
    self:_sendChatMessage(net.protocol.ChatType.EMOTION, "", index);
    --统计每个表情发送的人数  以及人次
    
    local key = game.globalConst.ChatEmojTimes["Emoj_index_"..(index+1)]
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();

    if Macro.assertFalse(key, string.format("send emotion error, index = %s", index)) then
	    game.service.TDGameAnalyticsService.getInstance():onEvent(key, {roleId = roleId})
    end
end

-- 发送用户输入的文字
-- @param text: string
function ChatService:sendCustomMessage(text)
	self:_sendChatMessage(net.protocol.ChatType.CUSTOM, text, 0);
end

-- 发送用户语音URL
-- @param textUrl: string
function ChatService:sendVoiceMsg(textUrl)
	self:_sendChatMessage(net.protocol.ChatType.VOICE, textUrl, 0);
end

-- @param type: net.protocol.ChatType
-- @param text: string
-- @param code: number
function ChatService:_sendChatMessage(type, text, code)
	local roomService = game.service.RoomService:getInstance()
	if roomService == nil or roomService:getRoomId() == 0 then
		return
	end
	-- 统计消息
	if type == net.protocol.ChatType.BUILDIN then
		-- 常用语
		game.service.DataEyeService.getInstance():onEvent("SendMsg_Custom")
		game.service.TDGameAnalyticsService.getInstance():onEvent("SendMsg_Detail_Custom", {msgCode = code})
	elseif type == net.protocol.ChatType.EMOTION then
		-- 表情
		game.service.DataEyeService.getInstance():onEvent("SendMsg_Emotion")
	elseif type == net.protocol.ChatType.CUSTOM then
		-- 自定义语句
		game.service.DataEyeService.getInstance():onEvent("SendMsg_Chat")
	elseif type == net.protocol.ChatType.VOICE then
		-- 语音
		game.service.DataEyeService.getInstance():onEvent("SendMsg_Voice")
	end
	
	-- 记录本次发送时间用于发送cd
	self._lastSendTime = kod.util.Time.now()
	self._recordBlock = false
	
	-- 发送消息, 聊天消息不用等待服务器返回
	local request = net.NetworkRequest.new(net.protocol.CBChatREQ, self._roomServerId);
	request:getProtocol():setData(type, text, code);
	request:setWaitForResponse(false);
	game.util.RequestHelper.request(request);
end

-- 发送消息的返回
function ChatService:_onChatRes(response)
	local protocol = response:getProtocol():getProtocolBuf();
end

-- 服务器下发有人聊天的同步消息
function ChatService:_onChatrSync(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	-- 当前处于禁用状态，那么就不再分发事件
	if not self._enabled then
		return
	end
	
	-- 发起聊天事件
	local event = {name = "SHOW_CHAT"}
	event.chatType = protocol.type
	event.roleId = protocol.roleId
	event.code = protocol.code
	event.content = protocol.content
	self:dispatchEvent(event);
end

function ChatService:_onIMUploadFinished(event)
	self:sendVoiceMsg(event.url);
end

-- 魔法表情
function ChatService:sendCGSendEmojiREQ(emojiId, receiver)
	local request = net.NetworkRequest.new(net.protocol.CGSendEmojiREQ,  game.service.LocalPlayerService:getInstance():getGameServerId())
	request.emojiId = emojiId
	request:getProtocol():setData(emojiId, receiver)
	game.util.RequestHelper.request(request)
end

function ChatService:_onGCSendEmojiRES(response)
	local request = response:getRequest()
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_SEND_EMOJI_SUCCESS then
	elseif protocol.result == net.ProtocolCode.GC_SEND_EMOJI_CURRENCY_NOT_ENOUGH then
		UIManager:getInstance():show("UIBuyExpression", request.emojiId)
	end
end

function ChatService:_onGCSendEmojiSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- 在设置里面的关了动画就不用播放了
	if game.service.LocalPlayerSettingService:getInstance():getEffectValues().effect_Expression == false then
		return
	end

	-- 如果玩家不在房间内就不显示表情
	if game.service.RoomService.getInstance():getPlayerById(protocol.sender) and game.service.RoomService.getInstance():getPlayerById(protocol.receiver) then
		self:_setExpressionTips()
		self._isPlay = true
		self:dispatchEvent({name = "SHOW_EXPRESSION", emojiId = protocol.emojiId, sender = protocol.sender, receiver = protocol.receiver})
	end
end

function ChatService:setIsPlay(isPlay)
	self._isPlay = isPlay
end

function ChatService:getIsPlay()
	return self._isPlay
end

function ChatService:_setExpressionTips()
	local localSetting = game.service.LocalPlayerSettingService:getInstance()
	if not localSetting:getIsExpression() then
		self:dispatchEvent({name = "SHOW_EXPRESSION_TIPS", isVisible = true})
		self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			if self._timer ~= nil then
       			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer)
        		self._timer = nil
    		end
			self:dispatchEvent({name = "SHOW_EXPRESSION_TIPS", isVisible = false})
        end, 5, false)
		localSetting:setIsExpression(true)
		localSetting:saveSetting()
	end
end

function ChatService:getExpressionInfo(id)
	for _, data in pairs(ExpressionConfig) do
		if tonumber(data.id) == tonumber(id) then
			return data
		end
	end

	return {}
end

function ChatService:getExpressionConfig()
	return ExpressionConfig
end

--[[
    请求魔法表情数量
]]
function ChatService:sendCGQueryEmojiREQ(data)
	-- 缓存一会显示的玩家信息
	self._playerInfoCache = data
	local request = net.NetworkRequest.new(net.protocol.CGQueryEmojiREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

--[[
    请求魔法表情数量RES
]]
function ChatService:_onGCQueryEmojiRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	if protocol.result == net.ProtocolCode.GC_QUERY_EMOJI_SUCCESS then
		if self._playerInfoCache ~= nil then
			UIManager:getInstance():show("UIPlayerinfo3",self._playerInfoCache, protocol.emoji)
		end
	end
end