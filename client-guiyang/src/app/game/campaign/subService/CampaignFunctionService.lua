--[[
    @desc: 将比赛本身功能相关协议放到这个service里来
    author:{贺逸}
    time:2019-03-05
    return
]]
--[[
    @desc: 将Arena比赛相关协议交付到这个service里来
    author:{贺逸}
    time:2018-06-20
    return
]]
local CampaignFunctionService = class("CampaignFunctionService")
local Constants = require("app.gameMode.mahjong.core.Constants");

function CampaignFunctionService:ctor(pService)
    cc.bind(self, "event")
    self._campaignService = pService
    self._currentTab = -1
end

function CampaignFunctionService:getCurrentTab()
    return self._currentTab
end

function CampaignFunctionService:setCurrentTab(value)
    self._currentTab = value
end

function CampaignFunctionService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CACCampaignHistoryRES.OP_CODE, self, self.onCACCampaignHistoryRES)
    requestManager:registerResponseHandler(net.protocol.CACHonorWallRES.OP_CODE, self, self.onQueryHonorWallRes)
    requestManager:registerResponseHandler(net.protocol.CACReceiveRewardRES.OP_CODE, self, self.onCACReceiveRewardRES)   
end

-- 比赛历史战绩请求CCACampaignHistoryREQ
function CampaignFunctionService:onCCACampaignHistoryREQ(clubId)
    local request = net.NetworkRequest.new(net.protocol.CCACampaignHistoryREQ, self._campaignService._campaignServerId);
    request:getProtocol():setData(clubId);
	game.util.RequestHelper.request(request);
end

-- 比赛历史战绩返回CACCampaignHistoryRES
function CampaignFunctionService:onCACCampaignHistoryRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    self._campaignService:dispatchEvent({name = "EVENT_CAMPAIGN_HISTORY_RECEIVED",data = protocol.results})
end

-- 请求荣誉墙列表
function CampaignFunctionService:onQueryHonorWall()
    local request = net.NetworkRequest.new(net.protocol.CCAHonorWallREQ, self._campaignService._campaignServerId);
	game.util.RequestHelper.request(request);
end

-- 荣誉墙返回
function CampaignFunctionService:onQueryHonorWallRes(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.mttHonor ~= nil then
        UIManager.getInstance():show("UICampaignHonorWall", protocol.mttHonor)
    end
end

-- 请求接受奖品
function CampaignFunctionService:onCCAReceiveRewardREQ(id , time)
    local request = net.NetworkRequest.new(net.protocol.CCAReceiveRewardREQ, self._campaignService._campaignServerId);
    request:getProtocol():setData(id, time);
    game.util.RequestHelper.request(request);
end

-- 接受奖品回复
function CampaignFunctionService:onCACReceiveRewardRES(response)
    local protocol = response:getProtocol():getProtocolBuf() 
    if protocol.result == net.ProtocolCode.CAC_RECEIVE_SUCCESS then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("领取奖励成功")  
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("领取失败")  
    end
end 


function CampaignFunctionService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
	
	self._campaignService:removeEventListenersByTag(self)
	
	-- 解绑事件系统
	cc.unbind(self, "event");
end

return CampaignFunctionService