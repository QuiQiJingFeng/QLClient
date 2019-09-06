--[[	 UIMyAwardRecord.lua (摇钱树我的奖励记录)
--]]
local MoneyTreeConfig = require("app.config.MoneyTreeConfig")

local csbPath = "ui/csb/UIMyAwardRecord.csb"
local super = require("app.game.ui.UIBase")

local UIMoneyTreeMyAwardRecord = class("UIMoneyTreeMyAwardRecord", super, function() return kod.LoadCSBNode(csbPath) end)
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local ListFactory = require("app.game.util.ReusedListViewFactory")

--初始化list控件中的每个单元
local function initDetailList(listItem)
	listItem.date = ccui.Helper:seekNodeByName(listItem, "Text_Date")
	listItem.name = ccui.Helper:seekNodeByName(listItem, "Text_Lbjn")
	listItem.btnReceive = ccui.Helper:seekNodeByName(listItem, "Button_Receive")
	listItem.btnInfo = ccui.Helper:seekNodeByName(listItem, "Button_info")
end

--给list中的控件赋值
local function setListData(listItem, value)
	local d = kod.util.Time.time2Date(value.time / 1000)
	local str = string.format("%d月%d日%d:%02d", d.month, d.day, d.hour, d.min)
	listItem.date:setString(str)
	listItem.name:setString(value.name)
	
	--因为两个list控件接近所以根据有没有对应的控件进行赋值
	if listItem.btnReceive then
		listItem.btnReceive:setVisible(value.data.status == 0)
		bindEventCallBack(listItem.btnReceive,	function() UIManager:getInstance():show("UIGiftTextField", value.name, value.id) end, ccui.TouchEventType.ended)
	end
	
	if listItem.btnInfo then
		listItem.btnInfo:setVisible(value.data.status ~= 0)
		bindEventCallBack(listItem.btnInfo,	function()
			UIManager:getInstance():show("UIGiftDetail", value.data.name, value.data.phone, value.data.address, value.data.logistics, value.data.order)
		end, ccui.TouchEventType.ended)
	end
end


function UIMoneyTreeMyAwardRecord:ctor()
	
	self._btnClose = nil;
	
	--实物,虚拟标签组
	self._tabs = nil
	--虚拟物品列表
	self._listVirtual = nil
	self._isLoadedVirtual = false
	--实物列表
	self._listReality = nil
	self._isLoadedReality = false
	--实物奖励红点
	self._imgGoodsRed = false
end

function UIMoneyTreeMyAwardRecord:init()
	
	self._btnClose	= seekNodeByName(self, "Button_Close", "ccui.Button");
	
	--实物,虚拟标签控件
	self._tabs = CheckBoxGroup.new({
		seekNodeByName(self, "CheckBox_1_fictitious", "ccui.CheckBox"),
		seekNodeByName(self, "CheckBox_2_Physical", "ccui.CheckBox"),
	}, handler(self, self._onTabClick))
	--虚拟奖品list
	self._listVirtual = ListFactory.get(
	seekNodeByName(self, "ListView_Award_fictitious", "ccui.ListView"),
	initDetailList, setListData,
	"listVirtual")
	--实物奖品list
	self._listReality = ListFactory.get(
	seekNodeByName(self, "ListView_Award_Physical", "ccui.ListView"),
	initDetailList, setListData,
	"listVirtual")
	
	self._imgGoodsRed	= seekNodeByName(self, "imgGoodsRed", "ccui.ImageView")
	
	bindEventCallBack(self._btnClose, handler(self, self.onBtnCloseClick), ccui.TouchEventType.ended);
end

function UIMoneyTreeMyAwardRecord:onShow(...)
	
	game.service.GiftService:getInstance():addEventListener("EVENT_RECIEVED_GIFT_LIST", function(event)
		self:_onGiftListRecieve(event.protocol)
	end, self)
	
	game.service.GiftService.getInstance():addEventListener("EVENT_GCApplyGoodsRES", function()
		game.service.GiftService.getInstance():queryGoods(true)
	end, self)
	
	game.service.MoneyTreeService:getInstance():addEventListener("EVENT_MONEY_TREE_GIFT_RED_CHANGE", function(event)
		self:refreshRedPoint(event.red)
	end, self)
	
	self._isLoadedVirtual = false
	self._isLoadedReality = false
	
	self._imgGoodsRed:setVisible(game.service.MoneyTreeService:getInstance():getGoodsRed())
	self._tabs:setSelectedIndex(1)
end

function UIMoneyTreeMyAwardRecord:onBtnCloseClick()
	--返回 
	game.service.GiftService:getInstance():removeEventListenersByTag(self)
	game.service.MoneyTreeService:getInstance():removeEventListenersByTag(self)
	UIManager.getInstance():hide("UIMoneyTreeMyAwardRecord")
end

function UIMoneyTreeMyAwardRecord:needBlackMask()
	return true;
end
--切换标签页回调1是虚拟,2是实物
function UIMoneyTreeMyAwardRecord:_onTabClick(group, index, _)
	if index == 1 then
		self._listVirtual:setVisible(true)
		self._listReality:setVisible(false)
		if not self._isLoadedVirtual then
			self._isLoadedVirtual = true
			self:_loadData(self._listVirtual, game.service.MoneyTreeService:getInstance().awardList)
		end
		
	elseif index == 2 then
		self._listVirtual:setVisible(false)
		self._listReality:setVisible(true)
		
		if not self._isLoadedReality then
			self._isLoadedReality = true
			game.service.GiftService:getInstance():queryGoods(true)
		end
		
	end
end

--设置list的具体内容
function UIMoneyTreeMyAwardRecord:_loadData(list, data, type)
	list:deleteAllItems()
	--根据来源不同读取对应的字段
	local name = "rewardDesc"
	local id = "rewardId"
	local time = "gainTime"
	
	if type == "Reality" then
		name = "goods"
		id = "goodUID"
		time = "time"
	end
	
	for _, v in ipairs(data) do
		list:pushBackItem({name = v[name], id = v[id], time = v[time], data = v})
	end
end
--实物奖励改变回调
function UIMoneyTreeMyAwardRecord:_onGiftListRecieve(protocol)
	self:_loadData(self._listReality, protocol.goodsList, "Reality")
end
--刷新实物奖励红点
function UIMoneyTreeMyAwardRecord:refreshRedPoint(value)
	self._imgGoodsRed:setVisible(value)
end


return UIMoneyTreeMyAwardRecord;

