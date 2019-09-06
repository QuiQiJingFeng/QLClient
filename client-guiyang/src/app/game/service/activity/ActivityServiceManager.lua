local Map = require("ds.Map")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local singleton = UtilsFunctions.singleton

local SERVICES = {
    [net.protocol.activityServerType.COME_BACK] = "app.game.service.activity.ComebackActivityService",
    [net.protocol.activityServerType.MONTH_SIGN] = "app.game.service.activity.MonthSignActivityService",
    [net.protocol.activityServerType.TANA_BATA] = "app.game.service.activity.TanabataActivityService",
    [net.protocol.activityServerType.TURN_CARD] = "app.game.service.activity.TurnCardActivityService",
    [net.protocol.activityServerType.LUCKY_DRAW] = "app.game.service.activity.LuckyDrawActivityService",
    [net.protocol.activityServerType.WEEK_SIGN] = "app.game.service.activity.WeekSignActivityService",
    [net.protocol.activityServerType.NEW_SHARE] = "app.game.service.activity.NewShareActivityService",
    [net.protocol.activityServerType.BIND_PHONE] = "app.game.service.activity.BindPhoneActivityService",
    [net.protocol.activityServerType.GUIDE] = "app.game.service.activity.GuideActivityService",
    [net.protocol.activityServerType.CHRISTMAS] = "app.game.service.activity.ChristmasServiceActivity",
    [net.protocol.activityServerType.RED_PACK] = "app.game.service.activity.RedpackActivityService",
    [net.protocol.activityServerType.SPRING_INVITED] = "app.game.service.activity.SpringInvitedService",
    [net.protocol.activityServerType.CLUB_WEEK_SIGN] = "app.game.service.activity.ClubWeekSignActivityService",
    [net.protocol.activityServerType.COLLECT_CODE] = "app.game.service.activity.CollectCodeService",
    [net.protocol.activityServerType.WEN_JUAN] = "app.game.service.activity.QuestionnaireActivityService",
    [net.protocol.activityServerType.UFO_CATCHER] = "app.game.service.activity.UFOCatcherActivityService",
    [net.protocol.activityServerType.CLUB_KOI] = "app.game.service.activity.ClubKoiActivityService",
}

local ActivityServiceManager = wrap_class_namespace("game.service.activity", singleton(class("ActivityServiceManager")))
function ActivityServiceManager:initialize()
    if self._serviceMap == nil then
        self._serviceMap = Map.new()
        -- 初始化map
        for key, path in pairs(SERVICES) do
            local _class = require(path)
            if Macro.assertFalse(_class, "require activity class failed! path: " .. tostring(path)) then
                local value = _class.new()
                -- 绑定事件
                cc.bind(value, "event")
                value:initialize()
                self._serviceMap:put(key, value)
            end
        end
    end
end

function ActivityServiceManager:dispose()
    self._serviceMap:forEach(function(key, value)
        -- 解绑事件
        value:dispose()
        cc.unbind(value, "event")
    end)
    self._serviceMap:clear()
    self._serviceMap = nil
end

function ActivityServiceManager:getService(key)
    local obj = self._serviceMap:get(key)
    return obj
end

return ActivityServiceManager