local HU_WAIT_TIME_1 = 1
local HU_WAIT_TIME_2 = 1
local Hus = {
}
local UIRoom_Hu = class("UIRoom_Hu")
local UIRoom_MulitHu = class("UIRoom_MulitHu", UIRoom_Hu)
local UIRoom_SingleHu = class("UIRoom_SingleHu", UIRoom_Hu)
Hus.UIRoom_Hu = UIRoom_Hu
Hus.UIRoom_MulitHu = UIRoom_MulitHu
Hus.UIRoom_SingleHu = UIRoom_SingleHu

local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local UI_ANIM = require("app.manager.UIAnimManager")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Constants = require("app.gameMode.mahjong.core.Constants")
local SoundsInfo = require("app.gameMode.mahjong.core.SoundsInfo")
local RoomProcessor = require("app.gameMode.mahjong.processor.RoomProcessor")
--------------------------------------------------------------
-- 这里配置好音乐后，再改
local SFX_OpKey = {}
local ui = {}

local areaId = game.service.LocalPlayerService:getInstance():getArea();
local HU_ANIMATIONS = MultiArea.getHuAnis(areaId)
local HU_WAIT_TIME = MultiArea.getConfigByKey('HU_WAIT_TIME')
local HU_WAIT_TIME_1 = HU_WAIT_TIME[1] or 0
local HU_WAIT_TIME_2 = HU_WAIT_TIME[2] or 0
--------------------------------------------------------------
--------------------------------------------------------------
function UIRoom_Hu:ctor(parent, huMask, boxIndicator)
    self._parentUI = parent
    self._huMask = huMask
    self._boxIndicator = boxIndicator

    self._huMask:setVisible(false)
    -- (BASE_CARD_Z_ORDER = 10) + 100 + 100
    self._huMask:setLocalZOrder(210)

    -- 当前房间的亲友圈ID，如果非0，结算后进入亲友圈界面
    self._roomClubId = 0
    self._roomLeagueId = 0
    self._animList = {}
    self._animListAuto = {}

    self._scheduleThis = nil
    self._turnCardsSchedule = nil
end

function UIRoom_Hu:clear()
    self._huMask:setVisible(false)
    self._huMask:stopAllActions()
    if self._scheduleThis then
        unscheduleOnce(self._scheduleThis)
        self._scheduleThis = nil
    end
    if self._turnCardsSchedule then
        unscheduleOnce(self._turnCardsSchedule)
        self._turnCardsSchedule = nil        
    end
    table.foreach(self._animList, function(key, val)
        UI_ANIM.UIAnimManager:getInstance():delOneAnim(val)
    end)
    self._animList = {}
    table.foreach(self._animListAuto, function(key, val)
        UI_ANIM.UIAnimManager:getInstance():delOneAnim(val)
    end)
    self._animListAuto = {}
end

function UIRoom_Hu:setRoomClubId(id)
    self._roomClubId = id
end

function UIRoom_Hu:setRoomLeagueId(id)
    self._roomLeagueId = id
end

function UIRoom_Hu:removeFromAnimList(anim)
    for i = 1, #self._animListAuto do
        if self._animListAuto[i] == anim then
            table.remove(self._animListAuto, i)
            break
        end
    end
end

function UIRoom_Hu:onHu()
end

function UIRoom_Hu:onBattleFinished()
end
--------------------------------------------------------------
--------------------------------------------------------------
function UIRoom_SingleHu:ctor(parent, huMask, boxIndicator)
    self.super.ctor(self, parent, huMask, boxIndicator)
end

function UIRoom_SingleHu:clear()
    self.super.clear(self)
end

--[[
@param steps PlayStep[]
@param isRecovery boolean
@param callback { (): void }
]]
function UIRoom_SingleHu:onHu(steps, isRecovery, callback)
    -- 这里是把所有的step合并在一起了，直接遍历，这样如果有一炮多响可以一块处理
    -- 先判断要播放那个动画
    -- 整体来说两大类，一个是自摸，在本家的位置播放
    -- 一个是点炮动事，要知道点炮的人，以及要胡牌的人
    -- 现在有歧义的是点杠花
    local huType = PlayType.UNKNOW
    local cardNumber_Hu = 0
    local playerId_Hu = {}
    local playerId_DianPao = 0
    local isKaihua = false
    for key, step in pairs(steps) do
        -- 获取胡的类型
        for _, data in pairs(step._scoreData.datas) do
            -- 先获取当前胡是不是特殊类型
            if HU_ANIMATIONS[data.type] then
                huType = data.type
            end
            if data.type == PlayType.HU_GANG_SHANG_HUA and step:getRoleId() == game.service.LocalPlayerService.getInstance():getRoleId() then
                isKaihua = true
            end
        end

        cardNumber_Hu = step._cards[1]
        table.insert(playerId_Hu, step:getRoleId())
        playerId_DianPao = step:getScoreData().sourceId;

        if step:getRoleId() == step:getScoreData().sourceId then
            -- 自摸
            -- 获取胡的类型
            if huType == PlayType.UNKNOW then
                huType = PlayType.HU_ZI_MO
            end

            -- 显示自摸动画
            self:clear();

            -- 播放音效
            local huProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(playerId_Hu[1])
            if huProcessor ~= nil then 
                SoundsInfo:getInstance():playSound(HU_ANIMATIONS[huType].sfx, huProcessor:getRoomSeat():getPlayer().sex)
            end 
            -- 自摸胡, 不需要后续的逻辑了
            return self:playAnimSelfHu(step:getRoleId(), HU_ANIMATIONS[huType].pfx, callback, isKaihua);
        end
    end

    -- 这里是点炮胡
    if huType == PlayType.UNKNOW then
        huType = PlayType.HU_DIAN_PAO
    end

    -- 播放音效, 使用第一个胡玩家播放声音
    local huProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(playerId_Hu[1])
    if huProcessor ~= nil then 
        SoundsInfo:getInstance():playSound(HU_ANIMATIONS[huType].sfx, huProcessor:getRoomSeat():getPlayer().sex)
    end 
    -- 显示自摸动画
    self:clear();
    return self:playAnimDiscardOther(playerId_DianPao, playerId_Hu, HU_ANIMATIONS[huType].pfx, cardNumber_Hu, callback, isKaihua);
