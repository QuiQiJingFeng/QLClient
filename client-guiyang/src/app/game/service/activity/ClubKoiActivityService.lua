local super = require("app.game.service.activity.ActivityServiceBase")
local ClubKoiActivityService = class("ClubKoiActivityService", super)

-- 俱乐部锦鲤活动

function ClubKoiActivityService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.ACCQueryKoiFishActivityInfoRES.OP_CODE, self, self._onACCQueryKoiFishActivityInfoRES)
    requestManager:registerResponseHandler(net.protocol.ACCPickKoiFishActivityAwardRES.OP_CODE, self, self._onACCPickKoiFishActivityAwardRES)
end

function ClubKoiActivityService:dispose()
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function ClubKoiActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

function ClubKoiActivityService:getAreaId()
    return game.service.LocalPlayerService:getInstance():getArea()
end

-- 查询锦鲤活动数据
function ClubKoiActivityService:sendCACQueryKoiFishActivityInfoREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACQueryKoiFishActivityInfoREQ, self:getServerId()):setBuffer(buffer):execute()
end

function ClubKoiActivityService:_onACCQueryKoiFishActivityInfoRES(response)
    if response:checkIsSuccessful() then
        if UIManager:getInstance():getIsShowing("UIClubActivityKoi") then
            UIManager:getInstance():destroy("UIClubActivityKoi")
        end
        UIManager:getInstance():show("UIClubActivityKoi", response:getBuffer())
    end
end

-- 领取锦鲤活动奖励
function ClubKoiActivityService:sendCACPickKoiFishActivityAwardREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACPickKoiFishActivityAwardREQ, self:getServerId()):setBuffer(buffer):execute()
end

function ClubKoiActivityService:_onACCPickKoiFishActivityAwardRES(response)
    if response:checkIsSuccessful() then
        game.ui.UIMessageTipsMgr.getInstance():showTips("领取成功！")
        self:sendCACQueryKoiFishActivityInfoREQ({area = self.getAreaId()})
    end
end

return ClubKoiActivityService