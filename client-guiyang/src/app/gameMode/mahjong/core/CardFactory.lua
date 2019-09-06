local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local ONE_CARD_MAX = 4;
local ONE_TYPE_MAX = 9;
local PLAY_CARD_COUNT = 13;
local ZI_TYPE_MAX = 7;
local HUA_TYPE_MAX = 8;

local cardAtlasFile = "art/%s.plist"

local surfaceConfig = {}

surfaceConfig[CardDefines.CardType.Wan + 0] =	{skin = "art/%s/w_1.png",		name = "一万"}
surfaceConfig[CardDefines.CardType.Wan + 1] =	{skin = "art/%s/w_2.png",		name = "二万"}
surfaceConfig[CardDefines.CardType.Wan + 2] =	{skin = "art/%s/w_3.png",		name = "三万"}
surfaceConfig[CardDefines.CardType.Wan + 3] =	{skin = "art/%s/w_4.png",		name = "四万"}
surfaceConfig[CardDefines.CardType.Wan + 4] =	{skin = "art/%s/w_5.png",		name = "五万"}
surfaceConfig[CardDefines.CardType.Wan + 5] =	{skin = "art/%s/w_6.png",		name = "六万"}
surfaceConfig[CardDefines.CardType.Wan + 6] =	{skin = "art/%s/w_7.png",		name = "七万"}
surfaceConfig[CardDefines.CardType.Wan + 7] =	{skin = "art/%s/w_8.png",		name = "八万"}
surfaceConfig[CardDefines.CardType.Wan + 8] =	{skin = "art/%s/w_9.png",		name = "九万"}
surfaceConfig[CardDefines.CardType.Tiao + 0] =	{skin = "art/%s/tiao_1.png",	name = "幺鸡"}
surfaceConfig[CardDefines.CardType.Tiao + 1] =	{skin = "art/%s/tiao_2.png",	name = "二条"}
surfaceConfig[CardDefines.CardType.Tiao + 2] =	{skin = "art/%s/tiao_3.png",	name = "三条"}
surfaceConfig[CardDefines.CardType.Tiao + 3] =	{skin = "art/%s/tiao_4.png",	name = "四条"}
surfaceConfig[CardDefines.CardType.Tiao + 4] =	{skin = "art/%s/tiao_5.png",	name = "五条"}
surfaceConfig[CardDefines.CardType.Tiao + 5] =	{skin = "art/%s/tiao_6.png",	name = "六条"}
surfaceConfig[CardDefines.CardType.Tiao + 6] =	{skin = "art/%s/tiao_7.png",	name = "七条"}
surfaceConfig[CardDefines.CardType.Tiao + 7] =	{skin = "art/%s/tiao_8.png",	name = "八条"}
surfaceConfig[CardDefines.CardType.Tiao + 8] =	{skin = "art/%s/tiao_9.png",	name = "九条"}
surfaceConfig[CardDefines.CardType.Tong + 0] =	{skin = "art/%s/tong_1.png",	name = "一筒"}
surfaceConfig[CardDefines.CardType.Tong + 1] =	{skin = "art/%s/tong_2.png",	name = "二筒"}
surfaceConfig[CardDefines.CardType.Tong + 2] =	{skin = "art/%s/tong_3.png",	name = "三筒"}
surfaceConfig[CardDefines.CardType.Tong + 3] =	{skin = "art/%s/tong_4.png",	name = "四筒"}
surfaceConfig[CardDefines.CardType.Tong + 4] =	{skin = "art/%s/tong_5.png",	name = "五筒"}
surfaceConfig[CardDefines.CardType.Tong + 5] =	{skin = "art/%s/tong_6.png",	name = "六筒"}
surfaceConfig[CardDefines.CardType.Tong + 6] =	{skin = "art/%s/tong_7.png",	name = "七筒"}
surfaceConfig[CardDefines.CardType.Tong + 7] =	{skin = "art/%s/tong_8.png",	name = "八筒"}
surfaceConfig[CardDefines.CardType.Tong + 8] =	{skin = "art/%s/tong_9.png",	name = "九筒"}
surfaceConfig[CardDefines.CardType.Zi + 0] =	{skin = "art/%s/zi_dong.png",	name = "东"}
surfaceConfig[CardDefines.CardType.Zi + 1] =	{skin = "art/%s/zi_nan.png",	name = "南"}
surfaceConfig[CardDefines.CardType.Zi + 2] =	{skin = "art/%s/zi_xi.png",		name = "西"}
surfaceConfig[CardDefines.CardType.Zi + 3] =	{skin = "art/%s/zi_bei.png",	name = "北"}
surfaceConfig[CardDefines.CardType.Zi + 4] =	{skin = "art/%s/zi_zhong.png",	name = "中"}
surfaceConfig[CardDefines.CardType.Zi + 5] =	{skin = "art/%s/zi_fa.png",		name = "发"}
surfaceConfig[CardDefines.CardType.Zi + 6] =	{skin = "art/%s/zi_bai.png",	name = "白"}
surfaceConfig[CardDefines.CardType.Hua + 0] =	{skin = "art/%s/tiao_45.png",	name = "春"}
surfaceConfig[CardDefines.CardType.Hua + 1] =	{skin = "art/%s/tiao_46.png",	name = "夏"}
surfaceConfig[CardDefines.CardType.Hua + 2] =	{skin = "art/%s/tiao_47.png",	name = "秋"}
surfaceConfig[CardDefines.CardType.Hua + 3] =	{skin = "art/%s/tiao_48.png",	name = "冬"}
surfaceConfig[CardDefines.CardType.Hua + 4] =	{skin = "art/%s/tiao_41.png",	name = "梅"}
surfaceConfig[CardDefines.CardType.Hua + 5] =	{skin = "art/%s/tiao_42.png",	name = "兰"}
surfaceConfig[CardDefines.CardType.Hua + 6] =	{skin = "art/%s/tiao_43.png",	name = "竹"}
surfaceConfig[CardDefines.CardType.Hua + 7] =	{skin = "art/%s/tiao_44.png",	name = "菊"}

