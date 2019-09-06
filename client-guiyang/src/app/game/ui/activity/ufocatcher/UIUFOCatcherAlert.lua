local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherAlert.csb"

---@class UIUFOCatcherAlert:UIBase
local UIUFOCatcherAlert = super.buildUIClass("UIUFOCatcherAlert", csbPath)
function UIUFOCatcherAlert:init()
    ---@type UFOCatcherActivityService
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.UFO_CATCHER)
    -- close button
    UtilsFunctions.attachCloseButton(self, true)

    -- ensure button
    seekButton(self, "Button_Ensure", function()
        self:hideSelf()
    end)

    -- get chance button
    seekButton(self, "Button_Chance", function()
        self._service:sendCACCatchDollTaskREQ()
        self:hideSelf()
    end)
end

function UIUFOCatcherAlert:needBlackMask()
    return true
end

return UIUFOCatcherAlert