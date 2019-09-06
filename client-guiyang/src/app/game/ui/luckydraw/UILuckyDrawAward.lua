local super = require("app.game.ui.UITurnCardAward")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UILuckyDrawAward= class("UILuckyDrawAward",  super)

function UILuckyDrawAward:onShow(nPage)
	self:_refreshAwardList()
	self:_refreshRedState()	

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):addEventListener("EVENT_AWARD_LIST_INFO", handler(self, self._onProcessAwardListInfo), self)		--处理中奖列表消息
	game.service.GiftService:getInstance():addEventListener("EVENT_GCApplyGoodsRES", handler(self, self._onProcessGiftStateChange), self)
end


function UILuckyDrawAward:_refreshAwardList()
	local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getRecordItems()
	self._listVirtual:deleteAllItems()
	self._listPhysical:deleteAllItems()
	self._nVirtual = 0
	self._nPhysical = 0
	for i = 1,#data do
		local info = data[i]
		-- if data[i].prizeType ~= 7 then
			self._listVirtual:pushBackItem(info)
			self._nVirtual = self._nVirtual + 1
		-- else
			-- self._listPhysical:pushBackItem(info)
			-- self._nPhysical = self._nPhysical + 1
		-- end
	end
	if self._nCurPage == 1 then
		self._imageNone:setVisible(self._nVirtual == 0)
	else
		self._imageNone:setVisible(self._nPhysical == 0)
	end
end

--关闭
function UILuckyDrawAward:_onClickClose()
	UIManager:getInstance():hide("UILuckyDrawAward")	
end




function UILuckyDrawAward:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):removeEventListenersByTag(self)
    game.service.GiftService:getInstance():removeEventListenersByTag(self)
end
return UILuckyDrawAward
