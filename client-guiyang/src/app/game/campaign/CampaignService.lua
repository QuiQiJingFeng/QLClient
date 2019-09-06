--[[
    比赛service
        网络消息驱动状态机
        监听状态机的事件，当发生改变时，转发给ui
]] --

--[[
    EVENT_CAMPAIGN_DATA_RECEIVED                        -- 比赛列表整体更新通知
    EVENT_CAMPAIGN_DATA_CHANGED                         -- 比赛列表变化通知
    EVENT_CAMPAIGN_RANK_CHANGED                         -- 玩家排名变化通知
    EVENT_CAMPAIGN_HISTORY_RECEIVED                     -- 俱乐部自建赛历史战绩推送
    EVENT_CLUBCAMPAIGN_REFRESH                          -- 俱乐部比赛数据推送
    EVENT_PLAY_CAMPAIGN_CACHE_ANIM                      -- 播放比赛开始缓存的动画
]]
local ns = namespace("game.service")
local Constants = require("app.gameMode.mahjong.core.Constants");
local CampaignList = require("app.game.campaign.DataStruct.CampaignList");
local CampaignData = require("app.game.campaign.DataStruct.CampaignData");
local CampaignAnimController = require("app.game.campaign.utils.CampaignAnimController");
local LocalStorageCampaignData = require("app.game.campaign.DataStruct.LocalStorageCampaignData");
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")

-- subService
local SelfBuildService = require("app.game.campaign.subService.SelfBuildCampaignService")
local ArenaService = require("app.game.campaign.subService.ArenaService")
local CampaignFunctionService = require("app.game.campaign.subService.CampaignFunctionService")

local CampaignService = class("CampaignService")
ns.CampaignService = CampaignService

---------------------------------
-- CampaignService
function CampaignService:getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getCampaignService()
    end

    return nil
end

function CampaignService:ctor()
    -- 绑定事件系统
    cc.bind(self, "event");

    self._campaignServerId = -1
    
    self._campaignList = CampaignList.new()                     -- 比赛列表

    -- TODO:将这些信息封装成一个data类
    self._campaignData = CampaignData.new()                     -- 玩家所在比赛的数据

    self._animCacheData = CampaignAnimController.new()          -- 玩家比赛牌局开始时需要播放的动画缓存

    self._daliFlag = false                                      -- 是否打立赛等待状态

    self._campaignSharedId = 0                                                    -- 分享所点击对应的比赛Id
    self._localStorageCampaignData = LocalStorageCampaignData.new()               -- 本地缓存的比赛信息       

    self._gameCreateBySelfData = {}                                                -- 自建赛创建列表数据
    self._gameCreatedData = {}                                                      -- 当前麻将馆所有已创建赛事数据

    self._selfbuildService = SelfBuildService.new(self)
    self._arenaService = ArenaService.new(self)
    self._campaignFunctionService = CampaignFunctionService.new(self)

    self._stateMachine = campaign.CampaignFSM.getInstance()
    
    self._stateMachine:addEventListener("CAMPAIGN_STATE_CHANGING", handler(self, self._onStateChanging), self)
    self._stateMachine:addEventListener("CAMPAIGN_STATE_CHANGED", handler(self, self._onStateChanged), self)
    self:addEventListener("CAMPAIGN_SHOW_WAIT", handler(self, self._waitToShowWaitWindow), self)  
    self:addEventListener("ON_POPUP_NEWPLAYER_GUIDE", handler(self, self._popCampaignGuide), self)
    self:addEventListener("EVENT_PLAY_CAMPAIGN_CACHE_ANIM", handler(self, self._playCacheAnim), self)  
end

