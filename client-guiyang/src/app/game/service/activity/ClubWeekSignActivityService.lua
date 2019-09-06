local super = require("app.game.service.activity.ActivityServiceBase")
local ClubWeekSignActivityService = class("ClubWeekSignActivityService", super)


function ClubWeekSignActivityService:initialize()
	local requestManager = net.RequestManager.getInstance()
	
	requestManager:registerResponseHandler(net.protocol.ACCQueryClubWeekSignInfoRES.OP_CODE, self, self._onACCQueryClubWeekSignInfoRES)
	requestManager:registerResponseHandler(net.protocol.ACCSelectClubWeekRewardPackageRES.OP_CODE, self, self._onACCSelectClubWeekRewardPackageRES)
    requestManager:registerResponseHandler(net.protocol.ACCPickClubWeekSignRewardRES.OP_CODE, self, self._onACCPickClubWeekSignRewardRES)
end

function ClubWeekSignActivityService:dispose()
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function ClubWeekSignActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

function ClubWeekSignActivityService:getAreaId()
    return game.service.LocalPlayerService:getInstance():getArea()
end

-- 请求查询俱乐部七日签到活动信息
function ClubWeekSignActivityService:sendCACQueryClubWeekSignInfoREQ()
    local request = net.NetworkRequest.new(net.protocol.CACQueryClubWeekSignInfoREQ, self:getServerId())
    request:getProtocol():setData(self:getAreaId())
	game.util.RequestHelper.request(request)
end

function ClubWeekSignActivityService:_onACCQueryClubWeekSignInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_QUERY_CLUB_WEEK_SIGN_INFO_SUCCESS then
        local ui = "UIClubRetainSign"
        if protocol.rewardPackages ~= nil and #protocol.rewardPackages > 0 then
            ui = "UIClubRetainBlessing"
        end
        if UIManager:getInstance():getIsShowing("UIClubRetainBlessing") then
            UIManager:getInstance():hide("UIClubRetainBlessing")
        end
        if UIManager:getInstance():getIsShowing("UIClubRetainSign") then
            UIManager:getInstance():hide("UIClubRetainSign")
        end

        UIManager:getInstance():show(ui, protocol)

        if #protocol.signInfos > 0 then
            local time = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
            if time > protocol.signInfos[1].vaildDate and time < protocol.signInfos[2].vaildDate then
                game.service.LocalPushService:getInstance():addOtherPush("clubSignPush")
            end
        end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 发送祈福礼包
function ClubWeekSignActivityService:sendCACSelectClubWeekRewardPackageREQ(packageId)
    local request = net.NetworkRequest.new(net.protocol.CACSelectClubWeekRewardPackageREQ, self:getServerId())
    request:getProtocol():setData(self:getAreaId(), packageId)
	game.util.RequestHelper.request(request)
end

function ClubWeekSignActivityService:_onACCSelectClubWeekRewardPackageRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_SELECT_CLUB_WEEK_REWARD_PACKAGE_SUCCESS then
        self:sendCACQueryClubWeekSignInfoREQ()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求领取签到奖励
function ClubWeekSignActivityService:sendCACPickClubWeekSignRewardREQ(day)
    local request = net.NetworkRequest.new(net.protocol.CACPickClubWeekSignRewardREQ, self:getServerId())
    request:getProtocol():setData(self:getAreaId(), day)
	game.util.RequestHelper.request(request)
end

function ClubWeekSignActivityService:_onACCPickClubWeekSignRewardRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_PICK_CLUB_WEEK_SIGN_REWARD_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("专属奖励领取成功")
        self:sendCACQueryClubWeekSignInfoREQ()

        local rPro = request:getProtocol():getProtocolBuf()
        if rPro.day == 7 then
            game.service.LocalPushService:getInstance():removeOtherPush("clubSignPush")
        end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

return ClubWeekSignActivityService