--[[
场景内聊天提示的UI封装类
--]]
-- local EmotionConfig = require("app.config.EmotionConfig") MARK TO DELETE
local EmotionConfig = require("app.config.DynamicEmotionConfig")
local UIRTVoiceIconComponent = require("app.game.ui.element.UIRTVoiceIconComponent")
local UI_ANIM = require("app.manager.UIAnimManager")

local CHAT_UI_DISPLAY_TIME = 3;

local UIElemChat = class("UIElemChat")

-- @param parentUI
-- @param anchorPoint
-- @param extend2Right
function UIElemChat:ctor()
	self._playerID = 0;
	self._chatUIParent = nil;
	self._chatUIBG = nil;
	self._chatUIText = nil;
	self._chatUIEmotion = nil;
	self._seatUI = nil;
	
	self._imUIParent = nil
	self._imUIxh1 = nil
	self._imUIxh2 = nil
	self._imUIxh3 = nil
	self._expandSize = cc.size(15,0)
end

function UIElemChat:initialize(seatUI, rtVoiceAcionName, charUIParent, chatUIBG, chatUIText, chatUIEmotion, imUIParent, imUIxh1, imUIxh2, imUIxh3, rtUIParent)
	self._seatUI = seatUI;
	self._rtVoiceAcionName = rtVoiceAcionName;
	self._chatUIParent = charUIParent;
	self._chatUIBG = chatUIBG;
	self._chatUIText = chatUIText;
	self._chatUIEmotion = chatUIEmotion
	self._imUIParent = imUIParent
	self._imUIxh1 = imUIxh1
	self._imUIxh2 = imUIxh2
	self._imUIxh3 = imUIxh3	

	-- 注册聊天消息事件
	game.service.ChatService.getInstance():addEventListener("SHOW_CHAT", handler(self, self._onChatSync), self)
	game.service.ChatService.getInstance():addEventListener("SHOW_EXPRESSION", handler(self, self._showExpression), self)
	game.service.RT_VoiceService.getInstance():addEventListener("EVENT_PLAY_STARTED", handler(self, self._onIMVoicePlayStarted), self)
	game.service.RT_VoiceService.getInstance():addEventListener("EVENT_PLAY_FINISNED", handler(self, self._onIMVoicePlayFinished), self)

	-- 创建实时语音聊天标记组件
	-- TODO:现在UI的生命周期要比Service的长，所以现在提前创建，等到Service的通知来控制相关的显示
	self._rtUI = UIRTVoiceIconComponent.new(self, rtUIParent)

    self:hideAll();
    
    if EmotionConfig.isDynamic then
        local headNode = self._chatUIEmotion:getParent():getParent()
        local node = headNode:getChildByName("Panel_Player")
        local uiemotion = cc.Sprite:create()
        uiemotion:setName("emotion_temp")
        if node then
            uiemotion:setAnchorPoint(cc.p(0.5,0.5))
            self._chatUIEmotion:setVisible(false)
            local origin = node:getChildByName("emotion_temp")
            if origin then
            	origin:removeSelf()
            end
            node:addChild(uiemotion)
            local icon = node:getChildByName("headFrame")
            local pos = cc.p(icon:getPosition())
            uiemotion:setPosition(pos)
        else
           local headNode = self._chatUIEmotion:getParent():getParent()
           local origin = headNode:getChildByName("emotion_temp")
            if origin then
            	origin:removeSelf()
            end
            headNode:addChild(uiemotion)
            local mvlist = EmotionConfig.getFixPosList()
            for i = 1, 4 do
                local name = string.format("Icon_img_player%d_Scene",i)
                local node = headNode:getChildByName(name)
                if node then
                	local pos = cc.p(node:getPosition())
                	pos.x = pos.x + mvlist[i].x
                	pos.y = pos.y + mvlist[i].y
                    uiemotion:setPosition(pos)
                    break
                end
            end
        end
        self._chatUIEmotion = uiemotion
    end
end

function UIElemChat:updateChatBg(background,color,expandSize)
	self._chatUIBG:loadTexture(background)
	self._chatUIText:setTextColor(color)
	if expandSize ~= nil then
		self._expandSize = expandSize
	end
end

function UIElemChat:destroy()
	if game.service.LocalPlayerService.getInstance() then
		-- TODO：在断线重连跟顶号同时进行时，会出现问题，强行添加保护
		game.service.ChatService.getInstance():removeEventListenersByTag(self)
		game.service.RT_VoiceService.getInstance():removeEventListenersByTag(self)
	end

	-- TODO：如果播放语音的时候断线重连，会不会出现不消失呢？
	self:_hideChatUI();
	self:_hideIMUI();

	self._rtUI:dispose();
