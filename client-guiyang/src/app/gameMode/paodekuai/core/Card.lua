local CardDefines_Paodekuai = require "app.gameMode.paodekuai.core.CardDefines_Paodekuai"

local Card = class("Card", function () return ccui.ImageView:create("poker/surface/z_bg.png") end)
Card.WIDTH = 96
Card.HEIGHT = 128
Card.MARGIN = Card.WIDTH * 0.35

function Card:ctor(value)
    -- self:setOpacity(170)
    self._isSelected = false
    self:reset(value)
    -- self:_registeCallback()
    self._index = -1
end

function Card:reset(value)
    self._value = value
    self:_check(value)
    self:_reloadTexture()
    self:unselect()
end

function Card:_registeCallback()
    bindEventCallBack(self, handler(self, self._onClick), ccui.TouchEventType.ended)
end

function Card:_check(value)
    local info = CardDefines_Paodekuai.Map[value]
    if Macro.assertFalse(info, "undefined value " .. value) then
        self._info = info
    end
end

function Card:_reloadTexture()
    local resPath = self._info.resPath
    self:loadTexture(resPath)
    -- printf("size = ", dump(self:getContentSize()))
end

-- function Card:_onClick(sender)
--     self._isSelected = not self._isSelected
--     local y = self._isSelected == true and 30 or 0
--     self:setPositionY(y)
-- end

function Card:unselect()
    self._isSelected = false
    local y = Card.HEIGHT * (self._scale or 1) * 0.5
    self:setPositionY(y)
end

function Card:select()
    self._isSelected = true
    local y = (self._scale or 1) * (Card.HEIGHT + 30) * 0.5
    self:setPositionY(y)
end

function Card:getName()
    return self._info.name
end

function Card:isSelected()
    return self._isSelected
end

function Card:setIndex(index)
    self._index = index
    self:setLocalZOrder(index)
end

function Card:getSortValue()
    return self._info.sortValue
end

function Card:getValue()
    return self._value
end

function Card:getIndex()
    return self._index
end

function Card:setSize(scale)
    self._scale = scale
    self:setScale(scale)
end

--[[
    为了适应麻将的结算排序，用下这个方式， 之后会修改 CardsInfo  
]]
function Card:getContentSize()
    local scale = self._scale or 1
    local size = cc.size(Card.MARGIN * scale, Card.HEIGHT * scale)
    return size
end

function Card:dispose()
end


return Card