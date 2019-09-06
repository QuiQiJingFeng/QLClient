local csbPath = "ui/csb/Gold/UIGoldMatch.csb"
local super = require("app.game.ui.UIBase")
local UIGoldMatch = class("UIGoldMatch", super, function() return kod.LoadCSBNode(csbPath) end)

local Enum_RoomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade
local ROOM_TYPE = {
	[Enum_RoomGrade.FIRST] = "gold/img_cc1.png",
	[Enum_RoomGrade.SECOND] = "gold/img_cc2.png",
	[Enum_RoomGrade.THIRD] = "gold/img_cc3.png",
	[Enum_RoomGrade.FOUR] = "gold/img_cc4.png",
	[Enum_RoomGrade.QUICK] = "gold/img_cc0.png"
}

function UIGoldMatch:ctor()
	
end

function UIGoldMatch:init()
	self._textGold = seekNodeByName(self, "textGold", "ccui.Text")
	self._textName = seekNodeByName(self, "textName", "ccui.Text")
	self._imgHead = seekNodeByName(self, "ImgHead", "ccui.ImageView")
	
	self._imgRoomGrade = seekNodeByName(self, "Image_RoomGrade", "ccui.ImageView")
	
	self._btnReturn = seekNodeByName(self, "btnReturn", "ccui.Button")
	
	self:_registerCallBack()
	
	self._action = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._action)
	
	
end


function UIGoldMatch:onShow(roomGrade)
	local goldService = game.service.GoldService.getInstance()
	--监听取消匹配事件
	goldService:addEventListener("EVENT_GOLD_MATCH_CANCEL", handler(self, self._onMatchCancel), self)
	
	local LocalPlayerService = game.service.LocalPlayerService.getInstance()
	
	self._textGold:setString(LocalPlayerService:getGoldAmount())
	self._textName:setString(LocalPlayerService:getName())
	self._imgRoomGrade:loadTexture(ROOM_TYPE[roomGrade])
	
	game.util.PlayerHeadIconUtil.setIcon(self._imgHead, LocalPlayerService:getIconUrl())
	game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead, PropReader.getIconById(LocalPlayerService:getHeadFrameId()),0.6)
	
	self._action:gotoFrameAndPlay(0, true)
end

function UIGoldMatch:onHide()
	local goldService = game.service.GoldService.getInstance()
	goldService:removeEventListenersByTag(self)

end

function UIGoldMatch:_registerCallBack()
	bindEventCallBack(self._btnReturn, handler(self, self._onBtnReturn), ccui.TouchEventType.ended)
end

--取消匹配
function UIGoldMatch:_onBtnReturn(sender)
	game.service.GoldService.getInstance():sendCGoldCancelMatchREQ()
end

--取消匹配成功后的回调
function UIGoldMatch:_onMatchCancel()
	UIManager.getInstance():hide("UIGoldMatch")
	GameFSM.getInstance():enterState("GameState_Gold")
end

return UIGoldMatch 