end

function UIElemChat:getSeatUI()
	return self._seatUI;
end

function UIElemChat:hideAll()
	self:_hideChatUI();
	self:_hideIMUI();
	
	self._rtUI:showRTVoiceUI(false);
end

function UIElemChat:onPlayerDataChanged()
	if self._seatUI:getRoomSeat():hasPlayer() == false then
		return
	end
end

-- 显示聊天信息
function UIElemChat:_onChatSync(event)
	if self._seatUI == nil or self._seatUI.getRoomSeat == nil then
		return
	end
	if self._seatUI:getRoomSeat():hasPlayer() == false then
		return
	end
	
	if self._seatUI:getRoomSeat():getPlayer().id ~= event.roleId then
		return
	end
	
	if event.chatType == net.protocol.ChatType.BUILDIN then
		self:_showBuildinText(event.code);
	elseif event.chatType == net.protocol.ChatType.EMOTION then
		self:_showEmotion(event.code);
	elseif event.chatType == net.protocol.ChatType.CUSTOM then
		self:_showCustomMessage(event.content);
	elseif event.chatType == net.protocol.ChatType.VOICE then
		self:_showVoice(event.content);
	end
end

function UIElemChat:_onIMVoicePlayStarted(event)
	if self._seatUI:getRoomSeat():hasPlayer() == false then
		return
	end
	
	if self._seatUI:getRoomSeat():getPlayer().id ~= event.roleId then
		return
	end

	--播放暂停
	manager.AudioManager.getInstance():mute()
	self:_showIMUI();
end

function UIElemChat:_onIMVoicePlayFinished(event)
	self:_hideIMUI();
	--取消暂停
	manager.AudioManager.getInstance():unmute()
end

function UIElemChat:_hideChatUI()
	self._chatUIParent:stopAllActions();
	self._chatUIParent:setVisible(false);
	self._chatUIText:setVisible(false);
	self._chatUIText:setString("");
	self._chatUIEmotion:setVisible(false);
	self._chatUIEmotion:setTexture("");
end

function UIElemChat:_hideIMUI()
	if nil == self._imUIParent or nil == self._imUIxh1 or nil == self._imUIxh2 or nil == self._imUIxh3 then return end
	self._imUIParent:stopAllActions()
	self._imUIxh1:stopAllActions()
	self._imUIxh2:stopAllActions()
	self._imUIxh3:stopAllActions()
	self._imUIxh1:setVisible(false)
	self._imUIxh2:setVisible(false)
	self._imUIxh3:setVisible(false)
	self._imUIParent:setVisible(false)
end

function UIElemChat:_delayHideChatUI(sec)
	local _func = cc.CallFunc:create(function () self:_hideChatUI() end)
	local _delay = cc.DelayTime:create(sec);
	local _sequ = cc.Sequence:create(_delay,_func)
	self._chatUIParent:runAction(_sequ);
end

-- 显示常用语
function UIElemChat:_showBuildinText(index)
	self:_hideChatUI();
	
	local roomService = game.service.RoomService.getInstance();
	local chatService = game.service.ChatService.getInstance();
	local playId = self._seatUI:getRoomSeat():getPlayer().id 
	
	-- 显示信息
	self._chatUIParent:setVisible(true);
	self._chatUIBG:setVisible(true)
	self._chatUIText:setVisible(true);
	
	-- 设置文字
	local text = chatService:getSoundTexts()[index + 1];
	self._chatUIText:setString(text);

	-- 播放语音
	local sound = chatService:getSoundPath(roomService._playerMap[playId].sex)..chatService:getSoundVoices()[index + 1];	
	manager.AudioManager.getInstance():playEffect(sound)
	
	--------------------------------
	self._chatUIText:ignoreContentAdaptWithSize(true);
	local _size = self._chatUIText:getVirtualRendererSize()

	if _size.width < 40 then
		_size.width = 40
	end
	self._chatUIBG:setContentSize(_size.width + self._expandSize.width,60 + self._expandSize.height);
	self._chatUIBG:setCapInsets(cc.rect(30, 20, 10, 17))

	--------------------------------
	-- 启动隐藏计时器
	self:_delayHideChatUI(CHAT_UI_DISPLAY_TIME);
end

