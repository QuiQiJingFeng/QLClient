local csbPath = "ui/csb/Paodekuai/PlayerIcon.csb"
local super = require "app.gameMode.base.ui.UIPlayer"
local Constants = require "app.gameMode.zhengshangyou.core.Constants_ZhengShangYou"
local CardFactory = require "app.gameMode.zhengshangyou.core.CardFactory_ZhengShangYou"
local CD_TIME = 15
local UIPlayer_ZhengShangYou = class("UIPlayer_ZhengShangYou", super, function() return kod.LoadCSBNode(csbPath) end)
---@overwrite
function UIPlayer_ZhengShangYou:ctor(cPos, playerInfo, uiContainer)
    -- Logger.debug("UIPlayer_ZhengShangYou ctor " .. playerInfo:getShortName())
    super.ctor(self, cPos, playerInfo, uiContainer)
    self._discardedCards = {}
    self._score = 0
    self._cardRemainNum = 0
    self._countDown = CD_TIME
    self:init()
    self:updatePlayerInfo(playerInfo)
end

function UIPlayer_ZhengShangYou:onAddInParent()
    super.onAddInParent(self)
    -- TODO 调整UI中的语音、聊天、特殊UI的位置
    self:_resetPositionAndAnchorPoint(self._cPos)
    -- self:onDiscard({})
    -- testcode
    -- if self._cPos == 2 or self._cPos == 3 then
    --     self:onDiscard({1,2,3,4,5,6,7,8,9,10})
    -- else
    -- self:onDiscard({1})
    -- self:onDiscard({21,22,23,24})
    -- self:onDiscard({1,2,3,4,5,6,7,8,10,11,12,13,1,2,3,4,5,6,7})
    -- end
end


---@overwrite
function UIPlayer_ZhengShangYou:init()
    super.init(self)
    self._root = seekNodeByName(self, "Panel_Player", "ccui.Layout")
    self._imageIcon = seekNodeByName(self, "Image_Icon", "ccui.ImageView")
    self._headFrame = seekNodeByName(self, "headFrame", "cc.Node")
    self._textName = seekNodeByName(self, "Text_Name", "ccui.Text")
    self._imageOffline = seekNodeByName(self, "Image_OffLine", "ccui.ImageView")
    self._imageBanker = seekNodeByName(self, "Image_Zhuang", "ccui.ImageView")
    self._imageBanker:setVisible(false)
    self._imagePass = seekNodeByName(self, "Image_Pass", "ccui.ImageView")
    self._imagePass:setVisible(false)

    -- Talk
    self._panelTalk = seekNodeByName(self, "Panel_Talk", "ccui.Layout")
    -- Voice
    self._panelVoice = seekNodeByName(self, "Panel_Voice", "cc.Sprite")

    -- UIPlayer_ZhengShangYou extends widget
    self._nodeClock = seekNodeByName(self, "Node_Clock", "cc.Node")
    self._imageReady = seekNodeByName(self, "Image_Ready", "ccui.ImageView")
    self._nodeCardRemainNum = seekNodeByName(self, "Node_Remain_Card_Num", "cc.Node")
    self._nodeClock:setVisible(false)
    self._imageReady:setVisible(true)
    self._nodeCardRemainNum:setVisible(false)

    -- 计时器
    self._textClock = seekNodeByName(self._nodeClock, "BitmapFontLabel", "ccui.TextBMFont")
    self._textCardRemainNum = seekNodeByName(self._nodeCardRemainNum, "BitmapFontLabel", "ccui.TextBMFont")
    self._textScore = seekNodeByName(self, "Text_Score", "ccui.Text")

    -- 出牌
    self._discardContainer = seekNodeByName(self, "Panel_Discard_Container", "ccui.Layout")

    self:_registerCallback()
    self:_initElement()
end