end

function UIRoom_SingleHu:_getGangShangHuaAnim()
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() or 
		game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		return nil
	end
	local effects = game.service.LocalPlayerService.getInstance():getSpecialEffectArray();
	local effect = nil
	table.foreach(effects,function (k,v)
		if Constants.EffectMap.gangshanghua[v] ~= nil then
			effect = Constants.EffectMap.gangshanghua[v]
		end
	end)
    return effect
end

--[[
自摸类动画播放
@param huPlayerId number
@param pfx anim
@param callback { (): void }
]]
function UIRoom_SingleHu:playAnimSelfHu(huPlayerId, pfx, callback, isKaihua)
    -- 播放动画
    local anim = nil
    local kaihua = self:_getGangShangHuaAnim()

    if isKaihua and kaihua ~= nil then
        anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(kaihua, function()
            self:removeFromAnimList(anim)
        end))
        anim._csbAnim:setScale(2.2)
        table.insert(self._animListAuto, anim)
    else
        anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(pfx, function()
            self:removeFromAnimList(anim)
        end))
        table.insert(self._animListAuto, anim)

        local huProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(huPlayerId)
        local widget = huProcessor:getSeatUI():getEffectNode()
        local x, y = widget:getPosition()
        local pos1 = widget:getParent():convertToWorldSpace(cc.p( x, y))
        if huProcessor:getSeatUI():getChairType() == CardDefines.Chair.Left then
            pos1 = widget:getParent():convertToWorldSpace(cc.p( x - 45, y))
        elseif huProcessor:getSeatUI():getChairType() == CardDefines.Chair.Right then
            pos1 = widget:getParent():convertToWorldSpace(cc.p( x + 45, y))
        end  
        local delay = cc.DelayTime:create(0.5)
        local seq = cc.Sequence:create(delay)
        pos1 = anim._csbAnim:getParent():convertToNodeSpace(pos1)
        anim._csbAnim:setPosition(pos1)
        anim._csbAnim:setScale(0.7)
        anim._csbAnim:runAction(seq)
    end

    -- anim播放完成后，会自动删除
    self:showHuMask(1, function()
        if callback then
            callback()
        end
    end)

    return 1
end

--[[
点炮类动画播放
@param playerId_DianPao number
@param playerId_Hu number[]
@param pfx anim
@param callback { (): void }
]]
function UIRoom_SingleHu:playAnimDiscardOther(playerId_DianPao, playerId_Hu, pfx, huCard, callback, isKaihua)
    local kaihua = self:_getGangShangHuaAnim()
    if isKaihua then     
        local anim = nil
        anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(kaihua, function()
            self:removeFromAnimList(anim)
        end))
        anim._csbAnim:setScale(2.2)
        table.insert(self._animListAuto, anim)
    else
        for k,v in pairs(playerId_Hu) do
            local anim = nil
            anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(pfx, function()
                self:removeFromAnimList(anim)
            end))
            table.insert(self._animListAuto, anim)
    
            local huProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(v)
            local widget = huProcessor:getSeatUI():getEffectNode()
            local x, y = widget:getPosition()
            local pos1 = widget:getParent():convertToWorldSpace(cc.p( x, y))
            if huProcessor:getSeatUI():getChairType() == CardDefines.Chair.Left then
                pos1 = widget:getParent():convertToWorldSpace(cc.p( x - 45, y))
            elseif huProcessor:getSeatUI():getChairType() == CardDefines.Chair.Right then
                pos1 = widget:getParent():convertToWorldSpace(cc.p( x + 45, y))
            end            
            local delay = cc.DelayTime:create(0.5)
            local seq = cc.Sequence:create(delay)
            pos1 = anim._csbAnim:getParent():convertToNodeSpace(pos1)
            anim._csbAnim:setPosition(pos1)
            anim._csbAnim:setScale(0.7)
            anim._csbAnim:runAction(seq)
        end        
    end    
    -- anim播放完成后，会自动删除
    self:showHuMask(1, function()
        if callback then
            callback()
        end
    end)
    return 1
