--[[0
    跑马灯需要注意的地方：
    1、什么时候添加：由服务器发送，由文件中读取（实际上还是由Server发送的，不过会重新整理下字段）
    2、什么时候删除：在开始定时跑马灯的时候，会删除已经过期的跑马灯（结束时间小于当前时间）
    3、什么时候播放：在接受到服务器推送时，在切换状态机时
    4、播放多少次：多少次由客户端计算，通过 开始时间与结束时间和间隔时间来计算
    5、播放完了做了什么：什么也不做
]]
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local Array = require("ds.Array")
local Map = require("ds.Map")
local bit = require("bit")
local ns = namespace("game.service")
local M = class("MarqueeService")
local SAVE_KEY = "Marquee_Key_v20180921"
ns[M.__cname] = M

M.ShowType = {
    LOBBY_SCENE = 2 ^ 0, -- 大厅主界面
    CLUB_SCENE = 2 ^ 1, -- 俱乐部主界面
    CAMPAIGN_SCENE = 2 ^ 2, -- 比赛场主界面
    GOLD_SCENE = 2 ^ 3, -- 金币场主界面
    LOBBY_ROOM = 2 ^ 4, -- 大厅牌局
    CLUB_ROOM = 2 ^ 5, -- 俱乐部牌局
    CAMPAIGN_ROOM = 2 ^ 6, -- 比赛场牌局
    GOLD_ROOM = 2 ^ 7, -- 金币场牌局
    ALL_SCENE = 2 ^ 9 - 1, -- 全部场景
}

-- 对应客户端本地的 lobbyType 和 roomType
M.ShowTypePeerTable = {
    [game.globalConst.LobbyType.Normal] = M.ShowType.LOBBY_SCENE,
    [game.globalConst.LobbyType.Gold] = M.ShowType.GOLD_SCENE,
    [game.globalConst.LobbyType.Campaign] = M.ShowType.CAMPAIGN_SCENE,
    [game.globalConst.LobbyType.Club] = M.ShowType.CLUB_SCENE,

    [game.globalConst.roomType.normal] = M.ShowType.LOBBY_ROOM,
    [game.globalConst.roomType.gold] = M.ShowType.GOLD_ROOM,
    [game.globalConst.roomType.campaign] = M.ShowType.CAMPAIGN_ROOM,
    [game.globalConst.roomType.club] = M.ShowType.CLUB_ROOM,
}

M.Style = {
    Normal = 0,
    Advance = 1, -- 火箭造型
}

local MarqueeStruct = class("MarqueeStruct")
MarqueeStruct.REPEAT_FOREVER = 0xFFFF
function MarqueeStruct:ctor(_data)
    self.id = _data.id
    -- area -> areaId 规范下
    self.areaId = _data.area
    self.showType = _data.showType -- 场景值，可混合多个场景
    self.style = _data.baseMapType -- 对应 M.Style
    self.color = _data.color
    self.text = _data.msg

    -- 为了规范下秒与毫秒，修改了字段名
    self.intervalTimeMS = _data.intervalTime * 1000
    self.startTimeMS = _data.startDate -- 可能为0
    self.endTimeMS = _data.endDate -- 外部其实可以不使用 可能为0
    self.sendType = _data.sendType -- 时间类型（0：固定时间点，1：每日，2：即时发送，错过就忽略）

    self.repeatCount = 1 -- 默认为1次

    -- 若没有开始时间，则默认为当前时间的0.5s之后开始
    if self.startTimeMS == 0 then
        self.startTimeMS = kod.util.Time.nowMilliseconds() + 500
    end

    -- 若没有结束时间，则结束时间为开始时间 + 500ms
    if self.endTimeMS == 0 then
        self.endTimeMS = self.startTimeMS + 500
    end

    -- 若有间隔时间，则重新计算重复次数
    if self.intervalTimeMS ~= 0 then
        self.repeatCount = math.abs(math.floor((self.endTimeMS - self.startTimeMS) / self.intervalTimeMS))

        -- 为了防止计算错误，检测下
        if self.repeatCount < 1 then
            self.repeatCount = 1
        end
    end
