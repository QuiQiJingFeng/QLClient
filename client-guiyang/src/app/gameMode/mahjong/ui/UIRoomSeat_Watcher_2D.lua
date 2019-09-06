--[[
-- 观察者，变种Down，用来处理群主察看牌局
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Super = require("app.gameMode.mahjong.ui.UIRoomSeat")
local Constants = require("app.gameMode.mahjong.core.Constants")
local UIRoomSeat_Watcher = class("UIRoomSeat_Watcher", Super)

local BG_WIDTH = 64
local BG_HEIGHT = 94
local BG_WIDTH_LIE = 41
local BG_HEIGHT_LTE = 56

local GROUP_SPACE = 6
local DRAW_CARD_SPACE = 20

local HUA_CARD_SCALE = 0.75
local DISCARDED_CARD_SCALE = 1
local DISCARDED_SEQUENCE_LENGTH = 12
local TOP_PAI_DISCARD_OVERLAY_Z_ORDER = 60 

local BASE_CARD_Z_ORDER = 10
local SHOUPAI_Z_ORDER = BASE_CARD_Z_ORDER + 100
local HU_DARK_MASK_ZORDER = SHOUPAI_Z_ORDER + 100
local HU_SHOUPAI_ZORDER = HU_DARK_MASK_ZORDER + 100
local HU_HEAD_ZORDER = HU_SHOUPAI_ZORDER + 100
local COMBAT_PFX_ZORDER = HU_HEAD_ZORDER + 100
local DISCARDED_INDICATOR_ZORDER = HU_DARK_MASK_ZORDER - 1
local OP_BTN_Z_ORDER = BASE_CARD_Z_ORDER + 1000

local DISCARDED_V_DELTA = 46
local GANG_Y_DELTA = 13
local PREPARED_CARD_Y_DELTA = 26

function UIRoomSeat_Watcher:ctor(parent)
	Super.ctor(self, parent, CardDefines.Chair.Down)

	self._multiSelectList = {}
	self._canMulitSelect = false

	self._draggingCard = false
	self._dragOut = false
	self._operatingCard = nil;	-- 打出的牌，等待服务器回调 因为服务器消息回来之前，lastPopCard可能变化，所以要单独保存
	
	self._root = seekNodeByName(parent, "Panel_player1_Scene", "ccui.Layout")
	self._rootNode = seekNodeByName(parent, "Panel_card_rootNode", "ccui.Layout");
	self._imgHightLight = seekNodeByName(parent, "Img_effect_player1_Scene", "cc.Sprite");
	self._imgPlayerIcon = seekNodeByName(parent, "Icon_img_player1_Scene", "ccui.ImageView");
	self._imgPlayerFrame = seekNodeByName(parent, "Icon_frame_player1_Scene", "cc.Sprite");	
	self._lablePlayerName = seekNodeByName(parent, "Text_name_player1_Scene", "ccui.Text");
	self._lableTotalScore = seekNodeByName(parent, "Text_score_player1_Scene", "ccui.Text");
	self._panelTalk = seekNodeByName(parent, "Panel_talk1_Scene", "ccui.Layout");
	self._imgMessageBorder = seekNodeByName(parent, "Image_talk1_Scene", "ccui.ImageView");
	self._lableMessage = seekNodeByName(parent, "Text_talk1_Scene", "ccui.Text");
	self._imgMessageIcon = seekNodeByName(parent, "bq_talk1_Scene", "cc.Sprite");
	self._imgTalk = seekNodeByName(parent, "Img_xht_player1_Scene", "cc.Sprite");
	self._imgXh1 = seekNodeByName(parent, "Img_xh1_player1_Scene", "cc.Sprite");
	self._imgXh2 = seekNodeByName(parent, "Img_xh2_player1_Scene", "cc.Sprite");
	self._imgXh3 = seekNodeByName(parent, "Img_xh3_player1_Scene", "cc.Sprite");
	self._nodeRTVoice = seekNodeByName(parent, "Node_icon_Label2_player1_Scene", "cc.Node");	
	self._imgReady = seekNodeByName(parent, "z_zb1_direction_Scene", "cc.Sprite");
	self._effectNode = seekNodeByName(parent, "down_mahjongEffect_wiget", "cc.Node");

	self._imgBankerIcon = seekNodeByName(parent, "icon_zhuang_player1_Scene", "cc.Sprite");
	self._imgTrustIcon = seekNodeByName(parent, "icon_trustee_player1_Scene", "cc.Sprite");
	self._imgOffLineIcon = seekNodeByName(parent, "icon_lx_player1_Scene", "ccui.TextBMFont");
	self._imgOffLineTips = seekNodeByName(parent, "Image_Offline_player1", "ccui.ImageView")
	self._imgCustomIcon = seekNodeByName(parent, "icon_Label1_player1_Scene", "cc.Sprite");
	self._imgCustomIcon2 = seekNodeByName(parent, "icon_Label2_player1_Scene", "cc.Sprite");
	self._imgTing = seekNodeByName(parent, "icon_Label3_player1_Scene", "cc.Sprite")
	self._imgLack = seekNodeByName(parent, "icon_Label4_player1_Scene", "cc.Sprite")
	self._bmBankCount = seekNodeByName(parent, "BitmapFontLabel_z_lzicon_player1_Scene", "ccui.TextBMFont")
	self._bgBankCount = seekNodeByName(parent, "Panel_lzicon_player1_Scene", "ccui.Layout")

	self._indicatorCenterImage = seekNodeByName(parent, "Img_bottom_direction_Scene", "cc.Sprite")

	self._discardLayout = seekNodeByName(parent, "discardTips_down", "ccui.Layout")
	self._discardLayout:setVisible(false)

	-- 适配相关，坐标全部转换到960，640的比例下
    local center = CC_DESIGN_RESOLUTION.screen.centerPoint()
    local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()
    local size = CC_DESIGN_RESOLUTION.screen.size()
    local design = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)

    local x2lx = CC_DESIGN_RESOLUTION.screen.toLeft
    local x2rx = CC_DESIGN_RESOLUTION.screen.toRight
    local y2by = CC_DESIGN_RESOLUTION.screen.toButtom
    local y2ty = CC_DESIGN_RESOLUTION.screen.toTop
    local x2px = CC_DESIGN_RESOLUTION.screen.toPercentX
    local y2py = CC_DESIGN_RESOLUTION.screen.toPercentY

	-- 初始化布局
	local cardLayout = self:getCardLayout()
	-- local width = self._parentUI:getContentSize().width
	local width = size.width
	cardLayout.cardAdvance = width / config.GlobalConfig.MAX_HAND_CARDNUMBER;
	-- cardLayout.cardScale = (width - DRAW_CARD_SPACE) / BG_WIDTH / config.GlobalConfig.MAX_HAND_CARDNUMBER;
	cardLayout.cardScale = cardLayout.cardAdvance / BG_WIDTH;
	cardLayout.cardLieAdvance = BG_WIDTH_LIE;
	cardLayout.groupScale = BG_WIDTH * cardLayout.cardScale * 2 / (BG_WIDTH_LIE * 3 + GROUP_SPACE);

	local handOffset = device.platform == "ios" and 7 or 0
	cardLayout.anchor = cc.p(x2lx(21), y2by((BG_HEIGHT + 10)/2*cardLayout.cardScale + handOffset));
	cardLayout.bgAdvance = cc.p(cardLayout.cardAdvance, 0);
	cardLayout.bgAcvanceLie = cc.p(BG_WIDTH_LIE * cardLayout.groupScale, 0);
	cardLayout.drawCardSpace = cc.p(DRAW_CARD_SPACE, 0);
	cardLayout.groupSpace = cc.p(GROUP_SPACE * cardLayout.groupScale, 0);
	cardLayout.gangOffset = cc.p(0, -GANG_Y_DELTA * cardLayout.groupScale-3);
	cardLayout.gangOffsetLie = cc.p(0, -y2by(BG_HEIGHT/2*cardLayout.cardScale)+y2by(BG_HEIGHT_LTE/2*cardLayout.groupScale));
	cardLayout.gangOffsetLie_mingDa = cc.p(0, -y2by(BG_HEIGHT_LTE/2*self:GROUP2_SCALE())+y2by(BG_HEIGHT_LTE/2*cardLayout.groupScale));
	cardLayout.gangZOrderOffset = 1;
	cardLayout.zOrder = SHOUPAI_Z_ORDER + 80;
	cardLayout.zOrderHu = HU_SHOUPAI_ZORDER;
	cardLayout.zOrderAcvance = 0;

	cardLayout.discardedAniStart = cc.p(center.x + offset.x, 150 + offset.y);
	cardLayout.discardedAniStartZOrder = SHOUPAI_Z_ORDER + 200;

	self:updateDiscardedLayout(4);
	cardLayout.discardedLayout.advance = cc.p(BG_WIDTH_LIE * DISCARDED_CARD_SCALE, 0);
	cardLayout.discardedLayout.lineAdvance = cc.p(0, -DISCARDED_V_DELTA * DISCARDED_CARD_SCALE);
	cardLayout.discardedLayout.zOrder = BASE_CARD_Z_ORDER + 80;
	cardLayout.discardedLayout.zOrderAdvance = 0;
	cardLayout.discardedLayout.zOrderLineAcvance = 1;
	cardLayout.discardedLayout.scale = DISCARDED_CARD_SCALE

	cardLayout.huaLayout.lineSize = 4;
	cardLayout.huaLayout.anchor = cc.p(x2px(850),y2py(150));
	cardLayout.huaLayout.advance = cc.p(0, BG_WIDTH_LIE * HUA_CARD_SCALE);
	cardLayout.huaLayout.lineAdvance = cc.p(0, -GANG_Y_DELTA * HUA_CARD_SCALE);
	cardLayout.huaLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huaLayout.zOrderAdvance = 0;
	cardLayout.huaLayout.zOrderLineAcvance = 1;

	cardLayout.huLayout.lineSize = 4;
	cardLayout.huLayout.anchor = cc.p(x2px(850),y2py(150));
	cardLayout.huLayout.advance = cc.p(BG_WIDTH_LIE * HUA_CARD_SCALE, 0);
	cardLayout.huLayout.lineAdvance = cc.p(0, GANG_Y_DELTA * HUA_CARD_SCALE);
	cardLayout.huLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huLayout.zOrderAdvance = 0;
	cardLayout.huLayout.zOrderLineAcvance = 1;

	cardLayout.opBtnAnchor = cc.p(x2px(960),y2py(150));
	cardLayout.opBtnAdvance = cc.p(-1, 0);
	cardLayout.opBtnScale = 1;
	cardLayout.opBtnRotation = 0;
	cardLayout.opBtnZorder = OP_BTN_Z_ORDER

	cardLayout.handCardColor = cc.c3b(255,255,255)
	cardLayout.discardColor = cc.c3b(235,235,235)

	cardLayout.huStatusPosition = cc.p(x2px(570),y2py(240))

	self._elemChat:initialize(self, "animation0", self._panelTalk, self._imgMessageBorder, self._lableMessage, self._imgMessageIcon, 
		self._imgTalk, self._imgXh1, self._imgXh2, self._imgXh3, self._nodeRTVoice)
end

-- 在回放的时候，创建玩家的时候，还没有取到最大玩家数，这时候创建出来的是问题的，需要更新一下
function UIRoomSeat_Watcher:updateDiscardedLayout(maxPlayerCount)
    local x2cx = CC_DESIGN_RESOLUTION.screen.toCenterX
    local y2cy = CC_DESIGN_RESOLUTION.screen.toCenterY
    local center = CC_DESIGN_RESOLUTION.screen.centerPoint()
    local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()
    local size = CC_DESIGN_RESOLUTION.screen.size()
    local design = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
	local cardLayout = self:getCardLayout()
    local isClassical = game.service.GlobalSetting.getInstance().isClassic
    local startx = isClassical and 360 or 370
	if maxPlayerCount == 2 then
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH*2;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(80+42), y2cy(255-BG_HEIGHT_LTE*0.5*DISCARDED_CARD_SCALE));
	else
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(startx+BG_WIDTH_LIE*0.5*DISCARDED_CARD_SCALE + 5), y2cy(250-BG_HEIGHT_LTE*0.5*DISCARDED_CARD_SCALE));
	end