local backGroundConfig = {}
-- 2d
backGroundConfig[CardDefines.BackGroundType.Stand] =			{csb = "ui/csb/Card/%s/Card_Stand.csb", bg = "art/%s/%s/mj_bg.png"}
backGroundConfig[CardDefines.BackGroundType.Stand_Top] =		{csb = "ui/csb/Card/%s/Card_Stand_Top.csb", bg = "art/%s/%s/mj_bg3.png"}
backGroundConfig[CardDefines.BackGroundType.Stand_Left] =		{csb = "ui/csb/Card/%s/Card_Stand_Left.csb", bg = "art/%s/%s/mj_bg5.png"}
backGroundConfig[CardDefines.BackGroundType.Stand_Right] =		{csb = "ui/csb/Card/%s/Card_Stand_Right.csb", bg = "art/%s/%s/mj_bg4.png"}
backGroundConfig[CardDefines.BackGroundType.Lie_Sur] =			{csb = "ui/csb/Card/%s/Card_Lie_Sur.csb", bg = "art/%s/%s/mj_bg2.png"}
backGroundConfig[CardDefines.BackGroundType.Lie_Sur_Glow] =	{csb = "ui/csb/Card/%s/Card_Lie_Sur_Glow.csb", bg = "art/%s/%s/mj_bg9.png"}
backGroundConfig[CardDefines.BackGroundType.Lie_Back] =		{csb = "ui/csb/Card/%s/Card_Lie_Back.csb", bg = "art/%s/%s/mj_bg7.png"}
backGroundConfig[CardDefines.BackGroundType.Lie_H_Back] =		{csb = "ui/csb/Card/%s/Card_Lie_H_Back.csb", bg = "art/%s/%s/mj_bg8.png"}
backGroundConfig[CardDefines.BackGroundType.Lie_H_Sur] =		{csb = "ui/csb/Card/%s/Card_Lie_H_Sur.csb", bg = "art/%s/%s/mj_bg6.png"}
backGroundConfig[CardDefines.BackGroundType.Stand_Back] =	{csb = "ui/csb/Card/%s/Card_Watcher.csb", bg = "art/%s/%s/mj_bg1.png"}
backGroundConfig[CardDefines.BackGroundType.Lie_H_Sur_Glow] =	{csb = "ui/csb/Card/%s/Card_Lie_H_Sur_Glow.csb", bg = "art/%s/%s/mj_bg10.png"}

