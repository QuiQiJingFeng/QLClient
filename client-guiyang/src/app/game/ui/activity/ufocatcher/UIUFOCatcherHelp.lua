local ScrollText = require("app.game.util.ScrollText")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherHelp.csb"

---@class UIUFOCatcherHelp:UIBase
local UIUFOCatcherHelp = super.buildUIClass("UIUFOCatcherHelp", csbPath)
function UIUFOCatcherHelp:init()
    -- close button
    UtilsFunctions.attachCloseButton(self, true)

    -----@type ScrollText
    --self._text = ScrollText.new(seekNodeByName(self, "Scroll_Text"), 25, true)
    --self._text:setString([[
    --
    --]])
end

function UIUFOCatcherHelp:onShow()
    game.service.TDGameAnalyticsService.getInstance():onEvent("UFOCatcher_Help_Show")
end

function UIUFOCatcherHelp:needBlackMask()
    return true
end


return UIUFOCatcherHelp