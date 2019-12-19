local Util = game.Util
local CARD_TYPE = {
    HANDCARD = 1,  --手牌
    OUTCARD = 2,   --推到的手牌
    DISCARD = 3,   --打出的手牌
    GROUPCARD = 4, -- 吃碰杠的手牌
    WHITE_SPACE = 5, --空格
}

local GROUP_TYPE = {
    CHI = 1,
    PENG = 2,
    ANGANG = 3,
    MINGGANG = 4,
    PENGGANG = 5,
}

local CONVERT_TO_OBJECT = {
    [CARD_TYPE.HANDCARD] = require("app.factory.HandCard"),
    [CARD_TYPE.OUTCARD] = require("app.factory.HandOutCard"),
    [CARD_TYPE.DISCARD] = require("app.factory.Discard"),
    [CARD_TYPE.GROUPCARD] = require("app.factory.CardGroup")
}
local CardFactory = class("CardFactory")
local _instance = nil
function CardFactory:getInstance()
    if not _instance then
        _instance = CardFactory.new()
    end

    return _instance
end

function CardFactory:getConvertObjList()
    return CONVERT_TO_OBJECT
end

function CardFactory:getCardType()
    return CARD_TYPE
end

function CardFactory:getGroupType()
    return GROUP_TYPE
end

function CardFactory:ctor()
    local csbPath = "csb/mengya/battle/mahjong/UICardFactory.csb"
    self._cacheNode = game.Util:loadCSBNode(csbPath)
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self._cacheNode,-1000)
    self._cacheNode:setVisible(false)


    local layoutSpace = ccui.Layout:create()
    layoutSpace:setContentSize(cc.size(10,10))
    layoutSpace:setVisible(false)
    scene:addChild(layoutSpace)


    self._map = {}
    local directions = {"Left","Bottom","Right","Top"}
    for i, direction in ipairs(directions) do
        self._map[direction] = {}
        local name = "list" .. direction
        local node = Util:seekNodeByName(self._cacheNode,name,"ccui.ListView")
        self._map[direction][CARD_TYPE.HANDCARD] = Util:seekNodeByName(node,"panelHandCard","ccui.Layout")
        self._map[direction][CARD_TYPE.OUTCARD] = Util:seekNodeByName(node,"panelOutCard","ccui.Layout")
        self._map[direction][CARD_TYPE.DISCARD] = Util:seekNodeByName(node,"panelDiscard","ccui.Layout")
        self._map[direction][CARD_TYPE.GROUPCARD] = Util:seekNodeByName(node,"panelGroup","ccui.Layout")
        self._map[direction][CARD_TYPE.WHITE_SPACE] = layoutSpace
    end
end

function CardFactory:createCardWithOptions(direction,type,data)
    local node = self._map[direction][type]
    local obj
    if CARD_TYPE.WHITE_SPACE ~= type then
        local cls = CONVERT_TO_OBJECT[type]
        obj = cls:extend(node:clone())
        obj:setData(data)
    else
        obj = node:clone()
    end
    return obj
end

return CardFactory