-- 比赛场晋级页面测试用例
local super = require("core.TestCaseBase")
local cases = {}

cases["收到一些奖励"] = function ()
    local event = {}
    event = {
        result = net.ProtocolCode.ACC_GOD_OF_WEALTH_RECORD_SUCCESS;
        rewards = {
            {
                itemId = 0x0F000001,
                count = 10,
                time = 0
            },
            {
                itemId = 0x0F000004,
                count = 1,
                time = 0
            }
        }
    }
    
    local resPack = net.protocol.ACCGodOfWealthRecordRES.new()
    resPack._protocolBuf = event
    local response = net.NetworkResponse.new(resPack)

    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:_onACCGodOfWealthRecordRES(response);
end

cases["摇奖"] = function ()
    local event = {}
    event = {
        result = net.ProtocolCode.ACC_GOD_OF_WEALTH_OPEN_SUCCESS;
        open = 2,
        rewards = {
            {
                itemId = 0x0F000001,
                count = 10,
                time = 0
            },
            {
                itemId = 0x0F000004,
                count = 1,
                time = 0
            }
        }
    }
    
    local resPack = net.protocol.ACCGodOfWealthInfoRES.new()
    resPack._protocolBuf = event
    local response = net.NetworkResponse.new(resPack)

    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:_onACCGodOfWealthOpenRES(response);
end

cases["次数减少"] = function ()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:dispatchEvent({name = "EVENT_SPRING_INVITED_WORSHIP",num = 3})
end

local UISpringFestivalInvitedOldTest = class("UISpringFestivalInvitedOldTest", super)

function UISpringFestivalInvitedOldTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UISpringFestivalInvitedOldTest