function CampaignService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CACFocusOnCampaignListRES.OP_CODE, self, self.onCACFocusOnCampaignListRES)
    requestManager:registerResponseHandler(net.protocol.CACNotifyCampaignListSYN.OP_CODE, self, self.onCACNotifyCampaignListSYN)
    requestManager:registerResponseHandler(net.protocol.CACPlayerStatusRES.OP_CODE, self, self.onCACPlayerStatusRES)
    requestManager:registerResponseHandler(net.protocol.CACPlayerStatusSYN.OP_CODE, self, self.onCACPlayerStatusSYN)
    requestManager:registerResponseHandler(net.protocol.CACSignUpRES.OP_CODE, self, self.onCACSignUpRES)
    requestManager:registerResponseHandler(net.protocol.CACSignUpCancelRES.OP_CODE, self, self.onCACSignUpCancelRES)
    requestManager:registerResponseHandler(net.protocol.CACRankChangeSYN.OP_CODE, self, self.onCACRankChangeSYN)
    requestManager:registerResponseHandler(net.protocol.CACPromotionSYN.OP_CODE, self, self.onCACPromotionSYN)
    requestManager:registerResponseHandler(net.protocol.CACGiveUpRES.OP_CODE, self, self.onCACGiveUpRES)
    requestManager:registerResponseHandler(net.protocol.CACResultSYN.OP_CODE, self, self.onCACResultSYN)
    
    requestManager:registerResponseHandler(net.protocol.CACEnterRoomSYN.OP_CODE, self, self.onCACEnterRoomSYN)
    requestManager:registerResponseHandler(net.protocol.CACMttPrepareSYN.OP_CODE, self, self.onCACMttPrepareSYN)
    
    requestManager:registerResponseHandler(net.protocol.CACRoundInfoRES.OP_CODE, self, self.onCACRoundInfoRES)
    requestManager:registerResponseHandler(net.protocol.CACRaiseLinePreSYN.OP_CODE, self, self.onCACRaiseLinePreSYN) 
    requestManager:registerResponseHandler(net.protocol.CACRaiseLineSYN.OP_CODE, self, self.onCACRaiseLineSYN)    
    requestManager:registerResponseHandler(net.protocol.CACDaLiPromotionSYN.OP_CODE, self, self.onCACDaLiPromotionSYN)
    requestManager:registerResponseHandler(net.protocol.CACRoleMissMttSYN.OP_CODE, self, self.onCACRoleMissMttSYN)   

    -- sub service init
    self._selfbuildService:initialize()
    self._arenaService:initialize()
    self._campaignFunctionService:initialize()

    -- 状态机
    self._stateMachine:enterState("CampaignState_NotSignUp");   
    self:loadLocalStorage()
end

function CampaignService:_onStateChanging( event )
    -- 转发state正在转变
    self:dispatchEvent({name = "CAMPAIGN_STATE_CHANGING", old = event.old, current = event.current})
end

function CampaignService:_onStateChanged( event )
    -- 转发state的变化
    self:dispatchEvent({name = "CAMPAIGN_STATE_CHANGED", current = event.current})
end

-- 播放缓存的动画
function CampaignService:_playCacheAnim()
    self._animCacheData:playCacheAnim()
end

--是否打立赛等待状态
function CampaignService:getDaliWaitFlag() 					    return self._daliFlag; end
function CampaignService:setDaliWaitFlag(value) 				self._daliFlag = value; end

function CampaignService:setId(campaignServerId)                self._campaignServerId = campaignServerId;end
function CampaignService:getId()                                return self._campaignServerId;end

-- 获取到的玩家当前比赛数据
function CampaignService:getCampaignData()                      return self._campaignData end

-- 获取到的比赛列表数据
function CampaignService:getCampaignList()                      return self._campaignList end

-- 玩家所分享的比赛id
function CampaignService:setShareCampaignId(value)              self._campaignSharedId = value; end
function CampaignService:getShareCampaignId()                   return self._campaignSharedId; end
function CampaignService:getLocalStorage()                      return self._localStorageCampaignData end

-- 请求比赛列表CCAFocusOnCampaignListREQ
function CampaignService:sendCCAFocusOnCampaignListREQ(type, tabId)
    local request = net.NetworkRequest.new(net.protocol.CCAFocusOnCampaignListREQ, self._campaignServerId);
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
	request:getProtocol():setData(type, areaId);
    request.tabId = tabId or 1
	game.util.RequestHelper.request(request);
end

-- 比赛列表返回CAFocusOnCampaignListRES 
function CampaignService:onCACFocusOnCampaignListRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest():getProtocol():getProtocolBuf()
    if not UIManager:getInstance():getIsShowing("UICampaignMain") and request.optype == game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST then
        UIManager:getInstance():show("UICampaignMain", response:getRequest().tabId)
    end 
    
    if protocol.result == net.ProtocolCode.CAC_FOCUS_ON_CAMPAIGN_LIST_SUCCESS then 
        -- 请求成功
        self._campaignList:removeAllCampaign()

        for _,campaignItem in ipairs(protocol.campaignList.campaignList) do
            self._campaignList:addCampaign(campaignItem)
        end

        self._campaignList:setCampaignTabs(protocol.tabInfo)

        if protocol.campaignList.signUpInfoList ~= nil then
            self._campaignList:setSignUpCampaignList(protocol.campaignList.signUpInfoList)
        end
        self:dispatchEvent({name = "EVENT_CAMPAIGN_DATA_RECEIVED", data = self._campaignList})
        self:dispatchEvent({name = "EVENT_CAMPAIGN_RECEIVE_FLAG", receiveFlag = protocol.receiveFlag})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 比赛列表同步CACNotifyCampaignListSYN
function CampaignService:onCACNotifyCampaignListSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()

    local newCampaigns = {} 
    local deleteCampaigns = {}

    -- 更新列表
    self._campaignList:updateCampaignList(protocol.campaignList)

    if protocol.signUpInfoList ~= nil then
        self._campaignList:setSignUpCampaignList(protocol.signUpInfoList)
    end
    
    self:dispatchEvent({name = "EVENT_CAMPAIGN_DATA_CHANGED", data = self._campaignList})

    -- 如果不在比赛列表界面则取消关注
    if UIManager:getInstance():getIsShowing("UICampaignMain") == false then
        self:sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.STOP_WATCH_CAMPAIGN_LIST)
    end
end

-- 请求玩家比赛状态CCAPlayerStatusREQ
function CampaignService:sendCCAPlayerStatusREQ()
    if self._campaignList:getCurrentCampaignId() == 0 then 
        return 
    end
    local request = net.NetworkRequest.new(net.protocol.CCAPlayerStatusREQ, self._campaignServerId);
	request:getProtocol():setData(self._campaignList:getCurrentCampaignId());
	game.util.RequestHelper.request(request);
end

-- 玩家比赛状态返回CACPlayerStatusRES
-- todo:这两方法可以封装成一个函数去调用
function CampaignService:onCACPlayerStatusRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local campaignId = response:getRequest():getProtocol():getProtocolBuf().campaignId   
    self:handleCampaignPlayerStatus(protocol.status, false, campaignId)
end

-- 玩家比赛状态同步CACPlayerStatusSYN
function CampaignService:onCACPlayerStatusSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local campaignId = protocol.campaignId
    self:handleCampaignPlayerStatus(protocol.status, true, campaignId)
end

-- 对状态消息进行处理
function CampaignService:handleCampaignPlayerStatus( status, isSyn, campaignId)
    -- 等待
    if status == config.CampaignConfig.CampaignPlayerStatus.WAITING then
        self._stateMachine:enterState("CampaignState_InCampaignWait");
            UIManager:getInstance():show("UICampaignWait")
    -- 正在比赛
    elseif status == config.CampaignConfig.CampaignPlayerStatus.MATCHING then
        if campaign.CampaignFSM.getInstance():getCurrentState():getIsInBattle() == false then
            UIManager:getInstance():show("UICampaignWaitToStart")            
        end
    elseif status == config.CampaignConfig.CampaignPlayerStatus.PLAYING then
        if game.service.RoomService:getInstance():getRoomId() == 0 then
            UIManager:getInstance():show("UICampaignWait")
        end
        self._stateMachine:enterState("CampaignState_InCampaignBattle");
    -- 比赛开始
    elseif status == config.CampaignConfig.CampaignPlayerStatus.START then
        if campaign.CampaignFSM.getInstance():getCurrentState():getIsInBattle()  == false then
            UIManager:getInstance():show("UICampaignWaitToStart") 
        end
    -- 停赛
    elseif status == config.CampaignConfig.CampaignPlayerStatus.STOP then
        if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() ~= true then
            if game.service.TimeService:getInstance():getCurrentTimeInMSeconds() > self._campaignList:getMttStartTime() -10000 and self._campaignList:getCurrentCampaignId() ~=  campaignId then
                game.ui.UIMessageBoxMgr.getInstance():show("由于开赛玩家不足，本场比赛未能顺利开赛，请关注后续比赛，感谢您的参与。", {"确认"},function()
                    --返回大厅  
                    self._campaignList:setMttStartTime(0)
                    end)
            else
                game.ui.UIMessageBoxMgr.getInstance():show("比赛暂时关闭，报名费已退还，敬请期待下次开启", {"确认"},function()
                    --返回大厅
                    campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")        
                    GameFSM.getInstance():enterState("GameState_Lobby");
                    end)
            end
        end

    -- 报名
    elseif status == config.CampaignConfig.CampaignPlayerStatus.SIGN_UP then
        campaign.CampaignFSM.getInstance():enterState("CampaignState_SignUp")
    -- 未报名
    elseif status == config.CampaignConfig.CampaignPlayerStatus.EXIT then
        campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
    end
end

function CampaignService:_waitToShowWaitWindow()
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() and UIManager:getInstance():getIsShowing("UICampaignResults") == false then
        self:setDaliWaitFlag(true)
        scheduleOnce(function()
            if self:getDaliWaitFlag() == true and UIManager:getInstance():getIsShowing("UICampaignResults") == false and 
                UIManager:getInstance():getIsShowing("UIMain") == false and game.service.RoomService:getInstance():getRoomId() == 0 then
                    local campaignId = self:getCampaignList():getCurrentCampaignId()
                    if campaignId ~= config.CampaignConfig.ARENA_ID then
                        UIManager:getInstance():show("UICampaignWait")
                    else
                        self._arenaService:sendCCAArenaInfoREQ()
                    end
            end
        end, 7)
    end
end

-- 报名请求CCASignUpREQ
function CampaignService:sendCCASignUpREQ(campaignId, configId, key)
    if CampaignUtils.forbidenMsgMtt() == false then    
        local request = net.NetworkRequest.new(net.protocol.CCASignUpREQ, self._campaignServerId);
        request:getProtocol():setData(campaignId, configId, key);
        game.util.RequestHelper.request(request);
    end
end

-- 返回报名结果CACSignUpRES
function CampaignService:onCACSignUpRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest():getProtocol():getProtocolBuf()
    local signupCampaignId = protocol.campaignId    
    local signupConfigId = protocol.configId
    local signUpCampaign = self._campaignList:getCampaignByConfigId(signupConfigId)
    -- 若成功则切换状态
    if protocol.result == net.ProtocolCode.CAC_SIGN_UP_SUCCESS then
        -- 判断是不是自建赛页面，要走自己的报名流程
        if UIManager:getInstance():getIsShowing("UIClubActivityMain") then
            local clubID = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
            game.ui.UIMessageTipsMgr.getInstance():showTips("报名成功，您仍可以参加其他比赛或牌局")
            self._selfbuildService:onCampaignCreateListREQ(clubID)
            self:dispatchEvent({name = "EVENT_CAMPAIGNSELFBUILD_SIGNUP", id = signupCampaignId}) 
            return
        end

        local tips = ""
        tips = tips .. self._campaignList:getCostName(protocol.cost, request.key)

        -- 设置为已报名,如果是MTT则改变mttStartTime        
        if signUpCampaign and signUpCampaign.isMtt then
            self._campaignList:setMttStartTime(signUpCampaign.createTimestamp)
            self._campaignList:addToSignUpCampaignList(signupConfigId)
            tips = tips .. "报名成功，您仍可以参加其他比赛或牌局"       
        else
            campaign.CampaignFSM.getInstance():enterState("CampaignState_SignUp")            
            self._campaignList:setCurrentCampaignId(signupCampaignId)
            self._campaignList:addToSignUpCampaignList(signupConfigId)
            tips = tips .. "报名成功"             
        end

        -- 如果是延时报名，则弹出匹配中
        if signUpCampaign ~= nil and signUpCampaign.enterTime ~= 0 and signUpCampaign.enterTime > game.service.TimeService:getInstance():getCurrentTimeInMSeconds() and 
             signUpCampaign.createTimestamp < game.service.TimeService:getInstance():getCurrentTimeInMSeconds() then
            UIManager:getInstance():show("UICampaignWait")
            self._campaignList:setCurrentCampaignId(signupCampaignId)
            self._campaignList:addToSignUpCampaignList(signupConfigId)
            tips = ""  
        end

        -- 如果是arena 则走arena流程
        if signupCampaignId == config.CampaignConfig.ARENA_ID then
            UIManager:getInstance():show("UICampaignPromotion")
            game.service.CampaignService.getInstance():getArenaService():clearArenaCache()
            self._arenaService:sendCCAArenaInfoREQ()
        end

        if tips ~= "" and signupCampaignId ~= config.CampaignConfig.ARENA_ID then
            game.ui.UIMessageTipsMgr.getInstance():showTips(tips)
        end

        self:dispatchEvent({name = "EVENT_CAMPAIGN_DATA_CHANGED", data = self._campaignList})
    elseif protocol.result == net.ProtocolCode.CAC_SIGN_UP_NO_CARD then
        self:feeNotEnoughProcessor( signUpCampaign.cost, request.key, protocol.key, signupCampaignId, signupConfigId)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end  
end

function CampaignService:feeNotEnoughProcessor( costs, requestKey, recommendedKey,  campaignId, configId)
    local CurrencyHelper = require("app.game.util.CurrencyHelper")

    local cost = self._campaignList:getCostByKey(costs,requestKey)
    if recommendedKey ~= 0 then
        local recommend = self._campaignList:getCostByKey(costs,recommendedKey)

        if cost.id == nil or recommend == nil then
            game.ui.UIMessageTipsMgr.getInstance():showTips("报名费不足")
            return
        end 

        local tips = ""
        if PropReader.getTypeById(recommend.id) ==  "GameMoney" then
            tips = PropReader.getNameById(cost.id) .. "不足,是否用金豆X" .. recommend.count .. "兑换门票并报名？"
        else
            tips = PropReader.getNameById(cost.id) .. "不足,是否使用" .. PropReader.getNameById(recommend.id) .."X" .. recommend.count .. "报名？"            
        end        
        game.ui.UIMessageBoxMgr.getInstance():show(tips, {"报名","取消"},function()
            self:sendCCASignUpREQ(campaignId,configId, recommendedKey)
        end)
    else
        -- 如果有金豆，则充值金豆兑换门票，如果没配金豆在世界弹报名费不足
        local beanIndex = 0
        for i,v in pairs(costs) do
            if PropReader.getTypeById(v.item.id) == "GameMoney" then
                beanIndex = i
            end
        end
        if beanIndex == 0 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("报名费不足")
        else
            local tips = PropReader.getNameById(cost.id) .. "不足,是否充值"
            game.ui.UIMessageBoxMgr.getInstance():show(tips, {"前去充值","取消"},function()
                CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.BEAN)
                game.service.MallService:setPurchaseCallback(function ()
                    self:sendCCASignUpREQ(campaignId,configId, costs[beanIndex].item.key)
                end)
            end)
        end
        return
    end
end

-- 请求取消报名CCASignUpCancelREQ
function CampaignService:sendCCASignUpCancelREQ(campaignId)
    local request = net.NetworkRequest.new(net.protocol.CCASignUpCancelREQ, self._campaignServerId);
	request:getProtocol():setData(campaignId);
	game.util.RequestHelper.request(request);
end

-- 取消报名结果CACSignUpCancelRES
function CampaignService:onCACSignUpCancelRES(response)
    local protocol = response:getProtocol():getProtocolBuf()    
    local signupCampaignId = response:getRequest():getProtocol():getProtocolBuf().campaignId
    local signupConfignId = protocol.configId
    if protocol.result == net.ProtocolCode.CAC_SIGN_UP_CANCEL_SUCCESS then

        -- 判断是不是自建赛页面，要走自己的流程
        if UIManager:getInstance():getIsShowing("UIClubActivityMain") then
            local clubID = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
            game.ui.UIMessageTipsMgr.getInstance():showTips("取消报名")  
            self._campaignList:setMttStartTime(0)
            self._campaignList:setCurrentCampaignId(0)
            self._campaignList:removeFromSignUpCampaignList(signupCampaignId)     
            self._selfbuildService:onCampaignCreateListREQ(clubID)
            self:dispatchEvent({name = "EVENT_CAMPAIGNSELFBUILD_CANCLED", id = signupCampaignId})             
            return
        end

        -- 设置为已报名,如果是MTT则改变mttStartTime
        local signUpCampaign = self._campaignList:getCampaignByConfigId(signupConfignId)
        if signUpCampaign and signUpCampaign.isMtt then
            self._campaignList:setMttStartTime(0)
            self._campaignList:removeFromSignUpCampaignList(signupConfignId)            
        else
            self._campaignList:setCurrentCampaignId(0)
            self._campaignList:setMttStartTime(0)
            self._campaignList:removeFromSignUpCampaignList(signupConfignId)            
            campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")                     
        end
        game.ui.UIMessageTipsMgr.getInstance():showTips("取消报名")     

        self:dispatchEvent({name = "EVENT_CAMPAIGN_DATA_CHANGED", data = self._campaignList}) 
    else 
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 放弃比赛请求CCAGiveUpREQ
function CampaignService:sendCCAGiveUpREQ()
    if self._campaignList:getCurrentCampaignId() ~= 0 then    
        local request = net.NetworkRequest.new(net.protocol.CCAGiveUpREQ, self._campaignServerId);
        request:getProtocol():setData(self._campaignList:getCurrentCampaignId());
        game.util.RequestHelper.request(request);
    end
end

-- 放弃比赛结果CACGiveUpRES
function CampaignService:onCACGiveUpRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CAC_GIVE_UP_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("放弃成功")
    elseif protocol.result == net.ProtocolCode.CAC_GIVE_UP_FULL_MEMBER then
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    else
        UIManager:getInstance():hide("UICampaignWait")
        campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))      
    end
end

function CampaignService:dispose()
    self._selfbuildService:dispose()
    self._arenaService:dispose()
    self._campaignFunctionService:dispose()

    net.RequestManager.getInstance():unregisterResponseHandler(self);
    self._stateMachine:removeEventListenersByTag(self)
    self._stateMachine:removeEventListenersByTag(self)
    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- get各种service
function CampaignService:getSelfbuildService()
    return self._selfbuildService
end

function CampaignService:getArenaService()
    return self._arenaService
end

function CampaignService:getCampaignFunctionService()
    return self._campaignFunctionService
end

function CampaignService:getAnimCache()
    return self._animCacheData
end

--玩家比赛房间同步CACEnterRoomSYN
function CampaignService:onCACEnterRoomSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local roomId = protocol.roomId
    local campaignId = protocol.campaignId
    local name = protocol.name
    self._campaignList:setCurrentCampaignId(campaignId)
    self._campaignData:setCampaignName(name)

    -- 往里添加各种开局动画
    self._animCacheData:addAnim("CampaignStart",1)

    -- 重置分数
    self._campaignData:resetData()
    self:setDaliWaitFlag(false)
    UIManager:getInstance():hide("UICampaignWait")

    -- 如果是arena则添加播放晋级动画，如果在显示结算页面就显示完结算再请求进房间
    if campaignId == config.CampaignConfig.ARENA_ID  then
        if UIManager:getInstance():getIsShowing("UICampaignPromotion") == true and 
            UIManager:getInstance():getUI("UICampaignPromotion"):getDontCloseme() or UIManager:getInstance():getIsShowing("UICampaignRoundReport") then
            self._arenaService:setRoomId(roomId)
        else
            -- 进入房间
            game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.Campaign,false)  
        end
    else
        -- 进入房间
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.Campaign,false)  
    end

    -- 切换状态机
    self._stateMachine:enterState("CampaignState_InCampaignBattle")

    -- 设置晋级玩家数量
    self:getCampaignData():setNextPlayerCount(protocol.count)
    self:getCampaignData():setPlayerCount(protocol.totalCount)
    self:dispatchEvent({name = "EVENT_CAMPAIGN_RANK_CHANGED"})
end

-- 排名变化同步CACRankChangeSYN
function CampaignService:onCACRankChangeSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    self._campaignData:updateData(protocol.rank, protocol.round, self._campaignData:getMultiple(), protocol.playerCount, 
        protocol.nextPlayerCount, protocol.totalPoint, protocol.roomCount, protocol.thisPlayerCount,protocol.daLiFlag)
    self._campaignData:setCampaignName(protocol.name)
    self:dispatchEvent({name = "EVENT_CAMPAIGN_RANK_CHANGED"})
end

-- 晋级通知同步CACPromotionSYN
function CampaignService:onCACPromotionSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local result = protocol.promotionFlag
     -- 需要在显示单据战绩后再显示晋升结果动画
     if result == true then
    end
end

-- 玩家奖状同步(单局战绩)CACResultSYN
function CampaignService:onCACResultSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()

    -- 如果是退赛则直接回比赛场
    if protocol.result.isGiveUp then
        campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")        
        GameFSM.getInstance():enterState("GameState_Lobby");
        self:sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
        return
    end

    -- 重置分数
    self._campaignData:resetData()
    if UIManager:getInstance():getIsShowing("UICampaignRoundReport") then
        UIManager:getInstance():getUI("UICampaignRoundReport"):setCallback(function ()
            UIManager:getInstance():show("UICampaignResults", protocol, "campaign")    
        end)
    else
        UIManager:getInstance():show("UICampaignResults", protocol, "campaign")    
    end
end

-- MTT 同步比赛准备
function CampaignService:onCACMttPrepareSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    game.ui.UIMessageBoxMgr.getInstance():show("即将开赛，请在游戏内等待", {"确定"})
    -- 将mtt开赛时间重置为3分钟后
    if self._campaignList:getCurrentCampaignId() == 0 then
        self._campaignList:setCurrentCampaignId(protocol.id)
    end
    self._campaignList:setMttStartTime(game.service.TimeService:getInstance():getCurrentTimeInMSeconds() + 180000)
end

-- 本轮详情请求
function CampaignService:onQueryRoundInfo()
    local request = net.NetworkRequest.new(net.protocol.CCARoundInfoREQ, self._campaignServerId);
    request:getProtocol():setData(self._campaignList:getCurrentCampaignId());
	game.util.RequestHelper.request(request);
end

-- 本轮详情返回
function CampaignService:onCACRoundInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    UIManager:getInstance():show("UICampaignRoundDetail", protocol) 
end

-- 打立赛提高淘汰线预警
function CampaignService:onCACRaiseLinePreSYN()
    -- UIManager:getInstance():show("UITopTipsAnim", "30秒后提高淘汰线") 
end

-- 打立赛提高淘汰线
function CampaignService:onCACRaiseLineSYN( response )
    -- local protocol = response:getProtocol():getProtocolBuf()
    -- UIManager:getInstance():show("UITopTipsAnim", "当前淘汰线为".. protocol.score .."分，积分倍数为".. protocol.multiple .."倍") 
end

-- 打立赛晋级同步
function CampaignService:onCACDaLiPromotionSYN()
    UIManager:getInstance():show("UITopTipsAnim", "当前淘汰人数已满，结束当前比赛后进入下一轮比赛") 
end

-- 开赛提示报名参赛
function CampaignService:onCACRoleMissMttSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()    
    if protocol.enterTime > game.service.TimeService:getInstance():getCurrentTimeInMSeconds() then            
        scheduleOnce(function()
            local state = GameFSM.getInstance():getCurrentState().class.__cname
            if state ~= nil and (state == "GameState_Lobby") then
                self:sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.STOP_WATCH_CAMPAIGN_LIST)
                UIManager:getInstance():show("UICampaignStartTip", protocol) 
            end
        end, 1)
    else            
        scheduleOnce(function()
            game.ui.UIMessageTipsMgr.getInstance():showTips("加入比赛时间已结束，请期待下次比赛")
        end, 1)
    end
end

-- 添加保存玩家分享赛分享状态
function CampaignService:addCampaignShareFreeRecord(id)
    self._localStorageCampaignData:addCampaignShareListItem(id)
    self:saveLocalStorage()
end

function CampaignService:_popCampaignGuide()
    self._localStorageCampaignData:setNotPopCampaignGuide(true)
    self:saveLocalStorage()
end

-- 获取玩家比赛分享状态
function CampaignService:getCampaignShareFreeRecord(id)
    return self._localStorageCampaignData:getCampaignShareStatus(id)
end

function CampaignService:loadLocalStorage()
    self._localStorageCampaignData = manager.LocalStorage.getUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "LocalStorageCampaignData", LocalStorageCampaignData);
end

function CampaignService:saveLocalStorage()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    manager.LocalStorage.setUserData(roleId,"LocalStorageCampaignData", self._localStorageCampaignData)
end