end

--[[
@param roundReports RoundReportInfo[]
@param machResult net.core.protocol.BCMatchResultSYN
]]
function UIRoom_SingleHu:onBattleFinished(roundReports, machResult)
     -- 关闭托管
    self:closeTrusteeship()    
    -- 比赛隐藏按钮
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
        game.service.CampaignService.getInstance():dispatchEvent({name = "EVENT_CAMPAIGN_RANK_HIDE"})	
    end
    -- 结算了，给大家亮一下牌，就可以显示结果了
    if machResult.isHuang then
        -- 黄庄
        local gameService = gameMode.mahjong.Context.getInstance():getGameService()
        table.foreach(roundReports, function(key, report)
            report.player:showHandCardsWhenFinished(report.hand, report.hus, #report.hus > 0, machResult.matchResults, report.huStatus)
        end)
        if machResult.isRejoin then
            -- 当前应该直接进结算了，是从断线重连
            self:showHandCardWhenFinished(roundReports, machResult)
        else
            self._huMask:setVisible(true)
            local anim = nil
            anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_huangzhuang.csb", function()
                self:showHandCardWhenFinished(roundReports, machResult)
                self:removeFromAnimList(anim)
            end))
            table.insert(self._animListAuto, anim)
        end

        -- 一定时间后推牌
        -- let self = this;
        -- this.parent.showHuMask(2000, () => self.showHandCardWhenFinished(roundReports, machResult))
        -- 播放音效, TODO : 不需要播放吗?
        -- this.playSFXConfig(SFX_OpKey.HuangZhuang, game.service.LocalPlayerService.getInstance().gender);
    else
        -- 直接推牌
        self:showHandCardWhenFinished(roundReports, machResult)
    end
end

--[[
牌局结束之后的推牌逻辑
@param roundReports Array<RoundReportInfo>
@param machResult net.core.protocol.BCMatchResultSYN
]]
function UIRoom_SingleHu:showHandCardWhenFinished(roundReports, machResult)
    -- 推倒手牌。
    -- for (let report of roundReports)
    --     this.parent.getCardSequence(report.player.id).showHandCardsWhenFinished(report.hand, report.hus, report.hus && report.hus.length > 0);
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    table.foreach(roundReports, function(key, report)
        report.player:showHandCardsWhenFinished(report.hand, report.hus, #report.hus > 0, machResult.matchResults, report.huStatus)
    end)
    if self._scheduleThis then
        unscheduleOnce(self._scheduleThis)
        self._scheduleThis = nil
    end
    -- 如果黄庄或者断线重连后，收到结算处理的时候，直接显示结算界面，不再延时到下帧再显示
    -- 在观战跟正常打牌的延时时间似乎不一样
    if not machResult.isRejoin and not machResult.isHuang then
        self._scheduleThis = scheduleOnce(function()
            self._scheduleThis = nil
            self:doHuMaskEvent(roundReports, machResult);
        end, HU_WAIT_TIME_1)
    else
        self:doHuMaskEvent(roundReports, machResult);
    end
end

function UIRoom_SingleHu:showHuMask(time, callback)
    self._huMask:setVisible(true)
    self._huMask:setOpacity(1)
    local alpha = cc.FadeTo:create(time, 255)
    local call = cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)
    local seq = cc.Sequence:create(alpha, call)
    self._huMask:runAction(seq)
end

--[[
@param roundReports RoundReportInfo[]
@param machResult net.core.protocol.BCMatchResultSYN
]]
function UIRoom_SingleHu:onReplayFinished(roundReports, machResult)
    -- 结算了，给大家亮一下牌，就可以显示结果了
    if machResult.isHuang then
        -- 黄庄
        local maxCardCount = nil
        local gameService = gameMode.mahjong.Context.getInstance():getGameService()
        table.foreach(roundReports, function(key, report)
            report.player:showHandCardsWhenFinished(report.hand, report.hus, #report.hus > 0, machResult.matchResults, report.huStatus)
            if maxCardCount == nil then
                maxCardCount = report.player:getSeatUI():maxCardNumber()
            end
        end)
        if maxCardCount == 0 or maxCardCount == nil or maxCardCount == - 1 then
            -- 当前应该直接进结算了，是从断线重连
            self:showHandCardWhenReplayFinished(roundReports, machResult)
        else
            local anim = nil
            anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_huangzhuang.csb", function()
                self:showHandCardWhenReplayFinished(roundReports, machResult)
                self:removeFromAnimList(anim)
            end))
            table.insert(self._animListAuto, anim)
        end
    else
        -- 直接推牌
        self:showHandCardWhenReplayFinished(roundReports, machResult)
    end
end

