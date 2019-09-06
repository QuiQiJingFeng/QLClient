-- local csbPath = "ui/csb/Activity/Christmas/fp.csb"
local csbPath = "ui/csb/UIFPYJ.csb"
local UIItem = require("app.game.ui.element.UIItem")

local UITurnCard = class("UITurnCard", require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UITurnCard:ctor()
	self._cards = {}
	self.isShowLED = true -- 其他地区可能不显示，就此做一个开关
end


function UITurnCard:init()
	--牌池
	self._panelCards = seekNodeByName(self, "Panel_1_0", "ccui.Layout")
	--单张牌
	self._layoutCard = seekNodeByName(self, "Panel_3", "ccui.Layout")
	self._layoutCard:removeFromParent()
	self._layoutCard:setVisible(false)
	
	self:addChild(self._layoutCard)
	
	--中奖文本
	self._panelAwardList = seekNodeByName(self, "Panel_1", "ccui.Layout")
	self._textAwardList = seekNodeByName(self, "Text_1", "ccui.Text")
	
	-- 翻牌按钮
	self._btnTurn = seekNodeByName(self, "Button_1_0_1", "ccui.Button")
	self._textNum = seekNodeByName(self, "Text_3_0",	"ccui.Text")
	
	
	--领取翻牌机会
	self._btnGetChance = seekNodeByName(self, "Button_1_0", "ccui.Button")
	
	--我的奖品
	self._btnMyAward = seekNodeByName(self, "Button_1_0_0", "ccui.Button")
	
	--关闭
	self._btnClose = seekNodeByName(self, "Button_x_CardInfo", "ccui.Button")
	
	--帮助按钮
	self._btnHelp = seekNodeByName(self, "Button_2", "ccui.Button")
	
	--通告
	self._panelLED = seekNodeByName(self, "Panel_1", "ccui.Layout")
	self._panelLED:setClippingEnabled(true)
	self._textLED = seekNodeByName(self, "Panel_2", "ccui.Layout")
	self._textLED2 = seekNodeByName(self, "Panel_2_0", "ccui.Layout")
	self._textLED2:setPositionX(self._panelLED:getContentSize().width)
	self._panelLED:setVisible(self.isShowLED)
	self._panelLED:setVisible(self.isShowLED)
	self._textLED:setVisible(self.isShowLED)
	self._textLED2:setVisible(self.isShowLED)
	self._textLED2:setVisible(self.isShowLED)
	
	
	self:_registerCallBack()
	self:_refreshLED()
end

function UITurnCard:_registerCallBack()
	bindEventCallBack(self._btnTurn, handler(self, self._onClickTurn), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnGetChance, handler(self, self._onClickGetChance), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnMyAward, handler(self, self._onClickMyAward), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
end

function UITurnCard:needBlackMask()
	return true
end

function UITurnCard:closeWhenClickMask()
	return false
end

function UITurnCard:onShow()
	self:_initCards()
	self:_resetCardsPosition()
	self:_changeCardTouchState(false)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryAcitivityInfo()
	
	self._btnTurn:setTouchEnabled(true)
	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	-- game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_TASK_INFO", handler(self, self._onProcessChanceInfo), self) 			--处理机会消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_AWARD_INFO", handler(self, self._onProcessAwardInfo), self) 	--处理抽奖奖品消息
	-- game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_AWARD_LIST_INFO", handler(self, self._onProcessAwardListInfo), self)		--处理中奖列表消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_CHANCE_CHANGE", handler(self, self._onProcessChancesChange), self); --处理活动消息
end

function UITurnCard:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
end

function UITurnCard:_onProcessChancesChange()
	self:_updateChances()
end

