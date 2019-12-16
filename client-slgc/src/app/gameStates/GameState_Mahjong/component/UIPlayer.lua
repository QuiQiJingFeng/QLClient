local Util = game.Util
local UIPlayer = class("UIPlayer")

function UIPlayer.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIPlayer)
    self:init()
    return self
end

function UIPlayer:init()
    --玩家信息
    --是否离线
    self._txtBmfOutLine = Util:seekNodeByName(self,"txtBmfOutLine","ccui.TextBMFont")
    self:setOutLineMarkVisible(false)
    --听牌标志
    self._spTing = Util:seekNodeByName(self,"spTing","cc.Sprite")
    self:setTingMarkVisible(false)
    --庄家标志
    self._spZhuang = Util:seekNodeByName(self,"spZhuang","cc.Sprite")
    self:setZhuangMarkVisible(false)
    --托管标志
    self._spTrustee = Util:seekNodeByName(self,"spTrustee","cc.Sprite")
    self:setTrusteeMarkVisible(false)

    --当局分数
    self._txtBmfTempScore = Util:seekNodeByName(self,"txtBmfTempScore","ccui.TextBMFont")
    self:updateTempScore(0)

    --总分数
    self._txtTotalScore = Util:seekNodeByName(self,"txtTotalScore","ccui.Text")
    self:updateTotalScore(0)

    --用户名
    self._txtRoleName = Util:seekNodeByName(self,"txtRoleName","ccui.Text")
    self:setRoleName("XXX")

    --特效背景
    self._spEffect = Util:seekNodeByName(self,"spEffect","cc.Sprite")

    --头像框
    self._spBorder = Util:seekNodeByName(self,"spBorder","cc.Sprite")
    --用户头像
    self._imgRoleIcon = Util:seekNodeByName(self,"imgRoleIcon","ccui.ImageView")

    --声音标志
    self._spAudio = Util:seekNodeByName(self,"spAudio","cc.Sprite")
    self._spLine1 = Util:seekNodeByName(self,"spLine1","cc.Sprite")
    self._spLine2 = Util:seekNodeByName(self,"spLine2","cc.Sprite")
    self._spLine3 = Util:seekNodeByName(self,"spLine3","cc.Sprite")
    
    --静态表情
    self._spEmoj = Util:seekNodeByName(self,"spEmoj","cc.Sprite")
    --准备标志
    self._spPrepare = Util:seekNodeByName(self,"spPrepare","cc.Sprite")
    --聊天
    self._panelChat = Util:seekNodeByName(self,"panelChat","ccui.Layout")

    --玩家信息相关
    Util:hide(self._spEmoj,self._panelChat)
    self:setPrepareVisible(false)
    self:setAudioMarkVisible(false)
end

--设置当前需要打牌的玩家的特效
function UIPlayer:setPlayEffectVisible(visible)
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
function UIPlayer:setRoleName(name)
    self._txtRoleName:setString(name)
end

--更新总分数
function UIPlayer:updateTotalScore(score)
    self._txtTotalScore:setString(tostring(score))
end

--更新当局分数
function UIPlayer:updateTempScore(score)
    self._txtBmfTempScore:setString(tostring(score))
end

--设置托管标志是否显示
function UIPlayer:setTrusteeMarkVisible(visible)
    self._spTrustee:setVisible(visible)
end

--设置庄家标志是否显示
function UIPlayer:setZhuangMarkVisible(visible)
    self._spZhuang:setVisible(visible)
end

--设置听牌标志是否显示
function UIPlayer:setTingMarkVisible(visible)
    self._spTing:setVisible(visible)
end

--设置离线标志是否显示
function UIPlayer:setOutLineMarkVisible(visible)
    self._txtBmfOutLine:setVisible(visible)
end

--设置准备的标志的隐藏和显示
function UIPlayer:setPrepareVisible(visible)
    self._spPrepare:setVisible(visible)
end

--设置播放语音的标志隐藏和显示
function UIPlayer:setAudioMarkVisible(visible)
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

function UIPlayer:dispose()
end

return UIPlayer