--[[
牌局结束之后的推牌逻辑
@param roundReports Array<RoundReportInfo>
@param machResult net.core.protocol.BCMatchResultSYN
]]
function UIRoom_SingleHu:showHandCardWhenReplayFinished(roundReports, machResult)
    -- 推倒手牌。
    -- for (let report of roundReports)
    --     this.parent.getCardSequence(report.player.id).showHandCardsWhenFinished(report.hand, report.hus, report.hus && report.hus.length > 0);
    local maxCardCount = nil
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    table.foreach(roundReports, function(key, report)
        report.player:showHandCardsWhenFinished(report.hand, report.hus, #report.hus > 0, machResult.matchResults, report.huStatus)
        if maxCardCount == nil then
            maxCardCount = report.player:getSeatUI():maxCardNumber()
        end
    end)
end

--[[
@param roundReports Array<RoundReportInfo>
@param proto net.core.protocol.BCMatchResultSYN
]]
function UIRoom_SingleHu:doHuMaskEvent(roundReports, proto)
    -- this.huMask = this.parent.huMask;
    -- -- 显示跳过提示
    -- UIManager.Instance.Show(MessageTips_SkipToResult);
    -- let isShow = false;
    -- let self = this;
    -- -- 定时强制进入结算
    -- this.parent.timer.once(2500, this, () => {
    --     if (!isShow)
    --         self.showRoundReport(roundReports, proto);
    --     isShow = true;
    -- })
    -- -- 点击进入结算
    -- this.huMask.on(Laya.Event.CLICK, this, () => {
    --     if (!isShow)
    --         self.showRoundReport(roundReports, proto);
    --     isShow = true;
    -- });
    --四个人的头像要抬到蒙板上边
    -- this.anchorBottomLeft.zOrder = HU_HEAD_ZORDER;
    -- this.anchorRight.zOrder = HU_HEAD_ZORDER;
    -- this.anchorTop.zOrder = HU_HEAD_ZORDER;
    -- this.anchorLeft.zOrder = HU_HEAD_ZORDER;
    -- this.parent.updateZOrder();
    -- 如果 maxCardCount 说明当前复牌后的显示结算，这里不再等待
    if proto.isRejoin then
        self:showRoundReport(roundReports, proto)
    else
        if self._scheduleThis then
            unscheduleOnce(self._scheduleThis)
            self._scheduleThis = nil
        end
        self._scheduleThis = scheduleOnce(function()
            self._scheduleThis = nil
            self:showRoundReport(roundReports, proto)
        end, HU_WAIT_TIME_2)
    end
end
--[[
    关闭托管
]]
function UIRoom_SingleHu:closeTrusteeship()
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign()
    or game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
        gameMode.mahjong.Context.getInstance():getGameService():setIsTrusteeship(false) 	
    end
end

--[[
@param __roundReports Array<RoundReportInfo>
@param __proto net.core.protocol.BCMatchResultSYN
]]
function UIRoom_SingleHu:showRoundReport(__roundReports, __proto)
    -- -- 隐藏结算
    -- this.huMask.offAll();
    -- this.huMask.visible = false;
    -- -- 终止所有动画
    -- self:clear();
    -- -- 恢复ZOrder
    -- this.parent.SetCmpZOrder();
    -- -- 隐藏跳过提示
    -- UIManager.Instance.Hide(MessageTips_SkipToResult);
    -- BattleService.getInstance().showRoundReport(__roundReports, __proto);
    self._huMask:setVisible(false)
    __proto.roomClubId = self._roomClubId
    __proto.roomLeagueId = self._roomLeagueId

    -- 金币场显示自己特有的界面
    if game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
        UIManager:getInstance():show("UIGoldRoundReport", __roundReports, __proto)
        return
    elseif campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
        UIManager:getInstance():show("UICampaignRoundReport", __roundReports, __proto, "campaign")
        return
    end

    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
        UIManager:getInstance():show("UIRoundReportPage2", __roundReports, __proto, "campaign")
    else
        UIManager:getInstance():show("UIRoundReportPage2", __roundReports, __proto)
    end

    -- 关闭无效窗口
    local _tab = {"UIChatPanel", "UISetting", "UIMahjongSelector", "UITimeDelay", "UIGpsNew"}
    for i, uiname in pairs(_tab) do 
        UIManager:getInstance():hide(uiname)
    end 
end

function UIRoom_SingleHu:showChicken(stepGroup)
    local cardValue = nil
    local scoreDatas = {}
    local chickenNums = 0
    local card_value = 0
    local ishz = false
    local iszj = false
    table.foreach(stepGroup, function(_, step)
        if step:getPlayType() == PlayType.DISPLAY_JI_SELF then
            iszj = true
            cardValue = step._cards[1]
        elseif step:getPlayType() == PlayType.DISPLAY_JI_FANPAI then
            local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(step:getRoleId())
            local chair = processor:getSeatUI():getChairType()
            scoreDatas[chair] = scoreDatas[chair] or {cards = {}, xingQi={}, fanPaiNums = 0}
            table.foreach(step._cards, function(_, card)
                scoreDatas[chair].fanPaiNums = scoreDatas[chair].fanPaiNums + 1
                chickenNums = chickenNums + 1
                table.insert(scoreDatas[chair].cards, card)
            end)
        elseif step:getPlayType() == PlayType.DISPLAY_JI_XINGQI then
            local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(step:getRoleId())
            local chair = processor:getSeatUI():getChairType()
            scoreDatas[chair] = scoreDatas[chair] or {cards = {}, xingQi={}, fanPaiNums = 0}
            table.foreach(step._cards, function(_, card)
                table.insert(scoreDatas[chair].xingQi, card)
            end)
        elseif step._playType == PlayType.DISPLAY_JI_CHUIFENG then
            card_value = cardValue
        elseif step._playType == PlayType.DISPLAY_FINISH_ALL then
            local rounds = {}
            table.foreach(step:getResult()._protocol:getProtocolBuf().matchResults, function(key, val)
			    table.insert(rounds, RoomProcessor:getCardList(val))
		    end)
            self:onBattleFinished(rounds, step:getResult()._protocol:getProtocolBuf())
            if step:getResult()._protocol:getProtocolBuf().isHuang then
                ishz =true
            end
        elseif step._playType == PlayType.DISPLAY_FINISH_ALL_REPLAY then
            local rounds = {}
            
            table.foreach(step:getResult().matchResults, function(key, val)
			    table.insert(rounds, RoomProcessor:getCardList(val))
		    end)
            self:onReplayFinished(rounds, step:getResult())
        end
    end)

    -- 添加星期鸡，但是不再计算翻牌鸡数量，用来区分开翻牌鸡跟星期鸡
    table.foreach(scoreDatas, function(chair, data)
        table.foreach(data.xingQi, function(index, val)
            -- 只累积总数量，不添加到各自chickenNums
            -- 这里也有歧义，不知道星期鸡到底应该算不算到实际翻到牌数中去
            chickenNums = chickenNums + 1
            table.insert(scoreDatas[chair].cards, val)
        end)
    end)

    if ishz then
        return
    end

    -- 现在星期鸡的存在，导致，在没有翻牌鸡的情况下也要翻鸡动画。。。
    local function turnCards()
        -- 播放对应玩家有几张鸡
        local chickenCsb = "ui/csb/Effect/TurnCardEffect.csb"
        local size = cc.Director:getInstance():getWinSize()

        -- 如果没有上家，则左右的y往上调整50像素
        local posY = size.height / 2
        -- local playerProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByChair(CardDefines.Chair.Top)
        -- if playerProcessor == nil then
        --     posY = posY + 50
        -- end
        local poss = {
            [CardDefines.Chair.Down] = {pos = cc.p(size.width / 2, size.height / 2 - 150), x = cc.p(50, 0), y = cc.p(0, 75)},
            [CardDefines.Chair.Right] = {pos = cc.p(size.width / 2 + 300, posY), x = cc.p(50, 0), y = cc.p(0, 75)},
            [CardDefines.Chair.Top] = {pos = cc.p(size.width / 2, size.height / 2 + 150), x = cc.p(50, 0), y = cc.p(0, 75)},
            [CardDefines.Chair.Left] = {pos = cc.p(size.width / 2 - 300, posY), x = cc.p(50, 0), y = cc.p(0, 75)},
        }
        table.foreach(scoreDatas, function(key1, val1)
            local chair = key1
            local cards = val1.cards
            local fanPaiNums = val1.fanPaiNums
            if #cards == 0 then
                return
            end
            local maxCardNumbers = 8
            -- 动态计算一行显示的最大排数量
            -- 显示规则如下
            -- 24 17 16 15 14 13 18 21
            -- 23 10  5  6  7  8 12 20
            -- 22  9  1  2  3  4 11 19
            if #cards >= 1 and #cards <= 8 then
                maxCardNumbers = 4
            elseif #cards >= 9 and #cards <= 10 then
                maxCardNumbers = 5
            elseif #cards >= 11 and #cards <= 18 then
                maxCardNumbers = 6
            elseif #cards >= 19 and #cards <= 21 then
                maxCardNumbers = 7
            else
                maxCardNumbers = 8
            end

            local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByChair(chair)
            if processor == nil then
                return
            end
            local startPositon = processor:getSeatUI():getHuStatusPosition()

            local nodePos = self._parentUI:convertToWorldSpace(startPositon)
            local newPos = cc.pSub(nodePos, cc.p(0,60))

            local posinfo = poss[chair]
            local max = #cards <= maxCardNumbers and #cards or maxCardNumbers
            local stepLength = cc.p( (max - 1) * 0.5 * 50 ,0)
            local initPos = cc.pSub(newPos, stepLength)
            local start = initPos
            local zorder = config.UIConstants.UIZorder

            for key, val in ipairs(cards) do 
                -- 翻版鸡的展示
                local cardBorn = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(chickenCsb, function()
                end, - 1))
                -- 此动画没有自动删除，需要手动去删除
                table.insert(self._animList, cardBorn)
                -- 更换卡牌，牌面
                local cardTexture2 = cardBorn:getChild("image_card", "ccui.ImageView")
                cardTexture2:loadTexture(CardFactory:getInstance():getSurfaceSkin(val), ccui.TextureResType.plistType)
                -- 更换牌背(为了符合主题对应的颜色)
                local imgCardBg = cardBorn:getChild("imgFlyCard", "ccui.ImageView")
                local style =  CardFactory.getInstance():_getCardStyle()
                local cardBg = ""
                if chair == CardDefines.Chair.Down or chair == CardDefines.Chair.Top then
                    cardBg = "art/%s/%s/mj_bg2.png"
                else
                    cardBg = "art/%s/%s/mj_bg6.png"
                end
                cardBg = string.format(cardBg, style.atlas, style.bg)
                imgCardBg:loadTexture(cardBg, ccui.TextureResType.plistType)

                -- 当最后一行的时候，改变位置，居中对齐
                if #cards > maxCardNumbers and math.floor((key-1)/maxCardNumbers) == math.floor((#cards-1)/maxCardNumbers) then
                    max = (#cards-1) % maxCardNumbers + 1
                    stepLength = cc.pMul(posinfo.x,(maxCardNumbers - max) * 0.5)
                    start = cc.pAdd(initPos, stepLength)
                end
                -- 隐藏星期鸡标记
                local cardTexture3 = cardBorn:getChild("image_card_xq", "ccui.ImageView")
                -- 如果当前的index 大于翻牌鸡的总数目了，那么就是星期鸡了
                if fanPaiNums < key then
                    cardTexture3:setVisible(true)
                else
                    cardTexture3:setVisible(false)
                end

                -- 这里需要位置的计算
                cardBorn:pos(cc.pAdd(cc.pAdd(start, cc.pMul(posinfo.x,(key - 1) % maxCardNumbers)), cc.pMul(posinfo.y, -math.floor((key - 1) / maxCardNumbers))))
                cardBorn._csbAnim:setLocalZOrder(zorder)

                cardBorn._csbAnim:setOpacity(0)
                local alpha = cc.FadeIn:create(0.3)
                local seq = cc.Sequence:create(alpha)
                cardBorn._csbAnim:runAction(seq)
                zorder = zorder - math.floor(key / maxCardNumbers)
            end
        end)
    end

    if card_value == 25 then
        local anim = nil
        anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(HU_ANIMATIONS[PlayType.DISPLAY_JI_FANPAI].pfx, function()
            UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(HU_ANIMATIONS[PlayType.DISPLAY_JI_CHUIFENG].pfx, function()
                end))
        end))
        local cardTexture = anim:getChild("image_card", "ccui.ImageView")
        cardTexture:loadTexture(CardFactory:getInstance():getSurfaceSkin(card_value), ccui.TextureResType.plistType)

        -- 替换动画的牌背 --TODO
        local cardBg = "art/%s/%s/mj_bg7.png"
        local imgCardBg = anim:getChild("Image_2_zhuoji", "ccui.ImageView")
        local style =  CardFactory.getInstance():_getCardStyle()
        cardBg = string.format(cardBg, style.atlas, style.bg)
        if imgCardBg then
            imgCardBg:loadTexture(cardBg, ccui.TextureResType.plistType)
        end
        cardBg = "art/%s/%s/mj_bg2.png"
        imgCardBg = anim:getChild("Image_3_zhuoji", "ccui.ImageView")
        cardBg = string.format(cardBg, style.atlas, style.bg)
        if imgCardBg then
            imgCardBg:loadTexture(cardBg, ccui.TextureResType.plistType)
        end
        return 5
    elseif cardValue and cardValue ~= -1 and cardValue ~= 255 then
        local anim = nil
        anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(HU_ANIMATIONS[PlayType.DISPLAY_JI_FANPAI].pfx,function()
            self:removeFromAnimList(anim)
        end))
        self._turnCardsSchedule = scheduleOnce(function()
            self._turnCardsSchedule = nil
            if chickenNums > 0 then
                turnCards()
            end
        end,1)
        
        table.insert(self._animListAuto, anim)

        -- 更换卡牌，牌面
        local cardTexture = anim:getChild("image_card", "ccui.ImageView")
        cardTexture:loadTexture(CardFactory:getInstance():getSurfaceSkin(cardValue), ccui.TextureResType.plistType)

        -- 替换动画的牌背 --TODO
        local cardBg = "art/%s/%s/mj_bg7.png"
        local imgCardBg = anim:getChild("Image_2_zhuoji", "ccui.ImageView")
        local style =  CardFactory.getInstance():_getCardStyle()
        cardBg = string.format(cardBg, style.atlas, style.bg)
        if imgCardBg then
            imgCardBg:loadTexture(cardBg, ccui.TextureResType.plistType)
        end
        cardBg = "art/%s/%s/mj_bg2.png"
        imgCardBg = anim:getChild("Image_3_zhuoji", "ccui.ImageView")
        cardBg = string.format(cardBg, style.atlas, style.bg)
        if imgCardBg then
            imgCardBg:loadTexture(cardBg, ccui.TextureResType.plistType)
        end

                
        return chickenNums == 0 and 3 or 5
    else
        if iszj then
            local chickenNo = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_zhuojiwuji.csb", function()
                -- 如果有星期鸡也要处理
                if chickenNums > 0 then
                    turnCards()
                end
            end))
            self._turnCardsSchedule = scheduleOnce(function()
                self._turnCardsSchedule = nil
                -- 如果有星期鸡也要处理
                if chickenNums > 0 then
                    turnCards()
                end
            end,1)
            -- 替换动画的牌背
            local cardBg = "art/%s/%s/mj_bg7.png"
            local imgCardBg = chickenNo:getChild("Image_3_zhuoji", "ccui.ImageView")
            local style =  CardFactory.getInstance():_getCardStyle()
            cardBg = string.format(cardBg, style.atlas, style.bg)
            imgCardBg:loadTexture(cardBg, ccui.TextureResType.plistType)
        end
        return 1
    end
