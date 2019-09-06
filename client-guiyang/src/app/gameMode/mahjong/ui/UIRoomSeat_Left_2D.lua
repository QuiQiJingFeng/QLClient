--[[
-- 屏幕左边玩家相关UI与操作
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Left = class("UIRoomSeat_Left", require("app.gameMode.mahjong.ui.UIRoomSeat"))

local V_DELTA = 24 + 6
local H_DELTA = 24
local BG_HEIGHT = 94
local V_DELTA_LIE = 29
local H_DELTA_LIE = 45
local BG_WIDTH_LIE_H = 54

local GROUP_SPACE = 15
local DRAW_CARD_SPACE = 16

local HUA_CARD_SCALE = 0.75
local DISCARDED_CARD_SCALE = 1
local DISCARDED_SEQUENCE_LENGTH = 10
local TOP_PAI_DISCARD_OVERLAY_Z_ORDER = 60

local BASE_CARD_Z_ORDER = 10
local SHOUPAI_Z_ORDER = BASE_CARD_Z_ORDER + 100
local HU_DARK_MASK_ZORDER = SHOUPAI_Z_ORDER + 100
local HU_SHOUPAI_ZORDER = HU_DARK_MASK_ZORDER + 100
local HU_HEAD_ZORDER = HU_SHOUPAI_ZORDER + 100
local COMBAT_PFX_ZORDER = HU_HEAD_ZORDER + 100
local DISCARDED_INDICATOR_ZORDER = HU_DARK_MASK_ZORDER - 1
local OP_BTN_Z_ORDER = BASE_CARD_Z_ORDER + 1000

local DISCARDED_V_DELTA = 45
local GANG_Y_DELTA = 13
local PREPARED_CARD_Y_DELTA = 26

local HUA_SPACE_TO_SHOUPAI = 30

function UIRoomSeat_Left:ctor(parent)
	self.super.ctor(self, parent, CardDefines.Chair.Left)

	self._root = seekNodeByName(parent, "Panel_player4_Scene", "ccui.Layout")
	-- 绑定UI控件
	self._imgHightLight = seekNodeByName(parent, "Img_effect_player4_Scene", "cc.Sprite");
	self._imgPlayerIcon = seekNodeByName(parent, "Icon_img_player4_Scene", "ccui.ImageView");
	self._imgPlayerFrame = seekNodeByName(parent, "Icon_frame_player4_Scene", "cc.Sprite");
	self._lablePlayerName = seekNodeByName(parent, "Text_name_player4_Scene", "ccui.Text");
	self._lableTotalScore = seekNodeByName(parent, "Text_score_player4_Scene", "ccui.Text");
	self._panelTalk = seekNodeByName(parent, "Panel_talk4_Scene", "ccui.Layout");
	self._imgMessageBorder = seekNodeByName(parent, "Image_talk4_Scene", "ccui.ImageView");
	self._lableMessage = seekNodeByName(parent, "Text_talk4_Scene", "ccui.Text");
	self._imgMessageIcon = seekNodeByName(parent, "bq_talk4_Scene", "cc.Sprite");
	self._imgTalk = seekNodeByName(parent, "Img_xht_player4_Scene", "cc.Sprite");
	self._imgXh1 = seekNodeByName(parent, "Img_xh1_player4_Scene", "cc.Sprite");
	self._imgXh2 = seekNodeByName(parent, "Img_xh2_player4_Scene", "cc.Sprite");
	self._imgXh3 = seekNodeByName(parent, "Img_xh3_player4_Scene", "cc.Sprite");
	self._nodeRTVoice = seekNodeByName(parent, "Node_icon_Label2_player4_Scene", "cc.Node");	
	self._imgReady = seekNodeByName(parent, "z_zb4_direction_Scene", "cc.Sprite");
	self._effectNode = seekNodeByName(parent, "left_mahjongEffect_wiget", "cc.Node");

	self._imgBankerIcon = seekNodeByName(parent, "icon_zhuang_player4_Scene", "cc.Sprite");
	self._imgTrustIcon = seekNodeByName(parent, "icon_trustee_player4_Scene", "cc.Sprite");
	self._imgOffLineIcon = seekNodeByName(parent, "icon_lx_player4_Scene", "ccui.TextBMFont");
	self._imgOffLineTips = seekNodeByName(parent, "Image_Offline_player4", "ccui.ImageView")
	self._imgCustomIcon = seekNodeByName(parent, "icon_Label1_player4_Scene", "cc.Sprite");
	self._imgCustomIcon2 = seekNodeByName(parent, "icon_Label2_player4_Scene", "cc.Sprite");
	self._imgTing = seekNodeByName(parent, "icon_Label3_player4_Scene", "cc.Sprite")
	self._imgLack = seekNodeByName(parent, "icon_Label4_player4_Scene", "cc.Sprite")
	self._bmBankCount = seekNodeByName(parent, "BitmapFontLabel_z_lzicon_player4_Scene", "ccui.TextBMFont")
	self._bgBankCount = seekNodeByName(parent, "Panel_lzicon_player4_Scene", "ccui.Layout")

	self._indicatorCenterImage = seekNodeByName(parent, "Img_left_direction_Scene", "cc.Sprite")

	self._discardLayout = seekNodeByName(parent, "discardTips_left", "ccui.Layout")
	self._discardLayout:setVisible(false)

	-- 适配相关，坐标全部转换到960，640的比例下
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

	-- 初始化布局
	local cardLayout = self:getCardLayout()
    local isClassical = game.service.GlobalSetting.getInstance().isClassic
	local starty = isClassical and y2ty(555) or y2ty(565)
	local handOffset = device.platform == "ios" and 7 or 0
	local endy = y2by(120+handOffset)
	local width = endy - starty
	cardLayout.cardAdvance = math.abs(width) / config.GlobalConfig.MAX_HAND_CARDNUMBER;
	cardLayout.cardScale = cardLayout.cardAdvance / V_DELTA;
	cardLayout.cardLieAdvance = V_DELTA_LIE;
	cardLayout.groupScale = cardLayout.cardAdvance * 3 / (V_DELTA_LIE * 3 + GROUP_SPACE);

	cardLayout.anchor = cc.p(x2lx(110), starty);
	cardLayout.bgAdvance = cc.p(0, -cardLayout.cardAdvance);
	cardLayout.bgAcvanceLie = cc.p(0, -V_DELTA_LIE * self:GROUP_SCALE());
	cardLayout.drawCardSpace = cc.p(0, -DRAW_CARD_SPACE);
	cardLayout.groupSpace = cc.p(0, GROUP_SPACE);
	cardLayout.gangOffset = cc.p(0, -GANG_Y_DELTA * self:GROUP_SCALE());
	cardLayout.gangOffsetLie = cc.p(-H_DELTA * 0.5*cardLayout.cardScale + BG_WIDTH_LIE_H * self:GROUP_SCALE() * 0.5, 0);
	cardLayout.gangOffsetLie_mingDa = cc.p(-BG_WIDTH_LIE_H * self:GROUP2_SCALE() * 0.5 + BG_WIDTH_LIE_H * self:GROUP_SCALE() * 0.5, 0);
	cardLayout.gangZOrderOffset = 1;
	cardLayout.zOrder = SHOUPAI_Z_ORDER + 40;
	cardLayout.zOrderHu = HU_SHOUPAI_ZORDER;
	cardLayout.zOrderAcvance = 1;

	cardLayout.discardedAniStart = cc.p(210+offset.x, center.y+offset.y + 30);
	cardLayout.discardedAniStartZOrder = SHOUPAI_Z_ORDER;

	cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH - 1;
    local adx = isClassical and 360 or 370
	local ady = isClassical and 415 or 445
	cardLayout.discardedLayout.anchor = cc.p(x2cx(adx-H_DELTA_LIE*0.5*DISCARDED_CARD_SCALE), y2cy(ady - V_DELTA_LIE*0.5*DISCARDED_CARD_SCALE));
    local add = isClassical and 0 or 4
    cardLayout.discardedLayout.advance = cc.p(0, -V_DELTA_LIE * DISCARDED_CARD_SCALE-add);
	cardLayout.discardedLayout.lineAdvance = cc.p(-BG_WIDTH_LIE_H * DISCARDED_CARD_SCALE+1, 0);
	cardLayout.discardedLayout.zOrder = BASE_CARD_Z_ORDER + 40;
	cardLayout.discardedLayout.zOrderAdvance = 1;
	cardLayout.discardedLayout.zOrderLineAcvance = 0;
	cardLayout.discardedLayout.scale = DISCARDED_CARD_SCALE

	cardLayout.huaLayout.lineSize = 4;
	cardLayout.huaLayout.anchor = cc.p(x2lx(110 + H_DELTA / 2 * cardLayout.cardScale + H_DELTA_LIE / 2 * HUA_CARD_SCALE + HUA_SPACE_TO_SHOUPAI), y2ty(520));
	cardLayout.huaLayout.advance = cc.p(0, V_DELTA_LIE * HUA_CARD_SCALE);
	cardLayout.huaLayout.lineAdvance = cc.p(0, GANG_Y_DELTA * HUA_CARD_SCALE);
	cardLayout.huaLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huaLayout.zOrderAdvance = - 1;
	cardLayout.huaLayout.zOrderLineAcvance = 0;
	cardLayout.huaLayout.scale = HUA_CARD_SCALE

	cardLayout.huLayout.lineSize = 4;
	cardLayout.huLayout.anchor = cc.p(x2px(170), y2py(260));
	cardLayout.huLayout.advance = cc.p(0, -V_DELTA_LIE * HUA_CARD_SCALE);
	cardLayout.huLayout.lineAdvance = cc.p(0, GANG_Y_DELTA * HUA_CARD_SCALE);
	cardLayout.huLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huLayout.zOrderAdvance = 1;
	cardLayout.huLayout.zOrderLineAcvance = 0;
	
	cardLayout.opBtnAnchor = cc.p(x2px(210), y2py(450));
	cardLayout.opBtnAdvance = cc.p(0, 1);
	cardLayout.opBtnScale = 0.7;
	cardLayout.opBtnRotation = 90;
	cardLayout.opBtnZorder = OP_BTN_Z_ORDER	

	cardLayout.huStatusPosition = cc.p(x2px(270), y2py(380))

	cardLayout.handCardColor = cc.c3b(235,235,235)
	cardLayout.discardColor = cc.c3b(235,235,235)

	self._elemChat:initialize(self, "animation3", self._panelTalk, self._imgMessageBorder, self._lableMessage, self._imgMessageIcon, 
	self._imgTalk, self._imgXh1, self._imgXh2, self._imgXh3, self._nodeRTVoice)
end

function UIRoomSeat_Left:getHuStatusPosition()
	return self:getCardLayout().huStatusPosition
end

function UIRoomSeat_Left:_updateDialogFrame(effects)
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

return UIRoomSeat_Left