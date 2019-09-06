local csbPath = "ui/csb/Choujiang/UIYaoJiang.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UILuckyDraw= class("UILuckyDraw",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UILuckyDraw:ctor()
	self._cards = {}
	self._inDraw = false;		--点击抽奖之后就置为true，防止连续点击
	self._doingAni = false;		--开始动画后置为true，防止动画过程中的断线重连导致可点击 
end


function UILuckyDraw:init()
	self._btnDrawOnce = seekNodeByName(self, "Button_44", "ccui.Button")	--抽一次
	self._btnDrawTen = seekNodeByName(self, "Button_44_0", "ccui.Button")	--抽十次

	self._imageMoneyType = seekNodeByName(self, "Image_1", "ccui.ImageView")	--货币种类
	self._bmfBeans = seekNodeByName(self, "BitmapFontLabel_5", "ccui.TextBMFont") 	--金豆数

	self._panelItem = seekNodeByName(self, "Panel_18_1", "ccui.Layout")
	self._imageItems = {} 	--物品图片
	for i =1,20 do
		self._imageItems[i] = seekNodeByName(self, "Image_Item_"..i, "ccui.ImageView")
		self._imageItems[i]:ignoreContentAdaptWithSize(true)
	end
	self._imageBlink = seekNodeByName(self, "Image_frame", "ccui.ImageView") 	--光标
	self._curIdx = 1				--当前光标位置

	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")	--关闭

	self._btnAddBeas = seekNodeByName(self, "Button_43", "ccui.Button") 	--加金豆按钮

	self._textLED = seekNodeByName(self, "Text_12", "ccui.Text")	--LED灯

	self._textOne = seekNodeByName(self, "BitmapFontLabel_6", "ccui.TextBMFont") --一次消耗
	self._textTen = seekNodeByName(self, "BitmapFontLabel_10", "ccui.TextBMFont") --十次消耗


	self._btnAwardList = seekNodeByName(self, "Button_40", "ccui.Button") 	--中奖记录
	self._btnHelp = seekNodeByName(self, "Button_40_0", "ccui.Button")		--帮助

	self._panelTeach = seekNodeByName(self, "Panel_jiaoxue", "ccui.Layout")	--引导
	self._textTeach = seekNodeByName(self._panelTeach, "Text_2", "ccui.Text") --引导字符串
	self._panelTeach:setVisible(false)

	--引导节点
	self._imageBlock = seekNodeByName(self, "Image_A", "ccui.ImageView")
	self._imageBlock:setLocalZOrder(100000)
	self._panelFather = seekNodeByName(self, "Panel_1", "ccui.Layout")
	self._tenNodes = {}

	--通告
	self._panelLED = seekNodeByName(self, "Panel_17", "ccui.Layout")
	self._panelLED:setClippingEnabled(true)
	self._textLED = seekNodeByName(self, "Panel_2", "ccui.Layout")

	self._textNotice = seekNodeByName(self, "Text_13_0", "ccui.Text")


	--动画效果
	self.animAction = cc.CSLoader:createTimeline(csbPath)
	-- self.animAction:gotoFrameAndPlay(0, true)
	self.animAction:play("animation1",true)
	self:runAction(self.animAction)

	self._panelLight = seekNodeByName(self, "Panel_18", "ccui.Layout")

	self._imageLight = seekNodeByName(self , "Image_34_0", "ccui.ImageView")

	-- self._boxMoney = seekNodeByName(self, "CheckBox_1", "ccui.CheckBox")
	self._imageMoney = seekNodeByName(self, "Image_Money", "ccui.ImageView")

	self:addBlack()
	self:_registerCallBack()
	self:_refreshLED()
end

function UILuckyDraw:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDrawOnce, handler(self, self._onClickDrawOnce), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDrawTen, handler(self, self._onClickDrawTen), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnAwardList, handler(self, self._onClickAwardList), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnAddBeas, handler(self, self._onClickAddBeas), ccui.TouchEventType.ended)
	bindEventCallBack(self._imageMoney, handler(self, self._onBoxMoney), ccui.TouchEventType.ended)
end

function UILuckyDraw:needBlackMask()
    return true
end

function UILuckyDraw:closeWhenClickMask()
	return false
end
function UILuckyDraw:_onBoxMoney(sender)
	local idx = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostIdx()
	idx = idx == 1 and 2 or 1
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):changeCostType(idx)
	self._imageMoney:loadTexture(config.LuckyDrawConfig.imageMoneyConfig[idx])

	self:_updateBeans()
	self:_updateCostIcon()
	self:_updateCostString()