end
--------------------------------------------------------------
-- 多胡的配置，现在没有完成
--------------------------------------------------------------
function UIRoom_MulitHu:ctor(parent, huMask, boxIndicator)
    self.super.ctor(self, parent, huMask, boxIndicator)

    self._animList = {}
end

function UIRoom_MulitHu:clear()
    table.foreach(self._animList, function(key, val)
    end)
end

--[[
@param steps PlayStep[]
@param isRecovery boolean
@param callback { (): void }
]]
function UIRoom_MulitHu:onHu(steps, isRecovery, callback)
    -- 这里是把所有的step合并在一起了，直接遍历，这样如果有一炮多响可以一块处理
    -- 先判断要播放那个动画
    -- 整体来说两大类，一个是自摸，在本家的位置播放
    -- 一个是点炮动事，要知道点炮的人，以及要胡牌的人
    -- 现在有歧义的是点杠花
    local huType = PlayType.UNKNOW
    local cardNumber_Hu = 0
    local playerId_Hu = {}
    local playerId_DianPao = 0
    for key, step in pairs(steps) do
        -- 获取胡的类型
        for _, data in pairs(step._scoreData.datas) do
            -- 先获取当前胡是不是特殊类型
            if HU_ANIMATIONS[data.type] then
                huType = data.type
            end
        end

        cardNumber_Hu = step._cards[1]
        table.insert(playerId_Hu, step:getRoleId())
        playerId_DianPao = step:getScoreData().sourceId;

        if step:getRoleId() == step:getScoreData().sourceId then
            -- 自摸
            -- 获取胡的类型
            if huType == PlayType.UNKNOW then
                huType = PlayType.HU_ZI_MO
            end

            -- 显示自摸动画
            self:clear();
            self:playAnimSelfHu(step:getRoleId(), HU_ANIMATIONS[huType].pfx, callback);

            -- 播放音效
            -- local player = BattleService.getInstance().FindPlayer(step.roleId);
            -- UIManager.Instance.GetUI(BattlePage).playSFXConfig(HU_ANIMATIONS[huType].sfx, player.sex);
            -- 自摸胡, 不需要后续的逻辑了
            return;
        end
    end


    -- 这里是点炮胡
    if huType == PlayType.UNKNOW then
        huType = PlayType.HU_DIAN_PAO
    end

    -- 显示自摸动画
    self:clear();
    self:playAnimDiscardOther(playerId_DianPao, playerId_Hu, HU_ANIMATIONS[huType].pfx, cardNumber_Hu, callback);

    -- 播放音效, 使用第一个胡玩家播放声音
    -- local huPlayer = BattleService.getInstance().FindPlayer(playerId_Hu[0]);
    -- UIManager.Instance.GetUI(BattlePage).playSFXConfig(HU_ANIMATIONS[huType].sfx, huPlayer.sex);