--LED滚动处理
function UITurnCard:_refreshLED()
	if not self.isShowLED then
		return
	end
	local function createOneLED(parent)
		local info = config.TurnCardConfig.getYearStr()
		local textGx = parent:getChildByName("Text_1_0")		
		local textName = parent:getChildByName("Text_1_1")
		textName:setString(info.name)
		local textHd = parent:getChildByName("Text_1_2")
		local textPrize = parent:getChildByName("Text_1_3")
		textPrize:setString(info.prize)
		textName:setPositionX(textGx:getVirtualRendererSize().width + 10)
		textHd:setPositionX(textName:getPositionX() + textName:getVirtualRendererSize().width + 10)
		textPrize:setPositionX(textHd:getPositionX() + textHd:getVirtualRendererSize().width + 10)
		-- parent:setContentSize(cc.size(textPrize:getPositionX() + textPrize:getContentSize().width, 24))
	end
	
	
	local act1 = cc.CallFunc:create(function()
		-- self._textLED:setString(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPrizeStr() or config.TurnCardConfig.getPrizeStr())
		createOneLED(self._textLED)
		self._textLED:setPositionX(self._panelLED:getContentSize().width)
	end
	)
	local act2 = cc.MoveBy:create(15, cc.p(- self._panelLED:getContentSize().width * 1.7, 0))
	
	local act3 = cc.Sequence:create(act1, act2)
	self._textLED:runAction(cc.RepeatForever:create(act3))
	
	
	-- self._textLED2:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(
	-- function()
	-- 	local act4 = cc.CallFunc:create(function()
	-- 		createOneLED(self._textLED2)
	-- 		self._textLED2:setPositionX(self._panelLED:getContentSize().width)
	-- 	end
	-- 	)
	-- 	local act5 = cc.MoveBy:create(8, cc.p(- self._panelLED:getContentSize().width * 1.7, 0))
	-- 	local act6 = cc.Sequence:create(act4, act5)
	-- 	self._textLED2:runAction(cc.RepeatForever:create(act6))
	-- end
	-- )))
	
end

function UITurnCard:_updateOneItem(idx, itemId, reset)
	if not itemId then
		return
	end
	local card = self._cards[idx]
	-- local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getItemByImageId(imageId)
	--改名称
	local textName = seekNodeByName(card, "Text_3", "ccui.Text")
	
	-- 该图片
	local panelParent = seekNodeByName(card, "panelParent", "ccui.Layout")

	UIItem.extend(panelParent, textName, itemId)
	
end
--还原被翻得那张牌，等待下次翻牌
function UITurnCard:_resetSelectCard()
	local idx = self._selectTag
	local card = self._cards[idx]
	
	self:_updateOneItem(idx, card.itemId)
end
-- 处理中奖列表消息
function UITurnCard:_onProcessAwardInfo(event)
	local function getCardByItemId(itemId)
		
		for _, card in pairs(self._cards) do
			if card.itemId == itemId then
				return card
			end	
		end
	end
	
	
	self:_updateChances()
	if event.item then
		--将道具一系列改变成单独的ID
		local itemId = event.item.itemId
		-- 道具类显示道具那个牌
		if PropReader.getTypeById(itemId) == "ConsumableTimeLimite" or
		PropReader.getTypeById(itemId) == "Consumable" or
		PropReader.getTypeById(itemId) == "HeadFrame" then
			itemId = 100663318
		end
		--交换位置
		local selectCard = self._cards[self._selectTag]
		local targetCard = getCardByItemId(itemId)
		self:_updateOneItem(targetCard:getTag(), itemId, true)
		if selectCard ~= targetCard then
			local x, y = selectCard:getPosition()
			selectCard:setPosition(targetCard:getPosition())
			targetCard:setPosition(cc.p(x, y))
			self._selectTag = targetCard:getTag()
		end
		--翻牌
		for i = 1, 8 do
			local card = self._cards[i]
			local actDelay = cc.DelayTime:create(1.2)
			local act1 = cc.RotateBy:create(0.3, cc.vec3(0, 90, 0))	
			local act2 = cc.CallFunc:create(function()
				card:getChildByName("Image_2"):setVisible(true)
			end)
			
			local act3 = cc.RotateBy:create(0.3, cc.vec3(0, 90, 0))
			if self._selectTag == i then
				local actEnd = cc.CallFunc:create(handler(self, self._actionEnd))
				local actDelay2 = cc.DelayTime:create(2.2)
				
				card:runAction(cc.Sequence:create(act1, act2, act3, actDelay2, actEnd))
				
				--加上动画效果
				local node = cc.CSLoader:createNode("ui/csb/Effect_Glow.csb")
				local animAction = cc.CSLoader:createTimeline("ui/csb/Effect_Glow.csb")
				animAction:gotoFrameAndPlay(0, true)
				node:runAction(animAction)
				node:setTag(100001)
				node:setPosition(cc.p(card:getPosition()))
				self._panelCards:addChild(node)
			else
				card:runAction(cc.Sequence:create(actDelay, act1, act2, act3))
			end
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips("您现在不能抽奖")
	end	
