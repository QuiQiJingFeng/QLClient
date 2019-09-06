local super = require("core.TestCaseBase")
local cases = {}

cases["saveNodeToPng Test"] = function ()
    local jpg = "saveNodeToPngTest.jpg"
    local sp = ccui.ImageView:create("art/activity/safeshare.jpg")
    saveNodeToPng(sp, function(filePath)
        tshould.equaltrue("The saveNodeToPngTest.jpg exists", tutils.file_exists(filePath))
    end, jpg)
    return true -- 异步看结果吧
end

-- cases[""] = function ()
    
-- end

local UtilsTest = class("UtilsTest", super)

function UtilsTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UtilsTest