end

--[[
@param roundReports RoundReportInfo[]
@param machResult net.core.protocol.BCMatchResultSYN
]]
function UIRoom_MulitHu:onBattleFinished(roundReports, machResult)
    -- 结算了，给大家亮一下牌，就可以显示结果了
    if machResult.isHuang then
        -- 黄庄
        -- -- 播放黄庄动画
        -- local anim = UIAnimManager.instance.OnShow(new UIAnimConfig(ui.huangzhuangUI, null, -1))
        -- table.insert(self._animList, anim)
        -- -- 获取中心位置作为播放位置
        -- local clientScale = Math.max(Laya.Browser.width / Laya.stage.desginWidth, Laya.Browser.height / Laya.stage.desginHeight)
        -- let startPoint = new laya.maths.Point(Laya.Browser.width * 0.5 / clientScale, Laya.Browser.height * 0.5 / clientScale);
        -- -- 设置动画位置
        -- startPoint = anim.point2Pos(startPoint);
        -- anim.pos(startPoint.x, startPoint.y);
        -- -- 一定时间后推牌
        -- let self = this;
        -- this.parent.showHuMask(2000, () => self.showHandCardWhenFinished(roundReports, machResult))
        -- 播放音效, TODO : 不需要播放吗?
        -- this.playSFXConfig(SFX_OpKey.HuangZhuang, game.service.LocalPlayerService.getInstance().gender);
        self:showHandCardWhenFinished(roundReports, machResult)
    else
        -- 直接推牌
        self:showHandCardWhenFinished(roundReports, machResult)
    end
