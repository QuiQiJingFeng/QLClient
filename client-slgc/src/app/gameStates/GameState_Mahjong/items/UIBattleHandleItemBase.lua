local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIBattleHandleItemBase = class("UIBattleHandleItemBase")
local UIManager = game.UIManager

function UIBattleHandleItemBase:init()
    self._panelCardGroup = Util:getChildByNames(self,"pengGangGroup","panelCardGroup")
    self._btnDiscard = Util:getChildByNames(self,"handDiscard","btnDiscard")
    self._btnHandCard = Util:getChildByNames(self,"handCard","btnHandCard")
end

function UIBattleHandleItemBase:updateData(data)
    if data.type == "peng" then
        Util:hide(self._btnDiscard,self._btnHandCard)
        Util:show(self._panelCardGroup)
        self._panelCardGroup:setData(data)
        return self._panelCardGroup:getContentSize()
    elseif data.type == "gang" then
        Util:hide(self._btnDiscard,self._btnHandCard)
        Util:show(self._panelCardGroup)
        self._panelCardGroup:setData(data)
        return self._panelCardGroup:getContentSize()
    elseif data.type == "angang" then
        Util:hide(self._btnDiscard,self._btnHandCard)
        Util:show(self._panelCardGroup)
        self._panelCardGroup:setData(data)
        return self._panelCardGroup:getContentSize()
    elseif data.type == "handCard" then
        if data.output then
            Util:hide(self._btnHandCard,self._panelCardGroup)
            Util:show(self._btnDiscard)
            self._btnDiscard:setData(data)
            local scale = self._btnDiscard:getParent():getScale()
            local size = self._btnDiscard:getContentSize()
            return cc.size(size.width*scale,size.height*scale)
        else
            Util:hide(self._panelCardGroup,self._btnDiscard)
            Util:show(self._btnHandCard)
            self._btnHandCard:setData(data)
            return self._btnHandCard:getContentSize()
        end
    end
end

return UIBattleHandleItemBase


--[[
    example:
    local datas = {
        {type = "gang",cardValue = 24,from = 1},
        {type = "angang",cardValue = 22,from = 2},
        {type = "peng",cardValue = 35,from = 3},
        {type = "handCard",cardValue = 2,output = true},
        {type = "handCard",cardValue = 3,output = true},
        {type = "handCard",cardValue = 4},
        {type = "handCard",cardValue = 9},
        {type = "handCard",cardValue = 255,isLastCard = true},
    }
]]