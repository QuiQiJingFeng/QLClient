--[[-- 观察者，变种Down，用来处理经理察看牌局
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Super = require("app.gameMode.mahjong.ui.UIRoomSeat")
local UIRoomSeat_Watcher = class("UIRoomSeat_Watcher", Super)
local Constants = require("app.gameMode.mahjong.core.Constants")

local H_DELTA = 64
local V_DELTA = 0

local H_DELTA_LIE = 87
local V_DELTA_LIE = 56

-- 弃牌的牌间偏移
local V_DELTA_QP = 0
local H_DELTA_QP = 65
-- 弃牌的换行偏移
local V_DELTA_QP_LINE = 54
local H_DELTA_QP_LINE = 6
local H_DELTA_QP_LINE_2 = 9.84
-- 牌组和手牌之间的差值
local DELTA_GANG_V = - 7
local DELTA_GANG_H = - 18

local GROUP_CARD_ADVANCE = 0.2
local GROUP_SPACE = 18
local DRAW_CARD_SPACE = 20

local GANG_X_DELTA = 0
local GANG_Y_DELTA = 33

local HUA_CARD_SCALE = 0.5

local DISCARDED_SEQUENCE_LENGTH = 10

local TOP_PAI_DISCARD_OVERLAY_Z_ORDER = 60

local BASE_CARD_Z_ORDER = 10
local SHOUPAI_Z_ORDER = BASE_CARD_Z_ORDER + 10
local HUA_CARD_ZORDER = SHOUPAI_Z_ORDER + 40
local DISCARD_ZORDER = HUA_CARD_ZORDER + 40

local HU_DARK_MASK_ZORDER = DISCARD_ZORDER + 100
local HU_SHOUPAI_ZORDER = HU_DARK_MASK_ZORDER + 100
local HU_HEAD_ZORDER = HU_SHOUPAI_ZORDER + 100
local COMBAT_PFX_ZORDER = HU_HEAD_ZORDER + 100
local DISCARDED_INDICATOR_ZORDER = HU_DARK_MASK_ZORDER - 1
local OP_BTN_Z_ORDER = BASE_CARD_Z_ORDER + 1000

local DISCARDED_H_DELTA = 3
local DISCARDED_H_DELTA_2Player = 15
local DISCARDED_V_DELTA = 80

local PREPARED_CARD_Y_DELTA = 26

-- 适配相关，坐标全部转换到的比例下
local center = CC_DESIGN_RESOLUTION.screen.centerPoint()
local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()

local design = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)

local x2cx = CC_DESIGN_RESOLUTION.screen.toCenterX
local y2cy = CC_DESIGN_RESOLUTION.screen.toCenterY
local x2lx = CC_DESIGN_RESOLUTION.screen.toLeft
local x2rx = CC_DESIGN_RESOLUTION.screen.toRight
local y2by = CC_DESIGN_RESOLUTION.screen.toButtom
local y2ty = CC_DESIGN_RESOLUTION.screen.toTop
local x2px = CC_DESIGN_RESOLUTION.screen.toPercentX
local y2py = CC_DESIGN_RESOLUTION.screen.toPercentY

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
	
	
	-- 初始化布局
	local cardLayout = self:getCardLayout()
	
	cardLayout.discardPromotion_line = 0.98
	
	-- local width = self._parentUI:getContentSize().width
	local width = 1136
	-- 根据屏幕设置长度求出牌的长度
	cardLayout.cardAdvance = width / config.GlobalConfig.MAX_HAND_CARDNUMBER;
	-- 根据长度求出牌的倍率
	cardLayout.cardScale = cardLayout.cardAdvance / H_DELTA;
	-- 吃碰杠牌的倍率
	cardLayout.groupScale = cardLayout.cardAdvance * 3 /(H_DELTA_LIE * 3 + GROUP_SPACE);
	
	-- 手牌锚点
	cardLayout.anchor = cc.p(x2cx(58 - DELTA_GANG_H), y2by(63));
	-- 手牌的间距
	cardLayout.bgAdvance = cc.p(cardLayout.cardAdvance, 0);
	-- 吃碰杠牌的间距
	cardLayout.bgAcvanceLie = cc.p(H_DELTA_LIE * cardLayout.groupScale, 0);
	-- 手牌和摸牌的间距
	cardLayout.drawCardSpace = cc.pMul(cc.p(DRAW_CARD_SPACE, 0), cardLayout.cardScale)
	
	--杠牌第4张的偏移(3D下,每张牌不一样,这个保留兼容其他模式,自己用特殊的)
	cardLayout.gangOffset = cc.p(GANG_X_DELTA * cardLayout.groupScale, GANG_Y_DELTA * cardLayout.groupScale)
	--杠牌第4张的偏移,每组偏移量不同,所以用数组表示
	cardLayout.gangOffset3D = {
		cc.pMul(cc.p(- 7, 33), cardLayout.groupScale),
		cc.pMul(cc.p(- 3, 33), cardLayout.groupScale),
		cc.pMul(cc.p(- 1, 33), cardLayout.groupScale),
		cc.pMul(cc.p(4, 33), cardLayout.groupScale),
	}
	
	cardLayout.gangOffsetLie = cc.p(DELTA_GANG_H, DELTA_GANG_V)
	
	cardLayout.gangZOrderOffset = 5;
	cardLayout.zOrder = SHOUPAI_Z_ORDER
	cardLayout.zOrderHu = HU_SHOUPAI_ZORDER;
	
	cardLayout.zOrderAcvance = 1;
	-- 注意第7张牌以后 zorder符号要变负的,因为3D的透视效果
	cardLayout.groupCardzOrderAcvance = 1;
	
	cardLayout.discardedAniStart = cc.p(center.x + offset.x, 150 + offset.y);
	cardLayout.discardedAniStartZOrder = DISCARD_ZORDER + 200;
	
	
	
	--根据弃牌区域算出弃牌应该占的纵坐标长度
	cardLayout.discardedLayout.startX = width / 2 - 240
	cardLayout.discardedLayout.endX = width / 2 + 240
	cardLayout.discardAdvance =(x2cx(cardLayout.discardedLayout.endX) - x2cx(cardLayout.discardedLayout.startX)) / DISCARDED_SEQUENCE_LENGTH
	
	
	-- 弃牌区倍率
	cardLayout.discardedLayout.scale = cardLayout.discardAdvance / H_DELTA_QP
	-- 弃牌牌之间的间距
	cardLayout.discardedLayout.advance = cc.pMul(cc.p(H_DELTA_QP, V_DELTA_QP), cardLayout.discardedLayout.scale)
	
	self:updateDiscardedLayout(4)
	
	cardLayout.discardedLayout.zOrder = DISCARD_ZORDER
	-- 注意第5张牌以后 zorder符号要变负的,因为3D的透视效果
	cardLayout.discardedLayout.zOrderAdvance = 1;
	cardLayout.discardedLayout.zOrderLineAcvance = - 13;
	
	
	cardLayout.huaLayout.lineSize = 4;
	cardLayout.huaLayout.anchor = cc.p(x2cx(780), y2by(160));
	cardLayout.huaLayout.advance = cc.p(H_DELTA_LIE, 0);
	cardLayout.huaLayout.lineAdvance = cc.p(HUA_CARD_SCALE * 10, - GANG_Y_DELTA * HUA_CARD_SCALE * 1);
	cardLayout.huaLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huaLayout.zOrderAdvance = - 1;
	cardLayout.huaLayout.zOrderLineAcvance = 5;
	cardLayout.huaLayout.scale = HUA_CARD_SCALE
	
	cardLayout.huLayout.lineSize = 7;
	
	local huAdvance = 40
	cardLayout.huLayout.scale = huAdvance / H_DELTA_LIE
	cardLayout.huLayout.anchor = cc.p(x2cx(760), y2by(145));
	cardLayout.huLayout.advance = cc.p(H_DELTA_LIE * cardLayout.huLayout.scale, 0);
	
	
	cardLayout.huLayout.lineAdvance = cc.pMul(cc.p(4, 35), cardLayout.huLayout.scale)
	cardLayout.huLayout.zOrder = HUA_CARD_ZORDER
	cardLayout.huLayout.zOrderAdvance = - 1;
	cardLayout.huLayout.zOrderLineAcvance = 10;
	cardLayout.huLayout.type = "hu"
	
	cardLayout.opBtnAnchor = cc.p(x2px(960), y2py(150));
	cardLayout.opBtnAdvance = cc.p(- 1, 0);
	cardLayout.opBtnScale = 1;
	cardLayout.opBtnRotation = 0;
	cardLayout.opBtnZorder = OP_BTN_Z_ORDER
	
	cardLayout.huStatusPosition = cc.p(x2px(570), y2py(240))
	
	self._elemChat:initialize(self, "animation0", self._panelTalk, self._imgMessageBorder, self._lableMessage, self._imgMessageIcon,
	self._imgTalk, self._imgXh1, self._imgXh2, self._imgXh3, self._nodeRTVoice)
end

-- 在回放的时候，创建玩家的时候，还没有取到最大玩家数，这时候创建出来的是问题的，需要更新一下
function UIRoomSeat_Watcher:updateDiscardedLayout(maxPlayerCount)
	local cardLayout = self:getCardLayout()
	if maxPlayerCount == 2 then
		-- 换行的偏移
		cardLayout.discardedLayout.lineAdvance = cc.pMul(cc.p(H_DELTA_QP_LINE_2, V_DELTA_QP_LINE), cardLayout.discardedLayout.scale)
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH + 6
		cardLayout.discardedLayout.anchor = cc.p(x2cx(cardLayout.discardedLayout.startX - 2.5 * cardLayout.discardAdvance), y2by(202))
	else
		-- 换行的偏移
		cardLayout.discardedLayout.lineAdvance = cc.pMul(cc.p(H_DELTA_QP_LINE, V_DELTA_QP_LINE), cardLayout.discardedLayout.scale)
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(cardLayout.discardedLayout.startX + cardLayout.discardAdvance / 2), y2by(202))
	end
end


-- 牌间的偏差
function UIRoomSeat_Watcher:_getCardzOrder(index)
	local sign = index > 7 and - 1 or 1
	return self:getCardLayout().zOrderAcvance * sign
end

function UIRoomSeat_Watcher:_getSubCardLayoutZOrder(subCardLayout, index)
	local sign = 1
	if subCardLayout.type == "hu" then
		sign = 1
	else
		if gameMode.mahjong.Context.getInstance():getGameService():getPlayerNums() == 2 then
			index = index - 3
		end
		sign = index > 5 and - 1 or 1
	end
	return subCardLayout.zOrderAdvance * sign
end

function UIRoomSeat_Watcher:getShowCardIndex(cardState, cardIndex)
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
			cardIndex = cardIndex - 3
		end
	elseif cardState == CardDefines.CardState.HuPai then
		cardIndex =(cardIndex - 1) % cardLayout.huLayout.lineSize + 1
		cardIndex = cardIndex + 14 - cardLayout.huLayout.lineSize
	end
	return cardIndex
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