end

--[[
自摸类动画播放
@param huPlayerId number
@param pfx anim
@param callback { (): void }
]]
function UIRoom_MulitHu:playAnimSelfHu(huPlayerId, pfx, callback)
    -- 播放动画
    -- let anim = UIAnimManager.instance.OnShow(new UIAnimConfig(pfx, null, -1))
    -- this._animList.push(anim);
    -- -- 设置动画位置
    -- let huPos = this.parent.getCardSequence(huPlayerId).CardLayout.discardedAniStart;
    -- anim.pos(huPos.x, huPos.y);
    -- anim._ui.zOrder = UIManager.LAYER_OVERLAY;
    -- -- anim播放完成后，会自动删除
    -- this.parent.showHuMask(1500, () => {
    --     if (callback)
    --         callback();
    -- })
    if callback then
        callback()
    end
end

--[[
点炮类动画播放
@param playerId_DianPao number
@param playerId_Hu number[]
@param pfx anim
@param callback { (): void }
]]
function UIRoom_MulitHu:playAnimDiscardOther(playerId_DianPao, playerId_Hu, pfx, huCard, callback)
    -- let dianPaoPos = this.parent.getCardSequence(playerId_DianPao).CardLayout.discardedAniStart;
    -- playerId_Hu.forEach(huId => {
    --     let anim = UIAnimManager.instance.OnShow(new UIAnimConfig(pfx, null, -1));
    --     this._animList.push(anim);
    --     -- 设置动画牌值
    --     if (CardDefines.isValidCardNumber(huCard)) {
    --         let skin = CardFactory:getInstance():getSurfaceSkin(huCard);
    --         if ((anim._ui as any).paimian)
    --             (anim._ui as any).paimian.skin = skin;
    --     }
    --     -- 计算动画飞出位置
    --     let huPos = this.parent.getCardSequence(huId).CardLayout.discardedAniStart.toLayaPoint();
    --     huPos = anim.point2Pos(huPos);
    --     anim._ui.x = dianPaoPos.x;
    --     anim._ui.y = dianPaoPos.y;
    --     anim._ui.zOrder = UIManager.LAYER_OVERLAY;
    --     -- 播放动画
    --     Laya.Tween.to(anim._ui, huPos, 2000, Laya.Ease.quintOut);
    -- })
    -- -- anim播放完成后，会自动删除
    -- this.parent.showHuMask(2600, () => {
    --     if (callback)
    --         callback();
    -- })
    if callback then
        callback()
    end