local backGroundConfig3D = {}
-- 3d
backGroundConfig3D[CardDefines.BackGroundType.Lie_Sur_Left] =	{csb = "ui/csb/Card/%s/Card_HP_Left.csb", bg = "art/%s/%s/mj_mp2.png"}
backGroundConfig3D[CardDefines.BackGroundType.Lie_Sur_Right] =	{csb = "ui/csb/Card/%s/Card_HP_Right.csb", bg = "art/%s/%s/mj_mp2.png"}
backGroundConfig3D[CardDefines.BackGroundType.Lie_Sur_Top] =	{csb = "ui/csb/Card/%s/Card_HP_Top_%d.csb", bg = "art/%s/%s/mj_mp3.png"}
backGroundConfig3D[CardDefines.BackGroundType.Lie_Sur] =	{csb = "ui/csb/Card/%s/Card_HP_Back_%d.csb", bg = "art/%s/%s/mj_mp3.png"}

backGroundConfig3D[CardDefines.BackGroundType.Lie_Back_Left] =	{csb = "ui/csb/Card/%s/Card_GP_Left.csb", bg = "art/%s/%s/mj_ap2.png"}
backGroundConfig3D[CardDefines.BackGroundType.Lie_Back_Right] =	{csb = "ui/csb/Card/%s/Card_GP_Right.csb", bg = "art/%s/%s/mj_ap2.png"}
backGroundConfig3D[CardDefines.BackGroundType.Lie_Back_Top] =	{csb = "ui/csb/Card/%s/Card_GP_%d.csb", bg = "art/%s/%s/mj_ap3.png"}
backGroundConfig3D[CardDefines.BackGroundType.Lie_Back] =	{csb = "ui/csb/Card/%s/Card_GP_%d.csb", bg = "art/%s/%s/mj_ap3.png"}

backGroundConfig3D[CardDefines.BackGroundType.Stand] =			{csb = "ui/csb/Card/%s/Card_Stand.csb", bg = "art/%s/%s/mj_bg.png"}
backGroundConfig3D[CardDefines.BackGroundType.Stand_Back] =	{csb = "ui/csb/Card/%s/Card_Watcher.csb", bg = "art/%s/%s/mj_bg1.png"}
backGroundConfig3D[CardDefines.BackGroundType.Stand_Left] =	{csb = "ui/csb/Card/%s/Card_Stand_Left.csb", bg = "art/mahjong_card_3d_new/bg01/mj_sp2.png"}
backGroundConfig3D[CardDefines.BackGroundType.Stand_Right] =	{csb = "ui/csb/Card/%s/Card_Stand_Right.csb", bg = "art/mahjong_card_3d_new/bg01/mj_sp2.png"}
backGroundConfig3D[CardDefines.BackGroundType.Stand_Top] =		{csb = "ui/csb/Card/%s/Card_Watcher.csb", bg = "art/%s/%s/mj_bg3.png"}

backGroundConfig3D[CardDefines.BackGroundType.QP_Left] =	{csb = "ui/csb/Card/%s/Card_QP_Left.csb", bg = "art/%s/%s/mj_hp1_1.png"}
backGroundConfig3D[CardDefines.BackGroundType.QP_Right] =	{csb = "ui/csb/Card/%s/Card_QP_Right.csb", bg = "art/%s/%s/mj_hp4_1.png"}
backGroundConfig3D[CardDefines.BackGroundType.QP_Top] =	{csb = "ui/csb/Card/%s/Card_QP_Top_%d.csb", bg = "art/%s/%s/mj_hp2_1.png"}
backGroundConfig3D[CardDefines.BackGroundType.QP_Back] =	{csb = "ui/csb/Card/%s/Card_QP_Back_%d.csb", bg = "art/%s/%s/mj_hp3_1.png"}

