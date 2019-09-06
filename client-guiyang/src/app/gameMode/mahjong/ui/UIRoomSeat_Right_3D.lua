--[[-- 屏幕右边玩家相关UI与操作
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Right = class("UIRoomSeat_Right", require("app.gameMode.mahjong.ui.UIRoomSeat"))


local x2cx = CC_DESIGN_RESOLUTION.screen.toCenterX
local y2cy = CC_DESIGN_RESOLUTION.screen.toCenterY
local x2lx = CC_DESIGN_RESOLUTION.screen.toLeft
local x2rx = CC_DESIGN_RESOLUTION.screen.toRight
local y2by = CC_DESIGN_RESOLUTION.screen.toButtom
local y2ty = CC_DESIGN_RESOLUTION.screen.toTop
local x2px = CC_DESIGN_RESOLUTION.screen.toPercentX
local y2py = CC_DESIGN_RESOLUTION.screen.toPercentY

-- 站立的牌的偏移
local V_DELTA = 36
local H_DELTA = 11
-- 放倒的牌的偏移(吃碰杠)
local V_DELTA_LIE = 36
local H_DELTA_LIE = 11

-- 纵距离下对应的X偏移比例
local SPACE_X_RATIO = H_DELTA / V_DELTA

-- 弃牌的牌间偏移
local V_DELTA_QP = 38
local H_DELTA_QP = 9.5
-- 弃牌的换行偏移
local V_DELTA_QP_LINE = 0
local H_DELTA_QP_LINE = 69

-- 牌组和手牌之间的差值
local DELTA_GANG_V = 0
local DELTA_GANG_H = - 3

local GANG_X_DELTA = 6
local GANG_Y_DELTA = 24

local BG_HEIGHT = 94

local BG_WIDTH_LIE_H = 65

local GROUP_SPACE = 15

local DRAW_CARD_SPACE = 16

local HUA_CARD_SCALE = 0.45
local DISCARDED_CARD_SCALE = 0.69
-- 弃牌区一行最大牌数
local DISCARDED_SEQUENCE_LENGTH = 11

local BASE_CARD_Z_ORDER = 10

local SHOUPAI_Z_ORDER = BASE_CARD_Z_ORDER + 10
local HUA_CARD_ZORDER = SHOUPAI_Z_ORDER + 40
local DISCARD_ZORDER = HUA_CARD_ZORDER + 40

local HU_DARK_MASK_ZORDER = DISCARD_ZORDER + 100
local HU_SHOUPAI_ZORDER = HU_DARK_MASK_ZORDER + 100
local HU_HEAD_ZORDER = HU_SHOUPAI_ZORDER + 100


local OP_BTN_Z_ORDER = BASE_CARD_Z_ORDER + 1000

function UIRoomSeat_Right:ctor(parent)
	self.super.ctor(self, parent, CardDefines.Chair.Right)
	
	self._root = seekNodeByName(parent, "Panel_player2_Scene", "ccui.Layout")
	
	self._root:setPosition(cc.p(x2rx(1014.4), y2cy(273.8)))
	
	-- 绑定UI控件
	self._imgHightLight = seekNodeByName(parent, "Img_effect_player2_Scene", "cc.Sprite");
	self._imgPlayerIcon = seekNodeByName(parent, "Icon_img_player2_Scene", "ccui.ImageView");
	self._imgPlayerFrame = seekNodeByName(parent, "Icon_frame_player2_Scene", "cc.Sprite");
	self._lablePlayerName = seekNodeByName(parent, "Text_name_player2_Scene", "ccui.Text");
	self._lableTotalScore = seekNodeByName(parent, "Text_score_player2_Scene", "ccui.Text");
	self._panelTalk = seekNodeByName(parent, "Panel_talk2_Scene", "ccui.Layout");
	self._imgMessageBorder = seekNodeByName(parent, "Image_talk2_Scene", "ccui.ImageView");
	self._lableMessage = seekNodeByName(parent, "Text_talk2_Scene", "ccui.Text");
	self._imgMessageIcon = seekNodeByName(parent, "bq_talk2_Scene", "cc.Sprite");
	self._imgTalk = seekNodeByName(parent, "Img_xht_player2_Scene", "cc.Sprite");
	self._imgXh1 = seekNodeByName(parent, "Img_xh1_player2_Scene", "cc.Sprite");
	self._imgXh2 = seekNodeByName(parent, "Img_xh2_player2_Scene", "cc.Sprite");
	self._imgXh3 = seekNodeByName(parent, "Img_xh3_player2_Scene", "cc.Sprite");
	self._nodeRTVoice = seekNodeByName(parent, "Node_icon_Label2_player2_Scene", "cc.Node");	
	self._imgReady = seekNodeByName(parent, "z_zb2_direction_Scene", "cc.Sprite");
	self._effectNode = seekNodeByName(parent, "right_mahjongEffect_wiget", "cc.Node");
	
	self._imgBankerIcon = seekNodeByName(parent, "icon_zhuang_player2_Scene", "cc.Sprite");
	self._imgTrustIcon = seekNodeByName(parent, "icon_trustee_player2_Scene", "cc.Sprite");
	self._imgOffLineIcon = seekNodeByName(parent, "icon_lx_player2_Scene", "ccui.TextBMFont");
	self._imgOffLineTips = seekNodeByName(parent, "Image_Offline_palyer2", "ccui.ImageView")
	self._imgCustomIcon = seekNodeByName(parent, "icon_Label1_player2_Scene", "cc.Sprite");
	self._imgCustomIcon2 = seekNodeByName(parent, "icon_Label2_player2_Scene", "cc.Sprite");
	self._imgTing = seekNodeByName(parent, "icon_Label3_player2_Scene", "cc.Sprite")
	self._imgLack = seekNodeByName(parent, "icon_Label4_player2_Scene", "cc.Sprite")
	self._bmBankCount = seekNodeByName(parent, "BitmapFontLabel_z_lzicon_player2_Scene", "ccui.TextBMFont")
	self._bgBankCount = seekNodeByName(parent, "Panel_lzicon_player2_Scene", "ccui.Layout")
	
	self._indicatorCenterImage = seekNodeByName(parent, "Img_right_direction_Scene", "cc.Sprite")
	
	self._discardLayout = seekNodeByName(parent, "discardTips_right", "ccui.Layout")
	self._discardLayout:setVisible(false)
	
	-- 适配相关，坐标全部转换到960，640的比例下
	local center = CC_DESIGN_RESOLUTION.screen.centerPoint()
	local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()
	local size = CC_DESIGN_RESOLUTION.screen.size()
	local design = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
	
	
	-- 初始化布局
	local cardLayout = self:getCardLayout()
	cardLayout.cardPromotion = 0.98
	
	cardLayout.discardPromotion = 100 / 102
	
	cardLayout.discardLineRotation = - 2
	--手牌的每张牌应该占用的纵坐标长度,根据手牌能摆放的区间和手牌个数算出来的
	cardLayout.cardAdvance =(y2cy(585) - y2cy(180)) / self:_getRealIndex(config.GlobalConfig.MAX_HAND_CARDNUMBER)
	-- 根据手牌应占的大小 除以 牌之前原本的总距离间距算出缩放比
	cardLayout.cardScale = cardLayout.cardAdvance / V_DELTA;
	cardLayout.cardLieAdvance = V_DELTA_LIE
	-- 吃碰杠牌的缩放比 : 根据吃碰杠牌占用的纵距离+间距 = 手牌三张占用的纵距离算出
	cardLayout.groupScale = cardLayout.cardAdvance * 3 /(V_DELTA_LIE * 3 + GROUP_SPACE);
	
	-- 手牌的起始点
	cardLayout.anchor = cc.p(x2cx(1071), y2cy(200));
	-- 手牌的偏移,手牌的每张牌应该占用的大小乘以缩放比
	cardLayout.bgAdvance = cc.p(- H_DELTA * cardLayout.cardScale, cardLayout.cardAdvance);	-- 修改了横坐标, 以便适应倾斜视角的手牌	-- by 赵杰
	-- 手牌和摸牌之间的偏移
	cardLayout.drawCardSpace = cc.pMul(cc.p(- DRAW_CARD_SPACE * SPACE_X_RATIO, DRAW_CARD_SPACE), cardLayout.cardScale);
	
	-- 吃碰杠等组内牌的偏移
	cardLayout.bgAcvanceLie = cc.pMul(cc.p(- H_DELTA_LIE, V_DELTA_LIE), cardLayout.groupScale)
	
	-- 杠顶上面的牌的偏移
	cardLayout.gangOffset = cc.pMul(cc.p(GANG_X_DELTA, GANG_Y_DELTA), cardLayout.groupScale)
	-- 吃碰杠与手牌之间的距离(感觉一张牌的距离,外加稍微的位移对其)
	cardLayout.gangOffsetLie = cc.p(DELTA_GANG_H, DELTA_GANG_V)
	
	
	cardLayout.gangZOrderOffset = 3;
	cardLayout.zOrder = SHOUPAI_Z_ORDER
	cardLayout.zOrderHu = HU_SHOUPAI_ZORDER;
	cardLayout.zOrderAcvance = - 1;
	cardLayout.groupCardzOrderAcvance = - 1;
	
	cardLayout.discardedAniStart = cc.p(x2rx(950), 50 + center.y + offset.y);
	cardLayout.discardedAniStartZOrder = DISCARD_ZORDER + 100
	
	cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH;
	cardLayout.discardedLayout.anchor = cc.p(x2cx(962), y2cy(237));
	--根据弃牌区域算出弃牌应该占的纵坐标长度
	local a = self:_getRealDisCardIndex(DISCARDED_SEQUENCE_LENGTH)
	local discardAdvance =(y2cy(520) - y2cy(228)) / self:_getRealDisCardIndex(DISCARDED_SEQUENCE_LENGTH)
	-- 根据次算出倍率
	cardLayout.discardedLayout.scale = discardAdvance / V_DELTA_QP
	-- 弃牌牌之间的间距
	cardLayout.discardedLayout.advance = cc.pMul(cc.p(- H_DELTA_QP, V_DELTA_QP), cardLayout.discardedLayout.scale)
	-- 换行的偏移
	cardLayout.discardedLayout.lineAdvance = cc.pMul(cc.p(- H_DELTA_QP_LINE, V_DELTA_QP_LINE), cardLayout.discardedLayout.scale)
	cardLayout.discardedLayout.zOrder = DISCARD_ZORDER
	cardLayout.discardedLayout.zOrderAdvance = - 1;
	cardLayout.discardedLayout.zOrderLineAcvance = 12;
	cardLayout.discardedLayout.cardSkewX = - 1
	
	
	cardLayout.huaLayout.lineSize = 4;
	cardLayout.huaLayout.anchor = cc.p(x2px(840), y2py(500));
	cardLayout.huaLayout.advance = cc.p(- H_DELTA_LIE * HUA_CARD_SCALE * 0.17, V_DELTA_LIE * HUA_CARD_SCALE * 0.8);
	cardLayout.huaLayout.lineAdvance = cc.p(GANG_X_DELTA * HUA_CARD_SCALE * 1.1, GANG_Y_DELTA * HUA_CARD_SCALE * 2);
	cardLayout.huaLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huaLayout.zOrderAdvance = - 1;
	cardLayout.huaLayout.zOrderLineAcvance = 5;
	cardLayout.huaLayout.scale = HUA_CARD_SCALE
	
	cardLayout.huLayout.lineSize = 7;

	local huAdvance = 18
	cardLayout.huLayout.scale = huAdvance / V_DELTA_LIE
	cardLayout.huLayout.anchor = cc.p(x2cx(951), y2cy(448));
	cardLayout.huLayout.advance = cc.pMul(cc.p(- H_DELTA_LIE, V_DELTA_LIE), cardLayout.huLayout.scale)
	
	
	cardLayout.huLayout.lineAdvance = cc.pMul(cc.p(GANG_X_DELTA, GANG_Y_DELTA), cardLayout.huLayout.scale)
	cardLayout.huLayout.zOrder = HUA_CARD_ZORDER
	cardLayout.huLayout.zOrderAdvance = - 1
	cardLayout.huLayout.zOrderLineAcvance = 10
	cardLayout.huLayout.type = "hu"
	
	cardLayout.opBtnAnchor = cc.p(x2px(940), y2py(380));
	cardLayout.opBtnAdvance = cc.p(0, - 1);
	cardLayout.opBtnScale = 0.7;
	cardLayout.opBtnRotation = - 90;
	cardLayout.opBtnZorder = OP_BTN_Z_ORDER	
	
	cardLayout.huStatusPosition = cc.p(x2px(950), y2py(380))
	

	self._elemChat:initialize(self, "animation1", self._panelTalk, self._imgMessageBorder, self._lableMessage, self._imgMessageIcon,
	self._imgTalk, self._imgXh1, self._imgXh2, self._imgXh3, self._nodeRTVoice)
end

function UIRoomSeat_Right:getHuStatusPosition()
	return self:getCardLayout().huStatusPosition
end

function UIRoomSeat_Right:_updateDialogFrame(effects)
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

return UIRoomSeat_Right 