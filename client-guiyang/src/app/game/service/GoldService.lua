local CurrencyHelper = require("app.game.util.CurrencyHelper")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local GoldQuickChargeHelper = require("app.game.gold.GoldQuickChargeHelper")
local GoldGambleHelper = require("app.game.gold.GoldGambleHelper")
local Enum_RoomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade
local UI_ANIM = require("app.manager.UIAnimManager")
-- 金币场本地缓存相关
local GoldCache = class("GoldCache")

local saveKey = "GoldCache"
function GoldCache:ctor()
    --玩家上次的选择
    self.lastSelectRoomGrade = 0
    --玩家实际进入的房间(快速匹配客户端不知道实际进入的需要记录服务器)
    self.currentRoomGrade = 0
    self.lastPromptDate = ""
    -- 剩余的大牌分享有礼次数
    self.remainShareLargeHuTimes = 0
    -- 是否有未发送的分享请求
    self.hasShareReqUnSend = false
end

local ROOM_NAME = {
    [Enum_RoomGrade.FIRST] = "普通场",
    [Enum_RoomGrade.SECOND] = "豪华场",
    [Enum_RoomGrade.THIRD] = "尊贵场",
    [Enum_RoomGrade.FOUR] = "雀神场",
    [Enum_RoomGrade.QUICK] = "快速场"
}

--[[    如果是直接重连去了牌桌，关于金币场的其他信息会不真实（但是roomGrade不会影响），roomGrade存储在RoomService中
]]
local ns = namespace("game.service")
local GoldService = class("GoldService")
ns.GoldService = GoldService

function GoldService.getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getGoldService()
    end
    return nil
end

function GoldService:ctor()
    -- 绑定事件系统
    cc.bind(self, "event");

    -- 是否在匹配中
    self.isInGoldMatch = false
    -- 金币场相关数据缓存
    -- 房间信息
    self.dataRoomInfo = nil
    -- 救助金信息
    self.brokeHelpInfo = nil
    self._goldCache = GoldCache.new()
    -- 缓存礼券的奖励信息(此信息仅供结算用,每进入新的房间,需从新赋值)
    self.giftCache = nil

    self._currentConvertGoldVersion = 0
    -- 大牌分享的数据，因为状态机切换会导致UI被删除，把数据放到service中保存
    self.shareData = {}

    -- 限时玩家相关
    self._currentGameplay = nil
    self._limitGameplay = nil

    self.chargeHelper = GoldQuickChargeHelper.getInstance()
end

function GoldService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    -- 解绑事件系统
    cc.unbind(self, "event")
    self.isInGoldMatch = false
    self.dataRoomInfo = nil

    self:removeEventListenersByTag(self)
    game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
    if self._battleStartListener then
        unlistenGlobalEvent(self._battleStartListener)
        self._battleStartListener = nil
    end
end

function GoldService:getCurrentGameplay()
    return self._currentGameplay
end

function GoldService:getLimitGameplay()
    return self._limitGameplay
end

function GoldService:getServerId()
    return self._goldServerId
end

function GoldService:getQuickChargeHelper()
    return GoldQuickChargeHelper.getInstance()
end

function GoldService:getGambleHelper()
    return GoldGambleHelper.getInstance()
end

--设置玩家上次的选择的金币场
function GoldService:setlastSelectRoomGrade(roomGrade)
    self._goldCache.lastSelectRoomGrade = roomGrade

    self:saveData()
end
--设置玩家实际进入的金币场
function GoldService:setCurrentRoomGrade(roomGrade)
    self._goldCache.currentRoomGrade = roomGrade

    self:dispatchEvent({ name = "EVENT_GOLD_ROOM_GRADE_CHANGED", data = { roomGrade = roomGrade } })
    self:saveData()
end

-- 获取上次选中的房间等级， 可能是 快速匹配
function GoldService:getlastSelectRoomGrade()
    return self._goldCache.lastSelectRoomGrade
end

-- 获取上一次实际进入的房间等级， 不可能是 快速匹配
function GoldService:getCurrentRoomGrade()
    return self._goldCache.currentRoomGrade
end

function GoldService:getRemainShareLargeHuTimes()
    return self._goldCache.remainShareLargeHuTimes
end