backGroundConfig3D[CardDefines.BackGroundType.Show_Sur_Back] =	{csb = "ui/csb/Card/%s/Card_Lie_Sur.csb", bg = "art/%s/%s/mj_hp3_1.png"}

-- todo 潮汕内蒙 填上bg
backGroundConfig[CardDefines.BackGroundType.Lie_Sur_Glow_Purple] =		{csb = "ui/csb/Card/%s/Card_Lie_Sur_Purple.csb"}
backGroundConfig[CardDefines.BackGroundType.Lie_H_Sur_Glow_Purple] =		{csb = "ui/csb/Card/%s/Card_Lie_H_Sur_Purple.csb"}

backGroundConfig[CardDefines.BackGroundType.CardTip_Dark] =		{csb = "ui/csb/Card/%s/Card_Lie_CardTips_Dark.csb", bg = "art/%s/%s/mj_bg11.png"}

local CardFactoryData = class("CardFactoryData")
function CardFactoryData:ctor()
	self._style = config.CARD_STYLE.STYLE_1  -- 玩家比赛分享数据
end

function CardFactoryData:getStyle()
	return self._style
end

function CardFactoryData:setStyle(style)
	self._style = style
end


cc.exports.CardFactory = class("CardFactory")
CardFactory._instance = nil;
local Card = require("app.gameMode.mahjong.core.Card")
function CardFactory:ctor()
	self._cardStyle = nil
	
	self._cardPool = nil
	-- 当前使用的牌列表，与上面的池无关
	self._cardList = {}
	
	self._monitor = require("app.gameMode.mahjong.core.CardTextureMonitor")(handler(self, self._reportTextureError))
	
	self:_loadLocalStorage()
	self:_loadAtlasFile()
	self:init();
end

function CardFactory:setCardStyle(style)
	self._cardStyle = config.CARD_STYLE_CFG['style_' .. style]
	self:_loadAtlasFile()
	self:_saveLocalSetting(style)
	
	if iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Mahjong") then
		game.service.RoomCreatorService.getInstance():queryBattleIdReq(game.service.RoomService:getInstance():getRoomId(), nil, false);
	end
end

function CardFactory:init()
	self._cardPool = ObjectPool:create(Card, 10, 1000);
end

function CardFactory:_reportTextureError(type, texture)
	local data = {
		type = type,
		msg = texture
	}
	dispatchGlobalEvent("MAHJONG_REPORT_ERROR", data)
end

function CardFactory:addTexture(texture)
	self._monitor.add(texture)
end

function CardFactory:removeTexture(texture)
	self._monitor.rm(texture)
end

function CardFactory:_loadAtlasFile()
	-- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	local _cardAtlasFile = string.format(cardAtlasFile, self._cardStyle.atlas)
	cc.SpriteFrameCache:getInstance():addSpriteFrames(_cardAtlasFile); -- 2d
	cc.SpriteFrameCache:getInstance():addSpriteFrames("art/mahjong_card_3d_new.plist"); -- 3d
	cc.SpriteFrameCache:getInstance():addSpriteFrames("mahjong_card_classical.plist"); -- 经典
end

function CardFactory:getInstance()
	if nil == CardFactory._instance then
		CardFactory._instance = CardFactory:new()
	end
	return CardFactory._instance;
end

function CardFactory:_loadLocalStorage()
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	local localdata = manager.LocalStorage.getUserData(roleId, "card_factory_card_style", CardFactoryData)
	self._cardStyle = config.CARD_STYLE_CFG[localdata:getStyle()];
end

function CardFactory:_saveLocalSetting(data)
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	local cardFactoryData = CardFactoryData.new()
	cardFactoryData:setStyle('style_' .. data)
	manager.LocalStorage.setUserData(roleId, "card_factory_card_style", cardFactoryData);
end