end
--LED滚动处理
function UILuckyDraw:_refreshLED()
	local function createOneLED(parent)
		local info = config.TurnCardConfig.getPrizeStr2()
		local textGx = parent:getChildByName("Text_1_0")		
		local textName = parent:getChildByName("Text_1_1")
		textName:setString(info.name)
		local textHd = parent:getChildByName("Text_1_2")
		local textPrize = parent:getChildByName("Text_1_3")
		textPrize:setString(info.prize)
		textName:setPositionX(textGx:getContentSize().width + 10)
		textHd:setPositionX(textName:getPositionX() + textName:getContentSize().width + 10)
		textPrize:setPositionX(textHd:getPositionX() + textHd:getContentSize().width + 10)
		-- parent:setContentSize(cc.size(textPrize:getPositionX() + textPrize:getContentSize().width, 24))
	end


	local act1 = cc.CallFunc:create(function()
		-- self._textLED:setString(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPrizeStr() or config.TurnCardConfig.getPrizeStr())
		createOneLED(self._textLED)
		self._textLED:setPositionX(self._panelLED:getContentSize().width)
		end
		)
	local act2 = cc.MoveBy:create(12.0, cc.p(-self._panelLED:getContentSize().width * 2 , 0))

	local act3 = cc.Sequence:create(act1, act2)
	self._textLED:runAction(cc.RepeatForever:create(act3))


	-- self._textLED2:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(
	-- 	function()
	-- 		local act4 = cc.CallFunc:create(function()
	-- 			createOneLED(self._textLED2)
	-- 			self._textLED2:setPositionX(self._panelLED:getContentSize().width)
	-- 			end
	-- 			)
	-- 		local act5 = cc.MoveBy:create(8.0, cc.p(-self._panelLED:getContentSize().width * 1.7, 0))
	-- 		local act6 = cc.Sequence:create(act4, act5)
	-- 		self._textLED2:runAction(cc.RepeatForever:create(act6))
	-- 	end
	-- 	)))

end

function UILuckyDraw:onShow()
	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):queryAcitivityInfo()
	self._inDraw = false

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):addEventListener("EVENT_AWARD_INFO", handler(self, self._onProcessAwardInfo), self) 	--处理抽奖奖品消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):addEventListener("EVENT_AWARD_LIST_INFO", handler(self, self._onProcessAwardListInfo), self)		--处理中奖列表消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):addEventListener("EVENT_NO_MONEY", handler(self, self._onProcessNoMoney), self)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):addEventListener("EVENT_FIRST_DRAW", handler(self, self._onProcessFirstDraw), self)


	--货币改变
	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_ROOM_CARD_COUNT_CHANGED", handler(self, self._updateBeans), self)
	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_GOLD_COUNT_CHANGED", handler(self, self._updateBeans), self)
	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_BEAN_COUNT_CHANGED", handler(self, self._updateBeans), self)
	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._reconnected), self)
	
end

function UILuckyDraw:_onProcessActivityInfo()
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getFreeTimes() > 0 then
		self:_showTeach()
	end
	self:_updateBeans()
	self:_updateCostIcon()
	self:_updateCostString()
	self:_updateItems()
	self:_updateDefaultLight()

	local idx = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostIdx()
	-- self._boxMoney:setSelected(idx == 1)
	self._imageMoney:loadTexture(config.LuckyDrawConfig.imageMoneyConfig[idx])
end
function UILuckyDraw:_onProcessFirstDraw()
	self._firstDraw = true
	
end
function UILuckyDraw:_showTeach()
	self._panelTeach:setVisible(true)
	self._textTeach:setString(config.LuckyDrawConfig.strTeachBefore)
end

function UILuckyDraw:_updateDefaultLight()
	local idx = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getDefaultLight()
	if  idx >=1 and idx <=20 then
		self._imageBlink:setPosition(self._imageItems[idx]:getPosition())
		self._curIdx = idx
	end
end

function UILuckyDraw:_onProcessAwardInfo()
	self:_updateCostString()
	local prizeIdx = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getPrizeIdx()
	if #prizeIdx == 1 then
		self:_doDrawOnce(prizeIdx[1])
	elseif #prizeIdx == 10 then
		self:_doDrawTen(prizeIdx)
	end