-- 显示表情
function UIElemChat:_showEmotion(index)
	self:_hideChatUI();
    self._chatUIParent:setVisible(true);
    self._chatUIBG:setVisible(false)
    self._chatUIEmotion:setVisible(true);
    if EmotionConfig.isDynamic then
        local action = EmotionConfig.getAnimation(index)
        action = cc.Sequence:create(cc.ScaleTo:create(0,0.7),action,cc.Hide:create())
        self._chatUIEmotion:stopAllActions()
        self._chatUIEmotion:runAction(action)
    else --MARK TO DELETE
        -- 显示信息
        self._chatUIEmotion:setSpriteFrame(EmotionConfig.getTexture(index));
        --self._chatUIEmotion:setPosition(cc.p(36,40))
        --self._chatUIBG:setContentSize(80,80);
        -- 启动隐藏计时器
	    self:_delayHideChatUI(CHAT_UI_DISPLAY_TIME);
    end
    

end

-- 显示自定义文字
function UIElemChat:_showCustomMessage(text)
	self:_hideChatUI();

	-- 显示信息
	self._chatUIParent:setVisible(true);
	self._chatUIBG:setVisible(true)
	self._chatUIText:setVisible(true);
	self._chatUIText:setString(text);
	
	--------------------------------
	self._chatUIText:ignoreContentAdaptWithSize(true);
	local _size = self._chatUIText:getVirtualRendererSize();
	if _size.width < 40 then
		_size.width = 40
	end

	self._chatUIBG:setContentSize(_size.width + self._expandSize.width,60 + self._expandSize.height);
	self._chatUIBG:setCapInsets(cc.rect(30, 20, 10, 17))

	--------------------------------
	-- 启动隐藏计时器
	self:_delayHideChatUI(CHAT_UI_DISPLAY_TIME);
end

-- 显示语音消息
function UIElemChat:_showVoice(text)
	-- 不播放自己的语音
	local id = self._seatUI:getRoomSeat():getPlayer().id
	if id == game.service.LocalPlayerService.getInstance():getRoleId() then 
		return 
	end
	
	-- 播放语音
	-- game.service.IM_VoiceService.getInstance():playFromUrl(text, id);
	game.service.RT_VoiceService.getInstance():downloadRecordFile(text, id)
end

function UIElemChat:_showIMUI()
	if nil == self._imUIParent or nil == self._imUIxh1 or nil == self._imUIxh2 or nil == self._imUIxh3 then return end
	self:_hideIMUI()
	self._imUIParent:setVisible(true)
	
	local func1 = cc.CallFunc:create(function() 
		self._imUIxh1:setVisible(true)
		self._imUIxh2:setVisible(false)
		self._imUIxh3:setVisible(false)
	end)
		
	local func2 = cc.CallFunc:create(function() 
		self._imUIxh1:setVisible(false)
		self._imUIxh2:setVisible(true)
		self._imUIxh3:setVisible(false)
	end)
		
	local func3 = cc.CallFunc:create(function() 
		self._imUIxh1:setVisible(false)
		self._imUIxh2:setVisible(false)
		self._imUIxh3:setVisible(true)
	end)
	
	local delay1 = cc.DelayTime:create(0.3)
	local delay2 = cc.DelayTime:create(0.3)
	local delay3 = cc.DelayTime:create(0.3)
	
	local sequ = cc.Sequence:create(func1,delay1,func2,delay2,func3,delay3)
	local forever = cc.RepeatForever:create(sequ)
	
	self._imUIParent:runAction(forever)
end

