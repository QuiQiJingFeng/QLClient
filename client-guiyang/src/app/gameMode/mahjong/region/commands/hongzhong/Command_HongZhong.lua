local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_HongZhong = class("Command_HongZhong", Command_PlayerProcessor_Base)
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local UI_ANIM = require("app.manager.UIAnimManager")

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_HongZhong:ctor( args )
    self.super:ctor(args)
end

function Command_HongZhong:execute( args )
    local step = self._stepGroup[1]
   
	-- self._processor:_onHongZhongHua(step._cards[1], self._revocer)
    self:_onHongZhongHua(step._cards[1])
end

function Command_HongZhong:_onHongZhongHua(cardValue)
    local cardList = self._processor:getCardList()
    if cardList.lastDrewCard ~= nil then
        cardList:removeHandCard(cardList.lastDrewCard)
        CardFactory:getInstance():releaseCard(cardList.lastDrewCard)
		cardList.lastDrewCard = nil;
    end

    self:_onDiscardHuaCard(cardValue)
end

function Command_HongZhong:_onDiscardHuaCard(cardValue)
    local seatUI = self._processor:getSeatUI()
	local playerProcessor = seatUI:getPlayerProcessor()
	local card = nil
	if config.getIs3D() then
		card = CardFactory:getInstance():createCard3d(seatUI:getChairType(), CardDefines.CardState.HuaPai, 1, cardValue, nil, seatUI:getCardLayout().huaLayout.scale)
	else
		card = CardFactory:getInstance():createCard2(seatUI:getChairType(), CardDefines.CardState.Chupai, cardValue, nil)
	end
    playerProcessor:getCardList():addHuaCard(card);
    seatUI:getCardParentNode():addChild(card);
	local place = seatUI:_ManageHuaPositions(playerProcessor:getCardList(), seatUI._cardLayout, false, {card})[card]
	if self._recover == false then
		card:setPosition(seatUI:getCardLayout().discardedAniStart)
		card:setVisible(false)
		local cardBorns = {
			[CardDefines.Chair.Down] = "ui/csb/Effect_fhz_down.csb",
			[CardDefines.Chair.Right] = "ui/csb/Effect_fhz_right.csb",
			[CardDefines.Chair.Top] = "ui/csb/Effect_fhz_up.csb",
			[CardDefines.Chair.Left] = "ui/csb/Effect_fhz_left.csb",
		}
		local anim = nil
		anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(cardBorns[seatUI:getChairType()], function()
			card:setVisible(true)
			local move = cc.MoveTo:create(0.3, cc.p(place.pos.x, place.pos.y))
			local callback = cc.CallFunc:create(function()
				if config.getIs3D() then
					seatUI:_ManageHuPositions(cardList, seatUI:getCardLayout(), true)
				else
					local place = seatUI:_ManageHuPositions(cardList, seatUI:getCardLayout(), false, {card})[card]
					card:setScale(0.8)
					card:setPosition(cc.p(place.pos.x, place.pos.y))
					card:setZOrder(place.zOrder)
				end
			end)
			local seq = cc.Sequence:create(move, callback)
			card:runAction(seq)	
		end))
		anim:toPos(card)
		-- 更换卡牌，牌面
		local cardTexture = anim:getChild("image_card", "ccui.ImageView")
		cardTexture:loadTexture(CardFactory:getInstance():getSurfaceSkin(cardValue), ccui.TextureResType.plistType)
	else
		if config.getIs3D() then
			seatUI:_ManageHuPositions(cardList, seatUI:getCardLayout(), true)
		else
			local place = seatUI:_ManageHuPositions(cardList, seatUI:getCardLayout(), false, {card})[card]
			card:setScale(0.8)
			card:setPosition(cc.p(place.pos.x, place.pos.y))
			card:setZOrder(place.zOrder)
		end
	end
end

return Command_HongZhong