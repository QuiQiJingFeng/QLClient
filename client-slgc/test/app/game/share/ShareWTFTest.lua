local super = require("core.TestCaseBase")
local cases = {}

cases["请先点这个谢谢！！！"] = function ()
    -- 先加载测试config
    require("app.game.share.ShareTestConfig")
    -- 再把测试ui注入uiconfig中
    local UI_CONFIG = require("app.define.UIConfig")
    table.merge(UI_CONFIG, {
        UITestShareWTF = "app.game.share.UITestShareWTF"
    })
    return true
end

cases["HALL Test"] = function ()
	local data =
	{
		enter = share.constants.ENTER.HALL,
	}
    share.ShareWTF.getInstance():share(share.constants.ENTER.HALL, {data, data, data})
    return true
end

cases["TestCase_Single_System_ScreenShot"] = function ()
    share.ShareWTF.getInstance():share("TestCase_Single_System_ScreenShot")
end

cases["TestCase_System_ScreenShot"] = function ()
    share.ShareWTF.getInstance():share("TestCase_System_ScreenShot")
end

cases["TestCase_Special_1"] = function ()
    local function final()
        tlog.info("我是final里的为所欲为！！")
    end
    share.ShareWTF.getInstance():share("TestCase_Special_1", {"我是传入的为所欲为吧！"}, final, "UITestShareWTF")
end

cases["TestCase_Special_2"] = function ()
    share.ShareWTF.getInstance():share("TestCase_Special_2")
end

local ShareWTFTest = class("ShareWTFTest", super)

function ShareWTFTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    self:sorted({
        "请先点这个谢谢！！！",
        "HALL Test",
        "TestCase_Single_System_ScreenShot",
        "TestCase_System_ScreenShot",
        "TestCase_Special_1",
        "TestCase_Special_2",
    })
end

return ShareWTFTest