end
function UILuckyDraw:addBlack()
	self._clipping = cc.ClippingNode:create()
    self:addChild(self._clipping)
    -- self._clipping:setLocalZOrder(-1)

	self._backgroung = cc.Node:create()
    self._foregroung = cc.Node:create()
    self._clipping:addChild(self._backgroung)
    self._clipping:setStencil(self._foregroung)

	self._bgImageView = ccui.ImageView:create("img/img_black2.png")
	self._bgImageView:setScale9Enabled(true)
	self._bgImageView:setContentSize(CC_DESIGN_RESOLUTION.screen.size())
    self._bgImageView:setPosition(cc.p(568, 320))
    self._backgroung:addChild(self._bgImageView)

	self._fgSprite = ccui.ImageView:create("art/function/img_Mask.png")
	-- self._fgSprite:setScale9Enabled(true)
	-- self._fgSprite:setContentSize(self._pane)
    self._fgSprite:setPosition(self._panelLight:getPosition())
    self._foregroung:addChild(self._fgSprite)
	
	self._clipping:setVisible(false)
	self._clipping:setAlphaThreshold( 0.05 )
	self._clipping:setInverted(true)
end
function  UILuckyDraw:_onProcessAwardListInfo()
	-- print("prepare to process awar list info")
	UIManager:getInstance():show("UILuckyDrawAward")
end
--设置奖品
function UILuckyDraw:_updateItems()
	local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getAllItems()
	for _,item in pairs(items) do
		local icon = config.LuckyDrawConfig.getImagePath(item.name)
		-- print("updateItems", item.id, icon)
		self._imageItems[item.id]:loadTexture(icon)
	end
end
--设置消耗种类
function UILuckyDraw:_updateCostIcon()
	local iconPath = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostIcon()
	if cc.FileUtils:getInstance():isFileExist(iconPath) then
		self._imageMoneyType:loadTexture(iconPath)
	end
end
--设置消耗数量
function UILuckyDraw:_updateCostString()
	local strOne,strTen = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostString()
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getFreeTimes() > 0 then
		self._textOne:setString("免费")
	else
		self._textOne:setString(strOne)
	end
	self._textTen:setString(strTen)
	self._textNotice:setString("十连摇可省"..strOne.."哦")
end

function UILuckyDraw:_updateBeans()
	local costType = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostType()
	if costType == 0x0F000001 then 	--金豆
		self._bmfBeans:setString("".. game.service.LocalPlayerService.getInstance():getBeanAmount())
	elseif costType == 0x0F000002 then --房卡
		self._bmfBeans:setString("".. game.service.LocalPlayerService.getInstance():getCardCount())
	elseif costType == 0x0F000003 then --金币
		self._bmfBeans:setString("".. game.service.LocalPlayerService.getInstance():getGoldAmount())
	end
end

function UILuckyDraw:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):removeEventListenersByTag(self)
	game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
	self:_updateDefaultLight()
end

--关闭
function UILuckyDraw:_onClickClose()
	if self._inDraw then
		return 
	end
	UIManager:getInstance():hide("UILuckyDraw")
end
--抽一次
function UILuckyDraw:_onClickDrawOnce()
	if self._inDraw then
		return 
	end
	self._panelTeach:setVisible(false)
	self._inDraw = true
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):queryDrawInfo(1)
end
--抽十次
function UILuckyDraw:_onClickDrawTen()
	if self._inDraw then
		return 
	end
	self._inDraw = true
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):queryDrawInfo(10)
end
--移动光标
function UILuckyDraw:_moveBlink()
	self._curIdx = self._curIdx%20 + 1
	self._imageBlink:setPosition(self._imageItems[self._curIdx]:getPosition())
end
--单次抽奖结束
function UILuckyDraw:_endOneDraw()
	-- self.animAction:gotoFrameAndPlay(0, true)
	self._doingAni = false
	self.animAction:play("animation1",true)
	local delay = cc.DelayTime:create(0.5)
	local show = cc.CallFunc:create(function()
		UIManager.getInstance():show("UILuckyDrawItem", self)
		self._inDraw = false
	end)
	self:runAction(cc.Sequence:create(delay, show))	
end
--十次抽奖结束
function UILuckyDraw:_endTenDraw()
	self._doingAni = false
	manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_GetItem, false)
	self.animAction:play("animation1",true)
	self:_endRunSound()
	self._imageLight:setScale(1.0)
	local delay = cc.DelayTime:create(3.0)
	local show = cc.CallFunc:create(function()
		self._imageBlock:setVisible(true)
		manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_TenEnd, false)
		UIManager.getInstance():show("UILuckyDrawTenItems")
		self:showBlack(false)
		self._inDraw = false
	end)
	self:runAction(cc.Sequence:create(delay, show))	