end
function UITurnCard:_actionEnd()
	local targetCard = self._cards[self._selectTag]
	local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPrizeItem()
	
	self._btnTurn:setTouchEnabled(true)
	UIManager:getInstance():show("UITurnCardItem", self)
	local card = self._cards[self._selectTag]
	self._panelCards:removeChildByTag(100001)
end

--处理抽奖机会信息
function UITurnCard:_onProcessChanceInfo()
	UIManager:getInstance():show("UITurnCardChance")
end
--处理活动消息
function UITurnCard:_onProcessActivityInfo(data)
	self:_updateItemsInfo()
	self:_updateChances()
end

--更新物品信息
function UITurnCard:_updateItemsInfo()
	-- local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getAllShowItems()
	local itemIds = config.TurnCardConfig.itemIds
	local i = 1
	for _, itemId in pairs(itemIds) do
		local card = self._cards[i]
		card.itemId = itemId
		card:setVisible(true)
		self:_updateOneItem(i, itemId)
		
		
		i = i + 1
	end
end

--更新次数
function UITurnCard:_updateChances()
	if(self._textNum) then
		self._textNum:setString("剩余:" .. game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum() .. "次")
	end
end


function UITurnCard:_initCards()
	if #self._cards == 0 then
		for i = 1, 8 do
			local card = self._layoutCard:clone()
			card:setLocalZOrder(9 - i)
			card:setTag(i)
			card:setAnchorPoint(cc.p(0.5, 0.5))
			self._panelCards:addChild(card)
			
			
			self._cards[i] = card
			card:setTouchEnabled(false)
			
			
			card:addClickEventListener(handler(self, self._onClickCard))
		end
	end
end
--获取卡牌位置
function UITurnCard:_getCardPositionByIdx(idx)
	local posX =((idx - 1) % 4 + 0.5) *(self._panelCards:getContentSize().width / 4)
	local posY =((idx <= 4 and 1 or 0) + 0.5) * self._layoutCard:getContentSize().height
	posY = idx <= 4 and posY + 5 or posY
	return cc.p(posX, posY)
end
--重置卡牌位置
function UITurnCard:_resetCardsPosition()
	self._panelCards:removeChildByTag(100001)
	if #self._cards ~= 8 then
		self:_initCards()
	end
	for i = 1, 8 do
		local card = self._cards[i]
		card:stopAllActions()
		card:setRotation3D(cc.vec3(0, 0, 0))
		card:getChildByName("Image_2"):setVisible(true)
		card:setPosition(self:_getCardPositionByIdx(i))
		card:setOpacity(255)
		card:removeChildByTag(100001)
	end
end
--获取卡牌集合点位置
function UITurnCard:_getMidPos()
	local posx =(self._panelCards:getContentSize().width) / 2
	local posy =(self._panelCards:getContentSize().height) / 2
	return cc.p(posx, posy)
end