end

--[[
牌局结束之后的推牌逻辑
@param roundReports Array<RoundReportInfo>
@param machResult net.core.protocol.BCMatchResultSYN
]]
function UIRoom_MulitHu:showHandCardWhenFinished(roundReports, machResult)
    -- 推倒手牌。
    -- for (let report of roundReports)
    --     this.parent.getCardSequence(report.player.id).showHandCardsWhenFinished(report.hand, report.hus, report.hus && report.hus.length > 0);
    self:doHuMaskEvent(roundReports, machResult);
end

--[[
@param roundReports Array<RoundReportInfo>
@param proto net.core.protocol.BCMatchResultSYN
]]
function UIRoom_MulitHu:doHuMaskEvent(roundReports, proto)
    -- this.huMask = this.parent.huMask;
    -- -- 显示跳过提示
    -- UIManager.Instance.Show(MessageTips_SkipToResult);
    -- let isShow = false;
    -- let self = this;
    -- -- 定时强制进入结算
    -- this.parent.timer.once(2500, this, () => {
    --     if (!isShow)
    --         self.showRoundReport(roundReports, proto);
    --     isShow = true;
    -- })
    -- -- 点击进入结算
    -- this.huMask.on(Laya.Event.CLICK, this, () => {
    --     if (!isShow)
    --         self.showRoundReport(roundReports, proto);
    --     isShow = true;
    -- });
    --四个人的头像要抬到蒙板上边
    -- this.anchorBottomLeft.zOrder = HU_HEAD_ZORDER;
    -- this.anchorRight.zOrder = HU_HEAD_ZORDER;
    -- this.anchorTop.zOrder = HU_HEAD_ZORDER;
    -- this.anchorLeft.zOrder = HU_HEAD_ZORDER;
    -- this.parent.updateZOrder();
    self:showRoundReport()
end

--[[
@param __roundReports Array<RoundReportInfo>
@param __proto net.core.protocol.BCMatchResultSYN
]]
function UIRoom_MulitHu:showRoundReport(__roundReports, __proto)
    -- -- 隐藏结算
    -- this.huMask.offAll();
    -- this.huMask.visible = false;
    -- -- 终止所有动画
    -- self:clear();
    -- -- 恢复ZOrder
    -- this.parent.SetCmpZOrder();
    -- -- 隐藏跳过提示
    -- UIManager.Instance.Hide(MessageTips_SkipToResult);
    -- BattleService.getInstance().showRoundReport(__roundReports, __proto);
    UIManager:getInstance():show("UIRoundReportPage2", __roundReports, __proto)
end
--------------------------------------------------------------
return Hus 