function GoldService:setRemainShareLargeHuTimes(value)
    self._goldCache.remainShareLargeHuTimes = value
    self:saveData()
end

function GoldService:setShareData(data)
    self.shareData = data
end

function GoldService:getShareData()
    return self.shareData
end

function GoldService:setId(goldServerId)
    self._goldServerId = goldServerId
end
--存储金币场的本地缓存
function GoldService:saveData()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    manager.LocalStorage.setUserData(roleId, saveKey, self._goldCache)
end
--读取金币场的本地缓存
function GoldService:loadLocalStorage()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    self._goldCache = manager.LocalStorage.getUserData(roleId, saveKey, GoldCache)
end

--检查是否需要并且能够领取破产补助
function GoldService:checkIsNeedBrokeHelp()
    if not self.dataRoomInfo then
        return false
    end
    local goldAmount = game.service.LocalPlayerService.getInstance():getGoldAmount()
    local roomInfo = self:getRoomInfo(Enum_RoomGrade.FIRST)
    local brokeInfo = self:getBrokeHelpInfo()
    if roomInfo ~= nil and brokeInfo ~= nil then
        return roomInfo.minGold > goldAmount and brokeInfo.usedBrokeHelpNum < brokeInfo.maxBrokeHelpNum
    else
        return false
    end
end
--[[    领取金币的特效部分,0是救助的特效不要音效
]]
function GoldService:playComingGoldEffect(costBean)

    local type = 0
    if costBean == 0 then
        type = 0
    elseif costBean < 50 then
        type = 1
    elseif costBean < 400 then
        type = 2
    else
        type = 3
    end

    UI_ANIM.UIAnimManager:getInstance():onShow({
        _path = string.format("ui/csb/Gold/Effect_Money%d.csb", type),
        _parent = UIManager.getInstance():getTopMostLayer()
    })
    --救助的金币不要音效
    if type ~= 0 then
        manager.AudioManager.getInstance():playEffect("sound/SFX/money.mp3")
    end
end

function GoldService:getRoomName(roomGrade)
    return ROOM_NAME[roomGrade]
end

function GoldService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.GOCQueryGoldInfoRES.OP_CODE, self, self._onGOCQueryGoldInfoRES)


    requestManager:registerResponseHandler(net.protocol.GoldCBrokeHelpRES.OP_CODE, self, self._onGoldCBrokeHelpRES)

    requestManager:registerResponseHandler(net.protocol.GoldCMatchRES.OP_CODE, self, self._onGoldCMatchRES)
    requestManager:registerResponseHandler(net.protocol.GoldCMatchResultSYN.OP_CODE, self, self._onGoldCMatchResultSYN)

    requestManager:registerResponseHandler(net.protocol.GoldCCancelMatchRES.OP_CODE, self, self._onGoldCCancelMatchRES)

    requestManager:registerResponseHandler(net.protocol.GoldCBattleForMallPointInfoRES.OP_CODE, self, self._onGoldCBattleForMallPointInfoRES)
    requestManager:registerResponseHandler(net.protocol.GoldCRewardMallPointSYN.OP_CODE, self, self._onGoldCRewardMallPointSYN)
    requestManager:registerResponseHandler(net.protocol.GOCPickWXShareRewardRES.OP_CODE, self, self._onGOCPickWXShareRewardRES)

    requestManager:registerResponseHandler(net.protocol.GOCBrokenHelpSYN.OP_CODE, self, self._onGOCBrokenHelpSYN)
    requestManager:registerResponseHandler(net.protocol.GOCQueryRoleRoomGradeRES.OP_CODE, self, self.onGOCQueryRoleRoomGradeRES)

    -- self._globalListenerTag = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onAppWillEnterForeground))
    --监听匹配开始,因为很多界面都有开始的位置所以放到sevice来监听
    self:addEventListener("EVENT_GOLD_MATCH_START", handler(self, self._onMatchStart), self)
    --监听进入房间信息来重置礼券奖励的数据	
    game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ENTER_ROOM", handler(self, self._onEventEnterRoom), self)
    game.service.LoginService.getInstance():addEventListener("EVENT_USER_LOGIN_SUCCESS", handler(self, self._onEventUserLoginSuccess), self)

    game.service.LocalPlayerService.getInstance():addEventListener("EVENT_GOLD_COUNT_CHANGED", handler(self, self.refreshLocalBattlePlayerGoldAmount), self)
    self._battleStartListener = listenGlobalEvent("EVENT_BATTLE_GAME_STARTED", handler(self, self.refreshLocalBattlePlayerGoldAmount))
    self.gambleHelper = GoldGambleHelper.getInstance()
