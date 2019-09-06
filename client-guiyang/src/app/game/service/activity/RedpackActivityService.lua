local super = require("app.game.service.activity.ActivityServiceBase")
local RedpackActivityService = class("RedpackActivityService", super)

-- 身份验证相关
-- 主要处理验证消息的收发，以及身份验证状态的存储

function RedpackActivityService:initialize()
    self._fMoney = 0.0       --目前的钱数
    self._fOpenMoney = 0.0      --拆到的钱数
    self._fWithDrawConfig = 0.0     --总钱
    self._arrInvitees = {} --邀请的玩
    self._resetTime = 0     --刷新时间
    self._alreadyShare = false  --是否已经领取过分享红包
    self._friendHuMoney = 0     --好友胡的钱
    self._openRecords = {}  --拆红包纪录
    self._withDrawRecords = {}  --提现记录
    self._fWithDrawMoney = 0 --提现金额
    self._bShowInvite = false --是否显示帮拆红包信息
    self._enterGameShow = false     --每日首次进游戏展示 
    self._newPlayerMoney = 0    --新玩家红包

    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCOpenRPInfoRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息    
    requestManager:registerResponseHandler(net.protocol.ACCOpenRedPackageRES.OP_CODE, self, self._onOpenRedPackage);    --拆红包信息
    requestManager:registerResponseHandler(net.protocol.ACCWithdrawRES.OP_CODE, self, self._onWithdrawInfo);    --拆红包信息
    requestManager:registerResponseHandler(net.protocol.ACCWithdrawRecordRES.OP_CODE, self, self._onWithdrawRecordInfo)  --纪录返回
end

function RedpackActivityService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function RedpackActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 申请活动信息
function RedpackActivityService:queryAcitivityInfo()
    local request = net.NetworkRequest.new(net.protocol.CACOpenRPInfoREQ, self:getServerId())
    request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea())
    game.util.RequestHelper.request(request)
end

-- 接收活动信息
function RedpackActivityService:_onReceiveAcivityInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    Logger.dump(protocol, "_onReceiveAcivityInfo~~")
    if protocol.result ==  net.ProtocolCode.ACC_OPEN_RP_INFO_SUCCESS then
        self:setMoney(protocol.money)
        self:setWithdrawConfig(protocol.withdrawConfig)
        self:setNewPlayerMoney(protocol.newMoney)
        self:setInviteInfo(protocol.invitees, protocol.openTips,protocol.huTips,protocol.newTips)
        self:setAlreadyShare(protocol.alreadyShare)
        self:setResetTime(protocol.resetTime)
        self:setFriendHuMoney(protocol.friendHuMoney)        
        if self._bShowInvite or protocol.newTips then
            return
        end
        if game.service.TimeService:getInstance():getCurrentTimeInMSeconds() > protocol.resetTime then
            UIManager:getInstance():show("UIRedpackOpen")
        elseif not protocol.alreadyShare then
            UIManager:getInstance():show("UIRedpackDetail")
        else
            UIManager:getInstance():show("UIRedpackFriends")
        end
    else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

-- 申请拆红包
function RedpackActivityService:queryOpenRedPackage(nType)
    local request = net.NetworkRequest.new(net.protocol.CACOpenRedPackageREQ, self:getServerId())
    request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea(), nType)
    game.util.RequestHelper.request(request)
end

-- 接收拆红包
function RedpackActivityService:_onOpenRedPackage(response)
    local protocol = response:getProtocol():getProtocolBuf()
    dump(protocol, "_onOpenRedPackage~~~~~~~~~")
    if protocol.result == net.ProtocolCode.ACC_OPEN_RED_PACKAGE_SUCCESS then
        if self._resetTime == 0 then
            self:setResetTime(kod.util.Time.nowMilliseconds() + 3600000 * 24)
        else
            self:setAlreadyShare(true)
        end
        self:setOpenMoney(protocol.money)
        if self._fOpenMoney > 0 then
            self:dispatchEvent({name = "EVENT_OPEN_REDPACKAGE"})
        end
    end    
end

--请求提现
function RedpackActivityService:queryWithDraw(money, bNew)
    local request = net.NetworkRequest.new(net.protocol.CACWithdrawREQ, self:getServerId())
    local long,lat = game.service.LocalPlayerService:getInstance():getGpsPosition()
    request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea(), money, tostring(long), tostring(lat), game.plugin.Runtime.getDeviceId(), bNew)
    game.util.RequestHelper.request(request)
end
function RedpackActivityService:_onWithdrawInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest():getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ACC_WITHDRAW_SUCCESS then        
        self:setWithDrawMoney(request.money)
        self:dispatchEvent({name="WITH_DRAW_SUCCEED"})
    elseif protocol.result == net.ProtocolCode.ACC_WITHDRAW_FAILED_BIND_PHONE_ERROR then
        game.ui.UIMessageTipsMgr.getInstance():showTips("提现需先绑定手机号")
        UIManager:getInstance():show("UIPhoneLogin", 1)
    else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end  
end

--请求纪录
function RedpackActivityService:queryRecord()
    local request = net.NetworkRequest.new(net.protocol.CACWithdrawRecordREQ, self:getServerId())
    request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea())
    game.util.RequestHelper.request(request)
end