end

-- 获得头部延迟时间秒数
function MarqueeStruct:getHeadDelaySecondTimeForNow()
    local nowMS = kod.util.Time.nowMilliseconds()
    local ret = math.floor((self.startTimeMS - nowMS) * 0.001)
    if ret < 0 then
        -- 小于0则是已经开始了，但是为结束的
        return 0
    else
        return ret
    end
end

-- 是否过期
function MarqueeStruct:isOverdue()
    if self.sendType == 1 then
        return false
    else
        local nowMS = kod.util.Time.nowMilliseconds()
        -- local offset = 2000
        return nowMS > self.endTimeMS
    end
end

function MarqueeStruct:toString()
    return UtilsFunctions.toString(self)
end

-- 最终保存在xml文件中的数据结构， array 类型的反序列化的时候会进行一次转换， 参见 Array.resumeFromStorage
local SavedStruct = class("SavedStruct")
function SavedStruct:ctor()
    self.version = 0
    self.marqueeArray = Array.new()
end


function M:getInstance()
    return game.service.LocalPlayerService.getInstance():getMarqueeService()
end

function M:ctor()
    self._savedStruct = SavedStruct.new()
    self._timerArray = Array.new()
end

-- 初始化
function M:initialize()
    local requestManager = net.RequestManager.getInstance()
    -- 监听跑马灯同步消息
    requestManager:registerResponseHandler(net.protocol.GCMarqueeVersionSYNC.OP_CODE, self, self._onGCMarqueeVersionSYNC)
    -- 监听跑马灯请求响应
    requestManager:registerResponseHandler(net.protocol.GCMarqueeRES.OP_CODE, self, self._onGCMarqueeRES)
    -- 亲友圈推送的特殊跑马灯
    requestManager:registerResponseHandler(net.protocol.CLCMarqueeSYNC.OP_CODE, self, self._onCLCMarqueeSYNC)

    GameFSM:getInstance():addEventListener("GAME_STATE_CHANGED", handler(self, self._onEventGameStateChanged), self);
end

function M:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    GameFSM:getInstance():removeEventListenersByTag(self)
    self:_cleanSchedule()
end

function M:clear()
    self:_cleanSchedule()
end

--[[0
    清空定时任务，但是不会删除正常播放的跑马灯
]]
function M:_cleanSchedule()
    self._timerArray:forEach(function(item, index, array)
        item:stopAllActions()
        item:removeFromParent(true)
    end)
    self._timerArray:clear()

    -- 已播放的跑马灯就不暂停了
    -- local marqueeUI = UIManager:getInstance():getUI("UIMarqueeTips")
    -- if nil ~= marqueeUI then
    --     marqueeUI:hideImmediately()
    -- end
end

--[[0
    设置跑马灯版本号，所以的跑马灯共用一个版本号,
    当需要增加或者删除一个跑马灯的时候会通过 GCMarqueeVersionSYNC 来推送
]]
function M:setServerVersion(version)
    if version == self._savedStruct.version then
        self:_scheduleMarquee()
    else
        self:sendCGMarqueeREQ()
    end
end

-- 发送获得跑马灯数据请求
function M:sendCGMarqueeREQ()
    net.NetworkRequest.new(net.protocol.CGMarqueeREQ, game.service.LocalPlayerService:getInstance():getGameServerId()):setBuffer({
        version = self._savedStruct.version
    }):execute()
end