end

--[[    开始匹配了,显示匹配界面
]]
function GoldService:_onMatchStart(event)
    self:setCurrentRoomGrade(event.roomGrade)
    UIManager.getInstance():show("UIGoldMatch", event.roomGrade)
end

-- 发送请求金币场房间数据
function GoldService:sendCGOQueryGoldInfoREQ()
    net.NetworkRequest.new(net.protocol.CGOQueryGoldInfoREQ, self._goldServerId):execute()
end

--登陆后金币场房间数据的推送
function GoldService:_onGOCQueryGoldInfoRES(response)
    if response:checkIsSuccessful() then
        local buffer = response:getBuffer()
        self.dataRoomInfo = {}
        self.dataRoomInfo.goldRooms = {}
        self:setRemainShareLargeHuTimes(buffer.remainShareTimes)
        self.brokeHelpInfo = buffer.brokeHelp
        
        for k, v in ipairs(buffer.gradeRoomConfigs) do
            self.dataRoomInfo.goldRooms[v.grade] = v
        end
        self._currentGameplay = rawget(buffer, "curGamePlays")
        self._limitGameplay = rawget(buffer, "limitGamePlays")
        self:dispatchEvent({ name = "EVENT_GOLD_ROOM_INFO_RECEIVE" })
    end
end

-- 领取破产补助（救助金）
function GoldService:sendCGoldBrokeHelpREQ()
    local req = net.NetworkRequest.new(net.protocol.CGoldBrokeHelpREQ, self._goldServerId)
    game.util.RequestHelper.request(req)
end

function GoldService:_onGoldCBrokeHelpRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GOLD_C_BROKE_HELP_SUCCESS then
        self.brokeHelpInfo = protocol.brokeHelp

        self:playComingGoldEffect(0)
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end

end

-- 尝试开始匹配请求,如果不满足条件则进行弹窗等处理
function GoldService:trySendCGoldMatchREQ(roomGrade)
    local goldAmount = game.service.LocalPlayerService.getInstance():getGoldAmount()
    --如果本地没有房间相关数据直接请求,由服务器判断结果
    if Macro.assetTrue(not self.dataRoomInfo, "客户端没有对应金币房间数据,请保证服务器正确的推送") then
        self:sendCGoldMatchREQ(roomGrade)
        return
    end

    -- local isNeedBrokeHelp = self:checkIsNeedBrokeHelp()
    -- -- 如果需要破产补助就弹窗提示领取
    -- if isNeedBrokeHelp then
    --     UIManager.getInstance():show("UIGoldBrokeHelp")
    --     return
    -- end
    --获取当前房间最低进入标准,如果是快速匹配则获取最低标准
    -- local minLimit = self.dataRoomInfo.goldRooms[roomGrade] and self.dataRoomInfo.goldRooms[roomGrade].minGold or self.dataRoomInfo.goldRooms[Enum_RoomGrade.FIRST].minGold
    -- --小于最低限定提示兑换金币
    -- if goldAmount < minLimit then
    --     --打开兑换金币界面
    --     game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow("您的金币不够哦~\n先兑换点金币再战斗吧!", { "兑换金币", "取消" }, function()
    --         -- UIManager.getInstance():show("UIShopNew", "gold")
    --         game.service.GoldService.getInstance():sendCGoldConvertDataREQ()
    --     end)
    --     return
    -- end
    --获取当前房间最大标准提示,如果是快速则是-1
    local maxLimit = self.dataRoomInfo.goldRooms[roomGrade] and self.dataRoomInfo.goldRooms[roomGrade].maxGold or -1
    --获取本次时间标准
    local time = game.service.TimeService:getInstance():getCurrentTime()
    local currentDate = os.date("%x", time)
    --大于最高限度提示换房并且今天没有提示过
    if goldAmount > maxLimit and maxLimit ~= -1 then
        game.ui.UIMessageBoxMgr.getInstance():show(
        config.STRING.UIGOLD_MAIN_GOLD_TOOMUCH_100,
        { "确定" },
        function()
            self:sendCGoldMatchREQ(self:_getFitRoomGradeWhenGoldIsTooMany(roomGrade))
        end,
        function()
        end,
        false,
        true)
        return
    end

    self:sendCGoldMatchREQ(roomGrade)