function UIPlayer_ZhengShangYou:_initElement()
    local UIElemChat = require("app.gameMode.mahjong.ui.UIElemChat")
    self._elemChat = UIElemChat.new()
    local messageBorder = seekNodeByName(self._panelTalk, "Image_Talk_BG", "ccui.ImageView")
    local labelMessage = seekNodeByName(self._panelTalk, "Text_Talk", "ccui.Text")
    local emoji = seekNodeByName(self._panelTalk, "Image_Emoji", "cc.Sprite")
    local voiceWave1 = seekNodeByName(self._panelVoice, "1", "cc.Sprite")
    local voiceWave2 = seekNodeByName(self._panelVoice, "2", "cc.Sprite")
    local voiceWave3 = seekNodeByName(self._panelVoice, "3", "cc.Sprite")
    local nodeRTVoice = seekNodeByName(self, "Node_RTVoice", "cc.Node")
    self._elemChat:initialize(self, "animation0", self._panelTalk, messageBorder, labelMessage, emoji, self._panelVoice, voiceWave1, voiceWave2, voiceWave3, nodeRTVoice)
end

function UIPlayer_ZhengShangYou:_registerCallback()
    bindEventCallBack(self._root, handler(self, self._onSelfClick), ccui.TouchEventType.ended)
end

function UIPlayer_ZhengShangYou:setEnable(value)
    self:setVisible(value or false)
end

-- call by uigamescene
---@overwrite
function UIPlayer_ZhengShangYou:updatePlayerInfo(info)
    super.updatePlayerInfo(self, info)

    self._textName:setString(info:getShortName() or '')
    game.util.PlayerHeadIconUtil.setIcon(self._imageIcon, info:getIconURL())

    -- 设置头像框
    if info.headFrame ~= nil then
        game.util.PlayerHeadIconUtil.setIconFrame(self._headFrame,PropReader.getIconById(info.headFrame),0.6)
    end

    self._imageOffline:setVisible(not info:isOnline())
    self:setScore(info.totalPoint)
end

function UIPlayer_ZhengShangYou:setScore(score)
    self._score = score or 0
    self._textScore:setString(score)
end

function UIPlayer_ZhengShangYou:setCardRemainNum(num)
    self._cardRemainNum = num or 0
    self._textCardRemainNum:setString(self._cardRemainNum)
end

function UIPlayer_ZhengShangYou:getCardRemainNum()
    return self._cardRemainNum
end

function UIPlayer_ZhengShangYou:setCounDownEnable(value)
    -- Logger.debug("==== SET COUNT DOWN")
    -- Logger.debug("roleId = " .. self:getPlayerInfo().roleId .. ", VALUE = " .. tostring(value))
    self._countDown = CD_TIME
    self._textClock:setString(self._countDown)

    if value then
        self:_startTask()
    else
        self:_cancelTask()
    end
    self._nodeClock:setVisible(value or false)
end

