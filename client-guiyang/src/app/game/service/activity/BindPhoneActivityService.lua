local super = require("app.game.service.activity.ActivityServiceBase")
local BindPhoneActivityService = class("BindPhoneActivityService", super)

function BindPhoneActivityService:initialize()
    self._prizeId = 0    --获奖物品id
    self._prizeCount = 0    --奖品数量
    self._enterGameShow = false     --每日首次进游戏展示 

    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCPhoneBindRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息
 
end

function BindPhoneActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end


function BindPhoneActivityService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

-- 申请活动信息
function BindPhoneActivityService:queryAcitivityInfo()
    net.NetworkRequest.new(net.protocol.CACPhoneBindREQ, self:getServerId()):setBuffer({
        area = game.service.LocalPlayerService:getInstance():getArea(),
    }):execute()
end

-- 接收活动信息
function BindPhoneActivityService:_onReceiveAcivityInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    self._prizeId = protocol.id
    self._prizeCount = protocol.count
    self:dispatchEvent({name = "EVENT_BINDPHONE_ACTIVITY_INFO"})
end

function BindPhoneActivityService:getPrizeStr()
    return self._prizeCount.."张".. PropReader.getNameById(self._prizeId)
end

function BindPhoneActivityService:getEnterShow()
    local bShow = self._enterGameShow;
    self._enterGameShow = true
    return bShow
end

return BindPhoneActivityService