end

--当金币过多时检查最适合的匹配房间
function GoldService:_getFitRoomGradeWhenGoldIsTooMany(roomGrade)
    local goldAmount = game.service.LocalPlayerService.getInstance():getGoldAmount()
    for roomGrade = roomGrade, Enum_RoomGrade.THIRD do
        if self.dataRoomInfo.goldRooms[roomGrade].tipGold > goldAmount or self.dataRoomInfo.goldRooms[roomGrade].tipGold == -1 then
            return roomGrade
        end
    end
    return Enum_RoomGrade.QUICK
end

-- 开始匹配请求
function GoldService:sendCGoldMatchREQ(roomGrade)
    local req = net.NetworkRequest.new(net.protocol.CGoldMatchREQ, self._goldServerId)
    req:getProtocol():setData(roomGrade)
    game.util.RequestHelper.request(req)

    self:setlastSelectRoomGrade(roomGrade)
end

--开始匹配的回调
function GoldService:_onGoldCMatchRES(response)
    local protocol = response:getProtocol():getProtocolBuf()

    if protocol.result == net.ProtocolCode.GOLD_C_MATCH_SUCCESS then
        self.isInGoldMatch = true
        --进入匹配成功的事件
        self:dispatchEvent({ name = "EVENT_GOLD_MATCH_START", roomGrade = protocol.roomGrade })
    elseif protocol.result == net.ProtocolCode.GOLD_C_MATCH_FAIL_GOLD_LESS_ROOM_MIN_GOLD then
        -- 金币不足不提示
    else
        -- 在比赛中等情况提示
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end

end

--匹配到人的推送
function GoldService:_onGoldCMatchResultSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local result = protocol.result == net.ProtocolCode.GOLD_C_MATCH_SUCCESS
    if result then
        -- start to enter room 如果是重连，会走game的逻辑，这里不需要处理
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(protocol.roomId, game.globalConst.JOIN_ROOM_STYLE.Gold, false)
        self:setCurrentRoomGrade(protocol.roomGrade)
    else
        -- 匹配失败所以取消
        self:dispatchEvent({ name = "EVENT_GOLD_MATCH_CANCEL" })
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
    self.isInGoldMatch = false

    -- self:dispatchEvent({name = "EVENT_GOLD_MATCH_RESULT", result = result})
end

--请求取消匹配
function GoldService:sendCGoldCancelMatchREQ()
    local req = net.NetworkRequest.new(net.protocol.CGoldCancelMatchREQ, self._goldServerId)
    game.util.RequestHelper.request(req)
end

--请求取消匹配的回调
function GoldService:_onGoldCCancelMatchRES(response)
    local protocol = response:getProtocol():getProtocolBuf()

    if protocol.result == net.ProtocolCode.GOLD_C_CANCEL_MATCH_SUCCESS then

    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
    -- 匹配取消事件
    self:dispatchEvent({ name = "EVENT_GOLD_MATCH_CANCEL" })
end


function GoldService:sendCGoldBattleForMallPointInfoREQ()
    local req = net.NetworkRequest.new(net.protocol.CGoldBattleForMallPointInfoREQ, self._goldServerId)
    game.util.RequestHelper.request(req)
end

--打牌送礼券信息
function GoldService:_onGoldCBattleForMallPointInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GOLD_C_BATTLE_FOR_MALL_POINT_INFO_SUCCESS then
        -- 打牌领取礼券的信息
        self.giftCache = {}
        self.giftCache.needRoundNextMallPoint = protocol.needRoundNextMallPoint
        self.giftCache.rewardMallPoint = protocol.rewardMallPoint

        self:dispatchEvent({ name = "EVENT_GOLD_GIFT_INFO_RECEIVE", protocol = protocol })
    else
        self.giftCache = nil
    end
end

