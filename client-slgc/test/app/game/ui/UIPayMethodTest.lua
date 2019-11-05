local super = require("core.TestCaseBase")
local cases = {}

cases["Display PayMethod Window"] = function ()
    UIManager:getInstance():show("UIPayMethod",{
        {payType = 1, status = 3},
        {payType = 2, status = 4}
    })    
end

local UIPayMethodTest = class("UIPayMethodTest", super)

function UIPayMethodTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UIPayMethodTest

