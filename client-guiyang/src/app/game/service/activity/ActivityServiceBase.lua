--[[0
    Q: 如何绑定 event ?
    A: 在 ServiceManager 中统一绑定了
]]
---@class ActivityServiceBase
---@field public removeEventListenersByTag fun(self:ActivityServiceBase, tag:table):void
---@field public addEventListener fun(self:ActivityServiceBase, eventName:string, handler:function, tag:table|userdata):void
local ActivityServiceBase = class("ActivityServiceBase")
function ActivityServiceBase:ctor()
    -- 不希望子类实现这个方法
end

function ActivityServiceBase:initialize()
    Macro.assertFalse(false, "abstract method")
end

function ActivityServiceBase:dispose()
    Macro.assertFalse(false, "abstract method")
end

-- 这个是活动类型值， 定义在 Protocol_Activity 中， 为number值
function ActivityServiceBase:getActivityType()
    Macro.assertFalse(false, "abstract method")
end

function ActivityServiceBase:openActivityMainPage()
    Macro.assertFalse(false, "abstract method")
end

-- 这个是用来在 ActivityManagerService 做为 key 的，我也不知道为什么不用 activityType
function ActivityServiceBase:getActivityServerType()
    Macro.assetFalse(false, "abstract method")
end

function ActivityServiceBase:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

function ActivityServiceBase:isActivityOpening()
    local activityType = self:getActivityType()
    local activityService = game.service.ActivityService.getInstance()
    if activityService and activityType then
        return activityService:isActivitieswithin(activityType)
    end
    return false
end

function ActivityServiceBase:getEntranceNodeCSBPath()
end

return ActivityServiceBase