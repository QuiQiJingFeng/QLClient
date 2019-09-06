--[[
    @desc: 新版比赛晋级页面
    author:{贺逸}
    time:2018-06-19
    return
]]
local csbPath = "ui/csb/Campaign/campaignBattle/UIPromotionBased.csb"
local super = require("app.game.ui.UIBase")

local CampaignAnimPlayer = require("app.game.campaign.utils.CampaignAnimPlayer");
local ArenaConfig = require("app.game.campaign.ArenaConfig")
local UI_ANIM = require("app.manager.UIAnimManager")

local NoticeText = {
    [1] = "听说多打比赛有助于提升牌技~",
    [2] = "掐指一算~今天是个赢红包的好日子！",
    [3] = "高额红包赛（50元、25元）的专属门票在商城的赛券一栏内就可以购买啦~",
    [4] = "千元红包赛在每晚9点开赛，麻友们可以提前免费报名参加哦",
    [5] = "近期参加过的比赛都可以在参赛记录里看到，并且可以分享给好友或者朋友圈~",
    [6] = "喜欢快速比赛的麻友可以选择 50元红包赛以及快速房卡赛，更快赢取奖品~",
    [7] = "听说有胆量打比赛场的人都是高手中的高手~",
    [8] = "最美的不是下雨天，是你与其他高手一决高下的激情！",
}

local UICampaignPromotion = class("UICampaignPromotion", super, function() return kod.LoadCSBNode(csbPath) end)

function  UICampaignPromotion:ctor()
    super.ctor(self)
    self._animNode = nil;
    self._arrow = nil;
    self._processBar = nil
    
    -- bar
    self._listRank = nil
    self._rankModel = nil

    -- anim controller
    self._barAnimTask = nil
    self._centerAnimTask = nil
    self._processTarget = 0
    self._arrowTargetX = 0
    self._dotCloseMe = true
    self._isArrowJump = false
    self._csbAnim = nil
    self._animList = {}
end

function UICampaignPromotion:init()
    self._animNode = seekNodeByName(self, "Node_anim", "cc.Node")
    self._arrow = seekNodeByName(self, "arrow", "ccui.ImageView")
    self._rankModel = seekNodeByName(self, "Panel_Node", "ccui.Layout")
    self._listRank = seekNodeByName(self, "ListView_Rank", "ccui.ListView")
    self._noticeTips = seekNodeByName(self, "BG_topTips", "ccui.ImageView")

    self._processPanel = seekNodeByName(self, "Panel_progress", "ccui.Layout")
    self._processBar = seekNodeByName(self, "prograssBar", "ccui.LoadingBar")

    self._rankModel:setVisible(false)
    self._rankModel:removeFromParent()
    self._rankModel:retain()

    self._listRank:setScrollBarEnabled(false)

end

function UICampaignPromotion:onShow( ... )
    local args = { ... }
    local anim = args[1]
    self._isArrowJump = false

    self.arenaService = game.service.CampaignService.getInstance():getArenaService();
    local data = self.arenaService:getArenaCache()

    self.arenaService:addEventListener("ARENA_DATA_REFRESHED",    handler(self, self._dataRefreshed), self)
    self:stopAllActions()

    if self._csbAnim ~= nil then
        self._csbAnim:setVisible(false)
        self._csbAnim:removeFromParent(true)
        self._animNode:removeAllChildren(true)   
    end

    self:_dataRefreshed()    

    self._action = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._action)
    self._dotCloseMe = true

    -- 开一个计时器
    self._timerScheduler = scheduleOnce(
    function() 
        if self.arenaService == nil then 
            return 
        end
        local roomId = self.arenaService:getRoomId()
        if roomId ~= 0 then
            game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.Campaign,false)  
        end
        self.arenaService:setRoomId(0)
        self._dotCloseMe = false
    end, 3)
end

function UICampaignPromotion:onHide()
    if self._timerScheduler then
		unscheduleOnce(self._timerScheduler)
		self._timerScheduler = nil
    end  
    self._isArrowJump = false
    self:stopAllActions()
    table.foreach(self._animList, function(key, val)
        UI_ANIM.UIAnimManager:getInstance():delOneAnim(val)
    end)
    self._animList = {}
    
    if self._csbAnim ~= nil then
        self._csbAnim:setVisible(false)
        self._csbAnim:removeFromParent(true)
        self._animNode:removeAllChildren(true)
        self._csbAnim = nil
    end

    game.service.CampaignService.getInstance():getArenaService():removeEventListenersByTag(self);