function UIElemChat:_showExpression(event)
	-- 这里的事件注册了四遍暂时这样处理
	if game.service.ChatService.getInstance():getIsPlay() == false then
		return
	end
	game.service.ChatService.getInstance():setIsPlay(false)

	local path = function(name, index)
		local pathName = string.format("propani_/%s%d.csb", name, index)
		Logger.debug("UIElemChat:_showExpression()  ExpressionPath = " .. pathName)
		return pathName
	end

	local expressionInfo = game.service.ChatService.getInstance():getExpressionInfo(event.emojiId)
	-- 魔法表情文件名称
	local csb = expressionInfo.animation
	-- 是否是付费动画
	local isPay = (tonumber(expressionInfo.count) or 0) > 0
	-- 发送者的位置
	local pos = self:getPlayerPosition(event.sender)
	-- 接收者的位置
	local pos1 = self:getPlayerPosition(event.receiver)

	local pNode= self:_createTimeline(path(csb, 1), true, pos.x, pos.y)
	local move = cc.MoveTo:create(0.6, self._seatUI:getCardParentNode():convertToNodeSpace(pos1))
	-- 所有玩家都能看见第一步动画
	local sequence = cc.Sequence:create(move, cc.CallFunc:create(function()
		self._seatUI:getCardParentNode():removeChild(pNode)
		if isPay and event.receiver == game.service.LocalPlayerService.getInstance():getRoleId() then
			-- 付费表情接受者播放全屏动画
			UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(path(csb, 3), function()
				if expressionInfo.isSpecial then
					self:_shitAnimation(event.receiver)
				end
			end))
		else
			-- 发送者看见的动画
			local pNode1, ani1 = self:_createTimeline(path(csb, 2), false, pos1.x, pos1.y)
			-- 普通表情
			local sequence1 = self:_freeAnimation(pNode1, ani1)
			-- 付费表情情况
			if isPay then
				if expressionInfo.isSpecial then
					sequence1 = cc.Sequence:create(sequence1, cc.CallFunc:create(function()
						self:_shitAnimation(event.receiver)
					end))
				else
					sequence1 = self:_payAnimation(pNode1, ani1)
				end
			end
			
			pNode1:runAction(sequence1)
		end
	end))
	pNode:runAction(sequence)
end

-- 获取玩家位置世界坐标
function UIElemChat:getPlayerPosition(playerId)
	local playerInfo = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(playerId)
	local widget = playerInfo:getSeatUI()._imgPlayerIcon
	local x, y = widget:getPosition()
	local position = widget:getParent():convertToWorldSpace(cc.p(x, y))
	return position
end

-- 大便动画特殊处理
function UIElemChat:_shitAnimation(playerId)
	-- 玩家头像四个角的坐标
	local pos =
	{
		{x = -15, y = 30},
		{x = 15, y = 30},
		{x = -15, y = 0},
		{x = 15, y = 0},
	}

	self._expressioninfo = game.service.RoomService.getInstance():getExpressioninfo()
	-- 初始化玩家动画显示个数
	if self._expressioninfo[playerId] == nil then
		local info = {false, false, false, false}
		self._expressioninfo[playerId] = info
	end

	-- 控制动画显示位置
	local index = 1
	for k, v in ipairs(self._expressioninfo[playerId]) do
		if v == false then
			index = k
			break
		end
	end
	
	local position = self:getPlayerPosition(playerId)
	local anim = UI_ANIM.UIAnimManager:getInstance():onShow(
		UI_ANIM.UIAnimConfig.new(
			{
				_path = "csb/Effect_dabian.csb",
				_replay = true
			}
		)
	)
	anim._csbAnim:setScale(0.5)
	position = anim._csbAnim:getParent():convertToNodeSpace(cc.p(position.x + pos[index].x, position.y + pos[index].y))
	anim._csbAnim:setPosition(position)
	self._expressioninfo[playerId][index] = true
	anim._csbAnim:runAction(cc.Sequence:create(cc.DelayTime:create(10), cc.CallFunc:create(function()
		-- 到时间把动画删掉，该位置状态复原
		UI_ANIM.UIAnimManager:getInstance():delOneAnim(anim)
		self._expressioninfo[playerId][index] = false
	end)))
end

-- 付费动画
function UIElemChat:_payAnimation(pNode, ani)
	local time = ani:getDuration() / 60 - 0.5
	local sequence = cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function()
			ani:pause()
		end),
		cc.DelayTime:create(5),
		cc.CallFunc:create(function()
			self._seatUI:getCardParentNode():removeChild(pNode)
		end)
	)
	return sequence
end

-- 免费动画
function UIElemChat:_freeAnimation(pNode, ani)
	local time = ani:getDuration() / 60
	local sequence = cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function()
			self._seatUI:getCardParentNode():removeChild(pNode)
		end)
	)
	return sequence
end

-- 由于原生动画太短，需要自己加载进行播放
--[[
	csb: 文件名称（带路径）
	isLoop: 是否重复播放
	x, y: 动画的位置
]]
function UIElemChat:_createTimeline(csb, isLoop, x, y)
	local pNode = cc.CSLoader:createNode(csb)
	local ani = cc.CSLoader:createTimeline(csb)
	ani:gotoFrameAndPlay(0, isLoop)
	
	self._seatUI:getCardParentNode():addChild(pNode, 10000)
	-- 转一下本地坐标
	pNode:setPosition(pNode:convertToNodeSpace(cc.p(x, y)))
	pNode:runAction(ani)
	return pNode, ani
end

return UIElemChat