--改变卡牌点击状态
function UITurnCard:_changeCardTouchState(bTouch)
	for i = 1, 8 do
		self._cards[i]:setTouchEnabled(bTouch)
	end
end
--播放洗牌动画
function UITurnCard:_runCardAction()
	local function getRandomArr()
		local arr = {1, 2, 3, 4, 5, 6, 7, 8}
		for i = 1, 8 do
			local n = math.ceil(8 * math.random())
			arr[i], arr[n] = arr[n], arr[i]
		end
		return arr
	end
	
	local tarPos = self:_getMidPos()
	local arr = getRandomArr()
	for i = 1, 8 do
		local card = self._cards[i]
		--act1：翻转90度，act2：隐藏牌面，act3：继续翻转90度，act4：移动位置
		local act1 = cc.RotateBy:create(0.4, cc.vec3(0, 90, 0))	
		local act2 = cc.CallFunc:create(function()
			card:getChildByName("Image_2"):setVisible(false)
		end)
		local act3 = cc.RotateBy:create(0.4, cc.vec3(0, 90, 0))
		local act4 = cc.MoveTo:create(1, tarPos)
		
		local actDelay = cc.DelayTime:create(i * 0.12)
		local actFadeOut = cc.CallFunc:create(function()
			card:setOpacity(180)
		end)
		local act5 = cc.MoveBy:create(0.13, cc.p(200, 0))
		local act6 = cc.MoveBy:create(0.26, cc.p(- 400, 0))
		local act7 = cc.MoveBy:create(0.13, cc.p(200, 0))
		local act8 = cc.Repeat:create(cc.Sequence:create(act5, act6, act7), 3)
		local actFadeIn = cc.CallFunc:create(function()
			card:setOpacity(255)
		end)
		
		local act9 = cc.DelayTime:create(1 - i * 0.12)
		local act10 = cc.MoveTo:create(0.5, self:_getCardPositionByIdx(arr[i]))
		local act11 = cc.CallFunc:create(function()
			card:setTouchEnabled(true)
			--加上动画效果
			local node = cc.CSLoader:createNode("ui/csb/Effect_fpyj.csb")
			local animAction = cc.CSLoader:createTimeline("ui/csb/Effect_fpyj.csb")
			animAction:gotoFrameAndPlay(0, true)
			node:runAction(animAction)
			node:setTag(100001)
			node:setPosition(cc.p(card:getContentSize().width / 2, card:getContentSize().height / 2))
			card:addChild(node)
			-- self._btnClose:setTouchEnabled(true)
		end)
		
		card:runAction(cc.Sequence:create(act1, act2, act3, act4, actDelay, actFadeOut, act8, actFadeIn, act9, act10, act11))
	end
end
-- 翻牌
function UITurnCard:_onClickTurn()
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum() <= 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("抽奖机会不足")
		return
	end
	
	-- self._btnClose:setTouchEnabled(false)
	self._btnTurn:setTouchEnabled(false)
	-- self:_resetCardsPosition()
	self:_runCardAction()
end

-- 获取机会按钮
function UITurnCard:_onClickGetChance()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Chance_CLICK)
	UIManager.getInstance():show("UITurnCardChance")
end

function UITurnCard:_onClickMyAward()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_My_Award_CLICK)
	UIManager.getInstance():show("UITurnCardAward")
end

function UITurnCard:_onClickCard(sender)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Turn_CLICK)
	
	self._selectTag = sender:getTag()
	
	self:_changeCardTouchState(false)
	
	for i = 1, 8 do
		local card = self._cards[i]
		card:removeChildByTag(100001)
	end
	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryCardInfo()
end

--关闭
function UITurnCard:_onClickClose()
	UIManager:getInstance():hide("UITurnCard")
end

--帮助按钮
function UITurnCard:_onClickHelp(sender)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Rull_CLICK)
	local str = string.gsub(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getRules(), "\\n", "\n")
	UIManager:getInstance():show('UITurnCardHelp', str)
end

return UITurnCard
