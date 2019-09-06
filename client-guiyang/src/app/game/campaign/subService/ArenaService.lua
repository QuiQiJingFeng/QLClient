--[[
    @desc: 将Arena比赛相关协议交付到这个service里来
    author:{贺逸}
    time:2018-06-20
    return
]]
local ArenaService = class("ArenaService")
local Constants = require("app.gameMode.mahjong.core.Constants");

function ArenaService:ctor(pService)
    cc.bind(self, "event")
    self._campaignService = pService

    self._arenaCache = {}    -- arena缓存的相关信息
    self._roomId = 0         -- roomid缓存一下
end

function ArenaService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CACArenaInfoRES.OP_CODE, self, self.onCACArenaInfoRES)
    requestManager:registerResponseHandler(net.protocol.CACArenaPromotionSYN.OP_CODE, self, self.onArenaPromotionSYN)
end

function ArenaService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
	
	self._campaignService:removeEventListenersByTag(self)
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

function ArenaService:getArenaCache()
    return self._arenaCache
end

function ArenaService:getRoomId() return self._roomId end
function ArenaService:setRoomId(id) self._roomId = id end

function ArenaService:sendCCAArenaInfoREQ()
    local request = net.NetworkRequest.new(net.protocol.CCAArenaInfoREQ, self._campaignService._campaignServerId);
	game.util.RequestHelper.request(request);
end

function ArenaService:onCACArenaInfoRES( response )
    local protocol = response:getProtocol():getProtocolBuf()
    self._arenaCache = protocol
    self:dispatchEvent({name = "ARENA_DATA_REFRESHED"})
    if next(protocol) == nil then
        return
    end

   self:handleArenaStatus(protocol.status)
end

function ArenaService:onArenaPromotionSYN( response )
    local protocol = response:getProtocol():getProtocolBuf()
    if next(self._arenaCache) then
        self._arenaCache.round = protocol.round
        self._arenaCache.rank = protocol.rank

        if self:getIsRewardCircle() then
            -- 添加奖励圈动画
            self._campaignService._animCacheData:addAnim("PromotionReward",0)
        end

        if UIManager:getInstance():getIsShowing("UICampaignRoundReport") then
            UIManager:getInstance():getUI("UICampaignRoundReport"):setCallback(function ()
                UIManager:getInstance():show("UICampaignPromotion")
                self:dispatchEvent({name = "ARENA_DATA_REFRESHED"})
            end)
        else
            UIManager:getInstance():show("UICampaignPromotion")
            self:dispatchEvent({name = "ARENA_DATA_REFRESHED"})
        end
    end
end

function ArenaService:handleArenaStatus(status)
    -- 状态处理
    local status = status
    Logger.debug("arena Status =  " .. status)

    local showPromotion = function ()
        UIManager:getInstance():show("UICampaignPromotion")
        self:dispatchEvent({name = "ARENA_DATA_REFRESHED"})  
    end

    local notDisplayProm = UIManager:getInstance():getIsShowing("UICampaignPromotion") == false

    if status == config.CampaignConfig.CampaignPlayerStatus.MATCHING then
        scheduleOnce(function()
            if notDisplayProm == true then
                showPromotion() 
            end                   
        end,0)      

    elseif status == config.CampaignConfig.CampaignPlayerStatus.PLAYING then
        if game.service.RoomService:getInstance():getRoomId() == 0 then
            campaign.CampaignFSM.getInstance():enterState("CampaignState_InCampaignBattle");
            scheduleOnce(function()
                if UIManager:getInstance():getIsShowing("UICampaignRoundReport") then
                    -- 如果已经有了callback 则说明结算已经有callback了 不显示晋级页面
                    if UIManager:getInstance():getUI("UICampaignRoundReport"):getCallback() == nil then
                        UIManager:getInstance():getUI("UICampaignRoundReport"):setCallback(function ()
                            if UIManager:getInstance():getIsShowing("UInotDisplayPromts") == false and notDisplayProm == true then
                                showPromotion()
                            end
                        end)
                    end
                else
                    showPromotion()
                end          
            end,0)    
        else
            campaign.CampaignFSM.getInstance():enterState("CampaignState_InCampaignBattle");
        end
    elseif status == config.CampaignConfig.CampaignPlayerStatus.SIGN_UP then
        scheduleOnce(function()
            UIManager:getInstance():show("UICampaignPromotion")
        end,0)    

        self:dispatchEvent({name = "ARENA_DATA_REFRESHED"})
    end
end

-- 是否为最终局
function ArenaService:getIsFinal()
    if self._arenaCache.round ~= nil then
        if self._arenaCache.round == #self._arenaCache.rounds then
            return true
        end
    end
    return false
end

-- 是否在奖励圈
function ArenaService:getIsRewardCircle()
    if self._arenaCache.round ~= nil then
        local rewards = self._arenaCache.rewards
        table.sort(rewards,function (a,b)
            return a.rank > b.rank
        end)        
        local count = 999999
        table.foreach(self._arenaCache.rounds,function (k,v)
            if v.count == self._arenaCache.round then
                count =  v.playerCount
            end
        end)
        if rewards[#rewards] ~= nil and count == rewards[1].rank then
            return true
        end
    end
    return false
end

-- 当前前多少名晋级
function ArenaService:getPromotionNum()
    if self._arenaCache.round ~= nil then
        local result = 0
        table.foreach(self._arenaCache.rounds,function (k,v)
            if v.count == self._arenaCache.round + 1 then
                result =  v.playerCount
            end
        end)
        return result
    end
    return 0
end

function ArenaService:getCurrentRound()
    if self._arenaCache.round ~= nil then
        return self._arenaCache.round
    else
        return 0
    end
end

-- 清楚缓存
function ArenaService:clearArenaCache()
    self._arenaCache = {}
end

return ArenaService