end
--创建移动序列
function UILuckyDraw:_createActionsByTimeArray(timeArr)
	local actions = {}
	for i = 1, #timeArr do
		local act1 = cc.CallFunc:create(handler(self, self._moveBlink))
		local act2 = cc.DelayTime:create(timeArr[i])		
		table.insert(actions, act1)
		table.insert(actions, act2)
	end
	return actions
end
--播放抽一次的动画
function UILuckyDraw:_doDrawOnce(endIdx)
	self._doingAni = true
	self.animAction:play("animation0", true)
	local function createTimeArray(beginIdx , endIdx)
		local timeArr = {}
		for i = 1,5 do
			timeArr[i] = 0.5 - 0.08 * i; 
		end
		local n = endIdx - beginIdx - 10
		n = n < 0 and (n+20) or n
		for i = 1, n + 60 do
			table.insert(timeArr, 0.03)
		end
		for i = 5,1,-1 do
			table.insert(timeArr, timeArr[i])
		end		
		return timeArr
	end	

	local beginIdx = self._curIdx;	

	local timeArr = createTimeArray(beginIdx, endIdx)
	local actions = self:_createActionsByTimeArray(timeArr)
	local actionEnd = cc.CallFunc:create(handler(self, self._endOneDraw))
	table.insert(actions, actionEnd)

	local act = cc.Sequence:create(actions)

	
	self._imageBlink:runAction(act)
	self:_playBeginSound()
end
function UILuckyDraw:_playBeginSound()	
	manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_Begin, false)
	local delay = cc.DelayTime:create(1.2)
	local delay2 = cc.DelayTime:create(2.8)
	self:runAction(cc.Sequence:create(delay,cc.CallFunc:create(handler(self, self._playRunSound))))
	self:runAction(cc.Sequence:create(delay2,cc.CallFunc:create(handler(self, self._playEndSound))))
end
function UILuckyDraw:_playRunSound(n)
	self._curSound = manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_Run1, true)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.22),
		cc.CallFunc:create(function()
			self._curSound2 = manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_Run2, true)
		end)
	))
	-- local delay = cc.DelayTime:create(0.3)
	-- local sequence = cc.Sequence:create(cc.CallFunc:create(function()
	-- 			manager.AudioManager:getInstance():playEffect("sound/SFX/Choujiang/run.mp3", false)
	-- 		end), delay)
	-- local action = cc.Repeat:create(sequence, 50)
	-- action:setTag(100)
	-- self:runAction(action)
end
function UILuckyDraw:_endRunSound()
	if self._curSound then
		manager.AudioManager:getInstance():stopEffect(self._curSound)
	end
	if self._curSound2 then
		manager.AudioManager:getInstance():stopEffect(self._curSound2)
	end
end
function UILuckyDraw:_playEndSound()
	self:_endRunSound()
	manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_End, false)
end
--播放抽十次的动画
function UILuckyDraw:_doDrawTen(arr)
	self._doingAni = true
	self._imageLight:setScale(2.0)
	self.animAction:play("animation0", true)
	arr[0] = self._curIdx
	local function createTimeArray(beginIdx , endIdx)
		local timeArr = {}
		local n = endIdx >= beginIdx and (endIdx - beginIdx) or (20 + endIdx - beginIdx)
		for i = 1, n + 20 do
			table.insert(timeArr, 0.028)
		end
		return timeArr
	end
	
	local tenactions = {}
	for i = 1,#arr do
		local timeArr = createTimeArray(arr[i -1], arr[i])
		local actions = self:_createActionsByTimeArray(timeArr)
		if i ~= #arr then
			local actFunc = cc.CallFunc:create(function()
				self:_addBlink(arr[i]) 
				manager.AudioManager:getInstance():playEffect(config.LuckyDrawConfig.soundConfig.Sound_GetItem, false)
				end)
			table.insert(actions, actFunc)
			local actDelay = cc.DelayTime:create(0.3)
			table.insert(actions, actDelay)
			
		end
		local act = cc.Sequence:create(actions)
		
		table.insert(tenactions, act)
	end	
	local actionEnd = cc.CallFunc:create(handler(self, self._endTenDraw))
	table.insert(tenactions, actionEnd)
	local actionTotal = cc.Sequence:create(tenactions)
	self._imageBlink:runAction(actionTotal)

	self:runTenAwardAnimation()
	self:showBlack(true)
