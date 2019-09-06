-- local csbPath = "ui/csb/Activity/Christmas/fp3.csb"
local csbPath = "ui/csb/UIFPYJ3.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local UITurnCardChance = class("UITurnCardChance", require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

-- local chance_config = {
-- 	'每日首次登陆可翻牌一次',
-- 	'比赛场获胜%d次可翻牌%d次',
-- 	'金币场获胜%d次可翻牌%d次',
-- 	'每日首次分享可翻牌%d次',
-- 	'在好友桌完成%d局可翻牌%d次',
-- 	'获得%d次大赢家可翻牌%d次',
-- 	'参与%d次比赛场可翻牌%d次',
-- 	'进行%d局金币场对局可翻牌%d次',
-- 	'进行%d局金币场对局可翻牌%d次',
-- }
local chance_config = {
	'每日登录',
	'比赛场获胜%d次可翻牌%d次',
	'金币场获胜%d次可翻牌%d次',
	'每日首次分享可翻牌%d次',
	'好友局%d局',
	'获得%d次大赢家可翻牌%d次',
	'比赛场%d局',
	'金币场%d局',
	'2房卡购买机会一次',
}

function UITurnCardChance:ctor()
	self._cards = {}
end

function UITurnCardChance:dispose()
end

function UITurnCardChance:init()
	
	--翻牌机会
	self._panelChance = seekNodeByName(self, "Panel_b", "ccui.Layout")
	self._listChance = seekNodeByName(self._panelChance, "ListView_Award_Physical", "ccui.ListView")
	self._listChance:setScrollBarEnabled(false)
	self._layoutChance = seekNodeByName(self._panelChance, "Panel_Award_record", "ccui.Layout")
	self._layoutChance:setVisible(false)
	self._layoutChance:removeFromParent()	
	self:addChild(self._layoutChance)
	
	self._textTitle = seekNodeByName(self, "textTitle", "ccui.TextBMFont")
	
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	
	
	
	self:_registerCallBack()
end

function UITurnCardChance:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UITurnCardChance:needBlackMask()
	return true
end

function UITurnCardChance:closeWhenClickMask()
	return false
end

function UITurnCardChance:onShow(title)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_TASK_INFO", handler(self, self._onProcessChanceInfo), self) 			--处理机会消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryChanceInfo()
	self:_refreshChanceList()
	if title then
		self._textTitle:setString(title)
	end
end

function UITurnCardChance:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
end

--创建任务节点
function UITurnCardChance:_createOneChanceNode(info)
	local function getButtonString()
		if info.taskType == 2 or info.taskType == 3 or info.taskType == 7 or info.taskType == 8 then
			return(info.needCount - info.missCount) .. "/" .. info.needCount
		elseif info.taskType == 4 then
			return "分享"
		elseif info.taskType == 5 or info.taskType == 6 then
			return(info.needCount - info.missCount) .. "/" .. info.needCount
		elseif info.taskType == 9 then
			return "获取机会"
		end
	end
	
	
	local node = self._layoutChance:clone()
	node:setVisible(true)
	if info.taskType <= #chance_config then
		local text = node:getChildByName('Text_Date')
		local str = chance_config[info.taskType]
		str = string.format(str, info.needCount, info.chanceCount)
		text:setString(str)
		
		local btn = node:getChildByName("Button_info")
		local textBtn = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_4")
		if info.isFinish then
			btn:setVisible(false)
			textBtn:setVisible(false)
		else
			node:getChildByName("Image_8"):setVisible(false)
			btn:setTag(info.taskType)
			textBtn:setString(getButtonString())
			bindEventCallBack(btn, handler(self, self._onClickDoTask), ccui.TouchEventType.ended)
			-- if info.taskType == 5 or info.taskType == 6 then
			-- 	btn:setVisible(false)
			-- end
		end
	end
	return node
end

function UITurnCardChance:_refreshChanceList()
	local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceInfo()
	self._listChance:removeAllChildren()
	for i = 1, #data do
		local info = data[i]
		local node = self:_createOneChanceNode(info)
		self._listChance:pushBackCustomItem(node)
	end
end
--关闭
function UITurnCardChance:_onClickClose()
	UIManager:getInstance():hide("UITurnCardChance")
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):setNeedRecover(false)
end

function UITurnCardChance:_onClickDoTask(sender)
	local tag = sender:getTag()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Mission_CLICK .. tag)
	if tag == 2 or tag == 7 then --	goto比赛场
		game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
	elseif tag == 3 or tag == 8 then -- goto金币场
		GameFSM.getInstance():enterState("GameState_Gold")
	elseif tag == 4 then --do 分享
		local data =
		{
			enter = share.constants.ENTER.TURN_CARD_SHARE,
		}
		share.ShareWTF:getInstance():share(share.constants.ENTER.TURN_CARD_SHARE, {data, data, data}, handler(self, self._onShareCompleted))
		-- game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryShareInfo()
	elseif tag == 5 or tag == 6 then -- 完成6局游戏
		uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
	elseif tag == 9 then
		if game.service.LocalPlayerService:getInstance():getCardCount() < 2 then
			--购买房卡
			game.ui.UIMessageBoxMgr.getInstance():show("房卡不足，是否前往商城购买", {"购买", "取消"}, function()
				CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
			end)
		else
			--购买点火机会
			game.ui.UIMessageBoxMgr.getInstance():show("是否确定使用2张房卡购买一次点火机会", {"确定", "取消"}, function(...)
				game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):CACFlopCardBuyREQ()
				self:_onClickClose()
			end)
		end
	else
		return
	end
	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):setNeedRecover(true)
end

--分享完成
function UITurnCardChance:_onShareCompleted()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryShareInfo()
	UIManager:getInstance():hide("UITurnCardChance")
end

function UITurnCardChance:_onProcessChanceInfo()
	self:_refreshChanceList()
end

return UITurnCardChance