--客户端领取礼券消息
function GoldService:_onGoldCRewardMallPointSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- 获得打牌领取礼券奖励
    self:dispatchEvent({ name = "EVENT_GOLD_BATTLE_REWARD_GIFT_RECEIVE", protocol = protocol })
end

-- 延时发送分享的请求
function GoldService:delaySendShareRequest()
    self._goldCache.hasShareReqUnSend = true
    self:saveData()

    -- ios设备直接设定时间请求
    if device.platform == "ios" then
        scheduleOnce(function()
            self:sendShareRequestIfNeed()
        end, 5)
    end
end

function GoldService:_onEventUserLoginSuccess()
    UIManager:getInstance():hide("UIGoldShareRoundResult_ShareNode")
    scheduleOnce(function()
        self:sendShareRequestIfNeed()
    end, 1)
end

function GoldService:_onEventEnterRoom(event)
    if game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
        self:sendCGoldBattleForMallPointInfoREQ()
        self:sendCGOQueryRoleRoomGradeREQ()
    end
end

function GoldService:sendCGOQueryRoleRoomGradeREQ()
    net.NetworkRequest.new(net.protocol.CGOQueryRoleRoomGradeREQ, self:getServerId()):execute()
end

function GoldService:onGOCQueryRoleRoomGradeRES(response)
    if response:isSuccessful() then
        self:setCurrentRoomGrade(response:getBuffer().roomGrade)
    else
        response:tipResultString()
    end
end

function GoldService:sendShareRequestIfNeed()
    if self._goldCache.hasShareReqUnSend then
        self._goldCache.hasShareReqUnSend = false
        self:saveData()
        self:sendCGOPickWXShareRewardREQ()
    end
end

-- 发送大牌分享请求，以前的消息是  GoldC 或者 CGold ，以后要改为 GOC 或者 CGO
function GoldService:sendCGOPickWXShareRewardREQ()
    -- 再检测下次数
    if Macro.assertFalse(self._goldCache.remainShareLargeHuTimes > 0, 'remain times should more than 0') then
        self:setRemainShareLargeHuTimes(self._goldCache.remainShareLargeHuTimes - 1)
        local req = net.NetworkRequest.new(net.protocol.CGOPickWXShareRewardREQ, self._goldServerId)
        game.util.RequestHelper.request(req)
    end
end

-- 大牌分享响应
function GoldService:_onGOCPickWXShareRewardRES(resp)
    local protocol = resp:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GO_C_PICK_WX_SHARE_REWARD_SUCCESS then
        UIManager:getInstance():show("UIGoldShareRoundResultTips")
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

function GoldService:getCurrentConvertGoldVersion()
    return self._currentConvertGoldVersion
end

function GoldService:_onGOCBrokenHelpSYN(response)
    local buffer = response:getProtocol():getProtocolBuf()
    self.dataRoomInfo.brokeHelp = {
        maxBrokeHelpNum = buffer.maxBrokeHelpNum,
        usedBrokeHelpNum = buffer.usedBrokeHelpNum,
        helpGoldAmount = buffer.helpGoldAmount,
    }
end

function GoldService:refreshLocalBattlePlayerGoldAmount(event)
    local isWatcher = game.service.LocalPlayerService.getInstance():isWatcher()
    local isGoldBattle = game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold
    local gameContext = gameMode.mahjong.Context.getInstance()
    if not isWatcher and isGoldBattle and gameContext ~= nil then
        local gameService = gameContext:getGameService()
        if gameService ~= nil then
            local down = gameService:getPlayerProcessorByChair(CardDefines.Chair.Down)
            if down then
                local roomSeat = down:getRoomSeat()
                if roomSeat then
                    local goldAmount = CurrencyHelper.getInstance():getCurrencyCount(CurrencyHelper.CURRENCY_TYPE.GOLD)
                    roomSeat:getSeatUI():setTotalScore(goldAmount)
                end
            end
        end
    end
end

function GoldService:getRoomInfo(grade)
    if grade == nil then
        return nil
    end

    if self.dataRoomInfo == nil then
        return nil
    end

    return self.dataRoomInfo.goldRooms[grade]
end

function GoldService:getBrokeHelpInfo()
    return self.brokeHelpInfo
end

return GoldService