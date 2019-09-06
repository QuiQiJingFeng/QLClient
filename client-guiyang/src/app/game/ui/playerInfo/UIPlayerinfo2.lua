local csbPath = "ui/csb/UIPlayerinfo2.csb"
local super = require("app.game.ui.UIBase")

local UIPlayerinfo2 = class("UIPlayerinfo2", super, function () return kod.LoadCSBNode(csbPath) end)

function UIPlayerinfo2:ctor()
	self._recordID = nil -- 保存id
end

function UIPlayerinfo2:init()
	self._textIP = seekNodeByName(self, "Text_ip", "ccui.Text")
	self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView")
	self._headFrame = seekNodeByName(self, "Image_frame", "ccui.ImageView")
	self._textPlayerName = seekNodeByName(self, "Text_name", "ccui.Text")
	self._textPlayerID = seekNodeByName(self, "Text_id",	"ccui.Text")
	self._btnCopy = seekNodeByName(self, "Button_copy_Playinfo2",	"ccui.Button")
	self._playerIdentify = seekNodeByName(self,'PlayerIdentify',"ccui.ImageView")
	self._panelId = seekNodeByName(self, "PanelId",	"ccui.Layout");
	self._btnAddFriend = seekNodeByName(self, "Button_addFriend", "ccui.Button")

	self._panelBg = seekNodeByName(self,"panelBg","ccui.Layout");
	
	self:_registerCallBack()
end

function UIPlayerinfo2:_registerCallBack()
	bindEventCallBack(self._btnCopy, handler(self, self._onBtnCopyID), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnAddFriend, handler(self, self._onClickAddFriend), ccui.TouchEventType.ended)
end 

function UIPlayerinfo2:onShow(...)
	local args = {...};
	local _textPlayerName = args[1];
	local _textPlayerID   = args[2];
    local _textIP         = args[3];
	local _imgHead        = args[4];
	local  phone           = args[6]
	local _identify		  = args[5]
	local _headFrame	  = args[6]

	self._btnAddFriend:setVisible(false)
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_CHECK_FRIEND_SHIP", handler(self, self._isFriend), self)
    
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
	local size = self._panelBg:getContentSize()
end

function UIPlayerinfo2:_onClickAddFriend()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Room_AddFriend)
    game.service.friend.FriendService.getInstance():sendCGSendFriendApplicantREQ(self._recordID, game.service.friend.FRIEND_APPLICANT_SOURCE.ROOM)
end


function UIPlayerinfo2:_isFriend(event)
    self._btnAddFriend:setVisible(not event.isFriend)
end

function UIPlayerinfo2:needBlackMask()
	return true;
end

function UIPlayerinfo2:closeWhenClickMask()
	return true
end

function UIPlayerinfo2:_onBtnCopyID()
	if self._recordID ~= nil and game.plugin.Runtime.setClipboard(tostring(self._recordID)) == true then
		game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
		--记录复制ID点击量
		game.service.DataEyeService.getInstance():onEvent("CopyID_Click")
	end	
end

function UIPlayerinfo2:onHide()
    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
end

return UIPlayerinfo2;