local LocalPushService = class("LocalPushService")
local ns = namespace("game.service")
ns.LocalPushService = LocalPushService


local pushDefine = class("pushDefine")
local daySeconds = 24 * 3600
local pushType = {
    newPlayerNextDay = 8,        --新玩家次日推送
    callNewPlayer = 9,      --新玩家三日未登录
    callOldPlayer = 10,     --召回旧玩家
}
local pushCondition = {
    new_player = 1, --新玩家
    old_player = 2, --老玩家
    all = 3,        --全部玩家
}
local otherPush ={
    --俱乐部签到推送
    clubSignPush = {
        id = 20,
        messages = {{title = "您有礼包未领取", content = "登录亲友圈领取专属奖励"}},
        timetype = "delay",
        day = 6,
        timeOfDay = "19:00:00",
        androidId = 30000020
    }
}
function pushDefine:ctor(id, day, timeOfDay, messages, android_id )
    self.id = id;
    self.android_id = android_id
    self.ios_id = ""..android_id
    self.timedelay = day * daySeconds  --延时时间，单位秒 \
    self.subTitle = ""
    local idx = math.ceil(#messages * math.random() )
    self.title = messages[idx].title      --标题
    self.message = messages[idx].content    --内容

    self:getCondition()

    self:getTimeFromStr(timeOfDay)   
    self:reDefineTime()
end

function pushDefine:getCondition()
    if self.id == pushType.newPlayerNextDay or self.id == pushType.callNewPlayer then
        self.condition = pushCondition.new_player
    elseif self.id == pushType.callOldPlayer then
        self.condition = pushCondition.old_player
    else
        self.condition = pushCondition.all
    end
end

function pushDefine:getTimeFromStr(timestr)
--     --切分时间
    if timestr == nil or timestr == "" then 
        return
    end

    local res_ddzultStrsList = {} 
    string.gsub(timestr, '[^' .. ":" ..']+', function(w) 
    	table.insert(res_ddzultStrsList, w) 
        end )

    self.hour = tonumber(res_ddzultStrsList[1])
    self.minute = tonumber(res_ddzultStrsList[2])
    self.second = tonumber(res_ddzultStrsList[3])
    self:reDefineTime()
end

--重新设定时间
function pushDefine:reDefineTime()
    local currentTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()/1000
    if self.id == pushType.callNewPlayer then
        currentTime = game.service.LocalPlayerService:getInstance():getCreateTime()/1000
    end
    local date = kod.util.Time.time2Date(currentTime + self.timedelay)
    self.year = date.year
    self.month = date.month
    self.day = date.day
end
--
function pushDefine:getPushInfo()
    -- if self.pushtype == pushType.delay then
    --     return titles[self.message_id],self.subTitle,messages[self.message_id],self.android_id,self.ios_id,self.timedelay
    -- else
    --     self:reDefineTime()
    --     return titles[self.message_id],self.subTitle,messages[self.message_id],self.android_id,self.ios_id,self.year,self.month,self.day,self.hour,self.minute,self.second
    -- end
    return self.title,self.subTitle,self.message,self.android_id,self.ios_id,self.year,self.month,self.day,self.hour,self.minute,self.second
end
--是否需要加入推送 
function pushDefine:needPush()
    if self.condition == pushCondition.new_player then
        local createTime = game.service.LocalPlayerService:getInstance():getCreateTime()/1000
        local now = kod.util.Time.now()
        if now - createTime > 7 * daySeconds then
            return false
        end
    elseif self.condition == pushCondition.old_player then
        local createTime = game.service.LocalPlayerService:getInstance():getCreateTime()/1000
        local now = kod.util.Time.now()
        if now - createTime < 7 * daySeconds then
            return false
        end
    end
    return true
end
function pushDefine:getPushType()
    return self.pushtype
end

function LocalPushService:getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getLocalPushService()
    end

    return nil
end


function LocalPushService:ctor()
    self._certificationStatus = false

    self._pushInfos = {}
end


function LocalPushService:initialize()
    local requestManager = net.RequestManager.getInstance();

    requestManager:registerResponseHandler(net.protocol.GCPushParameterSYN.OP_CODE, self, self._onReceivePushInfo);    --分享信息
end

function LocalPushService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function LocalPushService:_onReceivePushInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    
    local androidId = 30000001
    self._pushInfos = {}
    for i = 1, #protocol.parameters do
        local param = protocol.parameters[i]
        -- pushDefine.new("new_player_call_next_day", pushType.timeset, 30000001, "30000001", 0, "-1/-1/-1/19/00/00",pushCondition.new_player)
        for j = 1, #param.day do
            local info = pushDefine.new(param.id, param.day[j], param.timeOfDay, param.messages, androidId)
            table.insert(self._pushInfos, info)
            androidId = androidId+1
        end
    end

    if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() then
        -- for _,val in pairs(self._pushInfos) do
        --     game.service.JPushService:getInstance():removeLocalNotification(val.android_id,val.ios_id)
        -- end	
        game.service.JPushService:getInstance():clearLocalNotifications()
        game.service.JPushService:getInstance():registerAllLocalNotification()
    end
end

function LocalPushService:getLocalPushInfo()
    return self._pushInfos
end

function LocalPushService:addOtherPush(pushName)
    if otherPush[pushName] == nil then
        return
    end
    self:removeOtherPush(pushName)
    local param = otherPush[pushName]
    local val =  pushDefine.new(param.id, param.day, param.timeOfDay, param.messages, param.androidId)
    local title, subtitle, dec, notificationId, identifier, year, month, day, hour, minute, second = val:getPushInfo()
    game.service.JPushService:getInstance():addTimeLocalNotification(title, subtitle, dec, notificationId, identifier, year, month, day, hour, minute, second, "")	
end

function LocalPushService:removeOtherPush(pushName)
    if otherPush[pushName] == nil then
        return
    end
    local id = otherPush[pushName].androidId
    game.service.JPushService:getInstance():removeLocalNotification(id,""..id)
end