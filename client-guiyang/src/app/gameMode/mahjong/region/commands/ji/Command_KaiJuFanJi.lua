local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_KaiJuFanJi = class("Command_KaiJuFanJi", Command_PlayerProcessor_Base)
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local UI_ANIM = require("app.manager.UIAnimManager")

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_KaiJuFanJi:ctor( args )
    self.super:ctor(args)
end

function Command_KaiJuFanJi:execute( args )
    local step = self._stepGroup[1]

    --开局翻鸡
    local cardValue = step._cards[1];
    self._processor:getRoomUI():getHuHandler().kaijufanjiCardValue = cardValue
    self:_onKaiJuFanJi(cardValue, self._recover)

end

function Command_KaiJuFanJi:_onKaiJuFanJi(cardValue, recover)
    local seatUI = self._processor:getSeatUI()
	local playerProcessor = seatUI:getPlayerProcessor()
    local cardList = playerProcessor:getCardList()

    -- 创建翻出的鸡牌
	local card = CardFactory:getInstance():createCard2(CardDefines.Chair.Down, CardDefines.CardState.Chupai, cardValue, nil)
    
	local x2px = CC_DESIGN_RESOLUTION.screen.toPercentX
	local y2py = CC_DESIGN_RESOLUTION.screen.toPercentY
	local fanjiImg = cc.Sprite:create()
	fanjiImg:setTexture("mahjong_tile/img_labelJI.png")
	fanjiImg:setPosition(21, 31)
	fanjiImg:setName("corner_chicken")
	card:addChild(fanjiImg)

    -- 播放翻鸡动画（断线重连不播放）
	if recover == false then
		local size = cc.Director:getInstance():getWinSize()
		card:setPosition(size.width / 2 - 16, size.height / 2 - 24)
		local anim = UI_ANIM.UIAnimManager:getInstance():onShow(
			UI_ANIM.UIAnimConfig.new("ui/csb/Effect_kaijufanji.csb", function()
				cardList:addGuiCards(card);
				seatUI:getCardParentNode():addChild(card);
				local moveTo = cc.MoveTo:create(0.1, cc.p(x2px(700),y2py(150)))
				local callback = cc.CallFunc:create(function()
					card:setPosition(x2px(700), y2py(150))
				end)
				local seq = cc.Sequence:create(moveTo, callback)
				card:runAction(seq)
			end))
		-- 更换卡牌，牌面
		local cardTexture = anim:getChild("image_card", "ccui.ImageView")
		cardTexture:loadTexture(CardFactory:getInstance():getSurfaceSkin(cardValue), ccui.TextureResType.plistType)
	else
		cardList:addGuiCards(card);
		seatUI:getCardParentNode():addChild(card);
		card:setPosition(x2px(700), y2py(150))
	end
end

return Command_KaiJuFanJi

