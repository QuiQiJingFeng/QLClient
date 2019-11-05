local super = require("core.TestCaseBase")
local cases = {}
cases["显示晋级页面"] = function ()
    UIManager:getInstance():show("UICampaignPromotion")
end

local UIMainTest = class("UIMainTest", super)

function UIMainTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    -- self:sorted({
    --     "example! hide btn Test",
    --     "example! show btn Test",
    -- })
end

return UIMainTest  