function RedpackActivityService:_onWithdrawRecordInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()    
    if protocol.result == net.ProtocolCode.ACC_WITHDRAW_RECORD_SUCCESS then
        dump(protocol, "_onWithdrawRecordInfo~~~~~~~~")
        self:setOpenRecords(protocol.openRecords)
        self:setWithDrawRecords(protocol.withdrawRecords)
        self:dispatchEvent({name="REDPACK_RECORDS"})
    end
end
--红包总数
function RedpackActivityService:setTotalMoney(money)
    self._fTotalMoney = tonumber(money)
end
function RedpackActivityService:getTotalMoney()
    return self._fTotalMoney
end
--可提现的金额配置
function RedpackActivityService:setWithdrawConfig( config)
    self._fWithDrawConfig = {}
    self._fWithDrawConfig[1] = tonumber(config[1])
    self._fWithDrawConfig[2] = tonumber(config[3])
    self._fWithDrawConfig[3] = tonumber(config[2])
end
function RedpackActivityService:getWithdrawConfig()
    return self._fWithDrawConfig
end
--邀请玩家
function RedpackActivityService:setInviteInfo(invitees, openTips, huTips, newTips)
    self._arrInvitees = invitees
    if newTips then
        UIManager:getInstance():show("UIRedpackNewPlayer")
    elseif self._bShowInvite and openTips then
        UIManager:getInstance():show("UIRedpackCall", self._arrInvitees[#self._arrInvitees])
    elseif self._bShowInvite and huTips then
        UIManager:getInstance():show("UIRedpackCall", 1)
    end
end
function RedpackActivityService:getInviteInfo()
    return self._arrInvitees
end

--红包金额
function RedpackActivityService:setMoney(money)
    self._fMoney = tonumber(money)
    -- self._fMoney = math.floor(self._fMoney * 100)/100
    self._fTotalMoney = self._fMoney
end
function RedpackActivityService:getMoney()
    return self._fMoney
end
--拆的金额
function RedpackActivityService:setOpenMoney(money)
    
    self._fMoney = self._fMoney + tonumber(money)
    -- self._fMoney = math.floor(self._fMoney * 100)/100
    self._fOpenMoney = tonumber(money)
    -- self._fOpenMoney = math.floor(self._fOpenMoney * 100)/100
end
function RedpackActivityService:getOpenMoney()  
    return self._fOpenMoney
end
--刷新时间
function RedpackActivityService:setResetTime(time)
    self._resetTime = time
end
function RedpackActivityService:getResetTime()
    return self._resetTime
end
--设置是否已分享
function RedpackActivityService:setAlreadyShare(alreadyShare)
    self._alreadyShare = alreadyShare
end
function RedpackActivityService:getAlreadyShare()
    return self._alreadyShare
end
--提现成功
function RedpackActivityService:setWithDrawMoney(money)
    if tonumber(money) >= self._fWithDrawConfig[2] then
        self._fMoney = 0
        self._friendHuMoney = 0 
    elseif tonumber(money) > self._fWithDrawConfig[1] and tonumber(money) < self._fWithDrawConfig[2] then
        --抽的新手红包，啥都不做
        print("get new player redpackage")
    else
        self._fMoney = self._fMoney - money
        self._friendHuMoney = self._friendHuMoney - money
    end
    self._fWithDrawMoney = money
end
function RedpackActivityService:getWithDrawMoney()
    return self._fWithDrawMoney
end

--好友胡牌的钱
function RedpackActivityService:setFriendHuMoney(friendHuMoney)
    self._friendHuMoney = tonumber(friendHuMoney)
end
function RedpackActivityService:getFriendHuMoney()
    return self._friendHuMoney
end

--中奖记录
function RedpackActivityService:setOpenRecords(records)
    self._openRecords = records
    for i = 1,#self._openRecords do
        -- self._openRecords[i].money = math.floor(self._openRecords[i].money * 100)/100
        self._openRecords[i].money = tonumber(self._openRecords[i].money)
    end
end
function RedpackActivityService:getOpenRecords()
    return self._openRecords
end

--取现记录
function RedpackActivityService:setWithDrawRecords(records)
    self._withDrawRecords = records
    for i = 1,#self._withDrawRecords do
        self._withDrawRecords[i].money = tonumber(self._withDrawRecords[i].money)
    end
end
function RedpackActivityService:getWithDrawRecords()
    return self._withDrawRecords
end

function RedpackActivityService:setShowInvite(bShow)
    self._bShowInvite = bShow
end

function RedpackActivityService:getEnterShow()
	local bShow = self._enterGameShow;
	self._enterGameShow = true
	return bShow
end

function RedpackActivityService:setNewPlayerMoney(str)
    if str ~= nil and str ~= "" then
        self._newPlayerMoney = tostring(str)
    end
end

function RedpackActivityService:getNewPlayerMoney()
    return self._newPlayerMoney
end

function RedpackActivityService:doShare(func)
    local strUrl = config.UrlConfig.getRedPackUrl()

    kod.getShortUrl.doGet(strUrl, function(shortUrl, bSuccess)
        local data = {{url = shortUrl, shareInfo = "[限时红包]恭喜您获得15元现金红包!", shareContent = "快去邀请好友一起领现金吧!"}}
        if device.platform == "ios" then
            share.ShareWTF:getInstance():share(share.constants.ENTER.OPEN_REDPACKAGE, data, function() scheduleOnce(func,2.2) end)
        else
            share.ShareWTF:getInstance():share(share.constants.ENTER.OPEN_REDPACKAGE, data, function() scheduleOnce(func,1.0) end)
        end
    end)

end

return RedpackActivityService