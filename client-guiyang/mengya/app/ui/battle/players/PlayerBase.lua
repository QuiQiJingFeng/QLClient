local PlayerBase = class("PlayerBase")

local DIRECTION_CONFIG = {
    ["BOTTOM"] = app.UIBattleDiscardBottomItem,
    ["LEFT"] = app.UIBattleDiscardLeftItem,
    ["RIGHT"] = app.UIBattleDiscardRightItem,
    ["TOP"] = app.UIBattleDiscardTopItem,
}

function PlayerBase:ctor(uiPlayer,handCardList)
    self._uiPlayer = uiPlayer
    self._handCardList = handCardList
    self:init()
end

function PlayerBase:init()
    --声音标志
    self._spAudio = app.Util:seekNodeByName(self._uiPlayer,"spAudio","cc.Sprite")
    --静态表情
    self._spEmoj = app.Util:seekNodeByName(self._uiPlayer,"spEmoj","cc.Sprite")
    --准备标志
    self._spPrepare = app.Util:seekNodeByName(self._uiPlayer,"spPrepare","cc.Sprite")

    self._panelChat = app.Util:seekNodeByName(self._uiPlayer,"panelChat","ccui.Layout")

    --玩家信息相关
    self._playerInfo = app.Util:seekNodeByName(self._uiPlayer,"playerInfo","cc.Node")

    app.Util:hide(self._spAudio,self._spEmoj,self._spPrepare,self._panelChat)
end

function PlayerBase:getUIPlayer()
    return self._uiPlayer
end

function PlayerBase:getPlayerHandCardList()
    return self._handCardList
end

function PlayerBase:setPlayerDiscardList(discardList,direction,perNum)
    local item = DIRECTION_CONFIG[direction]
    self._discardList = app.UITableViewEx.extend(discardList,item)
    
    self._discardList:perUnitNums(perNum)
end

function PlayerBase:getPlayerDiscardList()
    return self._discardList
end

function PlayerBase:setVisible(boolean)
    self._uiPlayer:setVisible(boolean)
    self._handCardList:setVisible(boolean)
    if self._discardList then
        self._discardList:setVisible(boolean)
    end
end

function PlayerBase:setHandCardDatas(datas)
    self._handCardList:updateDatas(datas)
end

function PlayerBase:setDisCardDatas(datas)
    if self._discardList then
        self._discardList:updateDatas(datas)
    end
end

return PlayerBase