end

-----------------------------
-- 手牌布局相关函数
-----------------------------
-- @param cardGroup: CardGroup 	当前要操作的控件
-- @param index: number 		当前cardGroup的索引
-- @param setPos: boolean 		当前操作的控件是不是
-- @param cardsNeedPlaceHolder: Card[] 		当前组内的牌不设置坐标，只是把正确的坐标传出去
-- @param isMingDa 是否是明打，在对齐的时候使用
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat_Watcher:_getGroupCardPos(cardGroup, index, setPos, cardsNeedPlaceHolder, isMingDa)
	local placeHolders = {}
	local cardLayout = self:getCardLayout()
	
	-- 记录当前的组的所有 坐标，当是最后一个时候，不用重新计算了，直接取用中间的那个
	local pts_back = {};	-- point array
	-- 当牌数少于最大牌数时，做的一个偏移，保持牌看起来是在中间的
	local offset = self._cardOffset;
	-- 当前牌的基准zorder
	local zOrder = cardLayout:getZOrder(self._hasHuWhenBattleFinished);
	
	-- 一个吃碰扛组占用2个竖牌位置
	local currIndex = index * 2 + offset;
	-- 找到当前索引对应所在的坐标

	-- 亮牌后的偏移
	local start = cardLayout.anchor
	if isMingDa and (self._chairType == CardDefines.Chair.Left or self._chairType == CardDefines.Chair.Right) then
		start = cc.pSub(start, cc.pSub(cardLayout.gangOffsetLie_mingDa, cardLayout.gangOffsetLie))
	end

	local pt = cc.pAdd(start, cc.pMul(cardLayout.bgAdvance, currIndex));
	-- 索引对应的zOrder
	zOrder = zOrder + cardLayout.zOrderAcvance * currIndex;
	
	--[[
	-- 由于牌是中心对齐的，所以在设置坐标的时候，一张横牌的占用的空间是两张牌(自己还有下一张)同时计算出来的
	-- 所以要记录一下前面的牌是否是横倒的
	--]]
	local lastIsTrans = false;
	for j=1, #cardGroup.cards do
		local i = j - 1
		local card = cardGroup.cards[j];
		card:changeColor(cardLayout.handCardColor)
		
		-- 步进位置
		local advance = cardLayout:getAdvance(i==0);
		lastIsTrans = card:getChairType() ~= self._chairType;

		-- 牌的修正坐标，为了不影响其它牌，原值是累加的，这一组共用的，这里重新创建一个新的变量
		local ptFix = null;
		zOrder = zOrder + cardLayout.zOrderAcvance
		if i == 3 then
			-- 当是扛牌的那个顶上的牌的时候，这个牌的坐标直接套用中间那张牌就可以了，然后修正坐标以及zorder
			pt = cc.pSub(pts_back[2], cardLayout.gangOffset)
			ptFix = clone(pt);
			zOrder = zOrder + cardLayout.gangZOrderOffset
		else
			pt = cc.pAdd(pt, advance);
			if isMingDa then
				ptFix = cc.pAdd(pt, cardLayout.gangOffsetLie_mingDa);
			else
				ptFix = cc.pAdd(pt, cardLayout.gangOffsetLie);
			end
		end
		
		if setPos == true then
			card:setPosition(ptFix);
			card:setZOrder(zOrder);
			-- TODO：bug 当移动的时候，再次设置坐标，会移动到一个不可控的坐标，清除一下
			if card:getNumberOfRunningActions() > 0 then
				card:stopAllActions()
				card:setScale(self:GROUP_SCALE())
			end
		end
		
		if table.indexof(cardsNeedPlaceHolder, card) ~= false then
			-- 获取放置位置
			placeHolders[card] = { pos = clone(ptFix), zOrder = zOrder }
		end
		table.insert(pts_back, clone(ptFix))
	end

	return placeHolders;
