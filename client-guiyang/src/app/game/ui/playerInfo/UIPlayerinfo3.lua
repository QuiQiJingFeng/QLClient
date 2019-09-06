local csbPath = "ui/csb/UIPlayerinfo3_New.csb"
local super = require("app.game.ui.UIBase")

local UIPlayerinfo3 = class("UIPlayerinfo3", super, function () return kod.LoadCSBNode(csbPath) end)

function UIPlayerinfo3:ctor()
	self._recordID = nil -- 保存id
	self._emojiList = {} -- 创建的表情list的引用
	self._playerId = 0
end

function UIPlayerinfo3:init()
	self._textIP = seekNodeByName(self, "Text_ip", "ccui.Text")
	self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView")
	self._headFrame = seekNodeByName(self, "Image_frame", "ccui.ImageView")
	self._textPlayerName = seekNodeByName(self, "Text_name", "ccui.Text")
	self._textPlayerID = seekNodeByName(self, "Text_id",	"ccui.Text")
	self._btnCopy = seekNodeByName(self, "Button_copy_Playinfo2",	"ccui.Button")
	self._playerIdentify = seekNodeByName(self,'PlayerIdentify',"ccui.ImageView")
	self._panelId = seekNodeByName(self, "PanelId",	"ccui.Layout");
	self._btnAddFriend = seekNodeByName(self, "Button_addFriend", "ccui.Button")
	self._btnOffline = seekNodeByName(self, "Button_offline", "ccui.Button")

	self._panelBg = seekNodeByName(self,"panelBg","ccui.Layout");

	self._listExpression = seekNodeByName(self, "ListView_Expression", "ccui.ListView")
    
    -- 不显示滚动条, 无法在编辑器设置
    self._listExpression:setScrollBarEnabled(false)
	self._listExpression:setTouchEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listExpression, "Panel_node")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

	self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")
		
	self:_registerCallBack()
end

function UIPlayerinfo3:_registerCallBack()
	bindEventCallBack(self._btnCopy, handler(self, self._onBtnCopyID), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnAddFriend, handler(self, self._onClickAddFriend), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnOffline, handler(self, self._onClickOffline), ccui.TouchEventType.ended)
end 

function UIPlayerinfo3:onShow(...)
	local args = {...};

	local palyerInfo = args[1]
	local props = args[2]
	local _textPlayerName = palyerInfo.name;
	local _textPlayerID   = palyerInfo.id;
    local _textIP         = palyerInfo.ip;
	local _imgHead        = palyerInfo.headIconUrl;
	local _identify		  = palyerInfo.identify
	local _headFrame	  = palyerInfo.headframe

	self._playerId = palyerInfo.id

	self._btnAddFriend:setVisible(false)
	-- 邀请上线按钮牌局未开始该玩家掉线
	self._btnOffline:setVisible(not palyerInfo:isOnline() and not game.service.RoomService:getInstance():isHaveBeginFirstGame()and game.service.RoomService:getInstance():getRoomClubId() ~= 0)

	game.service.friend.FriendService.getInstance():addEventListener("EVENT_CHECK_FRIEND_SHIP", handler(self, self._isFriend), self)
	
	-- 刷新魔法表情数量    
	if nil ~= _textPlayerName then
		self._textPlayerName:setString(kod.util.String.getMaxLenString(_textPlayerName, 16));
	end
	
	if nil ~= _textPlayerID then
		self._recordID = _textPlayerID
		self._textPlayerID:setString("ID:".._textPlayerID);
		local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
		-- 如果自己看自己就不向服务器验证是否有好友关系
		-- if self._recordID ~= localRoleId then
		-- 	game.service.friend.FriendService.getInstance():sendCGCheckFriendShipREQ(self._recordID)
		-- end
	end
	
	if nil ~= _textIP then
		self._textIP:setString("IP:".._textIP);
	else
		self._textIP:setString("");
	end
	
	if nil ~= _imgHead then
		game.util.PlayerHeadIconUtil.setIcon(self._imgHead, _imgHead)
	end

	if nil ~= _headFrame then
		game.util.PlayerHeadIconUtil.setIconFrame(self._headFrame,PropReader.getIconById(_headFrame),0.9)
	end

	self._playerIdentify:setVisible(_identify)
	
	local roomType = game.service.RoomService.getInstance():getRoomType()
	
	self._panelId:setVisible(roomType ~= game.globalConst.roomType.gold)

	self:_initExpression()

	self:_refreshEmojInfo(props)
end

function UIPlayerinfo3:_refreshEmojInfo(data)
	-- 将隐藏的显示出来
	table.foreach(data,function (k,v)
		local panel = self._emojiList[string.format("0x%08X", v.itemId)]
		if panel ~= nil then
			local textRestriction = seekNodeByName(panel, "Text_restriction", "ccui.Text")
			local imgCurrency = seekNodeByName(panel, "Image_currency", "ccui.ImageView")
			local textCount = seekNodeByName(panel, "Text_count", "ccui.Text")
			if v.count >= 1 then
				textRestriction:setVisible(true)
				imgCurrency:setVisible(false)
				textCount:setVisible(false)
				textRestriction:setString("剩余:" .. v.count)				
			end
		end
	end)