end

function UICampaignPromotion:dispose()
    if self._rankModel ~= nil then
        self._rankModel:release()
        self._rankModel = nil
    end
end

function UICampaignPromotion:getDontCloseme()
    return self._dotCloseMe
end

-- 接收到数据变化
function UICampaignPromotion:_dataRefreshed()
    local data = self.arenaService:getArenaCache()
    if self._csbAnim ~= nil then
        self._animNode:removeAllChildren(true)  
    end

    table.foreach(self._animList, function(key, val)
        UI_ANIM.UIAnimManager:getInstance():delOneAnim(val)
    end)
    self._animList = {}

    if next(data) then
        self:createLoadingBar(data.round,self:getRecentRound(),data.configId)

        local text = self._noticeTips:getChildByName("Text_1")
        local innerText = NoticeText[math.random( 1,#NoticeText )] or ""
        text:setString(innerText)
        -- 控制要放什么动画
        if data.round == 1 then            
            self._csbAnim = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["READY"],true)
            -- 比赛名字
            local name = seekNodeByName(self._csbAnim, "BitmapFontLabel_1_1", "ccui.TextBMFont")
            name:setString(data.name)            
        elseif data.round == #self.arenaService:getArenaCache().rounds then
            self._csbAnim = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["FINALCAMPAIGN"],false)            
        else
            local node = CampaignAnimPlayer:getInstance():play1AndStay2(self._animNode, config.CampaignConfig.CampaignAnim["PROMOTION"], 1, false)
            local my = seekNodeByName(node, "BitmapFontLabel_1", "ccui.TextBMFont")
            local total = seekNodeByName(node, "BitmapFontLabel_1_0", "ccui.TextBMFont")
            local middle = seekNodeByName(node, "BitmapFontLabel_2", "ccui.TextBMFont")

            my:setString(data.rank)
            my:setAnchorPoint(cc.p(1,0.5))
            local totalNum = 0

            table.foreach(data.rounds,function (k,v)
                if v.count == data.round then
                    totalNum = v.playerCount
                end
            end)
            total:setString(totalNum)

            local delayTime = 1.5
            my:setScaleX(0.1)
            local delay = cc.DelayTime:create(delayTime)
            my:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 1.40, 1.40),
            cc.ScaleTo:create(0.06, 1.30, 1.30)
            ))

            total:setScaleX(0.1)
            total:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 0.9, 0.9),
            cc.ScaleTo:create(0.06, 0.8, 0.8)
            ))


            local x,y = self._animNode:getPosition()
            local widthDesigned,heightDesigned = display.width, display.height

            local wh = widthDesigned/heightDesigned

            if wh > 1.78 then
                self._animNode:setPosition(cc.p(widthDesigned/(2 + (wh - 1.7)*2), y))
            end

            self._csbAnim = node
        end
    end
end