end


-- @param card: Card 当前要操作的控件
-- @param index: number 当前card的索引
-- @param setPos: boolean 当前操作的控件是不是
-- @param cardsNeedPlaceHolder: Card[] 当前组内的牌不设置坐标，只是把正确的坐标传出去
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat_Watcher:_getHandCardPos(card, index, setPos, cardsNeedPlaceHolder, isMingDa, fixPos)
--	: kodUtil.Map<Card, { pos: KodGames.Point, zOrder: number }> {
	local placeHolders = {}
	
	if cardsNeedPlaceHolder == nil then
		cardsNeedPlaceHolder = {}
	end
	
	local cardLayout = self:getCardLayout()
	
	-- 记录当前的组的所有 坐标，当是最后一个时候，不用重新计算了，直接取用中间的那个
	local pts_back = {};	-- point array
	-- 当牌数少于最大牌数时，做的一个偏移，保持牌看起来是在中间的
	local offset = self._cardOffset;
	-- 当前牌的基准zorder
	local zOrder = cardLayout:getZOrder(self._hasHuWhenBattleFinished);
	
	-- 亮牌后的偏移
	local start = cardLayout.anchor
	if isMingDa and (self._chairType == CardDefines.Chair.Left or self._chairType == CardDefines.Chair.Right) then
		start = cc.pSub(start, cc.pSub(cardLayout.gangOffsetLie_mingDa, cardLayout.gangOffsetLie))
	end

	-- 这里的坐标实际要延后半张牌的坐标
	local startPoint = cc.pAdd(start, cc.pMul(cardLayout.bgAdvance, 0.5))
	if index == self:maxCardNumber() then
		-- 这张处理成摸牌
		startPoint = cc.pAdd(startPoint, cardLayout.drawCardSpace);
		index = index - fixPos
	end
	
	index = index + offset;
	-- 找到当前索引对应所在的坐标
	local pt = cc.pAdd(startPoint, cc.pMul(cardLayout.bgAdvance, index));
	
	-- 索引对应的zOrder
	zOrder = zOrder + cardLayout.zOrderAcvance * (index + 1);
	if setPos == true then
		card:setPosition(pt);
		card:setZOrder(zOrder);
		-- TODO：bug 当移动的时候，再次设置坐标，会移动到一个不可控的坐标，清除一下
		if card:getNumberOfRunningActions() > 0 then
			card:stopAllActions()
			card:setScale(self:CARD_SCALE())
		end
	end
	card:changeColor(cardLayout.handCardColor)
	
	if table.indexof(cardsNeedPlaceHolder, card) ~= false then
		placeHolders[card] = { pos = clone(pt), zOrder = zOrder };
	end

	return placeHolders;
end

--[[
-- 管理手牌位置
-- 统一设置手牌位置及Zorder
-- 会调用cardList.sort();
-- 
-- @param layout: CardLayout 
-- @param setPos: boolean 是设置位置还是单纯计算位置, true表示设置位置, false表示获取位置
-- @param cardsNeedPlaceHolder: Card[] 获取指定牌的位置, 当setPos为TRUE, 不设置这张牌的位置
-- @return {Card, {pos: point, zOrder: number}}
--]]
function UIRoomSeat_Watcher:ManageCardsPositions(cardList, layout, setPos, cardsNeedPlaceHolder,isDrag)
--	: kodUtil.Map<Card, { pos: KodGames.Point, zOrder: number }> {
	if Macro.assertTrue(self.battleFinished, "self.battleFinished") then
		return;
	end

	if cardsNeedPlaceHolder == nil then
		cardsNeedPlaceHolder = {}
	end

	cardList:sort();
	local placeHolders = {} -- {Card, {pos: point, zOrder: number}}

	-- TODO：各种变态对齐，处理
	local isMingDa = false
	if #cardList.handCards > 0 then
		if self:getChairType() == CardDefines.Chair.Down then
			isMingDa = cardList.handCards[1]._cardState == CardDefines.CardState.Chupai
		else
			isMingDa = cardList.handCards[1]._cardValue ~= 255
		end
	end
	-- TODO：还要在平辅手牌后，左右两家做一下偏移，b了
	-- 大体偏移量为：
	-- cardLayout.gangOffsetLie_mingDa - cardLayout.gangOffsetLie

	local zOrder = layout:getZOrder(self.hasHuWhenBattleFinished);
	for groupIdx=1, #cardList.cardGroups do
		local group = cardList.cardGroups[groupIdx];
		table.foreach(self:_getGroupCardPos(group, groupIdx-1, setPos, cardsNeedPlaceHolder, isMingDa), function(card, val)
			placeHolders[card] = val;
		end)
	end

	-- 一般手牌
	-- 如果提前碰到摸牌，那么后续的牌索引要减1
	local fixIndx = 0;
	local groupIndex = #cardList.cardGroups * 2;
	
	-- 修改为从左到右获取，因为中间有个摸牌的存在，导制index可能会出错，因为最后一张可能不是摸牌，但是确占用了index = 13！
	for cardIdx = 1, #cardList.handCards do
		local card = cardList.handCards[cardIdx];
		local index = 0;
		if card == cardList.lastDrewCard then
			-- 单独放置刚摸到的牌
			fixIndx = 1;
			index = self:maxCardNumber();
		else
			index = groupIndex + cardIdx - fixIndx - 1;
		end
		table.foreach(self:_getHandCardPos(card, index, setPos, cardsNeedPlaceHolder, isMingDa, #cardList.cardGroups), function(card, val)
			placeHolders[card] = val;
		end)
	end

	-- 原来的index值已经不能使用了，原来的index是从0开始的，这里要+1
	-- TODO:self:maxCardNumber() 在断线重连后，正好赶上结算，这时会是-1
	if #cardList.cardGroups * 3 + #cardList.handCards > self:maxCardNumber() + 1 and self:maxCardNumber() > 0 then
		-- 出现多牌！ 上传，只上传一次
		local roomService = game.service.RoomService.getInstance();
		local dataEyeService = game.service.DataEyeService.getInstance();
		local gameService = gameMode.mahjong.Context.getInstance():getGameService()
		if roomService ~= nil and dataEyeService:needReportCardListError(roomService:getRoomId(), gameService:getCurrentRoundCount()) then
			local cardsStr = "handCards:["
			for iddx = 1, #cardList.handCards do
				cardsStr = cardsStr .. cardList.handCards[iddx]._cardValue .. ","
			end
			for iddx=1, #cardList.cardGroups do
				local group = cardList.cardGroups[iddx];
				cardsStr = cardsStr .. "["
				for idddx=1, #group.cards do
					cardsStr = cardsStr .. cardList.handCards[iddx]._cardValue .. ","
				end
				cardsStr = cardsStr .. "]"
			end
			cardsStr = cardsStr .. "]"
			dataEyeService:reportCardListError(roomService:getRoomId(), gameService:getCurrentRoundCount(), cardsStr)
		end
	end

	return placeHolders;
end

function UIRoomSeat_Watcher:_updateDialogFrame(effects)
	local dialog = nil
	table.foreach(effects,function (k,v)
		if Constants.EffectMap.dialog[v] ~= nil then
			dialog = Constants.EffectMap.dialog[v]
		end
	end)

	if dialog ~= nil then
		local dialogFrame = dialog.Right
		-- 设置气泡框
		self._elemChat:updateChatBg(dialogFrame,dialog.Color,dialog.expandSize)
	end
end

return UIRoomSeat_Watcher