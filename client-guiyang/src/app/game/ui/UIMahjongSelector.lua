local csbPath = "ui/csb/UIMahjongSelector.csb"
local super = require("app.game.ui.UIBase")

local UIMahjongSelector = class("UIMahjongSelector", super, function () return kod.LoadCSBNode(csbPath) end)
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

function UIMahjongSelector:ctor()
    self._cards = {}
	self.root = seekNodeByName(self, "MahjongSelector", "ccui.Layer")
end

function UIMahjongSelector:needBlackMask()
	return true
end

function UIMahjongSelector:onShow(...)
    local args = {...}

    if #self._cards > 0 then
        self:releaseAllCards()
    end

    local stepGroup = args[1]
    local callback = args[2]
    local cardCounts = 0
    for i = 1, #stepGroup do
        cardCounts = cardCounts + #stepGroup[i]._cards
    end

    local GROUP_SPACE = 16
    local BG_WIDTH = 63
    local size = cc.Director:getInstance():getWinSize()
    local offset = CC_DESIGN_RESOLUTION.screen.offsetPoint()
    local startX = size.width / 2 - ((#stepGroup - 1) * GROUP_SPACE + cardCounts * BG_WIDTH) / 2 + BG_WIDTH / 2 + offset.x
    local startY = size.height / 2 - BG_WIDTH + offset.y
    for key, val in pairs( stepGroup ) do
        local cardNumbers = {}
        for k, v in pairs( val._cards ) do
            table.insert(cardNumbers, v)
        end
        table.sort(cardNumbers, function(a,b) return a<b end)
        for _, cardNumber in pairs( cardNumbers ) do
            local card = CardFactory:getInstance():CreateCard({
                chair = CardDefines.Chair.Down, 
                state = CardDefines.CardState.GangPai, 
                cardValue = cardNumber,
                sizeScale = 1.5,
                fromRull = true,
            });
            self:addChild(card)
            table.insert(self._cards, card)
            card:setPosition(cc.p(startX, startY))
            card:enable(true)
            startX = startX + BG_WIDTH
            bindEventCallBack(card._realBtn, function()
                if callback then
                    callback(val)
                end
                self:releaseAllCards()
                UIManager:getInstance():destroy("UIMahjongSelector")
            end, ccui.TouchEventType.ended);
        end

        startX = startX + GROUP_SPACE
    end
end

-- TODO:现在只有主动调用的销毁，没有被动关闭的销毁，处理一下
function UIMahjongSelector:destroy()
    self:releaseAllCards()
end

function UIMahjongSelector:releaseAllCards()
    while #self._cards > 0 do
        self._cards[1]:disable()
        CardFactory:getInstance():releaseCard(self._cards[1])
        table.remove(self._cards, 1)
    end
end

return UIMahjongSelector