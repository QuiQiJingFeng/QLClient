local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_Men = class("Command_Men", Command_PlayerProcessor_Base)

local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_Men:ctor(args)
	self.super:ctor(args)
end

function Command_Men:execute(args)
	local step = self._stepGroup[1]
	
	local time = 0
	if self._recover == false then
		time = self._processor:getRoomUI():playAnim(step:getPlayType())
	end
	
	self:_onMenHu(step._cards[1], step)
end

function Command_Men:_onMenHu(cardValue, step)
	local seatUI = self._processor:getSeatUI()
	local playerProcessor = seatUI:getPlayerProcessor()
	local cardList = playerProcessor:getCardList()
	
	local isZiMo = step._sourceRoleId == step._roleId and true or false
	
	-- 清除操作按钮
	seatUI:clearOpButtons();
	
	-- 清除闷胡玩家的操作牌
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	if isZiMo and roleId == step._roleId then
		seatUI:recoverOperatingCard()
	end
	
	-- 自摸闷胡删除自己的手牌
	if cardList.lastDrewCard ~= nil then
		cardList:removeHandCard(cardList.lastDrewCard);
		CardFactory:getInstance():releaseCard(cardList.lastDrewCard);
		cardList.lastDrewCard = nil;
	end
	
	self:_enableMutilHu(cardValue, isZiMo);
end

-- 闷胡的牌放置玩家右边
function Command_Men:_enableMutilHu(cardValue, isZiMo)
	local seatUI = self._processor:getSeatUI()
	local playerProcessor = seatUI:getPlayerProcessor()
	local cardList = playerProcessor:getCardList()
	
	-- 创建胡的牌
	local card = nil
	
    card = seatUI:createCard(CardDefines.CardState.HuPai, isZiMo and CardDefines.BattleConst.INVALID_CARD_VALUE or cardValue, nil, seatUI:getCardLayout().huLayout.scale, #cardList.huCards + 1)

	cardList:addHuCards(card);
	
	-- 设置胡牌的位置
	if config.getIs3D() then
		seatUI:_ManageHuPositions(cardList, seatUI:getCardLayout(), true)
	else
		local place = seatUI:_ManageHuPositions(cardList, seatUI:getCardLayout(), false, {card}) [card]
		card:setScale(0.8)
		card:setPosition(cc.p(place.pos.x, place.pos.y))
		card:setZOrder(place.zOrder)
	end
end

return Command_Men 