function CardFactory:getSurfaceSkin(cardValue)
	if CardDefines.isValidCardNumber(cardValue) then
		local _cardStyle = config.CARD_STYLE_CFG['style_1']
		return string.format(surfaceConfig[cardValue].skin, _cardStyle.atlas)
	else
		return nil
	end
end

-- 3d默认显示3d的牌，无需保存
function CardFactory:_getCardStyle(is3d)
	if is3d then
		return self:sytleTo3D()
	elseif config.getIs3D() then
		-- 如果是3D麻将的配置贼2D用绿色的牌背设置
		return config.CARD_STYLE_CFG["style_2"]
	elseif game.service.GlobalSetting.getInstance().isClassic then
		return config.CARD_STYLE_CFG["style_1_classical"]
	else
		return self._cardStyle
	end
	
end

function CardFactory:sytleTo3D()
	local name = self._cardStyle["name"]
	local style = config.CARD_STYLE[name .. "_3D"]
	return config.CARD_STYLE_CFG[style]
end

-- 切换2/3d的中间状态
local isChanging = false
local is3d = nil

function CardFactory:change2or3D(_is3d)
	is3d = _is3d
	isChanging = true
end

function CardFactory:realChange2or3D()
	if isChanging then
		isChanging = false
		game.service.GlobalSetting.getInstance().is3D = is3d
		config.change2D3DReset()
	end
end

function CardFactory:CreateCard(ctx)
	local _scale = nil;
	if ctx.sizeScale == nil or ctx.sizeScale <= 0 then
		_scale = 1;
	else
		_scale = ctx.sizeScale;
	end
	local _surScale = nil;
	if ctx.sizeScale == nil or ctx.sizeScale <= 0 then
		_surScale = 1;
	else
		_surScale = ctx.sizeScale;
	end
	if nil == ctx.cardValue then
		ctx.cardValue = - 1;
	end
	
	local card = nil;
	--牌面图案的旋转
	local surRotation = 0;
	local haveSurface = true;
	local backGroundType = CardDefines.BackGroundType.Invalid;
	
	if ctx.state == CardDefines.CardState.Shoupai then
		if ctx.chair == CardDefines.Chair.Down then
			if ctx.cardValue ~= - 1 then
				backGroundType = CardDefines.BackGroundType.Stand_Back;
			else
				backGroundType = CardDefines.BackGroundType.Stand;
			end
		elseif ctx.chair == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Stand_Left;
			haveSurface = false;
		elseif ctx.chair == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Stand_Right;
			haveSurface = false;
		elseif ctx.chair == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Stand_Top;
			haveSurface = false;
		end
	elseif ctx.state == CardDefines.CardState.Chupai then
		if ctx.chair == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Sur;
		elseif ctx.chair == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
			surRotation = 90;
		elseif ctx.chair == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
			surRotation = - 90;
		elseif ctx.chair == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Sur;
			surRotation = 180;
		end
	elseif ctx.state == CardDefines.CardState.Pengpai or
	ctx.state == CardDefines.CardState.GangPai or
	ctx.state == CardDefines.CardState.ChiPai or
	ctx.state == CardDefines.CardState.HuaPai or
	cardState == CardDefines.CardState.HuPai then
		if cardValue == CardDefines.BattleConst.INVALID_CARD_VALUE then
			if ctx.chair == CardDefines.Chair.Down then
				backGroundType = CardDefines.BackGroundType.Lie_Back;
			elseif ctx.chair == CardDefines.Chair.Left then
				backGroundType = CardDefines.BackGroundType.Lie_H_Back;
			elseif ctx.chair == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_H_Back;
			elseif ctx.chair == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Back;
			end
		else
			if ctx.chair == CardDefines.Chair.Down then
				backGroundType = CardDefines.BackGroundType.Lie_Sur;
			elseif ctx.chair == CardDefines.Chair.Left then
				backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
				surRotation = 90;
			elseif ctx.chair == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
				surRotation = - 90;
			elseif ctx.chair == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Sur;
				surRotation = 180;
			end
		end
	elseif ctx.state == CardDefines.CardState.GangPai2 then
		if ctx.chair == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Back;
		elseif ctx.chair == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_H_Back;
		elseif ctx.chair == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_H_Back;
		elseif ctx.chair == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Back;
		end
	elseif ctx.state == CardDefines.CardState.Ma_Lose then
		
		if ctx.chair == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Sur_Glow_Purple;
		elseif ctx.chair == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur_Glow_Purple;
			surRotation = 90;
		elseif ctx.chair == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur_Glow_Purple;
			surRotation = - 90;
		elseif ctx.chair == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Sur_Glow_Purple;
			surRotation = 180;
		end
	elseif ctx.state == CardDefines.CardState.Ma_Win then
		
		if ctx.chair == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Sur_Glow;
		elseif ctx.chair == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur_Glow;
		elseif ctx.chair == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur_Glow;
		elseif ctx.chair == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Sur_Glow;
		end
	end
	
	
	if backGroundType == CardDefines.BackGroundType.Invalid then
		error("Invalid state type or chair type.");
		return nil;
	end
	
	local csb = backGroundConfig[backGroundType].csb
	local bg = backGroundConfig[backGroundType].bg
	if nil == csb or "" == csb then
		return nil;
	end
	local img = self:getSurfaceImg(ctx.cardValue)
	local _result = self._cardPool:getObject();
	
	local _cardStyle = config.CARD_STYLE_CFG['style_1']
	_result:setVisible(true)
	if not ctx.fromRull then	
		_result:reset(ctx.cardValue, ctx.chair, ctx.state, backGroundType, ctx.cornerTypes, csb, img, bg, self:_getCardStyle())
	else
		_result:reset(ctx.cardValue, ctx.chair, ctx.state, backGroundType, ctx.cornerTypes, csb, img, bg, _cardStyle) -- 帮助界面的只用2d第一套牌
	end
	_result:scale(_scale)
	_result:rotation(surRotation)
	table.insert(self._cardList, _result)
	return _result;
