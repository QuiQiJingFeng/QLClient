local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleBottomItem = class("UIBattleHandleBottomItem",UITableViewCell)
local UIManager = app.UIManager


local POINTER_POS = {
    [1] = "art/mahjong/pointer/icon_zs1.png",
    [2] = "art/mahjong/pointer/icon_zs2.png",
    [3] = "art/mahjong/pointer/icon_zs3.png",
    [4] = "art/mahjong/pointer/icon_zs4.png",
}

function UIBattleHandleBottomItem:init()
    self._panelGangGroup = Util:seekNodeByName(self,"panelGangGroup","ccui.Widget")
    self._panelHandCard = Util:seekNodeByName(self,"panelHandCard","ccui.Widget")

    self._gangGroupContainer = self._panelGangGroup:getChildByName("panelContainer")
    self._handCardContainer = self._panelHandCard:getChildByName("panelContainer")

    self._cards = {}
    for i = 1, 4 do
        table.insert(self._cards,Util:seekNodeByName(self._panelGangGroup,"card"..i,"ccui.Layout"))
    end


end

--明杠
function UIBattleHandleBottomItem:processGangGroup()
    self._panelHandCard:setVisible(false)
    self._panelGangGroup:setVisible(true)
    local imgFrom = Util:seekNodeByName(self._panelGangGroup,"imgFrom","ccui.ImageView")
    imgFrom:setLocalZOrder(1)
    imgFrom:setVisible(true)

    for i = 1, 4 do
        local card = self._cards[i]
        card:setVisible(true)
        local imgBack = Util:seekNodeByName(card,"imgBack","ccui.ImageView")
        local imgFace = Util:seekNodeByName(card,"imgFace","ccui.ImageView")
        local cardValue = self._data.value
        imgFace:loadTexture("art/mahjong/faces/"..tostring(cardValue)..".png")
        imgBack:setVisible(false)
    end
end

--暗杠
function UIBattleHandleBottomItem:processAnGangGroup()
    self._panelHandCard:setVisible(false)
    self._panelGangGroup:setVisible(true)

    local imgFrom = Util:seekNodeByName(self._panelGangGroup,"imgFrom","ccui.ImageView")
    imgFrom:setLocalZOrder(1)
    imgFrom:setVisible(true)

    for i = 1, 4 do
        local card = self._cards[i]
        card:setVisible(true)
        local imgBack = Util:seekNodeByName(card,"imgBack","ccui.ImageView")
        local imgFace = Util:seekNodeByName(card,"imgFace","ccui.ImageView")
        local cardValue = self._data.value
        imgFace:loadTexture("art/mahjong/faces/"..tostring(cardValue)..".png")
        imgBack:setVisible(i ~= 4)
    end
end

--碰
function UIBattleHandleBottomItem:processPengGroup()
    self._panelHandCard:setVisible(false)
    self._panelGangGroup:setVisible(true)

    local imgFrom = Util:seekNodeByName(self._panelGangGroup,"imgFrom","ccui.ImageView")
    imgFrom:setLocalZOrder(1)
    imgFrom:setVisible(true)

    for i = 1, 4 do
        local card = self._cards[i]
        card:setVisible(i ~= 4)
        local imgBack = Util:seekNodeByName(card,"imgBack","ccui.ImageView")
        local imgFace = Util:seekNodeByName(card,"imgFace","ccui.ImageView")
        local cardValue = self._data.value
        imgFace:loadTexture("art/mahjong/faces/"..tostring(cardValue)..".png")
        imgBack:setVisible(false)
    end
end

function UIBattleHandleBottomItem:processHandCard()
    self._panelGangGroup:setVisible(false)
    self._panelHandCard:setVisible(true)
    local datas = self:getTableView():getDatas()
    if self:getIdx() == #datas then
        local num = 0
        for i, info in ipairs(datas) do
            if info.type == "handCard" then
                num = num + 1
            end
        end
        if num % 3 == 2 then
            self:setDiffDelt(cc.p(20,0))
        end
    end

    local imgBack = Util:seekNodeByName(self._handCardContainer,"imgBack","ccui.ImageView")
    local imgFace = Util:seekNodeByName(self._handCardContainer,"imgFace","ccui.ImageView")
    
    local cardValue = self._data.value
    imgBack:setVisible(cardValue == 255)
    imgFace:loadTexture("art/mahjong/faces/"..tostring(cardValue)..".png")
end

function UIBattleHandleBottomItem:updateData(data)
    if data.type == "peng" then
        self:processPengGroup()
        return self._gangGroupContainer:getContentSize()
    elseif data.type == "gang" then
        self:processGangGroup()
        return self._gangGroupContainer:getContentSize()
    elseif data.type == "angang" then
        self:processAnGangGroup()
        return self._gangGroupContainer:getContentSize()
    elseif data.type == "handCard" then
        self:processHandCard()
        return self._handCardContainer:getContentSize()
    end
end
 

return UIBattleHandleBottomItem