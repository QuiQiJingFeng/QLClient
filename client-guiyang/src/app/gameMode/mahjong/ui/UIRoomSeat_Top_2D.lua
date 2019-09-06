--[[-- 屏幕左边玩家相关UI与操作
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Top = class("UIRoomSeat_Top", require("app.gameMode.mahjong.ui.UIRoomSeat"))

local BG_WIDTH = 37
local BG_HEIGHT = 60
local BG_WIDTH_LIE = 41
local BG_HEIGHT_LIE = 54

local GROUP_SPACE = 10
local DRAW_CARD_SPACE = 8

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

local HUA_SPACE_TO_SHOUPAI = 15

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

function UIRoomSeat_Top:ctor(parent)
	self.super.ctor(self, parent, CardDefines.Chair.Top)
	
	self._root = seekNodeByName(parent, "Panel_player3_Scene", "ccui.Layout")
	-- 因为3D位置修改,所以2D要改回来
	self._root:setPosition(cc.p(x2rx(943), y2ty(510)))
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
	local isClassical = game.service.GlobalSetting.getInstance().isClassic
	local startx = isClassical and x2rx(920) or x2rx(860)
	local endx = isClassical and x2rx(150) or x2lx(244)
	local width = math.abs(endx - startx);
	cardLayout.cardAdvance = math.abs(width) / config.GlobalConfig.MAX_HAND_CARDNUMBER;
	cardLayout.cardScale =(cardLayout.cardAdvance / BG_WIDTH);
	cardLayout.cardLieAdvance = BG_WIDTH_LIE *(isClassical and 1 or 0.8);
	cardLayout.groupScale = cardLayout.cardAdvance * 3 /(BG_WIDTH_LIE * 3 + GROUP_SPACE);
	
	cardLayout.anchor = cc.p(startx, y2ty(640 -(BG_HEIGHT + 10) / 2 * cardLayout.cardScale));
	cardLayout.bgAdvance = cc.p(- cardLayout.cardAdvance, 0);
	cardLayout.bgAcvanceLie = cc.p(- BG_WIDTH_LIE * self:GROUP_SCALE(), 0);
	cardLayout.drawCardSpace = cc.p(- DRAW_CARD_SPACE, 0);
	cardLayout.groupSpace = cc.p(- GROUP_SPACE, 0);
	cardLayout.gangOffset = cc.p(0, - GANG_Y_DELTA * self:GROUP_SCALE());
	cardLayout.gangOffsetLie = cc.p(0, - y2by(BG_HEIGHT / 2 * cardLayout.cardScale) + y2by(BG_HEIGHT_LIE / 2 * self:GROUP_SCALE()));
	cardLayout.gangOffsetLie_mingDa = cc.p(0, - y2by(BG_HEIGHT_LIE / 2 * self:GROUP2_SCALE()) + y2by(BG_HEIGHT_LIE / 2 * self:GROUP_SCALE()));
	cardLayout.gangZOrderOffset = 1;
	cardLayout.zOrder = SHOUPAI_Z_ORDER + 20;
	cardLayout.zOrderHu = HU_SHOUPAI_ZORDER;
	cardLayout.zOrderAcvance = 0;
	
	cardLayout.discardedAniStart = cc.p(center.x + offset.x, y2ty(480));
	cardLayout.discardedAniStartZOrder = SHOUPAI_Z_ORDER;
	
	self:updateDiscardedLayout(4)
	cardLayout.discardedLayout.advance = cc.p(- BG_WIDTH_LIE * DISCARDED_CARD_SCALE, 0);
	cardLayout.discardedLayout.lineAdvance = cc.p(0, DISCARDED_V_DELTA * DISCARDED_CARD_SCALE);
	cardLayout.discardedLayout.zOrder = BASE_CARD_Z_ORDER + 20;
	cardLayout.discardedLayout.zOrderAdvance = 0;
	cardLayout.discardedLayout.zOrderLineAcvance = - 1;
	cardLayout.discardedLayout.scale = DISCARDED_CARD_SCALE
	
	cardLayout.huaLayout.lineSize = 4;
	cardLayout.huaLayout.anchor = cc.p(x2rx(916), y2ty(640 -(BG_HEIGHT + 10) / 2 * cardLayout.cardScale -(BG_HEIGHT / 2 * cardLayout.cardScale + BG_HEIGHT_LIE / 2 * HUA_CARD_SCALE + HUA_SPACE_TO_SHOUPAI)));
	cardLayout.huaLayout.advance = cc.p(0, - BG_WIDTH_LIE * HUA_CARD_SCALE);
	cardLayout.huaLayout.lineAdvance = cc.p(0, GANG_Y_DELTA * HUA_CARD_SCALE);
	cardLayout.huaLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huaLayout.zOrderAdvance = 0;
	cardLayout.huaLayout.zOrderLineAcvance = 1;
	cardLayout.huaLayout.scale = HUA_CARD_SCALE
	
	cardLayout.huLayout.lineSize = 4;
	cardLayout.huLayout.anchor = cc.p(x2px(280), y2py(520));
	cardLayout.huLayout.advance = cc.p(- BG_WIDTH_LIE * HUA_CARD_SCALE, 0);
	cardLayout.huLayout.lineAdvance = cc.p(0, GANG_Y_DELTA * HUA_CARD_SCALE);
	cardLayout.huLayout.zOrder = BASE_CARD_Z_ORDER;
	cardLayout.huLayout.zOrderAdvance = 0;
	cardLayout.huLayout.zOrderLineAcvance = 1;
	
	cardLayout.opBtnAnchor = cc.p(x2px(300), y2py(500));
	cardLayout.opBtnAdvance = cc.p(1, 0);
	cardLayout.opBtnScale = 0.7;
	cardLayout.opBtnRotation = 180;
	cardLayout.opBtnZorder = OP_BTN_Z_ORDER	
	
	cardLayout.huStatusPosition = cc.p(x2px(570), y2py(530))
	
	cardLayout.handCardColor = cc.c3b(235, 235, 235)
	cardLayout.discardColor = cc.c3b(235, 235, 235)
	
	self._elemChat:initialize(self, "animation2", self._panelTalk, self._imgMessageBorder, self._lableMessage, self._imgMessageIcon,
	self._imgTalk, self._imgXh1, self._imgXh2, self._imgXh3, self._nodeRTVoice)
end

function UIRoomSeat_Top:updateDiscardedLayout(maxPlayerCount)
	local x2cx = CC_DESIGN_RESOLUTION.screen.toCenterX
	local y2cy = CC_DESIGN_RESOLUTION.screen.toCenterY
	local center = CC_DESIGN_RESOLUTION.screen.centerPoint()
	local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()
	local size = CC_DESIGN_RESOLUTION.screen.size()
	local design = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
	local cardLayout = self:getCardLayout()
	local isClassical = game.service.GlobalSetting.getInstance().isClassic
	local startx = isClassical and 750 or 760
	local starty = isClassical and 410 or 440
	if maxPlayerCount == 2 then
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH * 2;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(1030), y2cy(starty + BG_HEIGHT_LIE * 0.5 * DISCARDED_CARD_SCALE + 5));
	else
		cardLayout.discardedLayout.lineSize = DISCARDED_SEQUENCE_LENGTH;
		cardLayout.discardedLayout.anchor = cc.p(x2cx(startx - BG_WIDTH_LIE * 0.5 * DISCARDED_CARD_SCALE - 2), y2cy(starty + BG_HEIGHT_LIE * 0.5 * DISCARDED_CARD_SCALE + 5));
	end
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