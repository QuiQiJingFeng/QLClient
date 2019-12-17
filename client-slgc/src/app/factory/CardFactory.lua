local Util = game.Util
local CONVERT_TO_OBJECT = {
    ["HANDCARD"] = require("app.factory.HandCard"),
    ["OUTCARD"] = require("app.factory.HandOutCard"),
    ["DISCARD"] = require("app.factory.Discard"),
    ["GROUPCARD"] = require("app.factory.CardGroup")
}
local CardFactory = class("CardFactory")

local CARD_TYPE = {
    HAND_CARD = 1,
    HAND_OUTCARD = 2,
    DISCARD = 3,
    CARD_GROUP_PENG = 4,
    CARD_GROUP_ANGANG = 5,
    CARD_GROUP_MINGGANG = 6,
}

local PLACE_DIRECTION = {
    LEFT = 1,
    BOTTOM = 2,
    RIGHT = 3,
    TOP = 4,
}

local _instance = nil
function CardFactory:getInstance()
    if not _instance then
        _instance = CardFactory.new()
    end

    return _instance
end

function CardFactory:ctor()
    local csbPath = "csb/mengya/battle/mahjong/UICardFactory.csb"
    self._cacheNode = game.Util:loadCSBNode(csbPath)
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self._cacheNode,-1000)
    self._cacheNode:setVisible(false)

    self._map = {}
    local directions = {"Left","Bottom","Right","Top"}
    for i, direction in ipairs(directions) do
        self._map[direction] = {}
        local name = "list" .. direction
        local node = Util:seekNodeByName(self._cacheNode,name,"ccui.ListView")
        self._map[direction]["HANDCARD"] = Util:seekNodeByName(node,"panelHandCard","ccui.Layout")
        self._map[direction]["OUTCARD"] = Util:seekNodeByName(node,"panelOutCard","ccui.Layout")
        self._map[direction]["DISCARD"] = Util:seekNodeByName(node,"panelDiscard","ccui.Layout")
        self._map[direction]["GROUPCARD"] = Util:seekNodeByName(node,"panelGroup","ccui.Layout")
    end

end

function CardFactory:createCardWithOptions(direction,type,data)
    local node = self._map[direction][type]
    local cls = CONVERT_TO_OBJECT[type]
    local obj = cls:extend(node:clone())
    obj:setData(data)
    return obj
end

return CardFactory