local CARD_SCALE = 1
local CARD_WIDTH = 96 * CARD_SCALE
local CARD_HEIGHT = 128 * CARD_SCALE 
local CARD_MARGIN = CARD_WIDTH * 0.3 * CARD_SCALE
local DIS_HAED = 135
function UIPlayer_ZhengShangYou:onDiscard(cards)
    -- 先删除所有的
    for idx, card in ipairs(self._discardedCards) do
        card:dispose()
        card:removeFromParent()
    end
    self._discardedCards = {}
    -- 先计算container的size
    local width = (#cards - 1) * CARD_MARGIN + CARD_WIDTH
    local startX = CARD_WIDTH * 0.5
    local y = CARD_HEIGHT * 0.5
    self._discardContainer:setContentSize(cc.size(width, CARD_HEIGHT))

    -- 再计算牌的位置
    for idx, value in ipairs(cards) do
        local card = CardFactory:get(value, CARD_SCALE)
        self._discardContainer:addChild(card)
        local x = startX + (idx - 1) * CARD_MARGIN
        card:setPosition(x, y)
        table.insert(self._discardedCards, card)
    end
end

function UIPlayer_ZhengShangYou:onGameStarted()

    -- Logger.debug("onGameStarted name = " .. self:getPlayerInfo():getShortName())
    self._imageReady:setVisible(false)
    self._nodeCardRemainNum:setVisible(true)
    self:onDiscard({})
end

function UIPlayer_ZhengShangYou:prepareForNextRound()
    self._imageReady:setVisible(true)
    self._nodeClock:setVisible(false)
    self._nodeCardRemainNum:setVisible(false)
    self._imagePass:setVisible(false)
    self:onDiscard({})
end

function UIPlayer_ZhengShangYou:setPassVisible(value)
    self._imagePass:setVisible(value or false)
    -- pass之后把出的牌删除
    if value == true then
        self:onDiscard({})
    end
end

function UIPlayer_ZhengShangYou:_onSelfClick()
    if GameMain.getInstance():isReviewVersion() then
        return
    end
    local playerInfo = super.getPlayerInfo(self) -- call super
    local _name = playerInfo.name
    local _id   = playerInfo.roleId
    local _ip   = playerInfo.ip
    local _url  = playerInfo.headIconUrl
    local _identify = playerInfo.isIdeneity
    local _headFrame = playerInfo.headFrame
    UIManager:getInstance():show("UIPlayerinfo2",_name,_id,_ip,_url,_identify,_headFrame)
end

---@overwrite
function UIPlayer_ZhengShangYou:dispose()
    if self._elemChat then
        self._elemChat:destroy()
    end
    self:_cancelTask()
    self:onDiscard({})
    UIPlayer_ZhengShangYou.super.dispose(self)
end

function UIPlayer_ZhengShangYou:_startTask()
    if self._task == nil then
        self._task = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
            self._textClock:setString(self._countDown)
            self._countDown = self._countDown - 1
            if self._countDown < 0 then
                self:_cancelTask()
            end
        end, 1, false)
    end
end

function UIPlayer_ZhengShangYou:_cancelTask()
    if self._task then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._task)
        self._countDown = CD_TIME
        self._task = nil
    end
end

local adjustTalk = function(view)
    local bg = seekNodeByName(view, "Image_Talk_BG", "ccui.ImageView")
    bg:setAnchorPoint(cc.p(0, 0.5))
    bg:setScaleX(1)
    bg:setScaleY(-1)
    bg:setPosition(300, 30)
    local txt = seekNodeByName(view, "Text_Talk", "ccui.Text")
    txt:setAnchorPoint(cc.p(1, 0.5))
    txt:setPosition(295, 35)
    local emoji = seekNodeByName(view, "Image_Emoji", "cc.Sprite")
    emoji:setAnchorPoint(cc.p(0.5, 0.5))
    emoji:setPosition(260, 37)
end

local adjustVoice = function (view) 
    view:setScaleX(-1) 
end

