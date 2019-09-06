--[[
    titile:2019春节邀新活动
    author:heyi
    time:2018-12-26
]]
local IdentityStatus = {
    Inviter = 1,    -- 邀请者
    Invitee = 2     -- 被邀请者
}

local super = namespace("app.game.service.activity.SpringInvitedService")

local SpringInvitedService = class("SpringInvitedService", super)

function SpringInvitedService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.ACCGodOfWealthInfoRES.OP_CODE, self, self._onACCGodOfWealthInfoRES)
    requestManager:registerResponseHandler(net.protocol.ACCGodOfWealthRecordRES.OP_CODE, self, self._onACCGodOfWealthRecordRES)
    requestManager:registerResponseHandler(net.protocol.ACCGodOfWealthOpenRES.OP_CODE, self, self._onACCGodOfWealthOpenRES)
    requestManager:registerResponseHandler(net.protocol.ACCGodOfWealthSYNC.OP_CODE, self, self._onACCGodOfWealthSYNC)

    self._popUpWindow = false
end

function SpringInvitedService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function SpringInvitedService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

function SpringInvitedService:getPopUpWindow()
    return self._popUpWindow
end

-- 请求拜财神活动信息
function SpringInvitedService:sendCACGodOfWealthInfoREQ()
    local request = net.NetworkRequest.new(net.protocol.CACGodOfWealthInfoREQ, self:getServerId())
    game.util.RequestHelper.request(request)
end

-- RES
function SpringInvitedService:_onACCGodOfWealthInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_GOD_OF_WEALTH_INFO_SUCCESS then
        self._popUpWindow = false
        if protocol.identity == IdentityStatus.Inviter then
            UIManager:getInstance():show("UISpringFestivalInvitedOld",protocol)
        elseif protocol.identity == IdentityStatus.Invitee then
            UIManager:getInstance():show("UISpringFestivalInvitedNew",protocol)
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求拜财神
function SpringInvitedService:sendCACGodOfWealthOpenREQ()
    local request = net.NetworkRequest.new(net.protocol.CACGodOfWealthOpenREQ, self:getServerId())
    game.util.RequestHelper.request(request)
end

-- RES
function SpringInvitedService:_onACCGodOfWealthOpenRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_GOD_OF_WEALTH_OPEN_SUCCESS then
        UIManager:getInstance():show("UISpringFestivalGetReward", protocol.rewards, protocol.open)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求拜财神记录
function SpringInvitedService:sendCACGodOfWealthRecordREQ()
    local request = net.NetworkRequest.new(net.protocol.CACGodOfWealthRecordREQ, self:getServerId())
    game.util.RequestHelper.request(request)
end

-- RES
function SpringInvitedService:_onACCGodOfWealthRecordRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_GOD_OF_WEALTH_RECORD_SUCCESS then
        UIManager:getInstance():show("UISpringFestivalMyGift", protocol.rewards)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

function SpringInvitedService:inviteFriend()
    local localPlayerService = game.service.LocalPlayerService:getInstance()
    local roleId = localPlayerService:getRoleId()
    local area = localPlayerService:getArea()
    local appid = "wx4330c6dd6db846dc"
    local activityId = net.protocol.activityType.COMEBACK
	
	-- 下载二维码
    local data =
    {
        enter = share.constants.ENTER.SPRING_INVITED,
        wxInfo = {
            redirectUrl = "http://agtzf.gzgy.majiang01.com/wechattools/bind_share",
            appId = "wx4330c6dd6db846dc",
            state = table.concat({ area, activityId, roleId}, "*"),
            pos = {x = 515, y = 162, scale = 0.7}
        },
        sourcePath = 'art/activity/caishen/inviteShare.jpg',
    }

    share.ShareWTF.getInstance():share(data.enter, { data }, function()
    end)
end

function SpringInvitedService:_onACCGodOfWealthSYNC(response)
    self._popUpWindow = true
end

return SpringInvitedService