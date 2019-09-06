--[[-- 屏幕左边玩家相关UI与操作
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local UIRoomSeat_Top = class("UIRoomSeat_Top", require("app.gameMode.mahjong.ui.UIRoomSeat"))
local Constants = require("app.gameMode.mahjong.core.Constants")

local H_DELTA = 64
local V_DELTA = 0

local H_DELTA_LIE = 87
local V_DELTA_LIE = 56

-- 弃牌的牌间偏移
local V_DELTA_QP = 0
local H_DELTA_QP = 64
-- 弃牌的换行偏移
local V_DELTA_QP_LINE = 54
local H_DELTA_QP_LINE = 6
local H_DELTA_QP_LINE_2 = 9.84
-- 牌组和手牌之间的差值
local DELTA_GANG_V = - 10
local DELTA_GANG_H = 5


local GROUP_SPACE = 18
local DRAW_CARD_SPACE = 10

local GANG_X_DELTA = 0
local GANG_Y_DELTA = 33

local DISCARDED_SEQUENCE_LENGTH = 10
local TOP_PAI_DISCARD_OVERLAY_Z_ORDER = 60

local HUA_CARD_SCALE = 0.45

local BASE_CARD_Z_ORDER = 70
local SHOUPAI_Z_ORDER = BASE_CARD_Z_ORDER + 10
local HUA_CARD_ZORDER = SHOUPAI_Z_ORDER + 40
local DISCARD_ZORDER = HUA_CARD_ZORDER + 40

local HU_DARK_MASK_ZORDER = DISCARD_ZORDER + 100
local HU_SHOUPAI_ZORDER = HU_DARK_MASK_ZORDER + 100
local HU_HEAD_ZORDER = HU_SHOUPAI_ZORDER + 100
local COMBAT_PFX_ZORDER = HU_HEAD_ZORDER + 100
local DISCARDED_INDICATOR_ZORDER = HU_DARK_MASK_ZORDER - 1
local OP_BTN_Z_ORDER = BASE_CARD_Z_ORDER + 1000

-- 适配相关，坐标全部转换到1136，640的比例下
local center = CC_DESIGN_RESOLUTION.screen.centerPoint()
local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()
local size = CC_DESIGN_RESOLUTION.screen.size()
local design = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)

local x2cx = CC_DESIGN_RESOLUTION.screen.toCenterX
local y2cy = CC_DESIGN_RESOLUTION.screen.toCenterY
local x2lx = CC_DESIGN_RESOLUTION.screen.toLeft
local x2rx = CC_DESIGN_RESOLUTION.screen.toRight
local y2by = CC_DESIGN_RESOLUTION.screen.toButtom
local y2ty = CC_DESIGN_RESOLUTION.screen.toTop
local x2px = CC_DESIGN_RESOLUTION.screen.toPercentX
local y2py = CC_DESIGN_RESOLUTION.screen.toPercentY


function UIRoomSeat_Top:ctor(parent)
	self.super.ctor(self, parent, CardDefines.Chair.Top)
	
	self._root = seekNodeByName(parent, "Panel_player3_Scene", "ccui.Layout")
	
	-- 3D位置修改
	self._root:setPosition(cc.p(x2cx(836), y2ty(510)))
	-- 绑定UI控件
	self._imgHightLight = seekNodeByName(parent, "Img_effect_player3_Scene", "cc.Sprite");
	self._imgPlayerIcon = seekNodeByName(parent, "Icon_img_player3_Scene", "ccui.ImageView");
	self._imgPlayerFrame = seekNodeByName(parent, "Icon_frame_player3_Scene", "cc.Sprite");
	self._lablePlayerName = seekNodeByName(parent, "Text_name_player3_Scene", "ccui.Text");
	self._lableTotalScore = seekNodeByName(parent, "Text_score_player3_Scene", "ccui.Text");
	self._panelTalk = seekNodeByName(parent, "Panel_talk3_Scene", "ccui.Layout");
	self._imgMessageBorder = seekNodeByName(parent, "Image_talk3_Scene", "ccui.ImageView");
	self._lableMessage = seekNodeByName(parent, "Text_talk3_Scene", "ccui.Text");
	self._imgMessageIcon = seekNodeByName(parent, "bq_talk3_Scene", "cc.Sprite");
	self._imgTalk = seekNodeByName(parent, "Img_xht_player3_Scene", "cc.Sprite");
	self._imgXh1 = seekNodeByName(parent, "Img_xh1_player3_Scene", "cc.Sprite");
	self._imgXh2 = seekNodeByName(parent, "Img_xh2_player3_Scene", "cc.Sprite");
	self._imgXh3 = seekNodeByName(parent, "Img_xh3_player3_Scene", "cc.Sprite");
	self._nodeRTVoice = seekNodeByName(parent, "Node_icon_Label2_player3_Scene", "cc.Node");	
	self._imgReady = seekNodeByName(parent, "z_zb3_direction_Scene", "cc.Sprite");
	self._effectNode = seekNodeByName(parent, "top_mahjongEffect_wiget", "cc.Node");
	
	self._imgBankerIcon = seekNodeByName(parent, "icon_zhuang_player3_Scene", "cc.Sprite");
	self._imgTrustIcon = seekNodeByName(parent, "icon_trustee_player3_Scene", "cc.Sprite");
	self._imgOffLineIcon = seekNodeByName(parent, "icon_lx_player3_Scene", "ccui.TextBMFont");
	self._imgOffLineTips = seekNodeByName(parent, "Image_Offline_player3", "ccui.ImageView")
	self._imgCustomIcon = seekNodeByName(parent, "icon_Label1_player3_Scene", "cc.Sprite");
	self._imgCustomIcon2 = seekNodeByName(parent, "icon_Label2_player3_Scene", "cc.Sprite");
	self._imgTing = seekNodeByName(parent, "icon_Label3_player3_Scene", "cc.Sprite")
	self._imgLack = seekNodeByName(parent, "icon_Label4_player3_Scene", "cc.Sprite")
	self._bmBankCount = seekNodeByName(parent, "BitmapFontLabel_z_lzicon_player3_Scene", "ccui.TextBMFont")
	self._bgBankCount = seekNodeByName(parent, "Panel_lzicon_player3_Scene", "ccui.Layout")
	
	self._indicatorCenterImage = seekNodeByName(parent, "Img_top_direction_Scene", "cc.Sprite")
	
	self._discardLayout = seekNodeByName(parent, "discardTips_top", "ccui.Layout")
	self._discardLayout:setVisible(false)
	
	
	-- 初始化布局
	local cardLayout = self:getCardLayout()
	local startx = x2cx(788)
	local endx = x2cx(238)
	local width = startx - endx
	
	cardLayout.discardPromotion_line = 1 / 0.98
	
	-- 根据屏幕设置长度求出牌的长度
	cardLayout.cardAdvance = width / config.GlobalConfig.MAX_HAND_CARDNUMBER;
	-- 根据长度求出牌的倍率
	cardLayout.cardScale = cardLayout.cardAdvance / H_DELTA
	-- 吃碰杠牌的倍率
	cardLayout.groupScale = cardLayout.cardAdvance / H_DELTA_LIE
	
	-- 吃碰杠的间距(上面玩家的杠牌和手牌一样打所以算法改变)
	cardLayout.groupSpace = cc.pMul(cc.p(- GROUP_SPACE, 0), cardLayout.groupScale)
	-- 手牌锚点
	cardLayout.anchor = cc.p(x2cx(747), y2ty(598))
	-- 手牌的间距
	cardLayout.bgAdvance = cc.p(- H_DELTA * cardLayout.cardScale, 0)
	-- 吃碰杠牌的间距
	cardLayout.bgAcvanceLie = cc.p(- H_DELTA_LIE * cardLayout.groupScale, 0)
	-- 手牌和摸牌的间距
	cardLayout.drawCardSpace = cc.pMul(cc.p(- DRAW_CARD_SPACE, 0), cardLayout.cardScale)
	
	--杠牌第4张的偏移(3D下,每张牌不一样,这个保留兼容其他模式,自己用特殊的)
	cardLayout.gangOffset = cc.p(GANG_X_DELTA * cardLayout.groupScale, GANG_Y_DELTA * cardLayout.groupScale)
	--杠牌第4张的偏移,每组偏移量不同,所以用数组表示
	cardLayout.gangOffset3D = {
		cc.pMul(cc.p(3, 33), cardLayout.groupScale),
		cc.pMul(cc.p(- 1, 33), cardLayout.groupScale),
		cc.pMul(cc.p(- 2, 33), cardLayout.groupScale),
		cc.pMul(cc.p(- 6, 33), cardLayout.groupScale),
	}
	-- 杠牌与手牌的额外间距(上面牌特有的)
	cardLayout.gangOffsetSpace = cc.pMul(cardLayout.groupSpace, - 5)
	
	cardLayout.gangOffsetLie = cc.p(DELTA_GANG_H, DELTA_GANG_V)
	
	cardLayout.gangZOrderOffset = 5;
	cardLayout.zOrder = SHOUPAI_Z_ORDER
	cardLayout.zOrderHu = HU_SHOUPAI_ZORDER;
	cardLayout.zOrderAcvance = 1;
	cardLayout.groupCardzOrderAcvance = 1;
	
	cardLayout.discardedAniStart = cc.p(center.x + offset.x, y2ty(500));
	cardLayout.discardedAniStartZOrder = DISCARD_ZORDER + 200
	
	
	--根据弃牌区域算出弃牌应该占的纵坐标长度
	cardLayout.discardedLayout.startX = 1136 / 2 - 202
	cardLayout.discardedLayout.endX = 1136 / 2 + 202
	cardLayout.discardAdvance =(x2cx(cardLayout.discardedLayout.endX) - x2cx(cardLayout.discardedLayout.startX)) / DISCARDED_SEQUENCE_LENGTH
	
	-- 弃牌区倍率
	cardLayout.discardedLayout.scale = cardLayout.discardAdvance / H_DELTA_QP
	-- 弃牌牌之间的间距
	cardLayout.discardedLayout.advance = cc.pMul(cc.p(- H_DELTA_QP, V_DELTA_QP), cardLayout.discardedLayout.scale)
	
	self:updateDiscardedLayout(4)
	
	cardLayout.discardedLayout.zOrder = DISCARD_ZORDER
	-- 注意第5张牌以后 zorder符号要变负的,因为3D的透视效果
	cardLayout.discardedLayout.zOrderAdvance = 1;
	cardLayout.discardedLayout.zOrderLineAcvance = 20;
	
	cardLayout.huaLayout.lineSize = 4;
	cardLayout.huaLayout.anchor = cc.p(x2px(400), y2py(560));
	cardLayout.huaLayout.advance = cc.p(- H_DELTA_LIE * HUA_CARD_SCALE * 0.9, 0);
	cardLayout.huaLayout.lineAdvance = cc.p(- GANG_X_DELTA * HUA_CARD_SCALE * 0.8, GANG_Y_DELTA * HUA_CARD_SCALE * 2);
	cardLayout.huaLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huaLayout.zOrderAdvance = - 1;
	cardLayout.huaLayout.zOrderLineAcvance = 5;
	cardLayout.huaLayout.scale = HUA_CARD_SCALE
	
	cardLayout.huLayout.lineSize = 7;
	
	local huAdvance = 24
	cardLayout.huLayout.scale = huAdvance / H_DELTA_LIE
	cardLayout.huLayout.anchor = cc.p(x2cx(415), y2ty(561));
	cardLayout.huLayout.advance = cc.p(- H_DELTA_LIE * cardLayout.huLayout.scale, 0);
	
	
	cardLayout.huLayout.lineAdvance = cc.pMul(cc.p(4, 35), cardLayout.huLayout.scale)
	cardLayout.huLayout.zOrder = HUA_CARD_ZORDER
	cardLayout.huLayout.zOrderAdvance = - 1
	cardLayout.huLayout.zOrderLineAcvance = 10;
	cardLayout.huLayout.type = "hu"
	
	
	cardLayout.opBtnAnchor = cc.p(x2px(300), y2py(500));
	cardLayout.opBtnAdvance = cc.p(1, 0);
	cardLayout.opBtnScale = 0.7;
	cardLayout.opBtnRotation = 180;
	cardLayout.opBtnZorder = OP_BTN_Z_ORDER	
	
	cardLayout.huStatusPosition = cc.p(x2px(570), y2py(530))
	
	self._elemChat:initialize(self, "animation2", self._panelTalk, self._imgMessageBorder, self._lableMessage, self._imgMessageIcon,
	self._imgTalk, self._imgXh1, self._imgXh2, self._imgXh3, self._nodeRTVoice)
end

function UIRoomSeat_Top:updateDiscardedLayout(maxPlayerCount)
	local cardLayout = self:getCardLayout()
	if maxPlayerCount == 2 then
		-- 头像位置修改
		self._root:setPosition(cc.p(x2cx(943), y2ty(510)))
		-- 换行的偏移
		cardLayout.discardedLayout.lineAdvance = cc.pMul(cc.p(H_DELTA_QP_LINE_2, - V_DELTA_QP_LINE), cardLayout.discardedLayout.scale)
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH + 6;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(cardLayout.discardedLayout.endX + 2.5 * cardLayout.discardAdvance), y2ty(520))
	else
		-- 头像位置修改
		self._root:setPosition(cc.p(x2cx(836), y2ty(510)))
		-- 换行的偏移
		cardLayout.discardedLayout.lineAdvance = cc.pMul(cc.p(H_DELTA_QP_LINE, - V_DELTA_QP_LINE), cardLayout.discardedLayout.scale)
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(cardLayout.discardedLayout.endX - cardLayout.discardAdvance / 2), y2ty(520))
	end