local MAP_ = 
{
    [1] = 
    { 
        discard = {AR = cc.p(0, 0.5), pos = cc.p(145, 0)},
        remain = {AR = cc.p(0.5, 0.5), pos = cc.p(115, -30)},
        ready = {AR = cc.p(0.5, 0.5), pos = cc.p(115, -30)},
        chat = {AR = cc.p(0, 0), pos = cc.p(35, 85)},
        voice = {AR = cc.p(0.5, 0.5), pos = cc.p(60, 85)},
        pass = {AR = cc.p(0.5, 0.5), pos = cc.p(190, 0)},
        clock = {AR = cc.p(0.5, 0.5), pos = cc.p(115, 45)}
    },
    [2] = 
    { 
        discard = {AR = cc.p(1, 0.5), pos = cc.p(-145, 0)},
        remain = {AR = cc.p(0.5, 0.5), pos = cc.p(-115, -30)},
        ready = {AR = cc.p(0.5, 0.5), pos = cc.p(115, -30)},
        chat = {AR = cc.p(1, 0), pos = cc.p(-35, 85), callback = adjustTalk},
        voice = {AR = cc.p(0.5, 0.5), pos = cc.p(-60, 85), callback = adjustVoice},
        pass = {AR = cc.p(0.5, 0.5), pos = cc.p(-190, 0)},
        clock = {AR = cc.p(0.5, 0.5), pos = cc.p(-115, 45)}
    },
    [3] = 
    { 
        discard = {AR = cc.p(1, 0.5), pos = cc.p(-145, 0)},
        ready = {AR = cc.p(0.5, 0.5), pos = cc.p(115, -30)},
        remain = {AR = cc.p(0.5, 0.5), pos = cc.p(-115, -30)},
        chat = {AR = cc.p(1, 0), pos = cc.p(-35, 85), callback = adjustTalk},
        voice = {AR = cc.p(0.5, 0.5), pos = cc.p(-60, 85), callback = adjustVoice},
        pass = {AR = cc.p(0.5, 0.5), pos = cc.p(-190, 0)},
        clock = {AR = cc.p(0.5, 0.5), pos = cc.p(-115, 45)}
    },
    [4] = 
    { 
        discard = {AR = cc.p(0, 0.5), pos = cc.p(145, 0)},
        remain = {AR = cc.p(0.5, 0.5), pos = cc.p(115, -30)},
        ready = {AR = cc.p(0.5, 0.5), pos = cc.p(115, -30)},
        chat = {AR = cc.p(0, 0), pos = cc.p(35, 85)},
        voice = {AR = cc.p(0.5, 0.5), pos = cc.p(60, 85)},
        pass = {AR = cc.p(0.5, 0.5), pos = cc.p(190, 0)},
        clock = {AR = cc.p(0.5, 0.5), pos = cc.p(115, 45)}
    },
}
-- 根据自身的位置不同，重新设置UI的位置和锚点
function UIPlayer_ZhengShangYou:_resetPositionAndAnchorPoint(cPos)
    -- local _Map = 
    -- {
    --     discard = self._listView_Discard, 
    --     ready = self._imageReady,
    --     remain = self._nodeCardRemainNum
    -- }
    -- 先实现已出牌的部分
    local cfg = MAP_[cPos]
    -- local keys = {'discard', 'ready', 'remain'}
    local prop, widget
    -- for idx, key in ipairs(keys) do
    --     prop = cfg[key]
    --     local widget = self._nodeCardRemainNum
    --     widget:setAnchorPoint(prop.AR)
    --     widget:setPosition(prop.pos.x, prop.pos.y)
    -- end
    prop = cfg.remain
    widget = self._nodeCardRemainNum
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)
    
    prop = cfg.discard
    -- widget = self._listView_Discard
    widget = self._discardContainer
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)

    prop = cfg.ready
    widget = self._imageReady
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)

    prop = cfg.pass
    widget = self._imagePass
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)

    prop = cfg.clock
    widget = self._nodeClock
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)

    prop = cfg.chat
    widget = self._panelTalk
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)
    if prop.callback then
        prop.callback(widget)
    end

    prop = cfg.voice
    widget = self._panelVoice
    widget:setAnchorPoint(prop.AR)
    widget:setPosition(prop.pos.x, prop.pos.y)
    if prop.callback then
        prop.callback(widget)
    end

    -- 本地玩家的出牌框在中间，倒计时也在中间
    if self:getPlayerInfo().cPosition == 1 then
        local p = cc.p(self._discardContainer:getPosition())
        self._discardContainer:setAnchorPoint(cc.p(0.5, 0.5))
        local pCenterInScene = self._discardContainer:getParent():convertToNodeSpace(display.center)
        self._discardContainer:setPosition(pCenterInScene.x, pCenterInScene.y)
        self._nodeClock:setPosition(pCenterInScene.x, pCenterInScene.y)
    end
end


-- 为了配合 ElemChat 而添加的方法 -- 这里返回processor更好
function UIPlayer_ZhengShangYou:getRoomSeat()
    return self
end

function UIPlayer_ZhengShangYou:getPlayer()
    return self:getPlayerInfo()
end

function UIPlayer_ZhengShangYou:getChairType()
    return self:getPlayerInfo().cPosition
end

function UIPlayer_ZhengShangYou:hasPlayer()
    return self:getPlayerInfo() ~= nil
end

return UIPlayer_ZhengShangYou