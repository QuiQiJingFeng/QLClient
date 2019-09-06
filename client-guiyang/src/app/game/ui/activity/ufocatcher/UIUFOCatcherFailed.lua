local UtilsFunctions = require("app.game.util.UtilsFunctions")
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherFailed.csb"

---@class UIUFOCatcherFailed:UIBase
local UIUFOCatcherFailed = super.buildUIClass("UIUFOCatcherFailed", csbPath)
function UIUFOCatcherFailed:init()
    UtilsFunctions.attachCloseButton(self, true)
    UtilsFunctions.attachCloseButton(self, true, "Button_Ensure")

    self._content = seekNodeByName(self, "Text_Content")
end

function UIUFOCatcherFailed:onShow(args)
    -- todo change content
    local text = args.isHalfwayFailed
    self._hideCallback = args.callback
end

function UIUFOCatcherFailed:onHide()
    if self._hideCallback then
        self._hideCallback()
        self._hideCallback = nil
    end
end

function UIUFOCatcherFailed:needBlackMask()
    return true
end

return UIUFOCatcherFailed