end

function UIPlayerinfo3:_onClickAddFriend()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Room_AddFriend)
    game.service.friend.FriendService.getInstance():sendCGSendFriendApplicantREQ(self._recordID, game.service.friend.FRIEND_APPLICANT_SOURCE.ROOM)
end

function UIPlayerinfo3:_isFriend(event)
    self._btnAddFriend:setVisible(not event.isFriend)
end

function UIPlayerinfo3:needBlackMask()
	return true;
end

function UIPlayerinfo3:closeWhenClickMask()
	return true
end

function UIPlayerinfo3:_onBtnCopyID()
	if self._recordID ~= nil and game.plugin.Runtime.setClipboard(tostring(self._recordID)) == true then
		game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
		--记录复制ID点击量
		game.service.DataEyeService.getInstance():onEvent("CopyID_Click")
	end	
end

function UIPlayerinfo3:onHide()
	self._listExpression:removeAllChildren()
	self._emojiList = {}
	game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
	game.service.ChatService:getInstance():removeEventListenersByTag(self)
end

-- 魔法表情 
function UIPlayerinfo3:_initExpression()
	self._listExpression:removeAllChildren()
	self._textTips:setVisible(false)
	if game.service.LocalPlayerSettingService:getInstance():getEffectValues().effect_Expression == false then
		self._textTips:setVisible(true)
		return
	end 
	local expressionConfig = game.service.ChatService.getInstance():getExpressionConfig()
	for _, data in ipairs(expressionConfig) do
		local node = self._listviewItemBig:clone()
		self._listExpression:addChild(node)
		node:setVisible(true)
		self:_onListViewInit(node, data)
		if data.id ~= nil then
			self._emojiList[data.id] = node
		end
	end
end

function UIPlayerinfo3:_onListViewInit(node, data)
	local imgExpression = seekNodeByName(node, "Image_expression", "ccui.ImageView")
	local textRestriction = seekNodeByName(node, "Text_restriction", "ccui.Text")
	local imgCurrency = seekNodeByName(node, "Image_currency", "ccui.ImageView")
	local textCount = seekNodeByName(node, "Text_count", "ccui.Text")
	local icon = string.format("art/emotion/%s.png", data.icon)
	imgExpression:loadTexture(icon)
	if tonumber(data.count) ~= nil and tonumber(data.count) == 0 then
		textCount:setString("")
		imgCurrency:setVisible(false)
		textRestriction:setVisible(true)
	else
		textCount:setString("x" .. data.count)
		imgCurrency:setVisible(true)
		textRestriction:setVisible(false)
		imgCurrency:loadTexture(PropReader.getIconById(data.costId))
	end

	bindEventCallBack(imgExpression, function()
		-- 防止玩家已经退出了该界面还显示，发送表情服务器没有判断玩家是否在房间内，所以客户端判断一下该用户是否在该房间内
		if self._recordID ~= nil and game.service.RoomService.getInstance():getPlayerById(self._recordID) ~= nil then
			game.service.DataEyeService.getInstance():onEvent(string.format("%s_new", data.animation))
			game.service.ChatService:getInstance():sendCGSendEmojiREQ(data.id, self._recordID)
		end
		UIManager:getInstance():destroy("UIPlayerinfo3")
	end, ccui.TouchEventType.ended)
end

-- 邀请上线
function UIPlayerinfo3:_onClickOffline()
	local url = config.UrlConfig.getBIUrl("callback_button_bill")
	local localPlayerService = game.service.LocalPlayerService.getInstance()
	local roomService = game.service.RoomService.getInstance()
	local timeService = game.service.TimeService.getInstance()
	local obj = {
		log_time = os.date("%Y-%m-%d %H:%M:%S", timeService:getCurrentTime()),
		room_create_time =  os.date("%Y-%m-%d %H:%M:%S", roomService:getCreateTime() / 1000),
		sub_area_id = localPlayerService:getArea(),
		room_id = roomService:getRoomId(),
		club_id = roomService:getRoomClubId(),
		callback_player_id = localPlayerService:getRoleId(),
		get_callback_player_id = self._playerId,
		gen_date = os.date("%Y-%m-%d", timeService:getCurrentTime()),
	}
	kod.util.Http.uploadInfo(obj, url)

	local data =	{
		enter = share.constants.ENTER.OFFLINE_ROOM_INFO,
	}
	share.ShareWTF.getInstance():share(share.constants.ENTER.OFFLINE_ROOM_INFO, {data, data, data})
end

return UIPlayerinfo3;