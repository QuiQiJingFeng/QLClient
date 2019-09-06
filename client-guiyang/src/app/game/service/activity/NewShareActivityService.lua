local super = require("app.game.service.activity.ActivityServiceBase")
local NewShareActivityService = class("NewShareActivityService", super)

function NewShareActivityService:initialize()
    self._rewardIndex = 1
    self._allPlayers = {}

    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCShareActivityInfoRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息
    requestManager:registerResponseHandler(net.protocol.ACCReceiveShareActivityRewardRES.OP_CODE, self, self._onReceiveRewardInfo); --次数信息
end

function NewShareActivityService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function NewShareActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 申请活动信息
function NewShareActivityService:queryAcitivityInfo()
    net.NetworkRequest.new(net.protocol.CACShareActivityInfoREQ, self:getServerId()):execute()
end

-- 接收活动信息
function NewShareActivityService:_onReceiveAcivityInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    dump(protocol, "_onReceiveAcivityInfo")
    if response:isSuccessful() then
        self:setAllPlayers(protocol.progresses)
        self:setActivityProgress(protocol.rewardProgress)
        self:dispatchEvent({name = "EVENT_ACTIVITY_INFO"})
    end
end

-- 申请奖励信息
function NewShareActivityService:queryRewardInfo(roleId, rewardIdx)
    net.NetworkRequest.new(net.protocol.CACReceiveShareActivityRewardREQ, self:getServerId()):setBuffer({
        roleId = roleId,
        rewardProgress = config.NewShareConfig.rawardProgress[rewardIdx],
    }):execute()
end

-- 接收奖励信息
function NewShareActivityService:_onReceiveRewardInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    dump(protocol, "_onReceiveRewardInfo")
    if response:isSuccessful() then
        self:setRewardInfo(protocol.roleId, protocol.rewardProgress)
        self:dispatchEvent({name = "EVENT_AWARD_INFO", roleId = protocol.roleId})
    end
end

function NewShareActivityService:setAllPlayers(players)
    self._allPlayers = players
    table.sort(self._allPlayers, function(p1, p2)
        if #p1.rewardProgress == 4 and #p2.rewardProgress < 4 then
            return false
        elseif #p1.rewardProgress < 4 and #p2.rewardProgress == 4 then
            return true
        end
        return p1.roundCount > p2.roundCount
    end)
end
function NewShareActivityService:getAllPlayers()
    return self._allPlayers
end

--设置抽奖成功消息
function NewShareActivityService:setRewardInfo(roleId, idx)
    self._rewardIndex = idx
    self._rewardRole = roleId
    for _,player in ipairs(self._allPlayers) do
        if player.roleId == roleId then
            print("player.rewardProgress..",player.rewardProgress)
            if player.rewardProgress == nil or #player.rewardProgress < 1 then
                player.rewardProgress = {idx}
            else
                table.insert(player.rewardProgress,idx)
            end
        end
    end
end

function NewShareActivityService:getPlayerById(roleId)
    for _,player in ipairs(self._allPlayers) do
        if player.roleId == roleId then
            return player
        end
    end
    return nil
end

function NewShareActivityService:getRewardIndex()
    for i = 1,4 do 
        if config.NewShareConfig.rawardProgress[i] == self._rewardIndex then
            return i
        end
    end
end

function NewShareActivityService:setActivityProgress(rewardProgress)
    config.NewShareConfig.rawardProgress = rewardProgress
end
return NewShareActivityService