--[[0
    当接收到跑马灯的版本号变化，
    协议中携带了一个跑马灯数据，若与本地版本相差为1时，根据携带的跑马灯数据类型，进行变化
    若版本差为1以上时，重新请求跑马灯
]]
function M:_onGCMarqueeVersionSYNC(response)
    local buffer = response:getBuffer()
    if buffer.version ~= self._savedStruct.version then
        local diff = math.abs(buffer.version - self._savedStruct.version)
        -- 仅当相差一个版本的时候才修改，否则全部重新请求
        if diff == 1 then
            self:_modifyMarqueeArray(response)
        else
            self:sendCGMarqueeREQ()
        end
    end
end

--[[0
    当接收到跑马灯消息时
]]
function M:_onGCMarqueeRES(response)
    local buffer = response:getBuffer()
    self._savedStruct.version = buffer.version
    self._savedStruct.marqueeArray:clear()

    for _, item in ipairs(buffer.marquees) do
        self._savedStruct.marqueeArray:add(MarqueeStruct.new(item))
    end

    self:_saveLocalStorage()
    self:_scheduleMarquee()
end

--[[0
    当接收到亲友圈的跑马灯消息时
]]
function M:_onCLCMarqueeSYNC(response)
    -- local buffer = response:getBuffer()
    -- self._savedStruct.marqueeArray:add(MarqueeStruct.new(buffer.marquee))
    -- self:_saveLocalStorage()
    -- self:_scheduleMarquee()
end

--[[0
    每次切换界面都重新设置跑马灯
]]
function M:_onEventGameStateChanged(event)
    self:_scheduleMarquee()
end

--[[0
    修改单个跑马灯，根据 id 去区别
]]
function M:_modifyMarqueeArray(response)
    local buffer = response:getBuffer()
    local marquee = buffer.marquee

    if buffer.opType == net.protocol.MarqueeOpType.ADD then
        -- 如果是 add ，可能发重复 id 的吗？那不就是 change 了吗
        -- todo 这里没有区分 marquee 的 style
        self._savedStruct.marqueeArray:add(MarqueeStruct.new(marquee))

    elseif buffer.opType == net.protocol.MarqueeOpType.CHANGE then
        self._savedStruct.marqueeArray:replaceIf(function(item, index, array)
            return item.id == marquee.id
        end, MarqueeStruct.new(marquee), true)

    elseif buffer.opType == net.protocol.MarqueeOpType.REMOVE then
        self._savedStruct.marqueeArray:removeIf(function(item, index, array)
            return item.id == marquee.id
        end, true)
    end

    -- update version & save in storage
    self._savedStruct.version = buffer.version
    self:_saveLocalStorage()

    -- schedule marquee
    self:_scheduleMarquee()
end

function M:_saveLocalStorage()
    manager.LocalStorage.setUserData(game.service.LocalPlayerService:getInstance():getRoleId(), SAVE_KEY, self._savedStruct)
end

--[[0
    从文件中读取存储的跑马灯数据，
    因为文件中存储格式为 json ，所以读取进行序列化是，要进行一次转换（类中类，嵌套类需要转换）
]]
function M:loadLocalStorage()
    local savedStruct = manager.LocalStorage.getUserData(game.service.LocalPlayerService:getInstance():getRoleId(), SAVE_KEY, SavedStruct)
    if nil ~= savedStruct then
        self._savedStruct = savedStruct
        self._savedStruct.marqueeArray = Array.resumeFromStorage(self._savedStruct.marqueeArray, MarqueeStruct)
    end
end

--[[0
    开启跑马灯的定时任务
    这里会忽略过滤一些符合条件的进行操作
]]
function M:_scheduleMarquee()
    self:_cleanSchedule()

    Logger.debug("=======START Schedule Marquee ==============")
    Logger.debug(self._savedStruct.marqueeArray:toString('\n'))


    local nowMS = kod.util.Time.nowMilliseconds()
    local oneDayMS = 24 * 60 * 60 * 1000

    -- 删除过期的
    self._savedStruct.marqueeArray:removeIf(function(item, index, array)
        return item:isOverdue()
    end, true)
    -- 删除完了保存下
    self:_saveLocalStorage()

    -- 过滤
    local arr = self._savedStruct.marqueeArray:filter(function(item, index, array)
        local diff = item.startTimeMS - nowMS
        if diff < 0 then
            -- 已经过了开始时间，但是未过期的
            return true
        elseif diff > 0 and diff <= oneDayMS then
            -- 开始时间在记下来的24小时以内
            return true
        else
            return false
        end
    end)

    local scene = cc.Director:getInstance():getRunningScene()
    for _, item in ipairs(arr) do
        local timer = self:_createMarqueeTimer(item)
        self._timerArray:add(timer)
        scene:addChild(timer)
    end
