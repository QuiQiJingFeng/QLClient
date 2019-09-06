local cases = {}
cases["Show UIConnectionMessageBox 50 times at one frame"] = function()
    for i = 1, 50 do
        local j = i
        local content = string.format("我是第%s次显示，点击确认或者取消后应该在日志区输出%s", j, j)
        UIManager:getInstance():show("UIConnectionMessageBox", content, { "确定" }, function()
            Logger.debug("index = " .. j)
        end)
    end
    return true
end

cases["show 50 times v2"] = function()
    local service = game.service.ConnectionService:getInstance()
    for j = 1, 50, 1 do
        local content = string.format("我是第%s次显示，点击按钮走的是正常的重连逻辑", j)
        service:_showRetryUI(content)
    end
    return true
end

local super = require("core.TestCaseBase")
local M = class("ConnectionServiceTest", super)
function M:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    return true
end


return M