end

function CardFactory:createCard2(chairType, cardState, cardValue, tagIconType, sizeScale, tagIconTxt)
	-- scale应该是有效值
	if sizeScale == nil or sizeScale <= 0 then
		sizeScale = 1;
	end
	
	-- cardValue应该是有效值
	if cardValue == nil or cardValue <= 0 then
		cardValue = CardDefines.BattleConst.INVALID_CARD_VALUE
	end
	
	-- 获取创建牌参数
	local surRotation = 0;
	local backGroundType = CardDefines.BackGroundType.Invalid;
	
	if cardState == CardDefines.CardState.Shoupai then		
		if cardValue == CardDefines.BattleConst.INVALID_CARD_VALUE then
			-- 立着的手牌
			if chairType == CardDefines.Chair.Down then
				-- 观战的时候，是没有牌值的
				backGroundType = CardDefines.BackGroundType.Stand_Back;
			elseif chairType == CardDefines.Chair.Left then
				-- 其他人是扣着的
				backGroundType = CardDefines.BackGroundType.Stand_Left;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Stand_Right;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Stand_Top;
			end
		else
			-- 躺着的手牌
			if chairType == CardDefines.Chair.Down then
				-- 自己的手牌永远是亮着的
				backGroundType = CardDefines.BackGroundType.Stand;
			elseif chairType == CardDefines.Chair.Left then
				-- 其他人是扣着的
				backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
				surRotation = 90;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
				surRotation = - 90;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Sur;
				surRotation = 180;
			end
		end
		
	elseif cardState == CardDefines.CardState.Chupai then
		if chairType == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Sur;
		elseif chairType == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
			surRotation = 90;
		elseif chairType == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
			surRotation = - 90;
		elseif chairType == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Sur;
			surRotation = 180;
		end
		
	elseif cardState == CardDefines.CardState.Pengpai or
	cardState == CardDefines.CardState.GangPai or
	cardState == CardDefines.CardState.ChiPai or
	cardState == CardDefines.CardState.HuaPai or
	cardState == CardDefines.CardState.HuPai then
		if cardValue == CardDefines.BattleConst.INVALID_CARD_VALUE then
			if chairType == CardDefines.Chair.Down then
				backGroundType = CardDefines.BackGroundType.Lie_Back;
			elseif chairType == CardDefines.Chair.Left then
				backGroundType = CardDefines.BackGroundType.Lie_H_Back;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_H_Back;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Back;
			end
		else
			if chairType == CardDefines.Chair.Down then
				backGroundType = CardDefines.BackGroundType.Lie_Sur;
			elseif chairType == CardDefines.Chair.Left then
				backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
				surRotation = 90;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_H_Sur;
				surRotation = - 90;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Sur;
				surRotation = 180;
			end
		end
	elseif cardState == CardDefines.CardState.GangPai2 then
		if chairType == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Back;
		elseif chairType == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_H_Back;
		elseif chairType == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_H_Back;
		elseif chairType == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Back;
		end
	elseif cardState == CardDefines.CardState.CardTip_Dark then
		backGroundType = CardDefines.BackGroundType.CardTip_Dark;
	end
	
	if backGroundType == CardDefines.BackGroundType.Invalid then
		error("Invalid state type or chair type. ");
		return nil;
	end
	
	-- 
	local csb = backGroundConfig[backGroundType].csb
	local bg = backGroundConfig[backGroundType].bg
	local surfaceImg = nil
	if cardValue ~= CardDefines.BattleConst.INVALID_CARD_VALUE then
		surfaceImg = surfaceConfig[cardValue].skin
	end
	
	local card = self._cardPool:getObject();
	card:setVisible(true)
	card:reset(cardValue, chairType, cardState, backGroundType, tagIconType, csb, surfaceImg, bg, self:_getCardStyle(), tagIconTxt) -- 只用2d的牌
	card:scale(sizeScale)
	card:rotation(surRotation)
	table.insert(self._cardList, card)
	return card;
