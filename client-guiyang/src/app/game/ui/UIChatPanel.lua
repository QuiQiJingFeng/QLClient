-- local EmotionConfig = require("app.config.EmotionConfig") MARK TO DELETE
local EmotionConfig = require("app.config.DynamicEmotionConfig")
local csbPath = "ui/csb/UIChatPanel.csb"
local super = require("app.game.ui.UIBase")
local UIChatPanel = class("UIChatPanel", super, function() return kod.LoadCSBNode(csbPath) end)

function UIChatPanel:ctor()
	self._btnSend = nil;
	self._checkBox_Chat_Text = nil;
	self._checkBox_Chat_Face = nil;
	self._list_Chat_Text = nil;
	self._list_Chat_Face = nil;
	self._textField_Chat = nil;
	self._textFrame_Chat = nil;
	self._defaultCommonTab = true;
end

function UIChatPanel:init()
	self._btnSend = seekNodeByName(self, "Button_fs_Chat", "ccui.Button");
	self._checkBox_Chat_Text = seekNodeByName(self, "CheckBox_Chat_Text", "ccui.CheckBox");
	self._checkBox_Chat_Face = seekNodeByName(self, "CheckBox_Chat_Face", "ccui.CheckBox");
	self._textField_Chat = seekNodeByName(self, "TextField_Chat", "ccui.TextField");
	self._textFrame_Chat = seekNodeByName(self, "Image_text_Chat", "ccui.TextField");
	self._list_Chat_Text = seekNodeByName(self, "ListView_Chat_Text", "ccui.ListView");
	self._list_Chat_Face = seekNodeByName(self, "ListView_Chat_Face", "ccui.ListView");

	self._textElem = ccui.Helper:seekNodeByName(self._list_Chat_Text, "Panel_word_Chat")
    self._textElem:removeFromParent(false)
    self:addChild(self._textElem)
    self._textElem:setVisible(false)
	
	bindEventCallBack(self._btnSend, handler(self, self._onSendCustomMessage), ccui.TouchEventType.ended);
	bindEventCallBack(self._checkBox_Chat_Text, handler(self, self._showCommonWords), ccui.TouchEventType.ended);
	bindEventCallBack(self._checkBox_Chat_Face, handler(self, self._showEmotion), ccui.TouchEventType.ended);
	
	self:_initTablePage();
end

function UIChatPanel:onShow(...)
	local args = {...}
	local inCampaignScene = args[1] == "campaign"
	-- 联盟房间隐藏输入框
	if inCampaignScene or game.service.RoomService:getInstance():getRoomLeagueId() ~= 0 then
		self:_onHideInputField()
	end
	if self._defaultCommonTab then
		self:_showCommonWords(nil);
	else
		self:_showEmotion(nil)
	end
	self:initChatTexts()
end

function UIChatPanel:onHide()
end

function UIChatPanel:initChatTexts()
	-- 初始化常用语界面
	self._list_Chat_Text:removeAllChildren(true)
	
	local _chatService = game.service.ChatService.getInstance();
	local _arr = _chatService:getSoundTexts();
	for i = 1, #_arr do
		local element = self._textElem:clone()
		element:setVisible(true)
		self._list_Chat_Text:addChild(element);
		
		local element = self._list_Chat_Text:getItem(i - 1);
		local _button = seekNodeByName(element, "Button_word_Chat", "ccui.Button");
		local _textWord = seekNodeByName(element, "Text_word", "ccui.Text");
		_textWord:setString(_arr[i]);
		local width = _textWord:getContentSize().width
		local btnWidth = _button:getContentSize().width
		
		-- 贵阳常用语不滑动（不同分辨率下相同数量的文本长度不同，目前先这样处理）
		local areaId = game.service.LocalPlayerService:getInstance():getArea()
		if width > btnWidth and areaId ~= 10002 and areaId ~= 10006 then
			local pos = cc.p(_textWord:getPosition())
			local newPos = clone(pos)
			newPos.x = pos.x -(width - 250)
			local anim = cc.MoveTo:create((width - 250) / 50, newPos);
			
			local callback = cc.CallFunc:create(function()
				_textWord:setPosition(pos)
			end)
			
			local delay = cc.DelayTime:create(0.5)
			_textWord:runAction(cc.Sequence:create(delay, anim, callback))
		end
		-- 绑定回调
		bindEventCallBack(_button, function(sender, _type)
			if self:_checkChatFrequence() then
				-- 统计点击每条常用语按钮的事件数
				game.service.DataEyeService.getInstance():onEvent(string.format("phrase%s", i < 10 and string.format("0%d", i) or tostring(i)));
				
				game.service.ChatService.getInstance():sendBuildinText(i - 1);
				UIManager:getInstance():hide("UIChatPanel", true);
			end;
		end, ccui.TouchEventType.ended);
	end
