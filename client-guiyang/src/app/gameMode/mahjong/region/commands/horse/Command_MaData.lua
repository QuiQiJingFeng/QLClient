local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local CommandBase = require("app.manager.CommandBase")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Command_MaData = class("Command_MaData", CommandBase)

local isFristMaAnim = false

--买马/罚马牌的位置
local function getMaProperty(playerProcessor)
	local layout = playerProcessor._seatUI:getCardLayout().huaLayout
	local chairType = playerProcessor._seatUI:getChairType()
	local offset = {x = 0, y = 0, zOrder = 1, baseZOrder = layout.zOrder, huShouPaiZOrder = playerProcessor._seatUI:getCardLayout().zOrderHu, scale = layout.scale}
	if chairType == CardDefines.Chair.Down then
		offset.x = 1.2
		offset.y = 0
	elseif chairType == CardDefines.Chair.Left then
		offset.x = 0
		offset.y = - 0.9
	elseif	chairType == CardDefines.Chair.Right then
		offset.x = 0
		offset.y = 0.9
	elseif chairType == CardDefines.Chair.Top then
		offset.x = - 1.2
		offset.y = 0
	end
	return {pos = cc.p(layout.anchor.x, layout.anchor.y), offset = offset, scale = layout.scale}
end
--播放买马开始的动画
local function playAniMaStart(playerProcessor, isRecover)
	local size = cc.Director:getInstance():getWinSize()
	
	local data = playerProcessor._cardList.mapais;
	local duration = 0.5
	if isRecover then
		duration = 0.01
	end
	for i = 1, data.maCount do
		local startPos = cc.p(size.width / 2, size.height / 2)
		local property = getMaProperty(playerProcessor)
		
		--这里使用杠牌2的牌面来创建压着的牌
		local card = playerProcessor._seatUI:createCard(CardDefines.CardState.GangPai2, nil, false, property.scale)
		card:setZOrder(property.offset.baseZOrder + property.offset.zOrder * i)
		card:setPosition(startPos)
		card:setScale(property.offset.scale or 1);
		table.insert(playerProcessor._cardList.maCards, card)
		
		-- 调整第二个开始的牌位置
		local offset = property.offset;
		local width, height = card:getSize()
		property.pos.x = property.pos.x +(i - 1) *(property.offset.x * width)
		property.pos.y = property.pos.y +(i - 1) *(property.offset.y * height)
		local anim = cc.MoveTo:create(duration, property.pos);
		card:runAction(anim)
	end
	
end
--播放牌局结束的买马翻过来的动画
local function playAniMaEnd(playerProcessor)
	local data = playerProcessor._cardList.mapais;
	for i = 1, #data.all do
		local maCards = playerProcessor._cardList.maCards
		local cardState = CardDefines.CardState.HuaPai
		if table.indexof(data.win, data[i]) then
			cardState = CardDefines.CardState.Ma_Win
		elseif table.indexof(data.lose, data[i]) then
			cardState = CardDefines.CardState.Ma_Lose
		end
		
		local property = getMaProperty(playerProcessor)
		local card = playerProcessor._seatUI:createCard(cardState, data.all[i], false, property.scale)
		table.insert(maCards, card)
		--让马牌不被手牌盖住
		card:setZOrder(maCards[i]:getLocalZOrder() + property.offset.huShouPaiZOrder + 20)
		card:setPosition(maCards[i]:getPositionX(), maCards[i]:getPositionY())
		card:setVisible(false)
		local anim = cc.RotateBy:create(0.5, 360)
		local callback = cc.CallFunc:create(function()
			maCards[i]:setRotation(0)
			card:setVisible(true)
		end)
		maCards[i]:runAction(cc.Sequence:create(anim, callback))
		
	end
end

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_MaData:ctor(args)
	self.super:ctor(args)
	self._recover = self.__args[1]
	self._stepGroup = self.__args[2]
	self._scope = self.__args[3]
end

function Command_MaData:execute(args)
	local step = self._stepGroup[1]
	self:processMaData(step, self._recover)
end

function Command_MaData:processMaData(step, isRecover)
	local mapais = self._scope._cardList.mapais
	if step:getPlayType() == PlayType.DISPLAY_BUY_HORSE or step:getPlayType() == PlayType.DISPLAY_PUNISH_HORSE then
		if not isRecover then
			isFristMaAnim = true;
		end
		mapais.maCount = #step:getCards()
		playAniMaStart(self._scope, isRecover)
		
	elseif step:getPlayType() == PlayType.DISPLAY_WIN_HORSE_CARD then
		mapais.win = step:getCards()
		
	elseif step:getPlayType() == PlayType.DISPLAY_LOSE_HORSE_CARD then
		mapais.lose = step:getCards()
		
	elseif step:getPlayType() == PlayType.DISPLAY_HORSE_CARD then
		mapais.all = step:getCards()
		
	elseif step:getPlayType() == PlayType.DISPLAY_HORSE_END then
		if isFristMaAnim then
			isFristMaAnim = false
			return
		end
		
		for i = CardDefines.Chair.Start, CardDefines.Chair.Max do
			local playProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByChair(i)
			if playProcessor then
				playAniMaEnd(playProcessor)
			end
		end
		
		isFristMaAnim = true
		
	end
end


return Command_MaData