end
function UILuckyDraw:_addBlink(v)
	local idx = v

	if idx < 1 or idx > 20 then
		return
	end
	self._imageItems[idx]:removeAllChildren()
	local blink = cc.CSLoader:createNode("ui/csb/Choujiang/Effect_shanguang2.csb")
	local action = cc.CSLoader:createTimeline("ui/csb/Choujiang/Effect_shanguang2.csb")
	action:gotoFrameAndPlay(0, false)

	blink:setPosition(self._imageItems[idx]:getPosition())
	blink:runAction(action)
	local dur = action:getDuration()
	-- local speed = action:getTimeSpeed()
	self._panelItem:addChild(blink)
	self._imageItems[idx]:runAction(cc.Sequence:create(cc.DelayTime:create(dur/ 60) , cc.CallFunc:create(function() blink:removeFromParent() end)))

end
--创建10个中奖物品
function UILuckyDraw:_createTenNodes()
	if #self._tenNodes == 10 then
		return
	end
	self._tenActions = {}
	for i = 1,10 do
		local pNode = cc.CSLoader:createNode("ui/csb/Choujiang/Effect_shanguang.csb")
		pNode:setVisible(false)
		local action = cc.CSLoader:createTimeline("ui/csb/Choujiang/Effect_shanguang.csb")
		action:setTag(1000)
		pNode:runAction(action)
		pNode:setPositionY(23)
		self._panelFather:addChild(pNode)
		self._tenNodes[i] = pNode
		self._tenActions[i] = action
	end
end
--播放中奖物品动画
function UILuckyDraw:runTenAwardAnimation()
	local function loadItemIcon(parentNode, item)
		local image = seekNodeByName(parentNode, "Image_3", "ccui.ImageView")
		image:getParent():removeChildByName("head_frame")
		-- if item.type < 0x03000001 or item.type > 0x03100005 then
		if item.type < 0 or PropReader.getTypeById(item.type) ~= "HeadFrame" then
			image:setVisible(true)
			
			image:loadTexture(config.LuckyDrawConfig.getImagePath(item.name))
		else
			local info = config.LuckyDrawConfig.getItemById(item.type)
			local pNode = cc.CSLoader:createNode(info.icon)
			pNode:setName("head_frame")
			pNode:setPosition(image:getPosition())
			pNode:setScale(0.6)
			image:getParent():addChild(pNode)
			image:setVisible(false)
		end		
	end

	self:_createTenNodes()
	-- self:_playRunSound()
	self._imageBlock:setVisible(false)
	local width = self._imageBlock:getContentSize().width
	local width1 = 100.00
	local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getPrizeItems()
	for i = 1,10 do
		local pNode = self._tenNodes[i]
		pNode:setVisible(false)
		pNode:setPositionX(width)
		loadItemIcon(pNode, items[i])
		local action = self._tenActions[i]
		local delay = cc.DelayTime:create(1.1 * i)
		local show = cc.CallFunc:create(function()
			pNode:setVisible(true)
			action:gotoFrameAndPlay(0, false)
		end)
		local move = cc.MoveBy:create(5.0, cc.p(-width - 100, 0))
		pNode:runAction(cc.Sequence:create(delay, show, move))
	end
	
end

function UILuckyDraw:showBlack(bVisible)
	self._clipping:setVisible(bVisible)
end

function UILuckyDraw:_onClickHelp()
	if self._inDraw then
		return 
	end
	UIManager:getInstance():show("UILuckyDrawHelp")
end

function UILuckyDraw:_onClickAwardList()
	if self._inDraw then
		return 
	end
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):queryAwardInfo()
end

function UILuckyDraw:_onProcessNoMoney()
	self._inDraw = false
	UIManager:getInstance():show("UILuckyDrawToShop", self)
end

function UILuckyDraw:_showFirstDraw()
	if self._firstDraw then
		self._panelTeach:setVisible(true)
		self._panelTeach:setLocalZOrder(10000)
		local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getPrizeItems()
		local str = string.format( config.LuckyDrawConfig.strTeachAfter, item[1].name)
		self._textTeach:setString(str)
		self._panelTeach:addClickEventListener(function()	self._panelTeach:setVisible(false) end)
		self._firstDraw = false
	end
end

function UILuckyDraw:_onClickAddBeas()
	if self._inDraw then
		return 
	end
	local costType = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostType()
	if costType == 0x0F000001 then 	--金豆
		CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.BEAN)
	elseif costType == 0x0F000002 then --房卡
		CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
	elseif costType == 0x0F000003 then --金币
		CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.GOLD)
	end
	
end

function UILuckyDraw:_reconnected()
	if not self._doingAni then
		self._inDraw = false
	end
end
return UILuckyDraw
