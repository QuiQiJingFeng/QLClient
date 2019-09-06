local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local CommandBase = require("app.manager.CommandBase")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Command_showMasterCard = class("Command_MaData", CommandBase)

local GuiPai_X = CC_DESIGN_RESOLUTION.screen.toLeft(230)
local GuiPai_Y = CC_DESIGN_RESOLUTION.screen.toTop(510)
local GuiPai_Zorder = 1000

function Command_showMasterCard:ctor(args)
	self.super:ctor(args)
	self._recover = self.__args[1]
	self._stepGroup = self.__args[2]
	self._scope = self.__args[3]
end

function Command_showMasterCard:execute(args)
	local step = self._stepGroup[1]
	
	self:setCornerCard(CardDefines.CornerType.GuiPai, step:getCards(), self._recover)
	
end

function Command_showMasterCard:setCornerCard(type, cardValues, isRecover)
	local _chair = self._scope._seatUI:getChairType()
	self._scope._cardList:setCornerCardValues(type, cardValues)
	self._scope._cardList:reSetCornerType(_chair)
	--设置鬼牌后排序
	self._scope._seatUI:ManageCardsPositions(self._scope._cardList, self._scope._seatUI:getCardLayout(), true)
	if _chair == CardDefines.Chair.Down and type == CardDefines.CornerType.GuiPai then
		self:setGuiPaiUI(cardValues);
	end
	
end

function Command_showMasterCard:setGuiPaiUI(cardValues)
	local roomUI = self._scope:getRoomUI()
	roomUI:clearGuiPai()
	Macro.assetTrue(#cardValues == 0)
	local cards = {}
	local is3D = config.getIs3D()
	local scale = 0.75
	if is3D then
		scale = 0.45
	end

	local _state = CardDefines.CardState.Chupai
	local _coner = CardDefines.CornerType.GuiPai
	for idx, cardValue in ipairs(cardValues) do
		local card = self._scope._seatUI:createCard(_state, cardValue, _coner, scale, idx)
		table.insert(cards, card)
	end
	local width, height = cards[1]:getSize()
	local totalWidth = #cards * width
	local startX = GuiPai_X - totalWidth/2 + width/2
	if is3D then
		startX = startX + width*2
	end
	
	for _, card in ipairs(cards) do
		card:setPosition(startX, GuiPai_Y)
		card.zOrder = GuiPai_Zorder
		startX = startX + width
	end
	roomUI.guiCards = cards
end

return Command_showMasterCard 