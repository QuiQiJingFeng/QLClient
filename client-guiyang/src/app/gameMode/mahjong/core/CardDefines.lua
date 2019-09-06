local CardDefines = class("CardDefines")

CardDefines.BattleConst = {
	PLAY_CARD_COUNT = 13,
	NUMBER_CARD_COUNT = 9,
	ZI_CARD_COUNT = 7,
	HUA_CARD_COUNT = 8,
	ONE_CARD_MAX = 4,
	EX_CARD_COUNT_MAX = 8,
	INVALID_ROLEID = - 1,
	INVALID_CARD_VALUE = 255,
}

-- 牌值 11-19 wan 21-29tiao 31-39 tong
CardDefines.CardType = {
	Invalid = - 1,
	Wan = 1 + 10 * 0,   -- 万
	Tiao = 1 + 10 * 1,  -- 条
	Tong = 1 + 10 * 2,  -- 筒
	Zi = 1 + 10 * 3,    -- 字牌, 东南西北中发白
	Hua = 1 + 10 * 4,   -- 花牌, 梅兰竹菊春夏秋冬
	TotalCount = 1 + 10 * 4 + CardDefines.BattleConst.HUA_CARD_COUNT    -- 总数量
}

CardDefines.Chair = {
	Invalid = 0,
	Start = 1,
	Down = 1,
	Right = 2,
	Top = 3,
	Left = 4,
	Max = 4,
}

-- 逆时针方向
CardDefines.CHAIR_MAP = {}
CardDefines.CHAIR_MAP[0] = CardDefines.Chair.Down; -- 南
CardDefines.CHAIR_MAP[1] = CardDefines.Chair.Right; -- 东
CardDefines.CHAIR_MAP[2] = CardDefines.Chair.Top; -- 北
CardDefines.CHAIR_MAP[3] = CardDefines.Chair.Left; -- 西

CardDefines.CardState = {
	Invalid	= - 1,
	Shoupai		= 0,  	-- 手牌
	Chupai		= 1,  	-- 已出牌
	MingPai		= 2,
	Pengpai		= 3,  	-- 碰牌
	GangPai		= 4,  	-- 明杠,
	GangPai2	= 5,  	-- 暗杠
	ChiPai		= 6,  	-- 吃牌
	HuaPai		= 7,  	-- 财神
	Ma_Win		= 8,    -- 奖马赢的牌
	Ma_Lose		= 9,    -- 奖马输的牌
	CardTip_Dark = 10,	-- 听牌提示蒙灰的牌
	HuPai 		= 11,	-- 多胡时的胡牌
	ShowCard	= 12,	-- 出牌时用于展示的牌
}

-- 对应着麻将的排放方式
CardDefines.BackGroundType = {
    Invalid = -1,   	
    Stand = 0,      	-- 标准放置 下方横排
    Stand_Top = 1,      -- 标准放置 上方横排
    Stand_Left = 2,     -- 标准放置 左方竖排
    Stand_Right = 3,    -- 标准放置 右方竖排
    Lie_Sur = 4,        -- 下方吃碰杠，正面朝上
    Lie_Sur_Glow = 5,   -- 平放，正面朝上，周围有光晕
    Lie_Sur_Left = 6,      -- 左侧吃碰杠, 正面朝上
    Lie_Sur_Right = 7,      -- 右侧吃碰杠, 正面朝上
    Lie_Sur_Top = 8,      -- 上侧吃碰杠, 正面朝上
    Lie_Back = 9,       -- 竖着平放，背面朝上
    Lie_Back_Left = 10,      -- 左侧杠, 背面朝上
    Lie_Back_Right = 11,      -- 右侧杠, 背面朝上
    Lie_Back_Top = 12,      -- 右侧杠, 背面朝上
    Lie_H_Back = 13,     -- 横着平放，背面朝上
    Lie_H_Sur = 14,      -- 竖牌平放，正面朝上
    Lie_H_Sur_Left = 15,      -- 左侧牌横着平放，正面朝上
    Lie_H_Sur_Right = 16,      -- 右侧牌横着平放，正面朝上
    Lie_H_Sur_Top = 17,      -- 对家牌打出竖牌平放，正面朝上
    Lie_H_Sur_Glow = 18, -- 横着平放，正面朝上，周围有光晕
    Lie_R_Sur = 19,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Left = 20,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Right = 21,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Top = 22,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Back = 23,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Back_Left = 24,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Back_Right = 25,     -- 花牌和闷胡牌, 本家
    Lie_R_Sur_Back_Top = 26,     -- 花牌和闷胡牌, 本家
    Stand_Back = 27,    -- 标准放置，背面朝前

	QP_Left = 28,
	QP_Right = 29,
	QP_Top = 30,
	QP_Back = 31,

	Show_Sur_Back = 32,		-- 出牌后用来展示的牌

	Lie_Sur_Glow_Purple = 45, -- 平放，正面朝上，周围有紫色光晕
	Lie_H_Sur_Glow_Purple = 46, -- 横着平放，正面朝上，周围有紫色光晕
	CardTip_Dark = 47, 		-- 听牌提示 蒙灰牌

    COUNT = 48,         -- 枚举数量，不要使用
}

CardDefines.ButtonType = {
	Pass = 1,
	Gang = 2,
	Peng = 3,
	Ting = 4,
	Hu = 5,
}

CardDefines.CornerType = {
	Invalid = - 1,
	Default = 0,
	GuiPai = 0,
	ZhengPai = 1,
	RemaingCards = 2,
	-- Count必须正确
	Count = 3
}

-- 获取指定牌的类型
-- @param number
-- @return number
function CardDefines.getCardType(cardValue)
	if cardValue >= CardDefines.CardType.Wan and cardValue < CardDefines.CardType.Wan + CardDefines.BattleConst.NUMBER_CARD_COUNT then
		return CardDefines.CardType.Wan;
	elseif cardValue >= CardDefines.CardType.Tiao and cardValue < CardDefines.CardType.Tiao + CardDefines.BattleConst.NUMBER_CARD_COUNT then
		return CardDefines.CardType.Tiao;
	elseif cardValue >= CardDefines.CardType.Tong and cardValue < CardDefines.CardType.Tong + CardDefines.BattleConst.NUMBER_CARD_COUNT then
		return CardDefines.CardType.Tong;
	elseif cardValue >= CardDefines.CardType.Zi and cardValue < CardDefines.CardType.Zi + CardDefines.BattleConst.ZI_CARD_COUNT then
		return CardDefines.CardType.Tong;
	elseif cardValue >= CardDefines.CardType.Hua and cardValue < CardDefines.CardType.Hua + CardDefines.BattleConst.HUA_CARD_COUNT then
		return CardDefines.CardType.Tong;
	else
		return CardDefines.CardType.Invalid;
	end
end

-- 获取一个牌值是否为有效值
-- @return boolean
function CardDefines.isValidCardNumber(cardValue)
	return cardValue ~= nil and cardValue > 0 and cardValue < CardDefines.CardType.TotalCount;
end

--[[cards string to card
]]
function CardDefines.getCards(str)
	local cards = {}
	if(type(str) == "string") then
		for i = 1, #str do
			local cardValue = string.byte(str, i)
			table.insert(cards, cardValue)
		end
		return cards
	else
		return str
	end
	
end

return CardDefines;
