local Util = app.Util
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
    --玩家信息
    --是否离线
    self._txtBmfOutLine = Util:seekNodeByName(self._uiPlayer,"txtBmfOutLine","ccui.TextBMFont")
    self:setOutLineMarkVisible(false)
    --听牌标志
    self._spTing = Util:seekNodeByName(self._uiPlayer,"spTing","cc.Sprite")
    self:setTingMarkVisible(false)
    --庄家标志
    self._spZhuang = Util:seekNodeByName(self._uiPlayer,"spZhuang","cc.Sprite")
    self:setZhuangMarkVisible(false)
    --托管标志
    self._spTrustee = Util:seekNodeByName(self._uiPlayer,"spTrustee","cc.Sprite")
    self:setTrusteeMarkVisible(false)

    --当局分数
    self._txtBmfTempScore = Util:seekNodeByName(self._uiPlayer,"txtBmfTempScore","ccui.TextBMFont")
    self:updateTempScore(0)

    --总分数
    self._txtTotalScore = Util:seekNodeByName(self._uiPlayer,"txtTotalScore","ccui.Text")
    self:updateTotalScore(0)

    --用户名
    self._txtRoleName = Util:seekNodeByName(self._uiPlayer,"txtRoleName","ccui.Text")
    self:setRoleName("XXX")

    --特效背景
    self._spEffect = Util:seekNodeByName(self._uiPlayer,"spEffect","cc.Sprite")

    --头像框
    self._spBorder = Util:seekNodeByName(self._uiPlayer,"spBorder","cc.Sprite")
    --用户头像
    self._imgRoleIcon = Util:seekNodeByName(self._uiPlayer,"imgRoleIcon","ccui.ImageView")

    --声音标志
    self._spAudio = Util:seekNodeByName(self._uiPlayer,"spAudio","cc.Sprite")
    self._spLine1 = Util:seekNodeByName(self._uiPlayer,"spLine1","cc.Sprite")
    self._spLine2 = Util:seekNodeByName(self._uiPlayer,"spLine2","cc.Sprite")
    self._spLine3 = Util:seekNodeByName(self._uiPlayer,"spLine3","cc.Sprite")
    
    --静态表情
    self._spEmoj = app.Util:seekNodeByName(self._uiPlayer,"spEmoj","cc.Sprite")
    --准备标志
    self._spPrepare = app.Util:seekNodeByName(self._uiPlayer,"spPrepare","cc.Sprite")
    --聊天
    self._panelChat = app.Util:seekNodeByName(self._uiPlayer,"panelChat","ccui.Layout")

    --玩家信息相关
    app.Util:hide(self._spEmoj,self._panelChat)
    self:setPrepareVisible(false)
    self:setAudioMarkVisible(false)
end

--设置当前需要打牌的玩家的特效
function PlayerBase:setPlayEffectVisible(visible)
    self._spEffect:stopAllActions()
    self._spEffect:setVisible(visible)
    if not visible then
        return
    end
    
    local action = cc.RotateBy:create(10, 360)
    local seq = cc.RepeatForever:create(action)
    self._spEffect:runAction(seq)
end

--设置用户名称
function PlayerBase:setRoleName(name)
    self._txtRoleName:setString(name)
end

--更新总分数
function PlayerBase:updateTotalScore(score)
    self._txtTotalScore:setString(tostring(score))
end

--更新当局分数
function PlayerBase:updateTempScore(score)
    self._txtBmfTempScore:setString(tostring(score))
end

--设置托管标志是否显示
function PlayerBase:setTrusteeMarkVisible(visible)
    self._spTrustee:setVisible(visible)
end

--设置庄家标志是否显示
function PlayerBase:setZhuangMarkVisible(visible)
    self._spZhuang:setVisible(visible)
end

--设置听牌标志是否显示
function PlayerBase:setTingMarkVisible(visible)
    self._spTing:setVisible(visible)
end

--设置离线标志是否显示
function PlayerBase:setOutLineMarkVisible(visible)
    self._txtBmfOutLine:setVisible(visible)
end

--设置准备的标志的隐藏和显示
function PlayerBase:setPrepareVisible(visible)
    self._spPrepare:setVisible(visible)
end

--设置播放语音的标志隐藏和显示
function PlayerBase:setAudioMarkVisible(visible)
    if not visible then
        self._spAudio:stopAllActions()
        self._spAudio:setVisible(false)
        return
    end
    self._spAudio:setVisible(true)
    Util:hide(self._spLine1,self._spLine2,self._spLine3)
    local delayTime = 0.4
    local action1 = cc.CallFunc:create(function() self._spLine1:setVisible(true) end)
    local action2 = cc.DelayTime:create(delayTime)
    local action3 = cc.CallFunc:create(function() self._spLine2:setVisible(true) end)
    local action4 = cc.DelayTime:create(delayTime)
    local action5 = cc.CallFunc:create(function() self._spLine3:setVisible(true) end)
    local action6 = cc.DelayTime:create(delayTime)
    local action7 = cc.CallFunc:create(function() 
        Util:hide(self._spLine1,self._spLine2,self._spLine3)
    end)
    local action8 = cc.Sequence:create(action1,action2,action3,action4,action5,action6,action7)
    local action9 = cc.RepeatForever:create(action8)
    self._spAudio:runAction(action9)
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