local csbPath = "ui/csb/UIMyAwardRecord.csb"
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIVirtualItem = class("UIVirtualItem")

function UIVirtualItem.extend(self)
	local t = tolua.getpeer(self)
	if not t then
		t = {}
		tolua.setpeer(self, t)
	end
	setmetatable(t, UIVirtualItem)
	self:_initialize()
	return self
end

function UIVirtualItem:_initialize()
	
end

function UIVirtualItem:setData(info)
	-- self._data = val
	local textDate = self:getChildByName("Text_Date")
	
	textDate:setString(kod.util.Time.dateWithFormat("%m-%d %H: %M", info.winTime / 1000))
	local textName = self:getChildByName("Text_Lbjn")
	textName:setString(info.prizeName)
	
	local btn = self:getChildByName("Button_info_0")
	if info.itemId == 251658244 then
		
		btn:setVisible(true)
		btn:addClickEventListener(function()
			UIManager:getInstance():show("UILuckyDrawGetHongbao")
		end)
	else
		btn:setVisible(false)
	end
end



local UIPhysicalItem = class("UIPhysicalItem")

function UIPhysicalItem.extend(self)
	local t = tolua.getpeer(self)
	if not t then
		t = {}
		tolua.setpeer(self, t)
	end
	setmetatable(t, UIPhysicalItem)
	self:_initialize()
	return self
end

function UIPhysicalItem:_initialize()
	
end

function UIPhysicalItem:setData(info)
	-- self._data = val
	local pNode = self
	local textDate = pNode:getChildByName("Text_Date")	
	
	textDate:setString(kod.util.Time.dateWithFormat("%m-%d %H: %M", info.winTime / 1000))
	
	local textName = pNode:getChildByName("Text_Lbjn")
	textName:setString(info.prizeName)
	
	local btnGet = pNode:getChildByName("Button_Receive")	
	local btnDetail = pNode:getChildByName("Button_info")
	btnGet.goodUID = info.goodUID
	btnDetail.goodUID = info.goodUID
	bindEventCallBack(btnGet, handler(self, self._onClickGetPhysicalItem), ccui.TouchEventType.ended)
	bindEventCallBack(btnDetail, handler(self, self._onClickPhysicalItemDetail), ccui.TouchEventType.ended)
	if info.status and info.status == 0 then
		btnGet:setVisible(true)
		btnDetail:setVisible(false)
	else
		btnGet:setVisible(false)
		btnDetail:setVisible(true)
	end
end

function UIPhysicalItem:_onClickGetPhysicalItem(sender)
	local goodUID = sender.goodUID
	local info = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPhysicalItemInfo(goodUID)
	
	if info then
		UIManager:getInstance():show("UIGiftTextField", info.name, goodUID)
	end
	
end


function UIPhysicalItem:_onClickPhysicalItemDetail(sender)
	local goodUID = sender.goodUID
	local info = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPhysicalItemInfo(goodUID)
	if info then
		UIManager:getInstance():show("UIGiftDetail", info.name, info.phone, info.address, info.logistics, info.order)
	end
end


local UITurnCardAward = class("UITurnCardAward", require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UITurnCardAward:ctor()
	self._cards = {}
	self._nVirtual = 0
	self._nPhysical = 0
	self._nCurPage = 1
end

function UITurnCardAward:init()
	--我的奖励
	self._tabs = CheckBoxGroup.new({
		seekNodeByName(self, "CheckBox_1_fictitious", "ccui.CheckBox"),
		seekNodeByName(self, "CheckBox_2_Physical", "ccui.CheckBox")
	}, handler(self, self._onTabClick))
	
	--实物奖励
	self._listPhysical = UIItemReusedListView.extend(seekNodeByName(self, "ListView_Award_Physical", "ccui.ListView"), UIPhysicalItem)
	self._listPhysical:setScrollBarEnabled(false)
	
	self._imgRed = seekNodeByName(self, "imgGoodsRed", "ccui.ImageView")
	
	--虚拟奖励
	self._listVirtual = UIItemReusedListView.extend(seekNodeByName(self, "ListView_Award_fictitious", "ccui.ListView"), UIVirtualItem)
	self._listVirtual:setScrollBarEnabled(false)
	
	self._imageNone = seekNodeByName(self, "Text_1", "ccui.ImageView")
	
	
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	
	self:_registerCallBack()
	
	self:_onTabClick(nil, 1)
	
end



function UITurnCardAward:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UITurnCardAward:_onTabClick(group, index, _)
	self._nCurPage = index
	if index == 1 then
		self._listVirtual:setVisible(true)
		self._imageNone:setVisible(self._nVirtual == 0)
		self._listPhysical:setVisible(false)
	else
		self._listVirtual:setVisible(false)
		self._listPhysical:setVisible(true)
		self._imageNone:setVisible(self._nPhysical == 0)
	end
end

function UITurnCardAward:_refreshRedState()
	self._imgRed:setVisible(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):hasPhysicalItemToGet())
end

function UITurnCardAward:needBlackMask()
	return true
end

function UITurnCardAward:closeWhenClickMask()
	return true
end

function UITurnCardAward:onShow(type)
	-- self:_refreshAwardList()
	-- self:_refreshRedState()	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_AWARD_LIST_INFO", handler(self, self._onProcessAwardListInfo), self)		--处理中奖列表消息
	game.service.GiftService:getInstance():addEventListener("EVENT_GCApplyGoodsRES", handler(self, self._onProcessGiftStateChange), self)
	if not type then
		self._req = function(...)
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryAwardInfo()
		end
	elseif type == "shuang11" then
		self._req = function(...)
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpiePrizeRecordREQ()
		end
	end
	self._req()
end

function UITurnCardAward:_onProcessAwardListInfo()
	self:_refreshAwardList()
	self:_refreshRedState()
end

function UITurnCardAward:_onProcessGiftStateChange()
	--服务器刷新不够快，所以加了个延迟
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1),
	cc.CallFunc:create(function()
		self._req()
	end)))
end

function UITurnCardAward:_refreshAwardList()
	local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getRecordItems()
	self._listVirtual:deleteAllItems()
	self._listPhysical:deleteAllItems()
	self._nVirtual = 0
	self._nPhysical = 0
	for i = 1, #data do
		local info = data[i]
		if PropReader.getTypeById(info.itemId) ~= "RealItem" then
			self._listVirtual:pushBackItem(info)
			self._nVirtual = self._nVirtual + 1
		else
			self._listPhysical:pushBackItem(info)
			self._nPhysical = self._nPhysical + 1
		end
	end
	if self._nCurPage == 1 then
		self._imageNone:setVisible(self._nVirtual == 0)
	else
		self._imageNone:setVisible(self._nPhysical == 0)
	end
end


function UITurnCardAward:_refreshPhysicalAwardList(data)
	local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getRecordItems()
	for i = 1, #data do
		local info = data[i]
		-- if data[i].prizeType ~= 7 then
		local node = self:_createOneAwardNode(info)
		self._listMyAward:pushBackCustomItem(node)
		-- end
	end
end
--关闭
function UITurnCardAward:_onClickClose()
	UIManager:getInstance():hide("UITurnCardAward")	
end




function UITurnCardAward:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
	game.service.GiftService:getInstance():removeEventListenersByTag(self)
end
return UITurnCardAward