end

function CardFactory:createCard3d(chairType, cardState, cardIndex, cardValue, tagIconType, sizeScale)
	-- scale应该是有效值
	if sizeScale == nil or sizeScale <= 0 then
		sizeScale = 1;
	end
	
	-- cardValue应该是有效值
	if cardValue == nil or cardValue <= 0 then
		cardValue = CardDefines.BattleConst.INVALID_CARD_VALUE
	end
	
	-- 获取创建牌参数
	local backGroundType, surRotation = self:getCard3Dbackground(chairType, cardState, cardIndex, cardValue)
	
	if backGroundType == CardDefines.BackGroundType.Invalid then
		error("Invalid state type or chair type. ");
		return nil;
	end
	
	-- 
	local csb = self:get3DCsbByBGType(backGroundType, cardIndex)
	local bg = backGroundConfig3D[backGroundType].bg
	local surfaceImg = self:getSurfaceImg(cardValue)
	
	local card = self._cardPool:getObject();
	card:reset(cardValue, chairType, cardState, backGroundType, tagIconType, csb, surfaceImg, bg, self:_getCardStyle(true), nil, cardIndex)
	card:scale(sizeScale)
	card:rotation(surRotation)
	card:setSkewX(0)
	return card;
end

function CardFactory:getCard3Dbackground(chairType, cardState, cardIndex, cardValue)
	local backGroundType = CardDefines.BackGroundType.Invalid
	local surRotation = 0;
	if cardState == CardDefines.CardState.Shoupai then		
		if cardValue == CardDefines.BattleConst.INVALID_CARD_VALUE then
			-- 立着的手牌
			if chairType == CardDefines.Chair.Down then
				-- 观战的时候，是没有牌值的
				backGroundType = CardDefines.BackGroundType.Stand_Back;
			elseif chairType == CardDefines.Chair.Left then
				-- 其他人是扣着的
				backGroundType = CardDefines.BackGroundType.Stand_Left;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Stand_Right;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Stand_Top;
			end
		else
			-- 躺着的手牌
			if chairType == CardDefines.Chair.Down then
				-- 自己的手牌永远是亮着的
				backGroundType = CardDefines.BackGroundType.Stand;
			elseif chairType == CardDefines.Chair.Left then
				-- 其他人是扣着的
				backGroundType = CardDefines.BackGroundType.Lie_Sur_Left;
				
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_Sur_Right;
				
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Sur_Top;
			end
		end
		
	elseif cardState == CardDefines.CardState.Chupai then
		if chairType == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.QP_Back;
		elseif chairType == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.QP_Left;
		elseif chairType == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.QP_Right;
		elseif chairType == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.QP_Top;
		end
		
	elseif cardState == CardDefines.CardState.Pengpai or
	cardState == CardDefines.CardState.GangPai or
	cardState == CardDefines.CardState.ChiPai or
	cardState == CardDefines.CardState.MingPai or
	cardState == CardDefines.CardState.HuaPai or
	cardState == CardDefines.CardState.HuPai then
		if cardValue == CardDefines.BattleConst.INVALID_CARD_VALUE then
			if chairType == CardDefines.Chair.Down then
				backGroundType = CardDefines.BackGroundType.Lie_Back;
			elseif chairType == CardDefines.Chair.Left then
				backGroundType = CardDefines.BackGroundType.Lie_Back_Left;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_Back_Right;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Back_Top;
			end
		else
			if chairType == CardDefines.Chair.Down then
				backGroundType = CardDefines.BackGroundType.Lie_Sur;
			elseif chairType == CardDefines.Chair.Left then
				backGroundType = CardDefines.BackGroundType.Lie_Sur_Left;
			elseif chairType == CardDefines.Chair.Right then
				backGroundType = CardDefines.BackGroundType.Lie_Sur_Right;
			elseif chairType == CardDefines.Chair.Top then
				backGroundType = CardDefines.BackGroundType.Lie_Sur_Top;
			end
		end
	elseif cardState == CardDefines.CardState.GangPai2 then
		if chairType == CardDefines.Chair.Down then
			backGroundType = CardDefines.BackGroundType.Lie_Back;
		elseif chairType == CardDefines.Chair.Left then
			backGroundType = CardDefines.BackGroundType.Lie_Back_Left;
		elseif chairType == CardDefines.Chair.Right then
			backGroundType = CardDefines.BackGroundType.Lie_Back_Right;
		elseif chairType == CardDefines.Chair.Top then
			backGroundType = CardDefines.BackGroundType.Lie_Back_Top;
		end
	elseif cardState == CardDefines.CardState.ShowCard then
		backGroundType = CardDefines.BackGroundType.Show_Sur_Back
	end
	return backGroundType, surRotation
end

function CardFactory:get3DCsbByBGType(backgroundType)
	return backGroundConfig3D[backgroundType].csb
end

function CardFactory:get3DCardBgByBGType(backgroundType)
	return backGroundConfig[backgroundType].bg
end

function CardFactory:getSurfaceImg(cardValue)
	local surfaceImg = nil
	if cardValue ~= CardDefines.BattleConst.INVALID_CARD_VALUE then
		surfaceImg = surfaceConfig[cardValue].skin
	end
	return surfaceImg
end

function CardFactory:releaseCard(card)
	if nil == card then
		error("ERROR: card is nil!")
		return;
	end
	local idx = table.indexof(self._cardList, card)
	if idx then
		table.remove(self._cardList, idx)
	end
	card:delete();
end

-- TODO: 现在有部分地区出现有牌不显示的问题，怀疑是有卡牌没有release，直接跟随UI被析构了，做一下缓存，看看是否如此
function CardFactory:releaseAllCards()
	if Macro.assertTrue(#self._cardList > 0, "CARD_ERROR(NOT RELEASE)") then
		Logger.debug("left card number: " .. #self._cardList)
		for _, card in ipairs(self._cardList) do
			self:releaseCard(card)
		end
		self._cardList = {}
	end
end 