end

--[[0
    创建跑马灯定时器（实际上是 cocos 的 action， 每一个跑马灯都由一个 node 去 run， node 由此 service 去维护）
]]
function M:_createMarqueeTimer(marqueeStruct)
    local call_func = function()
        self:_marqueeTimerHandler(marqueeStruct)
    end

    local head_delay_sec = marqueeStruct:getHeadDelaySecondTimeForNow()
    local repeat_count = marqueeStruct.repeatCount
    local interval_delay_sec = marqueeStruct.intervalTimeMS * 0.001

    local action = cc.Sequence:create(
    cc.DelayTime:create(head_delay_sec),
    cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(call_func), cc.DelayTime:create(interval_delay_sec)), repeat_count)
    )
    Logger.debug("+++++++ Create Marquee Timer ++++++")
    Logger.debug("head_delay_sec = " .. tostring(head_delay_sec))
    Logger.debug("repeat_count = " .. tostring(repeat_count))
    Logger.debug("interval_delay_sec = " .. tostring(interval_delay_sec))
    local timer = cc.Node:create()
    timer:runAction(action)
    return timer
end

--[[0
    跑马灯定时器的 handler
    当定时器响应时调用
]]
function M:_marqueeTimerHandler(marqueeStruct)
    if self:_marqueeCanShowAtCurrentScene(marqueeStruct) then
        local uiKey = "UIMarqueeTips"
        if marqueeStruct.style == M.Style.Normal then
            uiKey = "UIMarqueeTips"
        elseif marqueeStruct.style == M.Style.Advance then
            uiKey = "UIAdvancedMarqueeTips"
        end
        -- 如果正在播放，这次的定时执行忽略掉
        if UIManager:getInstance():getIsShowing(uiKey) then
            return
        else
            UIManager:getInstance():show(uiKey, marqueeStruct)
        end
    end
end

--[[0
    当前场景是否能够显示传入的跑马灯
]]
function M:_marqueeCanShowAtCurrentScene(marqueeStruct)
    local showType = marqueeStruct.showType

    -- 方便debug，存一下合法的所有场景key
    local sceneKeys = {}
    for _key, value in pairs(M.ShowType) do
        if bit.band(value, showType) ~= 0 and showType >= value then
            table.insert(sceneKeys, _key)
        end
    end

    -- dump(sceneKeys)

    if showType == M.ShowType.ALL_SCENE then
        return true
    end

    local service = game.service.LocalPlayerService.getInstance()
    local lobbyType = service:getCurrentLobbyType()
    local roomType = service:getCurrentRoomType()

    local sceneValue = nil
    if lobbyType ~= game.globalConst.LobbyType.None then
        sceneValue = M.ShowTypePeerTable[lobbyType]
    elseif roomType ~= game.globalConst.roomType.none then
        sceneValue = M.ShowTypePeerTable[roomType]
    end

    -- 先修复下这个问题， 因为线上有卡顿现象， 具体原因后续再查
    if sceneValue then
        return bit.band(showType, sceneValue) ~= 0
    else
        return false
    end

    -- -- 两者只可能有一种为空
    -- if Macro.assertFalse(sceneValue, 'lobby type and room type are nil value') then
    --     return bit.band(showType, sceneValue) ~= 0
    -- end
end