end

--引擎Bug Button克隆之后图片无法自适应尺寸
--只能这样绕过这个问题
function UIChatPanel:replace(button)
    local newbutton = ccui.Button:create()
    newbutton:setScale9Enabled(false)
    newbutton:setContentSize(button:getContentSize())
    newbutton:ignoreContentAdaptWithSize(false)
    newbutton:setPosition(cc.p(button:getPosition()))
    newbutton:setName(button:getName())
    local parent = button:getParent()
    parent:addChild(newbutton)
    button:removeSelf()
    return newbutton
end

function UIChatPanel:_initTablePage()
	local _chatService = game.service.ChatService.getInstance();
	-- 初始化表情界面
	local _faceElem = seekNodeByName(self, "Panel_Face_Chat", "ccui.Layout");
	local perNum = 5
	if EmotionConfig.isDynamic then
		perNum = 4
		_faceElem:retain()
		self._list_Chat_Face:removeAllChildren()
		self._list_Chat_Face:addChild(_faceElem)
		_faceElem:release()
		-- _faceElem:setClippingEnabled(false)
		-- local size = _faceElem:getContentSize()
		-- local unit = size.width/perNum
		-- local firstPos = nil
		-- for i= 1,perNum do
		-- 	local node = seekNodeByName(_faceElem, "Button_Face_" .. i, "ccui.Button");
		-- 	if not firstPos then
		-- 		firstPos = cc.p(node:getPosition())
		-- 	end
  --           node:setPositionX(unit* (i-1) + firstPos.x + 10)
  --           node:setContentSize(cc.size(80,80))
		-- end

	end
	local margin = self._list_Chat_Face:getItemsMargin()
	self._list_Chat_Face:setItemModel(_faceElem);
	local count = EmotionConfig.getCount();
	local _line = math.ceil(count / perNum);
	local index = 0;
	for i = 1, _line do
		if 1 < i then
			self._list_Chat_Face:pushBackDefaultItem();
		end
		local element = self._list_Chat_Face:getItem(i - 1);
		for j = 1, perNum do
			local _button = seekNodeByName(element, "Button_Face_" .. j, "ccui.Button");
            if index < count then
				_button = self:replace(_button)
				local _path = EmotionConfig.getTexture(index);
				_button:loadTextures(_path, _path, _path, ccui.TextureResType.plistType);
				-- 绑定回调
				local _index = index;
				bindEventCallBack(_button, function(sender, _type)
					if self:_checkChatFrequence() then	
						game.service.ChatService.getInstance():sendEmotion(_index);
						UIManager:getInstance():hide("UIChatPanel", true);
					end;
				end, ccui.TouchEventType.ended);
			else
				_button:setVisible(false);	
			end
			index = index + 1;
		end
	end
end

-- 检测是否发送过快
function UIChatPanel:_checkChatFrequence()
	if game.service.ChatService.getInstance():checkSendInterval() == true then
		return true;
	end
	
	game.ui.UIMessageTipsMgr.getInstance():showTips("发言间隔中，请稍后")
	return false;
end

function UIChatPanel:_showCommonWords(sender)
	self._list_Chat_Text:setVisible(true);
	self._checkBox_Chat_Text:setLocalZOrder(100);
	self._checkBox_Chat_Text:setSelected(true);
	self._list_Chat_Face:setVisible(false);
	self._checkBox_Chat_Face:setLocalZOrder(50);
	self._checkBox_Chat_Face:setSelected(false);
	
	self._defaultCommonTab = true;
end

function UIChatPanel:_showEmotion(sender)
	self._list_Chat_Text:setVisible(false);
	self._checkBox_Chat_Text:setLocalZOrder(50);
	self._checkBox_Chat_Text:setSelected(false);
	self._list_Chat_Face:setVisible(true);
	self._checkBox_Chat_Face:setLocalZOrder(100);
	self._checkBox_Chat_Face:setSelected(true);
	
	self._defaultCommonTab = false;
end

function UIChatPanel:_onSendCustomMessage(sender)
	if self:_checkChatFrequence() then
		local _str = self._textField_Chat:getString();
		game.service.ChatService.getInstance():sendCustomMessage(_str);
		self._textField_Chat:setString("");
		UIManager:getInstance():hide("UIChatPanel", true);
	end
end
-- 隐藏输入框
function UIChatPanel:_onHideInputField(sender)
	self._textField_Chat:setVisible(false)
	self._textFrame_Chat:setVisible(false)
	self._btnSend:setVisible(false)
end

function UIChatPanel:needBlackMask()
	return true
end

function UIChatPanel:closeWhenClickMask()
	return true
end

return UIChatPanel; 