end

function UIRoomSeat_Top:_getSubCardLayoutZOrder(subCardLayout, index)
	local sign = 1
	if subCardLayout.type == "hu" then
		sign = index > 7 and - 1 or 1
	else
		if gameMode.mahjong.Context.getInstance():getGameService():getPlayerNums() == 2 then
			index = index - 3
		end
		sign = index > 5 and - 1 or 1
	end
	return subCardLayout.zOrderAdvance * sign
end

-- 牌间的偏差
function UIRoomSeat_Top:_getCardzOrder(index)
	local sign = index > 7 and - 1 or 1
	return self:getCardLayout().zOrderAcvance * sign
end

function UIRoomSeat_Top:getShowCardIndex(cardState, cardIndex)
	local cardLayout = self:getCardLayout()
	-- -1时显示中间的那张牌
	if cardIndex == - 1 then
		if cardState == CardDefines.CardState.Chupai then
			cardIndex = 6
		else
			cardIndex = 8
		end
	elseif cardState == CardDefines.CardState.Chupai then
		if gameMode.mahjong.Context.getInstance():getGameService():getPlayerNums() == 2 then
			cardIndex = cardIndex + 3
		end
		cardIndex = cardLayout.discardedLayout.lineSize + 1 - cardIndex
	elseif cardState == CardDefines.CardState.HuPai then
		cardIndex = cardLayout.huLayout.lineSize -(cardIndex - 1) % cardLayout.huLayout.lineSize
	else
		cardIndex = self._maxCardNumber + 2 - cardIndex
	end
	return cardIndex
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
function UIRoomSeat_Top:_getGroupCardPos(cardGroup, index, setPos, cardsNeedPlaceHolder, isMingDa)
	local placeHolders = {}
	local cardLayout = self:getCardLayout()
	
	-- 记录当前的组的所有 坐标，当是最后一个时候，不用重新计算了，直接取用中间的那个
	local pts_back = {};	-- point array
	
	-- 当前牌的基准zorder
	local zOrder = cardLayout:getZOrder(self._hasHuWhenBattleFinished);
	
	
	local currIndex = index;
	-- 找到当前索引对应所在的坐标
	local start = cc.pAdd(cardLayout.anchor, cc.pMul(cardLayout.groupSpace, currIndex))
	
	local pt = cc.pAdd(start, cc.pMul(cardLayout.bgAcvanceLie, currIndex * 3))
	-- 索引对应的zOrder
	zOrder = zOrder + cardLayout.groupCardzOrderAcvance * currIndex * 3
	
	
	for j = 1, #cardGroup.cards do
		local card = cardGroup.cards[j];
		card:changeColor(cardLayout.groupCardColor)
		-- 牌的修正坐标，为了不影响其它牌，原值是累加的，这一组共用的，这里重新创建一个新的变量
		local ptFix = null;
		zOrder = zOrder + self:_getCardzOrder(index * 3 + j)
		local cardIndex = currIndex + j
		if j == 4 then
			-- 当是扛牌的那个顶上的牌的时候，这个牌的坐标直接套用中间那张牌就可以了，然后修正坐标以及zorder
			if self._chairType == CardDefines.Chair.Left or self._chairType == CardDefines.Chair.Right then
				pt = cc.pAdd(pts_back[2], cc.pMul(cardLayout.gangOffset, self:_getRealCardPromotion(currIndex + 2)))
			else
				-- 上下玩家因为透视效果,单独使用对应的偏差(上下不需要大小的变化所以不乘系数了)
				pt = cc.pAdd(pts_back[2], cardLayout.gangOffset3D[index + 1])
			end
			ptFix = clone(pt)
			zOrder = zOrder + cardLayout.gangZOrderOffset
		else
			ptFix = cc.pAdd(pt, cc.pAdd(cardLayout.gangOffsetSpace, cardLayout.gangOffsetLie))
			pt = cc.pAdd(pt, cc.pMul(cardLayout.bgAcvanceLie, self:_getRealCardPromotion(currIndex + j)))
			-- ptFix = clone(pt)
		end
		
		if setPos == true then
			-- TODO：bug 当移动的时候，再次设置坐标，会移动到一个不可控的坐标，清除一下
			if card:getNumberOfRunningActions() > 0 then
				card:stopAllActions()
			end
			card:setPosition(ptFix);
			card:setZOrder(zOrder);

			self:_resizeCard(card, cardIndex)
		end
		
		if table.indexof(cardsNeedPlaceHolder, card) ~= false then
			-- 获取放置位置
			placeHolders[card] = {pos = clone(ptFix), zOrder = zOrder}
		end
		table.insert(pts_back, clone(ptFix))
	end
	
	return placeHolders;
end

function UIRoomSeat_Top:_updateDialogFrame(effects)
	local dialog = nil
	table.foreach(effects,function (k,v)
		if Constants.EffectMap.dialog[v] ~= nil then
			dialog = Constants.EffectMap.dialog[v]
		end
	end)

	if dialog ~= nil then
		local dialogFrame = dialog.Left
		-- 设置气泡框
		self._elemChat:updateChatBg(dialogFrame,dialog.Color,dialog.expandSize)
	end
end

return UIRoomSeat_Top 