-- 返回当前轮次所在的组
function UICampaignPromotion:getRecentRound()
    -- 5个一组 取当前round所在的组
    local cache = self.arenaService:getArenaCache()
    if next(cache) == nil then return {} end
    local group = math.floor((cache.round - 1) / 5)

    local result = {}

    -- 往前取2个 往后取2个， 前面的不够就后面的补，后面的不够就前面的补,补不了就空着
    local before = 0
    local after = 0
    
    if cache.round < 3 then
        after = 3 - cache.round
    end

    if #cache.rounds - cache.round < 2 then
        before = 2 - (#cache.rounds - cache.round)
    end

    for i = cache.round - 2 - before , cache.round + after + 2 do
        if cache.rounds[i] ~= nil then
            table.insert(result,cache.rounds[i])
        end
    end
    return result
end

-- 创建各个晋级人数的node
function UICampaignPromotion:createLoadingBar(current,stages,configId)
    table.sort(stages,function (a,b)
        return a.count < b.count
    end)
    self._listRank:removeAllChildren(false)
    local rewardInfo = ArenaConfig[configId] or {}

    -- 从aim-1 运动到 aim
    local aim = 1
    table.foreach(stages, function (k,v)
        local item = self._rankModel:clone()
        local isCurrent = v.count == current
        local beforeCurrent = v.count <= current
        item:setVisible(true)
        local animCircle = nil
        local hasLoading = item:getChildByName("hadLoading")
        local normalCb = item:getChildByName("CheckBox_A")
        local rankText = item:getChildByName("TextRank")
        local reward = item:getChildByName("rewardPanel")
        local rewardIcon = reward:getChildByName("rewardIcon")
        rankText:setString(v.playerCount)
 
        if rewardInfo[v.count] ~= nil and not beforeCurrent then
            reward:setVisible(true)
            rewardIcon:loadTexture(rewardInfo[v.count])

            local sequence = cc.Sequence:create(cc.MoveBy:create(0.8, cc.p(0, 10)), cc.MoveBy:create(0.8, cc.p(0, -10)))
            
            reward:runAction(cc.RepeatForever:create(sequence))
        else
            reward:setVisible(false)
        end

        self._listRank:addChild(item )
        
        if isCurrent then
            normalCb:setVisible(true)
            hasLoading:setVisible(false)
            animCircle = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect/Campaign/promotionCircle.csb", function()
            end, nil, nil, nil, nil, nil, normalCb,true))

            animCircle._csbAnim:setPosition(cc.p( 32.5, 32.5))
            table.insert(self._animList ,animCircle)
            aim = k
        else
            if v.count < current then
                normalCb:setVisible(false)
                hasLoading:setVisible(true)
            else
                normalCb:setVisible(true)
                hasLoading:setVisible(false)
            end
        end

        hasLoading:setTouchEnabled(false)
        normalCb:setTouchEnabled(false)
    end)
    self:_createCusorMove(aim)         
    self:_createProcessAnim(aim)
end
-----------------------------------------------------
-- 动画处理类
------------------------------------------------------
-- 进度条动画
-- 将整个进度条范围划为1 - 5个点，进度条从 begin 的点 运行到 end的点
function UICampaignPromotion:_createProcessAnim(target)
    local round = self.arenaService:getArenaCache().round
    local currentRound = target

    self._processBar:setPercent(10 + (currentRound-2) * 20)
    self._processTarget = (10 + (currentRound-1) * 20)
    
    local update = function (dt)
        self:_loadingBarUpdate(dt)
    end

    self._processPanel:scheduleUpdateWithPriorityLua(update, 0)
end

-- 光标移动动画
-- 光标移动动画
function UICampaignPromotion:_createCusorMove(target)
    local round = self.arenaService:getArenaCache().round
    local currentRound = target

    local posY = self._arrow:getPositionY()
    self._arrow:setPosition(107 + 224.6 * (currentRound - 2) ,posY)
    self._arrowTargetX = 107 + 224.6 * (currentRound - 1)
     
    local update = function (dt)
        self:_arrowUpdate(dt)
    end
    
    self._arrow:scheduleUpdateWithPriorityLua(update, 0)
end

-- 中间动画
function UICampaignPromotion:_addCenterAnim(anim,isLoop)
    local node = CampaignAnimPlayer:getInstance():play(self._animNode, anim, 0.8, isLoop)
    
    node:setName("anim")
    return node
end

function UICampaignPromotion:_loadingBarUpdate(dt)
    if self._processBar:getPercent() > self._processTarget then
        return
    end
    self._processBar:setPercent(self._processBar:getPercent() + 0.5)

    -- 更新粒子位置
    local particle = self._processBar:getChildByName("particle")
    local percent = self._processBar:getPercent()
    particle:setPositionPercent(cc.p(percent*0.01 + 0.01,0.5))
end

function UICampaignPromotion:_arrowUpdate(dt)
    if self._arrow:getPositionX() > self._arrowTargetX then
        if self._isArrowJump == false then
            local sequence = cc.Sequence:create(cc.MoveBy:create(0.8, cc.p(0, 10)), cc.MoveBy:create(0.8, cc.p(0, -10)))     
            self._arrow:runAction(cc.RepeatForever:create(sequence))
            self._isArrowJump = true
        end
        return
    end
    self._arrow:setPosition(self._arrow:getPositionX() + 10 , self._arrow:getPositionY())
end

-- 提取进入奖励圈的名次
function UICampaignPromotion:_generateRewardRank(rewards)
    if #rewards == 0 then return 0 end
    table.sort(rewards, function (a,b)
        return a.rank > b.rank
    end)
    return rewards[1].rank
end

---------------------------------------------------------------------------

function UICampaignPromotion:needBlackMask()
	return true;
end

function UICampaignPromotion:closeWhenClickMask()
	return false
end

function UICampaignPromotion:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignPromotion