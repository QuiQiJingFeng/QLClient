--[[
    @desc: 将自建赛相关协议交付到这个service里来
    author:{贺逸}
    time:2018-06-19
    return
]]
local SelfBuildCampaignService = class("SelfBuildCampaignService")

function SelfBuildCampaignService:ctor(pSevice)
    cc.bind(self, "event")
    self._campaignService = pSevice
end

function SelfBuildCampaignService:initialize()
    local requestManager = net.RequestManager.getInstance()

    -- 自建赛相关
    requestManager:registerResponseHandler(net.protocol.CACCampaignCreateListRES.OP_CODE, self, self.onCACCampaignCreateListRES)
    requestManager:registerResponseHandler(net.protocol.CACCampaignCreateRES.OP_CODE, self, self.onCACCampaignCreateRES)
    requestManager:registerResponseHandler(net.protocol.CACCampaignCancelRES.OP_CODE, self, self.onCACCampaignCancelRES)
    requestManager:registerResponseHandler(net.protocol.CACCampaignConfigRES.OP_CODE, self, self.onCACCampaignConfigRES)
    requestManager:registerResponseHandler(net.protocol.CACCampaignCreatePlayerRES.OP_CODE, self, self.onCACCampaignCreatePlayerRES)
end

function SelfBuildCampaignService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
	
	self._campaignService:removeEventListenersByTag(self)
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

-- 自建赛可以创建数据
function SelfBuildCampaignService:getGameSelfData()                      return self._gameCreateBySelfData end
-- 自建赛已创建数据
function SelfBuildCampaignService:getGameCreatedData()                   return self._gameCreatedData    end

-- 请求可以创建的自建赛列表
function SelfBuildCampaignService:onCampaignConfigREQ( areaId)
    local request = net.NetworkRequest.new(net.protocol.CCACampaignConfigREQ, self._campaignService._campaignServerId);
    request:getProtocol():setData(areaId);
	game.util.RequestHelper.request(request);
end

function SelfBuildCampaignService:onCACCampaignConfigRES( response )
    local protocol = response:getProtocol():getProtocolBuf()    
    self._gameCreateBySelfData = protocol.campaigns
    UIManager:getInstance():show("UICampaignCreate_Club" , protocol.campaigns)
end


-- 俱乐部经理创建赛事请求
function SelfBuildCampaignService:onCampaignCreateREQ( gameID , gameName , startTime, clubID )
    local request = net.NetworkRequest.new(net.protocol.CCACampaignCreateREQ, self._campaignService._campaignServerId);
	request:getProtocol():setData(gameID,gameName,startTime,clubID);
	game.util.RequestHelper.request(request);
end

-- 俱乐部创建请求返回
function SelfBuildCampaignService:onCACCampaignCreateRES( response )
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CAC_CREATE_SUCCESS then
        local clubID = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
        self:onCampaignCreateListREQ(clubID)    
        game.ui.UIMessageTipsMgr.getInstance():showTips("创建成功")    
        UIManager:getInstance():destroy("UICampaignCreateConfirm_Club")
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 经理请求解散赛事
function SelfBuildCampaignService:onCCACampaignCancelREQ(gameID,clubId)
    local request = net.NetworkRequest.new(net.protocol.CCACampaignCancelREQ, self._campaignService._campaignServerId);
	request:getProtocol():setData(gameID,clubId);
	game.util.RequestHelper.request(request);
end

-- 解散请求回复
function SelfBuildCampaignService:onCACCampaignCancelRES( response )
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CAC_CANCEL_SUCCESS then
        local clubID = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
        self:onCampaignCreateListREQ(clubID)
        game.ui.UIMessageTipsMgr.getInstance():showTips("解散成功")
        UIManager:getInstance():destroy("UICampaignDetail_Club")
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 查看当前麻将馆所有的自建赛
--  clubID   当前麻将馆ID
function SelfBuildCampaignService:onCampaignCreateListREQ( clubID )
    local request = net.NetworkRequest.new(net.protocol.CCACampaignCreateListREQ, self._campaignService._campaignServerId);
	request:getProtocol():setData(clubID);
	game.util.RequestHelper.request(request);
end

--  已创建自建赛
function SelfBuildCampaignService:onCACCampaignCreateListRES( response )
    local protocol = response:getProtocol():getProtocolBuf()
    self._gameCreatedData = protocol.campaigns
    self._gameCreatedData.campaignId = protocol.campaignId
    self._campaignService:dispatchEvent({name = "EVENT_CLUBCAMPAIGN_REFRESH", data = {
        campaigns = self._gameCreatedData,
        campaignId = self._gameCreatedData.campaignId
        }
    })    
end

-- 查看指定Id的自建赛排名结果
function SelfBuildCampaignService:onCampaignCreatePlayerREQ( gameID )
    local request = net.NetworkRequest.new(net.protocol.CCACampaignCreatePlayerREQ, self._campaignService._campaignServerId);
	request:getProtocol():setData(gameID);
	game.util.RequestHelper.request(request);
end

-- 自建赛排名结果返回
function SelfBuildCampaignService:onCACCampaignCreatePlayerRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    UIManager:getInstance():show("UICampaignResult_Club", protocol.players)
end

function SelfBuildCampaignService:_signUp()
    self._campaignService:_signUp()
end

function SelfBuildCampaignService:_signUpCancle()
    self._campaignService:_signUpCancle()
end

return SelfBuildCampaignService