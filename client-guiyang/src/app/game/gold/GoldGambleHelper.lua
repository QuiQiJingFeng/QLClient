local UtilsFunctions = require("app.game.util.UtilsFunctions")
local M = UtilsFunctions.singleton(class("GoldGambleHelper"))

function M:ctor()
    self._currentBetGambleId = -1
    cc.bind(self, "event")
    self._gambleInfo = {}

    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.GOCNotifyGoldGambleInfoSYN.OP_CODE, self, self._onGOCNotifyGoldGambleInfoSYN)
    requestManager:registerResponseHandler(net.protocol.GOCQueryGoldGambleInfoRES.OP_CODE, self, self._onGOCQueryGoldGambleInfoRES)
    requestManager:registerResponseHandler(net.protocol.GOCSelectGoldGambleRES.OP_CODE, self, self._onGOCSelectGoldGambleRES)
    requestManager:registerResponseHandler(net.protocol.GOCCancelGoldGambleRES.OP_CODE, self, self._onGOCCancelGoldGambleRES)

    -- 开始对局了， 再发送请求次局的所有下注相关信息
    -- 没有取消，因为单例
    listenGlobalEvent("EVENT_BATTLE_GAME_STARTED", handler(self, self._onEventBattleGameStarted))
    listenGlobalEvent("EVENT_BATTLE_GAME_ENDED", handler(self, self._onEventBattleGameEnded))
end

-- 推送猜金币活动状态
function M:_onGOCNotifyGoldGambleInfoSYN(response)
    local buffer = response:getBuffer()
    local uiGoldGamble = UIManager:getInstance():getUI("UIGoldGamble")
    if uiGoldGamble == nil then
        uiGoldGamble = UIManager:getInstance():show("UIGoldGamble", self._gambleInfo)
    end
    self:dispatchEvent({ name = "EVENT_GOLD_GAMBLE_LAST_GUESS_RESULT", data = buffer })
end

-- 请求金币场赌注信息， 每次开场后请求下
function M:sendCGOQueryGoldGambleInfoREQ()
    local roomType = game.service.LocalPlayerService.getInstance():getCurrentRoomType()
    if roomType == game.globalConst.roomType.gold then
        net.NetworkRequest.new(net.protocol.CGOQueryGoldGambleInfoREQ, game.service.GoldService.getInstance():getServerId()):setBuffer({
            roomId = game.service.RoomService.getInstance():getRoomId()
        }):execute()
    end
end

-- 返回金币场赌注信息
function M:_onGOCQueryGoldGambleInfoRES(response)
    -- 没有配置，忽略
    if response:getResultCode() == net.ProtocolCode.GO_C_SELECT_GOLD_GAMBLE_FAILED_NO_CONFIG then
        return 
    end
    if response:isSuccessful() then
        local buffer = response:getBuffer()
        self._gambleInfo = buffer
        UIManager.getInstance():show("UIGoldGamble", self._gambleInfo)
    else
        response:tipResultString()
    end
end

-- 请求选择下注
function M:sendCGOSelectGoldGambleREQ(gambleId, goldAmount, roundCount)
    net.NetworkRequest.new(net.protocol.CGOSelectGoldGambleREQ, game.service.GoldService.getInstance():getServerId()):setBuffer({
        gambleId = gambleId,
        selectAmount = goldAmount,
        selectRoundCount = roundCount,
    }):execute()
    self._currentBetGambleId = gambleId
end

-- 应答下注结果
function M:_onGOCSelectGoldGambleRES(response)
    if response:isSuccessful() then
        -- 成功了就获取一次新的数据
        self:sendCGOQueryGoldGambleInfoREQ()
    else
        response:tipResultString()
    end

    self:dispatchEvent({
        name = "EVENT_GOLD_GAMBLE_BET_RESULT",
        data =    {
            ok = response:isSuccessful(),
            info = self:getGambleInfoById(self._currentBetGambleId)
        }
    })
end

-- 请求撤销下局赌注
function M:sendCGOCancelGoldGambleREQ()
    net.NetworkRequest.new(net.protocol.CGOCancelGoldGambleREQ, game.service.GoldService.getInstance():getServerId()):execute()
end

-- 应答撤销赌注的结果
function M:_onGOCCancelGoldGambleRES(response)
    if response:isSuccessful() then
        -- 成功了就获取一次新的数据
        self:sendCGOQueryGoldGambleInfoREQ()
    else
        response:tipResultString()
    end
    self:dispatchEvent({ name = "EVENT_GOLD_GAMBLE_CANCEL_BET_RESULT", data = { ok = response:isSuccessful() } })
end

function M:_onEventBattleGameStarted(event)
    self:sendCGOQueryGoldGambleInfoREQ()
end

function M:_onEventBattleGameEnded(event)
    UIManager:getInstance():hide("UIGoldGamble")
end

function M:getGambleInfoById(id)
    if self._gambleInfo then
        local list = rawget(self._gambleInfo, "selectGambleInfos") or {}
        table.insert(list, rawget(self._gambleInfo, "nextGambleInfo"))
        table.insert(list, rawget(self._gambleInfo, "curGambleInfo"))

        for index, info in ipairs(list) do
            if id == info.id then
                return info
            end
        end
    end
end

return M