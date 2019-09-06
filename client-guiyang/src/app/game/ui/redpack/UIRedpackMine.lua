-- local csbPath = "ui/csb/Redpack/UIRedpackMine.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackMine.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")


local strTexts ={
	"拆红包成功",
	"分享拆红包",
	"帮拆成功",
	"获胜一场游戏"
}

local status = {
	success = 1,
	fail = 2,
	waiting = 3,
	needhu = 4,
	candraw = 5
}
local hongbaoType = {
	"新人红包",
	"红包"
}


local UIOpenItem = class("UIOpenItem")

function UIOpenItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIOpenItem)
    self:_initialize()
    return self
end

function UIOpenItem:_initialize()

end


function UIOpenItem:setData(info)
    -- self._data = val

    local textName = self:getChildByName("Text_Name")
	textName:setString(info.nickname)

	local textTime = self:getChildByName("Text_Time")
	textTime:setString(kod.util.Time.dateWithFormat("%Y-%m-%d", info.time/1000))

	local textType = self:getChildByName("Text_Type")
	textType:setString(strTexts[info.type])

	local textPrize = self:getChildByName("Text_Prize")	
	textPrize:setString(info.money.."元")
end

local UIWithdRrawItem = class("UIWithDrawItem")

function UIWithdRrawItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIWithdRrawItem)
    self:_initialize()
    return self
end

function UIWithdRrawItem:_initialize()

end


function UIWithdRrawItem:setData(info)
    -- self._data = val

    local textName = self:getChildByName("Text_Name")
	textName:setString(hongbaoType[info.type])


	local textTime = self:getChildByName("Text_Time")
	textTime:setString(kod.util.Time.dateWithFormat("%Y-%m-%d", info.time/1000))

	local textPrize = self:getChildByName("Text_Prize")
	textPrize:setString(info.money.."元")

	local btnDraw = self:getChildByName("Button_1")
	if info.status == status.needhu then
		btnDraw:setVisible(true)
		btnDraw:getChildByName("BtnText"):setString("去胡牌")
		btnDraw:addClickEventListener(function() 	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club) end)
	elseif info.status == status.candraw then
		btnDraw:setVisible(true)
		btnDraw:getChildByName("BtnText"):setString("提现")
		btnDraw:addClickEventListener(function() 	
			local money = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getNewPlayerMoney()
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryWithDraw(money, true)
		end)
	else
		btnDraw:setVisible(false)
	end
end




local UIRedpackMine= class("UIRedpackMine",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackMine:ctor()
end


function UIRedpackMine:init()
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")	--关闭
	self._listOpen = UIItemReusedListView.extend(seekNodeByName(self, "ListView_Open", "ccui.ListView"), UIOpenItem)
	self._listWithDraw = UIItemReusedListView.extend(seekNodeByName(self, "ListView_WithDraw", "ccui.ListView"), UIWithdRrawItem)

	self._boxOpen = seekNodeByName(self, "CheckBox_Open", "ccui.CheckBox")
	self._boxWithDraw = seekNodeByName(self, "CheckBox_Draw", "ccui.CheckBox")

	self._panelOpen = seekNodeByName(self, "Panel_Open", "ccui.Layout")
	self._panelWithDraw = seekNodeByName(self, "Panel_WithDraw", "ccui.Layout")
	self._panelWithDraw:setVisible(false)
	self._main_cbx_group = CheckBoxGroup.new({self._boxOpen, self._boxWithDraw}, handler(self, self._onCheckBoxGroupMainClick))
end

function UIRedpackMine:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIRedpackMine:onShow()
	local activityServiceMgr = game.service.activity.ActivityServiceManager.getInstance()
	local redpackService = activityServiceMgr:getService(net.protocol.activityServerType.RED_PACK)
	
	redpackService:queryRecord()
	redpackService:addEventListener("REDPACK_RECORDS", handler(self, self._updateRecords), self)
	redpackService:addEventListener("WITH_DRAW_SUCCEED", handler(self, self._onWithDrawSucceed), self)
	self:_registerCallBack()
end

function UIRedpackMine:_onWithDrawSucceed()
	UIManager:getInstance():show("UIRedpackVerify")
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryRecord()
end

function UIRedpackMine:_updateRecords()
	self:_updateOpenRecords()
	self:_updateWithDrawRecords()
end

function UIRedpackMine:_updateOpenRecords()
	local records = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getOpenRecords()
	self._listOpen:deleteAllItems()
	for i = 1,#records do
		self._listOpen:pushBackItem(records[i])
	end
end

function UIRedpackMine:_updateWithDrawRecords()
	local records = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getWithDrawRecords()
	self._listWithDraw:deleteAllItems()
	for i = 1,#records do
		self._listWithDraw:pushBackItem(records[i])
	end
end


function UIRedpackMine:_onCheckBoxGroupMainClick(group, index)
	self._panelOpen:setVisible(index == 1)
	self._panelWithDraw:setVisible(index == 2)
end

function UIRedpackMine:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):removeEventListenersByTag(self)
end

function UIRedpackMine:needBlackMask()
    return true
end

function UIRedpackMine:closeWhenClickMask()
	return false
end

--关闭
function UIRedpackMine:_onClickClose()
	UIManager:getInstance():hide("UIRedpackMine")
end

return UIRedpackMine
