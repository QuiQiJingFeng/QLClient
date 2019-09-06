local csbPath = "ui/csb/Campaign/UIBattleTrusteeship.csb"
local super = require("app.game.ui.UIBase")

local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local UITrusteeship = class("UITrusteeship", super, function() return kod.LoadCSBNode(csbPath) end)

function UITrusteeship:ctor()
	self.bgPanel = nil 
	self.touchPanel = nil 
	self.btnCancle = nil
	self.textState = nil 
	self.hasSendMessage = false --防止发送多次cancle
end

function UITrusteeship:init()
	self.btnCancle = seekNodeByName(self, "Button_qxtg_ready_Battleplay", "ccui.Button");
	self.textState = seekNodeByName(self, "Text_State", "ccui.Text")

	self.touchPanel = seekNodeByName(self, "Panel_ready_Battleplay", "ccui.Layout")
	self.bgPanel = seekNodeByName(self, "Panel_Battleplay", "ccui.Layout")
	self.bgPanel:setTouchEnabled(true)
	
	bindEventCallBack(self.btnCancle,	handler(self, self.onBtnTrusteeship),	ccui.TouchEventType.ended);
	bindEventCallBack(self.bgPanel,	handler(self, self._onTouchEvent),	ccui.TouchEventType.ended)
end

function UITrusteeship:onShow(...)
	self.hasSendMessage = false

	-- 金币场托管保持不变
	local roomType = game.service.LocalPlayerService.getInstance():getCurrentRoomType()
	if roomType and roomType == game.globalConst.roomType.gold then
		self.bgPanel:setTouchEnabled(false)
		self.textState:setVisible(false)
	end 
end

function UITrusteeship:onBtnTrusteeship()
	--改动金币场也需要取消托管
	if	UIManager:getInstance():getIsShowing("UITrusteeship") then
		self:_cancelTrustShip()
	end
end

-- 触摸事件
function UITrusteeship:_onTouchEvent(sender, event)
	local location = sender:getTouchEndPosition()
	local point = self:convertToNodeSpace(location)
	if not cc.rectContainsPoint(self.touchPanel:getBoundingBox(), point) then 
		self:_cancelTrustShip()
	end 
end 

-- 取消托管
function UITrusteeship:_cancelTrustShip()
	if self.hasSendMessage == false then
		-- TODO:为啥，在游戏结算后还会进来这里？
		-- 先处理一下，如果roomservice不存在后，不发送
		if game.service.RoomService.getInstance() == nil then
			return
		end
		gameMode.mahjong.Context.getInstance():getGameService():sendPlayStep(PlayType.OPERATE_TRUSTEESHIP_CANCLE, {});
		self.hasSendMessage = true
	end
end 

function UITrusteeship:needBlackMask()
	return false;
end

function UITrusteeship:closeWhenClickMask()
	return false
end

return UITrusteeship;
